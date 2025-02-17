import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/assets/images/app_images.dart';
import 'package:restaurant/features/home/data/services/data_base.dart';
import 'package:restaurant/features/home/domain/models/cart.dart';
import 'package:restaurant/features/home/domain/models/item.dart';
import 'package:restaurant/features/home/presentation/pages/check_screen.dart';
import 'package:restaurant/features/home/presentation/pages/products_screen.dart';
import 'package:restaurant/features/home/presentation/provider/cart_provider.dart';
import 'package:restaurant/features/home/presentation/widgets/w_scale_animation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DBHelper? dbHelper = DBHelper();

  List<Item> products = [
    Item(name: 'Meaty Rice Dish Dish', unit: 'Plov', price: 20, image: AppImages.plov),
    Item(name: 'Soup', unit: 'Dish', price: 20, image: AppImages.soup),
    Item(name: 'Egg', unit: 'Dish', price: 20, image: AppImages.egg),
    Item(name: 'Lagmon', unit: 'Dish', price: 20, image: AppImages.lagmon),
    Item(name: 'Coca Cola', unit: 'Drink', price: 10, image: AppImages.cocaCola),
    Item(name: 'Apple', unit: 'Kg', price: 20, image: AppImages.apple),
    Item(name: 'Mango', unit: 'Doz', price: 30, image: AppImages.mango),
    Item(name: 'Banana', unit: 'Doz', price: 10, image: AppImages.banana),
    Item(name: 'Grapes', unit: 'Kg', price: 8, image: AppImages.grapes),
    Item(name: 'Water Melon', unit: 'Kg', price: 25, image: AppImages.watermelon),
    Item(name: 'Kiwi', unit: 'Pc', price: 40, image: AppImages.kiwi),
    Item(name: 'Orange', unit: 'Doz', price: 15, image: AppImages.orange),
    Item(name: 'Peach', unit: 'Pc', price: 8, image: AppImages.peach),
    Item(name: 'Strawberry', unit: 'Box', price: 12, image: AppImages.strawberry),
    Item(name: 'Fruit Basket', unit: 'Kg', price: 55, image: AppImages.fruitBasket),
  ];

  @override
  initState() {
    super.initState();
    context.read<CartProvider>().getData();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    void saveData(int index) {
      dbHelper
          ?.insert(
        Cart(
          id: index,
          productId: index.toString(),
          productName: products[index].name,
          initialPrice: products[index].price,
          productPrice: products[index].price,
          quantity: ValueNotifier(1),
          unitTag: products[index].unit,
          image: products[index].image,
        ),
      )
          .then((value) {
        cart.addTotalPrice(products[index].price.toDouble());
        cart.addCounter();
        print('Product Added to cart');
      }).onError((error, stackTrace) {
        print(error.toString());
      });
    }

    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Consumer<CartProvider>(builder: (BuildContext context, provider, widget) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Режим продаж'),
            actions: [
              WScaleAnimation(
                  child: Stack(children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.shopping_cart),
                    ),
                    provider.cart.isEmpty
                        ? const SizedBox()
                        : Positioned(
                            right: 8,
                            top: 0,
                            child: CircleAvatar(
                              radius: 10,
                              child: Text(provider.cart.length.toString(), style: const TextStyle(fontSize: 10)),
                            ),
                          )
                  ]),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductsScreen()));
                  }),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                  ),
                  child: const Text('Menu'),
                ),
                ListTile(
                  title: const Text('Item 1'),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Saved Orders'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckScreen()));
                  },
                ),
              ],
            ),
          ),
          body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
              shrinkWrap: true,
              itemCount: products.length,
              itemBuilder: (context, index) {
                return WScaleAnimation(
                  onTap: () {
                    saveData(index);
                    context.read<CartProvider>().getData();
                  },
                  child: Card(
                    color: (provider.cart.isNotEmpty &&
                            index < provider.cart.length &&
                            provider.cart[index].productName == products[index].name)
                        ? Colors.blueGrey.shade100
                        : Colors.blue.shade100,
                    elevation: 5.0,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              image: DecorationImage(image: AssetImage(products[index].image)),
                            ),
                          ),
                          SizedBox(
                            width: 130,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 5.0,
                                ),
                                RichText(
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  text: TextSpan(
                                      text: 'Name: ',
                                      style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 16.0),
                                      children: [
                                        TextSpan(
                                            text: '${products[index].name.toString()}\n',
                                            style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ]),
                                ),
                                RichText(
                                  maxLines: 1,
                                  text: TextSpan(
                                      text: 'Unit: ',
                                      style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 16.0),
                                      children: [
                                        TextSpan(
                                            text: '${products[index].unit.toString()}\n',
                                            style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ]),
                                ),
                                RichText(
                                  maxLines: 1,
                                  text: TextSpan(
                                      text: 'Price: ' r"$",
                                      style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 16.0),
                                      children: [
                                        TextSpan(
                                            text: '${products[index].price.toString()}\n',
                                            style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        );
      }),
    );
  }
}
