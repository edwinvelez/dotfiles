#!/usr/bin/env python3
import argparse
import logging
import os
import shutil
import socket
import subprocess
import sys

# Configure Logging
logging.basicConfig(
    level=logging.INFO,
    format="%(levelname)s: %(message)s"
)
logger = logging.getLogger(__name__)

class DotfilesManager:
    """
    Manages dotfiles symlinking using GNU Stow with automated hardware detection.
    """

    # Hostname to profile mapping
    # Update these values to match your specific machine hostnames
    HOSTNAME_MAP = {
        "my-desktop": "desktop",
        "my-laptop": "laptop",
    }

    def __init__(self, dry_run=False, delete=False, verbose=False):
        self.dry_run = dry_run
        self.delete = delete
        self.verbose = verbose
        self.target_home = os.path.expanduser("~")
        self.dotfiles_dir = os.path.dirname(os.path.abspath(__file__))

        if self.verbose:
            logger.setLevel(logging.DEBUG)

    def check_prerequisites(self):
        """Ensures GNU Stow is installed."""
        if not shutil.which("stow"):
            logger.error("GNU Stow is not installed. Please install it before running this script.")
            sys.exit(1)

    def _run_stow(self, package):
        """Executes the stow command for a given package."""
        action = "-D" if self.delete else "-S"
        verb = "Unstowing" if self.delete else "Stowing"

        cmd = ["stow", action, "-v", "-t", self.target_home, package]

        if self.dry_run:
            cmd.insert(1, "-n")
            logger.info(f"[DRY-RUN] Would execute: {' '.join(cmd)}")

        logger.info(f":: {verb} package: {package}")

        try:
            # We use subprocess.run with check=True to catch errors
            # We don't capture stdout/stderr to allow 'stow -v' to print directly to terminal
            subprocess.run(cmd, check=True, cwd=self.dotfiles_dir)
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to {verb.lower()} package '{package}': {e}")
            if not self.delete: # If we're installing, we might want to stop on error
                 sys.exit(1)

    def detect_profile(self):
        """
        Detects the appropriate hardware profile using hostnamectl, hostname mapping, or hardware features.
        """
        # Check hostnamectl chassis (Systemd standard)
        try:
            chassis = subprocess.check_output(["hostnamectl", "chassis"], stderr=subprocess.DEVNULL).decode().strip()
            if chassis in ["laptop", "desktop"]:
                logger.info(f"Auto-detected '{chassis}' profile via hostnamectl.")
                return chassis
        except (subprocess.CalledProcessError, FileNotFoundError):
            pass

        # Check explicit hostname map
        hostname = socket.gethostname()
        if hostname in self.HOSTNAME_MAP:
            logger.info(f"Matched profile '{self.HOSTNAME_MAP[hostname]}' from hostname map.")
            return self.HOSTNAME_MAP[hostname]

        # Heuristic fallback: Check for battery
        try:
            if os.path.exists("/sys/class/power_supply/BAT0"):
                logger.info("Auto-detected laptop profile via battery presence.")
                return "laptop"
        except Exception:
            pass

        return None

    def execute(self, manual_profile=None):
        """Main execution flow."""
        self.check_prerequisites()

        # Process Base Layers (Always processed)
        logger.info("==> Processing Base Layers")
        self._run_stow("common")
        self._run_stow("bin")

        # Process Hardware Layers
        if self.delete:
            # In delete mode, we attempt to unstow all possible hardware profiles to be clean
            logger.info("==> Unstowing all Hardware Profiles (Factory Reset)")
            self._run_stow("desktop")
            self._run_stow("laptop")
        else:
            profile = manual_profile or self.detect_profile()
            if profile:
                logger.info(f"==> Applying Hardware Profile: {profile}")
                self._run_stow(profile)
            else:
                logger.info("==> Skipping hardware-specific layer.")

def main():
    parser = argparse.ArgumentParser(
        description="Edwin Velez Dotfiles Manager",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 stow-setup.py              # Apply default configuration (auto-detect)
  python3 stow-setup.py --dry-run    # Preview changes without applying
  python3 stow-setup.py --delete     # Remove all symlinks
  python3 stow-setup.py --profile desktop  # Force desktop profile
        """
    )

    parser.add_argument("-n", "--dry-run", action="store_true", help="Simulate the operation")
    parser.add_argument("-d", "--delete", action="store_true", help="Unstow (remove) all packages")
    parser.add_argument("-p", "--profile", choices=["desktop", "laptop"], help="Manually specify hardware profile")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose output")

    args = parser.parse_args()

    manager = DotfilesManager(
        dry_run=args.dry_run,
        delete=args.delete,
        verbose=args.verbose
    )

    try:
        manager.execute(manual_profile=args.profile)
        logger.info("Success! Operation complete.")
    except KeyboardInterrupt:
        logger.warning("Operation cancelled by user.")
        sys.exit(1)

if __name__ == "__main__":
    main()
