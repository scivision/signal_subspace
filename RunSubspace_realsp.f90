program test_subspace

use comm
use perf, only: sysclock2ms
use subspace, only: esprit
use signals,only: signoise

Implicit none

integer :: Ns = 1024 !default value
real(sp) :: fs=48000, f0=12345.6, &
            snr=60  !dB
integer :: M
integer :: Ntone=4

real(sp),allocatable :: x(:)
real(sp),allocatable :: tones(:),sigma(:)

integer(i64) :: tic,toc
!----------- parse command line ------------------
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
if (narg.GT.4) then
 call get_command_argument(5,arg); read(arg,*) snr !dB
endif
!---------- assign variable size arrays ---------------
allocate(x(Ns),tones(Ntone/2),sigma(Ntone/2))
!--- checking system numerics --------------
if (sizeof(fs).ne.4) write(stderr,*) 'expected 4-byte real but you have real bytes: ', sizeof(fs)


!------ simulate noisy signal ------------ 
call signoise(fs,f0,snr,Ns,&
              x)
!------ estimate frequency of sinusoid in noise --------
call system_clock(tic)
call esprit(x,size(x),Ntone,M,fs,&
            tones,sigma)
call system_clock(toc)


write(stdout,*) ' ESPRIT found tone(s) [Hz]: ',tones
write(stdout,*) ' with sigma: ',sigma
write(stdout,*) ' seconds to compute: ',sysclock2ms(toc-tic)/1000
end program test_subspace



