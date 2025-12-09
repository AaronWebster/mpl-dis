/*
 * scatter_modern.c
 * A robust, optimized simulation of plasmon scattering events.
 *
 * Compile with:
 * gcc -O3 -std=c11 -Wall -Wextra scatter_modern.c -o scatter -lgsl -lgslcblas -lm
 */

#define _POSIX_C_SOURCE 200809L // For mkdir, getopt, snprintf

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <complex.h>
#include <time.h>
#include <errno.h>
#include <getopt.h>
#include <sys/stat.h>
#include <sys/types.h>

#include <gsl/gsl_rng.h>

// --- Constants ---
#define SCAN_AREA       2.27
#define ELLIPSE_A       5.0
#define ELLIPSE_B       3.0
#define LAMBDA          0.600
#define PATH_LEN        18.00
#define ENTIRE_AREA     8.8281
#define EPS             1e-12
#define DEFAULT_CPOINTS 1000
#define DEFAULT_NSCAT   20
#define DEFAULT_SEED    2532
#define MAX_EVENTS      1000

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

// --- Data Structures ---

typedef struct {
    double x;
    double y;
} Scatterer;

typedef struct {
    double phase;
    int nscat;
} Plasmon;

typedef struct {
    // Configuration
    int verbose;
    unsigned long random_seed;
    char output_dir[1024];
    int n_scat;
    int single_scattering;   // Flag for SS
    int multiple_scattering; // Flag for MS
    
    // Internal State
    int events;
    int c_points;
    Scatterer *scatterers;
    int *candidates;
    int n_candidates;
    
    // Look-Up Tables (Optimization)
    double *cos_lut;
    double *sin_lut;
    
    // Results
    double complex *ws_buf;
    int *scatt_hist;
} SimContext;

// --- Helper Functions ---

static inline double random_double_range(gsl_rng *r, double min, double max) {
    return (max - min) * gsl_rng_uniform(r) + min;
}

static inline int random_int(gsl_rng *r, int max) {
    return gsl_rng_uniform_int(r, max + 1);
}

// Optimized magnitude squared calculation to avoid sqrt() calls
static inline double complex_mag_sq(double complex z) {
    double r = creal(z);
    double i = cimag(z);
    return r*r + i*i;
}

void print_usage(void) {
    printf("\nUsage:\t ./scatter [OPTIONS ...]\n");
    printf("OPTIONS:\n");
    printf("  --random-seed <int>   Set random seed (default: %d)\n", DEFAULT_SEED);
    printf("  --output-dir <path>   Output directory\n");
    printf("  --nscat <int>         Number of scatterers (default: %d)\n", DEFAULT_NSCAT);
    printf("  --SS                  Enable Single Scattering mode\n");
    printf("  --MS                  Enable Multiple Scattering mode (default)\n");
    printf("  --verbose             Enable verbose output\n");
    printf("  --help                Show this message\n\n");
}

// --- Initialization & Cleanup ---

int init_simulation(SimContext *ctx) {
    if (!ctx) return -1;
    
    // Allocations
    ctx->scatterers = malloc(ctx->n_scat * sizeof(Scatterer));
    ctx->candidates = malloc(ctx->n_scat * sizeof(int));
    ctx->ws_buf = calloc(ctx->c_points, sizeof(double complex)); // calloc zeroes memory
    ctx->scatt_hist = calloc(1000, sizeof(int)); // Assuming max depth 1000
    ctx->cos_lut = malloc(ctx->c_points * sizeof(double));
    ctx->sin_lut = malloc(ctx->c_points * sizeof(double));

    if (!ctx->scatterers || !ctx->candidates || !ctx->ws_buf || 
        !ctx->scatt_hist || !ctx->cos_lut || !ctx->sin_lut) {
        fprintf(stderr, "Error: Memory allocation failed.\n");
        return -1;
    }

    // Precompute Trigonometry Look-Up Tables (Huge Optimization)
    for (int i = 0; i < ctx->c_points; ++i) {
        double angle = (double)i * (2.0 * M_PI) / ctx->c_points;
        ctx->cos_lut[i] = cos(angle);
        ctx->sin_lut[i] = sin(angle);
    }

    return 0;
}

void cleanup_simulation(SimContext *ctx) {
    if (!ctx) return;
    free(ctx->scatterers);
    free(ctx->candidates);
    free(ctx->ws_buf);
    free(ctx->scatt_hist);
    free(ctx->cos_lut);
    free(ctx->sin_lut);
}

// --- Core Logic ---

