program test_subspace
use,intrinsic:: iso_fortran_env, only: int64, stderr=>error_unit
use,intrinsic:: iso_c_binding, only: c_int
use comm, only: wp, init_random_seed, debug
use perf, only: sysclock2ms
use subspace, only: esprit
use signals,only: signoise

implicit none

integer(c_int) :: Ns = 1024, &
                  Ntone = 2
real(wp) :: fs=48000, &
            f0=12345.6_wp, &
            snr=60  !dB
integer(c_int) :: M

complex(wp), allocatable :: x(:)
real(wp), allocatable :: tones(:),sigma(:)

integer(int64) :: tic,toc
integer :: narg
character(16) :: arg

call init_random_seed()
!----------- parse command line ------------------
M = Ns / 4
narg = command_argument_count()

call get_command_argument(narg,arg)
if (arg=='-v'.or.arg=='-d') then
  debug=.true.
  narg = narg-1
endif

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

print *, "Fortran Esprit: real bits:",storage_size(fs)
!---------- assign variable size arrays ---------------
allocate(x(Ns), tones(Ntone), sigma(Ntone))

!------ simulate noisy signal ------------ 
call signoise(fs,f0,snr, x)
!------ estimate frequency of sinusoid in noise --------
call system_clock(tic)
call esprit(x, size(x,kind=c_int), Ntone, M, fs, &
            tones,sigma)
call system_clock(toc)

! -- assert <0.1% error ---------
if (abs(tones(1)-f0) > 0.001_wp*f0) error stop 'excessive estimation error'

print '(A,100F10.2)', 'estimated tone freq [Hz]: ',tones
print '(A,100F5.1)', 'with sigma: ',sigma
print '(A,F10.3)', 'seconds to estimate frequencies: ',sysclock2ms(toc-tic) / 1000

print *,'OK'

! deallocate(x,tones,sigma) ! this is automatic going out of scope
end program test_subspace



