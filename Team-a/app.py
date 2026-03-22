from flask import Flask, request, jsonify
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route("/")
def home():
    logger.info("Home endpoint hit")
    return "App is running!"

@app.route("/fibonacci")
def fibonacci():
    n = int(request.args.get("n", 5))

    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b

    logger.info(f"Calculated fibonacci({n}) = {a}")
    return jsonify({"n": n, "result": a})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
