import unittest

from config import ConfigError, load


class TestLoad(unittest.TestCase):
    def test_basic_pairs(self):
        self.assertEqual(load("host = db.internal\nport = 5432"),
                         {"host": "db.internal", "port": "5432"})

    def test_comments_and_blanks_ignored(self):
        self.assertEqual(load("# note\n\nhost = x\n"), {"host": "x"})

    def test_malformed_line_raises(self):
        with self.assertRaises(ConfigError):
            load("host db.internal")

    def test_values_are_stripped(self):
        self.assertEqual(load("timeout =   30  "), {"timeout": "30"})


if __name__ == "__main__":
    unittest.main()
