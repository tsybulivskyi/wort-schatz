import 'package:flutter/material.dart';
import '../flip_card.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            weight: 900,
            color: Colors.pinkAccent,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Second Page'),
      ),
      body: Center(
        child: FlipCard(
          front: Card(
            color: Colors.green,
            elevation: 4,
            child: SizedBox(
              width: 200,
              height: 120,
              child: Center(
                child: Text(
                  'Front  2 Side',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
          ),
          back: Card(
            color: Colors.pink[50],
            elevation: 4,
            child: SizedBox(
              width: 200,
              height: 120,
              child: Center(
                child: Text(
                  'Back Side',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
