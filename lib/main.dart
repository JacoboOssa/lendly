import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/features/auth/presentation/bloc/login_bloc.dart';
import 'package:lendly_app/features/auth/presentation/bloc/register_bloc.dart';
import 'package:lendly_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:lendly_app/features/auth/presentation/screens/login_screen.dart';
import 'package:lendly_app/features/home/presentation/screens/main_page.dart';
import 'package:lendly_app/features/home/presentation/bloc/get_user_role_bloc.dart';
import 'package:lendly_app/features/publish/presentation/screens/publish_product_screen.dart';
import 'package:lendly_app/features/publish/presentation/screens/manage_products_screen.dart';
import 'package:lendly_app/features/publish/presentation/bloc/create_product_bloc.dart';
import 'package:lendly_app/features/publish/presentation/bloc/manage_products_bloc.dart';
import 'package:lendly_app/features/home/presentation/bloc/available_products_bloc.dart';
import 'package:lendly_app/features/product/presentation/bloc/all_products_bloc.dart';
import 'package:lendly_app/features/product/presentation/screens/all_products_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lendly_app/features/product/presentation/screens/manage_availability_screen.dart';
import 'package:lendly_app/features/return/presentation/screens/return_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://shkdqehaexwwnpivuxeg.supabase.co',
    anonKey: 'sb_publishable_v16gtaKZ5F3hcGN7v7xwJg_d5JWRoco',
  );

  runApp(const MyApp());
}

//SINGLETON DE SUPABASE
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lendly App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) =>
            BlocProvider(create: (_) => LoginBloc(), child: LoginScreen()),
        '/signup': (_) =>
            BlocProvider(create: (_) => RegisterBloc(), child: SignupScreen()),

        '/main': (_) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => GetUserRoleBloc()),
            BlocProvider(create: (_) => AvailableProductsBloc()),
          ],
          child: MainPage(),
        ),

        '/publish': (_) => BlocProvider(
          create: (_) => CreateProductBloc(),
          child: PublishProductScreen(),
        ),

        '/manage-products': (_) {
          return BlocProvider(
            create: (_) => ManageProductsBloc(),
            child: ManageProductsScreen(),
          );
        },

        '/all-products': (_) => BlocProvider(
          create: (_) => AllProductsBloc(),
          child: AllProductsScreen(),
        ),
        '/manage-availability': (_) => const ManageAvailabilityScreen(),
        '/return': (_) => const ReturnScreen(),
      },
    );
  }
}
