module comm
    use, intrinsic :: iso_c_binding, only: sp=>C_FLOAT, dp=>C_DOUBLE, int64=>C_LONG_LONG, sizeof=>c_sizeof
    use, intrinsic :: iso_fortran_env, only: stderr=>error_unit
    implicit none
    
    complex(dp),parameter :: J=(0._dp, 1._dp)
    real(dp),parameter :: pi = 4._dp*atan(1._dp)

contains

subroutine random_init()
    integer :: i, n, clock
    integer, allocatable :: seed(:)

    call random_seed(size=n)
    allocate(seed(n))
    call system_clock(count=clock)
    seed = clock + 37 * [ (i - 1, i = 1, n) ]
    call random_seed(put=seed)
end subroutine

subroutine err(msg)
  character(*), intent(in) :: msg
  write(stderr,*) msg
  stop -1
end subroutine err

end module comm
