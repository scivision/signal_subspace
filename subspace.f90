module subspace
    use, intrinsic :: iso_fortran_env, only : dp=>real64, i64=>int64, stdout=>output_unit
    use perf, only : init_random_seed,sysclock2ms
    use signals,only: pi
    Implicit none
contains

subroutine esprit(x,N,L,M,fs,tones,sigma)

    integer, intent(in) :: L,M,N
    complex(dp),intent(in) :: x(N)
    real(dp),intent(in) :: fs
    real(dp),intent(out) :: tones(L),sigma(L)

    integer :: Lwork,i
    complex(dp) :: R(M,M),U(M,M),VT(M,M), WORK(4*M), S1(M-1,L), S2(M-1,L), &
        eig(L),junk(L,L)
    real(dp) :: S(M,M),RWORK(5*M),ang(L)
    integer :: luinfo=0
    integer :: svdinfo
    complex(dp) :: W1(L,L), IPIV(M-1), Phi(L,L)

    integer(i64) :: tic,toc

Lwork = 4*M

call system_clock(tic)
call corrmtx(x,size(x),M,R)
call system_clock(toc)
if (sysclock2ms(toc-tic).gt.1) write(stdout,*) 'ms to compute autocovariance estimate:',sysclock2ms(toc-tic)


call system_clock(tic)
call zgesvd('A','N',M,M,R,M,S,U,M,VT,M,WORK,LWORK,RWORK,svdinfo)
if (svdinfo.ne.0) write(stdout,*) 'SVD return code',svdinfo
call system_clock(toc)
if (sysclock2ms(toc-tic).gt.1) write(stdout,*) 'ms to compute SVD:',sysclock2ms(toc-tic)

S1 = U(1:M-1,1:L)
S2 = U(2:M,1:L)

call system_clock(tic)
W1=matmul(conjg(transpose(S1)),S1)
call zgetrf(L,L,W1,L,ipiv,luinfo) !LU decomp
call zgetri(L,W1,L,ipiv,work,Lwork,luinfo) !LU inversion
if (luinfo.ne.0) write(stdout,*) 'LU inverse output code',luinfo

Phi = matmul(matmul(W1, conjg(transpose(S1))), S2)
call system_clock(toc)
if (sysclock2ms(toc-tic).gt.1) write(stdout,*) 'ms to compute Phi via LU inv():',sysclock2ms(toc-tic)

call system_clock(tic)
call zgeev('N','N',L,Phi,L,eig,junk,L,junk,L,work,lwork,rwork,luinfo)
if (luinfo.ne.0) write(stdout,*) 'eig output code',luinfo
call system_clock(toc)
if (sysclock2ms(toc-tic).gt.1) write(stdout,*) 'ms to compute eigenvalues:',sysclock2ms(toc-tic)


ang = atan2(aimag(eig),real(eig))

tones = abs(fs*ang/(2*pi))
!eigenvalues
do i=1,L
    sigma(i) = S(i,i)
enddo

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
complex(dp),intent(in) :: x(N)
complex(dp),intent(out):: C(M,M)

integer :: i
complex(dp) :: yn(M,1), R(M,M)

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
