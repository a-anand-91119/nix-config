"""Regression checks for validation failures and staged-versus-working content."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SOURCE = Path(__file__).resolve().parents[1]


class ValidationScripts(unittest.TestCase):
    def setUp(self):
        self.scratch = tempfile.TemporaryDirectory(prefix="nix-config-validation-")
        self.addCleanup(self.scratch.cleanup)
        self.root = Path(self.scratch.name) / "repo with spaces"
        self.root.mkdir()
        self.env = os.environ.copy()
        self.env.update(GIT_CONFIG_NOSYSTEM="1", GIT_CONFIG_GLOBAL=os.devnull)
        self.run_command("git", "init", "--quiet")
        for filename in (
            "scripts/test.sh",
            "scripts/setup-hooks.sh",
            ".githooks/pre-commit",
        ):
            destination = self.root / filename
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(SOURCE / filename, destination)

    def run_command(self, *arguments, outside=False):
        return subprocess.run(
            arguments,
            cwd=self.root.parent if outside else self.root,
            env=self.env,
            capture_output=True,
            text=True,
            check=False,
        )

    def write(self, filename, content):
        (self.root / filename).write_text(content)

    def check_syntax(self):
        return self.run_command(
            "bash", str(self.root / "scripts/test.sh"), "--syntax-only", outside=True
        )

    def check_hook(self):
        return self.run_command("bash", ".githooks/pre-commit")

    def test_valid_untracked_file_from_another_directory(self):
        self.write("valid file.nix", "{ value = 1; }\n")
        result = self.check_syntax()
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_invalid_untracked_file_fails_parent_script(self):
        self.write("invalid file.nix", "{ broken =\n")
        result = self.check_syntax()
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("Syntax checks passed.", result.stdout)

    def test_invalid_staged_content_cannot_be_hidden_by_valid_working_copy(self):
        self.write("staged file.nix", "{ broken =\n")
        self.assertEqual(self.run_command("git", "add", "staged file.nix").returncode, 0)
        self.write("staged file.nix", "{ value = 1; }\n")
        result = self.check_hook()
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("Pre-commit checks passed.", result.stdout)

    def test_valid_staged_content_is_not_replaced_by_unstaged_edits(self):
        self.write("staged file.nix", "{ value = 1; }\n")
        self.assertEqual(self.run_command("git", "add", "staged file.nix").returncode, 0)
        self.write("staged file.nix", "{ broken =\n")
        result = self.check_hook()
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_hook_setup_uses_its_repository_from_another_directory(self):
        result = self.run_command(
            "bash", str(self.root / "scripts/setup-hooks.sh"), outside=True
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        setting = self.run_command("git", "config", "--local", "core.hooksPath")
        self.assertEqual(setting.stdout.strip(), ".githooks")


if __name__ == "__main__":
    unittest.main(verbosity=2)
