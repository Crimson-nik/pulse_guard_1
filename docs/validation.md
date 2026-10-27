# Validation

What can be established without a person and a second instrument, what cannot,
and how to do the part that cannot.

Be clear about the boundary. Everything in the first half has been run on the
build machine. Nothing in the second half has been run anywhere, because this
machine has no camera, no Android device and no human.

---

## What was verified here

| Check | Command | Result |
|---|---|---|
| Dart port matches the Python reference on six fixtures | `dart test` in `packages/ppg_core` | 37 tests, all pass |
| Blood pressure chain reproduces the hand calculation | `test/fixtures_test.dart` | 107.83 / 70.96 mmHg at HR 80, 25 y, 70 kg, 175 cm |
| The paper's failure mode reproduces | `two_peaks_30fps` fixture | 72 bpm signal read as 145 bpm by the transform and 144 by the counter |
| Static analysis | `flutter analyze` | no issues |
| The app compiles for Android | `flutter build apk` | debug and release APKs built, see the build note |
| Native libraries are 16 KB page aligned | `llvm-readelf -l` over both APKs | all 18 entries at 0x4000 or larger |

### Build note

| Item | Value |
|---|---|
| Flutter | 3.47.8 stable, Dart 3.13.7 |
| Android Gradle Plugin / Kotlin / Gradle | 9.1.0 / 2.4.0 / 9.3.1 |
| JDK | Temurin 17.0.21 |
| SDK | platform 35 and 36 installed, build-tools 35.0.0 |
| CameraX | 1.6.2 (camera-core, camera-camera2, camera-lifecycle) |
| APK sizes | release 57.7 MB (57,741,128 bytes), debug 154 MB |
| `minSdk` / `targetSdk` / `compileSdk` | 26 / 35 / 36 |
| Release permissions | `CAMERA`, plus the generated `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` |
| Release native libraries | 18 `.so` entries across arm64-v8a, armeabi-v7a, x86_64 |
| Bundled font | `RobotoMono-Regular.ttf` and `RobotoMono-Medium.ttf` present under `assets/flutter_assets/assets/fonts/`, listed in `FontManifest.json` as family `RobotoMono` |

Two facts worth stating because the app makes claims about them.

**The APK you install is rebuilt by CI, not copied from the machine above.**
`.github/workflows/build-apk.yml` pins the same Flutter 3.47.8 / Dart 3.13.7 and
JDK 17, runs `flutter build apk --release` on a clean Ubuntu runner, and
publishes the result as a workflow artifact and, on a `v*` tag, as a release
asset. `docs/ci-and-install.md` describes the pipeline and the install
checklist for a Galaxy A35. The build note above records the toolchain that was
used the first time the project was verified; CI is what keeps it true after a
change.

**No internet permission in the release build.** `aapt2 dump badging` on
`app-release.apk` lists camera and the generated receiver permission and
nothing else. The debug and profile manifests do add `INTERNET`, because the
Flutter tooling needs it for the Dart VM service, so anyone auditing the
debug build will see it and should know why it is there.

**Every native library is 16 KB page compatible.** `llvm-readelf -l` over all
18 entries reports `LOAD` alignment of `0x4000` or `0x10000`, so the app will
load on Android 15 devices configured with 16 KB pages. `libsqlite3.so` is
bundled from source by the `sqlite3` Dart package, and it is aligned too,
which is the case that usually breaks.

None of that proves the app runs. It was built and inspected, never executed
on a phone.

The fixtures are the important one. `tools/pyref/ppg_reference.py` is a second
implementation of the paper's method, written in Python against NumPy-free
code, and `packages/ppg_core/test/fixtures/paper_fixtures.json` contains six
synthetic captures with the numbers that implementation produced. If the Dart
code and the Python code ever disagree, a test fails. That means the Dart is
not quietly drifting from the transcription while the app keeps working.

---

## What cannot be verified here

Everything about accuracy. The paper's 98 percent claim is about a comparison
with a digital monitor that this project has no access to. Any number this app
prints is a reproduction of a method, not a validated measurement, and the
interface says so on every screen that shows one.

Three things follow, and they are the reason this file exists.

1. The app never prints an accuracy figure.
2. The app never calls its blood pressure a measurement.
3. The protocol below has to be run by a person with real instruments before
   anyone may describe this app as accurate, and even then only for the
   software, not for the user.

---

## Check one: on-device self checks

The Validation screen has three parts. The first two need nothing but the
phone.

**Recovery from a known rate.** A waveform is generated at a chosen rate and
analysed through both pipelines. Sweep the slider from 45 to 120 bpm and watch
the paper path error. It should stay inside about two and a half beats per
minute, which is one bin of the grid plus the ceiling. If it does not, either
the frame rate measurement or the transform is wrong.

**Re-run a stored capture.** Pick a session and re-analyse the stored samples.
The paper path must reproduce the stored numbers exactly. A mismatch means the
code changed since the capture was saved, or the record is incomplete.

Neither check says anything about whether the sensor sees a pulse. They check
the arithmetic, which is the part that can be wrong in a way nobody notices.

---

## Check two: agreement with a reference instrument

This is the only check that speaks to accuracy. It needs:

- A pulse oximeter with a heart rate display, or a digital monitor that shows
  both heart rate and blood pressure.
