import 'package:lendly_app/features/profile/domain/repositories/profile_detail_repository.dart';

class GetUserTransactionsCountUseCase {
  final ProfileDetailRepository repository;

  GetUserTransactionsCountUseCase(this.repository);

  Future<int> execute(String userId, String role) async {
    if (role.toLowerCase() == 'lender') {
      return repository.getCompletedRentalsCountForLender(userId);
    } else {
      return repository.getCompletedRentalsCountForBorrower(userId);
    }
  }
}

