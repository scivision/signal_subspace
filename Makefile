# Michael Hirsch 2014

FC = gfortran
#---- What the EXE filename should be ---------------------------------
TARGET_CMPL = fesprit
TARGET_REAL= fesprit_realsp
TARGET_C = cesprit
TARGET_CPP = cpp_esprit
TARGET_PYREAL = fortsubspace_real
TARGET_PYCMPL = fortsubspace_cmpl
#----Sources (in order of dependency) ---------------------------------
FSRC_CMPL = comm.f90 subspace.f90 signals.f90
FMAIN_CMPL = perf.f90 RunSubspace.f90

# yes, we should be using data polymorphism instead
FSRC_REAL = comm.f90 subspace_realsp.f90 signals_realsp.f90
FMAIN_REAL = perf.f90  RunSubspace_realsp.f90

CSRC = cSubspace.c 

CPPSRC = cppSubspace.c
#----- libs you need --------------------------------------------------
FLIBS = -latlas -llapack -lblas -lpthread
CLIBS = -lm -lgfortran
CPPLIBS = -lm -lgfortran
#----- suffix patterns ------------------------------------------------
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<
%.o: %.c
	$(CC) $(CFLAGS) -c  -o $@ $<
%.o: %.f90
	$(FC) $(FFLAGS) -c  -o $@ $<
#------------- FORTRAN ------------------------------------------------
FFLAGS = -std=f2008 -Wall -Wpedantic -Wextra -mtune=native -fexternal-blas -ffast-math -O3

DBGFLAGS = -O0  -fbacktrace -fbounds-check

FOBJS_CMPL =     $(FSRC_CMPL:.f90=.o)
FOBJMAIN_CMPL = $(FMAIN_CMPL:.f90=.o)

FOBJS_REAL =     $(FSRC_REAL:.f90=.o)
FOBJMAIN_REAL = $(FMAIN_REAL:.f90=.o)

MODS = $(wildcard *.mod)
#------ C ----------------- -------------------------------------------
CFLAGS = -std=c11 -Wall -Wpedantic -Wextra -mtune=native -ffast-math -O3
COBJS = $(CSRC:.c=.o)
#------- C++ ------------------------------------------------------------
CXXFLAGS = -std=c++14 -Wall -Wpedantic -Wextra -mtune=native -ffast-math -O3
CXXOBJS = $(CPPSRC:.cpp=.o)
#------ targeting a Fortran Program--------------------------------
all: $(TARGET_CMPL) $(TARGET_REAL) $(TARGET_C) $(TARGET_PYREAL) $(TARGET_PYCMPL)

debug: FFLAGS += -g $(DBGFLAGS)
debug: $(TARGET_CMPL) $(TARGET_REAL) $(TARGET_C)

real: $(TARGET_REAL)

cmpl: $(TARGET_CMPL)

c: $(TARGET_C)

cpp: $(TARGET_CPP)

pythonreal: $(TARGET_PYREAL)

pythoncmpl: $(TARGET_PYCMPL)

$(TARGET_PYREAL): $(FSRC_REAL)
	f2py3 --quiet -m $@ -c $(FSRC_REAL)  $(LDFLAGS)

$(TARGET_PYCMPL): $(FSRC_CMPL)
	f2py3 --quiet -m $@ -c $(FSRC_CMPL)  $(LDFLAGS)

$(TARGET_C): $(COBJS) $(FOBJS_REAL)
	$(CC) -o $@ $(CFLAGS) $(COBJS) $(FOBJS_REAL) $(FLIBS) $(CLIBS) $(LDFLAGS) 

$(TARGET_CPP): $(CPPOBJS) $(FOBJS_REAL)
	$(CC) -o $@ $(CFLAGS) $(COBJS) $(FOBJS_REAL) $(FLIBS) $(CLIBS) $(LDFLAGS) 
    
$(TARGET_CMPL): $(FOBJS_CMPL) $(FOBJMAIN_CMPL)
	$(FC) -o $@ $(FFLAGS) $(FOBJS_CMPL) $(FOBJMAIN_CMPL) $(FLIBS) $(LDFLAGS)

$(TARGET_REAL): $(FOBJS_REAL) $(FOBJMAIN_REAL)
	$(FC) -o $@ $(FFLAGS) $(FOBJS_REAL) $(FOBJMAIN_REAL) $(FLIBS) $(LDFLAGS)
#----------- CLEAN ----------------------------
clean:
	$(RM) $(FOBJS_REAL) $(FOBJMAIN_REAL) $(FOBJS_CMPL) $(FOBJMAIN_CMPL) $(COBJS) $(MODS)

