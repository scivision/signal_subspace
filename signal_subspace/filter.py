#!/usr/bin/env python
import numpy as np
from scipy.signal import remez


def fircoef(L,fc,fs):
    """
    remez uses normalized frequency, where 0.5 is Nyquist frequency
    fc: corner frequency [Hz]

    """

    fcn = fc/(0.5*fs)

    return remez(L, [0, 0.6*fcn, fcn, 0.5], [0, 1])


def fircirc(b,x):
    p=0
    nx = x.size
    nb = b.size
    z = np.zeros(nb)
    y = np.empty(nx)

    for n in range(nx):
        if p>=nb:
            p=0
        z[p] = x[n]
        acc = 0.
        k = p
        for j in range(nb):
            acc += b[j]*z[k]
            k-=1
            if k<0:
                k=nb-1

        y[n] = acc
        p+=1

    return y
