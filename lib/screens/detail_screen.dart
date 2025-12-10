import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/coffee.dart';
import '../providers/cart_provider.dart';

class DetailScreen extends StatelessWidget {
  final Coffee coffee;
  const DetailScreen({super.key, required this.coffee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(coffee.name, style: const TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
              background: Image.network(coffee.imageUrl, fit: BoxFit.cover),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(label: Text(coffee.type.toUpperCase()), backgroundColor: Colors.orange[100]),
                        Row(children: [const Icon(Icons.star, color: Colors.amber), Text(' ${coffee.rating}')]),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(coffee.price),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown),
                    ),
                    const SizedBox(height: 20),
                    const Text("Deskripsi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(coffee.description, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.grey)),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text("TAMBAH KE KERANJANG"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, foregroundColor: Colors.white),
                        onPressed: () {
                          Provider.of<CartProvider>(context, listen: false).addItem(coffee.id, coffee.price, coffee.name);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil masuk keranjang!")));
                        },
                      ),
                    )
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}