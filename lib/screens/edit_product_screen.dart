import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/coffee.dart';
import '../providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  final String? id;
  const EditProductScreen({super.key, this.id});
  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Initial Values
  var _editedProduct = Coffee(id: '', name: '', description: '', price: 0, imageUrl: '', type: 'hot');
  
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _urlController = TextEditingController();
  String _selectedType = 'hot';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      final product = Provider.of<ProductsProvider>(context, listen: false).items.firstWhere((prod) => prod.id == widget.id);
      _editedProduct = product;
      _nameController.text = product.name;
      _priceController.text = product.price.toStringAsFixed(0);
      _descController.text = product.description;
      _urlController.text = product.imageUrl;
      _selectedType = product.type;
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final newProduct = Coffee(
      id: _editedProduct.id,
      name: _nameController.text,
      description: _descController.text,
      price: double.parse(_priceController.text),
      imageUrl: _urlController.text.isEmpty ? 'https://via.placeholder.com/150' : _urlController.text,
      type: _selectedType,
    );

    try {
      if (widget.id != null) {
        await Provider.of<ProductsProvider>(context, listen: false).updateProduct(widget.id!, newProduct);
      } else {
        await Provider.of<ProductsProvider>(context, listen: false).addProduct(newProduct);
      }
    } catch (error) {
      await showDialog(context: context, builder: (ctx) => const AlertDialog(title: Text("Error"), content: Text("Gagal menyimpan data")));
    }

    setState(() => _isLoading = false);
    if(mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.id != null ? 'Edit Produk' : 'Tambah Produk')),
      body: _isLoading 
      ? const Center(child: CircularProgressIndicator())
      : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Kopi'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Harga (Angka)'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                TextFormField(controller: _descController, decoration: const InputDecoration(labelText: 'Deskripsi'), maxLines: 3),
                TextFormField(controller: _urlController, decoration: const InputDecoration(labelText: 'URL Gambar')),
                const SizedBox(height: 10),
                DropdownButtonFormField(
                  value: _selectedType,
                  decoration: const InputDecoration(labelText: 'Tipe'),
                  items: const [
                    DropdownMenuItem(value: 'hot', child: Text('Hot 🔥')),
                    DropdownMenuItem(value: 'cold', child: Text('Cold 🧊')),
                  ],
                  onChanged: (v) => setState(() => _selectedType = v.toString()),
                ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _saveForm, style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, foregroundColor: Colors.white, padding: const EdgeInsets.all(15)), child: const Text('SIMPAN DATA'))
              ],
            ),
          ),
        ),
    );
  }
}