#include <stdio.h>

int M[16];

// n MUST be a power of 2
void msort(int p, int n) {
  if (n == 1) return;

  int n1 = n >> 1; // /2
  int n2 = n - n1;

  msort(p, n1);
  msort(p + n1, n2);

  int s = 0; // use second quarter of M as sort buffer, copy later

  int i1 = p;
  int i2 = p + n1;

  while (i1 < p + n1)  {

    if (M[i1] > M[i2]) M[s] = M[i1];
    else M[s] = M[i2];

    i1 = i1 + 1;
    s = s + 1;
  }
  while (i2 <) {
    
    s
  }


}
