import numpy as np
import fortsubspace as S

fs=48e3; F=12345.6 #arbitrary
Ntarg=2
M = 10 #arbitrary, # of lags for autocovariance estimate
t = np.arange(0,0.01,1/fs)
x = np.exp(1j*2*np.pi*F*t) + 0.1*np.random.randn(t.size)
fest,sigma = S.subspace.esprit(x,Ntarg,M,fs)

print(fest)
print(sigma)
