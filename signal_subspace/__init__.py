import numpy as np
from scipy.linalg import toeplitz
from numpy import linalg as lg
from time import time
#


def corrmtx(x, m):
    """
    from https://github.com/cokelaer/spectrum/
    like matlab corrmtx(x,'mod'), with a different normalization factor.
    """
    x = np.asarray(x, dtype=float)
    assert x.ndim == 1, '1-D only'

    N = x.size

    Tp = toeplitz(x[m:N], x[m::-1])

    C = np.zeros((2*(N-m), m+1), dtype=x.dtype)

    for i in range(0, N-m):
        C[i] = Tp[i]

    Tp = np.fliplr(Tp.conj())
    for i in range(N-m, 2*(N-m)):
        C[i] = Tp[i-N+m]

    return C


def compute_autocovariance(x, M):
    r""" This function compute the auto-covariance matrix of a numpy signal. The auto-covariance is computed as follows

        .. math:: \textbf{R}=\frac{1}{N}\sum_{M-1}^{N-1}\textbf{x}_{m}\textbf{x}_{m}^{H}

        where :math:`\textbf{x}_{m}^{T}=[x[m],x[m-1],x[m-M+1]]`.

        :param x: 1-D vector of size N
        :param M:  int, optional. Size of signal block.
        :returns: NxN ndarray
        """

    # Create covariance matrix for psd estimation
    # length of the vector x
    x = np.asarray(x).squeeze()
    assert x.ndim == 1, '1-D only'
    N = x.size

    # Create column vector (Nx1) from row array
    x_vect = x[None, :].T

    # init covariance matrix
    yn = x_vect[M-1::-1]  # reverse order from M-1 to 0

    R = yn @ yn.conj().T  # zeroth lag
    # about 5-8% of computation time
    for i in range(1, N-M):  # no zero because we just computed it
        # extract the column vector
        yn = x_vect[M-1+i:i-1:-1]

        R = R + yn @ yn.conj().T

    return R / N


