module signals
use, intrinsic:: iso_c_binding, only: c_int
use comm, only: sp, dp, J

implicit none

interface randn
  procedure randn_r, randn_c
end interface randn

interface signoise
  procedure signoise_r, signoise_c
end interface signoise

private

real(dp) :: pi = 4._dp * atan(1._dp)
real(sp) :: pi_sp = 4._sp * atan(1._sp)

public :: signoise
contains

subroutine signoise_c(fs,f0,snr,Ns,x) bind(c)
! generate noisy tone

real(dp),intent(in) :: fs,f0,snr
integer(c_int), intent(in) :: Ns
complex(dp),intent(out) :: x(Ns)

real(dp) :: t(Ns),nvar
complex(dp) :: noise(Ns)
integer :: i

t = [(i, i=0,size(x)-1)] / fs
x = sqrt(2._dp) * exp(J * 2._dp * pi * f0 * t)
!--- add noise
call randn(noise)

nvar = 10._dp**(-snr/10._dp)

x = x + sqrt(nvar)*noise

end subroutine signoise_c


subroutine signoise_r(fs,f0,snr,Ns,x) bind(c)
! generate noisy tone

real(sp),intent(in) :: fs,f0,snr
integer(c_int), intent(in) :: Ns
real(sp),intent(out) :: x(Ns)


real(sp) :: t(Ns),nvar
real(sp) :: noise(Ns)
integer(c_int) :: i

t = [(i, i=0, size(x)-1)] / fs
x = sqrt(2._sp) * cos(2._sp * pi_sp * f0 * t)

!--- add noise
call randn(noise)

nvar = 10._sp**(-snr / 10._sp)

x = x + sqrt(nvar) * noise

end subroutine signoise_r

!---------------------------------

impure elemental subroutine randn_c(noise)
! implements Box-Muller Transform
! https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform
!
! Input:
! N: length of 1-D noise vector
! Output:
! noise: Gaussian 1-D noise vector

complex(dp), intent(out) :: noise
real(dp) :: u1, u2, x_i, x_r

call random_number(u1)
call random_number(u2)

x_r = sqrt(-2._dp * log(u1)) * cos(2._dp * pi * u2)
x_i = sqrt(-2._dp * log(u1)) * sin(2._dp * pi * u2)

noise = cmplx(x_r, x_i, dp)  !complex() can only handle scalars

end subroutine randn_c


impure elemental subroutine randn_r(noise)
! implements Box-Muller Transform
! https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform
!
! Input:
! N: length of 1-D noise vector
! Output:
! noise: Gaussian 1-D noise vector

real(sp), intent(out) :: noise
real(sp) :: u1, u2

call random_number(u1)
call random_number(u2)

noise = sqrt(-2._sp * log(u1)) * cos(2._sp * pi_sp * u2)

end subroutine randn_r

end module signals
