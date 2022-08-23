import 'package:flutter/material.dart';

import 'package:flutter_tdd_learn/features/number_trivia/domain/entities/number_trivia.dart';

class TriviaDisplay extends StatelessWidget {
  final NumberTrivia numberTrivia;
  const TriviaDisplay({
    Key? key,
    required this.numberTrivia,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      child: Column(
        children: [
          Text(
            '${numberTrivia.number}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Expanded(
              child: Center(
            child: SingleChildScrollView(
              child: Text(
                numberTrivia.text,
                style: const TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              ),
            ),
          ))
        ],
      ),
    );
  }
}
