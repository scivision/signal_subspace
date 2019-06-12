#!/usr/bin/env python
import setuptools  # noqa: F401
from numpy.distutils.core import setup, Extension


ext = Extension(name='subspace',
                sources=['comm_legacy.f90', 'filters.f90', 'covariance.f90', 'subspace.f90'],
                extra_link_args=['-llapack'])

setup(ext_modules=[ext])
