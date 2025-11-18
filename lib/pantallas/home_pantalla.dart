import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'editarperfil_pantalla.dart';
import '../api_service.dart';

class HomePantalla extends StatefulWidget {
  const HomePantalla({Key? key}) : super(key: key);

  @override
  State<HomePantalla> createState() => _HomePantallaState();
}

class _HomePantallaState extends State<HomePantalla> {
  final TextEditingController _searchController = TextEditingController();

  // Data de marcas: nombre legible, asset y url (si aplica)
  final List<Map<String, String?>> _allBrands = [
    {'name': 'Adidas', 'asset': 'assets/imagenes/adidas.png', 'url': 'https://www.adidas.com/us'},
    {'name': 'Nike', 'asset': 'assets/imagenes/nike.png', 'url': 'https://www.nike.com/xl/'},
    {'name': 'Hugo Boss', 'asset': 'assets/imagenes/boss.png', 'url': 'https://www.hugoboss.com.co/'},
    {'name': 'Calvin Klein', 'asset': 'assets/imagenes/calvinklein.png', 'url': 'https://www.calvinklein.us/'},
    {'name': 'Puma', 'asset': 'assets/imagenes/puma.png', 'url': 'https://us.puma.com/us/en'},
    {'name': 'Reebok', 'asset': 'assets/imagenes/reebok.png', 'url': 'https://www.reebok.com/'},
    {'name': 'Tommy', 'asset': 'assets/imagenes/tommy.png', 'url': null},
    {'name': 'Under Armour', 'asset': 'assets/imagenes/underh.png', 'url': 'https://www.underarmour.com/en-us/'},
    // Marcas nuevas (agregadas por el usuario)
    {'name': 'Levis', 'asset': 'assets/imagenes/levis.png', 'url': 'https://www.levi.com/US/en_US/?srsltid=AfmBOooGZCBPz39BqsPtwyD7f4rKtntDGfgeC8OgFYFd_-ggCIWRMYJX'},
    {'name': 'Ralph Lauren', 'asset': 'assets/imagenes/ralphlauren.png', 'url': 'https://www.ralphlauren.com/?_gl=1*1ninpvj*_ga*MTUzMDk1MTMzNS4xNzYzNDI3MzUy*_ga_JWJC3HP9M9*czE3NjM0MjczNTEkbzEkZzEkdDE3NjM0MjczNTEkajYwJGwwJGgw'},
    {'name': 'American Eagle', 'asset': 'assets/imagenes/americaneagle.webp', 'url': 'https://www.ae.com/us/en'},
    {'name': 'Champion', 'asset': 'assets/imagenes/champion.png', 'url': 'https://www.champion.com/?srsltid=AfmBOopxLlIOt-oWqwHseh5ddcdVgkG9eXyezZD8tD6b2UF7NMctpsrV'},
    {'name': 'The North', 'asset': 'assets/imagenes/thenorth.png', 'url': 'https://www.thenorthface.com/en-us'},
    {'name': 'Abercrombie', 'asset': 'assets/imagenes/abercrombi.png', 'url': 'https://www.abercrombie.com/shop/wd-es'},
    {'name': 'New Era', 'asset': 'assets/imagenes/newera.png', 'url': 'https://www.neweracap.com/?srsltid=AfmBOooPKgPgxLrObVV9jKabo_r6_jc8_YPgXIr1aK2OwoH2gLBOF5T8'},
    {'name': 'New Balance', 'asset': 'assets/imagenes/newbalance.png', 'url': 'https://www.newbalance.com/'},
    {'name': 'Skechers', 'asset': 'assets/imagenes/skeachers.png', 'url': 'https://www.skechers.com/?srsltid=AfmBOopluCY6D9bWY64qAeOquQasunDWPjh0Nq9cHZOBhqaYXIJ7OW-W'},
    {'name': 'Converse', 'asset': 'assets/imagenes/converse.png', 'url': 'https://www.converse.com/shop/love-chuck'},
    {'name': 'Columbia', 'asset': 'assets/imagenes/columbia.png', 'url': 'https://www.columbia.com/?srsltid=AfmBOoqeju0lM2t0BbB1LrZhFgA-HzOe7CyKkGtUKsSwwxMd1OEphZBx'},
    {'name': 'Vans', 'asset': 'assets/imagenes/vans.png', 'url': 'https://www.vans.com/es-es'},
    {'name': 'On Cloud', 'asset': 'assets/imagenes/oncloud.png', 'url': 'https://www.on.com/en-us/products/cloud-6-3wf1006?srsltid=AfmBOooQWkH7Y8P4hCJ2dNqJaFYZ3cDkILCiwgizFyvRK0qKiZhjHxJX'},
    {'name': 'Michael', 'asset': 'assets/imagenes/michael.png', 'url': 'https://www.michaelkors.com/'},
    {'name': 'Gap', 'asset': 'assets/imagenes/gap.jpg', 'url': 'https://www.gap.com/'},
    {'name': 'Guess', 'asset': 'assets/imagenes/guess.webp', 'url': 'https://www.guess.com/en-us/home'},
  ];

