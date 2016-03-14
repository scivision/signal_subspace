from numpy.linalg import inv
from numpy import asarray, zeros, fliplr,ndarray,any,linspace,exp,transpose,matrix,pi,arange,angle,roots,complex128
from scipy.linalg import toeplitz
from numpy import linalg as lg
from time import time
#

def corrmtx(x,m):
    """
    from https://github.com/cokelaer/spectrum/
    like matlab corrmtx(x,'mod'), with a different normalization factor.
    """
    x = asarray(x, dtype=float)
    assert x.ndim==1

    N = x.size

    Tp = toeplitz(x[m:N], x[m::-1])

    if x.dtype == complex:
        C = zeros((2*(N-m), m+1), dtype=complex)
    else:
        C = zeros((2*(N-m), m+1))

    for i in range(0, N-m):
        C[i] = Tp[i]

    Tp = fliplr(Tp.conj())
    for i in range(N-m, 2*(N-m)):
        C[i] = Tp[i-N+m]

    return C

def compute_covariance(X):
    r"""This function estimate the covariance of a zero-mean numpy matrix.
    The covariance is estimated as :math:`\textbf{R}=\frac{1}{N}\textbf{X}\textbf{X}^{H}`


        :param X: M*N ndarray
        :param type: string, optional
        :returns: covariance matrix of size M*M
        """
    assert isinstance(X,ndarray)

    #Number of columns
    N=X.shape[1]
    R=(1./N).dot(X).dot(X.conj().T)

    return R


def compute_autocovariance(x,M):

    r""" This function compute the auto-covariance matrix of a numpy signal. The auto-covariance is computed as follows

        .. math:: \textbf{R}=\frac{1}{N}\sum_{M-1}^{N-1}\textbf{x}_{m}\textbf{x}_{m}^{H}

        where :math:`\textbf{x}_{m}^{T}=[x[m],x[m-1],x[m-M+1]]`.

        :param x: 1-D vector of size N
        :param M:  int, optional. Size of signal block.
        :returns: NxN ndarray
        """

    # Create covariance matrix for psd estimation
    # length of the vector x
    x = asarray(x)
    assert x.ndim==1
    N=x.size

    #Create column vector from row array
    x_vect = x[None,:].T

    # init covariance matrix
    yn = x_vect[M-1::-1]
    #R  = yn @ yn.conj().T
    R = yn.dot(yn.conj().T)
    #about 5-8% of computation time
    for indice in range(1,N-M):
        #extract the column vector
        yn = x_vect[M-1+indice:indice-1:-1]
        #R  = R + yn @ yn.conj().T
        R = R + yn.dot(yn.conj().T)

    return R / N

def pseudospectrum_MUSIC(x,L,M=None,Fe=1,f=None):
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
    N=x.shape[0]

    if any(f) is None:
        f=linspace(0.,Fe//2,512)

    if M is None:
        M=N//2

    #extract noise subspace
    R=compute_autocovariance(x,M)
    U,S,V=lg.svd(R)
    G=U[:,L:]

    #compute MUSIC pseudo spectrum
    N_f=f.shape
    cost=zeros(N_f)

    tic=time()
    for indice,f_temp in enumerate(f):
        # construct a (note that there a minus sign since Yn are defined as [y(n), y(n-1),y(n-2),..].T)
        vect_exp=-2j*pi*f_temp*arange(0,M)/Fe
        a=exp(vect_exp)
        a=transpose(matrix(a))
        #Cost function
        cost[indice]=1./lg.norm((G.H)*a)

    print('pmusic: {:.6f} sec'.format(time()-tic))
    return f,cost

def rootmusic(x,L,M=None,fs=1):

    r""" This function estimate the frequency components based on the root-MUSIC algorithm [BAR83]_ .
    The root-Music algorithm find the roots of the following polynomial

        .. math:: P(z)=\textbf{a}^{H}(z)\textbf{G}\textbf{G}^{H}\textbf{a}(z)

        The frequencies are related to the roots as

        .. math:: z=e^{-2j\pi f/Fe}

        :param x: ndarray, vector or 2-D: Nensemble x Nsamples
        :param L: int. Number of components to be extracted.
        :param M:  int, optional. Size of signal block.
        :param Fe: float. Sampling Frequency.
        :returns: ndarray containing the L frequencies
    """
   # length of the vector x
    if x.ndim==1:
        N=x.size
    else:
        N=x.shape[0]

    if M is None:
        M=N//2

    #extract noise subspace
    R=compute_autocovariance(x,M)
    U,S,V=lg.svd(R)
    G=U[:,L:]

    #construct matrix P
    #P=G @ G.conj().T
    P = G.dot(G.conj().T)

    #construct polynomial Q
    Q = zeros(2*M-1,dtype=complex128)
    #Extract the sum in each diagonal  0.1% of computation time
    for (idx,val) in enumerate(range(M-1,-M,-1)):
        Q[idx] = P.diagonal(val).sum()


    #Compute the roots 92% of computation time here
    tic=time()
    rts=roots(Q)
    print(time()-tic)

    #Keep the roots with radii <1 and with non zero imaginary part
    rts = rts[abs(rts) < 1]
    rts = rts[rts.imag != 0]

    #Find the L roots closest to the unit circle
    distance_from_circle=abs(abs(rts)-1)
    index_sort = distance_from_circle.argsort()
    component_roots = rts[index_sort[:L]]

    #extract frequencies ((note that there a minus sign since Yn are defined as [y(n), y(n-1),y(n-2),..].T))
    ang = -angle(component_roots)

    #frequency normalisation
    f = fs*ang / (2.*pi)

    return f,S[:L]

def esprit(x,L,M=None,fs=1):

    r""" This function estimate the frequency components based on the ESPRIT algorithm [ROY89]_

        The frequencies are related to the roots as :math:`z=e^{-2j\pi f/Fe}`. See [STO97]_ section 4.7 for more information about the implementation.

        :param x: ndarray, Nensemble x Nsamples
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

    # length of the vector x
    x = asarray(x)
    assert x.ndim==1
    N=x.size

    if M==None:
        M=N//2

    #extract signal subspace  99.9 % of computation time
    R=compute_autocovariance(x,M) #75% of computation time
    #R = subspace.corrmtx(x.astype(complex128),M).astype(float) #f2py fortran
    U,S,V=lg.svd(R) #25% of computation time


    #Remove last row
    S1=U[:-1,:L]
    #Remove first row
    S2=U[1:,:L]

    #Compute matrix Phi (Stoica 4.7.12)  <0.1 % of computation time
    Phi=inv(S1.conj().T.dot(S1)).dot(S1.conj().T).dot(S2)

    #Perform eigenvalue decomposition <0.1 % of computation time
    V,U=lg.eig(Phi)

    #extract frequencies ((note that there a minus sign since Yn are defined as [y(n), y(n-1),y(n-2),..].T))
    ang = -angle(V)

    #frequency normalisation
    f = fs*ang/(2.*pi)

    return f,S[:L]
