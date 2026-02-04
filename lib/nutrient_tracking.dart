import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NutrientTrackingPage extends StatefulWidget {
  const NutrientTrackingPage({super.key});

  @override
  State<NutrientTrackingPage> createState() => _NutrientTrackingPageState();
}

class _NutrientTrackingPageState extends State<NutrientTrackingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController carbsController = TextEditingController();
  final TextEditingController fatsController = TextEditingController();

  // Intake values (kept as double internally, displayed as int)
  double calories = 0;
  double protein = 0;
  double carbs = 0;
  double fats = 0;

  // Goals
  final double calorieGoal = 2000;
  final double proteinGoal = 100;
  final double carbsGoal = 200;
  final double fatsGoal = 65;

  // Goal popup control
  bool _goalPopupShown = false;

  // Shop/menu state
  bool loadingShops = false;
  bool loadingMenu = false;

  List<Map<String, dynamic>> shops = [];
  String? selectedShopId; // null => show shops only
  List<Map<String, dynamic>> menuItemsForShop = [];

  @override
  void initState() {
    super.initState();
    _loadNutrientData(); // loads today's doc
    _loadShops();
  }

  @override
  void dispose() {
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatsController.dispose();
    super.dispose();
  }

  // ---------- Date-based doc id ----------
  String _todayDocId() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  // ---------- Helpers ----------
  double _asDouble(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return double.tryParse(v.toString()) ?? 0;
  }

  // menudata might use protein OR proteins

  void _syncControllersFromState() {
    caloriesController.text = calories.toInt().toString();
    proteinController.text = protein.toInt().toString();
    carbsController.text = carbs.toInt().toString();
    fatsController.text = fats.toInt().toString();
  }

  void _checkGoalsAndShowPopup() {
    final goalsMet = calories >= calorieGoal &&
        protein >= proteinGoal &&
        carbs >= carbsGoal &&
        fats >= fatsGoal;

    if (goalsMet && !_goalPopupShown && mounted) {
      _goalPopupShown = true;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Congratulations! 🎉'),
          content: const Text('You have achieved the daily goal!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

    if (!goalsMet) _goalPopupShown = false;
  }

  // ---------- READ nutrientdata (TODAY) ----------
  Future<void> _loadNutrientData() async {
    try {
      final todayId = _todayDocId();
      final doc = await _firestore.collection('nutrientdata').doc(todayId).get();

      if (!doc.exists) {
        setState(() {
          calories = 0;
          protein = 0;
          carbs = 0;
          fats = 0;
          _syncControllersFromState();
        });
        return;
      }

      final data = doc.data() ?? {};
      setState(() {
        calories = _asDouble(data['calories']);
        protein = _asDouble(data['proteins']); // nutrientdata stores as "proteins"
        carbs = _asDouble(data['carbs']);
        fats = _asDouble(data['fats']);
        _syncControllersFromState();
      });

      _checkGoalsAndShowPopup();
    } catch (e) {
      debugPrint('Failed to load nutrientdata: $e');
    }
  }

  // ---------- WRITE nutrientdata (TODAY) ----------
  Future<void> _saveNutrientData() async {
    try {
      final todayId = _todayDocId();

      final intCal = int.tryParse(caloriesController.text) ?? 0;
      final intPro = int.tryParse(proteinController.text) ?? 0;
      final intCar = int.tryParse(carbsController.text) ?? 0;
      final intFat = int.tryParse(fatsController.text) ?? 0;

      final data = {
        'date': todayId,
        'calories': intCal,
        'proteins': intPro,
        'carbs': intCar,
        'fats': intFat,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('nutrientdata')
          .doc(todayId)
          .set(data, SetOptions(merge: true));

      setState(() {
        calories = intCal.toDouble();
        protein = intPro.toDouble();
        carbs = intCar.toDouble();
        fats = intFat.toDouble();
        _syncControllersFromState();
      });

      _checkGoalsAndShowPopup();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved today ($todayId) to Firebase!')),
      );
    } catch (e) {
      debugPrint('Failed to save nutrientdata: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  // ---------- READ shopdata (shops list only) ----------
  Future<void> _loadShops() async {
    setState(() => loadingShops = true);
    try {
      final snap = await _firestore.collection('shopdata').get();
      final list = snap.docs.map((d) {
        final data = d.data();
        return {'id': d.id, ...data};
      }).toList();

      setState(() {
        shops = list;
      });
    } catch (e) {
      debugPrint('Failed to load shopdata: $e');
    } finally {
      if (mounted) setState(() => loadingShops = false);
    }
  }

  // ---------- MENU parsing helpers ----------
  List<Map<String, dynamic>> _extractMenuItemsFromDoc(
    String docId,
    Map<String, dynamic> data,
  ) {
    // Case 1: doc contains an array "items"
    final items = data['items'];
    if (items is List) {
      return items.map((raw) {
        final m = (raw is Map) ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
        return {
          'id': '${docId}_${m['item'] ?? m['name'] ?? ''}',
          ...m,
        };
      }).toList();
    }

    // Case 2: doc itself is one menu item
    return [
      {
        'id': docId,
        ...data,
      }
    ];
  }

  // ---------- READ menudata for a selected shop (NO HARD CODE) ----------
  Future<void> _loadMenuForShop(String shopId) async {
    setState(() {
      loadingMenu = true;
      menuItemsForShop = [];
    });

    try {
      // 1) Try to read menu doc ids from the shop doc (best for "each shop has BOTH menu items")
      final shopDoc = await _firestore.collection('shopdata').doc(shopId).get();
      final shopData = shopDoc.data() ?? {};

      // Accept multiple possible field names:
      // - menuDocIds: ["id1","id2"]
      // - menuDocId: "id1"
      // - menuIds / menuId
      List<String> menuDocIds = [];

      final dynamic idsList =
          shopData['menuDocIds'] ?? shopData['menuIds'] ?? shopData['menu_docs'];

      if (idsList is List) {
        menuDocIds = idsList.map((e) => e.toString()).toList();
      } else {
        final single =
            shopData['menuDocId'] ?? shopData['menuId'] ?? shopData['menu_doc'];
        if (single != null && single.toString().trim().isNotEmpty) {
          menuDocIds = [single.toString()];
        }
      }

      // 2) If shop doc doesn't contain ids, fallback to querying menudata by shopId (if your menudata has shopId field)
      if (menuDocIds.isEmpty) {
        final q = await _firestore
            .collection('menudata')
            .where('shopId', isEqualTo: shopId)
            .get();

        menuDocIds = q.docs.map((d) => d.id).toList();
      }

      if (menuDocIds.isEmpty) {
        setState(() => menuItemsForShop = []);
        return;
      }

      // 3) Fetch ALL menu docs (this is the part that makes "BOTH menu items" possible)
      final futures = menuDocIds.map((id) => _firestore.collection('menudata').doc(id).get());
      final docs = await Future.wait(futures);

      final List<Map<String, dynamic>> allItems = [];
      for (final d in docs) {
        if (!d.exists) continue;
        final data = d.data() ?? {};
        allItems.addAll(_extractMenuItemsFromDoc(d.id, data));
      }

      setState(() {
        menuItemsForShop = allItems;
      });
    } catch (e) {
      debugPrint('Failed to load menudata for shop: $e');
    } finally {
      if (mounted) setState(() => loadingMenu = false);
    }
  }

  // ---------- Add ONE menu item (separately) ----------
  Future<void> _addSingleMenuItemToIntake(Map<String, dynamic> item) async {
    try {
      final todayId = _todayDocId();

      final addCalories = _asDouble(item['calories']);
      final addProtein = _asDouble(item['protein'] ?? item['proteins']);
      final addCarbs = _asDouble(item['carbs']);
      final addFats = _asDouble(item['fats']);

      setState(() {
        calories += addCalories;
        protein += addProtein;
        carbs += addCarbs;
        fats += addFats;
        _syncControllersFromState();
      });

      await _firestore.collection('nutrientdata').doc(todayId).set({
        'date': todayId,
        'calories': calories.toInt(),
        'proteins': protein.toInt(),
        'carbs': carbs.toInt(),
        'fats': fats.toInt(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _checkGoalsAndShowPopup();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${(item['item'] ?? item['name'] ?? 'menu item')}')),
      );
    } catch (e) {
      debugPrint('Failed to add menu item: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Add failed: $e')),
      );
    }
  }

  // ---------- UI ----------
  Widget _thickProgress(double value, double goal, Color color) {
    return LinearProgressIndicator(
      value: (goal <= 0) ? 0 : (value / goal).clamp(0, 1),
      minHeight: 10,
      backgroundColor: Colors.grey[300],
      color: color,
      borderRadius: BorderRadius.circular(20),
    );
  }

  Widget _macroTile({
    required String title,
    required double value,
    required double goal,
    required Color color,
    required TextEditingController controller,
    required void Function(double) onValueChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _thickProgress(value, goal, color),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    hintText: 'Enter value',
                  ),
                  onChanged: (val) {
                    final parsed = int.tryParse(val) ?? 0;
                    onValueChanged(parsed.toDouble());
                    _checkGoalsAndShowPopup();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Text('${value.toInt()}/${goal.toInt()}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }

  Widget _shopsOnlyCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select shop',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (loadingShops)
            const Center(child: CircularProgressIndicator())
          else if (shops.isEmpty)
            const Text('No shops found in shopdata.')
          else
            Column(
              children: shops.map((s) {
                final id = s['id'] as String;
                final name = (s['shopname'] ?? 'Unknown').toString();
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    setState(() => selectedShopId = id);
                    await _loadMenuForShop(id);
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _menuForSelectedShopCard() {
    final shop = shops.firstWhere(
      (s) => s['id'] == selectedShopId,
      orElse: () => {'shopname': 'Selected shop'},
    );
    final shopName = (shop['shopname'] ?? 'Selected shop').toString();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                selectedShopId = null;
                menuItemsForShop.clear();
              });
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to shops'),
          ),
          const SizedBox(height: 6),
          Text(
            shopName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Menu items',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (loadingMenu)
            const Center(child: CircularProgressIndicator())
          else if (menuItemsForShop.isEmpty)
            const Text('No menu items found for this shop.')
          else
            Column(
              children: menuItemsForShop.map((m) {
                final name = (m['item'] ?? m['name'] ?? 'Unknown').toString();
                final cals = _asDouble(m['calories']).toInt();
                final prot = _asDouble(m['protein'] ?? m['proteins']).toInt();
                final carb = _asDouble(m['carbs']).toInt();
                final fat = _asDouble(m['fats']).toInt();

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(
                                'Calories: $cals | Protein: $prot | Carbs: $carb | Fats: $fat'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 36,
                        child: OutlinedButton(
                          onPressed: () => _addSingleMenuItemToIntake(m),
                          child: const Text('Add'),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PureBite - Nutrient Tracking'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // CALORIES
            _card(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Calories',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _thickProgress(calories, calorieGoal, Colors.green),
                    const SizedBox(height: 10),
                    TextField(
                      controller: caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter calories',
                        isDense: true,
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val) ?? 0;
                        setState(() {
                          calories = parsed.toDouble();
                        });
                        _checkGoalsAndShowPopup();
                      },
                    ),
                  ],
                ),
                trailing: Text(
                  '${calories.toInt()}/${calorieGoal.toInt()} kcal',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // MACROS
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Macronutrients',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  _macroTile(
                    title: 'Protein',
                    value: protein,
                    goal: proteinGoal,
                    color: Colors.red,
                    controller: proteinController,
                    onValueChanged: (v) => setState(() => protein = v),
                  ),
                  _macroTile(
                    title: 'Carbs',
                    value: carbs,
                    goal: carbsGoal,
                    color: Colors.blue,
                    controller: carbsController,
                    onValueChanged: (v) => setState(() => carbs = v),
                  ),
                  _macroTile(
                    title: 'Fats',
                    value: fats,
                    goal: fatsGoal,
                    color: Colors.lime,
                    controller: fatsController,
                    onValueChanged: (v) => setState(() => fats = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // SHOPS FIRST -> THEN MENU
            if (selectedShopId == null)
              _shopsOnlyCard()
            else
              _menuForSelectedShopCard(),

            const SizedBox(height: 12),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _saveNutrientData,
                child: const Text(
                  'Save Daily Intake',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}