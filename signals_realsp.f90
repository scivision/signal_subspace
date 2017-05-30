module signals
    use comm,only: sp, c_int, init_random_seed
    implicit none
    real(sp),parameter :: pi = 4.*atan(1.)
    public :: signoise,randn, pi
contains

subroutine signoise(fs,f0,snr,Ns,x)

    real(sp),intent(in) :: fs,f0,snr
    integer(c_int), intent(in) :: Ns
    real(sp),intent(out) :: x(Ns)


    real(sp) :: t,nvar
    real(sp) :: noise(Ns)
    integer :: i

    do i=1,size(x)
    t = (i-1) / fs
    x(i) = sqrt(2.) * cos(2.*pi*f0*t)
    enddo
!--- add noise
    call randn(Ns,noise)

    nvar = 10.**(-snr/10.)

    x = x + sqrt(nvar)*noise

end subroutine signoise

subroutine randn (N,noise)
! implements Box-Muller Transform
! https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform
!
! Input:
! N: length of 1-D noise vector
! Output:
! noise: Gaussian 1-D noise vector

  integer(c_int),intent(in) :: N
  real(sp),intent(out) :: noise(N)
  real (sp):: u1(N), u2(N)

  call init_random_seed()

  call random_number(u1)
  call random_number(u2)

  noise = sqrt ( - 2. * log ( u1 ) ) * cos ( 2. * pi * u2 )

end subroutine randn

end module signals
