#include <stdio.h>
#include <complex.h>

extern void __subspace_MOD_esprit(complex double [], int *, int *, int *, double *, double [], double []);

extern void __signals_MOD_signoise(double *,double *,double *,int *, complex double []);

int main () {
 int N=1024;
 int L=2;
 int M=50;
 double fs=48000.;
//------- noisy signal generation ----------------
 double snr = 20.; // dB, arbitrary
 double f0=12345.6; //arbitrary
 complex double x[N];

 __signals_MOD_signoise(&fs,&f0,&snr,&N,&x[0]);

//---- signal estimation -----------------------------
double tones[L], sigma[L];

// if we pass the reference to the first array address, the rest of the array will follow (tones,sigma)
__subspace_MOD_esprit(&x[0], &N, &L, &M, &fs, &tones[0], &sigma[0]);

printf("tones: %f %f\n",tones[0],tones[1]);
printf("sigma: %f %f",sigma[0],sigma[1]);

}

