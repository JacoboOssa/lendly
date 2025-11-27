import 'package:lendly_app/domain/model/return.dart';
import 'package:lendly_app/features/return/data/source/return_data_source.dart';
import 'package:lendly_app/features/return/domain/repositories/return_repository.dart';

class ReturnRepositoryImpl implements ReturnRepository {
  final ReturnDataSource dataSource;

  ReturnRepositoryImpl() : dataSource = ReturnDataSourceImpl();

  @override
  Future<Return> createReturn(Return returnData) {
    return dataSource.createReturn(returnData);
  }

  @override
  Future<Return?> getReturnByRentalId(String rentalId) {
    return dataSource.getReturnByRentalId(rentalId);
  }

  @override
  Future<Return> updateReturnStatus(String returnId, ReturnStatus status) {
    return dataSource.updateReturnStatus(returnId, status);
  }
}

