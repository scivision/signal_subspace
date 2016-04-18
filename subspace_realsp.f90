module subspace
    use comm,only: sp,c_int,stdout,stderr
    use covariance,only: autocov
    !use perf, only : sysclock2ms
    Implicit none

    real(sp),parameter :: pi = 4_sp*atan(1._sp)
    public::esprit,pi

contains

subroutine esprit(x,N,L,M,fs,tout,sigma)

    integer(c_int), intent(in) :: L,M,N
    real(sp),intent(in) :: x(N)
    real(sp),intent(in) :: fs
    real(sp),intent(out) :: tout(L/2),sigma(L)

    real(sp) :: tones(L)
    integer(c_int) :: LWORK,i
    real(sp) :: R(M,M),U(M,M),VT(M,M), S1(M-1,L), S2(M-1,L)
    real(sp) :: S(M,M),RWORK(8*M),ang(L),SWORK(8*M) !this Swork is real
    integer(c_int) :: getrfinfo,getriinfo, evinfo, svdinfo
    real(sp) :: W1(L,L), IPIV(M-1)
    complex(sp) :: Phi(L,L), CWORK(8*M), junk(L,L), eig(L)

   ! integer(i64) :: tic,toc

Lwork = 8*M !at least 5M for sgesvd
!------ estimate autocovariance from single time sample vector (1-D)
!call system_clock(tic)
call autocov(x,size(x),M,R)
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1) write(stdout,*) 'ms to compute autocovariance estimate:',sysclock2ms(toc-tic)

!-------- SVD -------------------
!call system_clock(tic)
!http://www.netlib.org/lapack/explore-html/d4/dca/group__real_g_esing.html
call sgesvd('A','N',M,M,R,M,S,U,M,VT,M,SWORK,LWORK,svdinfo)
if (svdinfo.ne.0) write(stderr,*) 'SGESVD return code',svdinfo
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute SVD:',sysclock2ms(toc-tic)

S1 = U(1:M-1,1:L)
S2 = U(2:M,1:L)

!call system_clock(tic)
W1=matmul((transpose(S1)),S1)
call sgetrf(L,L,W1,L,ipiv,getrfinfo) !LU decomp
call sgetri(L,W1,L,ipiv,Rwork,Lwork,getriinfo) !LU inversion
if (getrfinfo.ne.0) write(stderr,*) 'ZGETRF inverse output code',getrfinfo
if (getriinfo.ne.0) write(stderr,*) 'ZGETRI output code',getriinfo

Phi = matmul(matmul(W1, transpose(S1)), S2)
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute Phi via LU inv():',sysclock2ms(toc-tic)

!call system_clock(tic)
call cgeev('N','N',L,Phi,L,eig,junk,L,junk,L,cwork,lwork,rwork,evinfo)
if (evinfo.ne.0) write(stderr,*) 'CGEEV output code',evinfo
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute eigenvalues:',sysclock2ms(toc-tic)


ang = atan2(aimag(eig),real(eig))

tones = abs(fs*ang/(2*pi))

tout = tones(1:L:2)
!write(stdout,*) 'tones ',tones
!write(stdout,*) 'tout ',tout

!eigenvalues
do concurrent (i=1:L/2)
    sigma(i) = S(i,i)
enddo

end subroutine esprit

end module subspace
