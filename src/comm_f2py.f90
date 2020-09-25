module comm

use, intrinsic :: iso_c_binding, only: sp=>C_FLOAT, dp=>C_DOUBLE, int64=>C_LONG_LONG, sizeof=>c_sizeof

implicit none (type, external)
private
public :: rand_init, sp, dp, J, pi, debug

complex(dp),parameter :: J = (0._dp, 1._dp)
real(dp),parameter :: pi = 4._dp*atan(1._dp)
logical :: debug = .false.

contains

subroutine rand_init(repeatable, image_distinct)
logical, intent(in) :: repeatable, image_distinct

call random_init(repeatable, image_distinct)

end subroutine rand_init


end module comm
