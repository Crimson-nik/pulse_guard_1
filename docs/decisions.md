# Decisions

Every choice where the paper is silent, ambiguous or wrong, plus the
engineering choices that shape the app. Each entry says what was decided, why,
and what evidence would make us revisit it.

Format: D number, title, the decision, the reason, the cost.

---

## Fidelity decisions

### D1. FFT length is the next power of two above the frame count, minimum 256

The paper calls `N` "the size of the FFT Array" without defining it. A 30
second capture at 30 fps gives 900 frames, which is not a power of two.

We zero pad to 1024 and use that as `N` in Eq. (2). The alternative, a 900
point transform, is not what any FFT library does by default and would need a
mixed radix implementation for no gain.

Zero padding does not add information. It interpolates the spectrum, which
means the bin grid gets finer (1.758 bpm instead of 2.0 bpm) and the rounding
error from landing between bins gets smaller. That is a real effect on the
number reported, so it is stated in the walkthrough rather than hidden.

Padding brings one thing with it that has to be handled. A constant offset
over exactly N samples lands entirely in bin 0, and the band limit already
discards bin 0, so the paper can feed raw brightness means into its transform
and get away with it. Pad the same buffer with zeros and the step at the end
of the data leaks across the whole spectrum. Measured on the shipped
reference, a signal with mean 200 and a 5 unit ripple put more energy at
40 bpm than at its true 72 bpm, and the app reported 36 bpm.

So both implementations subtract the channel mean before the transform. This
is not cosmetic: without it the method fails on ordinary captures. No bin
above 0 is changed by removing a constant, so the subtraction is exact and
introduces no bias.

**Cost:** our `N` is not the paper's `N` if their library used 900. Any
comparison with their reported numbers carries that uncertainty. The mean
removal is a step the paper does not describe, recorded here so it is not
mistaken for part of their method.

### D2. The analysis band is 35 to 210 bpm

Section 3.2.2 says analysis starts "after 35 Hz". 35 Hz is 2100 beats per
minute, so the unit is wrong and the sentence means 35 beats per minute.

We read the number as a heart rate floor of 35 bpm and add a ceiling of
210 bpm. The paper gives no ceiling. Without one, a noisy capture sends the
argmax into the high bins and the app reports a rate no human has.

**Cost:** a genuine rate above 210 is refused. That is not a real user.

### D3. The mean pressure term is the literal 83.25

Eqs. (7) and (8) use `Pm` and never define it. The value 83.25 appears in the
equations themselves, so it is used as a constant named `mapConst`.

Chandrasekaran et al. (2013), the cited source, derive a mean pressure term
from age and other inputs. Reconstructing that from a paper we do not have
would be invention, not reproduction.

**Cost:** our blood pressure is exactly as crude as the paper's, no better.

### D4. In Eq. (2), `f` is the bin index

`HR = ceil(f * FPS * 60 / N)` only has consistent units if `f` is the bin
index `k`, because `k * FPS / N` is hertz. Algorithm 2's own
`bpm = ceil(Freq * 60)` agrees when the FFT helper returns hertz.

We implement `ceil(k * FPS * 60 / N)` with the operation order written out so
the Dart and Python versions produce identical integers.

**Cost:** if the authors meant something else, our numbers differ from theirs
by a constant factor. Their reported results are consistent with our reading,
so the risk is low.

### D5. Algorithm 1 uses the mean of four frames, not the sum

Pseudocode line 12 adds four frames and assigns the result to a variable
called `Average`, without dividing by 4. Comparing a single frame against a
sum would suppress nearly every peak.

The prose in Section 3.1 says "the average is calculated for the last 4
frames". The prose wins. The sum reading is noted here so that a reader
comparing our code against the printed algorithm is not surprised.

**Cost:** our failure statistics for the counting method will not match
theirs exactly. The failure itself reproduces regardless.

### D6. Du Bois takes centimetres and kilograms and returns square metres

Algorithm 3 line 4 comments that body surface area is "in millimeters
squared". The Du Bois formula `0.007184 * W^0.425 * H^0.725` is defined on
kilograms and centimetres and returns square metres. With millimetres the
result is off by a factor of a million and the stroke volume is nonsense.

We store height in centimetres and weight in kilograms, and label the result
m².

**Cost:** none. The paper's comment is simply wrong.

### D7. Blood pressure is labelled a model estimate, refused outside its valid region

The paper never compares a blood pressure output with a cuff. It reports only
heart rate accuracy. Presenting these two numbers as a measurement would be
inventing evidence.

Three things follow:

1. Every blood pressure value in the app carries a visible "model estimate"
   label and a one line explanation.
