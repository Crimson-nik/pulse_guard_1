# From this folder to an APK on the phone

Everything between "the code is on my laptop" and "PPG Lab is installed on the
Galaxy A35", using GitHub Actions so no Android SDK is needed locally.

The repository is the `dsp/` folder only. `pulse_guard/`, the paper PDF and the
other files next to it are not part of this app and must not be pushed with it.

---

## 1. Push this folder to a new GitHub repository

Create an empty repository on GitHub (no README, no .gitignore — this folder
already has both), then, from inside `dsp/`:

```bash
git remote set-url origin https://github.com/<your-account>/<new-repo>.git
git push -u origin master
```

The folder already has its own `.git` with one commit, so `git push` is enough.
Use `main` instead of `master` if you renamed the branch:

```bash
git branch -M main
git push -u origin main
```

The workflow listens to both names, so either works.

---

## 2. What happens on push

`.github/workflows/build-apk.yml` runs two jobs.

| Job | What it does | Blocks the APK? |
|---|---|---|
| Analyse and test | `flutter analyze`, `flutter test`, and the `ppg_core` tests against the Python fixtures | No. It is marked non-blocking on purpose, so a red check does not cost you a build |
| Release APK | `flutter build apk --release` and uploads the APK | This is the one you want |

The toolchain is pinned to the versions the app was verified with:

| Item | Version |
|---|---|
| Flutter / Dart | 3.47.8 / 3.13.7 |
| JDK | Temurin 17 |
| Gradle / AGP / Kotlin | 9.3.1 / 9.1.0 / 2.4.0 |
| compileSdk / targetSdk / minSdk | 36 / 35 / 26 |

A build takes roughly six to ten minutes on a cold cache.

---

## 3. Download the APK

**From a push:** open the repository → **Actions** → the newest **Build APK**
run → scroll to **Artifacts** → download **ppg-lab-apk-N**. Unzip it; inside is
`PPG-Lab-1.0.0-buildN.apk` and `SHA256SUMS.txt`.

**From a tag (nicer link, no unzipping):**

```bash
git tag v1.0.0
git push origin v1.0.0
```

The same APK is attached to a GitHub Release called `v1.0.0`, and the download
link is public if the repository is public. The tag also becomes the version
name, so `v1.0.1` produces a `1.0.1` APK.

**Manual run:** Actions → Build APK → **Run workflow**. You can type a version
name and version code there.

The build number defaults to the Actions run number, so every build has a
higher `versionCode` than the last and installs as an update rather than
needing an uninstall first.

---

## 4. Optional: sign with a real release key

Without this, the APK is signed with a debug key. That is fine for sideloading
and for testing, and the workflow caches the key so updates keep working. It is
not suitable for uploading to the Play Store.

Generate a keystore once, on a machine with a JDK:

```bash
keytool -genkeypair -v \
  -keystore upload-keystore.jks \
  -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias ppglab \
  -storepass 'CHANGE_ME' -keypass 'CHANGE_ME' \
  -dname "CN=PPG Lab, OU=Student project, O=PPG Lab, L=Jaipur, S=Rajasthan, C=IN"
```

Base64 it:

```bash
base64 -w0 upload-keystore.jks > upload-keystore.b64    # Linux
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) > upload-keystore.b64   # PowerShell
```

Then in the repository: **Settings → Secrets and variables → Actions → New
repository secret**:

| Secret | Value |
|---|---|
| `KEYSTORE_BASE64` | the contents of `upload-keystore.b64` |
| `KEYSTORE_PASSWORD` | the store password |
| `KEY_ALIAS` | `ppglab` |
| `KEY_PASSWORD` | the key password |

The workflow writes `android/key.properties` from those four secrets and the
Gradle build switches to the release key on its own. Keep the `.jks` file
somewhere safe; without it you cannot ship an update to an installed app.

Do not commit the keystore. `key.properties`, `*.jks` and `*.keystore` are
already ignored.

---

## 5. Install on the Samsung Galaxy A35

The A35 runs One UI, which adds two gates on top of stock Android.

1. **Transfer the APK.** Download it on the phone from the Actions artifact or
   Release page, or copy it over USB. Chrome can open the ZIP and the APK
   directly, but unzipping first is more predictable.
2. **Allow installs from the file manager or Chrome.** When you tap the APK,
   Android asks once: *"For your security, your phone is not allowed to install
   unknown apps from this source."* Tap **Settings**, enable **Allow from this
   source**, then go back and tap the APK again.
