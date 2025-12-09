#include <stdio.h>
#include <stdlib.h>

void swap(int *x, int *y) {
    int temp;
    temp = *x;
    *x = *y;
    *y = temp;
}

/* recursive function to generate permutations */
void permute(int *a, int l, int r) {
    int i;
    if (l == r) {
        for (i = 0; i <= r; i++) {
            printf("%d ", a[i]);
        }
        printf("\n");
    } else {
        for (i = l; i <= r; i++) {
            swap((a + l), (a + i));
            permute(a, l + 1, r);
            swap((a + l), (a + i)); // backtrack
        }
    }
}

int main() {
    int n = 5;
    int *arr = malloc(n * sizeof(int));
    if (!arr) return 1;
    
    for (int i = 0; i < n; i++) arr[i] = i;
    
    permute(arr, 0, n - 1);
    
    free(arr);
    return 0;
}