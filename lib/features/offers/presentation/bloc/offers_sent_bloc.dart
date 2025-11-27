import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/features/auth/domain/usecases/get_current_user_id_usecase.dart';
import 'package:lendly_app/features/checkout/data/repositories/payment_repository_impl.dart';
import 'package:lendly_app/features/checkout/data/source/payment_data_source.dart';
import 'package:lendly_app/features/offers/data/repositories/rental_repository_impl.dart';
import 'package:lendly_app/features/offers/data/repositories/rental_request_repository_impl.dart';
import 'package:lendly_app/features/offers/data/source/rental_data_source.dart';
import 'package:lendly_app/features/offers/data/source/rental_request_data_source.dart';
import 'package:lendly_app/features/offers/domain/usecases/get_sent_rental_requests_usecase.dart';
import 'package:lendly_app/features/offers/domain/usecases/get_sent_rental_requests_view_usecase.dart';
import 'package:lendly_app/features/product/data/repositories/product_repository_impl.dart';

export 'package:lendly_app/features/offers/domain/usecases/get_sent_rental_requests_view_usecase.dart' show SentRentalRequestView;

// EVENTS
abstract class OffersSentEvent {}

class LoadSentOffersEvent extends OffersSentEvent {}

// STATES
abstract class OffersSentState {}

class OffersSentInitial extends OffersSentState {}

class OffersSentLoading extends OffersSentState {}

class OffersSentLoaded extends OffersSentState {
  final List<SentRentalRequestView> offers;
  OffersSentLoaded(this.offers);
}

class OffersSentError extends OffersSentState {
  final String message;
  OffersSentError(this.message);
}

class OffersSentBloc extends Bloc<OffersSentEvent, OffersSentState> {
  late final GetSentRentalRequestsViewUseCase getUseCase;
  late final GetCurrentUserIdUseCase getCurrentUserIdUseCase;

  OffersSentBloc() : super(OffersSentInitial()) {
    // Instanciar repositories
    final rentalRequestDataSource = RentalRequestDataSourceImpl();
    final rentalDataSource = RentalDataSourceImpl();
    final paymentDataSource = PaymentDataSourceImpl();
    
    final rentalRepository = RentalRepositoryImpl(rentalDataSource);
    final paymentRepository = PaymentRepositoryImpl(paymentDataSource);
    final productRepository = ProductRepositoryImpl();
    final rentalRequestRepository = RentalRequestRepositoryImpl(
      rentalRequestDataSource,
      rentalRepository: rentalRepository,
      paymentRepository: paymentRepository,
      productRepository: productRepository,
    );

    // Instanciar use cases
    final getSentRentalRequestsUseCase = GetSentRentalRequestsUseCase(
      repository: rentalRequestRepository,
    );
    getUseCase = GetSentRentalRequestsViewUseCase(
      getRentalRequestsUseCase: getSentRentalRequestsUseCase,
      productRepository: productRepository,
      rentalRepository: rentalRepository,
    );
    getCurrentUserIdUseCase = GetCurrentUserIdUseCase();

    on<LoadSentOffersEvent>(_onLoadOffers);
  }

  Future<void> _onLoadOffers(
    LoadSentOffersEvent event,
    Emitter<OffersSentState> emit,
  ) async {
    emit(OffersSentLoading());
    try {
      final userId = await getCurrentUserIdUseCase.execute();
      if (userId == null) {
        emit(OffersSentError('Debes iniciar sesión para ver las solicitudes'));
        return;
      }

      final views = await getUseCase.execute(userId);
      emit(OffersSentLoaded(views));
    } catch (e) {
      emit(OffersSentError('Error al cargar las solicitudes: ${e.toString()}'));
    }
  }
}

