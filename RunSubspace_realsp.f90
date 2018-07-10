program test_subspace
use,intrinsic:: iso_fortran_env, only: int64, stderr=>error_unit
use,intrinsic:: iso_c_binding, only: c_int,c_bool
use comm, only: sp, random_init, err
use perf, only: sysclock2ms
use subspace, only: esprit
use signals, only: signoise
use filters, only: fircircfilter

implicit none

integer(c_int) :: Ns = 1024, &
                  Ntone = 2
real(sp) :: fs=48000, &
            f0=12345.6, &
            snr=60  !dB
character(*),parameter :: bfn='../bfilt.txt'

integer(c_int) :: M,Nb
integer:: fstat
logical(c_bool) :: filtok
 

real(sp),allocatable :: x(:), b(:), y(:)
real(sp),allocatable :: tones(:),sigma(:)

integer(int64) :: tic,toc
integer :: narg,u
character(16) :: arg

call random_init()
!----------- parse command line ------------------
M = Ns / 2_c_int
narg = command_argument_count()

if (narg > 0) then
  call get_command_argument(1,arg); read(arg,*) Ns
endif
if (narg > 1) then
  call get_command_argument(2,arg); read(arg,*) fs
endif
if (narg > 2) then
  call get_command_argument(3,arg); read(arg,*) Ntone
endif
if (narg > 3) then
  call get_command_argument(4,arg); read(arg,*) M
endif
if (narg > 4) then
  call get_command_argument(5,arg); read(arg,*) snr !dB
endif

print *, "Fortran Esprit: Real Single Precision"
!---------- assign variable size arrays ---------------
allocate(x(Ns), y(Ns), tones(Ntone/2), sigma(Ntone/2))
!--- checking system numerics --------------
if (sizeof(fs) /= 4) then
  write(stderr,*) 'expected 4-byte real but you have real bytes: ', sizeof(fs)
  call err('')
endif
!------ simulate noisy signal ------------ 
call signoise(fs, f0, snr, Ns, x)   ! output "X"
!------ filter noisy signal --------------
! read coefficients 'b'
filtok=.false.
open(newunit=u, file=bfn, status='old', action='read', iostat=fstat)

if (fstat == 0) then
  read(u,*) Nb !first line of file: number of coeff
  allocate(b(Nb))
  read(u,*) b ! second line all coeff
  close(u)
!    print *,'FIR Coefficients'
!    print '(EN10.1)', b

  call system_clock(tic)
  call fircircfilter(x, size(x,kind=c_int), b, size(b,kind=c_int), y, filtok)
  call system_clock(toc)
  print '(A,EN10.1)', 'seconds to FIR filter: ',sysclock2ms(toc-tic) / 1000
endif

if (fstat /= 0 .or. .not. filtok) then
  write(stderr,*) 'skipped FIR filter.'
  y=x
endif
!------ estimate frequency of sinusoid in noise --------
call system_clock(tic)
call esprit(y, size(y,kind=c_int), Ntone, M, fs, &
            tones,sigma)
call system_clock(toc)

! -- assert <0.1% error ---------
if (abs(tones(1)-f0) > 0.001*f0) call err('excessive frequency estimation error')

print '(A,100F10.2)', 'estimated tone freq [Hz]: ',tones
print '(A,100F5.1)', 'with sigma: ',sigma
print '(A,F10.3)', 'seconds to estimate frequencies: ',sysclock2ms(toc-tic) / 1000

print *,'OK'

! deallocate(x,y,tones,sigma)  ! this is automatic going out of scope
end program test_subspace

