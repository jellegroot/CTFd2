import pyotp
import qrcode
import io
import base64
from flask import Blueprint, render_template, request, session, redirect, url_for, jsonify
from flask import current_app as app

from CTFd.models import Users, Admins, db
from CTFd.utils.decorators import authed_only
from CTFd.utils.user import get_current_user
from CTFd.utils import get_config


# Add MFA columns to both Users and Admins tables
def add_mfa_columns():
    """Add MFA columns to Users and Admins tables if they don't exist"""
    try:
        inspector = db.inspect(db.engine)
        
        # Get list of existing tables
        tables = inspector.get_table_names()
        
        # Check Users table
        if 'users' in tables:
            users_columns = [col['name'] for col in inspector.get_columns('users')]
            if 'mfa_secret' not in users_columns:
                with db.engine.connect() as conn:
                    conn.execute(db.text("ALTER TABLE users ADD COLUMN mfa_secret VARCHAR(32)"))
                    conn.execute(db.text("ALTER TABLE users ADD COLUMN mfa_enabled BOOLEAN DEFAULT 0"))
                    conn.commit()
        
        # Check Admins table  
        if 'admins' in tables:
            admins_columns = [col['name'] for col in inspector.get_columns('admins')]
            if 'mfa_secret' not in admins_columns:
                with db.engine.connect() as conn:
                    conn.execute(db.text("ALTER TABLE admins ADD COLUMN mfa_secret VARCHAR(32)"))
                    conn.execute(db.text("ALTER TABLE admins ADD COLUMN mfa_enabled BOOLEAN DEFAULT 0"))
                    conn.commit()
    except Exception as e:
        # If tables don't exist yet, they'll be created by CTFd's migration system
        print(f"MFA Plugin: Could not add columns yet (tables may not exist): {e}")
        pass



