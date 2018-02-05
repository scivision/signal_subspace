module signals
    use, intrinsic:: iso_c_binding, only: c_int
    use comm,only: dp, pi, J
    implicit none

    private
    public :: signoise,randn
contains

subroutine signoise(fs,f0,snr,Ns,x) bind(c)
! generate noisy tone

    real(dp),intent(in) :: fs,f0,snr
    integer(c_int), intent(in) :: Ns
    complex(dp),intent(out) :: x(Ns)

    real(dp) :: t(Ns),nvar
    complex(dp) :: noise(Ns)
    integer :: i

    t = [(i, i=0,size(x)-1)] / fs
    x = sqrt(2._dp) * exp(J*2._dp*pi*f0*t)
!--- add noise
    call randn(noise)

    nvar = 10._dp**(-snr/10._dp)

    x = x + sqrt(nvar)*noise

end subroutine signoise


impure elemental subroutine randn(noise)
! implements Box-Muller Transform
! https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform
!
! Input:
! N: length of 1-D noise vector
! Output:
! noise: Gaussian 1-D noise vector

  complex(dp),intent(out) :: noise
  real (dp):: u1, u2, x_i, x_r

  call random_number(u1)
  call random_number(u2)

  x_r = sqrt(-2._dp * log(u1)) * cos(2._dp*pi*u2)
  x_i = sqrt(-2._dp * log(u1) ) * sin(2._dp * pi * u2)

  noise = cmplx(x_r, x_i, dp)  !complex() can only handle scalars

end subroutine randn

end module signals
