module subspace
    use, intrinsic:: iso_fortran_env, only: stderr=>error_unit
    use, intrinsic:: iso_c_binding, only: c_int,c_long
    use comm, only: sp,err
    use covariance,only: autocov
    !use perf, only : sysclock2ms
    Implicit none
!    private ! f2py won't import this Pi if this line exists, bug
    logical,parameter :: debug=.true.
    real(sp),parameter :: pi = 4.*atan(1.)
! do not put private here, because module parameters like pi won't be passed out
! for Numpy / f2py 1.10.4 (and other)  BUG in Numpy.
    public::esprit,pi

contains

subroutine esprit(x,N,L,M,fs,tout,sigma) bind(c)

    integer(c_int), intent(in) :: L,M,N
    real(sp),intent(in) :: x(N)
    real(sp),intent(in) :: fs
    real(sp),intent(out) :: tout(L/2),sigma(L)

    real(sp) :: tones(L)
    integer :: i,lwork
!    integer, parameter :: Lwork=4096
    integer,parameter :: LRATIO=8
    real(sp) :: R(M,M), U(M,M),VT(M,M), S1(M-1,L), S2(M-1,L)
    real(sp) :: S(M,M),RWORK(LRATIO*M),ang(L),SWORK(LRATIO*M) !this Swork is real
    integer(c_int) :: getrfinfo,getriinfo, evinfo, svdinfo
    real(sp) :: W1(L,L), IPIV(M-1)
    complex(sp) :: Phi(L,L), CWORK(LRATIO*M), junk(L,L), eig(L)

!    print*, shape(x)

   LWORK = LRATIO*M  !at least 5M for sgesvd
   ! integer(i64) :: tic,toc

!------ estimate autocovariance from single time sample vector (1-D)
!call system_clock(tic)
call autocov(x,size(x,kind=c_int),M,R)
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1) write(stdout,*) 'ms to compute autocovariance estimate:',sysclock2ms(toc-tic)

!-------- SVD -------------------
!call system_clock(tic)
!http://www.netlib.org/lapack/explore-html/d4/dca/group__real_g_esing.html
if (debug) print *,'LWORK: ',LWORK
call sgesvd('A','N',M,M,R,M,S,U,M,VT,M, SWORK, LWORK,svdinfo)
!if (debug) print *,'work(1):',swork(1)
if (svdinfo /= 0) then
    write(stderr,*) 'SGESVD return code',svdinfo,'  LWORK:',LWORK,'  M:',M
    if (M /= LWORK/LRATIO) call err('possible LWORK overflow')
endif
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute SVD:',sysclock2ms(toc-tic)

S1 = U(1:M-1, :L)
S2 = U(2:M, :L)

!call system_clock(tic)
W1=matmul((transpose(S1)),S1)

call sgetrf(L,L,W1,L,ipiv,getrfinfo) !LU decomp
if (getrfinfo /= 0) then
    write(stderr,*) 'SGETRF inverse output code',getrfinfo
    call err('GETRF')
endif

call sgetri(L,W1,L,ipiv,Rwork,Lwork,getriinfo) !LU inversion
if (getriinfo /= 0) then 
    write(stderr,*) 'SGETRI output code',getriinfo
    call err('GETRI')
endif

!call sgemm('N','T',L,L,max(L,N-1),1.0,W1,L,S1,L,1.0,Phi,L) 
!call sgemm('N','N',L,L,L,1.0,Phi,L,S2,L,1.,Phi,L)
Phi = matmul(matmul(W1, transpose(S1)), S2)

!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute Phi via LU inv():',sysclock2ms(toc-tic)

!call system_clock(tic)
call cgeev('N','N',L,Phi,L,eig,junk,L,junk,L,cwork,lwork,rwork,evinfo)
if (evinfo /= 0) then
    write(stderr,*) 'CGEEV output code',evinfo
    call err('GEEV')
endif
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute eigenvalues:',sysclock2ms(toc-tic)


ang = atan2(aimag(eig),real(eig))

tones = abs(fs*ang/(2*pi))

tout = tones(1:L:2)

!eigenvalues
do i = 1, L/2
  sigma(i) = S(i,i)
enddo

end subroutine esprit

end module subspace
