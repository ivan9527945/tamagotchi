import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trump_app/models/game_state.dart';
import 'package:trump_app/screens/main_game_screen.dart';

void main() {
  testWidgets('Main game screen renders without error', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GameState(),
        child: const MaterialApp(home: MainGameScreen()),
      ),
    );
    expect(find.byType(MainGameScreen), findsOneWidget);
  });

  test('GameState initial values are correct', () {
    final gs = GameState();
    expect(gs.hunger, 60);
    expect(gs.energy, 70);
    expect(gs.ego, 40);
  });

  test('Feed increases hunger and energy', () {
    final gs = GameState();
    final initialHunger = gs.hunger;
    final initialEnergy = gs.energy;
    gs.feed('BigMac');
    expect(gs.hunger, greaterThan(initialHunger));
    expect(gs.energy, greaterThanOrEqualTo(initialEnergy));
  });

  test('Tweet scoring works', () {
    final gs = GameState();
    final score = gs.postTweet('FAKE NEWS! CNN IS THE WORST! SAD!');
    expect(score, greaterThan(0));
  });
}
