#!/usr/bin/env python3
from time import time
import numpy as np
from pandas import DataFrame
#
from spectral_analysis.subspace import compute_autocovariance,esprit

try:
    import fortsubspace_cmpl as Sc
    assert Sc.comm.pi.dtype=='float64' #0d array
    np.testing.assert_allclose(Sc.comm.pi,np.pi)
except (ImportError,AssertionError) as e:
    print('problem importing Fortran Esprit complex {}'.format(e))
    Sc=None

try:
    import fortsubspace_real as Sr
    assert Sr.subspace.pi.dtype=='float32' #0d array
    np.testing.assert_allclose(Sr.subspace.pi,np.pi)
except ImportError as e:
    print('not able to import Fortran Esprit real {}'.format(e))
    Sr=None

def plot_noisehist():
    """
    not part of standard selftest
    """
    N = 10000

    from matplotlib.pyplot import figure,subplots,show
    fg,axs = subplots(3,1)

    noiser = Sr.signals.randn(N)
    noisec = Sc.signals.randn(N)
    noisepy = np.random.randn(N)

    ax = axs[0]
    ax.hist(noiser,bins=64)
    ax.set_title('real noise')

    ax = axs[1]
    ax.hist(noisec.real,bins=64)
    ax.set_title('complex noise')

    ax = axs[2]
    ax.hist(noisepy,bins=64)
    ax.set_title('python randn')
    show()


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
        Cc = Sc.subspace.corrmtx(x,M)
        tocfortcmpl = time()-tic

        tic = time()
        Cr = Sr.subspace.corrmtx(x.real,M)
        tocfortreal = time() - tic
    except Exception as e:
        print('problem loading Fortran module {}'.format(e))
        tocfortcmpl=tocfortreal=Cf=np.nan

    #print('autocovariance: python {:.6f} sec  fortran {:.6f} sec'.format(tocpy,tocfortcmpl))
    print('autocovariance: Fortran is {:.3f} times faster than Python \n'.format(tocpy/tocfortcmpl))

    np.testing.assert_allclose(C,Cc,rtol=1)
    np.testing.assert_allclose(C.real,Cr,rtol=1)

def test_esprit():
    """
    It appears that this PYTHON implementation of ESPRIT scales by O(N^3.25)
    0.0588 sec for N=480,fs=48e3,Ntone=1, M=N/2
    11.2199 sec for N=2400, .. .. . .

    FORTRAN results seem to scale by O(N^2.825)
    0.170 sec for N=480, fs=48e3, Ntone=1, M=N/2
    16.615 sec. for N=2400, ... .. .
    """
    f0 = 12345.6
    fs = 48e3
    snr=60.
    Ntarg = 2
    Ns = 1024
#%% create signal
    #t = np.arange(0,0.01,1/fs)
    #xc = np.exp(1j*2*np.pi*f0*t) + 0.01*(np.random.randn(t.size) + 1j*np.random.randn(t.size))

    xr = Sr.signals.signoise(fs,f0,snr,Ns)
    xc = Sc.signals.signoise(fs,f0,snr,Ns)

    # measure signal
    M = [100]

    py = DataFrame(index=M,columns=['err','sigma','time'])
    fortreal = DataFrame(index=M,columns=['err','sigma','time'])
    fortcmpl = DataFrame(index=M,columns=['err','sigma','time'])

    for m in M:
#%% python
        tic = time()
        fest,sigma = esprit(xc,Ntarg//2,M=m,fs=fs,verbose=False)
        toc = time()-tic
        py.loc[m,:] = [fest-f0,sigma,toc]
       # print('PYTHON time signal N= {} M={} freq error {} Hz, sigma {}, time {:.4f} sec'.format(x.size,m,fest-fb,sigma,toc))
#%% fortran
        if Sc is not None:
            tic = time()
            fest,sigma = Sc.subspace.esprit(xc, Ntarg, m, fs)
            np.testing.assert_allclose(fest[0],f0,rtol=0.1)
            fortcmpl.loc[m,:] = [fest-f0,sigma,time()-tic]

        if Sr is not None:
            fest,sigma = Sr.subspace.esprit(xr,Ntarg,m, fs)
            np.testing.assert_allclose(fest[0],f0,rtol=0.1)
            fortreal.loc[m,:] = [fest-f0,sigma,time()-tic]

        #print('FORTRAN time signal N= {} M={} freq error {} Hz, sigma {}, time {:.4f} sec'.format(x.size,m,fest-fb,sigma,toc))

    return py,fortcmpl,fortreal

if __name__ == '__main__':
    plot_noisehist()
    test_signoise()

#%%
    py,fortcmpl,fortreal=test_esprit()
    print('python complex: time {:.4f} sec.'.format(py['time'].values[0]))

    print('Fortran complex: time {:.4f} sec.'.format(fortcmpl['time'].values[0]))

    print('Fortran real: time {:.4f} sec.'.format(fortreal['time'].values[0]))

    print('ESPRIT: Fortran is {:.4f} times faster than Python'.format(py['time'].values[0] / fortcmpl['time'].values[0]))
#%%
    test_autocov()