def pseudospectrum_MUSIC(x, L, M=None, Fe=1, f=None):
    r""" This function compute the MUSIC pseudospectrum. The pseudo spectrum is defined as

        .. math:: S(f)=\frac{1}{\|\textbf{G}^{H}\textbf{a}(f) \|}

        where :math:`\textbf{G}` corresponds to the noise subspace and :math:`\textbf{a}(f)` is the steering vector.
        The peak locations give the frequencies of the signal.

        :param x: ndarray of size N
        :param L: int. Number of components to be extracted.
        :param M:  int, optional. Size of signal block.
        :param Fe: float. Sampling Frequency.
        :param f: nd array. Frequency locations f where the pseudo spectrum is evaluated.
        :returns: ndarray
        """

    # length of the vector x
    assert x.ndim == 1, '1-D only'
    N = x.size

    if any(f) is None:
        f = np.linspace(0., Fe//2, 512)

    if M is None:
        M = N // 2

    # extract noise subspace
    R = compute_autocovariance(x, M)
    U, S, V = lg.svd(R)
    G = U[:, L:]

    # compute MUSIC pseudo spectrum
    N_f = f.shape
    cost = np.zeros(N_f)

    tic = time()
    for indice, f_temp in enumerate(f):
        # construct a (note that there a minus sign since Yn are defined as [y(n), y(n-1),y(n-2),..].T)
        vect_exp = -2j*np.pi*f_temp*np.arange(M)/Fe
        a = np.exp(vect_exp)
        # Cost function
        cost[indice] = 1. / lg.norm(G.conj().T @ a.T)

    print('pmusic: sec. to compute:', time()-tic)
    return f, cost


def rootmusic(x, L, M=None, fs=1):
    r""" This function estimate the frequency components based on the root-MUSIC algorithm [BAR83]_ .
    The root-Music algorithm find the roots of the following polynomial

        .. math:: P(z)=\textbf{a}^{H}(z)\textbf{G}\textbf{G}^{H}\textbf{a}(z)

        The frequencies are related to the roots as

        .. math:: z=e^{-2j\pi f/Fe}

        :param x: ndarray, vector: Nsamples
        :param L: int. Number of components to be extracted.
        :param M:  int, optional. Size of signal block.
        :param fs:  Sampling Frequency. [Hz]
        :returns: ndarray containing the L frequencies
    """
   # length of the vector x
    assert x.ndim == 1, '1-D only'
    N = x.size

    if M is None:
        M = N // 2

    # extract noise subspace
    R = compute_autocovariance(x, M)
    U, S, V = lg.svd(R)
    G = U[:, L:]

    # construct matrix P
    P = G @ G.conj().T

    # construct polynomial Q
    Q = np.zeros(2*M-1, dtype='complex128')
    # Extract the sum in each diagonal  0.1% of computation time
    for (idx, val) in enumerate(range(M-1, -M, -1)):
        Q[idx] = P.diagonal(val).sum()

    # Compute the roots 92% of computation time here
    tic = time()
    rts = np.roots(Q)
    print(time()-tic)

    # Keep the roots with radii <1 and with non zero imaginary part
    rts = rts[abs(rts) < 1]
    rts = rts[rts.imag != 0]

    # Find the L roots closest to the unit circle
    distance_from_circle = abs(abs(rts)-1)
    index_sort = distance_from_circle.argsort()
    component_roots = rts[index_sort[:L]]

    # extract frequencies ((note that there a minus sign since Yn are defined as [y(n), y(n-1),y(n-2),..].T))
    ang = -np.angle(component_roots)

    # frequency normalisation
    f = fs*ang / (2.*np.pi)

    return f, S[:L]


def esprit(x, L, M=None, fs=1, verbose=False):
    r""" This function estimate the frequency components based on the ESPRIT algorithm [ROY89]_

        The frequencies are related to the roots as :math:`z=e^{-2j\pi f/Fe}`. See [STO97]_ section 4.7 for more information about the implementation.

        :param x: ndarray, Nsamples
        :param L: int. Number of components to be extracted.
        :param M:  int, optional. Size of signal block.
        :param Fs: float. Sampling Frequency.
        :returns: ndarray ndarray containing the L frequencies

        >>> import numpy as np
        >>> import spectral_analysis.spectral_analysis as sa
        >>> Fe=500
        >>> t=1.*np.arange(100)/Fe
        >>> x=np.exp(2j*np.pi*55.2*t)
        >>> f=sa.Esprit(x,1,None,Fe)
        >>> print(f)
        """

    x = np.asarray(x).squeeze()
    assert x.ndim in (1, 2)
    # length of the vector x
    if x.ndim == 1:
        N = x.size
    else:
        N = x.shape[1]

    if M is None:
        M = N // 2
# %% extract signal subspace  99.9 % of computation time
    tic = time()
    if x.ndim == 1:
        R = compute_autocovariance(x, M)  # 75% of computation time
    else:
        # the random phase of transmit/receive/target actually helps--need at least 5-6 observations to make useful
        R = np.cov(x, rowvar=False)
    if verbose:
        print('autocov sec.', time()-tic)
    # R = subspace.corrmtx(x.astype(complex128),M).astype(float) #f2py fortran

    tic = time()
    U, S, V = lg.svd(R)  # 25% of computation time
    if verbose:
        print('svd sec.', time()-tic)
# %% take eigenvalues and determine sinusoid frequencies
    # Remove last row
    S1 = U[:-1, :L]
    # Remove first row
    S2 = U[1:, :L]

    # Compute matrix Phi (Stoica 4.7.12)  <0.1 % of computation time
    Phi = lg.inv(S1.conj().T @ S1) @ S1.conj().T @ S2

    # Perform eigenvalue decomposition <0.1 % of computation time
    V, U = lg.eig(Phi)

    # extract frequencies ((note that there a minus sign since Yn are defined as [y(n), y(n-1),y(n-2),..].T))
    ang = -np.angle(V)

    # frequency normalisation
    f = fs*ang / (2.*np.pi)

    return f, S[:L]
