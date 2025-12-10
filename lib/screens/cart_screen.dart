import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/cart_provider.dart';
import '../providers/finance_provider.dart'; 
import '../providers/auth_provider.dart'; 

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final finance = Provider.of<FinanceProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang Belanja')),
      body: Column(
        children: [
          // Total Card
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(cart.totalAmount),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // List Item
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) {
                final item = cart.items.values.toList()[i];
                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed:
                      (_) => Provider.of<CartProvider>(
                        context,
                        listen: false,
                      ).removeItem(cart.items.keys.toList()[i]),
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.brown,
                        child: Text(
                          "x${item.quantity}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(item.title),
                      subtitle: Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(item.price * item.quantity),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Tombol Checkout
          Container(
            padding: const EdgeInsets.all(15),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(15),
              ),
              onPressed:
                  (cart.totalAmount <= 0)
                      ? null
                      : () {
                        // TAMPILKAN POPUP QRIS
                        showDialog(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: const Center(child: Text("SCAN QRIS")),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.qr_code_scanner,
                                      size: 150,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Total: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(cart.totalAmount)}",
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text("Batal"),
                                  ),

                                  // TOMBOL KONFIRMASI BAYAR
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(ctx); // Tutup Popup

                                      // 1. KIRIM DATA KE MOCKAPI (PENTING!)
                                      // Judul transaksi: "Penjualan Kopi (Nama User)"
                                      String judulTransaksi =
                                          "Penjualan Kopi (${user?.name ?? 'Guest'})";

                                      await finance.addTransaction(
                                        judulTransaksi, // Judul
                                        cart.totalAmount, // Jumlah Uang
                                        'masuk', // Tipe: Pemasukan
                                      );

                                      // 2. Kosongkan Keranjang
                                      cart.clear();

                                      // 3. Info Sukses
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Pembayaran Sukses & Tersimpan!",
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text("SAYA SUDAH BAYAR"),
                                  ),
                                ],
                              ),
                        );
                      },
              child: const Text("CHECKOUT SEKARANG"),
            ),
          ),
        ],
      ),
    );
  }
}
