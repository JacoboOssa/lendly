import 'package:lendly_app/domain/model/return.dart';

abstract class ReturnRepository {
  Future<Return> createReturn(Return returnData);
  Future<Return?> getReturnByRentalId(String rentalId);
  Future<Return> updateReturnStatus(String returnId, ReturnStatus status);
}

