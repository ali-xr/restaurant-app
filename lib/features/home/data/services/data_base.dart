import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restaurant/features/home/domain/models/cart.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await initDatabase();
      return _database;
    }
  }

  // Initialize the database
  Future<Database> initDatabase() async {
    io.Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'cart.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  // Create tables
  _onCreate(Database db, int version) async {
    // Table for active cart
    await db.execute(
        'CREATE TABLE cart(id INTEGER PRIMARY KEY, productId VARCHAR UNIQUE, productName TEXT, initialPrice INTEGER, productPrice INTEGER, quantity INTEGER, unitTag TEXT, image TEXT)');

    // Table for saved cart lists (order headers)
    await db.execute(
        'CREATE TABLE cart_lists(listId INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)');

    // Table for saved cart items (order items)
    await db.execute(
        'CREATE TABLE saved_cart(id INTEGER PRIMARY KEY AUTOINCREMENT, listId INTEGER, productId VARCHAR, productName TEXT, initialPrice INTEGER, productPrice INTEGER, quantity INTEGER, unitTag TEXT, image TEXT)');
  }

  // Insert a new cart item
  Future<Cart> insert(Cart cart) async {
    var dbClient = await database;
    await dbClient!.insert('cart', cart.toMap());
    return cart;
  }

  // Get all cart items
  Future<List<Cart>> getCartList() async {
    var dbClient = await database;
    final List<Map<String, Object?>> queryResult =
    await dbClient!.query('cart');
    return queryResult.map((result) => Cart.fromMap(result)).toList();
  }

  // Save current cart as a new order
  Future<int> saveCartToNewList(List<Cart> cartList,String totalPrice) async {
    var dbClient = await database;

    // Generate dynamic order name as "Order number X"
    int count = Sqflite.firstIntValue(
        await dbClient!.rawQuery('SELECT COUNT(*) FROM cart_lists')) ??
        0;
    String listName = "Order number ${count + 1}, Total price: \$$totalPrice ";

    // Insert the new order
    int listId = await dbClient.insert('cart_lists', {'name': listName});

    // Add carts to the order
    for (var cartItem in cartList) {
      // Create a map of the cart item, excluding the `id` field
      var cartMap = cartItem.toMap();
      cartMap.remove('id'); // Remove the id field to avoid conflict
      cartMap['listId'] = listId; // Add the associated listId
      await dbClient.insert('saved_cart', cartMap);
    }

    // Clear the active cart after saving
    await clearCart();
    return listId;
  }

  // Get all saved cart lists
  Future<Map<String, List<Cart>>> getAllSavedCartLists() async {
    var dbClient = await database;

    // Fetch all orders
    List<Map<String, Object?>> lists =
    await dbClient!.query('cart_lists', orderBy: 'listId ASC');

    Map<String, List<Cart>> groupedCartLists = {};
    for (var list in lists) {
      int listId = list['listId'] as int;
      String name = list['name'] as String;

      // Fetch all carts for this list
      List<Map<String, Object?>> carts = await dbClient.query(
        'saved_cart',
        where: 'listId = ?',
        whereArgs: [listId],
      );

      groupedCartLists[name] =
          carts.map((cartData) => Cart.fromMap(cartData)).toList();
    }

    return groupedCartLists;
  }

  // Clear the active cart
  Future<int> clearCart() async {
    var dbClient = await database;
    return await dbClient!.delete('cart'); // Deletes all records in the 'cart' table
  }

  // Delete a cart item
  Future<int> deleteCartItem(int id) async {
    var dbClient = await database;
    return await dbClient!.delete('cart', where: 'id = ?', whereArgs: [id]);
  }

  // Update the quantity of a cart item
  Future<int> updateQuantity(Cart cart) async {
    var dbClient = await database;
    return await dbClient!.update('cart', cart.quantityMap(),
        where: "productId = ?", whereArgs: [cart.productId]);
  }

  // Get cart items by ID
  Future<List<Cart>> getCartId(int id) async {
    var dbClient = await database;
    final List<Map<String, Object?>> queryIdResult =
    await dbClient!.query('cart', where: 'id = ?', whereArgs: [id]);
    return queryIdResult.map((e) => Cart.fromMap(e)).toList();
  }
}
