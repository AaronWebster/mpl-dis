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
#define SX 1 /* points of the scan area (not size) */
#define SY 1
#define SCANAREA 2.27 /* size of the square scan area */
#define ELLIPSE_A 5.0 /* size of the illuminated area as an ellipse */
#define ELLIPSE_B 3.0
#define LAMBDA 0.600 /* wavelength of light */ 
#define PATHLEN 18.00 /* max path length */
#define ENTIREAREA 8.8281 /* the boundary of the region for which scatterers will be generated */
#define EPS (1e-12)

#define SST 0
#define SSN 0
#define MST 1
#define MSN 1

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
	char scattseq[32]; /* the ordered sequence of scatterers it visits */
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


/* remove time reverse pairs - time taken here scales as n^2 */
int rtr(plasmon_t *gplasmon, double lphase, int events){
	int i;
	for(i=0;i<events;i++){
		//printf("%d\t%g\t%g\n",i,plasmon->phase,lphase);
		if(fabs(gplasmon->phase-lphase)<EPS){ return 1; } /* found */
			gplasmon++;
	}
	return 0; /* not found */
}

int checkpathlen(double *paths, double pathlen){
	return -1;
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
			{0,0,0,0}
		};
    /* getopt_long stores the option index here. */ 
		int option_index = 0;
     
		c = getopt_long (argc, argv, "", long_options, &option_index);
     
   /* Detect the end of the options. */
   if(c==-1){ break; }
   switch(c){ 
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

	int CPOINTS = 360; /* how many weirdospace images to make in a circle */
	double *ws_buf_p = malloc(CPOINTS*SX*SY*sizeof(double)); /* weirdospace */
	double *ws_buf_p_root = malloc(CPOINTS*SX*SY*sizeof(double));
	double *ws_buf = malloc(CPOINTS*SX*SY*sizeof(double)); /* weirdospace */
	double *ws_buf_root = malloc(CPOINTS*SX*SY*sizeof(double));
	double *paths = malloc(sizeof(double));
	if(ws_buf==NULL) { 
		printf("could not allcate memory for ws_buf\n");
		return -1; 
	}
	if(ws_buf_root==NULL){ 
		printf("could not allcate memory for ws_buf_root\n");
		return -1; 
	}
	bzero(ws_buf_root,CPOINTS*SX*SY*sizeof(double));
	bzero(ws_buf,CPOINTS*SX*SY*sizeof(double));

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
	plasmon_t *gplasmon;
	plasmon_t *plasmon = malloc(EVENTS*sizeof(plasmon_t));
	if(plasmon==NULL){ 
		printf("could not allocate memory for plasmon\n");
		return -1; 
	}
	bzero(plasmon,EVENTS*sizeof(plasmon_t));
	gplasmon=plasmon;
	hcreate(EVENTS); /* create hash table */
	ENTRY e_se, *ep_se;
	char rscattseq[32];

	/* sum up all the visits and pathlengths to compute the mean free path */
	unsigned int testparam= 0; 
	unsigned int testparam_root= 0; 

	unsigned long long int totalvisits = 0; 
	unsigned long long int totalvisits_root = 0;
	unsigned long long int totalpathlen = 0; 
	unsigned long long int totalpathlen_root = 0;
	unsigned long long int sscat[100] = {0};
	unsigned long long int sscat_root[100] = {0};
	unsigned long long int mscat[100] = {0};
	unsigned long long int mscat_root[100] = {0};
	size_t nphases = 0;
	double phases[EVENTS];
	/* raster */
	for(x_i=rank;x_i<SX;x_i+=nprocs){
	for(y_i=0;y_i<SY;y_i++){
		/* x_i and y_i are integer coordinates on the 128x128 grid.  x and y
		 * are the actual double coordinates */
		x=SCANAREA*((double)x_i/SX)-SCANAREA/2.0;
		y=SCANAREA*((double)y_i/SY)-SCANAREA/2.0;

		/* the tip is always the first in the scatt array */
		scatt[0].x=x; scatt[0].y=y;
		
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
			int includestip=0;
			/* first scatterer */
			n=iscanidates[random_int(r,ncanidates-1)];
			if(n==0){ includestip=1; }
			plasmon->phase+=scatt[n].x*((2*M_PI)/LAMBDA);
			plasmon->nscat++;
			plasmon->scattseq[plasmon->nscat-1]=n;
			plasmon->v=1;
	
			/* run around until we're out of path length or we choose the same
			 * scatterer twice */
			for(;;){
				next_n=nextscatt(r,plasmon,scatt,scanidates,n,NSCAT);
				if(next_n==-1){ next_n=n; break; }
				if(next_n==-2){ testparam++; next_n=n; break; }
				if(next_n==0){ includestip=1; }
	
				pathlen_tmp=sqrt( 
		 				(scatt[n].x-scatt[next_n].x)*(scatt[n].x-scatt[next_n].x)
					+ (scatt[n].y-scatt[next_n].y)*(scatt[n].y-scatt[next_n].y));
				dt_tmp=(((2*M_PI)/LAMBDA)*pathlen_tmp);
				plasmon->phase+=dt_tmp; 
	
				plasmon->pathlen+=pathlen_tmp;
				plasmon->nscat++;
				plasmon->scattseq[plasmon->nscat-1]=next_n;
				n=next_n;
			}

			if(plasmon->nscat>1 && rtr(gplasmon,plasmon->phase,events-1)==1){
				bzero(plasmon,sizeof(plasmon_t));
				continue;
			}

#if SST
			/* single scattering including the tip */
			if(plasmon->nscat==1 && includestip==1){ 
				bzero(plasmon,sizeof(plasmon_t));
				continue;
			}
#endif

#if MST
			/* multiple scattering including the tip */
			if(plasmon->nscat>1 && includestip==1){
				bzero(plasmon,sizeof(plasmon_t));
				continue;
			}
#endif
	
#if SSN
			/* single scattering that does not include the tip */
			if(plasmon->nscat==1 && includestip==0){ 
				bzero(plasmon,sizeof(plasmon_t));
				continue;
			}
#endif
	
	
#if MSN
			/* multiple scattering that does not include the tip */
			if(plasmon->nscat>1 && includestip==0){ 
				bzero(plasmon,sizeof(plasmon_t));
				continue;
			}
#endif

#if 0
			/* search for this phase in the list.  If it's already in the array,
			 * make a new scattering event.  If it's not, add it and keep the
			 * event */

			/* if it already exists */
			size_t mynphases=nphases;
			double myphase = plasmon->phase;
		  lsearch(&myphase, phases, &nphases, sizeof(double*), 
			(int (*)(const void *, const void *)) compare_doubles);
			if(mynphases==nphases){
				//plasmon->v=0;
				bzero(plasmon,sizeof(plasmon_t));
				continue;
			}
#endif
			//phases[events]=plasmon->phase;

			mscat[plasmon->nscat]++;	
			mscat[0]++;	
			for(i=0;i<plasmon->nscat;i++){
				if(plasmon->scattseq[i]==0){
					sscat[plasmon->nscat]++;
					sscat[0]++;
					break;
				}
			}
			
			events++;
			plasmon++;
		} plasmon-=events;
#if 0
		nphases=0;
		for(i=0;i<events;i++,plasmon++){
			size_t mynphases=nphases;
			double myphase = plasmon->phase;
		  lsearch(&myphase, phases, &nphases, sizeof(double*), 
			(int (*)(const void *, const void *)) compare_doubles);
			if(mynphases==nphases){ plasmon->v=0; }
		}plasmon-=i;

		/* sort list of phases */

		/* remove time reverse paths */
	 	rtr(plasmon,events);	
#endif

		/* add up the total visits and pathlengths */	
		for(i=0;i<events;i++,plasmon++){
			totalvisits+=plasmon->nscat;
			totalpathlen+=plasmon->pathlen;
		} plasmon-=i;


		/* move around in a circle */
		double c_t;
		double c_dt=(2*M_PI)/CPOINTS;
		for(e=0,c_t=0;c_t<2*M_PI;c_t+=c_dt,e++){
			/* sum up contributions from individual plasmons */
			//bzero(&expp_tmp,sizeof(complex double));
			//expp_tmp=cexp(1.0i*5);
			cosp_tmp=0.0;
			sinp_tmp=0.0;
			for(i=0;i<events;i++,plasmon++){
				//if(plasmon->v==1){ continue; }
				//if(plasmon->v==0){ plasmon->v++; }
				dt_tmp=(scatt[plasmon->scattseq[plasmon->nscat-1]].x*cos(c_t)+scatt[plasmon->scattseq[plasmon->nscat-1]].y*sin(c_t))*((2*M_PI)/LAMBDA);
				//expp_tmp+=cexp(plasmon->phase+dt_tmp)*plasmon->v;
				cosp_tmp+=cos(plasmon->phase+dt_tmp)*plasmon->v;
				sinp_tmp+=sin(plasmon->phase+dt_tmp)*plasmon->v;

				/* and its time reverse pair */
				//dt_tmp=(scatt[plasmon->scattseq[0]].x*cos(c_t)+scatt[plasmon->scattseq[0]].y*sin(c_t))*((2*M_PI)/LAMBDA);
				//cosp_tmp+=cos(plasmon->phase+dt_tmp)*plasmon->v;
				//sinp_tmp+=sin(plasmon->phase+dt_tmp)*plasmon->v;
			} plasmon-=i;
			
			int o = (SX*y_i+x_i)+e*(SX*SY);
			//ws_buf[o]=cabs(expp_tmp)*cabs(expp_tmp);
			ws_buf[o]=cosp_tmp*cosp_tmp+sinp_tmp*sinp_tmp;
			ws_buf_p[o]=(atan2(sinp_tmp,cosp_tmp)+M_PI)/(2*M_PI);
			//if(ws_buf_p[o]<0){ ws_buf_p[o]+=2*M_PI; }
		}

		bzero(plasmon,EVENTS*sizeof(plasmon_t));
	
	/* done with a single point */
}
}

	/* combine all the event runs */
	MPI_Reduce(ws_buf,ws_buf_root,CPOINTS*SX*SY,MPI_DOUBLE,MPI_SUM,0,MPI_COMM_WORLD);
	MPI_Reduce(ws_buf_p,ws_buf_p_root,CPOINTS*SX*SY,MPI_DOUBLE,MPI_SUM,0,MPI_COMM_WORLD);
	MPI_Reduce(&totalvisits,&totalvisits_root,1,MPI_LONG_LONG,MPI_SUM,0,MPI_COMM_WORLD);
	MPI_Reduce(&totalpathlen,&totalpathlen_root,1,MPI_LONG_LONG,MPI_SUM,0,MPI_COMM_WORLD);
	MPI_Reduce(sscat,sscat_root,100,MPI_LONG_LONG,MPI_SUM,0,MPI_COMM_WORLD);
	MPI_Reduce(mscat,mscat_root,100,MPI_LONG_LONG,MPI_SUM,0,MPI_COMM_WORLD);
	//MPI_Reduce(&testparam,&testparam_root,1,MPI_LONG_LONG,MPI_SUM,0,MPI_COMM_WORLD);

	if(rank==0){
		FILE *out;

		/* use gnuplot to give us a picture of the geometry */
		//out = popen("gnuplot", "w");
		out = fopen("gnuplot-output", "w");
		//fprintf(out,"set terminal postscript enhanced color\n");
		fprintf(out,"set terminal png\n");
		fprintf(out,"set output \"./%s/geometry.png\"\n",OUTPUT_DIR);
		fprintf(out,"set parametric\n");
		fprintf(out,"set size ratio 1\n");
		fprintf(out,"plot %lf*cos(t),%lf*sin(t) title \"illuminated region\",",(double)ELLIPSE_A,(double)ELLIPSE_B);
		fprintf(out,"'-' w lp title \"boundary\",");
		fprintf(out,"'-' w lp title \"raster area\",");
		fprintf(out,"'-' title \"scatterers\"\n");
		fprintf(out,"# bounding box\n");
		fprintf(out,"-%lf\t-%lf\n",(double)ENTIREAREA/2,(double)ENTIREAREA/2);
		fprintf(out,"%lf\t-%lf\n",(double)ENTIREAREA/2,(double)ENTIREAREA/2);
		fprintf(out,"%lf\t%lf\n",(double)ENTIREAREA/2,(double)ENTIREAREA/2);
		fprintf(out,"-%lf\t%lf\n",(double)ENTIREAREA/2,(double)ENTIREAREA/2);
		fprintf(out,"-%lf\t-%lf\ne\n",(double)ENTIREAREA/2,(double)ENTIREAREA/2);
		fprintf(out,"# raster area\n");
		fprintf(out,"-%lf\t-%lf\n",(double)SCANAREA/2,(double)SCANAREA/2);
		fprintf(out,"%lf\t-%lf\n",(double)SCANAREA/2,(double)SCANAREA/2);
		fprintf(out,"%lf\t%lf\n",(double)SCANAREA/2,(double)SCANAREA/2);
		fprintf(out,"-%lf\t%lf\n",(double)SCANAREA/2,(double)SCANAREA/2);
		fprintf(out,"-%lf\t-%lf\ne\n",(double)SCANAREA/2,(double)SCANAREA/2);
		fprintf(out,"# scatterers\n");
		for(i=1;i<NSCAT;i++){
			fprintf(out,"%lf\t%lf\n",scatt[i].x,scatt[i].y); 
		}
		fprintf(out,"e\n");
		fclose(out);

		/* paramter file just in case we forgot what we ran this program with */
		double div = SX*SY*EVENTS;
		memset(&filename,0,FILENAME_MAX*sizeof(char));
		if(strlen(OUTPUT_DIR)!=0){
			sprintf(filename,"%s/parameters",OUTPUT_DIR);
		}
		else{ sprintf(filename,"parameters"); }
		out=fopen(filename,"w");
		fprintf(out,"[SX]\t%d\n",(int)SX);
		fprintf(out,"[SY]\t%d\n",(int)SY);
		fprintf(out,"[SCANAREA]\t%lf\n",(double)SCANAREA);
		fprintf(out,"[ELLIPSE_A]\t%lf\n",(double)ELLIPSE_A);
		fprintf(out,"[ELLIPSE_B]\t%lf\n",(double)ELLIPSE_B);
		fprintf(out,"[LAMBDA]\t%lf\n",(double)LAMBDA);
		fprintf(out,"[PATHLEN]\t%lf\n",(double)PATHLEN);
		fprintf(out,"[ENTIREAREA]\t%lf\n",(double)ENTIREAREA);
		fprintf(out,"[EVENTS]\t%d\n",EVENTS);
		fprintf(out,"[FREE PATH]\t%lf\n",(double)totalpathlen_root/totalvisits_root);
		fprintf(out,"[TESTPARAM]\t%lf\n",(double)testparam_root/div);
		fprintf(out,"[NSCAT]\t%d\n",NSCAT);
		fprintf(out,"[REMOVED]\t\n");
#ifdef SST
		/* single scattering including the tip */
		fprintf(out,"SST\t");
#endif

#ifdef MST
			/* multiple scattering including the tip */
		fprintf(out,"MST\t");
#endif
	
#ifdef SSN
			/* single scattering that does not include the tip */
		fprintf(out,"SSN\t");
#endif
	
	
#ifdef MSN
			/* multiple scattering that does not include the tip */
		fprintf(out,"MSN");
#endif
		fprintf(out,"\n");

		fprintf(out,"[SCATTERERS]\n");
		for(i=1;i<NSCAT;i++){
			fprintf(out,"%g\t%g\n",scatt[i].x,scatt[i].y); 
		}
		fprintf(out,"[STATS]\n");
		for(i=0;i<20;i++){
			fprintf(out,"%d\t%g\t%g\n",i,mscat_root[i]/div,sscat_root[i]/div);
		}
		fclose(out);

		/* output all the HDF files */
		unsigned int fileid;
		for(fileid=0;fileid<CPOINTS;fileid++){
			hid_t file,dataset,dataspace;
			herr_t status;
			hsize_t dims[2];

			/* output file */
			memset(&filename,0,FILENAME_MAX*sizeof(char));
			if(strlen(OUTPUT_DIR)!=0){
				mkdir(OUTPUT_DIR,0777);
				sprintf(filename,"%s/%.5d-scatter.h5",OUTPUT_DIR,fileid);
			}
			else{ sprintf(filename,"%.5d-scatter.h5",fileid); }

			file = H5Fcreate(filename,H5F_ACC_TRUNC,H5P_DEFAULT,H5P_DEFAULT);

			dims[0]=(int)SX;
			dims[1]=(int)SY;
			dataspace = H5Screate_simple(2,dims,NULL);

			for(x_i=0;x_i<SX;x_i++){ for(y_i=0;y_i<SY;y_i++){
				ws_buf[SX*y_i+x_i]=ws_buf_root[(SX*y_i+x_i)+fileid*(SX*SY)];
				ws_buf_p[SX*y_i+x_i]=ws_buf_p_root[(SX*y_i+x_i)+fileid*(SX*SY)];
			}}
			/* write intensity and phase */
			dataset = H5Dcreate1(file,"/intensity",H5T_NATIVE_DOUBLE,dataspace,H5P_DEFAULT);
			status = H5Dwrite(dataset, H5T_NATIVE_DOUBLE, H5S_ALL, H5S_ALL, H5P_DEFAULT, ws_buf);
			dataset = H5Dcreate1(file,"/phase",H5T_NATIVE_DOUBLE,dataspace,H5P_DEFAULT);
			status = H5Dwrite(dataset, H5T_NATIVE_DOUBLE, H5S_ALL, H5S_ALL, H5P_DEFAULT, ws_buf_p);

			status = H5Dclose(dataset);
			status = H5Sclose(dataspace);
			status = H5Fclose(file);

		}

	}

