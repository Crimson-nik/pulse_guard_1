# PPG Lab: architecture and design

A reproduction of Sharma et al. (2022) as an Android app. This file explains
how the pieces fit and what the interface is trying to be. The paper itself is
walked through in `docs/journal-walkthrough.md`, the choices in
`docs/decisions.md`.

---

## What it is

One person holds a phone, presses a fingertip over the rear camera and torch
for thirty seconds, and gets a heart rate computed exactly the way the paper
computes it, plus a blood pressure estimate from the paper's equations, kept
in a local record that can be re-run at any time.

The app is a reproduction, so it shows its work. Every number is traceable to
an equation, a bin, a frame count or a user input.

---

## System map

```
            camera sensor
                  |
     CameraX ImageAnalysis (Kotlin)
        YUV_420_888, torch on, latest frame only
                  |
        per frame: mean red, mean green, timestamp
                  |  EventChannel, one small map per frame
     +------------------------------------------+
     |  Flutter isolate                          |
     |    capture controller (state machine)     |
     |    ring buffers: Float32List red, green   |
     |    live trace painter                     |
     +------------------------------------------+
                  |  30 seconds, then once
     +------------------------------------------+
     |  ppg_core (pure Dart, no Flutter)         |
     |    quality  -> gate                       |
     |    paper    -> FFT, band, ceil, fuse      |
     |    bp       -> Eqs. (3) to (8)            |
     |    robust   -> opt in second pipeline     |
     +------------------------------------------+
                  |
        Drift over SQLite (local file)
                  |
   Journal, Session detail, Trends, Validation
```

No server. No `INTERNET` permission. Nothing leaves the device.

---

## Boundaries and why they sit there

**Kotlin owns pixels.** The per frame callback is the only latency sensitive
code in the app. Doing YUV conversion in Kotlin keeps 30 frames per second
inside a single loop with no channel traffic, and it makes the exact pixel
format explicit, which matters because the paper's method is defined on frame
averages.

**The channel carries three numbers, not a frame.** Sending a 640x480 buffer
across the platform channel 30 times a second would dominate the CPU budget
and add nothing. The average is computed where the pixels already are.

**`ppg_core` is a separate package with no Flutter import.** The maths is
testable with `dart test` on a laptop, and it is the same code the app runs.
The Python reference in `tools/pyref` is a second implementation used to
generate fixtures, so the Dart cannot quietly drift.

**Drift over SQLite, not a JSON file.** Sessions reference user parameters and
have to support re-analysis, filtering and trend queries. Files would have to
reinvent that.

**No state management package.** A `ChangeNotifier` capture controller and
direct repository streams cover every screen here. Riverpod or Bloc would add
a dependency and an indirection for four pieces of state.

---

## Capture state machine

```
idle --start--> preparing --camera up--> capturing --30 s--> analysing
  ^                 |                        |                    |
  |                 v                        v                    v
  +------------- error  <--------------- error               ready / refused
```

- `preparing`: camera permission, torch on, first frames arriving. Shown
  because CameraX takes a moment and a blank screen looks broken.
- `capturing`: counting down, live trace drawing, quality metrics updating.
  The user can stop early; a short capture is analysed but flagged as such.
- `analysing`: transform runs, off the capture path.
- `ready`: result stored and shown.
- `refused`: quality gate failed. The capture is still stored, marked
  unusable, so the user can see what went wrong.

The controller is the only mutable state in the app. Screens read from it and
from the repository; nothing else holds a copy of the numbers.

---

## Storage

Two tables.

`sessions`: one row per capture. Timestamps, mode, frame count, measured fps,
red and green bpm, fused bpm, peak count, sliding bpm, quality metrics, the
profile used, the blood pressure intermediates, and a verdict column. The
intermediates (ejection time, body surface area, stroke volume, pulse
pressure) are stored rather than recomputed so a stored session stays exactly
what the user saw, even if the code changes later.

`profiles`: age, weight, height, and the default analysis mode. One row, plus
the history of what was used per session.

Raw channel arrays live in `sessions` as BLOBs, Float32, about 7 KB per
session. They are what makes the Validation screen able to replay a real
capture through both pipelines.

---

## Reading a measurement

The result screen answers, in order of what a person actually wants:

1. A heart rate, big, with its unit.
2. Whether to trust it. One line, plus the reason when the answer is no.
3. Blood pressure, clearly labelled as a model estimate.
4. The evidence: red bpm, green bpm, the gap between them, the rejected
   counting method's answer, frame count, measured frame rate.
5. A link into Explain, which shows the equations and this capture's numbers
   inside them.

