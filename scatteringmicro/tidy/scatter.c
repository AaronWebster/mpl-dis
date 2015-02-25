#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <math.h>
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
#include <signal.h>

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


double field_diff(complex double *a, complex double *b, int *event_bins, int CPOINTS){
  int i;
  double diff = 0;
  for(i=0;i<CPOINTS;++i){
    if(event_bins[i]>0){
      diff+=
	cabs(cabs(a[i])/(double)event_bins[i]-cabs(b[i])/(double)event_bins[i]);
    }
    else{
      diff+=100;
    }
  }
  return diff;
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
  int SS = 1;
  int MS = 1;
  int CPOINTS = 1000; /* how many weirdospace images to make in a circle */
  double tollerance = 1e-9;
  int scatthist[1000] = {0};

  /* initialize default command line options */
  int rseed = 2532;
  //int rseed = 2531;
  char OUTPUT_DIR[FILENAME_MAX] = {0};
  int NSCAT = 20; /* number of scatterers */
  int c;
  static int verbose_flag;
  for(;;){ 
    static struct option long_options[] = { 
      {"verbose",no_argument,&verbose_flag, 1},
      {"brief", no_argument,&verbose_flag, 0},
      {"random-seed", required_argument, 0, 'r'}, 
      {"output-dir", required_argument, 0, 'd'}, 
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
	  printf("Invalid options to --random-seed\n"); usage();
	  abort();
	}
	break;
      case 'd':
	sprintf(OUTPUT_DIR,"%s",optarg);
	break;
      case 'n':
	NSCAT=strtol(optarg,(char**)NULL,10);
	if(errno==ERANGE){ 
	  printf("Invalid options to --nscat\n"); usage(); 
	  abort();
	}
	break;
      case '?':
	/* getopt_long already printed an error message. */
	break;
      default:
	usage();
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
    usage(); 
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
  complex double *ws_buf_next = malloc(CPOINTS*sizeof(complex double)); /* weirdospace */
  int *event_bins = malloc(CPOINTS*sizeof(int)); 

  if(ws_buf==NULL) { 
    printf("could not allcate memory for ws_buf\n");
    return -1; 
  }
  bzero(ws_buf,CPOINTS*sizeof(complex double));
  bzero(ws_buf_next,CPOINTS*sizeof(complex double));
  bzero(event_bins,CPOINTS*sizeof(int));

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
  events=0;
  double diff = 100;
  int bingood = 1;
  double c_t;
  if(MS==0){
    bzero(plasmon,sizeof(plasmon_t));
    for(i=0;i<NSCAT;++i){
      plasmon->phase=scatt[i].x;
      plasmon->nscat++;
      for(e=0;e<CPOINTS;++e){
	double c_t = (double)e*(2.0*M_PI)/CPOINTS;
	dt_tmp=(scatt[i].x*cos(c_t)+scatt[i].y*sin(c_t));
	ws_buf[e]+=cexp(2.0i*M_PI/LAMBDA*(plasmon->phase+dt_tmp));
	event_bins[e]++;
      }

    }

  }
  else{
    while(events<1000){
      int includestip = 0;
      bzero(plasmon,sizeof(plasmon_t));

      /* first scatterer */
      n=iscanidates[random_int(r,ncanidates-1)];

      plasmon->phase+=scatt[n].x;
      plasmon->nscat++;

      /* run around until we're out of path length or we choose the same
       * scatterer twice */
      while(plasmon->nscat<2){
	next_n=random_int(r,NSCAT-1);
	  plasmon->phase+=sqrt(
	      (scatt[n].x-scatt[next_n].x)*(scatt[n].x-scatt[next_n].x)
	      + (scatt[n].y-scatt[next_n].y)*(scatt[n].y-scatt[next_n].y));

	  plasmon->nscat++;
	  n=next_n;
      }
      scatthist[plasmon->nscat]++;

      for(i=0;i<CPOINTS;++i){
	dt_tmp=(scatt[n].x*cos(i*2.0*M_PI/CPOINTS)+scatt[n].y*sin(i*2.0*M_PI/CPOINTS));
	ws_buf[i]+=cexp(2.0i*M_PI/LAMBDA*(plasmon->phase+dt_tmp));
      }

      /* go to the far field */
      //i = random_int(r,CPOINTS-1);
      //dt_tmp=(scatt[n].x*cos(c_t)+scatt[n].y*sin(c_t));
      //ws_buf[i]+=cexp(2.0i*M_PI/LAMBDA*(plasmon->phase+dt_tmp));
      //event_bins[i]++;
      //for(i=0,j=0;i<CPOINTS;++i){
      //	if(event_bins[i]>1000){ j++; }
      //     }
      //    if(j==CPOINTS){ bingood=0; }
      events++;

      //diff = field_diff(ws_buf, ws_buf_next, event_bins, CPOINTS);
      //memcpy(ws_buf_next, ws_buf, CPOINTS*sizeof(complex double));
    } 
  }

  /* done with a single point */

  FILE *out;
  /* paramter file just in case we forgot what we ran this program with */
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
  fprintf(out,"[NSCAT]\t%d\n",NSCAT);
  fprintf(out,"[EVENTS]\t%d\n",events);
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
    sprintf(filename,"%s/scatthist.dat",OUTPUT_DIR);
  }
  else{ sprintf(filename,"scatthist.dat"); }
  out=fopen(filename,"w");
  for(i=0;i<100;++i){
    fprintf(out,"%d\n",scatthist[i]);
  }

  fclose(out);


  /* output all the HDF files */
  memset(&filename,0,FILENAME_MAX*sizeof(char));
  if(strlen(OUTPUT_DIR)!=0){
    sprintf(filename,"%s/out.dat",OUTPUT_DIR);
  }
  else{ sprintf(filename,"out.dat"); }
  out=fopen(filename,"w");

  for(i=0;i<CPOINTS;++i){
    fprintf(out,"%g\n",cabs(ws_buf[i])*cabs(ws_buf[i]));
  }
  fclose(out);

  gsl_rng_free(r);

  return 0;
}
