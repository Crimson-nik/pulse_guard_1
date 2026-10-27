# What the paper actually does

A concept walkthrough of Sharma, Tanwar, Singh, Sharma, Daudra, Singal,
Gadekallu and Pancholi, "Heart rate and blood pressure measurement based on
photoplethysmogram signal using fast Fourier transform", Computers and
Electrical Engineering 101 (2022) 108057.

This document explains the method as the authors wrote it, checks the parts
that can be checked with arithmetic, and says plainly which sentences the
evidence supports. The app is built to this reading. Where the paper is
ambiguous or wrong, the choice we made is recorded in `docs/decisions.md` and
pointed at from here.

Everything numeric below was produced by `tools/pyref/ppg_reference.py`, a
second implementation written independently of the Dart one so that the two
can be compared. Run it with `python3 tools/pyref/ppg_reference.py`.

---

## 1. The signal

Photoplethysmography means "light written pulse". You put a light source
against skin and watch how much light comes back. Blood absorbs more light
than the tissue around it, so when the heart pushes a bolus of blood into the
fingertip the returning light dips, and between beats it recovers.

The phone is a usable instrument for this because it already has the two
parts you need, held millimetres apart: a rear camera and a torch. Press a
fingertip over both and each camera frame becomes one sample of a pulse
waveform.

Two details matter for everything that follows.

**It is a relative measurement.** Nobody knows the absolute brightness of
your finger. Only the ripple on top of the steady level carries pulse
information. The steady part is the DC term, the ripple is the AC term, and
the ratio between them is why the app computes a perfusion index rather than
trusting raw brightness.

**Colour choice is not arbitrary.** The paper averages the red and green
channels of every frame and uses both (Section 3.2.1). Its stated reason is
that skin lit by the torch sits between red and yellow, so green still carries
pulse information even though red dominates. That is true and it is also why
the two channels disagree in practice: they sample slightly different depths
and different amounts of the same signal.

---

## 2. The capture rig

The recipe in Section 3.1 and Algorithm 2:

1. Record 30 seconds with the rear camera, torch on.
2. Android hands the frame buffer over as YUV420SP, not RGB.
3. Convert each frame to RGB.
4. Average the red values of the frame into one number, and the green values
   into another.
5. Append both to two arrays, one value per frame.
6. Keep a frame counter and a wall clock, because the frame rate you get is
   not the frame rate you asked for.

Step 6 is the one that quietly decides the answer. Algorithm 2 line 13 sets
`SamplingFreq = Frames / totalTimeInSecs`, and every later calculation is
scaled by that number. The paper never says what to do when a phone delivers
23 fps instead of 30, which is why the app measures the rate from timestamps
rather than assuming a value.

