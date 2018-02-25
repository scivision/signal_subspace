module signals
    use, intrinsic:: iso_c_binding, only: c_int
    use comm,only: wp, pi
    implicit none
    private
    public :: signoise,randn
contains

subroutine signoise(fs,f0,snr,Ns,x) bind(c)
! generate noisy tone

  real(wp),intent(in) :: fs,f0,snr
  integer(c_int), intent(in) :: Ns
  real(wp),intent(out) :: x(Ns)


  real(wp) :: t(Ns),nvar
  real(wp) :: noise(Ns)
  integer(c_int) :: i

  t = [(i, i=0, size(x)-1)] / fs
  x = sqrt(2._wp) * cos(2._wp*pi*f0*t)

!--- add noise
  call randn(noise)

  nvar = 10._wp**(-snr/10._wp)

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

  real(wp),intent(out) :: noise
  real(wp):: u1, u2

  call random_number(u1)
  call random_number(u2)

  noise = sqrt(-2._wp * log(u1)) * cos(2._wp*pi*u2)

end subroutine randn

end module signals
