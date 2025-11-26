import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/features/auth/domain/usecases/get_current_user_id_usecase.dart';
import 'package:lendly_app/features/offers/domain/usecases/get_received_rental_requests_usecase.dart';
import 'package:lendly_app/features/offers/domain/usecases/approve_rental_request_usecase.dart';
import 'package:lendly_app/features/offers/domain/usecases/reject_rental_request_usecase.dart';
import 'package:lendly_app/features/offers/data/source/rental_data_source.dart';
import 'package:lendly_app/features/product/data/source/product_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lendly_app/domain/model/rental.dart';

// Modelo de vista que combina RentalRequest con Product, AppUser y Rental
class RentalRequestView {
  final RentalRequest request;
  final Product product;
  final AppUser borrower;
  final Rental? rental; // Información de recogida si está aprobada

  RentalRequestView({
    required this.request,
    required this.product,
    required this.borrower,
    this.rental,
  });
}

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
  final GetReceivedRentalRequestsUseCase getUseCase;
  final ApproveRentalRequestUseCase approveUseCase;
  final RejectRentalRequestUseCase rejectUseCase;
  final GetCurrentUserIdUseCase getCurrentUserIdUseCase;
  final ProductDataSource productDataSource = ProductDataSourceImpl();
  final RentalDataSource rentalDataSource = RentalDataSourceImpl();

  OffersReceivedBloc({
    required this.getUseCase,
    required this.approveUseCase,
    required this.rejectUseCase,
    required this.getCurrentUserIdUseCase,
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
      final userId = await getCurrentUserIdUseCase.execute();
      if (userId == null) {
        emit(OffersError('Debes iniciar sesión para ver las solicitudes'));
        return;
      }

      final requests = await getUseCase.execute(userId);
      
      // Obtener información del producto y del usuario para cada solicitud
      final List<RentalRequestView> views = [];
      for (final request in requests) {
        try {
          // Obtener producto
          final productResponse = await Supabase.instance.client
              .from('items')
              .select()
              .eq('id', request.productId)
              .single();
          final product = Product.fromJson(productResponse);

          // Obtener usuario que solicita
          final borrower = await productDataSource.getOwnerInfo(request.borrowerUserId);
          if (borrower == null) continue;

          // Obtener rental si la solicitud está aprobada
          Rental? rental;
          if (request.status == RentalRequestStatus.approved && request.id != null) {
            rental = await rentalDataSource.getRentalByRequestId(request.id!);
          }

          views.add(RentalRequestView(
            request: request,
            product: product,
            borrower: borrower,
            rental: rental,
          ));
        } catch (e) {
          // Si hay error obteniendo datos, continuar con la siguiente solicitud
          continue;
        }
      }

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

      final requests = await getUseCase.execute(userId);
      
      // Obtener información del producto y del usuario para cada solicitud
      final List<RentalRequestView> views = [];
      for (final request in requests) {
        try {
          // Obtener producto
          final productResponse = await Supabase.instance.client
              .from('items')
              .select()
              .eq('id', request.productId)
              .single();
          final product = Product.fromJson(productResponse);

          // Obtener usuario que solicita
          final borrower = await productDataSource.getOwnerInfo(request.borrowerUserId);
          if (borrower == null) continue;

          // Obtener rental si la solicitud está aprobada
          Rental? rental;
          if (request.status == RentalRequestStatus.approved && request.id != null) {
            try {
              rental = await rentalDataSource.getRentalByRequestId(request.id!);
            } catch (e) {
              // Si no se encuentra el rental, continuar sin él
              rental = null;
            }
          }

          views.add(RentalRequestView(
            request: request,
            product: product,
            borrower: borrower,
            rental: rental,
          ));
        } catch (e) {
          // Si hay error obteniendo datos, continuar con la siguiente solicitud
          continue;
        }
      }

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
