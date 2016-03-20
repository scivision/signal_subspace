from numpy.testing import assert_allclose
from numpy import pi

def fort():
    try:
        import fortsubspace_cmpl as Sc
        assert Sc.comm.pi.dtype=='float64' #0d array
        assert Sc.comm.j.dtype=='complex128'
        assert_allclose(Sc.comm.pi, pi)
    except (ImportError,AssertionError) as e:
        print('problem importing Fortran Esprit complex {}'.format(e))
        Sc=None

    try:
        import fortsubspace_real as Sr
        assert Sr.subspace.pi.dtype=='float32' #0d array
        assert_allclose(Sr.subspace.pi, pi)
    except ImportError as e:
        print('not able to import Fortran Esprit real {}'.format(e))
        Sr=None

    return Sc,Sr