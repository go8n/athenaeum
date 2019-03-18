import unittest
import env
import game


class TestGame(unittest.TestCase):
    
    def setUp(self):
        pass

    def test_upper(self):
        g = game.Game(id='game_id')
        self.assertEqual('game_id', g.id)

if __name__ == '__main__':
    unittest.main()