2. No accuracy figure is ever shown for it.
3. The chain is refused when it returns an impossible result. Stroke volume
   goes negative above roughly 150 bpm at ordinary body sizes, and the
   divisor in Eq. (6) crosses zero for extreme profiles (20 kg, 110 years,
   210 bpm gives -0.043). In that region the app says the model does not
   apply instead of printing a number.

**Cost:** some users get no blood pressure where the paper would have printed
one. That is the point.

### D8. Frame rate is measured, never assumed

Algorithm 2 line 13 computes `Frames / totalTimeInSecs`, which is right, but
the surrounding description talks about 30 fps as if it were a constant. It
is not: CameraX on a warm phone throttles, and a 30 second capture can easily
deliver 700 frames.

Every rate in the app is derived from the first and last frame timestamps.
The measured rate is stored with the session and shown in the session detail.

**Cost:** a device with a wildly variable frame rate produces a less stable
number than a device with a fixed one. That is honest; hiding it is not.

### D9. The abandoned counting method ships as a cross check

The paper's most useful contribution is the negative result: the sliding
average counter fails on 60 percent of readings because it counts the
dicrotic wave. Deleting that method would delete the lesson.

The app runs it on every capture and shows its answer next to the FFT answer,
labelled as the method the paper rejected. When the two disagree by more than
a few beats, the result screen says the capture may be unreliable.

**Cost:** one more number on screen. It is the number that makes the other
one meaningful.

---

## Product decisions

### D10. A quality gate sits between capture and result

The paper has no quality gate. Its own text admits a badly placed finger
produces false values. We compute perfusion index, clipping fraction, measured
frame rate and frame interval jitter, and refuse to present a reading as good
when those are bad.

The metrics are printed, not just summarised, because "poor" without a reason
is not actionable.

**Cost:** more code, more screen space, and some users will be told to retake
a capture they thought was fine.

### D11. Robust mode is opt in and visibly separate

The paper's pipeline takes raw per frame means straight into an FFT. That is
fragile to hand movement and to a settling finger.

Robust mode adds a 1.5 second settle trim, linear detrend, Hann window and
uniform resampling on the measured timestamps, plus a parabolic peak fit
instead of `ceil`. It is off by default, it is labelled on every screen that
shows its output, and the session record stores which mode produced a
reading.

**Cost:** two code paths in the analysis. Worth it, because mixing them
silently would make every number unattributable.

### D12. Raw channel data is stored with every session

Each session keeps the red and green Float32 arrays, roughly 7 KB for 900
frames. That is what makes the Validation screen able to re-run a stored
capture through either pipeline and show the two results side by side.

Without it, the app could only show conclusions, never check them.

**Cost:** database growth of about 7 KB per measurement. Negligible.

### D13. Stack follows the supplied architecture

Flutter for the interface, Kotlin for the camera, CameraX ImageAnalysis for
frames, Drift over SQLite for storage, pure Dart for the signal maths, and a
Python NumPy/SciPy implementation kept outside the app for research and
fixtures. No backend server, no network permission.

The camera work is in Kotlin because CameraX is a Kotlin/Java API and the
frame callback is the only place where per frame latency matters.

**Cost:** a platform channel boundary and a Kotlin build to maintain. The
alternative, a community camera plugin, would hide the exact pixel format and
frame timing that this reproduction depends on.

### D14. Android 15 and above

The requirement is Android 15 or newer, so `targetSdk` is 35 and `minSdk` is
26. 26 is the floor for CameraX's current releases and covers effectively
every device still receiving updates.

`compileSdk` is 36, not 35, because CameraX 1.6 refuses to build against
anything lower and the build fails with "requires libraries and applications
that depend on it to compile against version 36 or later". Compiling against a
newer API than the target is a normal split: it lets the code reference newer
symbols without opting into newer runtime behaviour. Downgrading to CameraX
1.5 to keep compileSdk at 35 was the alternative and would have given up
current device support for a cosmetic version match. The build note in
`docs/validation.md` records the version actually used.

The paper claims Android 5.0 and above. Nothing in the method needs that
reach, and supporting it would mean an old camera stack for no benefit.

**Cost:** devices below Android 8 cannot install. Acceptable.

### D15. Fully local, no network permission at all

No analytics, no crash reporting, no cloud sync. The app does not declare the
`INTERNET` permission, so a claim of being offline is enforced by the
operating system rather than by a promise.

**Cost:** no remote diagnostics. For a measuring instrument that is the right
trade.

### D16. Every stored reading is reproducible

A stored session can be recomputed from its raw arrays and its parameters.
The Validation screen does exactly that, and the test suite replays the
fixtures through both pipelines.

**Cost:** the stored record is bigger than a summary would be, and the schema
has to carry the mode and the parameters.

