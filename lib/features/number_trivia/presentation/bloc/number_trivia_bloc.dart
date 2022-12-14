import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_tdd_learn/core/error/failures.dart';
import 'package:flutter_tdd_learn/core/usecases/usecase.dart';

import 'package:flutter_tdd_learn/core/util/input_converter.dart';
import 'package:flutter_tdd_learn/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_tdd_learn/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:flutter_tdd_learn/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MSG = 'Server Failure';
const String CACHE_FAILURE_MSG = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MSG =
    'Invalid Input - The Number must be a positive integer or zeron';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaState get initialState => Empty();

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter,
  }) : super(Empty()) {
    on<GetTriviaForConcreteNumber>((event, emit) async {
      final inputEither =
          inputConverter.stringToUnsignedInteger(event.numberString);
      inputEither.fold((failure) async* {
        emit(const Error(message: INVALID_INPUT_FAILURE_MSG));
      }, (integer) async {
        emit(Loading());
        final failureOrTrivia =
            await getConcreteNumberTrivia(Params(number: integer));
        _eitherLoadedOrErrorState(failureOrTrivia);
      });
    });
    on<GetTriviaForRandomNumber>((event, emit) async {
      emit(Loading());
      final failureOrTrivia = await getRandomNumberTrivia(NoParams());
      failureOrTrivia.fold((failure) {
        emit(Error(message: _mapFailureToMessage(failure)));
      }, (trivia) {
        emit(Loaded(trivia: trivia));
      });
    });
  }
}

Stream<NumberTriviaState> _eitherLoadedOrErrorState(
  Either<Failure, NumberTrivia> failureOrTrivia,
) async* {
  failureOrTrivia.fold(
    (failure) => Error(message: _mapFailureToMessage(failure)),
    (trivia) => Loaded(trivia: trivia),
  );
}

String _mapFailureToMessage(Failure failure) {
  switch (failure.runtimeType) {
    case ServerFailure:
      return SERVER_FAILURE_MSG;
    case CacheFailure:
      return CACHE_FAILURE_MSG;
    default:
      return 'Unexpected error';
  }
}
