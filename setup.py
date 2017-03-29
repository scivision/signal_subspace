#!/usr/bin/env python
import setuptools #enables develop

req=['nose','numpy','scipy','matplotlib','pandas','seaborn']

from numpy.distutils.core import setup,Extension

setup(name='spectral_analysis',
      version='0.5',
	  description='1-D & 2-D spectral analysis methods',
	  author='Michael Hirsch, Ph.D.',
	  url='https://github.com/scivision/spectral_analysis',
      dependency_links = [],
	  install_requires=req,
      extras_require={},
      packages=['spectral_analysis'],
      ext_modules=[Extension(name='fortsubspace_cmpl',
                    sources=['comm.f90','filters.f90', 'signals.f90','covariance.f90', 'subspace.f90'],
                    f2py_options=['--quiet'],
                    extra_link_args=['-llapack'] ),

                   Extension(name='fortsubspace_real',
                    sources=['comm.f90', 'filters.f90', 'signals_realsp.f90', 'covariance_realsp.f90', 'subspace_realsp.f90'],
                    f2py_options=['--quiet'],
                    extra_link_args=['-llapack'])]
	  )

