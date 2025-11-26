import 'package:lendly_app/domain/model/app_user.dart';
import 'package:lendly_app/features/profile/domain/usecases/get_current_user_usecase.dart';

/// Singleton service to cache the current user's role
/// This avoids async calls every time we need to determine the user's role
class UserSessionService {
  static final UserSessionService _instance = UserSessionService._internal();
  factory UserSessionService() => _instance;
  UserSessionService._internal();

  AppUser? _currentUser;
  bool _isLoading = false;

  /// Get the current user (cached)
  AppUser? get currentUser => _currentUser;

  /// Get the current user's role (cached)
  String? get userRole => _currentUser?.role;

  /// Check if user is borrower
  bool get isBorrower => _currentUser?.role.toLowerCase() == 'borrower';

  /// Check if user is lender
  bool get isLender => _currentUser?.role.toLowerCase() == 'lender';

  /// Initialize the session by loading the current user
  /// Should be called after login
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

  /// Update the current user (e.g., after profile update)
  void updateUser(AppUser user) {
    _currentUser = user;
  }

  /// Clear the session (e.g., on logout)
  void clear() {
    _currentUser = null;
  }

  /// Refresh the current user from the database
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