void setup_scatterers(SimContext *ctx, gsl_rng *r) {
    // 1. Generate Random Scatterers
    for (int i = 0; i < ctx->n_scat; i++) {
        ctx->scatterers[i].x = random_double_range(r, -ENTIRE_AREA/2.0, ENTIRE_AREA/2.0);
        ctx->scatterers[i].y = random_double_range(r, -ENTIRE_AREA/2.0, ENTIRE_AREA/2.0);
    }

    // 2. Identify Candidates inside the Ellipse
    ctx->n_candidates = 0;
    double ellipse_factor_b = ELLIPSE_B * ELLIPSE_B;
    double ellipse_factor_a = ELLIPSE_A * ELLIPSE_A;
    double ab_prod = ELLIPSE_A * ELLIPSE_B;

    for (int i = 0; i < ctx->n_scat; i++) {
        double x = ctx->scatterers[i].x;
        double y = ctx->scatterers[i].y;
        double r_dist = sqrt(x*x + y*y);

        if (r_dist < EPS) continue; // Avoid division by zero

        double theta = atan2(y, x); // Use atan2 for correct quadrant
        double cos_t = cos(theta);
        double sin_t = sin(theta);
        
        double limit = ab_prod / sqrt(ellipse_factor_b * cos_t * cos_t + 
                                      ellipse_factor_a * sin_t * sin_t);

        if (r_dist < limit) {
            ctx->candidates[ctx->n_candidates++] = i;
        }
    }

    if (ctx->verbose) {
        printf("Setup complete. Found %d candidates out of %d scatterers.\n", 
               ctx->n_candidates, ctx->n_scat);
    }
}

void run_simulation(SimContext *ctx, gsl_rng *r) {
    double k_factor = 2.0 * M_PI / LAMBDA; // Precompute wavenumber

    // --- Single Scattering Mode ---
    if (ctx->single_scattering) {
        Plasmon p = {0};
        for (int i = 0; i < ctx->n_scat; ++i) {
            p.phase = ctx->scatterers[i].x;
            
            double complex term_phase = 0; 
            // Loop optimized using LUTs
            for (int e = 0; e < ctx->c_points; ++e) {
                double dt_tmp = ctx->scatterers[i].x * ctx->cos_lut[e] + 
                                ctx->scatterers[i].y * ctx->sin_lut[e];
                
                // Euler's formula: exp(i * x)
                ctx->ws_buf[e] += cexp(I * k_factor * (p.phase + dt_tmp));
            }
        }
    } 
    
    // --- Multiple Scattering Mode ---
    // Note: Logic preserved from original (while nscat < 2)
    else if (ctx->multiple_scattering) {
        if (ctx->n_candidates == 0) {
            fprintf(stderr, "Warning: No candidates found in illumination region.\n");
            return;
        }

        while (ctx->events < MAX_EVENTS) {
            Plasmon p = {0};

            // Pick first scatterer from candidates
            int n = ctx->candidates[random_int(r, ctx->n_candidates - 1)];
            
            p.phase += ctx->scatterers[n].x;
            p.nscat++;

            // Walk path
            while (p.nscat < 2) {
                int next_n = random_int(r, ctx->n_scat - 1);
                
                double dx = ctx->scatterers[n].x - ctx->scatterers[next_n].x;
                double dy = ctx->scatterers[n].y - ctx->scatterers[next_n].y;
                double dist = sqrt(dx*dx + dy*dy);

                p.phase += dist;
                p.nscat++;
                n = next_n;
            }

            if (p.nscat < 1000) {
                ctx->scatt_hist[p.nscat]++;
            }

            // Accumulate fields
            for (int i = 0; i < ctx->c_points; ++i) {
                double dt_tmp = ctx->scatterers[n].x * ctx->cos_lut[i] + 
                                ctx->scatterers[n].y * ctx->sin_lut[i];
                
                ctx->ws_buf[i] += cexp(I * k_factor * (p.phase + dt_tmp));
            }

            ctx->events++;
        }
    }
}

// --- Output ---

