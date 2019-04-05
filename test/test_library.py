import unittest
import unittest.mock
import env
import library
import game


class TestGame(unittest.TestCase):

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_appendGame(self):
        l = library.Library()
        l.appendGame(game.Game())
        self.assertEqual(1, len(l.games))

    def test_sort(self):
        l = library.Library()

        l.appendGame(game.Game(name='basketball'))
        l.appendGame(game.Game(name='Bear'))
        l.appendGame(game.Game(name='Cheetah'))
        l.appendGame(game.Game(name='chair'))
        l.appendGame(game.Game(name='antelope'))
        l.appendGame(game.Game(name='Asparagus'))

        l.sortGames()

        self.assertEqual('antelope', l.games[0].name)

    def test_search(self):
        l = library.Library()

        l.appendGame(game.Game(name='basketball'))
        l.appendGame(game.Game(name='Bear'))
        l.appendGame(game.Game(name='Cheetah'))
        l.appendGame(game.Game(name='chair'))
        l.appendGame(game.Game(name='antelope'))
        l.appendGame(game.Game(name='Asparagus'))

        l.updateFilters()
        l.searchGames('basket')

        self.assertEqual('basketball', l.filter[0].name)

        l.searchGames('chair')

        self.assertEqual('chair', l.filter[0].name)

if __name__ == '__main__':
    unittest.main()
