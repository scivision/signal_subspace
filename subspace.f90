module subspace
    use, intrinsic:: iso_fortran_env, only: stderr=>error_unit
    use, intrinsic:: iso_c_binding, only: c_int
    use comm,only: dp,pi
    use covariance,only: autocov
    !use perf, only : sysclock2ms

    Implicit none

    private
    public::esprit

contains

subroutine esprit(x,N,L,M,fs,tones,sigma)

    integer(c_int), intent(in) :: L,M,N
    complex(dp),intent(in) :: x(N)
    real(dp),intent(in) :: fs
    real(dp),intent(out) :: tones(L),sigma(L)

    integer :: LWORK,i
    complex(dp) :: R(M,M),U(M,M),VT(M,M), S1(M-1,L), S2(M-1,L)
    real(dp) :: S(M,M),RWORK(8*M),ang(L)
    integer :: getrfinfo,getriinfo, evinfo, svdinfo
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
if (svdinfo /= 0) then
    write(stderr,*) 'ZGESVD return code',svdinfo
    error stop
endif
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute SVD:',sysclock2ms(toc-tic)

S1 = U(1:M-1, :L)
S2 = U(2:M, :L)

!call system_clock(tic)
W1=matmul(conjg(transpose(S1)),S1)
call zgetrf(L,L,W1,L,ipiv,getrfinfo) !LU decomp
if (getrfinfo /= 0) then
    write(stderr,*) 'ZGETRF inverse output code',getrfinfo
    error stop
endif
call zgetri(L,W1,L,ipiv,Swork,Lwork,getriinfo) !LU inversion
if (getriinfo /= 0) then
    write(stderr,*) 'ZGETRI output code',getriinfo
    error stop
endif

Phi = matmul(matmul(W1, conjg(transpose(S1))), S2)
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute Phi via LU inv():',sysclock2ms(toc-tic)

!call system_clock(tic)
call zgeev('N','N',L,Phi,L,eig,junk,L,junk,L,cwork,lwork,rwork,evinfo)
if (evinfo /= 0) then
    write(stderr,*) 'ZGEEVS output code',evinfo
    error stop
endif
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute eigenvalues:',sysclock2ms(toc-tic)


ang = atan2(aimag(eig),real(eig))

tones = abs(fs*ang/(2*pi))
!eigenvalues
do concurrent (i=1:L/2)
    sigma(i) = S(i,i)
enddo

end subroutine esprit

end module subspace
