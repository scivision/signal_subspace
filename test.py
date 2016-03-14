#!/usr/bin/env python3
from time import time
import numpy as np
from subspace import compute_autocovariance,esprit

def test_autocov():
    x = np.random.randn(4096).astype(np.complex128) # 2x extra speedup from casting correct type

    M=5
    tic = time()
    C= compute_autocovariance(x,M)
    tocpy = time()-tic
    #%%
    from .subspace import subspace
    tic = time()
    Cf = subspace.corrmtx(x,M)
    tocfort = time()-tic

    print('python {:.6f} sec  fortran {:.6f} sec'.format(tocpy,tocfort))
    print('Fortran is {:.3f} times faster than Python'.format(tocpy/tocfort))

    np.testing.assert_allclose(C,Cf)

def test_esprit():
    tic = time()
    t = np.arange(0,0.01,1/48e3)
    x = np.exp(1j*2*np.pi*12345.5*t)
    fb,sigma=esprit(x,1,fs=48e3)
    print(fb,sigma,time()-tic)

test_esprit()