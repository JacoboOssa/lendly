import 'package:lendly_app/features/profile/data/repositories/profile_detail_repository_impl.dart';
import 'package:lendly_app/features/profile/data/source/profile_detail_data_source.dart';
import 'package:lendly_app/features/profile/domain/repositories/profile_detail_repository.dart';

class GetUserTransactionsCountUseCase {
  final ProfileDetailRepository repository;

  GetUserTransactionsCountUseCase() : repository = ProfileDetailRepositoryImpl(ProfileDetailDataSourceImpl());

  Future<int> execute(String userId, String role) async {
    if (role.toLowerCase() == 'lender') {
      return repository.getCompletedRentalsCountForLender(userId);
    } else {
      return repository.getCompletedRentalsCountForBorrower(userId);
    }
  }
}

