program test_subspace

use comm, only: dp, i64,stdout,stderr,sizeof
use perf, only: sysclock2ms,assert
use subspace, only: esprit
use signals,only: signoise

Implicit none

integer :: Ns = 1024, &
           Ntone=2
real(dp) :: fs=48000, f0=12345.6, &
            snr=60  !dB
integer :: M

complex(dp),allocatable :: x(:)
real(dp),allocatable :: tones(:),sigma(:)

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

write(stdout,*) "Fortran Esprit: Complex Double Precision"
!---------- assign variable size arrays ---------------
allocate(x(Ns),tones(Ntone),sigma(Ntone))
!--- checking system numerics --------------
if (sizeof(fs).ne.8) write(stderr,*) 'expected 8-byte real but you have real bytes: ', sizeof(fs)
if (sizeof(x(1)).ne.16) write(stderr,*) 'expected 16-byte complex but you have complex bytes: ', sizeof(x(1))

!------ simulate noisy signal ------------ 
call signoise(fs,f0,snr,Ns,&
              x)
!------ estimate frequency of sinusoid in noise --------
call system_clock(tic)
call esprit(x,size(x),Ntone,M,fs,&
            tones,sigma)
call system_clock(toc)

! -- assert <0.1% error ---------
call assert(abs(tones(1)-f0).le.0.001*f0)

write(stdout,*) 'estimated tone freq [Hz]: ',tones
write(stdout,*) 'with sigma: ',sigma
write(stdout,*) 'seconds to compute: ',sysclock2ms(toc-tic)/1000

write(stdout,*) 'OK'
end program test_subspace



