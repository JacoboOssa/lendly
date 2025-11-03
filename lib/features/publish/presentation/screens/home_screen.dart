import 'package:flutter/material.dart';

/// Home screen UI (mock data) matching the app visual style.
/// Contains: header (location + cart), search bar, categories row, trending horizontal cards and bottom nav.

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _primary = Color(0xFF98A1BC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeHeader(),
              const SizedBox(height: 20),
              _SearchBar(),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/manage-products'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B5670),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(0, 36),
                    ),
                    child: const Text(
                      'Gestionar mis productos',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _SectionTitle(title: 'Categorías', actionText: 'Ver todo'),
              const SizedBox(height: 12),
              _CategoriesRow(),
              const SizedBox(height: 20),
              _SectionTitle(title: 'Tendencia', actionText: 'Ver todo'),
              const SizedBox(height: 12),
              _TrendingRow(),
              const SizedBox(height: 20),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _HomeBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/publish'),
        backgroundColor: _primary,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location',
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                // use the same color as the scaffold so the pill doesn't create a visible contour
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Cali',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: Color(0xFF6B6B6B),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF5B5670),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Icon(Icons.search, color: Color(0xFF9E9E9E)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Buscar',
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
            ),
          ),
          SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String actionText;
  const _SectionTitle({required this.title, required this.actionText});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        Text(
          actionText,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B6B6B)),
        ),
      ],
    );
  }
}

class _CategoriesRow extends StatelessWidget {
  final List<Map<String, String>> cats = const [
    {'label': 'Tecnología', 'icon': 'devices'},
    {'label': 'Deportes', 'icon': 'sports_soccer'},
    {'label': 'Ocasiones', 'icon': 'celebration'},
    {'label': 'Eventos', 'icon': 'camera_alt'},
    {'label': 'Hogar', 'icon': 'weekend'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = cats[index];
          return Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    _mapIcon(item['icon']!),
                    size: 30,
                    color: const Color(0xFF5B5670),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 72,
                child: Text(
                  item['label']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _mapIcon(String name) {
    switch (name) {
      case 'devices':
        return Icons.phone_iphone;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'celebration':
        return Icons.emoji_events;
      case 'camera_alt':
        return Icons.camera_alt;
      case 'weekend':
        return Icons.weekend;
      default:
        return Icons.category;
    }
  }
}

class _TrendingRow extends StatelessWidget {
  final List<Map<String, String>> items = const [
    {'title': 'Chaqueta Adidas', 'price': r'$148.000/mes', 'img': ''},
    {'title': 'Nike Slides', 'price': r'$55.000/día', 'img': ''},
    {'title': 'Cámara Canon', 'price': r'$66.000/día', 'img': ''},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320, // slightly taller for more vertical separation
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final it = items[index];
          return _TrendingCard(title: it['title']!, price: it['price']!);
        },
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final String title;
  final String price;
  const _TrendingCard({required this.title, required this.price});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 220, // increased width to make the card more elongated
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 240, // taller image area for elongated look
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Container(
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.image, size: 64, color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5B5670),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavIcon(icon: Icons.home_filled, label: 'Inicio', active: true),
            _NavIcon(icon: Icons.notifications_none, label: 'Avisos'),
            const SizedBox(width: 48), // space for FAB
            _NavIcon(icon: Icons.chat_bubble_outline, label: 'Mensajes'),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: _NavIcon(icon: Icons.person_outline, label: 'Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _NavIcon({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: active ? const Color(0xFF5B5670) : const Color(0xFFBDBDBD),
        ),
        // labels removed by design: only icons are shown now
      ],
    );
  }
}
