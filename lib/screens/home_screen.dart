import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/auth_provider.dart';
import '../providers/products_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/finance_provider.dart';
import './cart_screen.dart';
import './manage_products_screen.dart';
import './finance_screen.dart';
import './profile_screen.dart';
import './login_screen.dart';
import '../widgets/product_item.dart';
import '../widgets/badge_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String _filterType = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        final products = Provider.of<ProductsProvider>(context, listen: false);
        final finance = Provider.of<FinanceProvider>(context, listen: false);

        Future.wait([
          products.fetchProducts(),
          finance.fetchTransactions(),
        ]).then((_) {
          if (mounted) setState(() => _isLoading = false);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    bool isAdmin = user?.role == 'admin';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isAdmin ? "Dashboard Owner" : "Menu Kopi"),
        backgroundColor: isAdmin ? const Color(0xFF1E88E5) : Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          if (!isAdmin)
            Consumer<CartProvider>(
              builder:
                  (_, cart, ch) => BadgeIcon(
                    value: cart.itemCount.toString(),
                    child: IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CartScreen(),
                            ),
                          ),
                    ),
                  ),
            ),
        ],
      ),
      drawer: _buildDrawer(context, user, isAdmin),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : isAdmin
              ? _buildAdminView(context)
              : _buildUserView(context),

      floatingActionButton:
          isAdmin
              ? FloatingActionButton(
                backgroundColor: const Color(0xFF1E88E5),
                child: const Icon(Icons.add, color: Colors.white),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FinanceScreen()),
                    ),
              )
              : null,
    );
  }

  Widget _buildAdminView(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);
    final currencyFmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final dailyTransactions =
        finance.transactions.where((tx) {
          return isSameDay(tx.date, _selectedDay);
        }).toList();

    double dailyIncome = dailyTransactions
        .where((tx) => tx.type == 'masuk')
        .fold(0, (s, i) => s + i.amount);
    double dailyExpense = dailyTransactions
        .where((tx) => tx.type == 'keluar')
        .fold(0, (s, i) => s + i.amount);

    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.week,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Color(0xFF1E88E5),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Laporan: ${DateFormat('dd MMM yyyy').format(_selectedDay)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        "Pemasukan",
                        dailyIncome,
                        Colors.green,
                        Icons.arrow_downward,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildSummaryCard(
                        "Pengeluaran",
                        dailyExpense,
                        Colors.red,
                        Icons.arrow_upward,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Detail Transaksi",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child:
                      dailyTransactions.isEmpty
                          ? Center(
                            child: Text(
                              "Data Kosong",
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          )
                          : ListView.builder(
                            itemCount: dailyTransactions.length,
                            itemBuilder: (ctx, i) {
                              final tx = dailyTransactions[i];
                              return ListTile(
                                leading: Icon(
                                  tx.type == 'masuk'
                                      ? Icons.add_circle
                                      : Icons.remove_circle,
                                  color:
                                      tx.type == 'masuk'
                                          ? Colors.green
                                          : Colors.red,
                                ),
                                title: Text(tx.title),
                                trailing: Text(currencyFmt.format(tx.amount)),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserView(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);

    final filteredItems =
        _filterType == 'all'
            ? productsData.items
            : productsData.items.where((i) => i.type == _filterType).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFilterChip('Semua', 'all'),
              const SizedBox(width: 10),
              _buildFilterChip('Hot 🔥', 'hot'),
              const SizedBox(width: 10),
              _buildFilterChip('Cold 🧊', 'cold'),
            ],
          ),
        ),

        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: filteredItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (ctx, i) => ProductItem(filteredItems[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 5),
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            fmt.format(amount),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filterType == value,
      onSelected: (bool selected) => setState(() => _filterType = value),
      selectedColor: Colors.brown,
      labelStyle: TextStyle(
        color: _filterType == value ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, dynamic user, bool isAdmin) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.name ?? "Guest"),
            accountEmail: Text(user?.email ?? "-"),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            decoration: BoxDecoration(
              color: isAdmin ? const Color(0xFF1E88E5) : Colors.brown,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profil"),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
          ),

          if (isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.wallet),
              title: const Text("Keuangan Toko"),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FinanceScreen()),
                  ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Kelola Produk"),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageProductsScreen(),
                    ),
                  ),
            ),
          ],

          if (!isAdmin)
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Riwayat Pemesanan Saya"), 
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (ctx) => _buildUserHistoryDialog(ctx, user?.name ?? ""),
                );
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserHistoryDialog(BuildContext context, String userName) {
    final finance = Provider.of<FinanceProvider>(context, listen: false);
    final myHistory =
        finance.transactions
            .where(
              (tx) => tx.title.toLowerCase().contains(userName.toLowerCase()),
            )
            .toList();
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return AlertDialog(
      title: const Text("Riwayat Pemesanan"), 
      content: SizedBox(
        width: double.maxFinite,
        child:
            myHistory.isEmpty
                ? const Text("Belum ada riwayat pemesanan.")
                : ListView.builder(
                  shrinkWrap: true,
                  itemCount: myHistory.length,
                  itemBuilder:
                      (ctx, i) => ListTile(
                        leading: const Icon(Icons.coffee, color: Colors.brown),
                        title: Text(
                          myHistory[i].title,
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Text(
                          fmt.format(myHistory[i].amount),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          DateFormat('dd MMM HH:mm').format(myHistory[i].date),
                        ),
                      ),
                ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Tutup"),
        ),
      ],
    );
  }
}
