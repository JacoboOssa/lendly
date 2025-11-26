import 'package:flutter/material.dart';
import 'package:lendly_app/core/utils/app_colors.dart';
import 'package:lendly_app/core/utils/toast_helper.dart';
import 'package:lendly_app/core/widgets/loading_spinner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lendly_app/features/rating/presentation/bloc/rating_owner_product_bloc.dart';

class RatingOwnerProductScreen extends StatefulWidget {
  final String rentalId;
  final String ownerUserId;
  final String ownerName;
  final String productId;
  final String productTitle;

  const RatingOwnerProductScreen({
    Key? key,
    required this.rentalId,
    required this.ownerUserId,
    required this.ownerName,
    required this.productId,
    required this.productTitle,
  }) : super(key: key);

  @override
  State<RatingOwnerProductScreen> createState() => _RatingOwnerProductScreenState();
}

class _RatingOwnerProductScreenState extends State<RatingOwnerProductScreen> {
  int _ownerRating = 0;
  int _productRating = 0;
  int _step = 0; // 0 = owner, 1 = product
  final TextEditingController _ownerCommentController = TextEditingController();
  final TextEditingController _productCommentController = TextEditingController();

  @override
  void dispose() {
    _ownerCommentController.dispose();
    _productCommentController.dispose();
    super.dispose();
  }

  void _submit() {
    // Final submit from product step
    if (_ownerRating == 0) {
      ToastHelper.showError(context, 'Por favor califica al propietario');
      return;
    }
    if (_productRating == 0) {
      ToastHelper.showError(context, 'Por favor califica el producto');
      return;
    }

    context.read<RatingOwnerProductBloc>().add(
          SubmitOwnerAndProductRatingsEvent(
            rentalId: widget.rentalId,
            ownerUserId: widget.ownerUserId,
            productId: widget.productId,
            ownerRating: _ownerRating,
            ownerComment: _ownerCommentController.text.trim().isEmpty
                ? null
                : _ownerCommentController.text.trim(),
            productRating: _productRating,
            productComment: _productCommentController.text.trim().isEmpty
                ? null
                : _productCommentController.text.trim(),
          ),
        );
  }

  Widget _buildStarRow(int value, ValueChanged<int> onChanged) {
    return Row(
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return IconButton(
          onPressed: () => onChanged(starIndex),
          icon: Icon(
            value >= starIndex ? Icons.star : Icons.star_border,
            color: const Color(0xFFFFC107),
            size: 32,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RatingOwnerProductBloc, RatingOwnerProductState>(
      listener: (context, state) {
        if (state is RatingOwnerProductSuccess) {
          Navigator.of(context).pop(true);
        } else if (state is RatingOwnerProductError) {
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
                    onTap: () {
                      if (_step == 1) {
                        setState(() => _step = 0);
                        return;
                      }
                      Navigator.pop(context);
                    },
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

            // Progress bar sits below the header/back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 8,
                    child: LinearProgressIndicator(
                      value: (_step + 1) / 2,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFECECEC),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _step == 0 ? _buildOwnerStep() : _buildProductStep(),
                ),
              ),
            ),

            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                    child: BlocBuilder<RatingOwnerProductBloc, RatingOwnerProductState>(
                      builder: (context, state) {
                        final isLoading = state is RatingOwnerProductLoading;
                        return ElevatedButton(
                          onPressed: isLoading ? null : (_step == 0 ? _nextStep : _submit),
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
                              : Text(
                                  _step == 0 ? 'Siguiente' : 'Enviar calificaciones',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _buildOwnerStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Calificar propietario', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1F1F1F))),
        const SizedBox(height: 8),
        const Text('Califica al propietario del producto.', style: TextStyle(fontSize: 14, color: Color(0xFF6D6D6D))),
        const SizedBox(height: 24),

        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: Center(child: Text(widget.ownerName.isNotEmpty ? widget.ownerName[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.ownerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 4), const Text('Propietario', style: TextStyle(color: Color(0xFF9E9E9E)))]),
          ],
        ),

        const SizedBox(height: 16),
        const Text('Calificación', style: TextStyle(fontSize: 14, color: Color(0xFF6D6D6D))),
        _buildStarRow(_ownerRating, (v) => setState(() => _ownerRating = v)),
        const SizedBox(height: 8),
        TextField(
          controller: _ownerCommentController,
          minLines: 6,
          maxLines: 10,
          decoration: InputDecoration(
            hintText: 'Comentario sobre el propietario (opcional)',
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildProductStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Calificar producto', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1F1F1F))),
        const SizedBox(height: 8),
        const Text('Califica el producto que devolviste.', style: TextStyle(fontSize: 14, color: Color(0xFF6D6D6D))),
        const SizedBox(height: 24),

        Row(
          children: [
            Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image, color: Colors.grey)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.productTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 4), const Text('Producto', style: TextStyle(color: Color(0xFF9E9E9E)))])),
          ],
        ),

        const SizedBox(height: 16),
        const Text('Calificación', style: TextStyle(fontSize: 14, color: Color(0xFF6D6D6D))),
        _buildStarRow(_productRating, (v) => setState(() => _productRating = v)),
        const SizedBox(height: 8),
        TextField(
          controller: _productCommentController,
          maxLines: 10,
          decoration: InputDecoration(
            hintText: 'Comentario sobre el producto (opcional)',
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _nextStep() {
    if (_ownerRating == 0) {
      ToastHelper.showError(context, 'Por favor califica al propietario antes de continuar');
      return;
    }

    setState(() => _step = 1);
  }
}
