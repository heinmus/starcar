import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
  bool isSearching = false;
  int currentTabIndex = 0; // 0: Veículos, 1: Lojas

  final String whatsappNumber = "5581999999999"; 
  final String apiUrl = "https://script.google.com/macros/s/AKfycby4LDzvV2HfMgLrsENcqfmXaF71FWsCfSC7WOAZuvu7Q7YfwZMo8zYF2ejmRiDLjpTb/exec";

  List<Map<String, dynamic>> vehicles = [];
  List<Map<String, dynamic>> filteredVehicles = [];
  List<String> availableStores = ["Todas"];
  String selectedStore = "Todas";

  final TextEditingController searchController = TextEditingController();

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
        final List<Map<String, dynamic>> loadedVehicles = List<Map<String, dynamic>>.from(data);
        
        Set<String> storesSet = {"Todas"};
        for (var car in loadedVehicles) {
          if (car['store'] != null && car['store'].toString().trim().isNotEmpty) {
            storesSet.add(car['store'].toString().trim());
          }
        }

        setState(() {
          vehicles = loadedVehicles;
          availableStores = storesSet.toList();
          _applyFilters();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      String query = searchController.text.toLowerCase().trim();
      
      filteredVehicles = vehicles.where((car) {
        String carStore = car['store']?.toString().toLowerCase() ?? 'geral';
        String carTitle = car['title']?.toString().toLowerCase() ?? '';
        String carYear = car['year']?.toString().toLowerCase() ?? '';

        bool matchesDropdownStore = (selectedStore == "Todas") || 
            (carStore == selectedStore.toLowerCase());
        
        bool matchesSearchQuery = query.isEmpty || 
            carTitle.contains(query) || 
            carYear.contains(query) || 
            carStore.contains(query);

        return matchesDropdownStore && matchesSearchQuery;
      }).toList();
    });
  }

  Map<String, int> getStoreCountsForSearch() {
    Map<String, int> counts = {};
    for (var car in filteredVehicles) {
      String store = car['store']?.toString() ?? 'Geral';
      counts[store] = (counts[store] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> _openWhatsApp(Map<String, dynamic> car) async {
    final String message = "Olá! Gostaria de mais informações sobre o veículo *${car['title']}* (${car['year']}) da loja *${car['store']}* - Valor: ${car['price']}.";
    final Uri url = Uri.parse("https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
        );
      }
    }
  }

  Future<void> addVehicle(String title, String year, String price, String km, String image, String store) async {
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
          "store": store,
        }),
      );
      fetchVehicles();
    } catch (e) {
      // Tratar excecao
    }
  }

  Future<void> updateVehicle(int rowIndex, String title, String year, String price, String km, String image, String store) async {
    try {
      await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "action": "update",
          "rowIndex": rowIndex,
          "title": title,
          "year": year,
          "price": price,
          "km": km,
          "image": image,
          "store": store,
        }),
      );
      fetchVehicles();
    } catch (e) {
      // Tratar excecao
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
      // Tratar excecao
    }
  }

  void _showAddVehicleDialog() {
    final titleController = TextEditingController();
    final yearController = TextEditingController();
    final priceController = TextEditingController();
    final kmController = TextEditingController();
    final imageController = TextEditingController();
    final storeController = TextEditingController(text: selectedStore == "Todas" ? "Matriz" : selectedStore);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Cadastrar Novo Veículo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: storeController, decoration: const InputDecoration(labelText: 'Nome da Loja/Unidade')),
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
                storeController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showEditVehicleDialog(Map<String, dynamic> car) {
    final storeController = TextEditingController(text: car['store']?.toString() ?? 'Matriz');
    final titleController = TextEditingController(text: car['title'].toString());
    final yearController = TextEditingController(text: car['year'].toString());
    final priceController = TextEditingController(text: car['price'].toString());
    final kmController = TextEditingController(text: car['km'].toString());
    final imageController = TextEditingController(text: car['image'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Editar Veículo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: storeController, decoration: const InputDecoration(labelText: 'Nome da Loja/Unidade')),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Modelo/Nome')),
              TextField(controller: yearController, decoration: const InputDecoration(labelText: 'Ano')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Preço')),
              TextField(controller: kmController, decoration: const InputDecoration(labelText: 'Quilometragem')),
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
              updateVehicle(
                car['rowIndex'],
                titleController.text,
                yearController.text,
                priceController.text,
                kmController.text,
                imageController.text,
                storeController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsSummary() {
    if (searchController.text.trim().isEmpty) return const SizedBox.shrink();

    final storeCounts = getStoreCountsForSearch();
    final totalFound = filteredVehicles.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Encontrado(s) $totalFound veículo(s) para "${searchController.text}":',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: storeCounts.entries.map((entry) {
              return Chip(
                backgroundColor: const Color(0xFF0F172A),
                side: const BorderSide(color: Colors.white24),
                label: Text(
                  '${entry.key}: ${entry.value}',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStoresListView() {
    List<String> storesList = availableStores.where((s) => s != "Todas").toList();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: storesList.length,
      itemBuilder: (context, index) {
        String storeName = storesList[index];
        int vehicleCount = vehicles.where((v) => v['store']?.toString().toLowerCase() == storeName.toLowerCase()).toList().length;

        return Card(
          color: const Color(0xFF1E293B),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.amber,
              child: Icon(Icons.store, color: Colors.black),
            ),
            title: Text(storeName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            subtitle: Text('$vehicleCount veículo(s) em estoque', style: const TextStyle(color: Colors.white60)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 16),
            onTap: () {
              setState(() {
                selectedStore = storeName;
                currentTabIndex = 0;
                _applyFilters();
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Digite o modelo (ex: civic)...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: (_) => _applyFilters(),
              )
            : const Text('StarCar'),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  isSearching = false;
                  searchController.clear();
                  _applyFilters();
                } else {
                  isSearching = true;
                }
              });
            },
          ),
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
      body: Column(
        children: [
          // Seletor de Loja no Topo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF0F172A),
            child: Row(
              children: [
                const Icon(Icons.store, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                const Text('Filtro Loja:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedStore,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white),
                    items: availableStores.map((String store) {
                      return DropdownMenuItem<String>(
                        value: store,
                        child: Text(store),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedStore = newValue;
                          _applyFilters();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Resumo da Pesquisa
          _buildSearchResultsSummary(),

          // Conteúdo da Aba
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : currentTabIndex == 1
                    ? _buildStoresListView()
                    : filteredVehicles.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'Nenhum veículo encontrado.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: filteredVehicles.length,
                            itemBuilder: (context, index) {
                              final item = filteredVehicles[index];
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
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.amber.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  item['store']?.toString() ?? 'Geral',
                                                  style: const TextStyle(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
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
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton.icon(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF25D366),
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                                  ),
                                                  onPressed: () => _openWhatsApp(item),
                                                  icon: const Icon(Icons.chat, size: 16),
                                                  label: const Text('Falar na Loja', style: TextStyle(fontSize: 12)),
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
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.amber, size: 20),
                                              onPressed: () => _showEditVehicleDialog(item),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                              onPressed: () => deleteVehicle(item['rowIndex']),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white54,
        currentIndex: currentTabIndex,
        onTap: (index) {
          setState(() {
            currentTabIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Veículos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Lojas',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddVehicleDialog,
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
