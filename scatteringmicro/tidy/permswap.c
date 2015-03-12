#include <stdio.h>
#include <stdlib.h>

/* recursive function to generate permutations */
void perm (int i, int depth, int n) {
  printf("%d\n",i);
  if(depth<0){ return; }
  int j;
  for (j=0;j<n;++j) {
    if(j==i){ continue; }
    perm(j,depth-1,n);
  }
}

/* little driver function to print perms of first 5 integers */

int main () {
  perm(0,1,5);
  return 0;
}
