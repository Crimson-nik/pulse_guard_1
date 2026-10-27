"""Reference implementation of Sharma et al. (2022), CEE 101:108057.

Every function here is a direct transcription of the paper, at double
precision, with the same operation order as the Dart port in
packages/ppg_core. The point of this file is to be the oracle: the Dart
code is only correct if it reproduces these numbers bit for bit on the
fixtures in test/fixtures.

Paper artifacts referenced by number:
  Eq. (1)  HR = FPS * FreqIdx * 60 / N          (sliding average paper, Sukaphat)
  Eq. (2)  HR = ceil(f * FPS * 60 / N)          (this paper's FFT method)
  Alg. 1   peak counting with a 4-frame mean and a flag
  Alg. 2   per-frame averaging, FFT per channel, mean of the two channels
  Alg. 3   BP chain: ET, BSA, SV, PP, SBP, DBP
  Eqs. (3)-(8) the same chain written out
"""

from __future__ import annotations

import json
import math
from dataclasses import dataclass

# Fidelity constants. See docs/decisions.md for why each one exists.
FFT_LEN_MIN = 256          # D1: zero-padded FFT length, next power of two >= frames
HR_MIN_BPM = 35.0          # D2: paper says "started after 35", read as 35 bpm
HR_MAX_BPM = 210.0         # D2: upper guard, not stated in the paper
MAP_CONST = 83.25          # D3: Pm in Eq. (7) and (8), taken literally
SLIDING_WINDOW = 4         # Alg. 1: "average is calculated for the last 4 frames"


# --------------------------------------------------------------------------
# Alg. 1: sliding average peak counter (the method the paper abandons)
# --------------------------------------------------------------------------

def count_peaks_sliding(red: list[float], window: int = SLIDING_WINDOW) -> int:
    """Alg. 1 verbatim, with the mean the prose describes.

    The pseudocode on p. 4 line 12 sums four values and calls the result
    "Average" without dividing. Comparing a sum against a single frame
    would suppress almost every peak, so the prose ("the average is
    calculated for the last 4 frames") is what we implement. Recorded as
    deviation D5 in docs/decisions.md.
    """
    count = 0
    flag = 0
    for i in range(window, len(red)):
        mean = (red[i] + red[i - 1] + red[i - 2] + red[i - 3]) / window
        current = red[i]
        if current > mean and flag == 0:
            count += 1
            flag = 1
        elif current <= mean and flag == 1:
            flag = 0
    return count


def hr_from_peaks(red: list[float], window: int = SLIDING_WINDOW) -> int:
    """Alg. 1 line 24: Beats = count * 2, because the capture is 30 s."""
    return count_peaks_sliding(red, window) * 2


# --------------------------------------------------------------------------
# Alg. 2 / Eq. (2): FFT peak with band limits
# --------------------------------------------------------------------------

def fft_length(n_frames: int) -> int:
    n = FFT_LEN_MIN
    while n < n_frames:
        n <<= 1
    return n


