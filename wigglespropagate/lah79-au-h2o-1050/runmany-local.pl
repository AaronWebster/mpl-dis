#!/usr/bin/perl
#PBS -N wiggles
#PBS -e wiggles.err
#PBS -o wiggles.out
#PBS -m abe
#PBS -q normal
#PBS -l walltime=04:00:00
#PBS -l nodes=8:ppn=4

### above PBS settings are: name = sample, std error -> sample.err,
###   std out -> sample.log, mail notification to the job owner,
###   queue = normal, request for 16 processors on 2 nodes (i.e.
###   8 jobs per node)

use POSIX ":sys_wait_h";
use strict;

my $ldvars = $ENV{'LD_LIBRARY_PATH'};
chomp($ldvars);

### set locations
#     assume the executable names are of the form
#     a.out.1, a.out.2, ..., a.out.n
#     or
#     executable file.1, executable file.2, ...
# my $workdir_base = $ENV{'PWD'};
my $workdir_base = $ENV{'PWD'};

# on the next line: put everything in the command,
#   the dot and last number will be appended to this string
#   (this could also be a.out for the other example above)
my @job_file;
open(IN,"<$workdir_base/runmany.in") || die "Could not open input file\n";
while(<IN>){ push @job_file, $_; }
my $num_jobs = scalar(@job_file);

### get node file name from shell
my $pbs_nodefile = $ENV{'PBS_NODEFILE'};
#my $pbs_nodefile = "nodefile";

### log stuff to standard error
my ($hostname, $number_of_procs);
$number_of_procs = 4;
#chomp($hostname = `hostname`);
#chomp($number_of_procs = `wc -l <$pbs_nodefile`); $number_of_procs =~ s/\s//g;
#print STDERR "Working base directory is $workdir_base\n";
#print STDERR "Running on host $hostname\n";
#print STDERR "Time is " . localtime(time) . "\n";
#print STDERR "Allocated $number_of_procs nodes\n";

### make list of jobs to do, and set up other lists
my $j; my @job_array; my @child_array; my @running_job_array; 
for ($j=1; $j<=$num_jobs; $j++) {
  push @job_array, $j
}


### make a list of available processors
my  @proc_array = ();
open(procfile, "<$pbs_nodefile");
  while(<procfile>) { chomp; push @proc_array, $_; }
close(procfile);

### make a job table to keep track of which processors are working;
#     a value of 1 means busy, a value of 0 means idle
my @busy_table = ();
for ($j=0; $j<$number_of_procs; $j++) { push @busy_table, 0; }

### run the jobs!
my $running_jobs = 0;
while ( $#job_array >= 0 or $running_jobs > 0 ) {

  # spawn new jobs, if needed
  while ( $running_jobs < $number_of_procs and $#job_array >= 0  ) {
    my $job = shift @job_array;
    my $job_command = $job_file[$job-1];

    # find first free job slot and launch
    $j = 0; while($busy_table[$j] == 1) {$j++;}
    if ( $j >= $number_of_procs ) {
      die "Internal error with allocation table";
    }
    $busy_table[$j] = 1;
    print STDERR "on $proc_array[$j]:\n";
    $job_command = "$job_command";
    #$job_command = "echo $job_command";
    print STDERR "Launching job #$job: \n$job_command\n";
    print STDERR "\n";

    my $child = fork();
    if ($child == 0) {
      exec($job_command);
    } else {
      $child_array[$j] = $child;
      $running_job_array[$j] = $job;
    }
    $running_jobs++;
  }

  # check for finished jobs
  for ($j=0; $j<=$#child_array; $j++) {
    if ( $busy_table[$j] == 1 ) {
      my $child = waitpid($child_array[$j], WNOHANG);
      if ( $child == -1 ) {
        my $exitstatus = int($?+0.49)/256;
        print STDERR "Finished job #$running_job_array[$j]";
        if ( $exitstatus != 0 ) {print STDERR ", exit status = $exitstatus";}
        print STDERR "\n\n";
        $child_array[$j] = -1;
        $running_job_array[$j] = -1;
        $running_jobs--;
        $busy_table[$j] = 0;
      }
    }
  }

  # wait a bit so we don't overload the processor with admin stuff
  sleep 1;

}
