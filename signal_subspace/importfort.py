from numpy.testing import assert_allclose
from numpy import pi
import logging

def fort():

    S = {}
    try:
        import fortsubspace_cmpl as Sc
        assert Sc.comm.pi.dtype == 'float64'  # 0d array
        assert Sc.comm.j.dtype == 'complex128'
        assert_allclose(Sc.comm.pi, pi)
        S['c'] = Sc
    except (ImportError, AssertionError, AttributeError) as e:
        logging.error(f'problem importing Fortran subspace complex  {e}')

    try:
        import fortsubspace_real as Sr
        assert Sr.subspace.pi.dtype == 'float32'  # 0d array
        assert_allclose(Sr.subspace.pi, pi)
        S['r'] = Sr
    except (ImportError, AssertionError, AttributeError) as e:
        logging.error(f'problem importing Fortran subspace real  {e}')

    return S

