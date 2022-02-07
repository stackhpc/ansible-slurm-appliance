#!/usr/bin/env python3

import os
import sys

try:
    from setuptools import setup, find_packages
except ImportError:
    print("cluster_config_manager needs setuptools in order to build."
          " Install it using"
          " your package manager (usually python-setuptools) or via pip (pip"
          " install setuptools).")
    sys.exit(1)

setup(name='cluster_config_manager',
      version="1.0.0",
      description='sync local user data from IPA',
      author="David Whiteside",
      author_email='david.whiteside@nrel.gov',
      url='https://github.nrel.gov/hpc/cluster_config_manager',
      license='MIT',
      install_requires=["python-ldap"],
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
         'files/cluster_config_manager',
      ]
      )
