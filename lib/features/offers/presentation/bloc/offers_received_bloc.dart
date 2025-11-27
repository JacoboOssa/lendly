import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/features/auth/domain/usecases/get_current_user_id_usecase.dart';
import 'package:lendly_app/features/checkout/data/repositories/payment_repository_impl.dart';
import 'package:lendly_app/features/checkout/data/source/payment_data_source.dart';
import 'package:lendly_app/features/offers/data/repositories/rental_repository_impl.dart';
import 'package:lendly_app/features/offers/data/repositories/rental_request_repository_impl.dart';
import 'package:lendly_app/features/offers/data/source/rental_data_source.dart';
import 'package:lendly_app/features/offers/data/source/rental_request_data_source.dart';
import 'package:lendly_app/features/offers/domain/usecases/approve_rental_request_usecase.dart';
import 'package:lendly_app/features/offers/domain/usecases/get_received_rental_requests_usecase.dart';
import 'package:lendly_app/features/offers/domain/usecases/get_received_rental_requests_view_usecase.dart';
import 'package:lendly_app/features/offers/domain/usecases/reject_rental_request_usecase.dart';
import 'package:lendly_app/features/product/data/repositories/product_repository_impl.dart';

export 'package:lendly_app/features/offers/domain/usecases/get_received_rental_requests_view_usecase.dart' show RentalRequestView;

// EVENTS
abstract class OffersReceivedEvent {}

class LoadOffersEvent extends OffersReceivedEvent {}

class ApproveOfferEvent extends OffersReceivedEvent {
  final String requestId;
  final String pickupLocation;
  final DateTime pickupAt;
  ApproveOfferEvent(this.requestId, this.pickupLocation, this.pickupAt);
}

class RejectOfferEvent extends OffersReceivedEvent {
  final String requestId;
  RejectOfferEvent(this.requestId);
}

// STATES
abstract class OffersReceivedState {}

class OffersInitial extends OffersReceivedState {}

class OffersLoading extends OffersReceivedState {}

class OffersLoaded extends OffersReceivedState {
  final List<RentalRequestView> offers;
  OffersLoaded(this.offers);
}

class OffersError extends OffersReceivedState {
  final String message;
  OffersError(this.message);
}

class OfferActionInProgress extends OffersReceivedState {
  final List<RentalRequestView> current;
  OfferActionInProgress(this.current);
}

class OfferActionSuccess extends OffersReceivedState {
  final List<RentalRequestView> updated;
  final String message;
  OfferActionSuccess(this.updated, this.message);
}

class OffersReceivedBloc
    extends Bloc<OffersReceivedEvent, OffersReceivedState> {
  late final GetReceivedRentalRequestsViewUseCase getUseCase;
  late final ApproveRentalRequestUseCase approveUseCase;
  late final RejectRentalRequestUseCase rejectUseCase;
  late final GetCurrentUserIdUseCase getCurrentUserIdUseCase;

  OffersReceivedBloc() : super(OffersInitial()) {
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
    final getReceivedRentalRequestsUseCase = GetReceivedRentalRequestsUseCase(
      repository: rentalRequestRepository,
    );
    getUseCase = GetReceivedRentalRequestsViewUseCase(
      getRentalRequestsUseCase: getReceivedRentalRequestsUseCase,
      productRepository: productRepository,
      rentalRepository: rentalRepository,
    );
    approveUseCase = ApproveRentalRequestUseCase(
      rentalRequestRepository: rentalRequestRepository,
      rentalRepository: rentalRepository,
      paymentRepository: paymentRepository,
      productRepository: productRepository,
    );
    rejectUseCase = RejectRentalRequestUseCase(
      repository: rentalRequestRepository,
    );
    getCurrentUserIdUseCase = GetCurrentUserIdUseCase();

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
      final userId = await getCurrentUserIdUseCase.execute();
      if (userId == null) {
        emit(OffersError('Debes iniciar sesión para ver las solicitudes'));
        return;
      }

      final views = await getUseCase.execute(userId);
      emit(OffersLoaded(views));
    } catch (e) {
      emit(OffersError('Error al cargar las solicitudes: ${e.toString()}'));
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
        : <RentalRequestView>[];
    emit(OfferActionInProgress(currentOffers));
    try {
      // Ejecutar el use case que actualiza el estado y crea el rental
      final approvedRequest = await approveUseCase.execute(
        event.requestId,
        event.pickupLocation,
        event.pickupAt,
      );
      
      // Verificar que la solicitud se aprobó correctamente
      if (approvedRequest.status != RentalRequestStatus.approved) {
        emit(OffersError('Error: La solicitud no se aprobó correctamente'));
        return;
      }
      
      // Recargar las ofertas para obtener los datos actualizados
      final userId = await getCurrentUserIdUseCase.execute();
      if (userId == null) {
        emit(OffersError('Debes iniciar sesión para ver las solicitudes'));
        return;
      }

      final views = await getUseCase.execute(userId);

      // Emitir estado de éxito con las ofertas actualizadas
      emit(OfferActionSuccess(views, 'Solicitud aprobada exitosamente'));
      // También emitir OffersLoaded para que la UI se actualice
      emit(OffersLoaded(views));
    } catch (e, stackTrace) {
      // Log del error para debugging
      print('Error en _onApprove: $e');
      print('Stack trace: $stackTrace');
      emit(OffersError('Error al aprobar la solicitud: ${e.toString()}'));
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
        : <RentalRequestView>[];
    emit(OfferActionInProgress(currentOffers));
    try {
      await rejectUseCase.execute(event.requestId);
      // Recargar las ofertas
      add(LoadOffersEvent());
    } catch (e) {
      emit(OffersError('Error al rechazar la solicitud: ${e.toString()}'));
    }
  }
}
