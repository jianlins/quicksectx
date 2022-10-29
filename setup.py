from Cython.Build import cythonize, build_ext
from setuptools.extension import Extension
from setuptools import setup, find_packages
# from distutils.core import setup

import os
from pathlib import Path

dir_path = os.path.dirname(os.path.realpath(__file__))
include_dirs = [dir_path + "/quicksectx", dir_path, dir_path + "/quicksect"]


def get_version():
    """Load the version from version.py, without importing it.

    This function assumes that the last line in the file contains a variable defining the
    version string with single quotes.

    """
    try:
        with open('quicksectx/version.py', 'r') as f:
            return f.read().split('\n')[0].split('=')[-1].replace('\'', '').strip()
    except IOError:
        return "0.0.0a1"


extensions = [
    Extension(
        'quicksect.quicksect',
        sources=['quicksect/quicksect.pyx'],
        include_dirs=include_dirs,
    ),
    Extension(
        'quicksectx.quicksectx',
        sources=['quicksectx/quicksectx.pyx'],
        include_dirs=include_dirs,
    )
]



setup(name='quicksectx',
      version=get_version(),
      description="fast, simple interval intersection",
      long_description_content_type="text/x-rst",
      long_description=open(Path(dir_path, 'README.rst').absolute()).read(),
      author="Brent Pedersen,Jianlin Shi",
      author_email="bpederse@gmail.com, jianlinshi.cn@gmail.com",
      url='https://github.com/jianlins/quicksectx',
      packages=find_packages(),
      ext_modules=cythonize(extensions, compiler_directives={'language_level': "3"}),
      license='The MIT License',
      zip_safe=False,
      setup_requires=['Cython>=0.25,<3.0'],
      install_requires=['Cython>=0.25,<3.0'],
      test_suite='nose.collector',
      tests_require='nose',
      package_data={'': ['*.pyx', '*.pxd', '*.so', '*.dll', '*.lib', '*.cpp', '*.c']},
      )