def create_mfa_blueprint():
    """Create the MFA blueprint with routes"""
    blueprint = Blueprint(
        "mfa",
        __name__,
        template_folder="templates",
        static_folder="assets",
        url_prefix="/mfa"
    )

    @blueprint.route("/setup", methods=["GET"])
    @authed_only
    def setup():
        """Display MFA setup page with QR code"""
        user = get_current_user()
        
        # Read directly from database
        from sqlalchemy import text
        result = db.session.execute(
            text("SELECT mfa_secret, mfa_enabled FROM users WHERE id = :user_id"),
            {"user_id": user.id}
        ).fetchone()
        
        mfa_secret = result[0] if result else None
        mfa_enabled = result[1] if result else False
        
        # Generate a new secret if user doesn't have one
        if not mfa_secret:
            secret = pyotp.random_base32()
            # Update via SQL to ensure it's saved properly
            db.session.execute(
                text("UPDATE users SET mfa_secret = :secret WHERE id = :user_id"),
                {"secret": secret, "user_id": user.id}
            )
            db.session.commit()
        else:
            secret = mfa_secret
        
        # Generate QR code
        totp = pyotp.TOTP(secret)
        # Use "Cybermeister - CTFd" as issuer and username as account name
        provisioning_uri = totp.provisioning_uri(
            name=user.name,
            issuer_name="Cybermeister - CTFd"
        )
        
        # Create QR code image
        qr = qrcode.QRCode(version=1, box_size=10, border=5)
        qr.add_data(provisioning_uri)
        qr.make(fit=True)
        img = qr.make_image(fill_color="black", back_color="white")
        
        # Convert to base64
        buffer = io.BytesIO()
        img.save(buffer, format="PNG")
        buffer.seek(0)
        qr_code = base64.b64encode(buffer.getvalue()).decode()
        
        return render_template(
            "mfa_setup.html",
            secret=secret,
            qr_code=qr_code,
            mfa_enabled=mfa_enabled,
            nonce=session.get("nonce")
        )

    @blueprint.route("/verify", methods=["POST"])
    @authed_only
    def verify_setup():
        """Verify MFA code and enable MFA"""
        user = get_current_user()
        code = request.form.get("code", "").strip()
        
        # Read directly from database
        from sqlalchemy import text
        result = db.session.execute(
            text("SELECT mfa_secret FROM users WHERE id = :user_id"),
            {"user_id": user.id}
        ).fetchone()
        
        if not result or not result[0]:
            return jsonify({"success": False, "message": "No MFA secret found"}), 400
        
        mfa_secret = result[0]
        
        totp = pyotp.TOTP(mfa_secret)
        
        if totp.verify(code, valid_window=1):
            # Update via SQL to ensure it's saved properly
            from sqlalchemy import text
            db.session.execute(
                text("UPDATE users SET mfa_enabled = 1 WHERE id = :user_id"),
                {"user_id": user.id}
            )
            db.session.commit()
            return jsonify({"success": True, "message": "MFA enabled successfully!"})
        else:
            return jsonify({"success": False, "message": "Invalid code. Please try again."}), 400

    @blueprint.route("/disable", methods=["POST"])
    @authed_only
    def disable():
        """Disable MFA for the current user"""
        user = get_current_user()
        code = request.form.get("code", "").strip()
        password = request.form.get("password", "")
        
        # Verify password
        if not user.verify_password(password):
            return jsonify({"success": False, "message": "Invalid password"}), 400
        
        # Verify MFA code
        mfa_secret = getattr(user, 'mfa_secret', None)
        if mfa_secret:
            totp = pyotp.TOTP(mfa_secret)
            if not totp.verify(code, valid_window=1):
                return jsonify({"success": False, "message": "Invalid MFA code"}), 400
        
        user.mfa_enabled = False
        user.mfa_secret = None
        db.session.commit()
        
        return jsonify({"success": True, "message": "MFA disabled successfully!"})

    @blueprint.route("/verify-login", methods=["GET", "POST"])
    def verify_login():
        """Verify MFA code during login"""
        if request.method == "GET":
            # Show MFA verification page
            if "mfa_user_id" not in session:
                return redirect(url_for("auth.login"))
            return render_template("mfa_verify.html", nonce=session.get("nonce"))
        
        # POST: Verify the code
        user_id = session.get("mfa_user_id")
        if not user_id:
            return jsonify({"success": False, "message": "No pending login"}), 400
        
        # Query MFA status directly from database using SQL
        from sqlalchemy import text
        result = db.session.execute(
            text("SELECT mfa_enabled, mfa_secret FROM users WHERE id = :user_id"),
            {"user_id": user_id}
        ).fetchone()
        
        if not result:
            return jsonify({"success": False, "message": "Invalid MFA state"}), 400
        
        mfa_enabled, mfa_secret = result
        
        if not mfa_enabled or not mfa_secret:
            return jsonify({"success": False, "message": "Invalid MFA state"}), 400
        
        code = request.form.get("code", "").strip()
        totp = pyotp.TOTP(mfa_secret)
        
        if totp.verify(code, valid_window=1):
            # Complete the login
            session["id"] = user_id
            session["nonce"] = session.get("nonce", "")
            session.pop("mfa_user_id", None)
            
            return jsonify({"success": True, "redirect": url_for("challenges.listing")})
        else:
            return jsonify({"success": False, "message": "Invalid code. Please try again."}), 400

    return blueprint


def load(app):
    """Plugin load function"""
    # Add MFA columns to database tables
    with app.app_context():
        add_mfa_columns()
    
    # Register blueprint
    mfa_blueprint = create_mfa_blueprint()
    app.register_blueprint(mfa_blueprint)
    
    # Hook into successful logins using after_request
    @app.after_request
    def check_mfa_after_login(response):
        # Only intercept successful login redirects
        if request.endpoint == 'auth.login' and request.method == 'POST' and response.status_code == 302:
            if session.get("id"):
                user_id = session["id"]
                
                # Read MFA status directly from database
                from sqlalchemy import text
                result = db.session.execute(
                    text("SELECT mfa_enabled FROM users WHERE id = :user_id"),
                    {"user_id": user_id}
                ).fetchone()
                
                mfa_enabled = result[0] if result and result[0] else False
                
                if mfa_enabled:
                    # Store user ID temporarily and remove from session
                    session["mfa_user_id"] = user_id
                    session.pop("id")
                    # Change redirect to MFA verification
                    response.headers['Location'] = url_for("mfa.verify_login")
        
        return response
    
    print("MFA Plugin loaded successfully")
