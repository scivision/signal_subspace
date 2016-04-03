module covariance
    use comm,only: sp,stdout
    !use perf, only : sysclock2ms
    Implicit none
    private
    public::autocov

contains

subroutine autocov(x,N,M,C)

! input:
! x is a 1-D vector
! N is length of x
! M is the size of signal block (integer)
! output:
! C is the 2-D result

 integer, intent(in) :: M,N
 real(sp),intent(in) :: x(N)
 real(sp),intent(out):: C(M,M)

 integer :: i
 real(sp) :: yn(M,1), R(M,M)!, work(M,M)

 yn(:,1) = x(M:1:-1)

 R = matmul(yn,(transpose(yn)))
 
 do i = 1,N-M-1 ! yes, -1; NO, not concurrent!
    yn(:,1) = x(M+i-1:i:-1) !yes, -1
    R = R + matmul(yn,(transpose(yn)))
 enddo

 C = R/real(N,sp)

end subroutine autocov

end module covariance
