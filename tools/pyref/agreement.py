"""Agreement analysis for the on-device validation protocol.

Reads a CSV with one row per paired measurement and reports the numbers the
protocol asks for: bias, spread, limits of agreement, mean absolute error.
This is the standard Bland and Altman treatment, which is what a reader of a
clinical engineering paper expects and what the source paper never reports.

Expected columns:
    subject,reading,kind,app_value,reference_value

kind is one of hr, sbp, dbp. app_value is what PPG Lab produced, reference_value
is the cuff or oximeter.

Usage:
    python3 tools/pyref/agreement.py readings.csv [--plot agreement.png]
"""

from __future__ import annotations

import argparse
import csv
import math
import statistics
import sys


def load(path: str) -> dict[str, list[tuple[float, float]]]:
    pairs: dict[str, list[tuple[float, float]]] = {"hr": [], "sbp": [], "dbp": []}
    with open(path, newline="") as handle:
        for row in csv.DictReader(handle):
            kind = (row.get("kind") or "").strip().lower()
            if kind not in pairs:
                continue
            try:
                app = float(row["app_value"])
                ref = float(row["reference_value"])
            except (KeyError, TypeError, ValueError):
                continue
            pairs[kind].append((app, ref))
    return pairs


def summarise(pairs: list[tuple[float, float]]) -> dict[str, float]:
    diffs = [app - ref for app, ref in pairs]
    n = len(diffs)
    if n == 0:
        return {"n": 0}
    bias = sum(diffs) / n
    sd = statistics.stdev(diffs) if n > 1 else 0.0
    mae = sum(abs(d) for d in diffs) / n
    rmse = math.sqrt(sum(d * d for d in diffs) / n)
    return {
        "n": n,
        "bias": bias,
        "sd": sd,
        "loa_low": bias - 1.96 * sd,
        "loa_high": bias + 1.96 * sd,
        "mae": mae,
        "rmse": rmse,
        "min": min(diffs),
        "max": max(diffs),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("csv")
    parser.add_argument("--plot", default="")
    args = parser.parse_args()

    pairs = load(args.csv)
    total = sum(len(v) for v in pairs.values())
    if total == 0:
        print("No usable rows. Expected columns subject,reading,kind,"
              "app_value,reference_value with kind in hr, sbp, dbp.")
        return 1

    units = {"hr": "bpm", "sbp": "mmHg", "dbp": "mmHg"}
    print(f"{'signal':6s} {'n':>3s} {'bias':>7s} {'sd':>6s} {'95% limits':>18s} {'MAE':>6s} {'RMSE':>6s}")
    for kind in ("hr", "sbp", "dbp"):
        s = summarise(pairs[kind])
        if s["n"] == 0:
            continue
        print(
            f"{kind:6s} {int(s['n']):3d} {s['bias']:7.2f} {s['sd']:6.2f} "
            f"{s['loa_low']:8.2f} to {s['loa_high']:7.2f} "
            f"{s['mae']:6.2f} {s['rmse']:6.2f}   ({units[kind]})"
        )

    if args.plot:
        try:
            import matplotlib

            matplotlib.use("Agg")
            import matplotlib.pyplot as plt
        except ImportError:
            print("\nmatplotlib is not installed, skipping the plot.")
            return 0

        fig, axes = plt.subplots(1, 3, figsize=(12, 4))
        for axis, kind in zip(axes, ("hr", "sbp", "dbp")):
            rows = pairs[kind]
            axis.set_title(f"{kind} ({units[kind]})")
            axis.set_xlabel("mean of app and reference")
            axis.set_ylabel("app minus reference")
            if not rows:
                continue
            means = [(a + r) / 2 for a, r in rows]
            diffs = [a - r for a, r in rows]
            axis.scatter(means, diffs, s=18, color="#A11D21")
            s = summarise(rows)
            axis.axhline(s["bias"], color="#14110F", linewidth=1)
            axis.axhline(s["loa_high"], color="#2C4A52", linewidth=1, linestyle="--")
            axis.axhline(s["loa_low"], color="#2C4A52", linewidth=1, linestyle="--")
            axis.axhline(0, color="#B8B2AC", linewidth=0.8)
        fig.tight_layout()
        fig.savefig(args.plot, dpi=150)
        print(f"\nBland-Altman plot written to {args.plot}")

    print(
        "\nBias is the mean of app minus reference. Limits of agreement are "
        "bias plus or minus 1.96 standard deviations, so roughly 95 percent of "
        "future differences should fall inside them. Report all three; a bias "
        "alone hides the spread."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
