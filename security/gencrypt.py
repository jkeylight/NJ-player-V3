#!/usr/bin/env python3
"""
NJ PLAYER 3.0 — GENCRYPT ENCRYPTION ENGINE
AES-256-GCM with PBKDF2 key derivation
Streaming encryption for large video files
"""

import os
import sys
import struct
import hashlib
import secrets
from pathlib import Path

try:
    from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
    from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
    from cryptography.hazmat.primitives import hashes
    from cryptography.hazmat.backends import default_backend
except ImportError:
    print("ERROR: cryptography library required")
    print("Install: pip install cryptography")
    sys.exit(1)


class GenCrypt:
    """AES-256-GCM file encryption with streaming support"""

    # File format constants
    MAGIC_BYTES = b'GENC'
    VERSION = 1
    HEADER_SIZE = 128
    CHUNK_SIZE = 1024 * 1024  # 1MB chunks

    # PBKDF2 parameters
    KDF_ITERATIONS = 100_000
    SALT_SIZE = 32
    IV_SIZE = 12
    KEY_SIZE = 32
    TAG_SIZE = 16

    def __init__(self):
        self.backend = default_backend()

    def _derive_key(self, password: str, salt: bytes) -> bytes:
        """Derive encryption key from password using PBKDF2"""
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=self.KEY_SIZE,
            salt=salt,
            iterations=self.KDF_ITERATIONS,
            backend=self.backend
        )
        return kdf.derive(password.encode('utf-8'))

    def _derive_key_concat(self, password: str, salt: bytes, keyfile: bytes) -> bytes:
        """Derive a key from the password combined with a keyfile's material.

        The password and keyfile bytes are concatenated before PBKDF2, and the
        derived key is XORed with a SHA-256 digest of the keyfile data. This means
        BOTH the password and the keyfile are required to derive the correct key
        (matching the behaviour of e.g. VeraCrypt/TrueCrypt keyfiles).
        """
        combined = password.encode('utf-8') + b'|NJ-KEYFILE|' + keyfile
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=self.KEY_SIZE,
            salt=salt,
            iterations=self.KDF_ITERATIONS,
            backend=self.backend
        )
        base_key = kdf.derive(combined)
        # Mix in the keyfile digest so the keyfile is mandatory.
        keyfile_digest = hashlib.sha256(keyfile).digest()
        return bytes(a ^ b for a, b in zip(base_key, keyfile_digest[:self.KEY_SIZE]))

    def _create_header(self, original_name: str, file_size: int, file_type: int) -> bytes:
        """Create 128-byte encrypted file header"""
        # Truncate or pad filename to 64 bytes
        name_bytes = original_name.encode('utf-8')[:64]
        name_bytes = name_bytes.ljust(64, b'\x00')

        salt = secrets.token_bytes(self.SALT_SIZE)
        iv = secrets.token_bytes(self.IV_SIZE)

        header = struct.pack(
            '>4sH32s12s64sBQ5s',  # Big-endian format
            self.MAGIC_BYTES,      # 4 bytes: Magic
            self.VERSION,          # 2 bytes: Version
            salt,                  # 32 bytes: Salt
            iv,                    # 12 bytes: IV
            name_bytes,            # 64 bytes: Original filename
            file_type,             # 1 byte: File type (0=video, 1=image)
            file_size,             # 8 bytes: Original size
            b'\x00' * 5           # 5 bytes: Reserved
        )

        return header, salt, iv

    def _resolve_password_key(self, password: str, keyfile: bytes) -> bytes:
        """Return the raw password material, conditionally concatenated with a keyfile.

        Returns (plain_password, keyfile_bytes). If a keyfile is provided, the key
        derivation combines the password and the keyfile.
        """
        return password, keyfile

    def encrypt_file(self, input_path: str, password: str,
                     output_path: str = None, progress_callback=None,
                     delete_original: bool = False, keyfile: bytes = None) -> str:
        """
        Encrypt a file with AES-256-GCM

        Args:
            input_path: Path to input file
            password: Encryption password
            output_path: Output path (defaults to input_path + '.enc')
            progress_callback: Function(current_bytes, total_bytes)
            delete_original: If True, secure-delete original after encryption
            keyfile: Raw keyfile bytes (optional). When provided, both the
                     password and the keyfile are required to decrypt.

        Returns:
            Path to encrypted file
        """
        input_path = str(Path(input_path))

        if output_path is None:
            output_path = input_path + '.enc'
        else:
            output_path = str(Path(output_path))

        # Get original file info
        original_name = os.path.basename(input_path)
        file_size = os.path.getsize(input_path)

        # Determine file type
        ext = Path(input_path).suffix.lower()
        video_exts = {'.mp4', '.mkv', '.avi', '.mov', '.webm', '.flv', '.wmv', '.m4v', '.ts', '.mts'}
        image_exts = {'.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.tiff', '.tif'}

        if ext in video_exts:
            file_type = 0
        elif ext in image_exts:
            file_type = 1
        else:
            file_type = 2  # Other

        # Create header
        header, salt, iv = self._create_header(original_name, file_size, file_type)

        # Derive key (optionally combined with a keyfile)
        if keyfile:
            key = self._derive_key_concat(password, salt, keyfile)
        else:
            key = self._derive_key(password, salt)

        # Create cipher
        cipher = Cipher(
            algorithms.AES(key),
            modes.GCM(iv),
            backend=self.backend
        )
        encryptor = cipher.encryptor()

        # Write encrypted file
        total_written = 0

        with open(input_path, 'rb') as fin, open(output_path, 'wb') as fout:
            # Write header
            fout.write(header)

            # Encrypt in chunks
            while True:
                chunk = fin.read(self.CHUNK_SIZE)
                if not chunk:
                    break

                encrypted_chunk = encryptor.update(chunk)
                fout.write(encrypted_chunk)

                total_written += len(chunk)

                if progress_callback:
                    progress_callback(total_written, file_size)

            # Finalize and write authentication tag
            encryptor.finalize()
            fout.write(encryptor.tag)

        # Verify encrypted file
        encrypted_size = os.path.getsize(output_path)
        expected_size = self.HEADER_SIZE + file_size + self.TAG_SIZE

        if encrypted_size != expected_size:
            print(f"WARNING: Encrypted size mismatch! Expected {expected_size}, got {encrypted_size}")

        print(f"[OK] Encrypted: {original_name}")
        print(f"  Original: {self._format_size(file_size)}")
        print(f"  Encrypted: {self._format_size(encrypted_size)}")
        print(f"  Output: {output_path}")

        # Optional: Delete original
        if delete_original:
            print("\nSecure-deleting original file...")
            shredder = SecureDelete()
            shredder.secure_delete_35(input_path)

        return output_path

    def decrypt_file(self, input_path: str, password: str,
                     output_path: str = None, progress_callback=None,
                     keyfile: bytes = None) -> str:
        """
        Decrypt a file encrypted with GenCrypt

        Args:
            input_path: Path to encrypted file
            password: Decryption password
            output_path: Output path (defaults to original filename)
            progress_callback: Function(current_bytes, total_bytes)
            keyfile: Raw keyfile bytes (optional). Must match the keyfile used
                     at encryption time.

        Returns:
            Path to decrypted file
        """
        input_path = str(Path(input_path))

        with open(input_path, 'rb') as fin:
            # Read header
            header = fin.read(self.HEADER_SIZE)

            if len(header) != self.HEADER_SIZE:
                raise ValueError("Invalid encrypted file: header too short")

            # Parse header
            magic, version, salt, iv, name_bytes, file_type, file_size, reserved = struct.unpack(
                '>4sH32s12s64sBQ5s', header
            )

            if magic != self.MAGIC_BYTES:
                raise ValueError("Invalid encrypted file: bad magic bytes")

            if version != self.VERSION:
                raise ValueError(f"Unsupported version: {version}")

            # Decode filename
            original_name = name_bytes.rstrip(b'\x00').decode('utf-8', errors='replace')

            # Determine output path
            if output_path is None:
                output_dir = os.path.dirname(input_path)
                output_path = os.path.join(output_dir, original_name)
            else:
                output_path = str(Path(output_path))

            # Derive key (optionally combined with a keyfile)
            if keyfile:
                key = self._derive_key_concat(password, salt, keyfile)
            else:
                key = self._derive_key(password, salt)

            # Calculate encrypted data size
            total_file_size = os.path.getsize(input_path)
            encrypted_data_size = total_file_size - self.HEADER_SIZE - self.TAG_SIZE

            # Read auth tag (at the end of file)
            fin.seek(total_file_size - self.TAG_SIZE)
            auth_tag = fin.read(self.TAG_SIZE)

        # Create cipher with tag for GCM verification
        cipher = Cipher(
            algorithms.AES(key),
            modes.GCM(iv, auth_tag),
            backend=self.backend
        )
        decryptor = cipher.decryptor()

        # Decrypt in chunks
        total_read = 0

        with open(input_path, 'rb') as fin:
            fin.seek(self.HEADER_SIZE)  # Skip header

            with open(output_path, 'wb') as fout:
                while total_read < encrypted_data_size:
                    chunk = fin.read(min(self.CHUNK_SIZE, encrypted_data_size - total_read))
                    if not chunk:
                        break

                    decrypted_chunk = decryptor.update(chunk)
                    fout.write(decrypted_chunk)

                    total_read += len(chunk)

                    if progress_callback:
                        progress_callback(total_read, encrypted_data_size)

            try:
                decryptor.finalize()
                print(f"[OK] Decrypted: {original_name}")
                print(f"  Output: {output_path}")
            except Exception as e:
                # Authentication failed - wrong password or corrupted file
                os.remove(output_path)  # Delete partial decrypted file
                raise ValueError("Decryption failed: Incorrect password or corrupted file") from e

        return output_path

    def _format_size(self, size_bytes: int) -> str:
        """Format bytes to human-readable string"""
        for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
            if size_bytes < 1024.0:
                return f"{size_bytes:.1f} {unit}"
            size_bytes /= 1024.0
        return f"{size_bytes:.1f} PB"


