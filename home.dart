import 'package:flutter/material.dart';
import 'dataservice.dart'; // Assuming you have a DataService to fetch data
import 'menu.dart'; // To navigate to the menu page

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  bool loading = true;
  List<Shop> shopList = [];

  @override
  void initState() {
    super.initState();
    _fetchShops(); // Fetch the list of shops when the page is loaded
  }

  Future<void> _fetchShops() async {
    try {
      shopList = await DataService.getShops(); // Fetch shop data from DataService
    } catch (e) {
      debugPrint("Error loading shops: $e");
    } finally {
      if (mounted) {
        setState(() {
          loading = false; // Stop loading when data is fetched
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/nutrient_tracking');
        break;
      case 2:
        Navigator.pushNamed(context, '/order_status');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Home', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Shops near you!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: shopList.length,
                    itemBuilder: (context, index) {
                      final shop = shopList[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigate to the menu page for the selected shop
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenuPage(shopName: shop.name),
                            ),
                          );
                        },
                        child: _ShopCard(shop: shop), // Pass shop data to _ShopCard
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart_outlined),
            label: 'Nutrients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Order Status',
          ),
        ],
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final Shop shop;
  const _ShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Image.asset(
              shop.image, // Use shop's image asset
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              shop.name, // Display shop name dynamically
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// Sample Shop class and DataService

class Shop {
  final String name;
  final String image;

  Shop({required this.name, required this.image});
}

class DataService {
  static Future<List<Shop>> getShops() async {
    // Here, you can fetch the data from an API or local storage.
    // For now, let's just return some dummy data.
    await Future.delayed(Duration(seconds: 2)); // Simulating network delay

    return [
      Shop(name: 'Healthy Bowls', image: 'assets/img/healthy_bowl.jpg'),
      Shop(name: 'Fresh Smoothies', image: 'assets/img/smoothie.jpg'),
      Shop(name: 'Vegan Bites', image: 'assets/img/vegan_bite.jpg'),
    ];
  }
}
