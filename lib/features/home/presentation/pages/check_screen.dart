import 'package:flutter/material.dart';
import 'package:restaurant/features/home/data/services/data_base.dart';
import 'package:restaurant/features/home/domain/models/cart.dart';

class CheckScreen extends StatefulWidget {
  const CheckScreen({super.key});

  @override
  State<CheckScreen> createState() => _CheckScreenState();
}

class _CheckScreenState extends State<CheckScreen> {
  DBHelper dbHelper = DBHelper();
  Map<String, List<Cart>> orders = {};

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    Map<String, List<Cart>> fetchedOrders = await dbHelper.getAllSavedCartLists();
    setState(() {
      orders = fetchedOrders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Orders'),
      ),
      body: orders.isEmpty
          ? const Center(
        child: Text(
          'No Orders Found',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
      )
          : ListView.builder(
        itemCount: orders.keys.length,
        itemBuilder: (context, index) {
          String orderName = orders.keys.elementAt(index);
          List<Cart> cartList = orders[orderName]!;

          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ExpansionTile(
              title: Text(orderName, style: const TextStyle(fontWeight: FontWeight.bold)),
              children: cartList.map((cart) {
                return ListTile(
                  title: Text(cart.productName!),
                  subtitle: Text(
                    "Price: \$${cart.productPrice} | Qty: ${cart.quantity?.value}",
                  ),
                  leading: Image.asset(cart.image!, height: 40, width: 40),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
