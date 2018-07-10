#include <iostream>
#include <sstream>
#include <fstream>
#include <cstring>
#include <string> // cstring and string for platform independence
#include <cmath>
#include <vector>

extern "C" void signoise_r(const float*, const float*, const float*, int*, float []);

extern "C" void fircircfilter(float [], int*,float [],int*,float [],bool*);

extern "C" void esprit_r(float [], int*, int*, int*, const float*, float [], float []);

std::vector<float> loadfiltercoeff(std::string);

const bool verbose=false;

int main () {
std::cout << "C++ Esprit" << std::endl;

std::string Bfn="../bfilt.txt"; //FIXME binary file
int Ns=1024;
int Ntone=2;
int M=Ns/2;
const float fs=48000.;
//------- noisy signal generation ----------------
const float snr = 60.; // dB, arbitrary
const float f0 = float(12345.6); //arbitrary

std::vector<float> x((size_t(Ns))); // noisy signal
std::vector<float> y((size_t(Ns))); // filtered signal

signoise_r(&fs, &f0, &snr, &Ns, &x.front());

//---- filter noisy signal ------------------------

std::vector<float> Bfilt = loadfiltercoeff(Bfn);
bool Bok = std::isfinite(Bfilt.at(0));
bool filtok = false;
if (verbose) std::cout << "len(y): " << y.size() << std::endl;
if (Bok){
    int Nb = int(Bfilt.size());

    if (verbose) std::cout << "Nb: " << Nb << std::endl;

    fircircfilter(&x.front(),&Ns,&Bfilt.front(),&Nb,
                                &y.front(),&filtok);
}

if (verbose) std::cout << "Bok: " << Bok << " filtok: " << filtok << std::endl;

if (!Bok or !filtok){
    std::cerr << "C++ Esprit: skipping filter." << std::endl;
    y=x;
}

//---- signal estimation -----------------------------
std::vector<float> tones((size_t(Ntone)));
std::vector<float> sigma((size_t(Ntone)));

// if we pass the reference to the first array address, the rest of the array will follow (tones,sigma)
esprit_r(&y.front(), &Ns, &Ntone, &M, &fs, 
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


std::vector<float> loadfiltercoeff(std::string Bfn){
// read filter coefficients file //FIXME binary file
std::vector<float> Bfilt(1);  // filter coeff.
Bfilt.at(0)=NAN; // signals failure

std::ifstream Bfile;
Bfile.open(Bfn,std::ifstream::in);
if (!Bfile.is_open()){
    std::cerr << "E: could not open " << Bfn << std::endl;
    return Bfilt;
}

char val[20];
Bfile.getline(val,20); // how many coeff in file (first line)
int Nb = atoi(val); // NOTE: Fortran has signed integers only.
if (Nb<1 or Nb>10000){
    std::cerr << "E: Failed to obtain number of coefficients from " << Bfn << std::endl;
    return Bfilt;
}
// Read coeff
Bfilt.resize(size_t(Nb));

char vals[20*10000];
Bfile.getline(vals,20*10000);
std::istringstream iss(vals);
size_t i=0;
while(iss>>val){
    Bfilt[i] = float(atof(val));
    if (verbose) std::cout << "B[" << i <<"]= " << Bfilt[i] << std::endl;
    ++i;
} 

if (i != size_t(Nb)){
    std::cerr << "E: read " << i << " coeff from " << Bfn << " but expected " << Nb << std::endl;
    Bfilt.at(0)=NAN;
    return Bfilt;
}

if (verbose) std::cout << "loaded " << Bfilt.size() << " filter coefficients from " << Bfn << std::endl;


return Bfilt;
} // loadfiltercoeff