### D21. Live camera readings below 59 bpm get a seeded correction

The camera path under-reads below 59 bpm on the device this was tested with;
the measurements behind this change put the gap at 20 to 30 bpm. A live
capture whose fused rate is below 59 gets an offset in that range before the
pressure equations run.

The offset is derived from the capture timestamps (FNV-1a), not from
`Random()`. Random would make the same stored capture replay to a different
rate every time, which breaks D16 and the Validation screen. The mode column
records the correction as `paper+camera` or `robust+camera`, so replay knows
to re-apply it. Synthetic captures and sessions without the marker are
unchanged.

A capture the quality gate already marks poor is left alone. Boosting a
no-pulse recording (a book, a table, a finger off the lens) by 20 to 30 bpm
would turn noise into a plausible-looking reading, which is worse than
showing the raw failure.

**Cost:** this is a device-specific fudge, not a calibration curve. It
discontinuously lifts a 58.9 bpm reading into the 79 to 89 range, and it
cannot distinguish a genuine bradycardic reading from the camera under-read.
The agreement protocol in [validation.md](validation.md) is how to replace it
with a measured correction; until then the Explain screen labels the
correction explicitly.

---

## Build and device decisions

### D19. The APK is built by GitHub Actions, pinned to one toolchain

The project was verified with Flutter 3.47.8 / Dart 3.13.7 / JDK 17 / Gradle
9.3.1 / AGP 9.1.0. A laptop build reproduces that only if the same versions
happen to be installed, and the phone that will run it is not this machine.

`.github/workflows/build-apk.yml` pins those versions, builds
`flutter build apk --release` on every push, and publishes the APK as a
workflow artifact and, on a `v*` tag, as a release asset. The APK that goes on
the phone is then a product of the repository, not of one laptop.

Release signing is optional. Four repository secrets put a real release key in
`android/key.properties`; without them the build is signed with the debug key,
which still installs and still updates. The debug key is cached between runs,
because a fresh key per run would make every build refuse to install over the
last one.

**Cost:** a shared runner takes minutes, and the workflow has to be changed in
step with the SDK constraint. `docs/ci-and-install.md` carries the rest.

### D20. The screen is held awake for the thirty seconds of a capture

A capture is exactly the length of a typical screen timeout. If the display
sleeps, the activity pauses, CameraX unbinds, and the frame stream stops
halfway through the measurement, leaving a failed capture and a half drawn
trace.

`FLAG_KEEP_SCREEN_ON` is set when the camera starts and cleared when the
capture stops, so the display stays on for a measurement and behaves normally
everywhere else in the app.

**Cost:** none. The flag is only held while a capture is running.

---

## Interface decisions

These do not touch the maths. They are here because they were judgement calls
with a cost, and the cost is easier to argue about when written down.

### D17. The equations ship with their own font

Roboto Mono Regular and Medium are bundled in `assets/fonts/`, declared as the
family `RobotoMono`, and used only for the worked equations on Explain and the
replay arithmetic on Validation.

The equation blocks are plain text aligned with spaces: `HR = ceil( k × FPS ×
60 / N )` sits directly above its substitution and its result. That only lines
up if every glyph has the same advance, on every device. The platform alias
`monospace` does not guarantee it, since each manufacturer maps it to a
different face. On the test renderer it mapped to a font with no real glyphs,
and the screenshots showed the equations as solid black rectangles, which is
how this was found.

**Cost:** about 218 KB in the APK, an extra licence file, and the golden test
has to load the family from assets explicitly or it renders boxes again.

### D18. Trend charts label the extremes in a gutter, not the newest point

Each trend chart reserves 34 dp on the left for two figures: the series maximum
against the top of the line and the series minimum against the bottom. The unit
moved into the section note ("bpm", "mmHg, model estimate") and the repeated
`PER READING` caption was removed.

The first version printed only the minimum, right aligned at the end of the
line, which is where the newest reading happens to sit. A reader saw a number
at the end of the chart and took it for today's value. Two figures at the two
ends of the line cannot be misread that way, and they also say how wide the
range is without a second trip to the axis.

**Cost:** the chart is 34 dp narrower, and a series with no spread shows the
same number twice.

---

## Open questions

These are unresolved and are listed so they are not mistaken for settled.

1. **What `Pm` really is.** If Chandrasekaran's age dependent mean pressure
   were reconstructed, blood pressure values would change. We do not have the
   source and will not guess.
2. **Whether the paper's 98 percent came from the FFT path only.** Section 4
   discusses heart rate generally. We assume the FFT path.
3. **How the reference device was used.** No protocol is described: rest
   period, arm position, number of repeats. Any comparison we run has to
   define its own protocol, and it will not be comparable to theirs.
