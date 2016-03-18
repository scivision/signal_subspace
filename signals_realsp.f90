module signals
    use comm,only: sp
    use perf,only: init_random_seed
    implicit none
    real(sp),parameter :: pi = 4_sp*atan(1._sp)

    private
    public :: signoise,randn
contains

subroutine signoise(fs,f0,snr,Ns,x)

    real(sp),intent(in) :: fs,f0,snr
    integer, intent(in) :: Ns
    real(sp),intent(out) :: x(Ns)


    real(sp) :: t,nvar
    real(sp) :: noise(Ns)
    integer :: i

    do i=1,size(x)
    t = (i-1)/fs
    x(i) = sqrt(2._sp) * cos(2._sp*pi*f0*t)
    enddo
!--- add noise
    call randn(Ns,noise)

    nvar = 10._sp**(-snr/10._sp)

    x = x + sqrt(nvar)*noise

end subroutine signoise

subroutine randn (N,rout)
! https://people.sc.fsu.edu/~jburkardt/f_src/normal/normal.f90
!
!  returns a unit pseudonormal C8.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    31 May 2007, 13 Mar 2016
!
!  Author:
!
!    John Burkardt, Michael Hirsch
!
!  Parameters:
!    Input, N length of 1-D complex dp noise vector
!    Output, complex (dp ) rout, 1-D vector drawn from gaussian PDF.


  integer,intent(in) :: N
  real(sp),intent(out) :: rout(N)
  real (sp):: v1(N), v2(N)

 CALL init_random_seed()

  call random_number(v1)
  call random_number(v2)

  rout = sqrt ( - 2._sp * log ( v1 ) ) * cos ( 2._sp * pi * v2 )


end subroutine randn

end module signals
