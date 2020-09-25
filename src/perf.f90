! https://github.com/JuliaLang/julia/blob/master/test/perf/micro/perf.f90
module perf

use, intrinsic:: iso_fortran_env, only: int64
use, intrinsic:: iso_c_binding, only: c_bool

use comm, only : dp

implicit none (type, external)
private
public :: sysclock2ms

contains

real(dp) function sysclock2ms(t)
!! Convert a number of clock ticks, as returned by system_clock called
!! with integer(i64) arguments, to milliseconds

integer(int64), intent(in) :: t
integer(int64) :: rate
real(dp) ::  r
call system_clock(count_rate=rate)
r = 1000._dp / rate
sysclock2ms = t * r
end function sysclock2ms


end Module perf
