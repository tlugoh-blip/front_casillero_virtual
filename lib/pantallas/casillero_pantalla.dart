import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front_casillero_virtual/api_service.dart';
import 'editarperfil_pantalla.dart';
import 'añadir_articulo.dart';

class CasilleroPantalla extends StatefulWidget {
  const CasilleroPantalla({Key? key}) : super(key: key);

  @override
  State<CasilleroPantalla> createState() => _CasilleroPantallaState();
}

class _CasilleroPantallaState extends State<CasilleroPantalla> {
  final TextEditingController _searchController = TextEditingController();
  bool _loading = false;
  List<Map<String, dynamic>> _items = [];

  int? _userId;

  // Lista de categorías disponibles (ajustar si tu backend tiene otras)
  final List<String> _categorias = ['Todos', 'Accesorios', 'Ropa', 'Calzado'];

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    final id = await ApiService.getUserId();
    setState(() => _userId = id);
    await _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    if (_userId == null) return;
    setState(() => _loading = true);
    try {
      final resp = await ApiService.getArticlesByUser(_userId!);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List) {
          setState(() {
            _items = data.map<Map<String, dynamic>>((e) {
              return Map<String, dynamic>.from(e as Map);
            }).toList();
          });
        } else if (data is Map && data['articulos'] is List) {
          setState(() {
            _items = (data['articulos'] as List).map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
          });
        } else {
          setState(() => _items = []);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar artículos: ${resp.statusCode}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _search({String? query, String? categoria}) async {
    // si no hay query ni categoria, no hacemos nada
    if ((query == null || query.trim().isEmpty) && (categoria == null || categoria.trim().isEmpty)) return;
    setState(() => _loading = true);
    try {
      final resp = await ApiService.searchArticles(query: query, categoria: (categoria == 'Todos' ? null : categoria));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List) {
          setState(() {
            _items = data.map<Map<String, dynamic>>((e) {
              return Map<String, dynamic>.from(e as Map);
            }).toList();
          });
        } else {
          setState(() => _items = []);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Respuesta inesperada del servidor')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar: ${resp.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _openAnadirArticulo({Map<String, dynamic>? articulo}) async {
    // Navegamos a la pantalla de añadir/editar y esperamos un resultado dinámico.
    final res = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (_) => AnadirArticuloPantalla(articulo: articulo)),
    );

    // Si la pantalla devolvió true, forzamos recarga completa.
    if (res == true) {
      await _fetchArticles();
      return;
    }

    // Si la pantalla devolvió un Map, intentamos actualizar la lista localmente
    if (res is Map) {
      try {
        final Map<String, dynamic> newItem = Map<String, dynamic>.from(res);
        // Determinar id según distintas claves posibles
        final dynamic newId = newItem['id'] ?? newItem['articuloId'] ?? newItem['codigo'];
        if (newId == null) {
          // si no hay id fiable, recargar como fallback
          await _fetchArticles();
          return;
        }

        final int existingIndex = _items.indexWhere((it) {
          final dynamic id = it['id'] ?? it['articuloId'] ?? it['codigo'];
          return id != null && id == newId;
        });

        setState(() {
          if (existingIndex >= 0) {
            // Reemplazar el artículo existente
            _items[existingIndex] = newItem;
          } else {
            // Insertar al inicio (reciente)
            _items.insert(0, newItem);
          }
        });
        return;
      } catch (e) {
        // Si algo falla al parsear, recargar como fallback
        await _fetchArticles();
        return;
      }
    }

    // Si no devolvió nada útil, no hacemos nada adicional
  }

