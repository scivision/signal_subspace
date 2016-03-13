module signals
    use, intrinsic :: iso_fortran_env, only : dp=>real64, i64=>int64, stdout=>output_unit
    use perf,only: init_random_seed
    implicit none
    complex(dp),parameter :: J=(0._dp,1._dp)
    real(dp),parameter :: pi = 4_dp*datan(1._dp)
contains

subroutine signoise(fs,fb,snr,Ns,x)

    real(dp),intent(in) :: fs,fb,snr
    integer, intent(in) :: Ns
    complex(dp),intent(out) :: x(Ns)

    real(dp) :: t,nvar
    complex(dp) :: noise(Ns)
    integer :: i

    do i=1,size(x)
    t = (i-1)/fs
    x(i) = sqrt(2._dp) * exp(J*2._dp*pi*fb*t)
    enddo
!--- add noise
    call randn(Ns,noise)

    nvar = 10._dp**(-snr/10._dp)

    x = x + sqrt(nvar)*noise


end subroutine signoise

subroutine randn (N,rout)
! https://people.sc.fsu.edu/~jburkardt/f_src/normal/normal.f90
!*****************************************************************************80
!
!! C8_NORMAL_01 returns a unit pseudonormal C8.
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
  complex(dp),intent(out) :: rout(N)
  real (dp):: v1(N), v2(N), x_c(N), x_r(N)

 CALL init_random_seed()

  call random_number(v1)
  call random_number(v2)

  x_r = sqrt ( - 2._dp * log ( v1 ) ) * cos ( 2._dp * pi * v2 )
  x_c = sqrt ( - 2._dp * log ( v1 ) ) * sin ( 2._dp * pi * v2 )

  rout = cmplx ( x_r, x_c, dp)

end subroutine randn

end module signals
