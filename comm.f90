module comm
use, intrinsic :: iso_c_binding, only: sp=>C_FLOAT, dp=>C_DOUBLE, i64=>C_LONG_LONG
!use, intrinsic :: iso_fortran_env, only : sp=>real32, dp=>real64, i64=>int64
use, intrinsic :: iso_fortran_env, only : stdout=>output_unit, stderr=>error_unit
implicit none
    
    complex(dp),parameter :: J=(0._dp,1._dp)
    real(dp),parameter :: pi = 4_dp*atan(1._dp)

end module comm