  // Confirm and delete
  Future<void> _confirmDelete(int articleId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar artículo'),
        content: const Text('¿Estás seguro de eliminar este artículo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        final resp = await ApiService.deleteArticle(articleId);
        if (resp.statusCode == 200 || resp.statusCode == 204) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Artículo eliminado')));
          await _fetchArticles();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: ${resp.statusCode}')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
      }
    }
  }

  // Muestra un menú modal con categorías y busca por la seleccionada
  void _showCategoryMenu() async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _categorias.map((cat) {
              return ListTile(
                title: Text(cat),
                onTap: () => Navigator.pop(context, cat),
              );
            }).toList(),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _searchController.text = selected == 'Todos' ? '' : selected;
      });

      await _search(categoria: selected == 'Todos' ? null : selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    const azulFondo = Color(0xFF002B68);

    return Scaffold(
      backgroundColor: azulFondo,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 ENCABEZADO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/imagenes/upperblanco.png',
                    height: 90,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text(
                      'Upper®',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const EditarPerfilPantalla()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 🔹 TÍTULO
            const Text(
              'Mis artículos',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 BOTÓN AÑADIR ARTÍCULO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: azulFondo,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => _openAnadirArticulo(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, size: 26, color: azulFondo),
                      SizedBox(width: 8),
                      Text('Añadir artículo'),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 CONTENEDOR PRINCIPAL
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Column(
                  children: [
                    // Search field (ahora como desplegable de categorías)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _searchController.text.isNotEmpty ? _searchController.text : null,
                              decoration: const InputDecoration(
                                hintText: 'Selecciona categoría',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: _categorias.map((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat,
                                  child: Text(cat),
                                );
                              }).toList(),
                              onChanged: (value) async {
                                // Actualizar el texto visible y ejecutar búsqueda por categoría
                                setState(() {
                                  _searchController.text = value == 'Todos' ? '' : (value ?? '');
                                });
                                await _search(categoria: value == 'Todos' ? null : value?.toLowerCase());
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Lista de artículos
                    Expanded(
                      child: _items.isEmpty
                          ? const Center(child: Text('No hay artículos', style: TextStyle(color: Colors.black54)))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _items.length,
                              itemBuilder: (context, index) {
                                final it = _items[index];
                                final imageUrl = (it['url'] as String?)?.isNotEmpty == true ? it['url'] as String : ApiService.defaultLogoUrl;
                                final nombre = it['nombre'] ?? 'Sin nombre';
                                final talla = it['talla'] ?? '';
                                final color = it['color'] ?? '';
                                final precio = (it['valorUnitario'] ?? it['precio'])?.toString() ?? '';
                                final id = it['id'] ?? it['articuloId'] ?? it['codigo'];
                                return Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Image.network(
                                          imageUrl,
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Image.network(ApiService.defaultLogoUrl, width: 90, height: 90),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                              const SizedBox(height: 6),
                                              Text('Talla: $talla  Color: $color', style: const TextStyle(color: Colors.black54)),
                                              const SizedBox(height: 6),
                                              Text('Precio: $precio COP', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 64,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                iconSize: 20,
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                                icon: const Icon(Icons.edit, color: Colors.black54),
                                                onPressed: id == null ? null : () => _openAnadirArticulo(articulo: it),
                                              ),
                                              IconButton(
                                                iconSize: 20,
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                                onPressed: id == null ? null : () => _confirmDelete(id as int),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    // 🔹 BOTÓN "IR A PAGAR"
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: azulFondo,
                            foregroundColor: Colors.white, // ✅ texto blanco
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/pagos');
                          },
                          child: const Text(
                            'Ir a pagar',
                            style: TextStyle(
                              color: Colors.white, // ✅ refuerzo de blanco en texto
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔹 MENÚ INFERIOR
            Container(
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
                    onTap: () => Navigator.pushNamed(context, '/home'),
                  ),
                  _NavBarItem(icon: Icons.search, label: 'Buscar', onTap: () {}),
                  _NavBarItem(
                    icon: Icons.payment,
                    label: 'Pagos',
                    onTap: () => Navigator.pushNamed(context, '/pagos'),
                  ),
                  _NavBarItem(icon: Icons.inventory, label: 'Mi casillero', selected: true),
                  _NavBarItem(icon: Icons.history, label: 'Historial'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 CARD DE PRODUCTO (no cambia mucho)
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool selected;

  const _NavBarItem({Key? key, required this.icon, required this.label, this.onTap, this.selected = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: selected ? Colors.white : Colors.white70),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: selected ? Colors.white : Colors.white70)),
        ],
      ),
    );
  }
}
