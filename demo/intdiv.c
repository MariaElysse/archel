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

// (50 / 7)

main:
  addi $4 <= $0 + d.50
  addi $5 <= $0 + d.7
  beq ($0 == $0) => int_div
main_2:


int_div:
  addi $1 <= $0 + d.0
int_div_loop:
  slt $2 <= ($4 < $5) // 0 if $4 >= $5
  beq ($2 == $0) => do_minus
  beq ($0 == $0) => main_2
do_minus:
  addi $1 <= $1 + d.1
  addi $4 <= $4 + d.-1
beq ($0)




















