module signals
    use comm
    use perf,only: init_random_seed
    implicit none
contains

subroutine signoise(fs,f0,snr,Ns,x)

    real(dp),intent(in) :: fs,f0,snr
    integer, intent(in) :: Ns
    complex(dp),intent(out) :: x(Ns)

    real(dp) :: t,nvar
    complex(dp) :: noise(Ns)
    integer :: i

    do i=1,size(x)
    t = (i-1)/fs
    x(i) = sqrt(2._dp) * exp(J*2._dp*pi*f0*t)
    enddo
!--- add noise
    call randn(Ns,noise)

    nvar = 10._dp**(-snr/10._dp)

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
  complex(dp),intent(out) :: rout(N)
  real (dp):: v1(N), v2(N), x_i(N), x_r(N)

 CALL init_random_seed()

  call random_number(v1)
  call random_number(v2)

  x_r = sqrt ( - 2._dp * log ( v1 ) ) * cos ( 2._dp * pi * v2 )
  x_i = sqrt ( - 2._dp * log ( v1 ) ) * sin ( 2._dp * pi * v2 )

  rout = cmplx ( x_r, x_i,dp)  !complex() can only handle scalars

end subroutine randn

end module signals
