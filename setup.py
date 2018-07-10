#!/usr/bin/env python
import setuptools  # noqa: F401
from numpy.distutils.core import setup, Extension

ext1 = Extension(name='fortsubspace',
                 sources=['comm.f90', 'filters.f90', 'covariance.f90', 'signals.f90', 'subspace.f90'],
                 f2py_options=['--quiet'],
                 extra_link_args=['-llapack'])

ext2 = Extension(name='subspace',
                 sources=['comm.f90', 'filters.f90', 'covariance.f90'],#, 'signals.f90', 'subspace.f90'],
                 f2py_options=['--quiet'],
                 extra_link_args=['-llapack'])
      

setup(ext_modules=[ext2])
