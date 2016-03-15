module subspace
    use comm,only: sp,stdout,stderr
    !use perf, only : init_random_seed,sysclock2ms
    Implicit none
    real(sp),parameter :: pi = 4_sp*atan(1._sp)
    private
    public::esprit,corrmtx

contains

subroutine esprit(x,N,L,M,fs,tout,sigma)

    integer, intent(in) :: L,M,N
    real(sp),intent(in) :: x(N)
    real(sp),intent(in) :: fs
    real(sp),intent(out) :: tout(L/2),sigma(L)

    real(sp) :: tones(L)
    integer :: Lwork,i
    real(sp) :: R(M,M),U(M,M),VT(M,M), S1(M-1,L), S2(M-1,L)
    real(sp) :: S(M,M),RWORK(5*M),ang(L),work(6*m)
    integer :: luinfo=0
    integer :: svdinfo
    real(sp) :: W1(L,L), IPIV(M-1)
    complex(sp) :: Phi(L,L), CWORK(6*M), junk(L,L), eig(L)

   ! integer(i64) :: tic,toc

Lwork = 6*M !at least5M for sgesvd
!------ estimate autocovariance from single time sample vector (1-D)
!call system_clock(tic)
call corrmtx(x,size(x),M,R)
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1) write(stdout,*) 'ms to compute autocovariance estimate:',sysclock2ms(toc-tic)

!-------- SVD -------------------
!call system_clock(tic)
call sgesvd('A','N',M,M,R,M,S,U,M,VT,M,WORK,LWORK,RWORK,svdinfo)
if (svdinfo.ne.0) write(stderr,*) 'SVD return code',svdinfo
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute SVD:',sysclock2ms(toc-tic)

S1 = U(1:M-1,1:L)
S2 = U(2:M,1:L)

!call system_clock(tic)
W1=matmul((transpose(S1)),S1)
call sgetrf(L,L,W1,L,ipiv,luinfo) !LU decomp
call sgetri(L,W1,L,ipiv,work,Lwork,luinfo) !LU inversion
if (luinfo.ne.0) write(stderr,*) 'LU inverse output code',luinfo

Phi = matmul(matmul(W1, (transpose(S1))), S2)
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute Phi via LU inv():',sysclock2ms(toc-tic)

!call system_clock(tic)
call cgeev('N','N',L,Phi,L,eig,junk,L,junk,L,cwork,lwork,rwork,luinfo)
if (luinfo.ne.0) write(stderr,*) 'eig output code',luinfo
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute eigenvalues:',sysclock2ms(toc-tic)


ang = atan2(aimag(eig),real(eig))

tones = abs(fs*ang/(2*pi))

tout = tones(1:L:2)

!eigenvalues
do i=1,L/2
    sigma(i) = S(i,i)
enddo

end subroutine esprit


subroutine corrmtx(x,N,M,C)

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
 
 do i = 1,N-M-1 ! yes, -1
    yn(:,1) = x(M+i-1:i:-1) !yes, -1
    R = R + matmul(yn,(transpose(yn)))
 enddo

 C = R/real(N,sp)

end subroutine corrmtx

end module subspace
