#!/usr/bin/env python
"""Get the version string from the git tag."""


def get_version():
    """Load the version from version.py, without importing it.

    This function assumes that the last line in the file contains a variable defining the
    version string with single quotes.

    """
    try:
        with open('../quicksectx/version.py', 'r') as f:
            return f.read().split('=')[-1].replace('\'', '').strip()
    except IOError:
        return "0.0.0a1"


def main():
    """Print the version derived from ``git describe --tags`` in a useful format."""
    print(get_version())


if __name__ == '__main__':
    main()
