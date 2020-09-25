from numpy.testing import assert_allclose
from numpy import pi
import logging


def fort():
    try:
        import subspace

        assert subspace.comm.pi.dtype == "float64"  # 0d array
        assert subspace.comm.j.dtype == "complex128"
        assert_allclose(subspace.comm.pi, pi)
    except (ImportError, AssertionError, AttributeError) as e:
        logging.error(f"problem importing Fortran subspace complex  {e}")

    return subspace
