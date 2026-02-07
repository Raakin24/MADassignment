import 'package:flutter/material.dart';
import 'dataservice.dart'; // Import DataService

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  bool loading = true; // To show loading spinner until data is fetched

  @override
  void initState() {
    super.initState();
    getShops(); // Fetch the shop data when the page loads
  }

  Future<void> getShops() async {
    try {
      await DataService.getShops();
    } catch (e) {
      debugPrint("Menu load error: $e");
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> _onItemTapped(int index) async {
    // If user taps Home while already on Home, do nothing
    if (index == 1) {
      setState(() => _selectedIndex = 1);
      return;
    }

    // Highlight the tapped tab immediately
    setState(() {
      _selectedIndex = index;
    });

    // Navigate, then when user returns, reset to Home tab
    switch (index) {
      case 0:
        await Navigator.pushNamed(context, '/nutrient_tracking');
        break;
      case 2:
        await Navigator.pushNamed(context, '/order_status');
        break;
    }
    if (!mounted) return;
    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Home', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 16, 8),
                  child: Text(
                    "Shops near you!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: localShopData.length,
                    itemBuilder: (context, index) {
                      final shop = localShopData[index];
                      return GestureDetector(
                        onTap: () {
                          selectedShop = shop;
                          Navigator.pushNamed(
                            context,
                            shop.pathName,
                          );
                        },
                        child: Card(
                          elevation: 2,
                          shadowColor: Colors.black,
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(14),
                                ),
                                child: Image.asset(
                                  'assets/img/${shop.imageName}',
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  10,
                                  12,
                                  2,
                                ),
                                child: Text(
                                  shop.shopName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  0,
                                  12,
                                  12,
                                ),
                                child: Text(
                                  shop.shopLocation,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (i) => _onItemTapped(i),
        iconSize: 20,
        selectedItemColor: Colors.green,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart_outlined),
            label: 'Nutrients',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Order Status',
          ),
        ],
      ),
    );
  }
}
