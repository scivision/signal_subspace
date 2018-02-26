module filters
  use, intrinsic:: iso_fortran_env, only: stderr=>error_unit
  use, intrinsic:: iso_c_binding, only: c_int
  use, intrinsic:: ieee_arithmetic
  use comm, only: wp, debug

  implicit none
  private

  real(wp) :: nan  

  public:: fircircfilter

contains


subroutine Cfircircfilter(x,N,b,L,y) bind(C)

  integer(c_int), intent(in) :: N,L
  real(wp), intent(in) :: x(N), b(L)
  real(wp), intent(out) :: y(N)
  
  call fircircfilter(x,b,y)

end subroutine Cfircircfilter


subroutine fircircfilter(x,b,y)
! http://www.mathworks.com/help/fixedpoint/ug/convert-fir-filter-to-fixed-point-with-types-separate-from-code.html

real(wp),intent(in) :: x(:), b(:) 
real(wp),intent(out) :: y(:)

integer :: k,p, i,j, L,N
real(wp) :: acc, z(size(b))

L = size(b)
N = size(x)

!---- sanity check
nan = ieee_value(1._wp, ieee_quiet_nan) 


if (N < 1) then
  write(stderr,*) "E: expected input vector length>0.  shape(x)=",shape(x)
  y = nan
  return
elseif (debug) then
  print *, "input shape(x)=",shape(x)," output shape(y)=",shape(y)
endif

if (L < 1) then
  write(stderr,*) "E: expected more than zero filter coefficients, len(B)=",L
  y = nan
  return
elseif (debug) then
  print *, "filter coefficients len(B)=",L
endif

if (any(ieee_is_nan(b))) then
  write(stderr,*) 'E: NaN filter coefficients'
  y = nan
  return
endif

! ---- filter
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


end subroutine fircircfilter

end module filters
