module signals
    use, intrinsic:: iso_c_binding, only: c_int
    use comm,only: sp
    implicit none
    real(sp),parameter :: pi = 4.*atan(1.)
    public :: signoise,randn, pi
contains

subroutine signoise(fs,f0,snr,Ns,x) bind(c)
! generate noisy tone

    real(sp),intent(in) :: fs,f0,snr
    integer(c_int), intent(in) :: Ns
    real(sp),intent(out) :: x(Ns)


    real(sp) :: t(Ns),nvar
    real(sp) :: noise(Ns)
    integer(c_int) :: i

    t = [(i, i=0, size(x)-1)] / fs
    x = sqrt(2.) * cos(2.*pi*f0*t)

!--- add noise
    call randn(noise)

    nvar = 10.**(-snr/10.)

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

  real(sp),intent(out) :: noise
  real (sp):: u1, u2

  call random_number(u1)
  call random_number(u2)

  noise = sqrt (-2. * log(u1)) * cos(2.*pi*u2)

end subroutine randn

end module signals
