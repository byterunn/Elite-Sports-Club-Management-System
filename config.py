"""
Configuration for the Elite Sports Club application.
Edit the values below to match your MySQL setup.
"""

# ── MySQL Connection ──────────────────────────────────────────────
MYSQL_HOST = "localhost"
MYSQL_PORT = 3306
MYSQL_USER = "root"
MYSQL_PASSWORD = "Darshan@21"
MYSQL_DATABASE = "elite_sports_club"

# ── Flask ─────────────────────────────────────────────────────────
SECRET_KEY = "elite-sports-club-secret-key-change-me"
DEBUG = True

# ── Admin credentials (simple auth) ──────────────────────────────
ADMIN_USERNAME = "admin"
ADMIN_PASSWORD = "admin"
