import 'package:flutter/material.dart';

// Starts the application and opens the shopping cart screen.
void main() => runApp(
  const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CartScreen(),
  ),
);

// Plain data class: quantity and gotIt are not final, so they can change.
class CartItem {
  final String name;
  final double price;
  int quantity;
  bool gotIt;

  CartItem({
    required this.name,
    required this.price,
    this.quantity = 1,
    this.gotIt = false,
  });
}

// Stateful because the cart changes while the app runs.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

// The State class owns the item list and the text controllers.
class _CartScreenState extends State<CartScreen> {
  final List<CartItem> _items = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Runs once when the screen is created: preloads the 3 sample items.
  @override
  void initState() {
    super.initState();

    _items.addAll([
      CartItem(name: 'Rice', price: 60.00, quantity: 2),
      CartItem(name: 'Eggs', price: 8.00, quantity: 12),
      CartItem(name: 'Milk', price: 95.00, quantity: 1),
    ]);
  }

  // Releases both text controllers when the screen is removed.
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Increases the item quantity but stops at 99.
  void _increase(int i) {
    if (_items[i].quantity < 99) {
      setState(() {
        _items[i].quantity++;
      });
    }
  }

  // Decreases the item quantity but never goes below 1.
  void _decrease(int i) {
    if (_items[i].quantity > 1) {
      setState(() {
        _items[i].quantity--;
      });
    }
  }

  // Marks an item as purchased or unmarks it when tapped again.
  void _toggle(int i) {
    setState(() {
      _items[i].gotIt = !_items[i].gotIt;
    });
  }

  // Removes all checked items from the shopping cart.
  void _clearChecked() {
    setState(() {
      _items.removeWhere((item) => item.gotIt);
    });
  }

  // Calculates the total price of all items based on their quantities.
  double get _total {
    double sum = 0;

    for (final item in _items) {
      sum += item.price * item.quantity;
    }

    return sum;
  }

  // Counts how many items are marked as purchased.
  int get _gotItCount {
    return _items.where((item) => item.gotIt).length;
  }

  // Adds a new item after checking if the name and price are valid.
  void _addItem() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());

    // Shows an error if the name is empty or the price is invalid.
    if (name.isEmpty || price == null || !price.isFinite || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid item name and price.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Updates the item list and refreshes the screen.
    setState(() {
      _items.add(
        CartItem(
          name: name,
          price: price,
        ),
      );
    });

    // Clears the input fields after adding the item.
    _nameController.clear();
    _priceController.clear();

    FocusScope.of(context).unfocus();

    // Displays a success message after adding an item.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Builds the main shopping cart interface.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Displays the application title.
      appBar: AppBar(
        title: const Text('Mini Shopping Cart'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Summary section: displays item count, checked count, and total.
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Items: ${_items.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Got it: $_gotItCount',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Displays the updated total price.
                  Text(
                    'Total: PHP ${_total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            // Displays the shopping items using a scrollable list.
            Expanded(
              child: _items.isEmpty
                  ? const Center(
                      child: Text(
                        'Your shopping cart is empty.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        // Passes item data and button actions to CartItemTile.
                        return CartItemTile(
                          item: _items[index],
                          onIncrease: () => _increase(index),
                          onDecrease: () => _decrease(index),
                          onToggle: () => _toggle(index),
                        );
                      },
                    ),
            ),

            // Button for removing all checked items.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _gotItCount > 0 ? _clearChecked : null,
                  icon: const Icon(Icons.delete),
                  label: const Text('Clear Checked'),
                ),
              ),
            ),

            const Divider(),

            // Form for entering a new item's name and price.
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Text field for the item name.
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      hintText: 'Enter item name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.shopping_bag),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Text field for the item price.
                  TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      hintText: 'Enter item price',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Button that calls _addItem to add a new item.
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Stateless because it only displays item data and sends actions to the parent.
class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onToggle;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onToggle,
  });

  // Builds the display for each shopping cart item.
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),
      child: ListTile(
        // Checkbox for marking an item as purchased.
        leading: Checkbox(
          value: item.gotIt,
          onChanged: (_) => onToggle(),
        ),

        // Displays the item name with a line-through when checked.
        title: Text(
          item.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: item.gotIt
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),

        // Displays the item's price with two decimal places.
        subtitle: Text(
          'PHP ${item.price.toStringAsFixed(2)}',
        ),

        // Buttons for decreasing and increasing the item quantity.
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: onDecrease,
            ),

            // Displays the current item quantity.
            Text(
              '${item.quantity}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onIncrease,
            ),
          ],
        ),
      ),
    );
  }
}