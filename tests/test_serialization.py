import unittest

from quicksectx import IntervalNode, IntervalTree, Interval
import operator
from pickle import dumps, loads,dump,load
from pathlib import Path

class SerialTestCase(unittest.TestCase):
    def setUp(self):
        if not Path('tmp').exists():
            Path('tmp').mkdir()
        

    def test_left(self):
        interval = Interval(start=1, end=5, data="sample data")
        with open('tmp/interval.pkl', 'wb') as file:
            dump(interval, file)

        with open('tmp/interval.pkl', 'rb') as file:
            loaded_interval = load(file)
        print("Original Interval:", interval)
        print("Loaded Interval:", loaded_interval)

    def test_intervaltree_serialization(self):
        # Create an instance of IntervalNode
        a = IntervalTree()
        for ichr in range(5):
            for i in range(10, 100, 6):
                f = Interval(i - 4, i + 4)
                a.insert(f)
        with open('tmp/interval.pkl', 'wb') as file:
            dump(a, file)

        with open('tmp/interval.pkl', 'rb') as file:
            b = load(file)

        for ichr in range(5):
            for i in range(10, 100, 6):
                f = Interval(i - 4, i + 4)
                af = sorted(a.find(f), key=operator.attrgetter('start'))
                bf = sorted(b.find(f), key=operator.attrgetter('start'))

                assert len(bf) > 0
                self.assertEqual(len(af), len(bf))
                self.assertEqual(af[0].start, bf[0].start)
                self.assertEqual(af[-1].start, bf[-1].start)


    def test_intervaltree_serialization(self):
        # Create an instance of IntervalNode
        a = IntervalTree()
        for ichr in range(5):
            for i in range(10, 100, 6):
                f = Interval(i - 4, i + 4)
                a.insert(f)
        pickled=dumps(a)

        b=loads(pickled)

        for ichr in range(5):
            for i in range(10, 100, 6):
                f = Interval(i - 4, i + 4)
                af = sorted(a.find(f), key=operator.attrgetter('start'))
                bf = sorted(b.find(f), key=operator.attrgetter('start'))

                assert len(bf) > 0
                self.assertEqual(len(af), len(bf))
                self.assertEqual(af[0].start, bf[0].start)
                self.assertEqual(af[-1].start, bf[-1].start)
def main():
    unittest.main()


if __name__ == "__main__":
    unittest.main()