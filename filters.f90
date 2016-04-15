module filters
    
    use comm, only: sp,c_int

    implicit none
    
    public:: fircircfilter

contains

pure subroutine fircircfilter(x,N,b,L,y)
! http://www.mathworks.com/help/fixedpoint/ug/convert-fir-filter-to-fixed-point-with-types-separate-from-code.html
    integer(c_int), intent(in) :: N,L
    real(sp),intent(in) :: x(N),b(L) 
    real(sp),intent(out) :: y(N)

    integer(c_int) :: k,p,i,j
    real(sp) :: z(L), acc
    
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