class SecureDelete:
    """35-pass Gutmann secure deletion"""

    GUTMANN_PATTERNS = [
        b'\x55', b'\xAA', b'\x92\x49\x24', b'\x49\x24\x92',
        b'\x24\x92\x49', b'\x00', b'\x11', b'\x22', b'\x33',
        b'\x44', b'\x55', b'\x66', b'\x77', b'\x88', b'\x99',
        b'\xAA', b'\xBB', b'\xCC', b'\xDD', b'\xEE', b'\xFF',
        b'\x92\x49\x24', b'\x49\x24\x92', b'\x24\x92\x49',
        b'\x6D\xB6\xDB', b'\xB6\xDB\x6D', b'\xDB\x6D\xB6',
        None, None, None, None,  # Random passes
        b'\x6D\xB6\x53', b'\xB6\xDB\x6D', b'\xDB\x6D\xB6',
        b'\x00'
    ]

    def __init__(self):
        self.cancel_flag = False
        self.CHUNK_SIZE = 1024 * 1024  # 1MB

    def cancel(self):
        """Cancel ongoing deletion"""
        self.cancel_flag = True

    def secure_delete_35(self, filepath: str, progress_callback=None) -> bool:
        """
        Perform 35-pass Gutmann secure deletion

        Args:
            filepath: Path to file to shred
            progress_callback: Function(pass_num, total_passes)

        Returns:
            True if successful, False if cancelled
        """
        filepath = str(Path(filepath))

        if not os.path.exists(filepath):
            print(f"File not found: {filepath}")
            return False

        file_size = os.path.getsize(filepath)
        self.cancel_flag = False

        print(f"\n[LOCK] Secure Deleting: {os.path.basename(filepath)}")
        print(f"   Size: {self._format_size(file_size)}")
        print(f"   Method: 35-Pass Gutmann")
        print()

        for pass_num in range(35):
            if self.cancel_flag:
                print("\n[!] Deletion cancelled")
                return False

            with open(filepath, 'r+b', buffering=0) as f:
                pattern = self.GUTMANN_PATTERNS[pass_num]

                if pattern is None:
                    # Random data pass
                    self._write_random(f, file_size)
                else:
                    # Pattern pass
                    self._write_pattern(f, pattern, file_size)

                # Force write to disk
                f.flush()
                os.fsync(f.fileno())

            # Show progress
            progress = (pass_num + 1) / 35 * 100
            bar_length = 20
            filled = int(bar_length * (pass_num + 1) / 35)
            bar = '#' * filled + '-' * (bar_length - filled)

            print(f"\r   Pass {pass_num + 1:2d}/35 [{bar}] {progress:5.1f}%", end='', flush=True)

            if progress_callback:
                progress_callback(pass_num + 1, 35)

        # Final: Truncate and delete
        with open(filepath, 'wb') as f:
            f.truncate(0)

        os.remove(filepath)

        print(f"\n\n[OK] File securely deleted")
        return True

    def secure_delete_quick(self, filepath: str, passes: int = 3) -> bool:
        """
        Perform quick secure deletion (1-7 passes)

        Args:
            filepath: Path to file
            passes: Number of passes (1, 3, or 7)
        """
        filepath = str(Path(filepath))

        if not os.path.exists(filepath):
            return False

        file_size = os.path.getsize(filepath)
        self.cancel_flag = False

        for pass_num in range(passes):
            if self.cancel_flag:
                return False

            with open(filepath, 'r+b', buffering=0) as f:
                if pass_num == 0:
                    self._write_pattern(f, b'\x00', file_size)
                elif pass_num == 1:
                    self._write_pattern(f, b'\xFF', file_size)
                else:
                    self._write_random(f, file_size)

                f.flush()
                os.fsync(f.fileno())

        with open(filepath, 'wb') as f:
            f.truncate(0)

        os.remove(filepath)
        return True

    def _write_pattern(self, f, pattern: bytes, size: int):
        """Write pattern repeatedly to file"""
        pattern = (pattern * (size // len(pattern) + 1))[:size]
        f.seek(0)

        # Write in chunks
        written = 0
        while written < size:
            chunk = pattern[written:written + self.CHUNK_SIZE]
            if not chunk:
                break
            f.write(chunk)
            written += len(chunk)

    def _write_random(self, f, size: int):
        """Write cryptographically secure random data"""
        f.seek(0)

        written = 0
        while written < size:
            chunk_size = min(self.CHUNK_SIZE, size - written)
            f.write(os.urandom(chunk_size))
            written += chunk_size

    def _format_size(self, size_bytes: int) -> str:
        """Format bytes to human-readable"""
        for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
            if size_bytes < 1024.0:
                return f"{size_bytes:.1f} {unit}"
            size_bytes /= 1024.0
        return f"{size_bytes:.1f} PB"


# ============================================
# PASSWORD STRENGTH
# ============================================

def password_strength(password: str) -> dict:
    """Estimate password strength and return a summary dict.

    Returns:
        dict with keys: score (0-4), label, entropy_bits, suggestions (list[str])
    """
    import re

    if not password:
        return {"score": 0, "label": "Empty", "entropy_bits": 0, "suggestions": ["Enter a password"]}

    length = len(password)
    lower = bool(re.search(r'[a-z]', password))
    upper = bool(re.search(r'[A-Z]', password))
    digit = bool(re.search(r'\d', password))
    symbol = bool(re.search(r'[^A-Za-z0-9]', password))

    # Estimate entropy from character-pool size.
    pool = 0
    if lower:
        pool += 26
    if upper:
        pool += 26
    if digit:
        pool += 10
    if symbol:
        pool += 33
    if pool == 0:
        pool = 10  # e.g. all spaces/control chars

    entropy = int(length * (pool.bit_length() or 1))

    # Heuristic score 0-4.
    score = 0
    if length >= 8:
        score = 1
    if length >= 10 and (upper or digit) and (lower or symbol):
        score = 2
    if length >= 14 and upper and lower and digit and symbol:
        score = 3
    if length >= 18 and upper and lower and digit and symbol:
        score = 4

    labels = ["Very weak", "Weak", "Fair", "Good", "Strong"]
    suggestions = []
    if length < 8:
        suggestions.append("Use at least 8 characters")
    if not (upper and lower):
        suggestions.append("Mix upper and lower case")
    if not digit:
        suggestions.append("Add numbers")
    if not symbol:
        suggestions.append("Add symbols")
    if len(set(password)) < 5:
        suggestions.append("Avoid repeated characters")

    return {
        "score": score,
        "label": labels[score],
        "entropy_bits": entropy,
        "suggestions": suggestions,
    }


# ============================================
# COMMAND LINE INTERFACE
# ============================================

def main():
    """Command-line interface for GenCrypt"""
    import argparse

    parser = argparse.ArgumentParser(
        description='NJ Player 3.0 — GenCrypt Encryption Engine',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  Encrypt a video:
    python gencrypt.py encrypt video.mp4 --password "MySecret123"

  Decrypt a video:
    python gencrypt.py decrypt video.mp4.enc --password "MySecret123"

  Encrypt and delete original:
    python gencrypt.py encrypt video.mp4 --password "MySecret123" --delete-original

  Secure delete a file:
    python gencrypt.py shred secret.mp4
        """
    )

    subparsers = parser.add_subparsers(dest='command', help='Command to execute')

    # Encrypt command
    encrypt_parser = subparsers.add_parser('encrypt', help='Encrypt a file')
    encrypt_parser.add_argument('input', help='Input file path')
    encrypt_parser.add_argument('--password', required=True, help='Encryption password')
    encrypt_parser.add_argument('--output', help='Output file path (default: input.enc)')
    encrypt_parser.add_argument('--delete-original', action='store_true',
                                help='Secure-delete original after encryption')
    encrypt_parser.add_argument('--keyfile', help='Path to keyfile (optional, added entropy)')

    # Encrypt-folder command
    enc_folder_parser = subparsers.add_parser('encrypt-folder', help='Encrypt every file in a folder')
    enc_folder_parser.add_argument('input', help='Folder containing files to encrypt')
    enc_folder_parser.add_argument('--password', required=True, help='Encryption password')
    enc_folder_parser.add_argument('--extensions', help='Comma-separated extensions to include (default: videos+images)')
    enc_folder_parser.add_argument('--delete-original', action='store_true',
                                   help='Secure-delete originals after encryption')
    enc_folder_parser.add_argument('--keyfile', help='Path to keyfile (optional)')

    # Decrypt command
    decrypt_parser = subparsers.add_parser('decrypt', help='Decrypt a file')
    decrypt_parser.add_argument('input', help='Encrypted file path')
    decrypt_parser.add_argument('--password', required=True, help='Decryption password')
    decrypt_parser.add_argument('--output', help='Output file path')
    decrypt_parser.add_argument('--keyfile', help='Path to keyfile (must match encryption)')

    # Shred command
    shred_parser = subparsers.add_parser('shred', help='Secure-delete a file')
    shred_parser.add_argument('input', help='File to shred')
    shred_parser.add_argument('--passes', type=int, default=35, choices=[1, 3, 7, 35],
                              help='Number of passes (default: 35)')

    # Strength command
    strength_parser = subparsers.add_parser('strength', help='Check password strength')
    strength_parser.add_argument('password', help='Password to evaluate')

    args = parser.parse_args()

    if args.command is None:
        parser.print_help()
        return

    gencrypt = GenCrypt()

    def _load_keyfile(path):
        if not path:
            return None
        return Path(path).read_bytes()

    if args.command == 'encrypt':
        def progress(current, total):
            percent = (current / total) * 100 if total > 0 else 0
            print(f"\r   Encrypting: {percent:.1f}%", end='', flush=True)

        gencrypt.encrypt_file(
            args.input,
            args.password,
            args.output,
            progress_callback=progress,
            delete_original=args.delete_original,
            keyfile=_load_keyfile(args.keyfile)
        )
        print()

    elif args.command == 'encrypt-folder':
        folder = Path(args.input)
        if not folder.is_dir():
            print(f"[FAIL] Not a folder: {folder}")
            sys.exit(1)

        video_exts = {'.mp4', '.mkv', '.avi', '.mov', '.webm', '.flv', '.wmv', '.m4v', '.ts', '.mts'}
        image_exts = {'.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.tiff', '.tif'}
        if args.extensions:
            wanted = {e.strip().lower() if e.strip().startswith('.') else '.' + e.strip().lower()
                      for e in args.extensions.split(',')}
        else:
            wanted = video_exts | image_exts

        files = [str(p) for p in folder.iterdir() if p.is_file() and p.suffix.lower() in wanted]
        if not files:
            print(f"[SKIP] No matching files in {folder}")
            return

        print(f"Encrypting {len(files)} file(s) in {folder}...")
        for i, f in enumerate(files, 1):
            print(f"\n[{i}/{len(files)}] {Path(f).name}")
            gencrypt.encrypt_file(
                f, args.password,
                progress_callback=lambda c, t: print("\r   Encrypting: {:.1f}%".format(
                    (c / t) * 100 if t > 0 else 0), end='', flush=True),
                delete_original=args.delete_original,
                keyfile=_load_keyfile(args.keyfile)
            )
        print("\n[OK] Folder encryption complete")

    elif args.command == 'decrypt':
        def progress(current, total):
            percent = (current / total) * 100 if total > 0 else 0
            print(f"\r   Decrypting: {percent:.1f}%", end='', flush=True)

        try:
            gencrypt.decrypt_file(
                args.input,
                args.password,
                args.output,
                progress_callback=progress,
                keyfile=_load_keyfile(args.keyfile)
            )
            print()
        except ValueError as e:
            print(f"\n[FAIL] {e}")
            sys.exit(1)

    elif args.command == 'shred':
        shredder = SecureDelete()

        def progress(pass_num, total):
            percent = (pass_num / total) * 100
            print(f"\r   Pass {pass_num}/{total} ({percent:.1f}%)", end='', flush=True)

        if args.passes == 35:
            shredder.secure_delete_35(args.input, progress_callback=progress)
        else:
            shredder.secure_delete_quick(args.input, passes=args.passes)

        print()

    elif args.command == 'strength':
        summary = password_strength(args.password)
        print(f"Score: {summary['score']}/4 ({summary['label']})")
        print(f"Entropy: ~{summary['entropy_bits']} bits")
        if summary['suggestions']:
            print("Suggestions:")
            for s in summary['suggestions']:
                print(f"  - {s}")


if __name__ == '__main__':
    main()
