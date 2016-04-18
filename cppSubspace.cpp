#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <vector>

extern "C" void __signals_MOD_signoise(const float*, const float*, const float*, int*, float []);

extern "C" void __filters_MOD_fircircfilter(float [], int*,float [],int*,float [], int*);

extern "C" void __subspace_MOD_esprit(float [], int*, int*, int*, const float*, float [], float []);

std::vector<float> loadfiltercoeff(const char*);

const bool verbose=false;

int main () {
printf("C++ Esprit\n");

const char* Bfn="../bfilt.txt"; //FIXME binary file
int Ns=1024;
int Ntone=2;
int M=Ns/2;
const float fs=48000.;
//------- noisy signal generation ----------------
const float snr = 60.; // dB, arbitrary
const float f0 = float(12345.6); //arbitrary

std::vector<float> x; x.resize(Ns); // noisy signal
std::vector<float> y; y.resize(Ns); // filtered signal

__signals_MOD_signoise(&fs, &f0, &snr, &Ns, &x.front());

//---- filter noisy signal ------------------------

std::vector<float> Bfilt = loadfiltercoeff(Bfn);
bool Bok = std::isfinite(Bfilt[0]);

int statfilt;
if (Bok){
    int Nb = Bfilt.size();
    if (verbose) printf("Nb: %d\n",Nb);
    __filters_MOD_fircircfilter(&x.front(),&Ns,&Bfilt.front(),&Nb,&y.front(), &statfilt);
}

if (!Bok or statfilt!=0){
    fprintf(stderr,"skipping filter.\n");
    y=x;
}

if (verbose) printf("len(y): %lu \n",y.size());
//---- signal estimation -----------------------------
std::vector<float> tones; tones.resize(Ntone);
std::vector<float> sigma; sigma.resize(Ntone);

// if we pass the reference to the first array address, the rest of the array will follow (tones,sigma)
__subspace_MOD_esprit(&y.front(), &Ns, &Ntone, &M, &fs, 
                      &tones.front(), &sigma.front());


printf("estimated tone freq [Hz]: ");
for (const auto i: tones) printf("%f ",i);

printf("\nwith sigma:               ");
for (const auto i: sigma) printf("%f ",i);
printf("\n");

if (fabsf(tones[0]-f0)>0.0001*f0){
    fprintf(stderr,"E: failed to meet tolerance\n");
    return EXIT_FAILURE;
}
else{
    printf("OK\n");
    return EXIT_SUCCESS;
}

} // main


std::vector<float> loadfiltercoeff(const char* Bfn){
// read filter coefficients file //FIXME binary file
FILE * Bfid = fopen(Bfn,"r");

std::vector<float> Bfilt;  // filter coeff.
Bfilt.resize(1);
Bfilt[0]=NAN; // signals failure

if (Bfid==nullptr){ // no fclose() on nullptr, can crash on some platforms.
    fprintf(stderr,"E: could not open %s\n",Bfn);
    return Bfilt;
}

// how many coeff in file (first line)
int i,Nb; // NOTE: Fortran has signed integers only.
int ret = fscanf(Bfid,"%d",&Nb);
if (ret!=1){
    fprintf(stderr,"E: Failed to obtain number of coefficients from %s",Bfn);
    fclose(Bfid);
    return Bfilt;
}
// Read coeff
Bfilt.resize(Nb);
float val;
for (i=0; i<Nb; i++){
    ret = fscanf(Bfid,"%f",&val);
    if (ret!=1){
        fprintf(stderr,"E: Failed to read filter coeff # %d from %s",i,Bfn);
        Bfilt[0]=NAN;
        fclose(Bfid);
        return Bfilt;
    }
    
    Bfilt[i] = val;

    if (verbose) printf("B[%d]= %f\n",i,Bfilt[i]);
} //for i

if (Bfilt.size()!=size_t(Nb)){
    fprintf(stderr,"E: read %zu coeff from %s but expected %d", Bfilt.size(), Bfn,Nb);
    Bfilt[0]=NAN;
    fclose(Bfid); 
    return Bfilt;
}

printf("loaded %zu filter coefficients from %s\n",Bfilt.size(),Bfn);

fclose(Bfid); // only if file was opened successfully, or fclose() may SIGSEGV on some platforms.

return Bfilt;
} // loadfiltercoeff
