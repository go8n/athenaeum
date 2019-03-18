import unittest
import env
import library
import game


class TestGame(unittest.TestCase):
    
    def setUp(self):
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

if __name__ == '__main__':
    unittest.main()
