program test_subspace

use comm, only: sp, i64,stdout,stderr,sizeof,c_int
use perf, only: sysclock2ms,assert
use subspace, only: esprit
use signals,only: signoise
use filters,only: fircircfilter

implicit none

integer(c_int) :: Ns = 1024, &
                  Ntone = 2
real(sp) :: fs=48000, &
            f0=12345.6, &
            snr=60  !dB
character(len=*),parameter :: bfn='../bfilt.txt'

integer(c_int) :: M,Nb,fstat
logical :: filtok
 

real(sp),allocatable :: x(:),b(:),y(:)
real(sp),allocatable :: tones(:),sigma(:)

integer(i64) :: tic,toc
!----------- parse command line ------------------
integer(c_int) :: narg
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

write(stdout,*) "Fortran Esprit: Real Single Precision"
!---------- assign variable size arrays ---------------
allocate(x(Ns),y(Ns),tones(Ntone/2),sigma(Ntone/2))
!--- checking system numerics --------------
if (sizeof(fs).ne.4) write(stderr,*) 'expected 4-byte real but you have real bytes: ', sizeof(fs)

!------ simulate noisy signal ------------ 
call signoise(fs,f0,snr,Ns,&
              x)
!------ filter noisy signal --------------
! read coefficients 'b'
filtok=.false.
open (unit=99, file=bfn, status='old',iostat=fstat)
if (fstat.eq.0) then
    read(99,*) Nb !first line of file: number of coeff
    allocate(b(Nb))
    read(99,*) b ! second line all coeff
    close(99)
    !write(stdout,*) b

    call system_clock(tic)
    call fircircfilter(x,Ns,b,size(b),y)
    call system_clock(toc)
    write(stdout,*) 'seconds to FIR filter: ',sysclock2ms(toc-tic)/1000

    filtok = .not.isnan(y(1))
endif

if (fstat.ne.0 .or. .not.filtok) then
    write(stderr,*) 'skipped FIR filter.'
    y=x
endif
!------ estimate frequency of sinusoid in noise --------
call system_clock(tic)
call esprit(y,size(y),Ntone,M,fs,&
            tones,sigma)
call system_clock(toc)

! -- assert <0.1% error ---------
call assert(abs(tones(1)-f0).le.0.001*f0)

write(stdout,*) 'estimated tone freq [Hz]: ',tones
write(stdout,*) 'with sigma: ',sigma
write(stdout,*) 'seconds to estimate frequencies: ',sysclock2ms(toc-tic)/1000

write(stdout,*) 'OK'

deallocate(x,y,tones,sigma,b)
end program test_subspace



