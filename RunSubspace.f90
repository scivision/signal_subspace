program test_subspace
use,intrinsic:: iso_fortran_env, only: int64, stderr=>error_unit
use,intrinsic:: iso_c_binding, only: c_int
use comm, only: dp, random_init, err
use perf, only: sysclock2ms
use subspace, only: esprit
use signals,only: signoise

implicit none

integer(c_int) :: Ns = 1024, &
                  Ntone=2
real(dp) :: fs=48000, &
            f0=12345.6, &
            snr=60  !dB
integer(c_int) :: M

complex(dp),allocatable :: x(:)
real(dp),allocatable :: tones(:),sigma(:)

integer(int64) :: tic,toc
integer :: narg
character(16) :: arg

call random_init()
!----------- parse command line ------------------
M = Ns / 4_c_int
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

print *, "Fortran Esprit: Complex Double Precision"
!---------- assign variable size arrays ---------------
allocate(x(Ns), tones(Ntone), sigma(Ntone))
!--- checking system numerics --------------
if (storage_size(fs) /= 64) then
  write(stderr,*) 'expected 64-bit real but you have: ', storage_size(fs)
  call err('')
endif
if (storage_size(x(1)) /= 128) then
  write(stderr,*) 'expected 128-bit complex but you have: ', storage_size(x(1))
  call err('')
endif

!------ simulate noisy signal ------------ 
call signoise(fs,f0,snr,Ns,&
              x)
!------ estimate frequency of sinusoid in noise --------
call system_clock(tic)
call esprit(x, size(x,kind=c_int), Ntone, M, fs, &
            tones,sigma)
call system_clock(toc)

! -- assert <0.1% error ---------
if (abs(tones(1)-f0) > 0.001*f0) call err('excessive estimation error')

print '(A,100F10.2)', 'estimated tone freq [Hz]: ',tones
print '(A,100F5.1)', 'with sigma: ',sigma
print '(A,F10.3)', 'seconds to estimate frequencies: ',sysclock2ms(toc-tic) / 1000

print *,'OK'

! deallocate(x,tones,sigma) ! this is automatic going out of scope
end program test_subspace