#if 0
		int fileid;
		double ws_buf[SX*SY];
		double ws_buf_p[SX*SY];
		double ws_buf_srt[SX*SY];
		double mean,variance;
		FILE *rintensity;
		if(strlen(OUTPUT_DIR)!=0){
			sprintf(filename,"%s/ring.dat",OUTPUT_DIR);
		}
		else{ sprintf(filename,"ring.dat"); }

		rintensity = fopen(filename,"w");
		char label[3];
		for(fileid=0;fileid<CPOINTS;fileid++){
			/* will ws_buf with the data from ws_buf_root.  We will work with
			 * ws_buf down here */
			for(x_i=0;x_i<SX;x_i++){ for(y_i=0;y_i<SY;y_i++){
				ws_buf[SX*y_i+x_i]=ws_buf_root[(SX*y_i+x_i)+fileid*(SX*SY)];
				ws_buf_srt[SX*y_i+x_i]=ws_buf_root[(SX*y_i+x_i)+fileid*(SX*SY)];
				ws_buf_p[SX*y_i+x_i]=ws_buf_p_root[(SX*y_i+x_i)+fileid*(SX*SY)];
			}}

			qsort(ws_buf_srt,SX*SY,sizeof(double),compare_doubles);

			/* just curious if we can see any vorticies around here */
			double framemean = 0;
			for(i=0;i<SX*SY;i++){
				framemean+=ws_buf_srt[i];
			} framemean/=(SX*SY);

			double top = 0;
			double bottom = 0;
			for(i=0;i<SX*SY*0.001;i++){
				top+=ws_buf_srt[i];
			} top/=i;

			for(j=0,i=SX*SY-1;i>SX*SY-SX*SY*0.001;i--,j++){ 
				bottom+=ws_buf_srt[i]; 
			} bottom/=j;
		
			fprintf(rintensity,"%d\t%lf\t%lf\n",fileid,framemean,bottom-top);

			/* normalize the image */
			double normr=-DBL_MAX;
			double norml=DBL_MAX;
			for(x_i=0;x_i<SX;x_i++){ for(y_i=0;y_i<SY;y_i++){
				int o = (SX*y_i+x_i);
				if(ws_buf[o]>normr){ normr=ws_buf[o]; } 
				if(ws_buf[o]<norml){ norml=ws_buf[o]; } 
			}}
	
			for(x_i=0;x_i<SX;x_i++){ for(y_i=0;y_i<SY;y_i++){
				int o = (SX*y_i+x_i);
				ws_buf[o]=(ws_buf[o]+norml)/(normr+norml); 
				/* make normalization work correctly */
				if(ws_buf[o]>1.0){ ws_buf[o]=1.0; }
				/* reset if NaN */
				if(ws_buf[o]!=ws_buf[o]){ ws_buf[o]=0.0; }
			}}

			/* loop through the array we gathered and fill the colors */
			memset(&filename,0,128*sizeof(char));
			if(strlen(OUTPUT_DIR)!=0){
				mkdir(OUTPUT_DIR,0777);
				sprintf(filename,"%s/%.5d-scatter.ppm",OUTPUT_DIR,fileid);
			}
			else{ sprintf(filename,"%.5d-scatter.ppm",fileid); }
			out=fopen(filename,"wb");

			/* now write the wierdospace image */
			fprintf(out,"P6\n%d %d\n255\n",SX,SY);
			unsigned int r,g,b,i1;
			double h1,s1,v1,aa,bb,cc,f1;
			for(x_i=0;x_i<SX;x_i++){
				for(y_i=0;y_i<SY;y_i++){
					int o = (SX*y_i+x_i);

					h1=ws_buf_p[o];
					s1=1.0;
					v1=ws_buf[o];

					if(h1==1.0){ h1=0; }
					h1*=6;
					i1=floor(h1);
					f1=h1=i1;
					aa=v1*(1-s1);
					bb=v1*(1-(s1*f1));
					cc=v1*(1-(s1*(1-f1)));
					
					switch(i1){
						case 0: 
							r=(v1*255); g=(cc*255); b=(aa*255);
							break;
						case 1:
							r=(bb*255); g=(v1*255); b=(aa*255);
							break;
						case 2:
							r=(aa*255); g=(v1*255); b=(cc*255);
							break;
						case 3:
							r=(aa*255); g=(bb*255); b=(v1*255);
							break;
						case 4:
							r=(cc*255); g=(aa*255); b=(v1*255);
							break;
						case 5:
							r=(v1*255); g=(aa*255); b=(bb*255);
							break;
						default:
							r=0; g=0; b=0;
							break;
					}
					fputc(r,out); fputc(g,out); fputc(b,out);

				}
			}
			fclose(out);

		}
		fclose(rintensity);
	}
#endif
	gsl_rng_free(r);
	free(plasmon);
	free(scatt);
	hdestroy();
	MPI_Finalize();

	return 0;
}
