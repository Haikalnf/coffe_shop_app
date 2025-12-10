import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});
  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.delayed(Duration.zero, () {
      Provider.of<FinanceProvider>(context, listen: false).fetchTransactions();
    });
  }

  void _showAddDialog(String type) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text("Tambah $type"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: titleController, decoration: const InputDecoration(labelText: "Keterangan")),
          TextField(controller: amountController, decoration: const InputDecoration(labelText: "Jumlah (Rp)"), keyboardType: TextInputType.number),
        ],
      ),
      actions: [
        ElevatedButton(onPressed: () {
          if(titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
            Provider.of<FinanceProvider>(context, listen: false).addTransaction(
              titleController.text, 
              double.parse(amountController.text), 
              type == 'Pemasukan' ? 'masuk' : 'keluar'
            );
            Navigator.pop(ctx);
          }
        }, child: const Text("SIMPAN"))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final financeData = Provider.of<FinanceProvider>(context);
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Keuangan"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: "PEMASUKAN"), Tab(text: "PENGELUARAN")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(financeData.transactions.where((tx) => tx.type == 'masuk').toList(), Colors.green, formatCurrency),
          _buildList(financeData.transactions.where((tx) => tx.type == 'keluar').toList(), Colors.red, formatCurrency),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddDialog(_tabController.index == 0 ? 'Pemasukan' : 'Pengeluaran'),
      ),
    );
  }

  Widget _buildList(List txList, Color color, NumberFormat fmt) {
    if (txList.isEmpty) return const Center(child: Text("Belum ada data"));
    return ListView.builder(
      itemCount: txList.length,
      itemBuilder: (ctx, i) => Card(
        child: ListTile(
          leading: Icon(Icons.monetization_on, color: color),
          title: Text(txList[i].title),
          subtitle: Text(DateFormat('dd MMM yyyy').format(txList[i].date)),
          trailing: Text(fmt.format(txList[i].amount), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}