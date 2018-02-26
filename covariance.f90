module covariance
  use, intrinsic:: iso_c_binding, only: c_int
  use comm,only: wp
  !use perf, only : sysclock2ms
  Implicit none
  private
  public:: autocov

contains


pure subroutine Cautocov(x, N, M, C) bind(C)

 integer(c_int), intent(in) :: M,N
 complex(wp), intent(in) :: x(N)
 complex(wp), intent(out):: C(M,M)

 call autocov(x,C)

end subroutine Cautocov


pure subroutine autocov(x, C)
! autocovariance estimate of 1-D vector (e.g. noisy sinusoid)
! input:
! x is a 1-D vector
! N is length of x
! M is the size of signal block (integer)
! output:
! C is the 2-D result

 complex(wp), intent(in) :: x(:)
 complex(wp), intent(out):: C(:,:)

 integer:: i, N, M
 complex(wp), allocatable :: yn(:,:), R(:,:) !, work(M,M)
 
 N = size(x)
 M = size(C,1)
 
 allocate(yn(M,1), R(M,M))

 yn(:,1) = x(M:1:-1) ! index from M to 1, reverse order
 
 R = matmul(yn, conjg(transpose(yn)))
 !call zgemm('N','C',M,M,1,1._dp,yn,M,yn,M,0._dp,R,M) !slower, worse accuracy than matmul in Gfortran 5.2.1

 do i = 2, N-M ! not concurrent
    yn(:,1) = x(M-1+i:i-1:-1)
    R = R + matmul(yn, conjg(transpose(yn)))
    !call zgemm('N','C',M,M,1,1._dp,yn,M,yn,M,0._dp,work,M)
    !R = R + work
 enddo

 C = R / N

end subroutine autocov

end module covariance
