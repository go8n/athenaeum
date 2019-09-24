import unittest
from unittest.mock import MagicMock
import env
import library
import game


class TestGame(unittest.TestCase):

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_sort(self):
        pass

    def test_search(self):
        mockMetaRepo = MagicMock()
        mockMetaRepo.set.return_value = None
        l = library.Library(metaRepository=mockMetaRepo)
        pass

if __name__ == '__main__':
    unittest.main()
