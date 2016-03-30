! https://github.com/JuliaLang/julia/blob/master/test/perf/micro/perf.f90
module perf
    use comm,only : dp,i64, stderr
    implicit none
contains

    real(dp) function sysclock2ms(t)
    ! Convert a number of clock ticks, as returned by system_clock called
    ! with integer(i64) arguments, to milliseconds

        integer(i64), intent(in) :: t
        integer(i64) :: rate
        real(dp) ::  r
        call system_clock(count_rate=rate)
        r = 1000.d0 / rate
        sysclock2ms = t * r
    end function sysclock2ms


    subroutine assert(cond)
        logical, intent(in) :: cond

        if (.not. cond) then
            write(stderr,*) 'assertion failed, halting test'
            error stop
        end if

    end subroutine assert

End Module perf
