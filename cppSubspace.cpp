#include <cstdio>
#include <stdlib.h>

extern void __subspace_MOD_esprit(float [], int *, int *, int *, float *, float [], float []);

extern void __signals_MOD_signoise(float *,float *,float *,int *, float []);

int main () {
 int N=1024;
 int L=4;
 int M=N/2;
 float fs=48000.;
//------- noisy signal generation ----------------
 float snr = 60.; // dB, arbitrary
 float f0 = 12345.6; //arbitrary
 float x[N];

 __signals_MOD_signoise(&fs, &f0, &snr, &N, &x[0]);

//---- signal estimation -----------------------------
float tones[L], sigma[L];

// if we pass the reference to the first array address, the rest of the array will follow (tones,sigma)
__subspace_MOD_esprit(&x[0], &N, &L, &M, &fs, &tones[0], &sigma[0]);

printf("tones: %f %f\n",tones[0],tones[1]);
printf("sigma: %f %f\n",sigma[0],sigma[1]);

if (abs(tones[0]-f0)>0.0001*f0){
    perror("failed to meet tolerance\n");
    exit(EXIT_FAILURE);
}
else{
    printf("OK\n");
    exit(EXIT_SUCCESS);
}

}

