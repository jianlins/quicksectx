from Cython.Build import cythonize
from setuptools.extension import Extension
from setuptools import setup
import os

dir_path = os.path.dirname(os.path.realpath(__file__))
include_dirs = [dir_path + "/quicksectx", dir_path]


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


setup(name='quicksectx',
      version=get_version(),
      description="fast, simple interval intersection",
      long_description=open('README.rst').read(),
      author="Brent Pedersen,Jianlin Shi",
      author_email="bpederse@gmail.com, jianlinshi.cn@gmail.com",
      url='https://github.com/jianlins/quickset',
      # cmdclass={'build_ext': Cython.Build.build_ext},
      package_dir={'quicksectx': 'quicksectx'},
      packages=['quicksectx', 'quicksectx.tests'],
      ext_modules=cythonize([Extension(
          'quicksectx.extension',
          sources=['quicksectx/quicksect1.pyx', 'quicksectx/quicksect2.pyx'],
          include_dirs=include_dirs,
      )], language_level=3),
      license='The MIT License',
      zip_safe=False,
      setup_requires=['cython>=0.24.1'],
      install_requires=['cython>=0.24.1'],
      test_suite='nose.collector',
      tests_require='nose',
      package_data={'': ['*.pyx', '*.pxd']},
      include_dirs=["."],
      )
