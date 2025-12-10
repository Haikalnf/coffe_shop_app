import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import './edit_product_screen.dart';

class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProductScreen())),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: productsData.items.length,
        itemBuilder: (_, i) => Column(
          children: [
            ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(productsData.items[i].imageUrl)),
              title: Text(productsData.items[i].name),
              subtitle: Text("ID: ${productsData.items[i].id}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProductScreen(id: productsData.items[i].id))),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog(
                        context: context, 
                        builder: (ctx) => AlertDialog(
                          title: const Text("Yakin hapus?"),
                          actions: [
                            TextButton(onPressed: ()=>Navigator.pop(ctx, false), child: const Text("Batal")),
                            TextButton(onPressed: ()=>Navigator.pop(ctx, true), child: const Text("Hapus")),
                          ],
                        )
                      );
                      if(confirm == true) {
                        Provider.of<ProductsProvider>(context, listen: false).deleteProduct(productsData.items[i].id);
                      }
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}