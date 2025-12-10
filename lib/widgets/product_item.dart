import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/coffee.dart';
import '../providers/cart_provider.dart';
import '../screens/detail_screen.dart'; 

class ProductItem extends StatelessWidget {
  final Coffee coffee;

  const ProductItem(this.coffee, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => DetailScreen(coffee: coffee), 
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            title: Text(coffee.name, textAlign: TextAlign.center),
            trailing: IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                Provider.of<CartProvider>(context, listen: false)
                    .addItem(coffee.id, coffee.price, coffee.name);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${coffee.name} added to cart!'),
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        Provider.of<CartProvider>(context, listen: false)
                            .removeItem(coffee.id);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          child: Image.network(
            coffee.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (ctx, error, stackTrace) =>
                Container(color: Colors.grey, child: const Icon(Icons.error)),
          ),
        ),
      ),
    );
  }
}