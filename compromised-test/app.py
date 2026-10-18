from flask import Flask
app = Flask(__name__)
# Deliberately planted secret (FAKE) to trigger secret scanning
AWS_SECRET_ACCESS_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
AWS_ACCESS_KEY_ID = "AKIAIOSFODNN7EXAMPLE"
@app.get("/")
def i(): return "compromised"
