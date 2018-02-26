module subspace
  use, intrinsic:: iso_fortran_env, stderr=>error_unit
  use, intrinsic:: iso_c_binding, only: c_int,c_long
  use comm,only: wp, pi, debug
  use covariance,only: autocov
  !use perf, only : sysclock2ms

  Implicit none

  private
  public::esprit

contains

subroutine esprit(x,N,L,M,fs,tout,sigma) bind(c)

    integer(c_int), intent(in) :: L,M,N
    real(wp),intent(in) :: x(N)
    real(wp),intent(in) :: fs
    real(wp),intent(out) :: tout(L/2),sigma(L)

    integer, parameter :: r32 = kind(0._real32)
    integer, parameter :: r64 = kind(0._real64)
!    integer, parameter :: r128 = kind(0._real128)

    real(wp) :: tones(L)
    integer :: LWORK,i
    integer,parameter :: LRATIO=8
    real(wp) :: R(M,M), U(M,M), VT(M,M), S1(M-1,L), S2(M-1,L)
    real(wp) :: S(M,M),RWORK(LRATIO*M),ang(L),SWORK(LRATIO*M) !this Swork is real
    integer :: stat
    real(wp) :: W1(L,L), IPIV(M-1)
    real(wp) :: Phi(L,L), junk(L,L), Reig(L), Ieig(L)

   LWORK = LRATIO*M  !at least 5M for gesvd
   ! integer(i64) :: tic,toc

!------ estimate autocovariance from single time sample vector (1-D)
!call system_clock(tic)
call autocov(x, R)
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1) write(stdout,*) 'ms to compute autocovariance estimate:',sysclock2ms(toc-tic)

!-------- SVD -------------------
!call system_clock(tic)
!http://www.netlib.org/lapack/explore-html/d4/dca/group__real_g_esing.html
if (debug) print *,'LWORK: ',LWORK
select case (kind(U))
  case (r32)  
    call sgesvd('A','N',M,M,R,M,S,U,M,VT,M,SWORK,LWORK,stat)
  case (r64)  
    call dgesvd('A','N',M,M,R,M,S,U,M,VT,M,SWORK,LWORK,stat)
  case default 
    error stop 'unknown type input to GESVD'
end select

!if (debug) print *,'work(1):',swork(1)
if (stat /= 0) then
    write(stderr,*) 'GESVD return code',stat,'  LWORK:',LWORK,'  M:',M
    if (M /= LWORK/LRATIO) write(stderr,*) 'possible LWORK overflow'
    error stop
endif
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute SVD:',sysclock2ms(toc-tic)

!-------- LU decomp
S1 = U(1:M-1, :L)
S2 = U(2:M, :L)

!call system_clock(tic)
W1=matmul((transpose(S1)),S1)
select case (kind(U))
  case (r32)
    call sgetrf(L,L,W1,L,ipiv,stat)
  case (r64)
    call dgetrf(L,L,W1,L,ipiv,stat)
  case default
    error stop 'unknown type input to GETRF'
end select

if (stat /= 0) then
  write(stderr,*) 'GETRF inverse output code',stat
  error stop
endif
!------------ LU inversion
select case (kind(U))
  case (r32)
    call sgetri(L,W1,L,ipiv,Rwork,Lwork,stat)
  case (r64)
    call dgetri(L,W1,L,ipiv,Rwork,Lwork,stat)
  case default
    error stop 'unknown type input to GETRI'
end select

if (stat /= 0) then
  write(stderr,*) 'GETRI output code',stat
  error stop
endif
!call system_clock(toc)

! matmul is faster 
!call sgemm('N','T',L,L,max(L,N-1),1.0,W1,L,S1,L,1.0,Phi,L) 
!call sgemm('N','N',L,L,L,1.0,Phi,L,S2,L,1.,Phi,L)

!-----------
!call system_clock(tic)
Phi = matmul(matmul(W1, transpose(S1)), S2)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute Phi via LU inv():',sysclock2ms(toc-tic)

select case (kind(U))
  case (r32)
    call sgeev('N','N',L,Phi,L,Reig,Ieig,junk,L,junk,L,rwork,lwork,stat)
  case (r64)
    call dgeev('N','N',L,Phi,L,Reig,Ieig,junk,L,junk,L,rwork,lwork,stat)
  case default
    error stop 'unknown type input to GEEV'
end select

if (stat /= 0) then
  write(stderr,*) 'GEEV output code',stat
  error stop
endif
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute eigenvalues:',sysclock2ms(toc-tic)

ang = atan2(Ieig, Reig)

tones = abs(fs*ang/(2*pi))

tout = tones(1:L:2)

!eigenvalues
do concurrent (i = 1:L/2)
  sigma(i) = S(i,i)
enddo

end subroutine esprit

end module subspace
