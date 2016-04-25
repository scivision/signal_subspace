#include <iostream>
#include <cmath>
#include <vector>

extern "C" void __signals_MOD_signoise(const float*, const float*, const float*, int*, float []);

extern "C" void __filters_MOD_fircircfilter(float [], int*,float [],int*,float [], int*);

extern "C" void __subspace_MOD_esprit(float [], int*, int*, int*, const float*, float [], float []);

std::vector<float> loadfiltercoeff(const char*);

const bool verbose=false;

int main () {
std::cout << "C++ Esprit" << std::endl;

const char* Bfn="../bfilt.txt"; //FIXME binary file
int Ns=1024;
int Ntone=2;
int M=Ns/2;
const float fs=48000.;
//------- noisy signal generation ----------------
const float snr = 60.; // dB, arbitrary
const float f0 = float(12345.6); //arbitrary

std::vector<float> x; x.resize(size_t(Ns)); // noisy signal
std::vector<float> y; y.resize(size_t(Ns)); // filtered signal

__signals_MOD_signoise(&fs, &f0, &snr, &Ns, &x.front());

//---- filter noisy signal ------------------------

std::vector<float> Bfilt = loadfiltercoeff(Bfn);
bool Bok = std::isfinite(Bfilt[0]);

int statfilt=-1;
if (Bok){
    int Nb = int(Bfilt.size());
    if (verbose) std::cout << "Nb: " << Nb << std::endl;
    __filters_MOD_fircircfilter(&x.front(),&Ns,&Bfilt.front(),&Nb,&y.front(), &statfilt);
}

if (!Bok or statfilt!=0){
    std::cerr << "skipping filter." << std::endl;
    y=x;
}

if (verbose) std::cout << "len(y): " << y.size() << std::endl;
//---- signal estimation -----------------------------
std::vector<float> tones; tones.resize(size_t(Ntone));
std::vector<float> sigma; sigma.resize(size_t(Ntone));

// if we pass the reference to the first array address, the rest of the array will follow (tones,sigma)
__subspace_MOD_esprit(&y.front(), &Ns, &Ntone, &M, &fs, 
                      &tones.front(), &sigma.front());


std::cout << "estimated tone freq [Hz]: ";
for (const auto i: tones) std::cout << i;

std::cout << std::endl << "with sigma:               ";
for (const auto i: sigma) std::cout << i;
std::cout << std::endl;

if (fabsf(tones[0]-f0)>0.0001*f0){
    std::cerr << "E: failed to meet tolerance" << std::endl;
    return EXIT_FAILURE;
}
else{
    std::cout << "OK" << std::endl;
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
    std::cerr << "E: could not open " << Bfn << std::endl;
    return Bfilt;
}

// how many coeff in file (first line)
int Nb; // NOTE: Fortran has signed integers only.
int ret = fscanf(Bfid,"%d",&Nb);
if (ret!=1){
    std::cerr << "E: Failed to obtain number of coefficients from " << Bfn << std::endl;
    fclose(Bfid);
    return Bfilt;
}
// Read coeff
Bfilt.resize(size_t(Nb));
float val;
for (size_t i=0; i<size_t(Nb); i++){
    ret = fscanf(Bfid,"%f",&val);
    if (ret!=1){
        std::cerr << "E: Failed to read filter coeff # " << i << " from " << Bfn << std::endl;
        Bfilt[0]=NAN;
        fclose(Bfid);
        return Bfilt;
    }
    
    Bfilt[i] = val;

    if (verbose) std::cout << "B[" << i <<"]= " << Bfilt[i] << std::endl;
} //for i

if (Bfilt.size()!=size_t(Nb)){
    std::cerr << "E: read " << Bfilt.size() << " coeff from " << Bfn << " but expected " << Nb << std::endl;
    Bfilt[0]=NAN;
    fclose(Bfid); 
    return Bfilt;
}

std::cout << "loaded " << Bfilt.size() << " filter coefficients from " << Bfn << std::endl;

fclose(Bfid); // only if file was opened successfully, or fclose() may SIGSEGV on some platforms.

return Bfilt;
} // loadfiltercoeff
