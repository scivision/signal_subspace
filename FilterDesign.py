#!/usr/bin/env python
import numpy as np
from warnings import warn
from pathlib import Path
import scipy.signal as signal
from matplotlib.pyplot import subplots,show,figure
import seaborn as sns
sns.set_context('talk',font_scale=1.5)

def computefir(L,ofn):
    """
    http://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.remez.html
    """

    if not (L % 2):
        warn('For high pass filter, select odd number of taps!')

    b  = signal.remez(L, [0, 0.075, 0.125, 0.5], [0, 1])

    if ofn:
        ofn = Path(ofn).expanduser()
        print('writing {}'.format(ofn))
#TODO make binary
        with ofn.open('w') as h:
            h.write(f'{b.size}\n') # first line is number of coefficients
            b.tofile(h,sep=" ") # second line is space-delimited coefficents

    return b

def plotfilt(b,L,fs,ofn):
    if fs is None:
        fs=1. #normalized freq


    fg,axs = subplots(2,1,sharex=False)
    freq, response = signal.freqz(b)
    axs[0].plot(freq*fs/(2*np.pi),20*np.log10(abs(response)))
    axs[0].set_title('filter response  {} taps'.format(L))
    axs[0].set_ylim(top=1)
    axs[0].set_ylabel('|H| [db]')
    axs[0].set_xlabel('frequency [Hz]')

    t = np.arange(0, L/fs, 1/fs)
    axs[1].plot(t,b)
    axs[1].set_xlabel ('time [sec]')
    axs[1].set_title('impulse response')
    axs[1].set_ylabel('amplitude')
    axs[1].autoscale(True,tight=True)

    fg.tight_layout()

    if ofn:
        ofn = Path(ofn).expanduser()
        ofn = ofn.with_suffix('.png')
        print('writing',ofn)
        fg.savefig(str(ofn),dpi=100,bbox_inches='tight')

def butterplot(fs,fc):
    """
    https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.butter.html
    """
    b, a = signal.butter(4, 100, 'low', analog=True)
    w, h = signal.freqs(b, a)
    ax = figure().gca()
    ax.semilogx(fs*0.5/np.pi*w, 20*np.log10(abs(h)))
    ax.set_title('Butterworth filter frequency response')
    ax.set_xlabel('Frequency [Hz]')
    ax.set_ylabel('Amplitude [dB]')
    ax.grid(which='both', axis='both')
    ax.axvline(fc, color='green') # cutoff frequency
    ax.set_ylim(-50,0)

def chebyshevplot(fs):
    """
    https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.cheby1.html#scipy.signal.cheby1
    """
    b, a = signal.cheby1(4, 5, 100, 'high', analog=True)
    w, h = signal.freqs(b, a)

    ax = figure().gca()
    ax.semilogx(w, 20*np.log10(abs(h)))
    ax.set_title('Chebyshev Type I frequency response (rp=5)')
    ax.set_xlabel('Frequency [radians / second]')
    ax.set_ylabel('Amplitude [dB]')
    ax.grid(which='both', axis='both')
    ax.axvline(100, color='green') # cutoff frequency
    ax.axhline(-5, color='green') # rp

if __name__ == '__main__':
    from argparse import ArgumentParser
    p = ArgumentParser()
    p.add_argument('-o','--ofn',help='output coefficient file to write')
    p.add_argument('-L',help='number of coefficients for FIR filter',type=int,default=63)
    p.add_argument('--fs',help='optional sampling frequency for plots',type=float)
    p = p.parse_args()

    b=computefir(p.L,p.ofn)

    plotfilt(b,p.L,p.fs,p.ofn)

    show()

