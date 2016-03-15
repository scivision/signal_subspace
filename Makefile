# Michael Hirsch 2014
# generic cross-platform, cross-language Makefil
FC = gfortran 
#---- What the EXE filename should be ---------------------------------
EXEC = cesprit

#----Sources (in order of dependency) ---------------------------------
FSOURCES = comm.f90 subspace.f90
CSOURCES = RunSubspace.c

LIBS = -lblas -llapack -lpthread -lgfortran -lm
#------------- FORTRAN ------------------------------------------------
FFLAGS = -Wall -pedantic -mtune=native -ffast-math -O3
#FFLAGS = -g $(DBGFLAGS) 

DBGFLAGS = -debug full -traceback
DBGFLAGS += -check bounds -check format -check output_conversion -check pointers -check uninit
DBGFLAGS += -fpe-all=0 # this traps all floating point exceptions

%.o: %.c
	$(CC) $(CFLAGS) -c  -o $@ $<
%.o: %.F90
	$(FC) $(FFLAGS) -c  -o $@ $<
%.o: %.f90
	$(FC) $(FFLAGS) -c  -o $@ $<
%.o: %.F
	$(FC) $(FFLAGS) -c  -o $@ $<
%.o: %.f
	$(FC) $(FFLAGS) -c  -o $@ $<

#------ That other language -------------------------------------------
CFLAGS = -Wall -pedantic -mtune=native -ffast-math -O3

#------ That other OO language ----------------------------------------
CPPFLAGS = -Wall -pedantic -mtune=native -O3
%.o: %.cpp
	$(CXX) $(CPPFLAGS) -c  -o $@ $<
#------ Turn the crank -----------------------
FOBJS = $(addsuffix .o, $(basename $(FSOURCES)))
MODS = $(addsuffix .mod, $(basename $(FSOURCES)))
COBJS = $(CSOURCES:%.c=%.o)

#------ A C program linking to Fortran --------------------------------
$(EXEC): $(COBJS) $(FOBJS) 
	$(CC) -o $@ $(CFLAGS) $(COBJS) $(FOBJS) $(LIBS) $(LDFLAGS)

#----------- CLEAN ----------------------------

clean:
	$(RM) $(FOBJS) $(COBJS) $(MODS)

