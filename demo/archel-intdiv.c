#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int int_div(int N, int D) {
  int Q = 0;
  while (N >= D) {
    Q = Q + 1;
    N = N - D;
  }
  return Q;
}

int main(int argc, int ** argv) {
  int N = atoi(argv[1]);
  int D = atoi(argv[2]);
  int Q = int_div(N, D);
  printf("%d\n", Q);
}
