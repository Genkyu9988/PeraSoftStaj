import json
import tempfile
import unittest
from pathlib import Path

from configure_cloudflare import save_config


class SetupTest(unittest.TestCase):
    def test_explicit_replace_preserves_options_and_disables_generation(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / 'config.json'
            save_config(path, 'a' * 32, 'old-test-token')
            save_config(path, 'a' * 32, 'new-test-token', replace=True)
            config = json.loads(path.read_text())
            self.assertEqual(config['api_token'], 'new-test-token')
            self.assertEqual(config['max_attempts'], 15)
            self.assertFalse(config['generation_enabled'])
            self.assertEqual(list(Path(folder).iterdir()), [path])

    def test_invalid_replacement_preserves_old_file(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / 'config.json'
            save_config(path, 'a' * 32, 'old-test-token')
            original = path.read_bytes()
            with self.assertRaises(ValueError):
                save_config(path, 'a' * 32, '', replace=True)
            self.assertEqual(path.read_bytes(), original)

    def test_saves_disabled_configuration(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / 'config.json'
            save_config(path, 'a' * 32, 'test-only-token')
            config = json.loads(path.read_text())
            self.assertFalse(config['generation_enabled'])
            self.assertEqual(config['max_attempts'], 15)
            self.assertEqual(config['api_token'], 'test-only-token')

    def test_never_overwrites(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / 'config.json'
            save_config(path, 'a' * 32, 'original-test-token')
            with self.assertRaises(FileExistsError):
                save_config(path, 'a' * 32, 'replacement-test-token')
            self.assertEqual(json.loads(path.read_text())['api_token'], 'original-test-token')

    def test_invalid_values_do_not_create_file(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / 'config.json'
            for account, token in [('bad', 'token'), ('a' * 32, ''), ('a' * 32, 'bad\ntoken')]:
                with self.assertRaises(ValueError):
                    save_config(path, account, token)
                self.assertFalse(path.exists())


if __name__ == '__main__':
    unittest.main()
