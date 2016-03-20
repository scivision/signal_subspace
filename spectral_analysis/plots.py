

def plot_noisehist():
    N = 10000

    from matplotlib.pyplot import subplots,show
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