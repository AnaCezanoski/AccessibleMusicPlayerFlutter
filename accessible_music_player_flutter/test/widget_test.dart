import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:accessible_music_player_flutter/main.dart';

void main() {
  testWidgets('Player carrega com título e artista', (WidgetTester tester) async {
    // Build our app e renderiza o frame inicial
    await tester.pumpWidget(const AccessibleMusicPlayerApp());

    // Verifica se o título da música aparece
    expect(find.text('Nonstop'), findsOneWidget);

    // Verifica se o artista aparece
    expect(find.text('Drake'), findsOneWidget);

    // Verifica se o botão de play/pause existe
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });
}
