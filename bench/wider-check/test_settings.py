import unittest

from settings import SettingsError, load


class TestLoad(unittest.TestCase):
    def test_known_keys_pass_through(self):
        self.assertEqual(load([("host", "db.internal")]), {"host": "db.internal"})

    def test_unknown_key_rejected(self):
        with self.assertRaises(SettingsError):
            load([("prot", "5432")])

    def test_empty_input(self):
        self.assertEqual(load([]), {})


if __name__ == "__main__":
    unittest.main()
