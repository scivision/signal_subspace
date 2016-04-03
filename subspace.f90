module subspace
    use comm,only: dp,pi,stdout,stderr
    use covariance,only: autocov
    !use perf, only : sysclock2ms
    Implicit none

    private
    public::esprit

contains

subroutine esprit(x,N,L,M,fs,tones,sigma)

    integer, intent(in) :: L,M,N
    complex(dp),intent(in) :: x(N)
    real(dp),intent(in) :: fs
    real(dp),intent(out) :: tones(L),sigma(L)

    integer :: LWORK
    complex(dp) :: R(M,M),U(M,M),VT(M,M), S1(M-1,L), S2(M-1,L)
    real(dp) :: S(M,M),RWORK(8*M),ang(L)
    integer :: getrfinfo,getriinfo,evinfo, svdinfo,i
    complex(dp) :: W1(L,L), IPIV(M-1), SWORK(8*M) !yes, this swork is complex
    complex(dp) :: Phi(L,L), CWORK(8*M), junk(L,L), eig(L)

   ! integer(i64) :: tic,toc

Lwork = 8*M !at least 5M for sgesvd
!------ estimate autocovariance from single time sample vector (1-D)
!call system_clock(tic)
call autocov(x,size(x),M,R)
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
call zgetrf(L,L,W1,L,ipiv,getrfinfo) !LU decomp
call zgetri(L,W1,L,ipiv,Swork,Lwork,getriinfo) !LU inversion
if (getrfinfo.ne.0) write(stderr,*) 'ZGETRF inverse output code',getrfinfo
if (getriinfo.ne.0) write(stderr,*) 'ZGETRI output code',getriinfo

Phi = matmul(matmul(W1, conjg(transpose(S1))), S2)
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute Phi via LU inv():',sysclock2ms(toc-tic)

!call system_clock(tic)
call zgeev('N','N',L,Phi,L,eig,junk,L,junk,L,cwork,lwork,rwork,evinfo)
if (evinfo.ne.0) write(stderr,*) 'ZGEEVS output code',evinfo
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute eigenvalues:',sysclock2ms(toc-tic)


ang = atan2(aimag(eig),real(eig))

tones = abs(fs*ang/(2*pi))
!eigenvalues
do concurrent (i=1:L)
    sigma(i) = S(i,i)
enddo

end subroutine esprit

end module subspace
