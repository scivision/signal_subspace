#!/usr/bin/env python3
from time import time
import numpy as np
from pandas import DataFrame
#
from subspace import compute_autocovariance,esprit
try:
    import fortsubspace as S
except ImportError as e:
    print('not able to import Fortran Esprit code  {}'.format(e))
    S=None

def test_autocov():
    x = np.random.randn(4096).astype(np.complex128) # 2x extra speedup from casting correct type

    M=5
    tic = time()
    C= compute_autocovariance(x,M)
    tocpy = time()-tic
    #%%
    try:
        from fortsubspace import subspace
        tic = time()
        Cf = subspace.corrmtx(x,M)
        tocfort = time()-tic
    except ImportError as e:
        print('problem loading Fortran module {}'.format(e))
        tocfort=Cf=np.nan

    print('python {:.6f} sec  fortran {:.6f} sec'.format(tocpy,tocfort))
    print('Fortran is {:.3f} times faster than Python'.format(tocpy/tocfort))

    np.testing.assert_allclose(C,Cf)

def test_esprit():
    """
    It appears that this PYTHON implementation of ESPRIT scales by O(N^3.25)
    0.0588 sec for N=480,fs=48e3,Ntone=1, M=N/2
    11.2199 sec for N=2400, .. .. . .

    FORTRAN results seem to scale by O(N^2.825)
    0.170 sec for N=480, fs=48e3, Ntone=1, M=N/2
    16.615 sec. for N=2400, ... .. .
    """
    fb = 12345.6
    fs = 48e3
    Ntarg = 1
    # create signal
    t = np.arange(0,0.01,1/fs)
    x = np.exp(1j*2*np.pi*fb*t) + 0.01*(np.random.randn(t.size) + 1j*np.random.randn(t.size))
    # measure signal
    N=x.size
    M = [N//2]#range(2,N)

    py = DataFrame(index=M,columns=['err','sigma','time'])
    fort = DataFrame(index=M,columns=['err','sigma','time'])

    for m in M:
#%% python
        tic = time()
        fest,sigma = esprit(x,Ntarg,M=m,fs=fs,verbose=False)
        toc = time()-tic
        py.loc[m,:] = [fest-fb,sigma,toc]
       # print('PYTHON time signal N= {} M={} freq error {} Hz, sigma {}, time {:.4f} sec'.format(x.size,m,fest-fb,sigma,toc))
#%% fortran
        tic = time()
        fest,sigma = S.subspace.esprit(x,Ntarg,m,fs)
        toc = time()-tic
        fort.loc[m,:] = [fest-fb,sigma,toc]
        #print('FORTRAN time signal N= {} M={} freq error {} Hz, sigma {}, time {:.4f} sec'.format(x.size,m,fest-fb,sigma,toc))

    return py,fort

py,fort=test_esprit()
#test_autocov()
print(py)
print(fort)