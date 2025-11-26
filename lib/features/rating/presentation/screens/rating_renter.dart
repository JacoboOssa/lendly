import 'package:flutter/material.dart';

class RatingRenterScreen extends StatefulWidget {
  final String renterName;

  const RatingRenterScreen({Key? key, required this.renterName}) : super(key: key);

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una calificación')),
      );
      return;
    }

    final result = {
      'rating': _rating,
      'comment': _commentController.text.trim(),
    };

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
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
                          color: Color(0xFF5B5670),
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
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText: 'Comentario sobre el producto (opcional)',
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B5670),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Enviar calificación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
