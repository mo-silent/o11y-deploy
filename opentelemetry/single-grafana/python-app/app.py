from flask import Flask
import random
import time

app = Flask(__name__)

@app.route("/")
def hello():
    time.sleep(random.random() * 0.5)
    return "Hello World!"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)