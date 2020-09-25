#!/usr/bin/env python
import setuptools  # noqa: F401  # lgtm [py/unused-import]
from numpy.distutils.core import setup, Extension


ext = Extension(
    name="subspace",
    sources=["src/comm_f2py.f90", "src/filters.f90", "src/covariance.f90", "src/subspace.f90"],
    extra_link_args=["-llapack"],
)

setup(ext_modules=[ext])
