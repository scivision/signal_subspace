#!/usr/bin/env python3
import setuptools #enables develop
import subprocess

with open('README.rst','r') as f:
	long_description = f.read()

try:
    subprocess.run(['conda','install','--yes','--quiet','--file','requirements.txt'])
except Exception as e:
    print('you will need to install packages in requirements.txt  {}'.format(e))

from numpy.distutils.core import setup,Extension

setup(name='spectral_analysis',
      version='0.1',
	  description='1-D & 2-D spectral analysis methods',
	  long_description=long_description,
	  author='Michael Hirsch',
	  url='https://github.com/scienceopen/spectral_analysis',
      dependency_links = [],
	  install_requires=[],
      extras_require={},
      packages=['spectral_analysis'],
      ext_modules=[Extension(name='fortsubspace_cmpl',
                    sources=['comm.f90','signals.f90','subspace.f90'],
                    f2py_options=['--quiet']),
                   Extension(name='fortsubspace_real',
                    sources=['comm.f90','signals_realsp.f90','subspace_realsp.f90'],
                    f2py_options=['--quiet'])]
	  )

