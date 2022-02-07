#!/usr/bin/env python3

import os
import sys

#sys.path.insert(0, os.path.abspath('lib'))

try:
    from setuptools import setup, find_packages
except ImportError:
    print("sync_slurm_allocations needs setuptools in order to build."
          " Install it using"
          " your package manager (usually python-setuptools) or via pip (pip"
          " install setuptools).")
    sys.exit(1)

setup(name='sync_slurm_allocations',
      version="1.0.0",
      description='Upload Slurm Job Accounting to Lex',
      author="David Whiteside",
      author_email='david.whiteside@nrel.gov',
      url='https://github.nrel.gov/hpc/sync_slurm_allocations',
      license='MIT',
      install_requires=[],
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
         'files/sync_slurm_allocations',
      ]
      )
