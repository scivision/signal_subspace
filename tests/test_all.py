#!/usr/bin/env python
import pytest
from time import time
import numpy as np
from pandas import DataFrame
#
from signal_subspace import compute_autocovariance, esprit
import subspace


def test_autocov():
    # 2x extra speedup from casting correct type
    x = np.random.randn(4096).astype(np.complex128)

    M = 5
    tic = time()
    C = compute_autocovariance(x, M)
    tocpy = time()-tic
# %%
    tic = time()
    Cc = subspace.covariance.autocov_c(x, M)
    tocfortcmpl = time()-tic

    tic = time()
    Cr = subspace.covariance.autocov_r(x.real, M)
    tocfortreal = time() - tic

    print('autocovariance: Complex: Fortran faster than Python by factor:', tocpy/tocfortcmpl)
    print('autocovariance: Real: Fortran faster than Python by factor:', tocpy/tocfortreal)

    np.testing.assert_allclose(C, Cc, rtol=1)
    np.testing.assert_allclose(C.real, Cr, rtol=1)


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
    snr = 60.  # dB
    Ntone = 2
# %% create signal
    t = np.arange(0, 0.01, 1/fs)

    nvar = 10**(-snr/10.)

    xr = (np.exp(1j*2*np.pi*f0*t) + np.sqrt(nvar)*(np.random.randn(t.size))).real
    xc = np.exp(1j*2*np.pi*f0*t) + np.sqrt(nvar)*(np.random.randn(t.size) + 1j*np.random.randn(t.size))

    # measure signal
    M = [100]  # iterating over block length

    py = DataFrame(index=M, columns=['err', 'sigma', 'time'])
    fortreal = DataFrame(index=M, columns=['err', 'sigma', 'time'])
    fortcmpl = DataFrame(index=M, columns=['err', 'sigma', 'time'])

    for m in M:
        # %% python
        tic = time()
        fest, sigma = esprit(xc, Ntone//2, M=m, fs=fs, verbose=False)
        toc = time()-tic
        py.loc[m, :] = [fest-f0, sigma, toc]
        np.testing.assert_allclose(fest, f0, rtol=1e-6)
        assert sigma[0] > 50, 'too small sigma {}'.format(sigma[0])
        #  print(f'PYTHON time signal N= {xc.size} M={m} freq {fest} Hz, sigma {sigma}, time {toc:.4f} sec')
# %% fortran

        tic = time()
        fest, sigma = subspace.subspace.esprit_c(xc, Ntone, m, fs)
        np.testing.assert_allclose(fest[0], f0, rtol=1e-6)
        assert sigma[0] > 50, 'too small sigma {}'.format(sigma[0])
        fortcmpl.loc[m, :] = [fest-f0, sigma, time()-tic]

        fest, sigma = subspace.subspace.esprit_r(xr, Ntone, m, fs)
        np.testing.assert_allclose(fest[0], f0, rtol=1e-6)
        assert sigma[0] > 20, 'too small sigma {}'.format(sigma[0])
        fortreal.loc[m, :] = [fest-f0, sigma, time()-tic]

        # print('FORTRAN time signal N= {} M={} freq {} Hz, sigma {}, time {:.4f} sec'.format(x.size,m,fest,sigma,toc))

    print('python complex: sec.', py["time"].values[0])

    print('Fortran complex: sec.', fortcmpl["time"].values[0])

    print('Fortran real: sec.', fortreal["time"].values[0])

    print('fESPRIT: Fortran faster than Python by factor:', py["time"].values[0] / fortcmpl["time"].values[0])


if __name__ == '__main__':
    pytest.main()