The rejection method's answer is not decoration. The paper's central finding
is that this counter fails; showing both numbers is the cheapest way to make
that visible.

---

## Visual direction

**The read.** A single purpose instrument, used by one person, in a dark room,
for thirty seconds, then read afterwards in normal light. Not a fitness app,
not a dashboard. It should look like something that reports a measurement and
stands behind it.

**Dials.** Energy 1, rhythm 2, motion 2. Almost flat. The only movement is the
live trace, and the only emphasis is the number.

**Palette.** Warm paper ground, near black ink, one arterial red used for the
heart rate and system warnings, one muted slate for secondary structure.
Light theme is the default because reading happens in light. A dark theme
exists with the same token names for use at night, and it is not the default
because a default dark instrument reads as a style choice rather than as a
response to a dark room.

```
paper      #FBFAF8   page ground
surface    #FFFFFF   cards
ink        #14110F   primary text            18.0:1 on paper
muted      #625C56   secondary text           6.3:1 on paper
hairline   #E4DFD9   rules and borders
artery     #A11D21   measurement and alarm   7.4:1 on paper
slate      #2C4A52   structure and labels    9.1:1 on paper
```

Contrast ratios are computed against the paper ground with the WCAG 2.1
formula. All four text colours clear AA for body text, and ink, artery and
slate also clear AAA. The hairline is a rule, not text, and carries no
information on its own.

**Type.** System sans for prose. Numerals are tabular and set large, because a
number that changes width as it changes value is harder to read. Sizes: 64 for
the primary reading, 34 for secondary readings, 22 for section titles, 15 for
body, 12 for labels with wide tracking.

One family is bundled: Roboto Mono, used only for the worked equations on the
Explain screen and the replay arithmetic on Validation. Those blocks align
their equals signs with spaces, so the glyphs have to be the same width on
every device. Asking the platform for `monospace` does not promise that: the
alias resolves to a different face per manufacturer, and in the golden test it
resolved to a metrically square font the equation filled with solid blocks.
Shipping two weights (Regular and Medium, 109 KB each, Apache 2.0, licence
text in `assets/fonts/README.md`) costs a little size and buys an equation
that reads as one in a screenshot and on a phone.

**Layout.** A single column, 24 dp side margins, 8 dp vertical rhythm unit,
hairline rules instead of cards with shadows, 4 dp corner radius. Nothing
floats above anything else; this is a printed report that happens to be on a
screen.

**Components.** Buttons are rectangles with a clear edge and a pressed state,
minimum 48 dp. Inputs are labelled fields with the unit inside the label
("Weight, kg"), not placeholder text that vanishes. Charts are hand drawn
sparklines: no chart package, no gradients, no area fills, just the line and
its axis. The trend charts put the highest and lowest value of the series in a
narrow left gutter, against the top and bottom of the line, so the reader can
place the shape without hunting for a caption. The first version labelled only
the minimum, at the far end of the line, and it read as if the newest reading
had that value.

**Motion.** 160 ms fades for screen content, a 200 ms fill for the countdown
ring, and the trace draws as data arrives. No bounce, no scale, no shimmer.

**Copy.** Declarative and specific. "Heart rate 73 bpm" not "Your heart rate
is looking good!". Errors name the physical cause ("Almost no pulse was
visible. Cover the lens and flash fully") rather than apologising. No
exclamation marks, no emoji, no measure of enthusiasm.

---

## Screens

| Screen | Job |
|---|---|
| Home | Today's state, the last reading, the way in |
| Measure | Run a 30 second capture, watch the trace, see quality live |
| Result | The reading, the trust verdict, the evidence |
| Explain | The equations, with this capture's numbers substituted |
| Journal | Every session, newest first, with what made it |
| Session detail | One session in full, including the stored trace |
| Validation | Replay a stored capture through both pipelines, compare |
| Trends | Heart rate and the two pressures across sessions |
| Settings | Profile, default mode, about, data deletion |

Nine screens is more than a reproduction needs. Home, Measure, Result,
Journal and Settings are the minimum. Explain and Validation exist because
without them the app cannot show its reasoning, and Trends and Session detail
are what turn records into something a person can look back at.

---

## Accessibility and platform

- Every interactive element is at least 48 dp in both directions.
- Text scales: layouts use `TextScaler` aware widgets, and the primary number
  is the only element allowed to shrink to fit.
- Colour is never the only carrier of meaning: the trust verdict has a word,
  not just a red dot.
- Screen reader labels on the trace describe the trend ("heart rate settled
  near 73") rather than the raw sample count.
- Torch and camera permission are requested in context, with a plain
  explanation of why before the system dialog appears.
- Nothing runs in the background. The capture stops when the app leaves the
  foreground.
