module filters
use, intrinsic:: iso_fortran_env, only: stderr=>error_unit
use, intrinsic:: iso_c_binding, only: c_int, c_bool
use, intrinsic:: ieee_arithmetic, only: ieee_value, ieee_quiet_nan
use comm, only: sp

implicit none (type, external)
private
public:: fircircfilter

contains

subroutine fircircfilter(x,N,b,L, y,filtok) bind(c)
! http://www.mathworks.com/help/fixedpoint/ug/convert-fir-filter-to-fixed-point-with-types-separate-from-code.html
integer(c_int), intent(in) :: N,L
real(sp),intent(in) :: x(N), b(L)
real(sp),intent(out) :: y(N)
logical(c_bool),intent(out) :: filtok

integer :: k,p, i,j
real(sp) :: z(L), acc, nan
logical,parameter :: verbose=.false.

nan = ieee_value(1._sp, ieee_quiet_nan)

filtok=.false.

if (N < 1) then
  write(stderr,*) "E: expected input array length>0, you passed in len(x)=",N
  y(1) = nan
  return
elseif (verbose) then
  print *, "input signal len(x)=",size(x)," output signal len(y)=",size(y)
endif

if (L < 1) then
  write(stderr,*) "E: expected more than zero filter coefficients, len(B)=",L
  y(1) = nan
  return
elseif (verbose) then
  print *, "filter coefficients len(B)=",L
endif

!    if (any(ieee_is_nan(b))) then
!        write(stderr,*) 'E: NaN filter coefficients'
!        y(1) = nan
!        return
!    endif

p = 0
z(:) = 0

do i = 1,N
  p = p + 1
  if (p > L)  p = 1
  z(p) = x(i)
  acc = 0
  k = p
  do j = 1,L
    acc = acc + b(j)*z(k)
    k = k - 1
    if (k < 1)  k = L
  enddo !j
  y(i) = acc
enddo !i

filtok = .true.

end subroutine fircircfilter

end module filters
