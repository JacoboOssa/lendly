import 'package:lendly_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:lendly_app/features/home/domain/repositories/home_repository.dart';

class ListenItemsUpdatesUsecase {
  final HomeRepository repository = HomeRepositoryImpl();

  Stream<String> execute() {
    return repository.listenItemsUpdates();
  }
}
