module comm

use, intrinsic :: iso_c_binding, only: sp=>C_FLOAT, dp=>C_DOUBLE, int64=>C_LONG_LONG, sizeof=>c_sizeof

implicit none (type, external)
private
public :: sp, dp, J, pi, debug

complex(dp),parameter :: J = (0._dp, 1._dp)
real(dp),parameter :: pi = 4._dp*atan(1._dp)
logical :: debug = .false.


end module comm
