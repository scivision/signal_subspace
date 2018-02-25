! https://github.com/JuliaLang/julia/blob/master/test/perf/micro/perf.f90
module perf
    use, intrinsic:: iso_fortran_env, only: int64, real64
    use, intrinsic:: iso_c_binding, only: c_bool
    
    implicit none
    private
    public:: sysclock2ms
contains

    real(real64) function sysclock2ms(t)
    ! Convert a number of clock ticks, as returned by system_clock called
    ! with integer(i64) arguments, to milliseconds

        integer(int64), intent(in) :: t
        integer(int64) :: rate
        real(real64) ::  r
        call system_clock(count_rate=rate)
        r = 1000._real64 / rate
        sysclock2ms = t * r
    end function sysclock2ms


!    subroutine assert(cond)
!        logical(c_bool), intent(in) :: cond
!        if (.not. cond) error stop 'assertion failed, halting test'
!    end subroutine assert

End Module perf
