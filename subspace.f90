module subspace
  use, intrinsic:: iso_fortran_env, stderr=>error_unit
  use, intrinsic:: iso_c_binding, only: c_int
  use comm,only: wp,pi
  use covariance,only: autocov
  !use perf, only : sysclock2ms

  Implicit none

  private
  public::esprit

contains

subroutine esprit(x,N,L,M,fs,tones,sigma) bind(c)

    integer(c_int), intent(in) :: L,M,N
    complex(wp),intent(in) :: x(N)
    real(wp),intent(in) :: fs
    real(wp),intent(out) :: tones(L),sigma(L)
    
    integer, parameter :: c64 = kind((0._real32, 1._real32))
    integer, parameter :: c128 = kind((0._real64, 1._real64))
!    integer, parameter :: c256 = kind((0._real128, 1._real128))

    integer :: LWORK,i
    complex(wp) :: R(M,M), U(M,M), VT(M,M), S1(M-1,L), S2(M-1,L)
    real(wp) :: S(M,M), RWORK(8*M), ang(L)
    integer :: stat
    complex(wp) :: W1(L,L), IPIV(M-1), SWORK(8*M) !yes, this swork is complex
    complex(wp) :: Phi(L,L), CWORK(8*M), junk(L,L), eig(L)

   ! integer(i64) :: tic,toc

Lwork = 8*M !at least 5M for sgesvd
!------ estimate autocovariance from single time sample vector (1-D)
!call system_clock(tic)
call autocov(x, size(x,kind=c_int), M, R)
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1) write(stdout,*) 'ms to compute autocovariance estimate:',sysclock2ms(toc-tic)

!-------- SVD -------------------
!call system_clock(tic)
select case (kind(U))
  case (c64)  
    call cgesvd('A','N',M,M,R,M,S,U,M,VT,M,SWORK,LWORK,RWORK,stat)
  case (c128)  
    call zgesvd('A','N',M,M,R,M,S,U,M,VT,M,SWORK,LWORK,RWORK,stat)
  case default 
    error stop 'unknown type input to GESVD'
end select

if (stat /= 0) then
    write(stderr,*) 'GESVD return code',stat
    error stop
endif
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute SVD:',sysclock2ms(toc-tic)

!-------- LU decomp
S1 = U(1:M-1, :L)
S2 = U(2:M, :L)

!call system_clock(tic)
W1=matmul(conjg(transpose(S1)), S1)
select case (kind(U))
  case (c64) 
    call cgetrf(L,L,W1,L,ipiv,stat) 
  case (c128)
    call zgetrf(L,L,W1,L,ipiv,stat) 
  case default 
    error stop 'unknown type input to GETRF'
end select

if (stat /= 0) then
  write(stderr,*) 'GETRF inverse output code',stat
  error stop
endif
!------------ LU inversion
select case (kind(U))
  case (c64) 
    call cgetri(L,W1,L,ipiv,Swork,Lwork,stat) 
  case (c128)
    call zgetri(L,W1,L,ipiv,Swork,Lwork,stat) 
  case default 
    error stop 'unknown type input to GETRI'
end select

if (stat /= 0) then
  write(stderr,*) 'GETRI output code',stat
  error stop
endif
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute Phi via LU inv():',sysclock2ms(toc-tic)

!-----------
!call system_clock(tic)
Phi = matmul(matmul(W1, conjg(transpose(S1))), S2)

select case (kind(U))
  case (c64) 
    call cgeev('N','N',L,Phi,L,eig,junk,L,junk,L,cwork,lwork,rwork,stat)
  case (c128)
    call zgeev('N','N',L,Phi,L,eig,junk,L,junk,L,cwork,lwork,rwork,stat)
  case default 
    error stop 'unknown type input to GEEV'
end select

if (stat /= 0) then
  write(stderr,*) 'GEEV output code',stat
  error stop
endif
!call system_clock(toc)
!if (sysclock2ms(toc-tic).gt.1.) write(stdout,*) 'ms to compute eigenvalues:',sysclock2ms(toc-tic)


ang = atan2(aimag(eig), real(eig, kind=wp))

tones = abs(fs*ang/(2*pi))
!eigenvalues
do concurrent (i=1:L/2)
  sigma(i) = S(i,i)
enddo

end subroutine esprit

end module subspace
