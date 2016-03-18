#!/usr/bin/env python3

from setuptools import setup
import subprocess

with open('README.rst','r') as f:
	long_description = f.read()

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
	  )

#%%
try:
    subprocess.run(['conda','install','--yes','--quiet','--file','requirements.txt'])
except Exception as e:
    pass
