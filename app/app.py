import hashlib
import logging
import os
import time
from flask import Flask, jsonify, request
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s"
)

metrics = PrometheusMetrics(app)
memory_store = []


@app.route("/")
def home():
    app.logger.info("Root endpoint called")
    return jsonify(
        status="ok",
        message="Flask application is running"
    ), 200


@app.route("/health")
def health():
    return jsonify(status="healthy"), 200


@app.route("/work")
def work():
    n = request.args.get("n", default=100000, type=int)
    app.logger.info("CPU workload started n=%s", n)
    start = time.time()
    value = b"eks-sre-demo"
    for i in range(n):
        value = hashlib.sha256(
            value + str(i).encode()
        ).digest()
    duration = time.time() - start
    app.logger.info(
        "CPU workload completed n=%s duration=%.3f",
        n,
        duration
    )
    return jsonify(
        status="completed",
        iterations=n,
        duration_seconds=round(duration, 3),
        result=value.hex()[:16]
    ), 200


@app.route("/leak")
def leak():
    mb = request.args.get("mb", default=1, type=int)

    if mb <= 0:
        return jsonify(
            error="mb must be greater than 0"
        ), 400

    memory_store.append(bytearray(mb * 1024 * 1024))

    total_mb = sum(len(item) for item in memory_store) / 1024 / 1024

    app.logger.warning(
        "Allocated %s MB. Total retained memory %.2f MB",
        mb,
        total_mb
    )

    return jsonify(
        allocated_mb=mb,
        retained_mb=round(total_mb, 2)
    ), 200


if __name__ == "__main__":
    port = int(os.getenv("PORT", "5000"))

    app.run(
        host="0.0.0.0",
        port=port
    )
