#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <math.h>
#include <mpi.h> /* distributed computing */ 
#include <malloc.h>
#include <string.h>
#include <unistd.h> /* parse command line arguments */
#include <getopt.h> /* command line arguments */
#include <sys/stat.h>
#include <ctype.h>
#include <time.h>
#include <float.h>
#include <gsl/gsl_rng.h> /* random number generator using mt19937 */
#include <errno.h>
#include <search.h>
#include <hdf5.h> /* hdf5 output */
#include <complex.h> /* complex math */
#include <search.h>

/* all distances are in microns */
#define SCANAREA 2.27 /* size of the square scan area */
#define ELLIPSE_A 5.0 /* size of the illuminated area as an ellipse */
#define ELLIPSE_B 3.0
#define LAMBDA 0.600 /* wavelength of light */ 
#define PATHLEN 18.00 /* max path length */
#define ENTIREAREA 8.8281 /* the boundary of the region for which scatterers will be generated */
#define EPS (1e-12)

/* return a random double */
__inline double random_double_range(gsl_rng *r,double min, double max) {
  /* use the gsl (mersene twister) random number generator */
  return (max-min)*(gsl_rng_uniform(r))+min;
  /* use the standard unix rand() */
  //return ( (max-min)*(((double)rand())/(double)RAND_MAX) + min );
}

__inline int random_int(gsl_rng *r,int max){
  /* use the gsl (mersene twister) random number generator */
  return gsl_rng_uniform_int(r,max+1);
  /* use the standard unix rand() */
  //return (int)((rand()/(RAND_MAX+1.0))*(max+1));
}

/* a scatterer */
typedef struct {
  double x,y; /* scatterer position */
} scatterer_t;

/* plasmon structure for a single scattering event */
typedef struct { 
  double cosp,sinp; /* sums of the cos and sine of the phase */
  double phase; /* total phase */
  double pathlen; /* its total path length */
  int nscat; /* total number of scatterers it visits */
  int flags; /* flag to detect if we've been here before */
  double v; /* have we considered this plasmon before? */

} plasmon_t;

/* choose the next scatterer */
int nextscatt(gsl_rng *r,plasmon_t *plasmon,scatterer_t *scatt, int *scanidates, int n, int NSCAT){
  int i,ncanidates=0;
  double pathlen_tmp;

  /* find all canidate scatterers we could reach with our current pathlen */
  bzero(scanidates,NSCAT*sizeof(int));
  for(i=0;i<NSCAT;i++){
    //if(i==n){ continue; }
    /* we have to be able to reach it */
    pathlen_tmp=sqrt( 
	(scatt[n].x-scatt[i].x)*(scatt[n].x-scatt[i].x)
	+ (scatt[n].y-scatt[i].y)*(scatt[n].y-scatt[i].y));
    if(pathlen_tmp+plasmon->pathlen < PATHLEN){
      scanidates[ncanidates]=i;
      ncanidates++;
    }
  }
  /* exit if choose the same scatterer twice */
  if(ncanidates<2) { return -1; }
  i=random_int(r,ncanidates-1);
  if(scanidates[i]==n){ return -2; }
  return scanidates[i]; 
}

int compare_doubles(const void *a, const void *b){ 
  const double *da = (const double *) a; 
  const double *db = (const double *) b; 
  return (*da > *db) - (*da < *db);
}

/* print usage */
void usage(void){
  printf("\nUsage:\t ./scatter [OPTIONS ...]\n");
  printf("OPTIONS:\n");
  printf("  --random-seed   set random seed\n");
  printf("  --output-dir    output to directory\n");
  printf("  --events        number of events per scan point\n");
  printf("  --nscat         number of scatterers\n\n");
}

