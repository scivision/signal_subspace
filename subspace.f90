module subspace
    use comm,only: dp,pi,stdout,stderr
    !use perf, only : init_random_seed,sysclock2ms
    Implicit none

    private
    public::esprit,corrmtx

contains

subroutine esprit(x,N,L,M,fs,tones,sigma)

    integer, intent(in) :: L,M,N
    complex(dp),intent(in) :: x(N)
    real(dp),intent(in) :: fs
    real(dp),intent(out) :: tones(L),sigma(L)

    integer :: LWORK
    complex(dp) :: R(M,M),U(M,M),VT(M,M), S1(M-1,L), S2(M-1,L)
    real(dp) :: S(M,M),RWORK(8*M),ang(L)
    integer :: luinfo=0
    integer :: svdinfo,i
    complex(dp) :: W1(L,L), IPIV(M-1), SWORK(8*M) !yes, this swork~complex
    complex(dp) :: Phi(L,L), CWORK(8*M), junk(L,L), eig(L)

   ! integer(i64) :: tic,toc

Lwork = 8*M !at least 5M for sgesvd
!------ estimate autocovariance from single time sample vector (1-D)
!call system_clock(tic)
call corrmtx(x,size(x),M,R)
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1) write(stdout,*) 'ms to compute autocovariance estimate:',sysclock2ms(toc-tic)

!-------- SVD -------------------
!call system_clock(tic)
call zgesvd('A','N',M,M,R,M,S,U,M,VT,M,SWORK,LWORK,RWORK,svdinfo)
if (svdinfo.ne.0) write(stderr,*) 'ZGESVD return code',svdinfo
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute SVD:',sysclock2ms(toc-tic)

S1 = U(1:M-1,1:L)
S2 = U(2:M,1:L)

!call system_clock(tic)
W1=matmul(conjg(transpose(S1)),S1)
call zgetrf(L,L,W1,L,ipiv,luinfo) !LU decomp
call zgetri(L,W1,L,ipiv,Swork,Lwork,luinfo) !LU inversion, yes Swork~complex
if (luinfo.ne.0) write(stderr,*) 'LU inverse output code',luinfo

Phi = matmul(matmul(W1, conjg(transpose(S1))), S2)
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute Phi via LU inv():',sysclock2ms(toc-tic)

!call system_clock(tic)
call zgeev('N','N',L,Phi,L,eig,junk,L,junk,L,cwork,lwork,rwork,luinfo)
if (luinfo.ne.0) write(stderr,*) 'eig output code',luinfo
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute eigenvalues:',sysclock2ms(toc-tic)


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
 complex(dp) :: yn(M,1), R(M,M)!, work(M,M)

 yn(:,1) = x(M:1:-1)

 R = matmul(yn,conjg(transpose(yn)))
 !call zgemm('N','C',M,M,1,1._dp,yn,M,yn,M,0._dp,R,M) !slower, worse accuracy than matmul in Gfortran 5.2.1

 do i = 1,N-M-1 ! yes, -1
    yn(:,1) = x(M+i-1:i:-1) !yes, -1
    R = R + matmul(yn,conjg(transpose(yn)))
    !call zgemm('N','C',M,M,1,1._dp,yn,M,yn,M,0._dp,work,M)
    !R = R + work
 enddo

 C = R/real(N,dp)

end subroutine corrmtx

end module subspace
