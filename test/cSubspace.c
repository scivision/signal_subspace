#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "cSubspace.h"

int main(void) {
printf("C Esprit\n");

int Ns=1024;
int Ntone=2;
int M=Ns/2;
const float fs=48000.;
//------- noisy signal generation ----------------
const float snr = 60.; // dB, arbitrary
const float f0 = (float)12345.6; //arbitrary

float * x;
x = malloc((size_t)Ns*sizeof(float));
signoise_r(&fs, &f0, &snr, &Ns, &x[0]);

//---- signal estimation -----------------------------
float * tones = calloc((size_t)Ntone,(size_t)Ntone*sizeof(float));
float * sigma = calloc((size_t)Ntone,(size_t)Ntone*sizeof(float));

esprit_r(&x[0], &Ns, &Ntone, &M, &fs, &tones[0], &sigma[0]);

free(x);

printf("estimated tone freq [Hz]: ");
for (int i=0; i<Ntone; i++) printf("%f ",tones[i]);

printf("\nwith sigma:               ");
for (int i=0; i<Ntone; i++) printf("%f ",sigma[i]);
printf("\n");

if (fabsf(tones[0]-f0)>0.0001*f0){
    fprintf(stderr,"E: failed to meet tolerance\n");
    free(tones); free(sigma);
    return EXIT_FAILURE;
}
else{
    printf("OK\n");
    free(tones); free(sigma);
    return EXIT_SUCCESS;
}

} // main
