#!/usr/bin/env python3
from time import time
import numpy as np
from dtclient.specest import compute_autocovariance,esprit

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
    x = np.arange(1,11)
    fb,sigma=esprit(x,4,fs=48e3)
    print(fb,sigma)

test_esprit()