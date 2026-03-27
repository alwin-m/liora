# Liora Development Examples

This guide provides practical code snippets and patterns for common development tasks in the Liora project.

## Common Core Tasks

### Working with Cycle Session
Getting the current user's profile and predicting the next period:

```dart
// Check if initialized first
if (CycleSession.isInitialized) {
  final userProfile = await CycleSession.getUserProfile();
  final nextPeriod = CycleSession.algorithm.getNextPeriodDate();
  print('Next period: ${nextPeriod.toString()}');
}
```

### Scheduling a Period Reminder
Scheduling a reminder notification based on the predicted period:

```dart
// Reschedule period reminder safely
try {
  final nextPeriod = CycleSession.algorithm.getNextPeriodDate();
  await NotificationService.reschedulePeriodReminder(nextPeriod);
} catch (e) {
  debugPrint("Reminder restore error: $e");
}
```

---

## UI Development Examples

### Switching Theme Mode
Global theme switching using the `ValueNotifier` in `main.dart`:

```dart
// In any widget
onTap: () async {
  bool isNowDark = themeNotifier.value == ThemeMode.light;
  themeNotifier.value = isNowDark ? ThemeMode.dark : ThemeMode.light;
  await AppSettings.setDarkMode(isNowDark);
}
```

### Displaying a Product List
Using `ProductService` to fetch and display products in the shop:

```dart
FutureBuilder<List<Product>>(
  future: ProductService.getProducts(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    final products = snapshot.data ?? [];
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) => ProductCard(product: products[index]),
    );
  },
)
```

---

## Navigation & Routing

### Adding a New Route
Registering a new screen in `main.dart`:

```dart
routes: {
  // Existing routes...
  '/new-feature': (context) => const NewFeatureScreen(),
}
```

### Navigating to a Screen
Using named routes for consistency:

```dart
Navigator.pushNamed(context, '/new-feature', arguments: {'id': 123});
```

---

## State Management with Provider

### Accessing the Shopping Cart
Reading and writing to the `CartProvider` from a widget:

```dart
@override
Widget build(BuildContext context) {
  final cart = context.watch<CartProvider>(); // Listen for changes
  
  return IconButton(
    icon: const Icon(Icons.add_shopping_cart),
    onPressed: () {
      context.read<CartProvider>().addItem(product); // Do not listen during action
    },
  );
}
```

---

## Debugging Snippets

### Quick State Logout
Clearing session and preferences during a reset:

```dart
Future<void> clearSession() async {
  await FirebaseAuth.instance.signOut();
  await AppSettings.setDarkMode(false);
  await AppSettings.clearCycleData(); // Custom method if available
}
```

---

**Version**: 1.2.0  
**Updated**: March 26, 2026
