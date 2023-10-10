#!/usr/bin/python3
# distutils: language = c++
"""
Intersects ... faster.  Suports GenomicInterval datatype and multiple
chromosomes.

extend the implementation to allow remove intervals @jianlins

"""
import operator
from .quicksectx cimport Interval, IntervalNode, IntervalTree
import cython

#@cdef extern from "math.h":

cdef class Interval:
    def __init__(self, int start, int end, data=None):
        if start > end:
            raise ValueError(
                'Start cannot be greater than end. trying to construct an interval using {}-{}'.format(start, end))
        self.start = start
        self.end = end
        self.data = data

    @property
    def start(self):
        return self.start

    @start.setter
    def start(self, int start):
        self.start = start

    @property
    def end(self):
        return self.end

    @end.setter
    def end(self, int end):
        self.end = end

    @property
    def data(self):
        return self.data

    @data.setter
    def data(self, object data):
        self.data = data

    def __repr__(self):
        return self.get_str()

    cdef str get_str(self):
        if self.data is not None:
            return "Inv(%d, %d, d=%s)" % (self.start, self.end, self.data)
        else:
            return "Inv(%d, %d)" % (self.start, self.end)

    def __reduce__(self):
        args = self.__getstate__()
        return type(self), (args.pop('start'), args.pop('end')), args

    def __getstate__(self):
        return {'start': self.start, 'end': self.end, 'data': self.data}

    def __setstate__(self, kwargs):
        self.data = kwargs['data']

    def __str__(self):
        return self.__repr__()

cpdef int positioning(Interval f1, Interval f2):
    if f1.start < f2.start:
        return 1
    if f1.start > f2.start:
        return -1
    if f1.end < f2.end:
        return 1
    if f1.end > f2.end:
        return -1
    return 0


cpdef int overlaps(Interval f1, Interval f2):
    if f1.end < f2.start or f2.end < f1.start:
        return 1
    elif f1.start == f2.start and f1.end == f2.end:
        return 0
    else:
        return -1

cpdef int distancex(Interval f1, Interval f2):
    """\
    Distance between 2 features. The integer result is always positive or zero.
    If the features overlap or touch, it is zero.
    # >>> from quicksectx import Interval, distancex
    # >>> distancex(Interval(1, 2), Interval(12, 13))
    # 10
    # >>> distancex(Interval(1, 2), Interval(2, 3))
    # 0
    # >>> distancex(Interval(1, 100), Interval(20, 30))
    0

    """
    # if f1.end < f2.start: return f2.start - f1.end
    # if f2.end < f1.start: return f1.start - f2.end
    if f1.end < f2.start:
        return f2.start - f1.end
    elif f2.end < f1.start:
        return f1.start - f2.end
    elif f1.start == f2.start and f1.end == f2.end:
        return 0
    else:
        return -1

