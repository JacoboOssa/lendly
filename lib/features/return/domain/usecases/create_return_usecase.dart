import 'package:flutter/material.dart';
import 'package:lendly_app/domain/model/return.dart';
import 'package:lendly_app/domain/model/rental.dart';
import 'package:lendly_app/features/return/data/repositories/return_repository_impl.dart';
import 'package:lendly_app/features/return/data/source/return_data_source.dart';
import 'package:lendly_app/features/return/domain/repositories/return_repository.dart';
import 'package:lendly_app/features/offers/data/repositories/rental_repository_impl.dart';
import 'package:lendly_app/features/offers/data/source/rental_data_source.dart';
import 'package:lendly_app/features/offers/domain/repositories/rental_repository.dart';

class CreateReturnUseCase {
  final ReturnRepository returnRepository;
  final RentalRepository rentalRepository;

  CreateReturnUseCase({
    ReturnRepository? returnRepository,
    RentalRepository? rentalRepository,
  })  : returnRepository = returnRepository ??
            ReturnRepositoryImpl(ReturnDataSourceImpl()),
        rentalRepository = rentalRepository ??
            RentalRepositoryImpl(RentalDataSourceImpl());

  Future<Return> execute({
    required String rentalId,
    required TimeOfDay proposedReturnTime,
    String? note,
  }) async {
    // Crear el return
    final returnData = Return(
      rentalId: rentalId,
      proposedReturnTime: proposedReturnTime,
      note: note,
      status: ReturnStatus.pending,
      createdAt: DateTime.now(),
    );

    final createdReturn = await returnRepository.createReturn(returnData);

    // Actualizar el status del rental a COMPLETED
    await rentalRepository.updateRentalStatus(rentalId, RentalStatus.completed);

    return createdReturn;
  }
}

