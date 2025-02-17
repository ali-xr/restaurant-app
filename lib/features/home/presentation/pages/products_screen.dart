import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/features/home/data/services/data_base.dart';
import 'package:restaurant/features/home/domain/models/cart.dart';
import 'package:restaurant/features/home/presentation/provider/cart_provider.dart';
import 'package:restaurant/features/home/presentation/widgets/w_scale_animation.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  DBHelper? dbHelper = DBHelper();

  @override
  initState() {
    super.initState();
    context.read<CartProvider>().getData();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Режим продаж'),
          bottom: const TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(
                text: "Tовары",
              ),
              Tab(
                text: "Параметры",
              ),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            Column(
              children: [
                Expanded(
                  child: Consumer<CartProvider>(
                    builder: (BuildContext context, provider, widget) {
                      if (provider.cart.isEmpty) {
                        return const Center(
                            child: Text(
                              'Your Cart is Empty',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                            ));
                      } else {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: provider.cart.length,
                            itemBuilder: (context, index) {
                              return Card(
                                color: Colors.blueGrey.shade200,
                                elevation: 5.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Image(
                                        height: 80,
                                        width: 80,
                                        image: AssetImage(provider.cart[index].image!),
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
                                                        text: '${provider.cart[index].productName!}\n',
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
                                                        text: '${provider.cart[index].unitTag!}\n',
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
                                                        text: '${provider.cart[index].productPrice!}\n',
                                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                                  ]),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ValueListenableBuilder<int>(
                                          valueListenable: provider.cart[index].quantity!,
                                          builder: (context, val, child) {
                                            return PlusMinusButtons(
                                              addQuantity: () {
                                                cart.addQuantity(provider.cart[index].id!);
                                                dbHelper!
                                                    .updateQuantity(Cart(
                                                    id: index,
                                                    productId: index.toString(),
                                                    productName: provider.cart[index].productName,
                                                    initialPrice: provider.cart[index].initialPrice,
                                                    productPrice: provider.cart[index].productPrice,
                                                    quantity: ValueNotifier(provider.cart[index].quantity!.value),
                                                    unitTag: provider.cart[index].unitTag,
                                                    image: provider.cart[index].image))
                                                    .then((value) {
                                                  setState(() {
                                                    cart.addTotalPrice(
                                                        double.parse(provider.cart[index].productPrice.toString()));
                                                  });
                                                });
                                              },
                                              deleteQuantity: () {
                                                cart.deleteQuantity(provider.cart[index].id!);
                                                cart.removeTotalPrice(
                                                    double.parse(provider.cart[index].productPrice.toString()));
                                              },
                                              text: val.toString(),
                                            );
                                          }),
                                      IconButton(
                                          onPressed: () {
                                            dbHelper!.deleteCartItem(provider.cart[index].id!);
                                            provider.removeItem(provider.cart[index].id!);
                                            provider.removeCounter();
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red.shade800,
                                          )),
                                    ],
                                  ),
                                ),
                              );
                            });
                      }
                    },
                  ),
                ),

              ],
            ),
            Column(
              children: [
                const Spacer(),
                const Text(
                  'Oбщая сумма',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Consumer<CartProvider>(
                  builder: (BuildContext context, value, Widget? child) {
                    final ValueNotifier<int?> totalPrice = ValueNotifier(null);
                    for (var element in value.cart) {
                      totalPrice.value = (element.productPrice! * element.quantity!.value) + (totalPrice.value ?? 0);
                    }
                    return Column(
                      children: [
                        ValueListenableBuilder<int?>(
                            valueListenable: totalPrice,
                            builder: (context, val, child) {
                              return Text(r'$' + (val?.toStringAsFixed(2) ?? '0'),
                                  style: const TextStyle(
                                    fontSize: 32.0,
                                    fontWeight: FontWeight.w400,
                                  ));
                            }),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                        // const Spacer(flex: 3),
                        WScaleAnimation(
                          onTap: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Payment Successful'), duration: Duration(seconds: 2)),
                            );
                            await dbHelper?.saveCartToNewList(value.cart, totalPrice.value.toString());
                            context.read<CartProvider>().getData();
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 18.0),
                            decoration: BoxDecoration(
                              color: Colors.yellow.shade600,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            alignment: Alignment.center,
                            height: 50.0,
                            child: const Text(
                              'Заплатить',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const Spacer(),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class PlusMinusButtons extends StatelessWidget {
  final VoidCallback deleteQuantity;
  final VoidCallback addQuantity;
  final String text;
  const PlusMinusButtons({super.key, required this.addQuantity, required this.deleteQuantity, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: deleteQuantity, icon: const Icon(Icons.remove)),
        Text(text),
        IconButton(onPressed: addQuantity, icon: const Icon(Icons.add)),
      ],
    );
  }
}

class ReusableWidget extends StatelessWidget {
  final String title, value;
  const ReusableWidget({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
