#!/usr/bin/env python
"""
Design FIR filter coefficients using Parks-McClellan or windowing algorithm
and plot filter transfer function.
Michael Hirsch, Ph.D.

example for PiRadar CW prototype,
writing filter coefficients for use by filters.f90:
./FilterDesign.py 9950 10050 100e3 -L 4096 -m firwin -o cwfir.asc

Refs:
http://www.iowahills.com/5FIRFiltersPage.html
"""
import numpy as np
from pathlib import Path
import scipy.signal as signal
from matplotlib.pyplot import show, figure
from argparse import ArgumentParser
from signal_subspace.plots import plotfilt

try:
    import seaborn as sns

    sns.set_context("talk")
except ImportError:
    pass


def computefir(fc, L: int, ofn, fs: int, method: str):
    """
    bandpass FIR design

    https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.firwin.html
    http://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.remez.html

    L: number of taps

    output:
    b: FIR filter coefficients
    """

    assert len(fc) == 2, "specify lower and upper bandpass filter corner frequencies in Hz."

    if method == "remez":
        b = signal.remez(numtaps=L, bands=[0, 0.9 * fc[0], fc[0], fc[1], 1.1 * fc[1], 0.5 * fs], desired=[0, 1, 0], Hz=fs)
    elif method == "firwin":
        b = signal.firwin(L, [fc[0], fc[1]], window="blackman", pass_zero=False, nyq=fs // 2)
    elif method == "firwin2":
        b = signal.firwin2(
            L,
            [0, fc[0], fc[1], fs // 2],
            [0, 1, 1, 0],
            window="blackman",
            nyq=fs // 2,
            # antisymmetric=True,
        )
    else:
        raise ValueError(f"unknown filter design method {method}")

    if ofn:
        ofn = Path(ofn).expanduser()
        print(f"writing {ofn}")
        # FIXME make binary
        with ofn.open("w") as h:
            h.write(f"{b.size}\n")  # first line is number of coefficients
            b.tofile(h, sep=" ")  # second line is space-delimited coefficents

    return b


def butterplot(fs, fc):
    """
    https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.butter.html
    """
    b, a = signal.butter(4, 100, "low", analog=True)
    w, h = signal.freqs(b, a)
    ax = figure().gca()
    ax.semilogx(fs * 0.5 / np.pi * w, 20 * np.log10(abs(h)))
    ax.set_title("Butterworth filter frequency response")
    ax.set_xlabel("Frequency [Hz]")
    ax.set_ylabel("Amplitude [dB]")
    ax.grid(which="both", axis="both")
    ax.axvline(fc, color="green")  # cutoff frequency
    ax.set_ylim(-50, 0)


def chebyshevplot(fs):
    """
    https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.cheby1.html#scipy.signal.cheby1
    """
    b, a = signal.cheby1(4, 5, 100, "high", analog=True)
    w, h = signal.freqs(b, a)

    ax = figure().gca()
    ax.semilogx(w, 20 * np.log10(abs(h)))
    ax.set_title("Chebyshev Type I frequency response (rp=5)")
    ax.set_xlabel("Frequency [radians / second]")
    ax.set_ylabel("Amplitude [dB]")
    ax.grid(which="both", axis="both")
    ax.axvline(100, color="green")  # cutoff frequency
    ax.axhline(-5, color="green")  # rp


def main():
    p = ArgumentParser()
    p.add_argument("fc", help="lower,upper bandpass filter corner frequences [Hz]", nargs=2, type=float)
    p.add_argument("fs", help="optional sampling frequency [Hz]", type=float)
    p.add_argument("-o", "--ofn", help="output coefficient file to write")
    p.add_argument("-L", help="number of coefficients for FIR filter", type=int, default=63)
    p.add_argument("-m", "--method", help="filter design method [remez,firwin,firwin2]", default="firwin")
    p.add_argument("-k", "--filttype", help="filter type: low, high, bandpass", default="low")
    p = p.parse_args()

    b = computefir(p.fc, p.L, p.ofn, p.fs, p.method)

    plotfilt(b, p.fs, p.ofn)

    show()


if __name__ == "__main__":
    main()
