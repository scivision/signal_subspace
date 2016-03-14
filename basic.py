import numpy as np
import fortsubspace as S

fs=48e3; F=1000 #arbitrary
M = 10 #arbtirary, # of lags for autocovariance estimate
t = np.arange(0,0.01,1/fs)
x = np.exp(1j*2*np.pi*F*t) + 0.1*np.random.randn(t.size)
fest,sigma = S.subspace.esprit(x,1,M,fs)

print(fest)
print(sigma)