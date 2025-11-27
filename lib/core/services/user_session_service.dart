import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/features/profile/domain/usecases/get_current_user_usecase.dart';


class UserSessionService {
  static final UserSessionService _instance = UserSessionService._internal();
  factory UserSessionService() => _instance;
  UserSessionService._internal();

  AppUser? _currentUser;
  bool _isLoading = false;

  AppUser? get currentUser => _currentUser;

  String? get userRole => _currentUser?.role;

  bool get isBorrower => _currentUser?.role.toLowerCase() == 'borrower';

  bool get isLender => _currentUser?.role.toLowerCase() == 'lender';


  Future<void> initialize() async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      final getCurrentUserUsecase = GetCurrentUserUsecase();
      _currentUser = await getCurrentUserUsecase.execute();
    } catch (e) {
      _currentUser = null;
    } finally {
      _isLoading = false;
    }
  }

  void updateUser(AppUser user) {
    _currentUser = user;
  }

  void clear() {
    _currentUser = null;
  }

  Future<void> refresh() async {
    _isLoading = true;
    try {
      final getCurrentUserUsecase = GetCurrentUserUsecase();
      _currentUser = await getCurrentUserUsecase.execute();
    } catch (e) {
      _currentUser = null;
    } finally {
      _isLoading = false;
    }
  }
}

