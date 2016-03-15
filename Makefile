# Michael Hirsch 2014
# cross-platform, cross-language Makefile linking Fortran to C main
FC = gfortran
#---- What the EXE filename should be ---------------------------------
EXEC = cesprit
#----Sources (in order of dependency) ---------------------------------
FSOURCES = comm.f90 perf.f90 subspace.f90 signals.f90
CSOURCES = RunSubspace.c
#----- libs you need --------------------------------------------------
LIBS = -lblas -llapack -lpthread -lgfortran -lm
#----- suffix patterns ------------------------------------------------
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
#------------- FORTRAN ------------------------------------------------
FFLAGS = -Wall -pedantic -mtune=native -ffast-math -O3
#FFLAGS = -g $(DBGFLAGS)

DBGFLAGS = -debug full -traceback
DBGFLAGS += -check bounds -check format -check output_conversion -check pointers -check uninitgit 
DBGFLAGS += -fpe-all=0 # this traps all floating point exceptions

FOBJS = $(addsuffix .o, $(basename $(FSOURCES)))
MODS = $(addsuffix .mod, $(basename $(FSOURCES)))
#------ That other language -------------------------------------------
CFLAGS = -Wall -pedantic -mtune=native -ffast-math -O3
COBJS = $(CSOURCES:%.c=%.o)
#------ That other OO language ----------------------------------------
CPPFLAGS = -Wall -pedantic -mtune=native -O3
%.o: %.cpp
	$(CXX) $(CPPFLAGS) -c  -o $@ $<

CPPOBJS = $(CPPSOURCES:%.cpp=%.o)
#------ A C program linking to Fortran --------------------------------
$(EXEC): $(COBJS) $(FOBJS) 
	$(CC) -o $@ $(CFLAGS) $(COBJS) $(FOBJS) $(LIBS) $(LDFLAGS)
#----------- CLEAN ----------------------------
clean:
	$(RM) $(FOBJS) $(COBJS) $(MODS)

