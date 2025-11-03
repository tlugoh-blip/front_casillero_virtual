import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'editarperfil_pantalla.dart';
import '../api_service.dart';

class HomePantalla extends StatelessWidget {
  const HomePantalla({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003366),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 32, left: 24, right: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/imagenes/upperblanco.png',
                      height: 88,
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.person, color: Colors.white, size: 36),
                      onSelected: (value) async {
                        if (value == 'editar') {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const EditarPerfilPantalla()),
                          );
                        } else if (value == 'cerrar') {
                          await ApiService.clearUserId();
                          // Llevar al usuario a la pantalla de bienvenida / login
                          Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'editar', child: Text('Editar perfil')),
                        const PopupMenuItem(value: 'cerrar', child: Text('Cerrar sesión')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 🔹 Título centrado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Casillero Virtual',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Para explorar marcas, dale clic a la marca que desees.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color.fromRGBO(255, 255, 255, 0.8),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Botón Añadir artículo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF003366),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Añadir artículo'),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Grid de marcas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.1,
                  children: [
                    _brandScrollTile('assets/imagenes/adidas.png', 'https://www.adidas.com/us'),
                    _brandScrollTile('assets/imagenes/nike.png', 'https://www.nike.com/xl/'),
                    _brandScrollTile('assets/imagenes/boss.png', 'https://www.hugoboss.com.co/'),
                    _brandScrollTile('assets/imagenes/calvinklein.png', 'https://www.calvinklein.us/en?cid=paidsearch_ggl_us_brandpla_bau_g-usa-pmax-catchall-unisex-nca_na_na__na&gclsrc=aw.ds&gad_source=1&gad_campaignid=22346720136&gbraid=0AAAAAD0wQr1fO7t0G74FmqARUb-0jK4wI&gclid=EAIaIQobChMIp7C3wsvWkAMVq4NaBR1cVDSrEAAYASAAEgIUxfD_BwE'),
                    _brandScrollTile('assets/imagenes/puma.png', 'https://us.puma.com/us/en?srsltid=AfmBOorYohrFPCtenExBnSlDdTjEIB66LjCIlYLwxA2hLZ0_cYljCp4k'),
                    _brandScrollTile('assets/imagenes/reebok.png', 'https://www.reebok.com/?srsltid=AfmBOor7jCp9GLYBF3a3y8fTeP7pWR-rYbDkR0TZ2-pFG_OSlAMgav-m'),
                    _brandScrollTile('assets/imagenes/tommy.png'),
                    _brandScrollTile('assets/imagenes/underh.png', 'https://www.underarmour.com/en-us/'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Barra de navegación inferior
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF003366),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Cambié la etiqueta a 'Home' y quité const para permitir callbacks
                    _NavBarItem(
                      icon: Icons.home,
                      label: 'Home',
                      selected: true,
                      onTap: () {
                        // Podrías navegar a la misma pantalla /home o refrescar
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                    ),

                    _NavBarItem(
                      icon: Icons.search,
                      label: 'Buscar',
                      onTap: () {
                        // Implementa búsqueda cuando exista la pantalla
                      },
                    ),

                    // Reinsertamos el ítem de Pagos
                    _NavBarItem(
                      icon: Icons.payment,
                      label: 'Pagos',
                      onTap: () {
                        Navigator.pushNamed(context, '/pagos');
                      },
                    ),

                    // Nuevo icono para navegar al casillero del usuario
                    _NavBarItem(
                      icon: Icons.inventory, // icono elegido
                      label: 'Mi casillero',
                      onTap: () {
                        Navigator.pushNamed(context, '/casillero');
                      },
                    ),

                    _NavBarItem(
                      icon: Icons.history,
                      label: 'Historial',
                      onTap: () {
                        // Implementa historial cuando exista la pantalla
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _brandScrollTile(String assetPath, [String? url]) {
    return InkWell(
      onTap: url == null
          ? null
          : () async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
          ),
        ),
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
    // Hacemos el ítem interactivo
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
