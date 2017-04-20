#!/usr/bin/env python
import subprocess
from pathlib import Path
from time import time
import numpy as np
from pandas import DataFrame
#
from signal_subspace import compute_autocovariance,esprit
from signal_subspace.importfort import fort
Sc,Sr = fort()

path=Path(__file__).parents[1]

def test_signoise():
    noiser = Sr.signals.randn(10)
    assert isinstance(noiser[0],np.float32)
    noisec = Sc.signals.randn(10)
    assert isinstance(noisec[0],np.complex128)

def test_autocov():
    x = np.random.randn(4096).astype(np.complex128) # 2x extra speedup from casting correct type

    M=5
    tic = time()
    C= compute_autocovariance(x,M)
    tocpy = time()-tic
    #%%
    try:
        tic = time()
        Cc = Sc.covariance.autocov(x,M)
        tocfortcmpl = time()-tic

        tic = time()
        Cr = Sr.covariance.autocov(x.real,M)
        tocfortreal = time() - tic
    except Exception as e:
        print(f'problem loading Fortran module {e}')
        tocfortcmpl=tocfortreal=Cc=Cr=np.nan

    #print(f'autocovariance: python {tocpy:.6f} sec  fortran {tocfortcmpl:.6f} sec')
    print(f'autocovariance: Fortran is {tocpy/tocfortcmpl:.3f} times faster than Python \n')

    np.testing.assert_allclose(C,Cc,rtol=1)
    np.testing.assert_allclose(C.real,Cr,rtol=1)

def test_esprit():
    """
    ESPRIT TEST PYTHON
    It appears that this PYTHON implementation of ESPRIT scales by O(N^3.25)
    0.0588 sec for N=480,fs=48e3,Ntone=1, M=N/2
    11.2199 sec for N=2400, .. .. . .

    FORTRAN results seem to scale by O(N^2.825)
    0.170 sec for N=480, fs=48e3, Ntone=1, M=N/2
    16.615 sec. for N=2400, ... .. .

    later found literature stating ESPRIT is O(M^3) (or was it N^3?)
    """
    f0 = 12345.6
    fs = 48e3
    snr = 60. # dB
    Ntone = 2
    Ns = 1024
#%% create signal
    #t = np.arange(0,0.01,1/fs)
    #xc = np.exp(1j*2*np.pi*f0*t) + 0.01*(np.random.randn(t.size) + 1j*np.random.randn(t.size))

    xr = Sr.signals.signoise(fs, f0, snr, Ns)
    xc = Sc.signals.signoise(fs, f0, snr, Ns)

    # measure signal
    M = [100] # iterating over block length

    py = DataFrame(index=M, columns=['err','sigma','time'])
    fortreal = DataFrame(index=M, columns=['err','sigma','time'])
    fortcmpl = DataFrame(index=M, columns=['err','sigma','time'])

    for m in M:
#%% python
        tic = time()
        fest,sigma = esprit(xc, Ntone//2, M=m, fs=fs, verbose=False)
        toc = time()-tic
        py.loc[m,:] = [fest-f0, sigma, toc]
        np.testing.assert_allclose(fest, f0, rtol=1e-6)
        assert sigma[0] > 100,f'sigma {sigma[0]} is small'
        print(f'PYTHON time signal N= {xc.size} M={m} freq {fest} Hz, sigma {sigma}, time {toc:.4f} sec')
#%% fortran
        if Sc is not None:
            tic = time()
            fest,sigma = Sc.subspace.esprit(xc, Ntone, m, fs)
            np.testing.assert_allclose(fest[0], f0, rtol=1e-6)
            assert sigma[0] > 100,f'sigma {sigma[0]} is small'
            fortcmpl.loc[m,:] = [fest-f0,sigma,time()-tic]

        if Sr is not None:
            fest,sigma = Sr.subspace.esprit(xr,Ntone,m, fs)
            np.testing.assert_allclose(fest[0], f0, rtol=1e-6)
            assert sigma[0] > 40,f'sigma {sigma[0]} is small'
            fortreal.loc[m,:] = [fest-f0,sigma,time()-tic]

        #print('FORTRAN time signal N= {} M={} freq error {} Hz, sigma {}, time {:.4f} sec'.format(x.size,m,fest-fb,sigma,toc))

    print(f'python complex: time {py["time"].values[0]:.4f} sec.')

    print(f'Fortran complex: time {fortcmpl["time"].values[0]:.4f} sec.')

    print(f'Fortran real: time {fortreal["time"].values[0]:.4f} sec.')

    print(f'fESPRIT: Fortran is {py["time"].values[0] / fortcmpl["time"].values[0]:.4f} times faster than Python')

def test_cxx():
    subprocess.check_call([path / 'bin/cppesprit'])

def test_c():
    subprocess.check_call([path / 'bin/cesprit'])

def test_fortranreal():
    subprocess.check_call([path / 'bin/fespritreal'])

def test_fortrancmpl():
    subprocess.check_call([path / 'bin/fespritcmpl'])

if __name__ == '__main__':
    #test_esprit()
    np.testing.run_module_suite()
