program test_subspace

use subspace
use signals,only: signoise

Implicit none

integer :: Ns = 1024 !default value
real(dp) :: fs=48000_dp, fb=12345.6_dp,snr=60
integer :: M
integer :: Ntone=1

complex(dp),allocatable :: x(:)
real(dp),allocatable :: tones(:),sigma(:)
!-----------------------------
integer :: narg
character(len=16) :: arg

narg = command_argument_count()

if (narg.GT.0) then
 call get_command_argument(1,arg); read(arg,*) Ns
endif
if (narg.GT.1) then
 call get_command_argument(2,arg); read(arg,*) fs
endif
if (narg.GT.2) then
 call get_command_argument(3,arg); read(arg,*) Ntone
endif
if (narg.GT.3) then
    call get_command_argument(4,arg); read(arg,*) M
 else
    M=Ns/2
endif
!-------------------------
allocate(x(Ns),tones(Ntone),sigma(Ntone))


call signoise(fs,fb,snr,Ns,&
              x)


call esprit(x,size(x),Ntone,M,fs,&
            tones,sigma)

write(stdout,*) ' ESPRIT found tone(s) [Hz]: ',tones
write(stdout,*) ' with sigma: ',sigma
end program test_subspace



