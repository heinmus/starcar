import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const StarCarApp());
}

class StarCarApp extends StatelessWidget {
  const StarCarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StarCar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E293B),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        useMaterial3: true,
      ),
      home: const CatalogScreen(),
    );
  }
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  bool isPresentationMode = false;
  bool isLoading = true;
  List<Map<String, dynamic>> vehicles = [];

  final String apiUrl = "https://script.google.com/macros/s/AKfycby4LDzvV2HfMgLrsENcqfmXaF71FWsCfSC7WOAZuvu7Q7YfwZMo8zYF2ejmRiDLjpTb/exec";

  @override
  void initState() {
    super.initState();
    fetchVehicles();
  }

  Future<void> fetchVehicles() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          vehicles = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> addVehicle(String title, String year, String price, String km, String image) async {
    try {
      await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "action": "add",
          "title": title,
          "year": year,
          "price": price,
          "km": km,
          "image": image,
        }),
      );
      fetchVehicles();
    } catch (e) {
      // Tratar exceção
    }
  }

  Future<void> deleteVehicle(int rowIndex) async {
    try {
      await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "action": "delete",
          "rowIndex": rowIndex,
        }),
      );
      fetchVehicles();
    } catch (e) {
      // Tratar exceção
    }
  }

  void _showAddVehicleDialog() {
    final titleController = TextEditingController();
    final yearController = TextEditingController();
    final priceController = TextEditingController();
    final kmController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Cadastrar Novo Veículo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Modelo/Nome')),
              TextField(controller: yearController, decoration: const InputDecoration(labelText: 'Ano (ex: 2022/2023)')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Preço (ex: R\$ 50.000)')),
              TextField(controller: kmController, decoration: const InputDecoration(labelText: 'Quilometragem (ex: 30.000 km)')),
              TextField(controller: imageController, decoration: const InputDecoration(labelText: 'URL da Imagem')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              addVehicle(
                titleController.text,
                yearController.text,
                priceController.text,
                kmController.text,
                imageController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('StarCar'),
        actions: [
          IconButton(
            icon: Icon(
              isPresentationMode ? Icons.visibility_off : Icons.visibility,
              color: isPresentationMode ? Colors.amber : Colors.white70,
            ),
            onPressed: () => setState(() => isPresentationMode = !isPresentationMode),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchVehicles,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : vehicles.isEmpty
              ? const Center(child: Text('Nenhum veículo cadastrado na planilha.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final item = vehicles[index];
                    return Card(
                      color: const Color(0xFF1E293B),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Image.network(
                                  item['image'].toString(),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.directions_car, size: 50),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['title'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('${item['year']} • ${item['km']}', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                                    const SizedBox(height: 4),
                                    Text(
                                      isPresentationMode ? 'Sob Consulta' : item['price'].toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isPresentationMode ? Colors.amber : Colors.greenAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (!isPresentationMode)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => deleteVehicle(item['rowIndex']),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddVehicleDialog,
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
