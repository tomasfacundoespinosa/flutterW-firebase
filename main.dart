import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyectofirebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class Producto {
  final String nombre;
  double precio;
  int cantidad;
  final String categoria;

  Producto({
    required this.nombre,
    required this.precio,
    required this.cantidad,
    required this.categoria,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proyecto-FireBase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 2, 232, 248)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Gestion de Stock - Espinosa/Schmidt'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  late List<Producto> _productos = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre o categoría',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {}); // Actualizar la interfaz al cambiar el texto de búsqueda
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _productos.length,
              itemBuilder: (context, index) {
                final producto = _productos[index];
                // Filtrar productos por nombre y categoría
                final bool matchesSearch = producto.nombre.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                    producto.categoria.toLowerCase().contains(_searchController.text.toLowerCase());
                if (!matchesSearch) {
                  return Container(); // Si no hay coincidencias, no mostrar este elemento
                }
                return ListTile(
                  title: Text(producto.nombre),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Precio: \$${producto.precio.toStringAsFixed(2)}'),
                      Text('Cantidad: ${producto.cantidad}'),
                      Text('Categoría: ${producto.categoria}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _eliminarProducto(index),
                  ),
                  onTap: () => _editarProducto(context, index),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _agregarProducto(context),
        label: const Text('Agregar Producto'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _agregarProducto(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    String nombreProducto = "";
    double precioProducto = 0.0;
    int cantidadProducto = 0;
    String categoriaProducto = "";

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Producto'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el nombre del producto.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Nombre del Producto',
                    ),
                    onChanged: (value) => nombreProducto = value,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el precio del producto.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Precio del Producto',
                    ),
                    onChanged: (value) => precioProducto = double.parse(value),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la cantidad inicial.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Cantidad Inicial',
                    ),
                    onChanged: (value) => cantidadProducto = int.parse(value),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la categoría del producto.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Categoría del Producto',
                    ),
                    onChanged: (value) => categoriaProducto = value,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _productos.add(Producto(
                      nombre: nombreProducto,
                      precio: precioProducto,
                      cantidad: cantidadProducto,
                      categoria: categoriaProducto,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _eliminarProducto(int index) {
    setState(() {
      _productos.removeAt(index);
    });
  }

  void _editarProducto(BuildContext context, int index) async {
    final _formKey = GlobalKey<FormState>();
    String nombreProducto = _productos[index].nombre;
    double precioProducto = _productos[index].precio;
    int cantidadProducto = _productos[index].cantidad;
    String categoriaProducto = _productos[index].categoria;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Producto'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    initialValue: nombreProducto,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el nombre del producto.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Nombre del Producto',
                    ),
                    onChanged: (value) => nombreProducto = value,
                  ),
                  TextFormField(
                    initialValue: precioProducto.toString(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el precio del producto.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Precio del Producto',
                    ),
                    onChanged: (value) => precioProducto = double.parse(value),
                  ),
                  TextFormField(
                    initialValue: cantidadProducto.toString(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la cantidad inicial.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Cantidad Inicial',
                    ),
                    onChanged: (value) => cantidadProducto = int.parse(value),
                  ),
                  TextFormField(
                    initialValue: categoriaProducto,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la categoría del producto.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Categoría del Producto',
                    ),
                    onChanged: (value) => categoriaProducto = value,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _productos[index] = Producto(
                      nombre: nombreProducto,
                      precio: precioProducto,
                      cantidad: cantidadProducto,
                      categoria: categoriaProducto,
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}

