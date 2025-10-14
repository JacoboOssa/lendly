import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:lendly_app/features/auth/presentation/bloc/register_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  // Step 1 controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool acceptTerms = false;

  // Step 2 controllers
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool notifyPush = false;
  bool notifyEmail = false;

  int _currentStep = 1; // 1 or 2
  XFile? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    cityController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _goToStep2() {
    if (_formKeyStep1.currentState?.validate() ?? false) {
      if (!acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes aceptar los términos para continuar')),
        );
        return;
      }

      setState(() => _currentStep = 2);
    }
  }

  void _finishRegistration({required bool skipProfile}) {
    // Collect data
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Submit to BLoC (the bloc expects email, password and name)
    try {
      context.read<RegisterBloc>().add(
            SubmitRegisterEvent(
              email: email,
              password: password,
              name: '$firstName $lastName',
            ),
          );
    } catch (_) {
      // If RegisterBloc not available, show a dialog with summary
      final payload = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'phone': skipProfile ? null : phoneController.text.trim(),
        'city': skipProfile ? null : cityController.text.trim(),
        'address': skipProfile ? null : addressController.text.trim(),
        'notifyPush': skipProfile ? false : notifyPush,
        'notifyEmail': skipProfile ? false : notifyEmail,
      };

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Registro (demo)'),
          content: Text('Datos: ${payload.toString()}'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 800);
      if (picked != null) {
        setState(() {
          _profileImage = picked;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo seleccionar la imagen')));
    }
  }

  // _buildProgressBar removed - not used in the current design

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // back button and title area
                Row(
                  children: [
                    // circular back button
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _currentStep == 1 ? 0.5 : 1.0,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(const Color(0xFF98A1BC)),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Crea tu cuenta',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C)),
                ),
                const SizedBox(height: 18),

                // card-like container matching design
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
                    child: _currentStep == 1 ? _buildStep1() : _buildStep2(),
                  ),
                ),

                const SizedBox(height: 18),
                // bottom link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tienes cuenta? ', style: TextStyle(color: Color(0xFF6D6D6D))),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/login'),
                      child: const Text('Ingresa', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _formKeyStep1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: firstNameController,
            decoration: InputDecoration(
              hintText: 'Primer nombre*',
              hintStyle: TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 16,
              ),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: lastNameController,
            decoration: InputDecoration(
              hintText: 'Apellido(s)*',
              hintStyle: TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 16,
              ),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu apellido' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Correo electronico*',
              hintStyle: TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 16,
              ),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa el correo';
              final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
              if (!emailRegex.hasMatch(v.trim())) return 'Correo inválido';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Contraseña*',
              hintStyle: TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 16,
              ),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa la contraseña';
              if (v.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: acceptTerms,
                onChanged: (v) => setState(() => acceptTerms = v ?? false),
              ),
              const Expanded(child: Text('Acepto los términos y condiciones*')),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF98A1BC),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _goToStep2,
              child: const Text('Continuar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _formKeyStep2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Centered profile photo with edit overlay
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _profileImage != null ? FileImage(File(_profileImage!.path)) : null,
                      child: _profileImage == null ? const Icon(Icons.person, size: 48, color: Colors.grey) : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => SafeArea(
                              child: Wrap(
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: const Text('Seleccionar de la galería'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _pickImage(ImageSource.gallery);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: const Text('Tomar foto'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _pickImage(ImageSource.camera);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.edit, size: 18, color: Color(0xFF98A1BC)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Foto de perfil (opcional)', style: TextStyle(color: Color(0xFF6D6D6D))),
                const SizedBox(height: 18),
              ],
            ),
          ),

          // phone and city side by side
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Teléfono',
                    hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: cityController,
                  decoration: InputDecoration(
                    hintText: 'Ciudad',
                    hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // address full width
          TextFormField(
            controller: addressController,
            decoration: InputDecoration(
              hintText: 'Dirección',
              hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          const SizedBox(height: 12),

          // notifications inline
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Checkbox(value: notifyPush, onChanged: (v) => setState(() => notifyPush = v ?? false)),
                    const Flexible(child: Text('Notificaciones push')),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Checkbox(value: notifyEmail, onChanged: (v) => setState(() => notifyEmail = v ?? false)),
                    const Flexible(child: Text('Notificaciones por email')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // actions: stacked vertically for clarity
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF98A1BC),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (_formKeyStep2.currentState?.validate() ?? true) {
                  _finishRegistration(skipProfile: false);
                }
              },
              child: const Text('Finalizar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF98A1BC)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _finishRegistration(skipProfile: true),
              child: const Text('Saltar por ahora', style: TextStyle(color: Color(0xFF98A1BC), fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
