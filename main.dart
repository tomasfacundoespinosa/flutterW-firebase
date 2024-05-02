import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class Producto {
  final String nombre;
  final double precio;
  final int cantidad;

  const Producto({
    required this.nombre,
    required this.precio,
    required this.cantidad,
  });

  // Add a method to convert the product to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'precio': precio,
      'cantidad': cantidad,
    };
  }
}

Future<void> agregarProducto(BuildContext context) async {
  final _formKey = GlobalKey<FormState>();
  String nombreProducto = "";
  double precioProducto = 0.0;
  int cantidadProducto = 0;

  return showDialog(
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
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // Add product to Firestore
                await _guardarProductoEnFirestore(
                  Producto(
                    nombre: nombreProducto,
                    precio: precioProducto,
                    cantidad: cantidadProducto,
                  ),
                );
                // Show success message or navigate back
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

Future<void> _guardarProductoEnFirestore(Producto producto) async {
  // Create a reference to the products collection
  final firebase = FirebaseFirestore.instance;

  // Add the product data to the collection
  await firebase.collection('productos').add(producto.toMap());
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
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      //APPBAR

      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),

      //BODY

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => agregarProducto(context),
        tooltip: 'Agregar Producto',
        child: const Icon(Icons.add),
      ),
    );
  }
}
