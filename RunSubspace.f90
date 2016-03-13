program test_subspace

 use subspace
 Implicit none


 complex(dp),parameter :: x(10)=[1,2,3,4,5,6,7,8,9,10]
 integer,parameter :: M=10/2, N=4
 !complex(dp) :: C(M,M)
 real(dp) :: tones(N)
 real(dp),parameter :: fs=48000_dp

 !call corrmtx(x,size(x),M,C)
 call esprit(x,size(x),N,M,fs,tones)

    write(stdout,*) tones

end program test_subspace
