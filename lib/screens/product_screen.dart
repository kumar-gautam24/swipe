import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/custom_progress_bar.dart';
// import '../widgets/search_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar.dart';
import 'add_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  void _showFilterDialog(BuildContext context, String currentFilter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Products'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('All'),
              onTap: () {
                context.read<ProductProvider>().setFilterType('All');
                Navigator.pop(context);
              },
              selected: currentFilter == 'All',
            ),
            ListTile(
              title: Text('Product'),
              onTap: () {
                context.read<ProductProvider>().setFilterType('Product');
                Navigator.pop(context);
              },
              selected: currentFilter == 'Product',
            ),
            ListTile(
              title: Text('Service'),
              onTap: () {
                context.read<ProductProvider>().setFilterType('Service');
                Navigator.pop(context);
              },
              selected: currentFilter == 'Service',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(
              context,
              context.read<ProductProvider>().filterType,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          CustomSearchBar(
            onSearch: (query) {
              context.read<ProductProvider>().setSearchQuery(query);
            },
          ),
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return CustomProgressIndicator(isIndeterminate: true);
                }

                if (provider.error.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${provider.error}',
                          style: TextStyle(color: Colors.red),
                        ),
                        ElevatedButton(
                          onPressed: () => provider.fetchProducts(),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.products.isEmpty) {
                  return Center(
                    child: Text('No products found'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchProducts(),
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: provider.products.length,
                    itemBuilder: (context, index) {
                      final product = provider.products[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          // Handle product tap
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => AddProductScreen(),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