cdef class IntervalTree:
    def __init__(self):
        self.root = None

    def insert(self, interval):
        self._insert(interval)

    cdef _insert(self, Interval interval):

        if self.root is None:
            self.root = IntervalNode(interval)
        else:
            self.root = self.root._insert(interval)

    def add(self, int start, int end, other=None):
        return self._insert(Interval(start, end, other))

    def remove(self, Interval interval):
        self.root = self._remove(self.root, interval)

    cdef IntervalNode _remove(self, IntervalNode h, Interval interval):
        if h is None:
            return None
        cdef dist = positioning(h.interval, interval)
        # print(h, interval, dist)
        if dist < 0:
            if h.cleft is not None and h.cleft != EmptyNode:
                h.cleft = self._remove(h.cleft, interval)
        elif dist > 0:
            if h.cright is not None and h.cright != EmptyNode:
                h.cright = self._remove(h.cright, interval)
        else:
            # print("find and remove: {}".format(h))
            h = self.join_lr(h.cleft, h.cright)
        if h is not None:
            # print("fix: ",h)
            h.croot.set_stops()
        else:
            h = EmptyNode
        return h

    cdef IntervalNode join_lr(self, IntervalNode a, IntervalNode b):
        if a is None or a == EmptyNode:
            return b
        if b is None or b == EmptyNode:
            return a
        if 1.0 * rand() * (a.priority + b.priority) < a.priority:
            a.cright = self.join_lr(a.cright, b)
            a.set_stops()
            return a
        else:
            b.cleft = self.join_lr(a, b.cleft)
            b.set_stops()
            return b
        pass

    def find(self, interval: Interval)-> list:
        return self._find(interval)

    cdef list _find(self, Interval interval):
        if self.root is None:
            return []
        else:
            return self.root.intersect(interval.start, interval.end)

    def search(self, start: int, end: int)-> list:
        return self._search(start, end)

    cdef list _search(self, int start, int end):
        if self.root is None:
            return []
        else:
            return self.root.intersect(start, end)

    def left(self, Interval f, int n=1, int max_dist=25000):
        if self.root is None:
            return []
        else:
            return self.root._left(f, n, max_dist)

    def right(self, Interval f, int n=1, int max_dist=25000):
        if self.root is None:
            return []
        else:
            return self.root.right(f, n, max_dist)

    def dump(self, fn):
        try:
            import cPickle
        except ImportError:
            import pickle as cPickle
        l = []
        a = l.append
        self.root.traverse(a)
        fh = open(fn, "wb")
        for f in l:
            cPickle.dump(f, fh)
        fh.close()

    def load(self, fn):
        try:
            import cPickle
        except ImportError:
            import pickle as cPickle
        fh = open(fn, "rb")
        while True:
            try:
                feature = cPickle.load(fh)
                self.insert(feature)
            except EOFError:
                break
        fh.close()

    def loads(self, intervals):
        for inv in intervals:
            self.insert(inv)

    def dumps(self):
        intervals = []
        a = intervals.append
        self.root.traverse(a)
        return intervals

    @classmethod
    def _reconstruct(cls, intervals):
        obj=cls()
        obj.loads(intervals)
        return obj
    def __reduce__(self):
        intervals=self.dumps()
        return (self._reconstruct, (intervals,))
    @property
    def root(self):
        return self.root

    @root.setter
    def root(self, IntervalNode node):
        self.root = node

    def pretty_print(self):
        return self._pretty_print()

    cdef _pretty_print(self):
        return str(self.root)

cdef inline int imax2(int a, int b):
    if b > a: return b
    return a

cdef inline int imax3(int a, int b, int c):
    if b > a:
        if c > b:
            return c
        return b
    if a > c:
        return a
    return c

cdef inline int imin3(int a, int b, int c):
    if b < a:
        if c < b:
            return c
        return b
    if a < c:
        return a
    return c

cdef inline int imin2(int a, int b):
    if b < a: return b
    return a

cdef float nlog = -1.0 / log(0.5)

