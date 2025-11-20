import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({Key? key, this.selectedIndex = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const azulFondo = Color(0xFF003366);

    return Container(
      decoration: const BoxDecoration(
        color: azulFondo,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(
            icon: Icons.home,
            label: 'Home',
            selected: selectedIndex == 0,
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
          ),

          // Reemplazo global del ícono de búsqueda por envío / costo importación
          _NavBarItem(
            icon: Icons.local_shipping,
            label: 'Costo import.',
            selected: selectedIndex == 1,
            onTap: () => Navigator.pushNamed(context, '/costo_import'),
          ),

          _NavBarItem(
            icon: Icons.payment,
            label: 'Pagos',
            selected: selectedIndex == 2,
            onTap: () => Navigator.pushNamed(context, '/pagos'),
          ),

          _NavBarItem(
            icon: Icons.inventory,
            label: 'Mi casillero',
            selected: selectedIndex == 3,
            onTap: () => Navigator.pushNamed(context, '/casillero'),
          ),

          _NavBarItem(
            icon: Icons.history,
            label: 'Historial',
            selected: selectedIndex == 4,
            onTap: () => Navigator.pushNamed(context, '/historial'),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selected ? const Color(0xFF2D7DFE) : Colors.white,
            size: 28,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: selected ? const Color(0xFF2D7DFE) : Colors.white,
              fontSize: 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

