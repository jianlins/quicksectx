from Cython.Build import cythonize, build_ext
from setuptools.extension import Extension
from setuptools import setup, find_packages
# from distutils.core import setup

import os
from pathlib import Path

dir_path = os.path.dirname(os.path.realpath(__file__))
include_dirs = [dir_path + "/quicksectx", dir_path, dir_path + "/quicksect"]


def get_version():
    for line in open(os.path.join(os.path.dirname(__file__), 'quicksectx', '__init__.py')).read().splitlines():
        if line.startswith('__version__'):
            delim = '"' if '"' in line else "'"
            return line.split(delim)[1]
    else:
        raise RuntimeError("Unable to find version string.")

        
def parse_requirements(requirements_file):
    requirements=open(os.path.join(os.path.dirname(__file__), requirements_file)).read().split('\n')
    requirements=[r.strip() for r in requirements]
    requirements=[r for r in requirements if len(r)>0 and not r.startswith('#')]
    return requirements

build_version=get_version()
install_reqs = parse_requirements('requirements.txt')
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
      version=build_version,
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
      setup_requires=install_reqs,
      install_requires=install_reqs,
      test_suite='nose.collector',
      tests_require='nose',
      package_data={'': ['*.pyx', '*.pxd', '*.so', '*.dll', '*.lib', '*.cpp', '*.c']},
      )
