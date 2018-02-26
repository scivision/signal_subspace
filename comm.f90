module comm
    use, intrinsic :: iso_c_binding, only: real32=>C_FLOAT, real64=>C_DOUBLE!, int64=>C_LONG_LONG
    implicit none
    private 
   
    include 'kind.txt'
    
    real(wp),parameter :: pi = 4._wp*atan(1._wp)
    
    logical :: debug

    public :: wp, init_random_seed, pi, debug

contains

subroutine init_random_seed()

    integer :: i, n, clock
    integer, allocatable :: seed(:)

    call random_seed(size=n)
    allocate(seed(n))
    call system_clock(count=clock)
    
    do concurrent (i=1:n)
        seed(i) = clock + 37 * (i-1)
    enddo

    call random_seed(put=seed)
end subroutine

end module comm
