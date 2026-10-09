"""Interactive credential setup only: no network calls or generation requests."""
import argparse
import getpass
import json
import os
import re
import subprocess
import sys
import tempfile
import warnings
from pathlib import Path

CONFIG_PATH = Path(__file__).resolve().parent / '.cloudflare.local.json'
ACCOUNT_ID = '549a92b12980833fcb676037b30ff516'


def save_config(path, account_id, token, *, replace=False):
    if not re.fullmatch(r'[a-f0-9]{32}', account_id):
        raise ValueError('Account ID must contain 32 hexadecimal characters.')
    if not token or not token.isascii() or any(c.isspace() for c in token):
        raise ValueError('Invalid token format; no file was written.')
    if replace:
        # Preserve existing options and keep the old file intact until replacement.
        config = json.loads(path.read_text(encoding='utf-8'))
        config.update(account_id=account_id, api_token=token, generation_enabled=False)
        temporary = None
        try:
            with tempfile.NamedTemporaryFile(mode='w', encoding='utf-8',
                                             dir=path.parent, prefix='.cloudflare-secret-',
                                             suffix='.tmp', delete=False) as stream:
                temporary = Path(stream.name)
                json.dump(config, stream, indent=2)
                stream.write('\n')
                stream.flush()
                os.fsync(stream.fileno())
            os.replace(temporary, path)
        finally:
            if temporary is not None:
                temporary.unlink(missing_ok=True)
        return
    # Exclusive creation: never silently replace an existing credential.
    with path.open('x', encoding='utf-8') as stream:
        json.dump({
            'account_id': account_id,
            'api_token': token,
            'model': '@cf/black-forest-labs/flux-2-klein-4b',
            'generation_enabled': False,
            'max_attempts': 15,
        }, stream, indent=2)
        stream.write('\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--status', action='store_true', help='Check local configuration without showing secrets.')
    parser.add_argument('--replace', action='store_true', help='Interactively replace the saved token.')
    args = parser.parse_args()
    if args.status:
        if not CONFIG_PATH.exists():
            print('Cloudflare credential file is not configured yet.')
            return 1
        config = json.loads(CONFIG_PATH.read_text(encoding='utf-8'))
        print('Local credential present: ' + str(bool(config.get('api_token'))))
        print('Generation enabled: ' + str(config.get('generation_enabled', False)))
        print('No API connection was tested. Django enforces the 15-call shared limit through ai_attempts.')
        return 0
    if CONFIG_PATH.exists() and not args.replace:
        print('Configuration already exists; nothing overwritten. Use --status to check it.')
        return 1
    if args.replace and not CONFIG_PATH.exists():
        print('No saved configuration exists. Run without --replace first.')
        return 1
    if not sys.stdin.isatty():
        print('Run this command yourself in an interactive terminal. Do not pipe the token.')
        return 1
    ignored = subprocess.run(
        ['git', 'check-ignore', '--quiet', '--no-index', str(CONFIG_PATH)],
        cwd=CONFIG_PATH.parent.parent, capture_output=True, check=False,
    )
    tracked = subprocess.run(
        ['git', 'ls-files', '--error-unmatch', '--', str(CONFIG_PATH)],
        cwd=CONFIG_PATH.parent.parent, capture_output=True, check=False,
    )
    if ignored.returncode != 0 or tracked.returncode != 1:
        print('Cannot confirm the secret file is ignored and untracked. Setup stopped.')
        return 1
    print('The token will be stored locally in backend/.cloudflare.local.json (not encrypted).')
    print('It will not be printed, sent to Flutter, or committed to Git. No API calls will be made.')
    if args.replace and input('Replace the existing local token? Type YES: ').strip() != 'YES':
        print('Cancelled; existing file unchanged.')
        return 1
    with warnings.catch_warnings():
        # Never fall back to echoed input on unsupported terminals.
        warnings.simplefilter('error', getpass.GetPassWarning)
        token = getpass.getpass('Paste Workers AI token (input hidden), then press Enter: ')
    save_config(CONFIG_PATH, ACCOUNT_ID, token, replace=args.replace)
    print('Saved. Generation remains disabled. Do not share the credential file.')
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (KeyboardInterrupt, EOFError):
        print('\nCancelled.')
        sys.exit(1)
    except (OSError, ValueError, getpass.GetPassWarning):
        print('Setup could not complete. No credential values are displayed. Check the terminal and file permissions.')
        sys.exit(1)
