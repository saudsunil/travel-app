import firebase_admin
from firebase_admin import credentials

cred_path = 'firebase_credential.json'  # Same directory as manage.py

cred = credentials.Certificate(cred_path)

if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)
