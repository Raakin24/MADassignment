import 'package:flutter/material.dart';
import 'dataservice.dart';

class MenuPage2 extends StatefulWidget {
  final String shopName;
  const MenuPage2({super.key, required this.shopName});

  @override
  State<MenuPage2> createState() => _MenuPage2State();
}

class _MenuPage2State extends State<MenuPage2> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getMenu();
  }

  Future<void> getMenu() async {
    try {
      await DataService.getItemData2();
    } catch (e) {
      debugPrint("$e");
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  int getCartItemCount() {
    int count = 0;
    for (final line in cart.values) {
      count += line.qty;
    }
    return count;
  }

  double getCartTotal() {
    double total = 0;
    for (final line in cart.values) {
      total += line.item.price * line.qty;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = getCartItemCount();
    final cartTotal = getCartTotal();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          widget.shopName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    "Menu",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
                    itemCount: localItemData2.length,
                    itemBuilder: (context, index) {
                      final menuItem = localItemData2[index];

                      return Card(
                        elevation: 2,
                        shadowColor: Colors.black,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
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
                                'assets/img/${menuItem.imageName}',
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) =>
                                    const SizedBox(
                                      height: 180,
                                      child: Center(
                                        child: Text("Image not found"),
                                      ),
                                    ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    menuItem.item,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${menuItem.calories}kcal | ${menuItem.protein}g protein | ${menuItem.carbs}g carbs | ${menuItem.fats}g fats',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Text(
                                        '\$${menuItem.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const Spacer(),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            addToCart(menuItem);
                                          });

                                          // Optional: quick feedback
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${menuItem.item} added to cart',
                                              ),
                                              duration: const Duration(
                                                milliseconds: 500,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 25,
                                            vertical: 18,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          '+ Add',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$cartCount items in cart',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  '\$${cartTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: const Text(
                'View Cart',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
