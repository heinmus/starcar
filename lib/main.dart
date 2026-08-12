import 'package:flutter/material.dart';

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

  final List<Map<String, String>> vehicles = [
    {
      'title': 'Fiat Strada Volcano',
      'year': '2022/2023',
      'price': 'R\$ 98.900',
      'km': '32.000 km',
      'image': 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=600&q=80',
    },
    {
      'title': 'VW Gol 1.0 MC',
      'year': '2021/2021',
      'price': 'R\$ 54.500',
      'km': '48.000 km',
      'image': 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?auto=format&fit=crop&w=600&q=80',
    },
    {
      'title': 'Renault Sandero Stepway',
      'year': '2020/2021',
      'price': 'R\$ 59.900',
      'km': '55.000 km',
      'image': 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?auto=format&fit=crop&w=600&q=80',
    },
    {
      'title': 'Royal Enfield Meteor 350',
      'year': '2023/2023',
      'price': 'R\$ 23.900',
      'km': '8.500 km',
      'image': 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?auto=format&fit=crop&w=600&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.directions_car_filled, color: Colors.amber),
            const SizedBox(width: 8),
            Text(
              'StarCar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPresentationMode ? Colors.amber : Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Modo Apresentação (Cliente)',
            icon: Icon(
              isPresentationMode ? Icons.visibility_off : Icons.visibility,
              color: isPresentationMode ? Colors.amber : Colors.white70,
            ),
            onPressed: () {
              setState(() {
                isPresentationMode = !isPresentationMode;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isPresentationMode
                        ? 'Modo Apresentação ATIVADO (Valores ocultos)'
                        : 'Modo Lojista ATIVADO',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar modelo, ano ou marca...',
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
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
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(item['image']!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item['year']} • ${item['km']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isPresentationMode ? 'Sob Consulta' : item['price']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isPresentationMode ? Colors.amber : Colors.greenAccent,
                                ),
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
      ),
    );
  }
}
