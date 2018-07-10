#!/usr/bin/env python
import setuptools  # noqa: F401
from numpy.distutils.core import setup, Extension

setup(ext_modules=[Extension(name='fortsubspace_cmpl',
                             sources=['comm.f90', 'filters.f90', 'covariance.f90', 
                                      'signals.f90', 'subspace.f90'],
                             f2py_options=['--quiet'],
                             extra_link_args=['-llapack']),

                   Extension(name='fortsubspace_real',
                             sources=['comm.f90', 'filters.f90', 
                                      'signals_realsp.f90','covariance_realsp.f90', 
                                      'subspace_realsp.f90'],
                             f2py_options=['--quiet'],
                             extra_link_args=['-llapack'])])
