import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/domain/model/rental_request.dart';
import 'package:lendly_app/domain/model/product.dart';
import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/features/auth/domain/usecases/get_current_user_id_usecase.dart';
import 'package:lendly_app/features/offers/domain/usecases/get_sent_rental_requests_usecase.dart';
import 'package:lendly_app/features/offers/data/source/rental_data_source.dart';
import 'package:lendly_app/features/product/data/source/product_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lendly_app/domain/model/rental.dart';

// Modelo de vista que combina RentalRequest con Product, AppUser (owner) y Rental
class SentRentalRequestView {
  final RentalRequest request;
  final Product product;
  final AppUser owner; // Dueño del producto
  final Rental? rental; // Información de recogida si está aprobada

  SentRentalRequestView({
    required this.request,
    required this.product,
    required this.owner,
    this.rental,
  });
}

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
  final GetSentRentalRequestsUseCase getUseCase;
  final GetCurrentUserIdUseCase getCurrentUserIdUseCase;
  final ProductDataSource productDataSource = ProductDataSourceImpl();
  final RentalDataSource rentalDataSource = RentalDataSourceImpl();

  OffersSentBloc({
    required this.getUseCase,
    required this.getCurrentUserIdUseCase,
  }) : super(OffersSentInitial()) {
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

      final requests = await getUseCase.execute(userId);
      
      // Obtener información del producto y del dueño para cada solicitud
      final List<SentRentalRequestView> views = [];
      for (final request in requests) {
        try {
          // Obtener producto
          final productResponse = await Supabase.instance.client
              .from('items')
              .select()
              .eq('id', request.productId)
              .single();
          final product = Product.fromJson(productResponse);

          // Obtener dueño del producto
          final owner = await productDataSource.getOwnerInfo(product.ownerId);
          if (owner == null) continue;

          // Obtener rental si la solicitud está aprobada
          Rental? rental;
          if (request.status == RentalRequestStatus.approved && request.id != null) {
            rental = await rentalDataSource.getRentalByRequestId(request.id!);
          }

          views.add(SentRentalRequestView(
            request: request,
            product: product,
            owner: owner,
            rental: rental,
          ));
        } catch (e) {
          // Si hay error obteniendo datos, continuar con la siguiente solicitud
          continue;
        }
      }

      emit(OffersSentLoaded(views));
    } catch (e) {
      emit(OffersSentError('Error al cargar las solicitudes: ${e.toString()}'));
    }
  }
}

