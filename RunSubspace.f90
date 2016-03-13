program test_subspace

use subspace
Implicit none

integer,parameter :: Ns = 128
integer :: i
complex(dp),parameter :: J=(0_dp,1_dp)
complex(dp) :: t,x(Ns)
integer,parameter :: M=Ns/2, Ntone=1
!complex(dp) :: C(M,M)
real(dp) :: tones(Ntone)
real(dp),parameter :: fs=48000_dp

do i=1,Ns
t = (i-1)/fs
x(i) = exp(J*2*pi*12345.5_dp*t)
enddo

!write(stdout,*) x

call esprit(x,size(x),Ntone,M,fs,tones)

write(stdout,*) tones

end program test_subspace
