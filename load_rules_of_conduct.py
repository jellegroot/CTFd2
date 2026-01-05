#!/usr/bin/env python
"""
Load CSS from file into CTFd database during startup
"""
import os
from CTFd import create_app
from CTFd.models import db, Configs
from CTFd.utils import set_config

def load_rules_of_conduct():
    """Load cybermeister CSS, header and footer into the database"""
    app = create_app()
    
    with app.app_context():
        rules_of_conduct = "CTFd/themes/core/templates/rules_of_conduct.html"

        # Read rules of conduct
        if not os.path.exists(rules_of_conduct):
            print(f"[ WARNING ] Rules of conduct file not found: {rules_of_conduct}")
            return

        with open(rules_of_conduct, 'r', encoding='utf-8') as f:
            rules_content = f.read()

        try:
            # Use set_config to properly update and clear cache
            set_config("terms_of_participation", rules_content)
            print(f"[ SUCCESS ] terms_of_participation loaded into database")

        except Exception as e:
            print(f"[ ERROR ] Failed to load rules of conduct: {e}")
            raise
            return
if __name__ == "__main__":
    load_rules_of_conduct()
