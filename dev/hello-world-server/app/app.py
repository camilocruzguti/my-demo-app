from flask import Flask
from flask import Response
import os

app = Flask(__name__)

@app.route("/")
def hello():
    resp = Response("hello world from flask backend!!!")
    resp.headers['Access-Control-Allow-Origin'] = '*'
    return resp

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(debug=True,host='0.0.0.0',port=port)