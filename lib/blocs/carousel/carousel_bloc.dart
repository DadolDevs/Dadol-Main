import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'carousel_event.dart';

part 'carousel_state.dart';

class CarouselBloc extends Bloc<CarouselEvent, CarouselState> {
  CarouselBloc() : super(InitialCarouselState());

  @override
  Stream<CarouselState> mapEventToState(CarouselEvent event) async* {
    // TODO: Add your event logic
  }
}
