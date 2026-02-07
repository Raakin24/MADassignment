import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NutrientTrackingPage extends StatefulWidget {
  const NutrientTrackingPage({super.key});

  @override
  State<NutrientTrackingPage> createState() => _NutrientTrackingPageState();
}

class _NutrientTrackingPageState extends State<NutrientTrackingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers (intake)
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController carbsController = TextEditingController();
  final TextEditingController fatsController = TextEditingController();

  // Controllers (goals - session only)
  final TextEditingController calorieGoalController = TextEditingController();
  final TextEditingController proteinGoalController = TextEditingController();
  final TextEditingController carbsGoalController = TextEditingController();
  final TextEditingController fatsGoalController = TextEditingController();

  // Intake values
  double calories = 0;
  double protein = 0;
  double carbs = 0;
  double fats = 0;

  // Goals (SESSION ONLY, defaults)
  double calorieGoal = 2000;
  double proteinGoal = 100;
  double carbsGoal = 200;
  double fatsGoal = 65;

  // Goal popup control
  bool _goalPopupShown = false;

  // ✅ Session doc id (fresh every app reopen)
  late final String _sessionDocId;

  // Shop/menu state
  bool loadingShops = false;
  bool loadingMenu = false;

  List<Map<String, dynamic>> shops = [];
  String? selectedShopId; // null => show shops only
  List<Map<String, dynamic>> menuItemsForShop = [];

  @override
  void initState() {
    super.initState();
    _sessionDocId = _firestore.collection('nutrientdata').doc().id;
    _resetTrackerUI();
    _loadShops();
  }

  @override
  void dispose() {
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatsController.dispose();

    calorieGoalController.dispose();
    proteinGoalController.dispose();
    carbsGoalController.dispose();
    fatsGoalController.dispose();

    super.dispose();
  }

  // ---------- Helpers ----------
  double _asDouble(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return double.tryParse(v.toString()) ?? 0;
  }

  int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  String _dateString(DateTime now) {
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _timeString(DateTime now) {
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final ss = now.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  void _syncControllersFromState() {
    caloriesController.text = calories.toInt().toString();
    proteinController.text = protein.toInt().toString();
    carbsController.text = carbs.toInt().toString();
    fatsController.text = fats.toInt().toString();
  }

  void _resetTrackerUI() {
    setState(() {
      calories = 0;
      protein = 0;
      carbs = 0;
      fats = 0;
      _goalPopupShown = false;

      selectedShopId = null;
      menuItemsForShop.clear();

      _syncControllersFromState();
    });
  }

  void _checkGoalsAndShowPopup() {
    final goalsMet =
        calories >= calorieGoal &&
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

  // ---------- GOALS (SESSION ONLY) ----------
  Widget _goalInputTile({
    required String title,
    required String subtitle,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
              hintText: 'Enter goal',
            ),
          ),
        ],
      ),
    );
  }

  void _openGoalEditor() {
    calorieGoalController.text = calorieGoal.toInt().toString();
    proteinGoalController.text = proteinGoal.toInt().toString();
    carbsGoalController.text = carbsGoal.toInt().toString();
    fatsGoalController.text = fatsGoal.toInt().toString();

    double parseGoal(String s, double fallback) {
      final v = double.tryParse(s);
      if (v == null || v <= 0) return fallback;
      return v;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Set Goals',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Looks like your tracker section
              _goalInputTile(
                title: 'Calories',
                subtitle: 'Daily calories goal (kcal)',
                controller: calorieGoalController,
              ),
              _goalInputTile(
                title: 'Protein',
                subtitle: 'Daily protein goal (g)',
                controller: proteinGoalController,
              ),
              _goalInputTile(
                title: 'Carbs',
                subtitle: 'Daily carbs goal (g)',
                controller: carbsGoalController,
              ),
              _goalInputTile(
                title: 'Fats',
                subtitle: 'Daily fats goal (g)',
                controller: fatsGoalController,
              ),

              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.black),),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        setState(() {
                          calorieGoal = parseGoal(
                            calorieGoalController.text,
                            calorieGoal,
                          );
                          proteinGoal = parseGoal(
                            proteinGoalController.text,
                            proteinGoal,
                          );
                          carbsGoal = parseGoal(
                            carbsGoalController.text,
                            carbsGoal,
                          );
                          fatsGoal = parseGoal(
                            fatsGoalController.text,
                            fatsGoal,
                          );
                          _goalPopupShown = false;
                        });

                        _checkGoalsAndShowPopup();
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Goals updated')),
                        );
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- WRITE nutrientdata (SESSION DOC) ----------
  Future<void> _saveNutrientData() async {
    try {
      final now = DateTime.now();
      final date = _dateString(now);
      final time = _timeString(now);

      final intCal = int.tryParse(caloriesController.text) ?? 0;
      final intPro = int.tryParse(proteinController.text) ?? 0;
      final intCar = int.tryParse(carbsController.text) ?? 0;
      final intFat = int.tryParse(fatsController.text) ?? 0;

      final data = {
        'sessionId': _sessionDocId,
        'date': date,
        'time': time,
        'calories': intCal,
        'proteins': intPro,
        'carbs': intCar,
        'fats': intFat,
        'clientTimestamp': Timestamp.fromDate(now),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('nutrientdata')
          .doc(_sessionDocId)
          .set(data, SetOptions(merge: true));

      if (!mounted) return;
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
        SnackBar(content: Text('Saved Successfully')),
      );
    } catch (e) {
      debugPrint('Failed to save nutrientdata: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  // ---------- READ shopdata ----------
  Future<void> _loadShops() async {
    setState(() => loadingShops = true);
    try {
      final snap = await _firestore.collection('shopdata').get();
      final list = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      if (!mounted) return;
      setState(() => shops = list);
    } catch (e) {
      debugPrint('Failed to load shopdata: $e');
    } finally {
      if (mounted) setState(() => loadingShops = false);
    }
  }

  // ---------- Menu parsing ----------
  Map<String, dynamic> _normalizeMenuItem(
    String docId,
    Map<String, dynamic> raw,
  ) {
    final name = (raw['item'] ?? raw['name'] ?? '').toString();
    final proteinVal = raw.containsKey('protein')
        ? raw['protein']
        : raw['proteins'];

    return {
      'id': docId,
      'item': name,
      'imagename': raw['imagename'],
      'price': _asDouble(raw['price']),
      'calories': _asInt(raw['calories']),
      'protein': _asInt(proteinVal),
      'carbs': _asInt(raw['carbs']),
      'fats': _asInt(raw['fats']),
    };
  }

  String _resolveMenuCollection(Map<String, dynamic> shopData) {
    final fromField =
        (shopData['menuCollection'] ?? shopData['menu_collection'])
            ?.toString()
            .trim();
    if (fromField != null && fromField.isNotEmpty) return fromField;

    final path = (shopData['path'] ?? '').toString().toLowerCase();
    if (path.contains('menu2')) return 'menu2data';
    return 'menudata';
  }

  Future<void> _loadMenuForShop(String shopId) async {
    setState(() {
      loadingMenu = true;
      menuItemsForShop = [];
    });

    try {
      final shopDoc = await _firestore.collection('shopdata').doc(shopId).get();
      final shopData = shopDoc.data() ?? {};
      final collectionName = _resolveMenuCollection(shopData);

      final List<String> menuDocIds = ((shopData['menuDocIds'] as List?) ?? [])
          .map((e) => e.toString())
          .toList();

      if (menuDocIds.isEmpty) {
        if (!mounted) return;
        setState(() => menuItemsForShop = []);
        return;
      }

      final docs = await Future.wait(
        menuDocIds.map(
          (id) => _firestore.collection(collectionName).doc(id).get(),
        ),
      );

      final items = <Map<String, dynamic>>[];
      for (final d in docs) {
        if (!d.exists) continue;
        items.add(_normalizeMenuItem(d.id, d.data() ?? {}));
      }

      if (!mounted) return;
      setState(() => menuItemsForShop = items);
    } catch (e) {
      debugPrint('Failed to load menu for shop: $e');
    } finally {
      if (mounted) setState(() => loadingMenu = false);
    }
  }

  Future<void> _addSingleMenuItemToIntake(Map<String, dynamic> item) async {
    try {
      final addCalories = _asDouble(item['calories']);
      final addProtein = _asDouble(item['protein']);
      final addCarbs = _asDouble(item['carbs']);
      final addFats = _asDouble(item['fats']);

      if (!mounted) return;
      setState(() {
        calories += addCalories;
        protein += addProtein;
        carbs += addCarbs;
        fats += addFats;
        _syncControllersFromState();
      });

      final now = DateTime.now();
      final date = _dateString(now);
      final time = _timeString(now);

      await _firestore.collection('nutrientdata').doc(_sessionDocId).set({
        'sessionId': _sessionDocId,
        'date': date,
        'time': time,
        'calories': calories.toInt(),
        'proteins': protein.toInt(),
        'carbs': carbs.toInt(),
        'fats': fats.toInt(),
        'clientTimestamp': Timestamp.fromDate(now),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _checkGoalsAndShowPopup();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${(item['item'] ?? 'menu item')}')),
      );
    } catch (e) {
      debugPrint('Failed to add menu item: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Add failed: $e')));
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }

  //Solid white pill in AppBar (clickable)
  Widget _setGoalsPill() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: TextButton.icon(
        onPressed: _openGoalEditor,
        icon: const Icon(Icons.flag),
        label: const Text('Set Goals'),
        style: TextButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
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
                final name = (m['item'] ?? 'Unknown').toString();
                final cals = _asInt(m['calories']);
                final prot = _asInt(m['protein']);
                final carb = _asInt(m['carbs']);
                final fat = _asInt(m['fats']);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Calories: $cals | Protein: $prot | Carbs: $carb | Fats: $fat',
                            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PureBite - Nutrient Tracking',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [_setGoalsPill()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _card(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Calories',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
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
                        setState(() => calories = parsed.toDouble());
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
            if (selectedShopId == null)
              _shopsOnlyCard()
            else
              _menuForSelectedShopCard(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