Step 4 throws away almost everything. A 640 by 480 frame becomes one number.
That is deliberate: the mean over many pixels suppresses sensor noise by
roughly the square root of the pixel count, and it is the cheapest possible
pipeline for a phone. It also means a moving finger, which changes the
average through shading rather than through blood, corrupts the sample
completely. The paper acknowledges this at the end of Section 4 ("if you do
not place your finger properly, there may be false values") but the method
itself has no defence against it.

---

## 3. Method A, the sliding average, and why it fails

Algorithm 1 is a peak counter. Walk the red array. For each frame, compare it
to the mean of the previous four. If the current frame is above that mean and
a flag is down, count a peak and raise the flag. If it drops to or below the
mean, lower the flag. At the end, `Beats = count * 2`, because 30 seconds of
peaks doubled is a per-minute rate.

The flag is doing one job: it stops the counter from firing on every frame of
a rising edge. Figs. 1 to 10 in the paper are the authors walking through ten
consecutive frames by hand, which is a fair sign that the state machine was
harder to get right than it looks.

Three things go wrong.

**The doubling assumes exactly one peak per beat.** Every error in the count
is doubled with it.

**The threshold is relative to the last four frames, so it is a
zero-crossing detector, not a peak detector.** On a clean pulse, one systolic
rise gives one crossing. Add any ripple and each ripple adds a crossing. A
slow baseline drift also moves the mean under the signal and produces
crossings that have nothing to do with a heartbeat.

**Real pulses have a second bump.** The authors report this as the reason the
method failed on 60 percent of their comparisons with a digital monitor, and
they attribute the two bumps to atrial contraction followed by ventricular
contraction.

The empirical finding is real and easy to reproduce. `synth_ppg` in the
reference file builds a pulse with a second harmonic, and on a 72 bpm pulse
the counter returns 37 peaks in 30 seconds, which doubles to 74, and with a
stronger second harmonic it returns 144 for a 72 bpm signal. The app ships
that second case as a fixture so the failure is visible rather than asserted.

The proposed mechanism is the part to be careful about. In standard PPG
physiology the second bump in a fingertip volume pulse is the dicrotic wave,
produced by aortic valve closure and the reflection of the pressure wave off
the lower body, not by atrial contraction. Atrial contraction happens before
ventricular ejection and does not create a separate volume pulse at the
finger at twice the heart rate. Nothing in the app depends on which
explanation is right: the counter is wrong either way, and the fix is the
same.

---

## 4. Method B, the transform

Algorithm 2 keeps the same capture, adds the green channel, and replaces the
counter with a spectrum.

    HR = ceil( f * FPS * 60 / N )                                      (2)

Here `f` is the frequency of maximum amplitude, `FPS` is the measured frame
rate, `N` is the FFT length, and `ceil` rounds up. The red array goes through
the transform, then the green array, each gives a rate, and the rate that is
reported is their mean.

Read the units carefully, because the paper does not. `f * FPS` is not
meaningful if `f` is a bin index; `f * FPS / N` is. The only reading under
which Eq. (2) is dimensionally consistent is that `f` is the bin index `k`,
so `k * FPS / N` is hertz and the factor 60 converts to per minute. The app
implements that reading. Algorithm 2's own line 15, `bpm = ceil(Freq * 60)`,
is consistent with it as long as the FFT helper returns hertz rather than a
bin number, which is presumably what the authors' code did.

**The band limit.** Section 3.2.2 says analysis "has been started after 35 Hz
frequency because it is understood that no human beings have such a low heart
rate". 35 Hz is 2100 beats per minute, so the unit is wrong. The sentence
means 35 beats per minute, which is 0.583 Hz. The app therefore searches the
band 35 to 210 bpm, and the ceiling of 210 is ours: the paper states only a
floor. Without a ceiling the search would wander into the noise floor at high
bins, and there is no heart rate above 210 worth reporting.

**One step the paper omits.** A constant offset lands entirely in bin 0 when
the transform length equals the number of samples, and the band limit throws
bin 0 away, so the authors can send raw brightness averages into their
transform and never notice. Padding to a power of two breaks that: the zero
fill leaves a step at the end of the buffer whose leakage spreads across the
spectrum. On a signal with mean 200, the leakage at 40 bpm can outrank the
true peak at 72 bpm. Both implementations subtract the channel mean first,
which changes no bin above 0 and costs nothing.

**Why the peak of the spectrum is the heart rate.** A pulse that repeats 72
times a minute is, to a first approximation, a 1.2 Hz oscillation plus
harmonics. The FFT sorts the signal by how much of each frequency it contains.
The biggest bin inside the band is the cardiac fundamental, so reading that
bin gives the rate. The approximation is crude, since pulse shape is far from
sinusoidal, but it is robust to everything the counting method was fragile
about: ripples, baseline drift and amplitude changes all live in other bins.

**And a caveat the paper does not mention.** "Biggest bin wins" means the
method reports whichever harmonic is strongest. If the dicrotic wave is
stronger than the systolic peak, the answer doubles. Our stress fixture does
exactly that and the FFT returns 145 bpm for a 72 bpm signal. In real
fingertip pulses the fundamental is normally dominant, so this is a failure
mode rather than the expected case, but it is the same failure the sliding
average has, only quieter. The app shows the red-green disagreement and the
prototype counter's answer next to the FFT result for exactly this reason: a
reading you cannot cross-check is a reading you should not trust.

---

## 5. What resolution the method can possibly have

This is the most useful piece of arithmetic in the paper, and the paper does
not do it.

The bins of an N point transform sampled at FPS hertz are spaced

    delta_f = FPS / N  hertz,  which is  FPS * 60 / N  beats per minute.

A 30 second capture at 30 fps is 900 samples. Zero pad to the next power of
two, 1024, and the spacing is

    30 * 60 / 1024 = 1.758 bpm.

The winning bin is at most half a bin from the true rate, so up to 0.88 bpm
of error comes from binning alone, and `ceil` then adds up to another whole
bin, worth 1.758 bpm, in the upward direction. The method's floor is
therefore about 2.6 bpm of upward bias on a perfectly clean signal, and the
paper's reported "error of plus or minus 2" sits right on that floor.

That is worth stating plainly: an error of 2 bpm does not demonstrate a good
method, it demonstrates arithmetic. It also predicts the paper's own table.
On the clean 72 bpm fixture the app returns 73, which is exactly the +1 the
bin grid and the ceiling predict, and the five row table in Section 4 shows
observed values of 75, 78, 82, 85 and 87 against actual 75, 80, 81, 83 and 88,
which is consistent with quantisation, not with an accuracy claim.

Shortening the capture moves the grid, not the method:

| Capture | Frames at 30 fps | N | Bin spacing |
|---|---|---|---|
| 10 s | 300 | 512 | 3.52 bpm |
| 20 s | 600 | 1024 | 1.758 bpm |
| 30 s | 900 | 1024 | 1.758 bpm |
| 60 s | 1800 | 2048 | 0.879 bpm |

The reference fixtures include a 10 second capture of a 76 bpm signal which
comes back as 78, a 2 bpm error that is entirely explained by the coarser
grid. This is why the app refuses to treat a 10 second capture as equivalent
to a 30 second one, and why the capture screen counts the full duration.

---

## 6. Blood pressure

Section 3.3 gets a heart rate from Algorithm 2, asks the user for height,
weight and age, and pushes all four through six equations.

    ET  = 364.5 - 1.23 * HR                                            (3)
    BSA = 0.007184 * W^0.425 * H^0.725                                 (4)
    SV  = -6.6 + 0.25*(ET - 35) - 0.62*HR + 40.4*BSA - 0.51*Age        (5)
    PP  = SV / ((0.013*W - 0.007*Age - 0.004*HR) + 1.307)              (6)
    SBP = 83.25 + (2/3)*PP                                             (7)
    DBP = 83.25 - (1/3)*PP                                             (8)

The named quantities are real clinical concepts. Ejection time is how long
the left ventricle spends pushing blood out. Stroke volume is how much it
pushes. Body surface area is a size normaliser, computed with the Du Bois
formula, which is why Eq. (4) has those odd exponents. Pulse pressure is the
gap between systolic and diastolic, and equations (7) and (8) split that gap
around a fixed mean of 83.25 mmHg.

Worked example, the one that ships as a test: heart rate 80, 70 kg, 175 cm,
25 years.

| Step | Value |
|---|---|
| ET (3) | 364.5 - 1.23 * 80 = **266.1 ms** |
| BSA (4) | 0.007184 * 70^0.425 * 175^0.725 = **1.848 m²** |
| SV (5) | -6.6 + 57.6 - 49.6 + 74.7 - 12.8 = **63.49 mL** |
| PP (6) | 63.49 / 1.722 = **36.87 mmHg** |
| SBP (7) | 83.25 + 24.58 = **107.83 mmHg** |
| DBP (8) | 83.25 - 12.29 = **70.96 mmHg** |

The chain is from Chandrasekaran et al. (2013), cited as reference 25. It is
not fitted to the paper's own subjects, it is not validated against a cuff
anywhere in the paper, and the paper never compares a single blood pressure
number with a reference instrument. Section 4 discusses only heart rate
results and Fig. 18 plots only heart rate. Any statement about the blood
pressure accuracy of this method would be unsupported by the paper.

Two properties of the chain are worth knowing before reading its output.

**Systolic moves the wrong way with heart rate.** The table, computed with
the shipped reference code at 25 years, 70 kg, 175 cm:

| HR | ET ms | SV mL | PP mmHg | SBP / DBP |
|---|---|---|---|---|
| 50 | 303.0 | 91.31 | 49.57 | 116.3 / 66.7 |
| 60 | 290.7 | 82.04 | 45.53 | 113.6 / 68.1 |
| 72 | 275.9 | 70.91 | 40.43 | 110.2 / 69.8 |
| 80 | 266.1 | 63.49 | 36.87 | 107.8 / 71.0 |
| 100 | 241.5 | 44.94 | 27.37 | 101.5 / 74.1 |
| 120 | 216.9 | 26.39 | 16.89 | 94.5 / 77.6 |

A person who climbs stairs gets a faster heart rate and, physiologically, a
higher systolic pressure. This model returns a lower one, because Eq. (3)
shortens ejection time as rate rises and Eq. (5) then shrinks stroke volume.
So the model is descriptive of a resting relationship, and it is inverted
with respect to exercise.

**The chain has a pole.** The divisor in Eq. (6) is
`0.013*W - 0.007*Age - 0.004*HR + 1.307`. At 20 kg, age 110 and 210 bpm it
comes to -0.043, so the pulse pressure flips sign and systolic comes out
below diastolic. That is inside the input ranges the app accepts, so it is
reachable by a user, not a hypothetical. Above roughly 150 bpm the stroke volume in Eq. (5) goes negative
at ordinary body sizes. The paper prints no guard. The app refuses to display
a number in that region and says why, which is a deviation, recorded as D7.

The consequence for the app's honesty: blood pressure here is a model
estimate computed from a heart rate. It is presented as such, labelled, and
never given an accuracy figure.

---

## 7. The evidence the paper actually offers

| Claim in the paper | Where | What backs it |
|---|---|---|
| 98 percent accuracy for heart rate | Abstract, Sections 4 and 5 | Five rows for one subject in Table 1, ten unnamed people in Fig. 18 |
| Error of plus or minus 2 | Section 4 | Same data, no method described for computing it |
| Works on any Android 5.0 and above | Section 4 | Stated, plus two devices named in Fig. 18's caption |
| Blood pressure from heart rate | Section 3.3 | Equations and a cited model. No comparison with any reference |
| 60 percent of sliding average readings wrong | Section 3.1 | Stated, no table |
| "More accurate and faster than previous techniques" | Contributions | No head to head measurement is shown |

That is the full evidence base. It is thin in the usual way for this genre:
one subject, a handful of points, no confidence intervals, no protocol for how
the reference device was used, no exclusion criteria.

Nothing in that list makes the method wrong. The FFT approach is sound, the
physiology is mostly right, and the arithmetic works. What it means for this
project is that we reproduce the method and claim only what we measured
ourselves, which is why `docs/validation.md` exists and why the app never
prints "98 percent".

---

## 8. Errors and ambiguities, itemised

| # | Item | Problem | What the app does |
|---|---|---|---|
| 1 | "after 35 Hz" | 35 Hz is 2100 bpm | reads it as 35 bpm, band 35 to 210, D2 |
| 2 | Eq. (2) `f * FPS * 60 / N` | only consistent if `f` is a bin index, otherwise the units do not close | implements `k * FPS * 60 / N`, D1 and D4 |
| 3 | Alg. 1 line 12 | sums four frames and calls it an average | uses the mean, as the prose says, D5 |
| 4 | Alg. 2 line 15 | `ceil(Freq * 60)` omits FPS and N that Eq. (2) has | consistent if the helper returns hertz, which is how we read it |
| 5 | Alg. 3 line 4 | "body surface area in millimeters squared" | Du Bois is cm/kg and yields m², D6 |
| 6 | Eqs. (7) and (8) | `Pm = 83.25` is never defined | kept literally as a constant, D3 |
| 7 | Section 3.1 failure reason | attributes the second peak to atrial contraction | noted in Section 3 above, no code depends on it |
| 8 | Frame rate | assumed constant, never measured in the pseudocode | measured from timestamps |
| 9 | Blood pressure validation | none anywhere in the paper | never reported as accurate, D7 |
| 10 | No code, data or app | no repository, no APK, no dataset | this project is a from scratch reproduction |

The neighbouring literature that the paper compares itself against has the
same shape. Sukaphat (reference 2) uses Eq. (1), which is the same transform
with the same ceiling, and reports 0.57 percent average discrepancy. The
methods are the same family; the numbers are not comparable across papers
because the protocols are not described.

---

## 9. What a faithful app has to contain

Reading the paper as a specification gives this minimum:

- a 30 second capture from the rear camera with the torch on, using the whole
  frame average per channel, red and green;
- a measured frame rate, not an assumed one;
- the sliding average counter kept as a cross check, since the paper's
  central lesson is that it fails;
- the FFT path with a band limit, per channel, averaged;
- height, weight and age as user input feeding Eqs. (3) to (8);
- a record of each session with those inputs, because the paper says the
  database is used to analyse accuracy.

Everything else in the app (quality gate, trends, robust mode, the Explain
screen) exists to keep a user from believing a number that the method cannot
support. Those are additions, and they are labelled as additions in the
interface.

Next: `docs/app-walkthrough.md` walks the screens, `docs/decisions.md`
records every choice above as a decision, and `docs/validation.md` describes
how to check the app against a real reference device.
