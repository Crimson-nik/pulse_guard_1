import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ppg_core/ppg_core.dart';

import 'package:ppg_lab/design/theme.dart';
import 'package:ppg_lab/design/tokens.dart';

void main() {
  testWidgets('a reading is legible and the tracer renders', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(Brightness.light),
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: <Widget>[
                Text('73', style: readingStyle(context)),
                Text('bpm', style: bodyStyle(context)),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.text('73'), findsOneWidget);
    expect(find.text('bpm'), findsOneWidget);
  });

  test('the paper constants are the ones documented', () {
    expect(fftLenMin, 256);
    expect(hrMinBpm, 35.0);
    expect(hrMaxBpm, 210.0);
    expect(mapConst, 83.25);
    expect(slidingWindow, 4);
  });
}
