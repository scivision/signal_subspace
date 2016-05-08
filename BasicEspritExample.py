#!/usr/bin/env python3
import numpy as np
from scipy.signal import periodogram,remez,freqz,lfilter
from time import time
from matplotlib.pyplot import subplots,show
#
from spectral_analysis.importfort import fort
from spectral_analysis.filter import fircirc
Sc,Sr = fort()

fs=48e3; F=12345.6 #arbitrary
Ntone=2
M = 10 #arbitrary, # of lags for autocovariance estimate
L=64

def main():
    t = np.arange(0,0.01,1/fs)
    #%% noisy sinusoid
    xc = np.exp(1j*2*np.pi*F*t) + 0.01*(np.random.randn(t.size) + 1j*np.random.randn(t.size))
    xr = np.cos(2*np.pi*F*t) + 0.01*np.random.randn(t.size)
    #%% estimate sinusoid frequency

    if Sc is not None:
        festc,sigmac = Sc.subspace.esprit(xc,Ntone//2,M,fs)

        print('complex')
        print(festc)
        print(sigmac)
    #%% real
    # design filter coeff (offline, one-time)

    if Sr is not None:
        b  = remez(L, [0, 0.1, 0.15, 0.35, 0.4, 0.5], [0, 1, 0])

        tic=time()
        yrpy = lfilter(b,1,xr)
        tscipy = time()-tic

        tic = time()
        yrfort = Sr.filters.fircircfilter(xr.astype(np.float32),b)[0]
        tfort = time()-tic
        np.testing.assert_allclose(yrfort,yrpy,rtol=1e-4) #single prec vs double prec

        tic= time()
        yr = fircirc(b,xr)
        print('{:.6f} sec. using circular buffer FIR filter'.format(time()-tic))
        np.testing.assert_allclose(yr,yrpy)
#%% estimations
        festr,sigmar = Sr.subspace.esprit(yr,Ntone,M,fs)
        print('real')
        print(festr)
        print(sigmar)

        fg,axs = subplots(2,4,sharey=False)

        plotperiodogram(t,xr,fs,axs[:,0],'noisy input signal X')
        axs[0,0].set_ylabel('amplitude [dB]')
        axs[1,0].set_ylabel('amplitude')

        plotperiodogram(t,yrpy,fs,axs[:,1],'Scipy lfilter() signal, {:.3f} ms'.format(tscipy*1000))

        plotperiodogram(t,yrfort,fs,axs[:,2],'Fortran filtered signal,  {:.3f} ms'.format(tfort*1000))

        for a in axs[0,:]:
            a.set_xlabel('frequency [Hz]')
            a.autoscale(True,axis='x',tight=True)
            a.set_ylim(-100,-20)

        freq, response = freqz(b)
        axs[0,-1].plot(freq*fs/(2*np.pi),10*np.log10(abs(response)))
        axs[0,-1].set_title('filter response  L={}'.format(L))
        axs[0,-1].set_ylim(-40,2)

        impulse = np.repeat(0.,L); impulse[0] =1.
        response = lfilter(b,1,impulse)
        axs[1,-1].plot(response)
        axs[1,-1].set_xlabel ('sample number')

        show()

def plotperiodogram(t,x,fs,ax,ttxt):
    fax,Pxx = periodogram(x,fs,'hanning')
    ax[0].plot(fax,10*np.log10(abs(Pxx)))
    ax[0].set_title(ttxt)

    ax[1].plot(t,x)
    ax[1].set_ylim(-1,1)
    ax[1].set_xlabel('time [sec.]')

if __name__ == "__main__":
    main()
