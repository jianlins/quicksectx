# distutils: language = c++
cdef extern from "stdlib.h":
    int ceil(float f)
    float log(float f)
    int RAND_MAX
    int rand()
    int strlen(char *)
    int iabs(int)

cdef class Interval:
    cdef int start
    cdef int end
    cdef object data
    cdef str get_str(self)

cdef class IntervalNode:
    cdef int priority
    cdef public Interval interval
    cdef int start, end
    cdef int minstop, maxstop, minstart
    cdef IntervalNode cleft, cright, croot
    cdef IntervalNode _insert(self, Interval interval)
    cdef IntervalNode rotate_right(self)
    cdef IntervalNode rotate_left(self)
    cdef inline void set_stops(self)
    cpdef list find(self, int start, int stop)
    cdef void _intersect(self, int start, int stop, list results)
    cdef void _seek_left(self, int position, list results, int n, int max_dist)
    cdef void _seek_right(self, int position, list results, int n, int max_dist)
    cdef _left(self, Interval f, int n, int max_dist)
    cdef _right(self, Interval f, int n, int max_dist)
    cdef void _traverse(self, object func)
    cdef str _str(self, int level= *)

cdef class IntervalTree:
    cdef IntervalNode root
    cdef IntervalNode _remove(self, IntervalNode h, Interval interval)
    cdef _insert(self, Interval interval)
    cdef list _search(self, int start, int end)
    cdef list _find(self, Interval interval)
    cdef IntervalNode join_lr(self, IntervalNode a, IntervalNode b)
    cdef _pretty_print(self)
