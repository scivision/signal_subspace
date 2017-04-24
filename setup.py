#!/usr/bin/env python
req=['nose','numpy','scipy','matplotlib','pandas','seaborn','pathlib2']
# %%
import pip
try:
    import conda.cli
    conda.cli.main('install',*req)
except Exception as e:
    pip.main(['install'] +req)
pip.main(['install']+pipreq)
# %%
import setuptools #enables develop
from numpy.distutils.core import setup,Extension

setup(name='signal_subspace',
      packages=['signal_subspace'],
      version='1.0.0',
	  description='1-D & 2-D signal subspace estimation methods',
	  author='Michael Hirsch, Ph.D.',
	  url='https://github.com/scivision/signal_subspace',
      ext_modules=[Extension(name='fortsubspace_cmpl',
                    sources=['comm.f90','filters.f90', 'signals.f90','covariance.f90', 'subspace.f90'],
                    f2py_options=['--quiet'],
                    extra_link_args=['-llapack'] ),

                   Extension(name='fortsubspace_real',
                    sources=['comm.f90', 'filters.f90', 'signals_realsp.f90', 'covariance_realsp.f90', 'subspace_realsp.f90'],
                    f2py_options=['--quiet'],
                    extra_link_args=['-llapack'])]
	  )