- A quiet room with steady light, not direct sunlight.
- At least eight people, preferably more, covering a spread of ages and both
  sexes, and at least a few with a known cardiovascular condition if the
  reading is ever meant for them.

### Protocol

Run this identically for every subject and write down the deviations.

1. Seat the subject. Rest for five minutes, no talking, phone away from the
   cuff arm.
2. Record: subject id, age, sex, weight in kilograms, height in centimetres,
   any medication that affects heart rate, and the device model and Android
   version.
3. Reference reading first, using the monitor exactly as its manual says.
   Write down the heart rate and, if the monitor measures it, the pressure.
4. Within sixty seconds, start the app capture. Same finger every time, the
   pad of the index finger, gentle pressure, screen facing away from the
   subject so the countdown does not distract.
5. Wait two minutes.
6. Repeat steps 3 to 5 three times per subject. That gives three paired
   readings per person.
7. Note the app's quality verdict for each capture. Never discard a capture
   after seeing the numbers; record every one, including refusals, and note
   why.

Record every capture, not the best one. Discarding bad captures after seeing
their values is how a validation study turns into a demonstration.

### Recording template

    subject,reading,kind,app_value,reference_value
    S1,1,hr,73,72
    S1,1,sbp,108,110
    S1,1,dbp,71,70
    S2,1,hr,68,69

`kind` is `hr`, `sbp` or `dbp`. One row per signal per reading. Keep the raw
export next to the analysis so it can be checked.

### Analysis

    python3 tools/pyref/agreement.py readings.csv --plot agreement.png

This reports, for each signal, the number of pairs, the bias (mean of app
minus reference), the standard deviation of the differences, the 95 percent
limits of agreement, the mean absolute error and the root mean squared error,
and draws the Bland-Altman plot. The paper reports none of this; it reports a
single accuracy percentage and a "plus or minus 2" with no method.

Report all three of bias, spread and limits. A bias near zero with wide limits
means the method is unbiased and imprecise, which is a different problem from
a systematic offset.

### Decision rules, fixed before data collection

These are set in advance so the result cannot be argued into shape later.

- **Heart rate is described as accurate** only if the absolute bias is under
  2 bpm and the limits of agreement fall inside plus or minus 8 bpm across at
  least 24 paired readings from at least eight subjects.
- **Heart rate is described as unreliable** if the limits of agreement exceed
  plus or minus 12 bpm. In that case the result screen keeps its current
  wording and the app is described as a reproduction only.
- **Blood pressure is never described as accurate** by this project, whatever
  the data shows, because the model was never fitted to these subjects and a
  single-site convenience sample cannot support a claim. The result may be
  reported as "the model tracks the cuff with a bias of X and limits of
  agreement of Y to Z", which is a factual statement about this sample and
  nothing more.
- **Captures refused by the quality gate** are counted and reported as a
  proportion, not quietly dropped. A method that refuses a fifth of its
  captures is a different product from one that refuses two percent.

---

## Check three: reproducing the paper's Table 1

Table 1 in the paper is five readings from one person on a Moto G9 running
Android 10, app values 87, 82, 85, 78, 75 against reference 88, 81, 83, 80, 75.

To reproduce the shape of that table, take five successive captures in one
sitting with a reference reading beside each, and put them side by side. What
matters is not that the numbers match theirs, since the person, device and
conditions differ, but whether the same pattern appears: differences of one to
three beats, always in the same direction or not, and no drift over the five
readings.

Publish the table with the app, whatever it shows.

---

## Device checks

Run these once per device, before trusting any reading from it.

| Check | How | Why |
|---|---|---|
| Torch turns on during capture | Watch the lens | Some devices refuse the torch while the camera is bound |
| Frame rate is stable | Session detail shows measured fps | A throttled device changes the bin grid |
| 16 KB page size compatibility | See below | Android 15 devices can use 16 KB pages; a misaligned `.so` crashes on launch |
| Screen does not sleep during capture | Watch a full 30 s capture | A sleeping screen stops the frame stream |
| Permission denial is handled | Deny camera permission | The app must explain, not crash |
| Storage works after force stop | Kill the app, reopen, check Journal | An unflushed database loses readings |

### Checking 16 KB page alignment

Android 15 can run with 16 KB memory pages, and native libraries must be
linked with a matching maximum page size or the app fails at load time.

    unzip -o build/app/outputs/flutter-apk/app-release.apk 'lib/*/*.so' -d /tmp/apk-libs
    for so in $(find /tmp/apk-libs -name '*.so'); do
      echo "$so"
      "$ANDROID_HOME"/ndk/*/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-readelf \
        -l "$so" | grep LOAD
    done

Every `LOAD` line must end in `0x4000` (16384) or larger. `0x1000` means 4 KB
only, and the library will fail to load on a 16 KB device.

---

## Known limitations of this reproduction

- The camera path averages a subsampled grid of pixels, not every pixel. The
  paper averages the whole frame. On a uniform fingertip image the difference
  is negligible; on a partly covered lens it is not, which is one reason the
  quality gate exists.
- Frame timestamps come from the analysis callback, so they include a little
  scheduling delay. The measured rate is therefore a lower bound on the sensor
  rate, by a small constant.
- Memory use during capture is a few hundred kilobytes of samples plus the
  camera buffers. Nothing is streamed to disk mid-capture, so a crash loses
  the capture.
- No emulator was used. An emulator has no torch and no fingertip, so it can
  only exercise the synthetic path, which the tests already cover.
