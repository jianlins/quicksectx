Quicksect
=========

Description
-----------


Quicksect is a fast python / cython implementation of interval search based on the pure python version in 
`bx-python <http://bx-python.trac.bx.psu.edu/>`__ 
I pulled it out, optimized and converted to cython and James Taylor has incoporated it back into bx-python
with his improvements.

I have brought this project back from the dead because I want a fast, simple, no-dependencies Interval
tree.

(https://github.com/brentp/quicksect)

Extended with removal operations and allows pretty print to display tree structure (By Jianlin)


License is MIT.

Installation
------------

    pip install quicksectx

Use
---

To use extended quicksect(quicksectx):

    >>> from quicksectx import IntervalNode, IntervalTree, Interval
    >>> tree = IntervalTree()
    >>> tree.add(1, 3, 100)
    >>> tree.add(3, 7, 110)
    >>> tree.add(2, 5, 120)
    >>> tree.add(4, 6, 130)
    >>> print(tree.pretty_print())
    Inv(1, 3, d=100)
    r:  Inv(3, 7, d=110)
    l:    Inv(2, 5, d=120)
    r:    Inv(4, 6, d=130)
    >>> print(tree.find(Interval(2, 5)))
    [Inv(1, 3, d=100), Inv(3, 7, d=110), Inv(2, 5, d=120), Inv(4, 6, d=130)]
    >>> tree.remove(Interval(2, 5))
    >>> print(tree.find(Interval(2, 5)))
    [Inv(1, 3, d=100), Inv(3, 7, d=110), Inv(4, 6, d=130)]
    

To use traditional quicksect, you can still using the same syntax:

    >>> from quicksect import IntervalNode, Interval, IntervalTree

Most common use will be via IntervalTree:

    >>> tree = IntervalTree()
    >>> tree.add(23, 45)
    >>> tree.add(55, 66)
    >>> tree.search(46, 47)
    []
    >>> tree.search(44, 56)
    [Interval(55, 66), Interval(23, 45)]

    >>> tree.insert(Interval(88, 444, 'a'))
    >>> res = tree.find(Interval(99, 100, 'b'))
    >>> res
    [Interval(88, 444)]
    >>> res[0].start, res[0].end, res[0].data
    (88, 444, 'a')

Thats pretty much everything you need to know about the tree.


Test
----

$ python setup.py test

Low-Level
+++++++++

In some cases, users may want to utilize the lower-level interface that accesses
the nodes of the tree:

    >>> inter = IntervalNode(Interval(22, 33))
    >>> inter = inter.insert(Interval(44, 55))
    >>> inter.intersect(24, 26)
    [Interval(22, 33)]

    >>> inter.left(Interval(34, 35), n=1)
    [Interval(22, 33)]

    >>> inter.right(Interval(34, 35), n=1)
    [Interval(44, 55)]


Since 0.3.7, you can use python's native pickle to pickle an IntervalTree object. For details, check 
`test_serialization.py <https://github.com/jianlins/quicksectx/blob/master/tests/test_serialization.py>`__

For Dev
-------

Now the version specification has been integrated with setup.py and pyproject.toml. To update versions, only need to change the __version__ in `quicksectx/__init__.py <https://github.com/jianlins/quicksectx/blob/master/quicksectx/__init__.py>`__
