program test_subspace

use subspace
use signals,only: signoise

Implicit none

integer :: Ns = 1024 !default value
real(dp) :: fs=48000_dp, fb=12345.6_dp, &
            snr=60  !dB
integer :: M
integer :: Ntone=1

complex(dp),allocatable :: x(:)
real(dp),allocatable :: tones(:),sigma(:)

integer(i64) :: tic,toc
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

call system_clock(tic)
call esprit(x,size(x),Ntone,M,fs,&
            tones,sigma)
call system_clock(toc)


write(stdout,*) ' ESPRIT found tone(s) [Hz]: ',tones
write(stdout,*) ' with sigma: ',sigma
write(stdout,*) ' seconds to compute: ',sysclock2ms(toc-tic)/1000_dp
end program test_subspace



