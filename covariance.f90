module covariance
    use comm,only: dp,stdout
    !use perf, only : sysclock2ms
    Implicit none
    private
    public::autocov

contains

subroutine autocov(x,N,M,C)
! autocovariance estimate of 1-D vector (e.g. noisy sinusoid)
! input:
! x is a 1-D vector
! N is length of x
! M is the size of signal block (integer)
! output:
! C is the 2-D result

 integer, intent(in) :: M,N
 complex(dp),intent(in) :: x(N)
 complex(dp),intent(out):: C(M,M)

 integer :: i
 complex(dp) :: yn(M,1), R(M,M)!, work(M,M)

 yn(:,1) = x(M:1:-1)

 R = matmul(yn,conjg(transpose(yn)))
 !call zgemm('N','C',M,M,1,1._dp,yn,M,yn,M,0._dp,R,M) !slower, worse accuracy than matmul in Gfortran 5.2.1

 do i = 1,N-M-1 ! yes, -1; NO, not concurrent!
    yn(:,1) = x(M+i-1:i:-1) !yes, -1
    R = R + matmul(yn,conjg(transpose(yn)))
    !call zgemm('N','C',M,M,1,1._dp,yn,M,yn,M,0._dp,work,M)
    !R = R + work
 enddo

 C = R/real(N,dp)

end subroutine autocov

end module covariance