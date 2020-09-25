from pathlib import Path
import logging
import numpy as np
import scipy.signal as signal
from matplotlib.pyplot import subplots, show

#
from .importfort import fort

S = fort()


def plot_noisehist():
    N = 10000

    fg, axs = subplots(3, 1)

    noiser = S["r"].signals.randn(N)
    noisec = S["c"].signals.randn(N)
    noisepy = np.random.randn(N)

    ax = axs[0]
    ax.hist(noiser, bins=64)
    ax.set_title("real noise")

    ax = axs[1]
    ax.hist(noisec.real, bins=64)
    ax.set_title("complex noise")

    ax = axs[2]
    ax.hist(noisepy, bins=64)
    ax.set_title("python randn")
    show()


def plotfilt(b: np.ndarray, fs: int, ofn: Path = None):
    if fs is None:
        fs = 1  # normalized freq

    L = b.size

    fg, axs = subplots(2, 1, sharex=False)
    freq, response = signal.freqz(b)
    response_dB = 20 * np.log10(abs(response))
    if response_dB.max() > 0:
        logging.error("filter may be unstable")

    axs[0].plot(freq * fs / (2 * np.pi), response_dB)
    axs[0].set_title(f"filter response  {L} taps")
    axs[0].set_ylim((-100, None))
    axs[0].set_ylabel("|H| [db]")
    axs[0].set_xlabel("frequency [Hz]")

    t = np.arange(0, L / fs, 1 / fs)
    axs[1].plot(t, b)
    axs[1].set_xlabel("time [sec]")
    axs[1].set_title("impulse response")
    axs[1].set_ylabel("amplitude")
    axs[1].autoscale(True, tight=True)

    fg.tight_layout()

    if ofn:
        ofn = Path(ofn).expanduser()
        ofn = ofn.with_suffix(".png")
        print("writing", ofn)
        fg.savefig(str(ofn), dpi=100, bbox_inches="tight")
