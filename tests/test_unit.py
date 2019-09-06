#!/usr/bin/env python
import pytest
from pytest import approx
import subspace  # fortran f2py
import signal_subspace as subs
from time import time


def test_corrmtx(fake_sig):
    M = 5
    subs.corrmtx(fake_sig.real, M)


def test_autocov(fake_sig):
    """2x extra speedup from casting correct type"""
    x = fake_sig

    M = 5
    tic = time()
    C = subs.compute_autocovariance(x, M)
    tocpy = time() - tic
    print(C)
    # %%
    tic = time()
    Cc = subspace.covariance.autocov_c(x, M)
    tocfortcmpl = time() - tic

    tic = time()
    Cr = subspace.covariance.autocov_r(x.real, M)
    tocfortreal = time() - tic

    print("autocovariance: Complex: Fortran faster than Python by factor:", tocpy / tocfortcmpl)
    print("autocovariance: Real: Fortran faster than Python by factor:", tocpy / tocfortreal)

    assert C == approx(Cc, rel=1)
    assert C.real == approx(Cr, rel=1)


if __name__ == "__main__":
    pytest.main(["-v", __file__])