cdef class IntervalNode:
    @property
    def left_node(self):
        return self.cleft if self.cleft is not EmptyNode else None
    @left_node.setter
    def left_node(self, IntervalNode node):
        self.cleft = node
    @property
    def right_node(self):
        return self.cright if self.cright is not EmptyNode else None
    @right_node.setter
    def right_node(self, IntervalNode node):
        self.cright = node
    @property
    def root_node(self):
        return self.croot if self.croot is not EmptyNode else None
    @root_node.setter
    def root_node(self, IntervalNode node):
        self.croot = node

    def __repr__(self):
        return "IntervalNode(%i, %i)" % (self.start, self.end)

    @cython.cdivision(True)
    def __cinit__(self, Interval interval):
        # Python lacks the binomial distribution, so we convert a
        # uniform into a binomial because it naturally scales with
        # tree size.  Also, python's uniform is perfect since the
        # upper limit is not inclusive, which gives us undefined here.
        self.priority = ceil(nlog * log(-1.0 / (1.0 * rand() / RAND_MAX - 1)))
        self.start = interval.start
        self.end = interval.end
        self.interval = interval
        self.maxstop = interval.end
        self.minstart = interval.start
        self.minstop = interval.end
        self.cleft = EmptyNode
        self.cright = EmptyNode
        self.croot = EmptyNode

    def insert(self, interval):
        return self._insert(interval)

    cdef IntervalNode _insert(self, Interval interval):
        cdef IntervalNode croot = self
        if interval.start > self.start:

            # insert to cright tree
            if self.cright is not EmptyNode:
                self.cright = self.cright._insert(interval)
            else:
                self.cright = IntervalNode(interval)
            # rebalance tree
            if self.priority < self.cright.priority:
                croot = self.rotate_left()

        else:
            # insert to cleft tree
            if self.cleft is not EmptyNode:
                self.cleft = self.cleft._insert(interval)
            else:
                self.cleft = IntervalNode(interval)
            # rebalance tree
            if self.priority < self.cleft.priority:
                croot = self.rotate_right()

        croot.set_stops()
        self.cleft.croot = croot
        self.cright.croot = croot
        return croot

    cdef IntervalNode rotate_right(self):
        cdef IntervalNode croot = self.cleft
        self.cleft = self.cleft.cright
        croot.cright = self
        self.set_stops()
        return croot

    cdef IntervalNode rotate_left(self):
        cdef IntervalNode croot = self.cright
        self.cright = self.cright.cleft
        croot.cleft = self
        self.set_stops()
        return croot

    def setstops(self):
        self.set_stops()

    cdef inline void set_stops(self):
        if self.cright is not EmptyNode and self.cleft is not EmptyNode:
            self.maxstop = imax3(self.end, self.cright.maxstop, self.cleft.maxstop)
            self.minstop = imin3(self.end, self.cright.minstop, self.cleft.minstop)
            self.minstart = imin3(self.start, self.cright.minstart, self.cleft.minstart)
        elif self.cright is not EmptyNode:
            self.maxstop = imax2(self.end, self.cright.maxstop)
            self.minstop = imin2(self.end, self.cright.minstop)
            self.minstart = imin2(self.start, self.cright.minstart)
        elif self.cleft is not EmptyNode:
            self.maxstop = imax2(self.end, self.cleft.maxstop)
            self.minstop = imin2(self.end, self.cleft.minstop)
            self.minstart = imin2(self.start, self.cleft.minstart)

    cpdef list find(self, int start, int stop):
        return self.intersect(start, stop)

    def intersect(self, int start, int stop):
        """
        given a start and a stop, return a list of features
        falling within that range
        """
        cdef list results = []
        self._intersect(start, stop, results)
        return results

    cdef void _intersect(self, int start, int stop, list results):
        # to have starts, stops be non-inclusive, replace <= with <  and >= with >
        #if start <= self.end and stop >= self.start: results.append(self.interval)
        # print(self, start, stop, results)
        if not (self.end <= start or self.start >= stop) or (start == stop == self.start) or (
                self.start == self.end == start): results.append(
            self.interval)
        #if self.cleft is not EmptyNode and start <= self.cleft.maxstop:
        if self.cleft is not EmptyNode and not self.cleft.maxstop < start:
            # print('go cleft')
            self.cleft._intersect(start, stop, results)
        #if self.cright is not EmptyNode and stop >= self.start:
        if self.cright is not EmptyNode and not self.start > stop:
            # print('go right')
            self.cright._intersect(start, stop, results)

    cdef void _seek_left(self, int position, list results, int n, int max_dist):
        # we know we can bail in these 2 cases.
        if self.maxstop + max_dist < position: return
        if self.minstart > position: return

        #import sys;sys.stderr.write( " ".join(map(str, ["SEEK_LEFT:", self, self.cleft, self.maxstop, self.minstart,  position])))

        # the ordering of these 3 blocks makes it so the results are
        # ordered nearest to farest from the query position
        if self.cright is not EmptyNode:
            self.cright._seek_left(position, results, n, max_dist)

        if -1 < position - self.end < max_dist:
            results.append(self.interval)

        # TODO: can these conditionals be more stringent?
        if self.cleft is not EmptyNode:
            self.cleft._seek_left(position, results, n, max_dist)

    cdef void _seek_right(self, int position, list results, int n, int max_dist):
        # we know we can bail in these 2 cases.
        if self.maxstop < position: return
        if self.minstart - max_dist > position: return

        #print "SEEK_RIGHT:",self, self.cleft, self.maxstop, self.minstart, position

        # the ordering of these 3 blocks makes it so the results are
        # ordered nearest to farest from the query position
        if self.cleft is not EmptyNode:
            self.cleft._seek_right(position, results, n, max_dist)

        if -1 < self.start - position < max_dist:
            results.append(self.interval)

        if self.cright is not EmptyNode:
            self.cright._seek_right(position, results, n, max_dist)

    def neighbors(self, Interval f, int n=1, int max_dist=25000):
        cdef list neighbors = []

        cdef IntervalNode right = self.cright
        while right.cleft is not EmptyNode:
            right = right.cleft

        cdef IntervalNode left = self.cleft
        while left.cright is not EmptyNode:
            left = left.cright
        return [left, right]

    def left(self, Interval f, int n, int max_dist=25000):
        return self._left(f, n, max_dist)

    cdef _left(self, Interval f, int n, int max_dist):
        """find n features with a start > than f.end
        f: a Interval object
        n: the number of features to return
        max_dist: the maximum distancex to look before giving up.
        """
        cdef list results = []
        # use start - 1 becuase .left() assumes strictly left-of
        self._seek_left(f.start - 1, results, n, max_dist)
        if len(results) <= n: return results
        r = results
        r.sort(key=operator.attrgetter('end'), reverse=True)
        if distancex(f, r[n]) != distancex(f, r[n - 1]):
            return r[:n]

        while n < len(r) and (distancex(r[n], f) == distancex(r[n - 1], f) or (
                distancex(r[n], f) < 1 and distancex(r[n - 1], f) < 1)):
            n += 1
        return r[:n]

    def right(self, Interval f, int n=1, int max_dist=25000):
        return self._right(f, n, max_dist)

    cdef _right(self, Interval f, int n, int max_dist):
        """find n features with a stop < than f.start
        f: a Interval object
        n: the number of features to return
        max_dist: the maximum distancex to look before giving up.
        """
        cdef list results = []

        # use stop + 1 becuase .right() assumes strictly right-of
        self._seek_right(f.end + 1, results, n, max_dist)
        if len(results) <= n: return results
        r = results
        r.sort(key=operator.attrgetter('start'))
        if distancex(f, r[n]) != distancex(f, r[n - 1]):
            return r[:n]
        while n < len(r) and (distancex(r[n], f) == distancex(r[n - 1], f) or (
                distancex(r[n], f) < 1 and distancex(r[n - 1], f) < 1)):
            n += 1
        return r[:n]

    def __iter__(self):

        if self.cleft is not EmptyNode:
            yield self.cleft

        yield self.interval

        if self.cright is not EmptyNode:
            yield self.cright

    def traverse(self, func):
        self._traverse(func)

    cdef void _traverse(self, object func):
        if self.cleft is not EmptyNode: self.cleft._traverse(func)
        func(self.interval)
        if self.cright is not EmptyNode: self.cright._traverse(func)

    cdef str _str(self, int level=0):
        cdef rep = "  " * level + repr(self.interval) + "\n"
        if self.cleft is not None and self.cleft is not EmptyNode:
            rep += 'l:' + self.cleft._str(level + 1)
        if self.cright is not None and self.cright is not EmptyNode:
            rep += 'r:' + self.cright._str(level + 1)
        return rep

    def __str__(self):
        return self._str()


cdef IntervalNode EmptyNode = IntervalNode(Interval(0, 0))