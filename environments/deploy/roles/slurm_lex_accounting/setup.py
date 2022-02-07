#!/usr/bin/env python3

import os
import sys

sys.path.insert(0, os.path.abspath('lib'))
from slurm_lex_accounting import __version__, __author__

try:
    from setuptools import setup, find_packages
except ImportError:
    print("slurm_lex_accounting needs setuptools in order to build."
          " Install it using"
          " your package manager (usually python-setuptools) or via pip (pip"
          " install setuptools).")
    sys.exit(1)

setup(name='slurm_lex_accounting',
      version=__version__,
      description='Upload Slurm Job Accounting to Lex',
      author=__author__,
      author_email='david.whiteside@nrel.gov',
      url='https://github.nrel.gov/hpc/slurm-lex-accounting',
      license='MIT',
      install_requires=["iso8601==0.1.14", "PyJWT==1.7.1", "pytz==2021.1", "rfc3339==6.2"],
      package_dir={'': 'lib'},
      packages=find_packages('lib'),
      classifiers=[
          'Environment :: Console',
          'Intended Audience :: Information Technology',
          'Intended Audience :: System Administrators',
          'License :: OSI Approved :: MIT License',
          'Natural Language :: English',
          'Operating System :: POSIX',
          'Programming Language :: Python :: 3.6',
          'Programming Language :: Python :: 3.7',
          'Programming Language :: Python :: 3.8',
          'Programming Language :: Python :: 3.9',
          'Topic :: System :: Installation/Setup',
          'Topic :: System :: Systems Administration',
          'Topic :: Utilities',
      ],
      scripts=[
         'bin/slurm-lex-accounting-upload',
      ]
      )
