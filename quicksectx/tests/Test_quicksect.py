import pyximport
pyximport.install()
from quicksectx import IntervalNodeX, IntervalTreeX, distancex,IntervalX
import unittest
# tree = IntervalTreeX()
# tree.add(0, 3, 100)
# tree.add(5, 8, 110)
# tree.add(6, 10, 120)
# tree.add(8, 9, 130)
# tree.add(15, 23, 140)
# tree.add(19, 20, 150)
# tree.add(17, 19, 160)
# tree.add(26, 26, 160)
# tree.add(25, 30, 160)
# tree.add(16, 21, 160)
# print(tree.pretty_print())
# print('\n\n---\n\n\n')
# tree = IntervalXTreeX()
# tree.add(0, 3, 100)
# tree.add(5, 8, 110)
# tree.add(6, 10, 120)
# tree.add(8, 9, 130)
# tree.add(15, 23, 140)
# tree.add(16, 21, 160)
# tree.add(17, 19, 160)
# tree.add(19, 20, 150)
# tree.add(25, 30, 160)
# tree.add(26, 26, 160)
# tree.add(27, 28, 160)
# tree.add(27, 28, 160)
# tree.add(27, 28, 160)
# print(tree.pretty_print())
class MyTestCase(unittest.TestCase):

    def test_1(self):
        tree = IntervalTreeX()
        tree.add(1, 3, 100)
        tree.add(3, 7, 110)
        tree.add(2, 5, 120)
        tree.add(4, 6, 130)
        tree.add(4, 8, 140)
        tree.add(4, 8, 150)
        tree.add(5, 7, 160)
        print(tree.pretty_print())
        print(tree.find(IntervalX(2, 5)))
        tree.remove(IntervalX(2, 5))
        print(tree.find(IntervalX(2, 5)))
        print(tree.pretty_print())
        self.assertEqual(True, True)


if __name__ == '__main__':
    unittest.main()
print(IntervalX(1, 2).__reduce__())