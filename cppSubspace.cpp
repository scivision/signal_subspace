#include <cstdio>
#include <stdlib.h>
#include <cmath>

extern "C" void __subspace_MOD_esprit(float [], const int *, const int *, int *, const float *, float [], float []);

extern "C" void __signals_MOD_signoise(const float *,const float *, const float *, const int *, float []);

int main () {
 const int N=1024;
 const int L=4;
 int M=N/2;
 const float fs=48000.;
//------- noisy signal generation ----------------
 const float snr = 60.; // dB, arbitrary
 const float f0 = float(12345.6); //arbitrary

 float * x = new float[N];

 __signals_MOD_signoise(&fs, &f0, &snr, &N, &x[0]);

//---- signal estimation -----------------------------
float * tones = new float[L];
float * sigma = new float[L];

// if we pass the reference to the first array address, the rest of the array will follow (tones,sigma)
__subspace_MOD_esprit(&x[0], &N, &L, &M, &fs, &tones[0], &sigma[0]);

delete[] x;

printf("C++ Esprit\n");
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