def rfft_magnitudes(x: list[float], n: int) -> list[float]:
    """Naive DFT, written out so the port has an obvious thing to match.

    Only used by this reference file and by the fixture generator. The
    Dart side uses a radix-2 FFT, which must agree to floating point
    precision and therefore give the same argmax on the fixtures.
    """
    re = [0.0] * (n // 2 + 1)
    im = [0.0] * (n // 2 + 1)
    for k in range(n // 2 + 1):
        sr = 0.0
        si = 0.0
        wk = -2.0 * math.pi * k / n
        for t, v in enumerate(x):
            sr += v * math.cos(wk * t)
            si += v * math.sin(wk * t)
        re[k] = sr
        im[k] = si
    return [math.hypot(re[k], im[k]) for k in range(n // 2 + 1)]


def peak_bin(x: list[float], fps: float) -> tuple[int, int, float]:
    """Return (bin index, fft length, peak Hz) inside the allowed band.

    Eq. (2) as printed is ceil(f * FPS * 60 / N) where f is called "the
    frequency of max amplitude". Taking f as the raw bin index makes the
    units work out: f * FPS / N is the bin in Hz. Decision D4.
    """
    n = fft_length(len(x))
    # Mean removal before padding. Without it the zero padding leaves a step
    # at the end of the buffer whose leakage outranks the pulse peak inside
    # the band. See docs/decisions.md, D1.
    mean = sum(x) / len(x) if x else 0.0
    centered = [v - mean for v in x]
    padded = centered + [0.0] * (n - len(centered))
    mags = rfft_magnitudes(padded, n)
    lo = max(1, int(math.ceil(HR_MIN_BPM / 60.0 * n / fps)))
    hi = min(len(mags) - 1, int(math.floor(HR_MAX_BPM / 60.0 * n / fps)))
    best_k = lo
    best = -1.0
    for k in range(lo, hi + 1):
        if mags[k] > best:
            best = mags[k]
            best_k = k
    return best_k, n, best_k * fps / n


def hr_from_channel(x: list[float], fps: float) -> int:
    k, n, _hz = peak_bin(x, fps)
    return int(math.ceil(k * fps * 60.0 / n))


def hr_from_rgb(red: list[float], green: list[float], fps: float) -> float:
    """Alg. 2 lines 14-18: FFT each channel, convert to bpm, average."""
    return (hr_from_channel(green, fps) + hr_from_channel(red, fps)) / 2.0


# --------------------------------------------------------------------------
# Alg. 3 / Eqs. (3)-(8): blood pressure
# --------------------------------------------------------------------------

@dataclass
class Bp:
    ejection_time_ms: float
    bsa_m2: float
    stroke_volume_ml: float
    pulse_pressure: float
    systolic: float
    diastolic: float


def blood_pressure(heart_rate: float, age_years: float,
                   weight_kg: float, height_cm: float) -> Bp:
    """Eqs. (3)-(8) in order. BSA uses cm and kg and returns m^2 (D6).

    The paper's Alg. 3 line 4 comment says "body surface area in
    millimeters squared", which contradicts the Du Bois exponent form.
    Du Bois is defined on cm and kg and yields m^2, so that is what we do.
    """
    et = 364.5 - 1.23 * heart_rate
    bsa = 0.007184 * (weight_kg ** 0.425) * (height_cm ** 0.725)
    sv = (-6.6 + (0.25 * (et - 35.0)) - (0.62 * heart_rate)
          + (40.4 * bsa) - (0.51 * age_years))
    pp = sv / ((0.013 * weight_kg - 0.007 * age_years - 0.004 * heart_rate) + 1.307)
    sbp = MAP_CONST + (2.0 / 3.0) * pp
    dbp = MAP_CONST - (1.0 / 3.0) * pp
    return Bp(et, bsa, sv, pp, sbp, dbp)


# --------------------------------------------------------------------------
# Synthetic signals, used for fixtures and for the replay test path
# --------------------------------------------------------------------------

def synth_ppg(heart_rate: float, fps: float, seconds: float,
              seed: int = 7, noise: float = 0.0,
              dicrotic: float = 0.35) -> tuple[list[float], list[float]]:
    """Two-harmonic pulse with a fixed-seed noise floor.

    The second harmonic at ~2x the cardiac rate is the dicrotic notch,
    which is exactly what makes Alg. 1 double count. Keeping it in the
    synthetic signal is deliberate: the fixtures then reproduce the
    paper's stated failure mode instead of assuming it away.
    """
    import random
    rng = random.Random(seed)
    n = int(round(fps * seconds))
    f0 = heart_rate / 60.0
    red: list[float] = []
    green: list[float] = []
    for i in range(n):
        t = i / fps
        base = 200.0 + 18.0 * math.sin(2 * math.pi * f0 * t)
        notch = 18.0 * dicrotic * math.sin(2 * math.pi * 2 * f0 * t + 0.6)
        drift = 3.0 * math.sin(2 * math.pi * 0.08 * t)
        red.append(base + notch + drift + noise * rng.gauss(0, 1))
        green.append(0.55 * base + 0.8 * notch + drift + noise * rng.gauss(0, 1))
    return red, green


def fixture_set() -> dict:
    cases = []

    def add(name: str, note: str, hr: float, fps: float, seconds: float,
            seed: int, noise: float, dicrotic: float = 0.35):
        red, green = synth_ppg(hr, fps, seconds, seed, noise, dicrotic)
        # Round first, then compute. The fixture file stores rounded values,
        # so expectations must come from the same rounded arrays or the port
        # could differ on a near tie.
        red = [round(v, 6) for v in red]
        green = [round(v, 6) for v in green]
        k_r, n_r, hz_r = peak_bin(red, fps)
        k_g, n_g, hz_g = peak_bin(green, fps)
        bp = blood_pressure(hr, 25.0, 70.0, 175.0)
        cases.append({
            "name": name,
            "note": note,
            "fps": fps,
            "heartRateTrue": hr,
            "red": red,
            "green": green,
            "expected": {
                "peakCount": count_peaks_sliding(red),
                "slidingBpm": hr_from_peaks(red),
                "redBin": k_r, "redFftLen": n_r, "redPeakHz": round(hz_r, 9),
                "greenBin": k_g, "greenFftLen": n_g, "greenPeakHz": round(hz_g, 9),
                "redBpm": hr_from_channel(red, fps),
                "greenBpm": hr_from_channel(green, fps),
                "fusedBpm": hr_from_rgb(red, green, fps),
            },
        })
        return bp

    add("clean_72bpm_30fps", "Idealised capture, 30 s at 30 fps, no noise",
        72, 30, 30, 1, 0.0)
    add("noisy_88bpm_30fps", "Moderate noise floor, matches Table 1 row 1",
        88, 30, 30, 2, 1.2)
    add("resting_55bpm_30fps", "Bradycardic side of normal",
        55, 30, 30, 3, 0.9)
    add("fast_100bpm_60fps", "60 fps device, taps above 100",
        100, 60, 30, 4, 1.1)
    add("short_10s_30fps", "Interrupted capture, 10 s of data",
        76, 30, 10, 5, 0.8)
    add("two_peaks_30fps", "Dicrotic notch exaggerated on purpose",
        72, 30, 30, 6, 0.6, 1.4)

    bp = blood_pressure(80.0, 25.0, 70.0, 175.0)
    return {
        "generator": "tools/pyref/ppg_reference.py",
        "paper": "Sharma et al., Computers and Electrical Engineering 101 (2022) 108057",
        "constants": {
            "fftLenMin": FFT_LEN_MIN, "hrMinBpm": HR_MIN_BPM,
            "hrMaxBpm": HR_MAX_BPM, "mapConst": MAP_CONST,
            "slidingWindow": SLIDING_WINDOW,
        },
        "goldenBp": {
            "heartRate": 80, "age": 25, "weightKg": 70, "heightCm": 175,
            "ejectionTimeMs": round(bp.ejection_time_ms, 6),
            "bsaM2": round(bp.bsa_m2, 6),
            "strokeVolumeMl": round(bp.stroke_volume_ml, 6),
            "pulsePressure": round(bp.pulse_pressure, 6),
            "systolic": round(bp.systolic, 6),
            "diastolic": round(bp.diastolic, 6),
        },
        "cases": cases,
    }


if __name__ == "__main__":
    import os
    here = os.path.dirname(os.path.abspath(__file__))
    root = os.path.abspath(os.path.join(here, "..", ".."))
    out = os.path.join(root, "packages", "ppg_core", "test", "fixtures")
    os.makedirs(out, exist_ok=True)
    data = fixture_set()
    path = os.path.join(out, "paper_fixtures.json")
    with open(path, "w") as fh:
        json.dump(data, fh, indent=1)
    g = data["goldenBp"]
    print("wrote", path)
    print("golden BP: ET %.3f ms  BSA %.4f m2  SV %.3f mL  PP %.3f"
          % (g["ejectionTimeMs"], g["bsaM2"], g["strokeVolumeMl"], g["pulsePressure"]))
    print("golden BP: %.2f / %.2f mmHg" % (g["systolic"], g["diastolic"]))
    for c in data["cases"]:
        e = c["expected"]
        print("%-22s true %5.1f  fft %5.1f  sliding %4d  peaks %3d"
              % (c["name"], c["heartRateTrue"], e["fusedBpm"],
                 e["slidingBpm"], e["peakCount"]))