  late List<Map<String, String?>> _filteredBrands;

  // Paginación
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _filteredBrands = List.from(_allBrands);
    _searchController.addListener(_onSearchChanged);
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBrands = List.from(_allBrands);
      } else {
        _filteredBrands = _allBrands
            .where((b) => (b['name'] ?? '').toLowerCase().contains(query))
            .toList();
      }
      // Al cambiar la búsqueda, volver a la página 0
      _currentPage = 0;
      _pageController.jumpToPage(0);
    });
  }

  Future<void> _maybeOpenIfSingleResult() async {
    if (_filteredBrands.length == 1) {
      final url = _filteredBrands.first['url'];
      if (url != null && url.isNotEmpty) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    }
  }

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

              // Barra de búsqueda (reemplaza el botón 'Añadir artículo')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) async {
                      await _maybeOpenIfSingleResult();
                    },
                    style: const TextStyle(color: Color(0xFF003366)),
                    decoration: InputDecoration(
                      icon: const Icon(Icons.search, color: Colors.grey),
                      hintText: 'Buscar...',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Grid de marcas paginado (6 por página)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _filteredBrands.isEmpty
                    ? Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: Text(
                          'No se encontraron marcas',
                          style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.8)),
                        ),
                      )
                    : Column(
                        children: [
                          SizedBox(
                            // altura fija para que el PageView no crezca indefinidamente
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: ((_filteredBrands.length + 5) / 6).floor(),
                              onPageChanged: (p) => setState(() => _currentPage = p),
                              itemBuilder: (context, pageIndex) {
                                final start = pageIndex * 6;
                                final end = (start + 6) > _filteredBrands.length ? _filteredBrands.length : (start + 6);
                                final pageItems = _filteredBrands.sublist(start, end);
                                return GridView.count(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  padding: const EdgeInsets.only(top: 12),
                                  childAspectRatio: 1.1,
                                  children: pageItems
                                      .map((b) => _brandTile(b['name']!, b['asset']!, b['url']))
                                      .toList(),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Controles numerados (hipervínculos 1..N)
                          Wrap(
                            spacing: 8,
                            children: List.generate(((_filteredBrands.length + 5) / 6).floor(), (i) {
                              final isSelected = i == _currentPage;
                              return TextButton(
                                onPressed: () {
                                  _pageController.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: isSelected ? Colors.white : Colors.white70,
                                ),
                                child: Text('${i + 1}'),
                              );
                            }),
                          ),
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

  Widget _brandTile(String name, String assetPath, String? url) {
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                assetPath,
                fit: BoxFit.cover,
              ),
              // Nombre sobre la imagen (opcional en caso de que la imagen no lo muestre claro)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 0, 0, 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