void save_results(SimContext *ctx) {
    char filepath[1024];
    FILE *fp;

    // 1. Parameters File
    if (strlen(ctx->output_dir) > 0) {
        snprintf(filepath, sizeof(filepath), "%s/parameters.txt", ctx->output_dir);
    } else {
        snprintf(filepath, sizeof(filepath), "parameters.txt");
    }

    fp = fopen(filepath, "w");
    if (fp) {
        fprintf(fp, "[SCANAREA]\t%lf\n", SCAN_AREA);
        fprintf(fp, "[ELLIPSE_A]\t%lf\n", ELLIPSE_A);
        fprintf(fp, "[ELLIPSE_B]\t%lf\n", ELLIPSE_B);
        fprintf(fp, "[LAMBDA]\t%lf\n", LAMBDA);
        fprintf(fp, "[PATHLEN]\t%lf\n", PATH_LEN);
        fprintf(fp, "[ENTIREAREA]\t%lf\n", ENTIRE_AREA);
        fprintf(fp, "[NSCAT]\t%d\n", ctx->n_scat);
        fprintf(fp, "[EVENTS]\t%d\n", ctx->events);
        fprintf(fp, "\n[SCATTERERS]\n");
        for (int i = 0; i < ctx->n_scat; i++) {
            fprintf(fp, "%g\t%g\n", ctx->scatterers[i].x, ctx->scatterers[i].y);
        }
        fclose(fp);
    } else {
        perror("Failed to write parameters");
    }

    // 2. Scattering Histogram
    if (strlen(ctx->output_dir) > 0) {
        snprintf(filepath, sizeof(filepath), "%s/scatthist.dat", ctx->output_dir);
    } else {
        snprintf(filepath, sizeof(filepath), "scatthist.dat");
    }

    fp = fopen(filepath, "w");
    if (fp) {
        for (int i = 0; i < 100; ++i) {
            fprintf(fp, "%d\n", ctx->scatt_hist[i]);
        }
        fclose(fp);
    }

    // 3. Output Data (Intensity)
    if (strlen(ctx->output_dir) > 0) {
        snprintf(filepath, sizeof(filepath), "%s/out.dat", ctx->output_dir);
    } else {
        snprintf(filepath, sizeof(filepath), "out.dat");
    }

    fp = fopen(filepath, "w");
    if (fp) {
        for (int i = 0; i < ctx->c_points; ++i) {
            // Optimization: Use custom norm squared
            fprintf(fp, "%g\n", complex_mag_sq(ctx->ws_buf[i]));
        }
        fclose(fp);
    }
}

// --- Main ---

int main(int argc, char *argv[]) {
    // Default Configuration
    SimContext ctx;
    memset(&ctx, 0, sizeof(SimContext));
    ctx.verbose = 0;
    ctx.random_seed = DEFAULT_SEED;
    ctx.n_scat = DEFAULT_NSCAT;
    ctx.single_scattering = 0;
    ctx.multiple_scattering = 1; // Default to MS
    ctx.c_points = DEFAULT_CPOINTS;
    ctx.output_dir[0] = '\0';

    // Argument Parsing
    static struct option long_options[] = {
        {"verbose",     no_argument,       0, 'v'},
        {"help",        no_argument,       0, 'h'},
        {"random-seed", required_argument, 0, 'r'},
        {"output-dir",  required_argument, 0, 'd'},
        {"nscat",       required_argument, 0, 'n'},
        {"SS",          no_argument,       0, 'S'},
        {"MS",          no_argument,       0, 'M'},
        {0, 0, 0, 0}
    };

    int c, option_index = 0;
    while ((c = getopt_long(argc, argv, "vhr:d:n:SM", long_options, &option_index)) != -1) {
        switch (c) {
            case 'v': ctx.verbose = 1; break;
            case 'h': print_usage(); return 0;
            case 'S': ctx.single_scattering = 1; ctx.multiple_scattering = 0; break;
            case 'M': ctx.multiple_scattering = 1; ctx.single_scattering = 0; break;
            case 'r':
                ctx.random_seed = strtoul(optarg, NULL, 10);
                if (errno == ERANGE) {
                    fprintf(stderr, "Invalid random seed.\n");
                    return 1;
                }
                break;
            case 'd':
                snprintf(ctx.output_dir, sizeof(ctx.output_dir), "%s", optarg);
                break;
            case 'n':
                ctx.n_scat = strtol(optarg, NULL, 10);
                if (errno == ERANGE) {
                    fprintf(stderr, "Invalid number of scatterers.\n");
                    return 1;
                }
                break;
            case '?':
                // getopt_long prints error
                return 1;
            default:
                abort();
        }
    }

    // Directory Creation
    if (strlen(ctx.output_dir) > 0) {
        struct stat st = {0};
        if (stat(ctx.output_dir, &st) == -1) {
            if (mkdir(ctx.output_dir, 0755) == -1 && errno != EEXIST) {
                perror("Could not create output directory");
                return 1;
            }
        }
    }

    // Initialize RNG
    gsl_rng_env_setup();
    const gsl_rng_type *T = gsl_rng_default;
    gsl_rng *r = gsl_rng_alloc(T);
    if (!r) {
        fprintf(stderr, "Failed to allocate RNG.\n");
        return 1;
    }
    gsl_rng_set(r, ctx.random_seed);

    // Run Simulation
    if (init_simulation(&ctx) != 0) {
        gsl_rng_free(r);
        return 1;
    }

    setup_scatterers(&ctx, r);
    run_simulation(&ctx, r);
    save_results(&ctx);

    if (ctx.verbose) {
        printf("Simulation complete. Results saved.\n");
    }

    // Cleanup
    cleanup_simulation(&ctx);
    gsl_rng_free(r);

    return 0;
}
