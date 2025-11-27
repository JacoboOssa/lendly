import 'package:flutter/material.dart';
import 'package:lendly_app/core/utils/app_colors.dart';
import 'package:lendly_app/core/utils/toast_helper.dart';
import 'package:lendly_app/core/widgets/loading_spinner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/features/rating/presentation/bloc/rating_renter_bloc.dart';

class RatingRenterScreen extends StatefulWidget {
  final String rentalId;
  final String borrowerUserId;
  final String renterName;

  const RatingRenterScreen({
    Key? key,
    required this.rentalId,
    required this.borrowerUserId,
    required this.renterName,
  }) : super(key: key);

  @override
  State<RatingRenterScreen> createState() => _RatingRenterScreenState();
}

class _RatingRenterScreenState extends State<RatingRenterScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) {
      ToastHelper.showError(context, 'Por favor selecciona una calificación');
      return;
    }

    context.read<RatingRenterBloc>().add(
          SubmitBorrowerRatingEvent(
            rentalId: widget.rentalId,
            borrowerUserId: widget.borrowerUserId,
            rating: _rating,
            comment: _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RatingRenterBloc, RatingRenterState>(
      listener: (context, state) {
        if (state is RatingRenterSuccess) {
          Navigator.of(context).pop(true);
        } else if (state is RatingRenterError) {
          ToastHelper.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calificar a ${widget.renterName}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1F1F1F)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Califica al usuario que devolvió el producto',
                      style: TextStyle(fontSize: 14, color: Color(0xFF6D6D6D)),
                    ),
                    const SizedBox(height: 24),

                    // Avatar + name preview
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              widget.renterName.isNotEmpty ? widget.renterName[0].toUpperCase() : 'U',
                              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(widget.renterName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text('Calificación', style: TextStyle(fontSize: 14, color: Color(0xFF6D6D6D))),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        return IconButton(
                          onPressed: () => setState(() => _rating = starIndex),
                          icon: Icon(
                            _rating >= starIndex ? Icons.star : Icons.star_border,
                            color: const Color(0xFFFFC107),
                            size: 32,
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 16),
                    TextField(
                      controller: _commentController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu opinión sobre el arrendatario (opcional)',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<RatingRenterBloc, RatingRenterState>(
                    builder: (context, state) {
                      final isLoading = state is RatingRenterLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Enviar calificación',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
