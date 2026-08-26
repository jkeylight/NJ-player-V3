#!/usr/bin/env python3
"""Unit tests for NJ Player's GenCrypt encryption engine.

Run with:
    python -m pytest tests/test_gencrypt.py -v
or (no pytest installed):
    python tests/test_gencrypt.py

Requires the `cryptography` package:
    pip install cryptography
"""

import os
import sys
import tempfile

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'security'))

import gencrypt  # noqa: E402


def _roundtrip(tmp, keyfile=None):
    """Encrypt then decrypt a small file and assert the contents match."""
    src = os.path.join(tmp, 'sample.mp4')
    with open(src, 'wb') as f:
        f.write(b'hello world this is a test video payload' * 100)

    enc = gencrypt.GenCrypt()
    enc_out = os.path.join(tmp, 'sample.mp4.enc')
    enc.encrypt_file(src, 'Secret123!', output_path=enc_out, keyfile=keyfile)

    dec_out = os.path.join(tmp, 'dec.mp4')
    enc.decrypt_file(enc_out, 'Secret123!', output_path=dec_out, keyfile=keyfile)

    with open(src, 'rb') as f:
        original = f.read()
    with open(dec_out, 'rb') as f:
        decrypted = f.read()

    assert original == decrypted, "roundtrip mismatch"
    return enc_out


def test_roundtrip_no_keyfile():
    with tempfile.TemporaryDirectory() as tmp:
        _roundtrip(tmp, keyfile=None)


def test_roundtrip_with_keyfile():
    with tempfile.TemporaryDirectory() as tmp:
        kf = os.path.join(tmp, 'key.bin')
        with open(kf, 'wb') as f:
            f.write(os.urandom(64))
        _roundtrip(tmp, keyfile=open(kf, 'rb').read())


def test_wrong_password_rejected():
    with tempfile.TemporaryDirectory() as tmp:
        src = os.path.join(tmp, 'v.mp4')
        with open(src, 'wb') as f:
            f.write(b'data' * 1000)
        enc = gencrypt.GenCrypt()
        enc_out = os.path.join(tmp, 'v.mp4.enc')
        enc.encrypt_file(src, 'correct-pass', output_path=enc_out)

        raised = False
        try:
            enc.decrypt_file(enc_out, 'wrong-pass', output_path=os.path.join(tmp, 'out.mp4'))
        except ValueError:
            raised = True
        assert raised, "wrong password should raise ValueError"


def test_wrong_keyfile_rejected():
    with tempfile.TemporaryDirectory() as tmp:
        src = os.path.join(tmp, 'v.mp4')
        with open(src, 'wb') as f:
            f.write(b'data' * 1000)
        kf_enc = os.path.join(tmp, 'enc.key')
        with open(kf_enc, 'wb') as f:
            f.write(os.urandom(64))
        enc = gencrypt.GenCrypt()
        enc_out = os.path.join(tmp, 'v.mp4.enc')
        enc.encrypt_file(src, 'pw', output_path=enc_out, keyfile=open(kf_enc, 'rb').read())

        kf_wrong = os.path.join(tmp, 'wrong.key')
        with open(kf_wrong, 'wb') as f:
            f.write(os.urandom(64))
        raised = False
        try:
            enc.decrypt_file(enc_out, 'pw', output_path=os.path.join(tmp, 'out.mp4'),
                             keyfile=open(kf_wrong, 'rb').read())
        except ValueError:
            raised = True
        assert raised, "wrong keyfile should raise ValueError"


def test_corrupt_file_rejected():
    with tempfile.TemporaryDirectory() as tmp:
        src = os.path.join(tmp, 'v.mp4')
        with open(src, 'wb') as f:
            f.write(b'data' * 1000)
        enc = gencrypt.GenCrypt()
        enc_out = os.path.join(tmp, 'v.mp4.enc')
        enc.encrypt_file(src, 'pw', output_path=enc_out)
        # Corrupt a byte in the middle of the ciphertext.
        with open(enc_out, 'r+b') as f:
            f.seek(200)
            f.write(b'\xff')
        raised = False
        try:
            enc.decrypt_file(enc_out, 'pw', output_path=os.path.join(tmp, 'out.mp4'))
        except ValueError:
            raised = True
        assert raised, "corrupted ciphertext should raise ValueError"


def test_password_strength():
    weak = gencrypt.password_strength('abc')
    strong = gencrypt.password_strength('SuperSecret!2024#XyZ')
    assert weak['score'] < strong['score']
    assert weak['entropy_bits'] <= strong['entropy_bits']


def test_shred_removes_file():
    with tempfile.TemporaryDirectory() as tmp:
        path = os.path.join(tmp, 'secret.bin')
        with open(path, 'wb') as f:
            f.write(os.urandom(1024))
        shredder = gencrypt.SecureDelete()
        ok = shredder.secure_delete_quick(path, passes=1)
        assert ok
        assert not os.path.exists(path), "shredded file should not exist"


def test_encrypt_folder():
    with tempfile.TemporaryDirectory() as tmp:
        with open(os.path.join(tmp, 'a.mp4'), 'wb') as f:
            f.write(b'a' * 100)
        with open(os.path.join(tmp, 'b.mkv'), 'wb') as f:
            f.write(b'b' * 100)
        with open(os.path.join(tmp, 'notes.txt'), 'wb') as f:
            f.write(b'not a video')

        enc = gencrypt.GenCrypt()
        # Encrypt only video extensions.
        for name in ('a.mp4', 'b.mkv'):
            enc.encrypt_file(os.path.join(tmp, name), 'pw')
        # notes.txt should have no .enc.
        assert not os.path.exists(os.path.join(tmp, 'notes.txt.enc'))
        assert os.path.exists(os.path.join(tmp, 'a.mp4.enc'))
        assert os.path.exists(os.path.join(tmp, 'b.mkv.enc'))


if __name__ == '__main__':
    # Lightweight runner if pytest is unavailable.
    tests = [v for k, v in sorted(globals().items()) if k.startswith('test_')]
    for t in tests:
        t()
        print(f"PASS: {t.__name__}")
    print(f"\n{len(tests)} tests passed.")
