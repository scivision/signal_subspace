!
module subspace
use, intrinsic :: iso_fortran_env, only : dp=>real64, stdout=>output_unit
Implicit none
real(dp),parameter :: pi = 4_dp*datan(1._dp)
contains

subroutine esprit(x,N,L,M,fs,tones)

integer, intent(in) :: L,M,N
double complex,intent(in) :: x(N)
real(dp),intent(in) :: fs
real(dp),intent(out) :: tones(L)

integer :: Lwork
complex(dp) :: R(M,M),U(M,M),VT(M,M), WORK(4*M), S1(M-1,L), S2(M-1,L), &
    eig(L),junk(L,L)
real(dp) :: S(M,M),RWORK(5*M),ang(L),f(L)
integer :: luinfo=0
integer :: svdinfo

complex(dp) :: W1(L,L), IPIV(M-1), Phi(L,L)

Lwork = 4*M

!write(stdout,*) 'autocov'
call corrmtx(x,size(x),M,R)


call zgesvd('A','N',M,M,R,M,S,U,M,VT,M,WORK,LWORK,RWORK,svdinfo)
write(stdout,*) 'SVD return code',svdinfo
S1 = U(1:M-1,1:L)
S2 = U(2:M,1:L)

W1=matmul(conjg(transpose(S1)),S1)
!write(stdout,*) 'LU decomp'
call zgetrf(L,L,W1,L,ipiv,luinfo) !LU decomp
!write(stdout,*) 'LU inverse'
call zgetri(L,W1,L,ipiv,work,Lwork,luinfo) !LU inversion
write(stdout,*) 'LU inverse output code',luinfo

Phi = matmul(matmul(W1, conjg(transpose(S1))), S2)

!write(stdout,*) 'find eigenvalues'
call zgeev('N','N',L,Phi,L,eig,junk,L,junk,L,work,lwork,rwork,luinfo)
write(stdout,*) 'eig output code',luinfo

!write(stdout,*) 'eig -> angle'
ang = atan2(aimag(eig),real(eig))
!write(stdout,*) 'angle -> tone'
tones = fs*ang/(2*pi)

end subroutine esprit
!----------------------------------------------------------------------
subroutine corrmtx(x,N,M,C)

! input:
! x is a 1-D vector
! N is length of x
! M is the size of signal block (integer)
! output:
! C is the 2-D result

integer, intent(in) :: M,N
double complex,intent(in) :: x(N)
double complex,intent(out):: C(M,M)

integer :: i
double complex :: yn(M,1), R(M,M)

yn(:,1) = x(M:1:-1)

R = matmul(yn,conjg(transpose(yn)))
!call zgemm('N','C',M,M,M,1_dp,yn,M,yn,M,0_dp,R,M) !half speed of matmul, Gfortran 5.2.1

do i = 1,N-M-1
    yn(:,1) = x(M-1+i:i:-1)
    R = R + matmul(yn,conjg(transpose(yn)))
enddo

C = R/real(N,dp)

end subroutine corrmtx

end module subspace
