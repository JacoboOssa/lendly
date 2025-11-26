import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/features/offers/domain/models/offer.dart';
import 'package:lendly_app/features/offers/domain/usecases/get_received_offers_usecase.dart';
import 'package:lendly_app/features/offers/domain/usecases/approve_offer_usecase.dart';
import 'package:lendly_app/features/offers/domain/usecases/reject_offer_usecase.dart';

// EVENTS
abstract class OffersReceivedEvent {}

class LoadOffersEvent extends OffersReceivedEvent {}

class ApproveOfferEvent extends OffersReceivedEvent {
  final String offerId;
  final String pickupPoint;
  ApproveOfferEvent(this.offerId, this.pickupPoint);
}

class RejectOfferEvent extends OffersReceivedEvent {
  final String offerId;
  RejectOfferEvent(this.offerId);
}

// STATES
abstract class OffersReceivedState {}

class OffersInitial extends OffersReceivedState {}

class OffersLoading extends OffersReceivedState {}

class OffersLoaded extends OffersReceivedState {
  final List<Offer> offers;
  OffersLoaded(this.offers);
}

class OffersError extends OffersReceivedState {
  final String message;
  OffersError(this.message);
}

class OfferActionInProgress extends OffersReceivedState {
  final List<Offer> current;
  OfferActionInProgress(this.current);
}

class OfferActionSuccess extends OffersReceivedState {
  final List<Offer> updated;
  final String message;
  OfferActionSuccess(this.updated, this.message);
}

class OffersReceivedBloc
    extends Bloc<OffersReceivedEvent, OffersReceivedState> {
  final GetReceivedOffersUseCase getUseCase;
  final ApproveOfferUseCase approveUseCase;
  final RejectOfferUseCase rejectUseCase;

  OffersReceivedBloc({
    required this.getUseCase,
    required this.approveUseCase,
    required this.rejectUseCase,
  }) : super(OffersInitial()) {
    on<LoadOffersEvent>(_onLoadOffers);
    on<ApproveOfferEvent>(_onApprove);
    on<RejectOfferEvent>(_onReject);
  }

  Future<void> _onLoadOffers(
    LoadOffersEvent event,
    Emitter<OffersReceivedState> emit,
  ) async {
    emit(OffersLoading());
    try {
      final offers = await getUseCase();
      emit(OffersLoaded(offers));
    } catch (e) {
      emit(OffersError(e.toString()));
    }
  }

  Future<void> _onApprove(
    ApproveOfferEvent event,
    Emitter<OffersReceivedState> emit,
  ) async {
    final currentOffers = state is OffersLoaded
        ? (state as OffersLoaded).offers
        : state is OfferActionSuccess
        ? (state as OfferActionSuccess).updated
        : <Offer>[];
    emit(OfferActionInProgress(currentOffers));
    try {
      await approveUseCase(event.offerId, event.pickupPoint);
      final refreshed = await getUseCase();
      emit(OfferActionSuccess(refreshed, 'Oferta aprobada'));
    } catch (e) {
      emit(OffersError(e.toString()));
    }
  }

  Future<void> _onReject(
    RejectOfferEvent event,
    Emitter<OffersReceivedState> emit,
  ) async {
    final currentOffers = state is OffersLoaded
        ? (state as OffersLoaded).offers
        : state is OfferActionSuccess
        ? (state as OfferActionSuccess).updated
        : <Offer>[];
    emit(OfferActionInProgress(currentOffers));
    try {
      await rejectUseCase(event.offerId);
      final refreshed = await getUseCase();
      emit(OfferActionSuccess(refreshed, 'Oferta rechazada'));
    } catch (e) {
      emit(OffersError(e.toString()));
    }
  }
}
