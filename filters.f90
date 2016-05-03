module filters
    
    use comm, only: sp,c_int, stderr,stdout

    implicit none

    real(sp),parameter :: nan = transfer(Z'7FF80000',1.0)
    private
    public:: fircircfilter

contains

subroutine fircircfilter(x,N,b,L,y)
! http://www.mathworks.com/help/fixedpoint/ug/convert-fir-filter-to-fixed-point-with-types-separate-from-code.html
    integer(c_int), intent(in) :: N,L
    real(sp),intent(in) :: x(N),b(L) 
    real(sp),intent(out) :: y(N)

    integer(c_int) :: k,p,i,j
    real(sp) :: z(L), acc
    logical,parameter :: verbose=.false.


    if (N.lt.1) then
        write(stderr,*) "E: expected input array length>0, you passed in len(x)=",N
        y(1) = nan
        return
    elseif (verbose) then
        write(stdout,*) "input signal len(x)=",N
    endif

    if (L.lt.1) then
        write(stderr,*) "E: expected more than zero filter coefficients, len(B)=",L
        y(1) = nan
        return
    elseif (verbose) then
        write(stdout,*) "filter coefficients len(B)=",L
    endif
    
    p = 0
    z = 0. !fill array with zeros

    do i = 1,N
        p = p+1
        if (p.gt.L)  p = 1
        z(p) = x(i)
        acc = 0.
        k = p
        do j = 1,L
            acc = acc + b(j)*z(k)
            k = k-1
            if (k.lt.1)  k = L
        enddo !j
        y(i) = acc
    enddo !i


end subroutine fircircfilter

end module filters