int main( int argc, char *argv[]) {

  int i,j,n,n_i,e,x_i,y_i,next_n,events = 0;
  double dt_tmp = 0;
  double x,y,ob_x,ob_y,f_t = 0;
  double cosp_tmp, sinp_tmp, pathlen_tmp = 0;
  complex double expp_tmp;
  double tp_tmp=0;
  int ncanidates = 0;
  int removed, totalremoved = 0;
  int SS, MS = 1;
  int CPOINTS = 360; /* how many weirdospace images to make in a circle */

  /* MPI initialization */
  int rank, nprocs;
  MPI_Init(&argc,&argv);
  MPI_Comm_size(MPI_COMM_WORLD,&nprocs);
  MPI_Comm_rank(MPI_COMM_WORLD,&rank);


  /* initialize default command line options */
  int rseed = 2532;
  //int rseed = 2531;
  char OUTPUT_DIR[FILENAME_MAX] = {0};
  int EVENTS = 100; /* events to trace out */
  int NSCAT = 20; /* number of scatterers */
  int c;
  static int verbose_flag;
  for(;;){ 
    static struct option long_options[] = { 
      {"verbose",no_argument,&verbose_flag, 1},
      {"brief", no_argument,&verbose_flag, 0},
      {"random-seed", required_argument, 0, 'r'}, 
      {"output-dir", required_argument, 0, 'd'}, 
      {"events", required_argument, 0, 'e'}, 
      {"nscat", required_argument, 0, 'n'},
      {"SS", no_argument, 0, 'w'},
      {"MS", no_argument, 0, 'x'},
      {0,0,0,0}
    };
    /* getopt_long stores the option index here. */ 
    int option_index = 0;

    c = getopt_long (argc, argv, "", long_options, &option_index);

    /* Detect the end of the options. */
    if(c==-1){ break; }
    switch(c){ 
      case 'w':
	SS=0;
	break;
      case 'x':
	MS=0;
	break;
      case 0:
	/* If this option set a flag, do nothing else now. */ 
	if (long_options[option_index].flag != 0) 
	  break; 
	printf ("option %s", long_options[option_index].name); 
	if (optarg) 
	  printf (" with arg %s", optarg); 
	printf ("\n");
	break;

      case 'r':
	rseed=strtol(optarg,(char**)NULL,10);
	if(errno==ERANGE){ 
	  if(rank==0){ printf("Invalid options to --random-seed\n"); usage(); }
	  abort();
	}
	break;
      case 'd':
	sprintf(OUTPUT_DIR,"%s",optarg);
	break;
      case 'e':
	EVENTS=strtol(optarg,(char**)NULL,10);
	if(errno==ERANGE){ 
	  if(rank==0){ printf("Invalid options to --events\n"); usage(); }
	  abort();
	}
	break;
      case 'n':
	NSCAT=strtol(optarg,(char**)NULL,10);
	if(errno==ERANGE){ 
	  if(rank==0){ printf("Invalid options to --nscat\n"); usage(); }
	  abort();
	}
	break;
      case '?':
	/* getopt_long already printed an error message. */
	break;
      default:
	if(rank==0){ usage(); }
	abort();
    }
  }

  /* Print any remaining command line arguments (not options). */
  if(optind<argc){ 
    printf ("non-option ARGV-elements: "); 
    while(optind < argc){ 
      printf ("%s ", argv[optind++]); 
      putchar ('\n'); 
    }
    if(rank==0){ usage(); }
    abort();
  }

  if(strlen(OUTPUT_DIR)!=0){ mkdir(OUTPUT_DIR,0777); }

  /* initialize the random number generator */
  const gsl_rng_type *T;
  gsl_rng *r;
  gsl_rng_env_setup();
  T = gsl_rng_default;
  r = gsl_rng_alloc(T);

  /* seed both rngs */
  gsl_rng_set(r,rseed); 
  srand(rseed);

  complex double *ws_buf = malloc(CPOINTS*sizeof(complex double)); /* weirdospace */
  complex double *ws_buf_root = malloc(CPOINTS*sizeof(complex double));

  if(ws_buf==NULL) { 
    printf("could not allcate memory for ws_buf\n");
    return -1; 
  }
  if(ws_buf_root==NULL){ 
    printf("could not allcate memory for ws_buf_root\n");
    return -1; 
  }
  bzero(ws_buf_root,CPOINTS*sizeof(complex double));
  bzero(ws_buf,CPOINTS*sizeof(complex double));

  /* seed the scatterers */
  scatterer_t *scatt = malloc(NSCAT*sizeof(scatterer_t));
  if(scatt==NULL){ 
    printf("could not allcate memory for scatt\n");
    return -1; 
  }

  char filename[FILENAME_MAX];

  i=0;while(i<NSCAT){
    /* random distribution of scatterers */
    scatt[i].x=random_double_range(r,-ENTIREAREA/2.0,ENTIREAREA/2.0);
    scatt[i].y=random_double_range(r,-ENTIREAREA/2.0,ENTIREAREA/2.0);
    i++;
  } 

  /* scatterer canidates */
  int *scanidates = malloc(NSCAT*sizeof(int)); 
  if(scanidates==NULL){ 
    printf("could not allocate memory for scanidates\n");
    return -1; 
  }

  /* initial scatterer canidates */
  int *iscanidates = malloc(NSCAT*sizeof(int)); 
  if(iscanidates==NULL){ 
    printf("could not allocate memory for iscanidates\n");
    return -1;
  }
  bzero(iscanidates,NSCAT*sizeof(int));


  /* now that all the processes have the same random scatterers, we want to
   * adjust the seed so that each run will give us different results */
  srand(rseed+rank*1000);
  gsl_rng_set(r,rseed+rank*1000);

  /* our plasmon */
  plasmon_t *plasmon = malloc(sizeof(plasmon_t));
  if(plasmon==NULL){ 
    printf("could not allocate memory for plasmon\n");
    return -1; 
  }


  /* get a list of all scatterers that are in the illuminated region.  Note
   * that we are guaranteed at least one because of the tip scatterer */
  double theta;
  ncanidates=0;
  for(i=0;i<NSCAT;i++){
    theta=atan(scatt[i].y/scatt[i].x);
    if(sqrt(scatt[i].x*scatt[i].x+scatt[i].y*scatt[i].y) < 
	(ELLIPSE_A*ELLIPSE_B)/sqrt(ELLIPSE_B*ELLIPSE_B*cos(theta)*cos(theta)
	  + ELLIPSE_A*ELLIPSE_A*sin(theta)*sin(theta))){
      iscanidates[ncanidates]=i;
      ncanidates++;
    }
  }
  /* accumulate the effect over EVENTS events */
  events=0;
  while(events<EVENTS){
    int includestip = 0;
    bzero(plasmon,sizeof(plasmon_t));

    /* first scatterer */
    n=iscanidates[random_int(r,ncanidates-1)];

    plasmon->phase+=scatt[n].x;
    plasmon->nscat++;

    /* run around until we're out of path length or we choose the same
     * scatterer twice */
    for(;;){
      next_n=nextscatt(r,plasmon,scatt,scanidates,n,NSCAT);
      if(next_n==-1){ next_n=n; break; }
      if(next_n==-2){ includestip=1; next_n=n; break; }

      plasmon->phase+=sqrt(
	  (scatt[n].x-scatt[next_n].x)*(scatt[n].x-scatt[next_n].x)
	  + (scatt[n].y-scatt[next_n].y)*(scatt[n].y-scatt[next_n].y));

      plasmon->pathlen+=pathlen_tmp;
      plasmon->nscat++;
      n=next_n;
    }

    if(SS){
      /* single scattering including the tip */
      if(plasmon->nscat==1){
	bzero(plasmon,sizeof(plasmon_t));
	continue;
      }
    }

    if(MS){
      /* multiple scattering including the tip */
      if(plasmon->nscat>1){
	bzero(plasmon,sizeof(plasmon_t));
	continue;
      }
    }


  /* move around in a circle */
  double c_t;
  double c_dt=(2*M_PI)/CPOINTS;
  for(e=0,c_t=0;c_t<2*M_PI;c_t+=c_dt,e++){
    dt_tmp=(scatt[n].x*cos(c_t)+scatt[n].y*sin(c_t));
    ws_buf[e]+=cexp(2.0i*M_PI/LAMBDA*(plasmon->phase+dt_tmp));
  }


    events++;
  } 

  /* done with a single point */

  /* combine all the event runs */
  MPI_Reduce(ws_buf,ws_buf_root,CPOINTS,MPI_DOUBLE_COMPLEX,MPI_SUM,0,MPI_COMM_WORLD);

  if(rank==0){
    FILE *out;
    /* paramter file just in case we forgot what we ran this program with */
    double div = EVENTS;
    memset(&filename,0,FILENAME_MAX*sizeof(char));
    if(strlen(OUTPUT_DIR)!=0){
      sprintf(filename,"%s/parameters",OUTPUT_DIR);
    }
    else{ sprintf(filename,"parameters"); }
    out=fopen(filename,"w");
    fprintf(out,"[SCANAREA]\t%lf\n",(double)SCANAREA);
    fprintf(out,"[ELLIPSE_A]\t%lf\n",(double)ELLIPSE_A);
    fprintf(out,"[ELLIPSE_B]\t%lf\n",(double)ELLIPSE_B);
    fprintf(out,"[LAMBDA]\t%lf\n",(double)LAMBDA);
    fprintf(out,"[PATHLEN]\t%lf\n",(double)PATHLEN);
    fprintf(out,"[ENTIREAREA]\t%lf\n",(double)ENTIREAREA);
    fprintf(out,"[EVENTS]\t%d\n",EVENTS);
    fprintf(out,"[NSCAT]\t%d\n",NSCAT);
    fprintf(out,"[REMOVED]\t\n");
    fprintf(out,"\n");

    fprintf(out,"[SCATTERERS]\n");
    for(i=1;i<NSCAT;i++){
      fprintf(out,"%g\t%g\n",scatt[i].x,scatt[i].y); 
    }
    fprintf(out,"[STATS]\n");
    fclose(out);

    /* output all the HDF files */
    memset(&filename,0,FILENAME_MAX*sizeof(char));
    if(strlen(OUTPUT_DIR)!=0){
      sprintf(filename,"%s/out.dat",OUTPUT_DIR);
    }
    else{ sprintf(filename,"out.dat"); }
    out=fopen(filename,"w");

    for(i=0;i<CPOINTS;++i){
      fprintf(out,"%g\n",cabs(ws_buf[i])*abs(ws_buf[i]));
    }
    fclose(out);
  }

  //gsl_rng_free(r);
  MPI_Finalize();

  return 0;
}