3. **Turn off Auto Blocker if it interferes.** One UI 6.1 and newer ship
   **Settings → Security and privacy → Auto Blocker**, which blocks sideloaded
   apps by default. Turn it off while testing (or use *"Allow installs from
   unknown sources"* inside Auto Blocker on newer builds). Play Protect may also
   show *"Unsafe app blocked"* because the APK is debug-signed — tap **More
   details → Install anyway**.
4. **Open PPG Lab and grant the camera permission.** The app asks in context,
   on the Measure screen, not at launch. If you denied it once, grant it in
   *Settings → Apps → PPG Lab → Permissions → Camera*.
5. **The torch turns on by itself** when a capture starts. You do not need to
   enable the flashlight.

### First run, in order

Do this once, on the phone, before trusting a real capture.

1. **Settings** → set age, weight and height. All three feed Eqs. (3) to (8);
   bone fide values only, as the paper says.
2. **Today → Take a reading → Synthetic capture.** This runs a generated
   72 bpm waveform through the whole path, camera included in no step. You
   should land on a Result of about 73 bpm. If that does not work, the problem
   is the app, not your finger.
3. **Validation → Recovery from a known rate.** Sweep the slider. The paper
   path should stay within about 2.5 bpm of the chosen rate.
4. **A real capture.** Index finger pad over the rear camera *and* flash, gentle
   pressure, hand still, thirty seconds. Watch the trace on screen: a wandering
   line means the finger moved.
5. **Repeat with the phone in airplane mode.** There is no network permission in
   the release build, so nothing should change. That is the point.

### What "good" looks like on the A35

- Frame rate in Session detail around 28–30 fps, steady. A dip is the phone
  throttling, and the app measures the real rate instead of assuming 30.
- Pulse strength (perfusion index) above about 0.5 percent with the finger
  properly placed.
- Red and green heart rates within a couple of beats of each other. A wide gap
  is a capture warning, not biology.
- Blood pressure labelled **model estimate** everywhere. It is computed from
  the heart rate by the paper's equations; it has never met a cuff.

---

## 6. Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Workflow fails at `flutter pub get` | Flutter version drifted from the lockfile | The workflow pins 3.47.8; if you change `pubspec.yaml`'s SDK constraint, change `FLUTTER_VERSION` too |
| Workflow fails at Gradle: "requires compile against 36" | SDK platform 36 missing | The workflow installs it; check the "Install the SDK platform" step log |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | The installed copy was signed with a different key (an older build, or a local `flutter run`) | Uninstall PPG Lab once, then install the new APK. Every later CI build updates cleanly |
| "App not installed" / "Invalid package" | Corrupt download, or the APK was unzipped from a partial artifact | Re-download the artifact and compare `SHA256SUMS.txt` |
| Play Protect blocks the install | Debug signing | More details → Install anyway. A real release key (section 4) avoids this |
| Camera permission granted but capture fails with "The camera did not start" | Another app holds the camera | Close other camera apps; reopen PPG Lab |
| Torch does not come on | Some devices refuse the torch while the camera is bound | The app reports a bad reading rather than a crash; try the synthetic capture to confirm the maths path still works |
| Capture stops early / screen turns off | Screen timeout | Fixed in this build: the window is held awake for the duration of a capture. Make sure you installed the latest APK |
| Heart rate is nonsense (e.g. double) | The dicrotic wave outranking the systolic peak — a known failure of the method, shown on the Validation screen | Retake with less pressure and more stillness; cross-check red vs green and the sliding-average answer on the Result screen |
| Nothing in the Journal after a capture | Storage failed; the Result screen says so | Restart the app and capture again. Sessions are stored in SQLite on the device |

Logs, if you need them, with the phone connected and USB debugging on:

```bash
adb logcat -s flutter:V ActivityManager:E CameraX:E
```

---

## 7. What the APK is, and is not

- It is a reproduction of the method in Sharma et al. (2022), implemented from
  the text of the paper. The paper published no code.
- The heart rate is an estimate from a camera. The blood pressure is a model
  output computed from that estimate.
- It has no network permission, no account, no analytics and no crash
  reporting. Every reading stays in a local SQLite file and can be deleted from
  Settings.
- It is not a medical device, and `docs/validation.md` says exactly what would
  have to happen before anyone calls its numbers accurate.
