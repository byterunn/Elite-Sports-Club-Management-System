"""
Elite Sports Club – Flask Application Entry Point
Run: python app.py
"""

from flask import Flask, session, redirect, url_for, request, flash
from functools import wraps
import config

# ── Import blueprints ─────────────────────────────────────────────
from routes.auth import auth_bp
from routes.dashboard import dashboard_bp
from routes.members import members_bp
from routes.sports import sports_bp
from routes.coaches import coaches_bp
from routes.facilities import facilities_bp
from routes.enrollments import enrollments_bp
from routes.bookings import bookings_bp
from routes.membership_plans import plans_bp
from routes.reports import reports_bp


def create_app():
    app = Flask(__name__)
    app.secret_key = config.SECRET_KEY

    # ── Register blueprints ───────────────────────────────────────
    app.register_blueprint(auth_bp)
    app.register_blueprint(dashboard_bp)
    app.register_blueprint(members_bp)
    app.register_blueprint(sports_bp)
    app.register_blueprint(coaches_bp)
    app.register_blueprint(facilities_bp)
    app.register_blueprint(enrollments_bp)
    app.register_blueprint(bookings_bp)
    app.register_blueprint(plans_bp)
    app.register_blueprint(reports_bp)

    # ── Login-required middleware ─────────────────────────────────
    @app.before_request
    def require_login():
        allowed = ("auth.login", "static")
        if not session.get("logged_in"):
            if request.endpoint and not any(request.endpoint.startswith(a) for a in allowed):
                return redirect(url_for("auth.login"))

    # ── Friendly error handlers for DB failures ───────────────────
    @app.errorhandler(ConnectionError)
    def handle_db_connection_error(e):
        flash(f"Database connection error: {e}", "danger")
        if session.get("logged_in"):
            return redirect(url_for("dashboard.index"))
        return redirect(url_for("auth.login"))

    @app.errorhandler(RuntimeError)
    def handle_runtime_error(e):
        flash(f"Database error: {e}", "danger")
        return redirect(request.referrer or url_for("dashboard.index"))

    @app.errorhandler(500)
    def handle_internal_error(e):
        flash("An unexpected error occurred. Please try again.", "danger")
        if session.get("logged_in"):
            return redirect(url_for("dashboard.index"))
        return redirect(url_for("auth.login"))

    return app


if __name__ == "__main__":
    app = create_app()
    app.run(debug=config.DEBUG, host="0.0.0.0", port=5000)
