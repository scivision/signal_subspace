#include <stdio.h>
#include <stdlib.h>
#include <math.h>

extern void __subspace_MOD_esprit(float [], const int *, const int *, int *, const float *, float [], float []);

extern void __signals_MOD_signoise(const float *,const float *, const float *, const int *, float []);

int main () {
 const int N=1024;
 const int L=4;
 int M=N/2;
 const float fs=48000.;
//------- noisy signal generation ----------------
 const float snr = 60.0; // dB, arbitrary
 const float f0 = (float)12345.6; //arbitrary
 
 float * x;
 x = malloc(N*sizeof(float));
 __signals_MOD_signoise(&fs, &f0, &snr, &N, &x[0]);

//---- signal estimation -----------------------------
float * tones; 
float * sigma;
tones = malloc(L*sizeof(float));
sigma = malloc(L*sizeof(float));

// if we pass the reference to the first array address, the rest of the array will follow (tones,sigma)
__subspace_MOD_esprit(&x[0], &N, &L, &M, &fs, &tones[0], &sigma[0]);

free(x);

printf("ANSI C Esprit\n");
printf("tones: %f %f\n",tones[0],tones[1]);
printf("sigma: %f %f\n",sigma[0],sigma[1]);

if (fabsf(tones[0]-f0)>0.0001*f0){
    perror("failed to meet tolerance\n");
    exit(EXIT_FAILURE);
}
else{
    printf("OK\n");
    exit(EXIT_SUCCESS);
}

}

