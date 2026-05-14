import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/widgets/custom_bottom_nav.dart';
import '../../data/models/shop_model.dart';
import '../../data/models/browse_models.dart';
import '../../services/shop_api_service.dart';
import '../../services/browse_api_service.dart';
import 'shop_products_page.dart';
import '../widgets/item_detail_sheet.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage>
    with SingleTickerProviderStateMixin {
  final ShopApiService _shopService = ShopApiService();
  final BrowseApiService _browseService = BrowseApiService();
  final TextEditingController _searchCtrl = TextEditingController();
  late final TabController _tabController;
  Timer? _debounce;

  List<ShopResponse> _shops = [];
  bool _loadingShops = true;
  bool _searching = false;
  List<_ShopResults> _results = [];
  String _lastQuery = '';

  bool _didInit = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;
    final auth = context.read<AuthService>();
    if (auth.token != null) {
      _shopService.setAuthToken(auth.token!);
      _browseService.setAuthToken(auth.token!);
    }
    _loadShops();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadShops() async {
    try {
      final res = await _shopService.getShops(limit: 50);
      if (!mounted) return;
      setState(() {
        _shops = res.shops.where((s) => s.isActive).toList();
        _loadingShops = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingShops = false);
    }
  }

  void _onSearchChanged(String value) {
    setState(() {});
    if (value.isEmpty) {
      setState(() {
        _results = [];
        _lastQuery = '';
      });
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().length >= 2) _runSearch(value.trim());
    });
  }

  Future<void> _runSearch(String query) async {
    if (query == _lastQuery) return;
    _lastQuery = query;
    setState(() => _searching = true);

    final futures = _shops.map((shop) async {
      try {
        final p = await _browseService.getShopProducts(shop.id);
        final s = await _browseService.getShopServices(shop.id);
        final q = query.toLowerCase();
        final products = p.products.where((item) =>
            item.name.toLowerCase().contains(q) ||
            (item.description?.toLowerCase().contains(q) ?? false) ||
            (item.category?.toLowerCase().contains(q) ?? false) ||
            (item.brand?.toLowerCase().contains(q) ?? false)).toList();
        final services = s.services.where((item) =>
            item.name.toLowerCase().contains(q) ||
            (item.description?.toLowerCase().contains(q) ?? false)).toList();
        if (products.isEmpty && services.isEmpty) return null;
        return _ShopResults(shop: shop, products: products, services: services);
      } catch (_) {
        return null;
      }
    });

    final all = await Future.wait(futures);
    if (!mounted) return;
    setState(() {
      _results = all.whereType<_ShopResults>().toList();
      _searching = false;
    });
  }

  List<ShopProduct> get _allProducts =>
      _results.expand((r) => r.products).toList();
  List<ShopServiceItem> get _allServices =>
      _results.expand((r) => r.services).toList();
  int get _totalResults => _allProducts.length + _allServices.length;

  @override
  Widget build(BuildContext context) {
    final hasQuery = _searchCtrl.text.isNotEmpty;
    final showTabs = hasQuery && !_searching && _lastQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Search',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade100),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: _onSearchChanged,
              onSubmitted: (v) {
                _debounce?.cancel();
                if (v.trim().length >= 2) _runSearch(v.trim());
              },
              decoration: InputDecoration(
                hintText: 'Search products, services, brands...',
                hintStyle:
                    TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon:
                    Icon(Icons.search, color: Colors.red.shade400, size: 22),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        color: Colors.grey,
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {
                            _results = [];
                            _lastQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Tabs (only visible when results are ready)
          if (showTabs)
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.red.shade700,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.red.shade700,
                indicatorWeight: 2.5,
                labelStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: 'All ($_totalResults)'),
                  Tab(text: 'Products (${_allProducts.length})'),
                  Tab(text: 'Services (${_allServices.length})'),
                ],
              ),
            ),

          Expanded(child: _buildBody(hasQuery, showTabs)),
        ],
      ),
    );
  }

  Widget _buildBody(bool hasQuery, bool showTabs) {
    if (!hasQuery) return _buildShopBrowser();

    if (_searching) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
                color: Colors.red, strokeWidth: 2.5),
            const SizedBox(height: 16),
            Text(
              'Searching across ${_shops.length} shops...',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_lastQuery.isNotEmpty && _results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No results for "$_lastQuery"',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              'Try a different search term',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (!showTabs) return const SizedBox.shrink();

    return TabBarView(
      controller: _tabController,
      children: [
        _buildGroupedResults(),
        _buildFlatList<ShopProduct>(
          items: _allProducts,
          shopFor: (p) =>
              _results.firstWhere((r) => r.products.contains(p)).shop,
          builder: (p, shop) => _ProductCard(product: p, shop: shop),
          emptyMessage: 'No products found',
          emptyIcon: Icons.inventory_2_outlined,
        ),
        _buildFlatList<ShopServiceItem>(
          items: _allServices,
          shopFor: (s) =>
              _results.firstWhere((r) => r.services.contains(s)).shop,
          builder: (s, shop) => _ServiceCard(service: s, shop: shop),
          emptyMessage: 'No services found',
          emptyIcon: Icons.build_outlined,
        ),
      ],
    );
  }

  Widget _buildGroupedResults() {
    final widgets = <Widget>[];
    for (final r in _results) {
      widgets.add(_ShopSectionHeader(shop: r.shop));
      for (final p in r.products) {
        widgets.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: _ProductCard(product: p, shop: r.shop),
        ));
      }
      for (final s in r.services) {
        widgets.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: _ServiceCard(service: s, shop: r.shop),
        ));
      }
    }
    return ListView(
        padding: const EdgeInsets.only(bottom: 16), children: widgets);
  }

  Widget _buildFlatList<T>({
    required List<T> items,
    required ShopResponse Function(T) shopFor,
    required Widget Function(T, ShopResponse) builder,
    required String emptyMessage,
    required IconData emptyIcon,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(emptyMessage,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        try {
          return builder(items[i], shopFor(items[i]));
        } catch (_) {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildShopBrowser() {
    if (_loadingShops) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2.5));
    }
    if (_shops.isEmpty) {
      return Center(
        child: Text('No shops available',
            style: TextStyle(color: Colors.grey.shade500)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Browse by shop',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: _shops.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) => _ShopBrowseCard(
              shop: _shops[i],
              onTap: () => Navigator.push(
                ctx,
                MaterialPageRoute(
                    builder: (_) => ShopProductsPage(shop: _shops[i])),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShopResults {
  final ShopResponse shop;
  final List<ShopProduct> products;
  final List<ShopServiceItem> services;
  _ShopResults(
      {required this.shop, required this.products, required this.services});
}

// ---------- Shared sub-widgets ----------

class _ShopSectionHeader extends StatelessWidget {
  final ShopResponse shop;
  const _ShopSectionHeader({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.store_rounded, size: 16, color: Colors.red),
          const SizedBox(width: 6),
          Expanded(
            child: Text(shop.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          if (shop.address != null)
            Text(shop.address!,
                style:
                    TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class _ShopBrowseCard extends StatelessWidget {
  final ShopResponse shop;
  final VoidCallback onTap;
  const _ShopBrowseCard({required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)]),
                borderRadius: BorderRadius.circular(11),
              ),
              child:
                  const Icon(Icons.store_rounded, color: Colors.red, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  if (shop.address != null)
                    Text(shop.address!,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ShopProduct product;
  final ShopResponse shop;
  const _ProductCard({required this.product, required this.shop});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showProductDetail(context, product, shop),
      child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.inventory_2_outlined,
                color: Colors.blue.shade400, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                if (product.brand != null || product.category != null)
                  Text(
                    [product.brand, product.category]
                        .whereType<String>()
                        .join(' · '),
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade400),
                  ),
                if (product.description != null)
                  Text(product.description!,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.red.shade700)),
                    const Spacer(),
                    _AvailabilityDot(available: product.isAvailable),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: product.isAvailable
                ? () => showProductDetail(context, product, shop)
                : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: product.isAvailable
                    ? Colors.red.shade700
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.shopping_cart_outlined,
                  size: 18,
                  color: product.isAvailable
                      ? Colors.white
                      : Colors.grey.shade400),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ShopServiceItem service;
  final ShopResponse shop;
  const _ServiceCard({required this.service, required this.shop});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showServiceDetail(context, service, shop),
      child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.build_outlined,
                color: Colors.orange.shade400, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                if (service.description != null)
                  Text(service.description!,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('\$${service.price.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.red.shade700)),
                    if (service.estimatedMinutes != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.schedule_outlined,
                          size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 2),
                      Text('${service.estimatedMinutes}m',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500)),
                    ],
                    const Spacer(),
                    _AvailabilityDot(available: service.isAvailable),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: service.isAvailable
                ? () => showServiceDetail(context, service, shop)
                : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: service.isAvailable
                    ? Colors.red.shade700
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.calendar_today_outlined,
                  size: 18,
                  color: service.isAvailable
                      ? Colors.white
                      : Colors.grey.shade400),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _AvailabilityDot extends StatelessWidget {
  final bool available;
  const _AvailabilityDot({required this.available});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle,
            size: 7,
            color: available ? Colors.green.shade500 : Colors.grey.shade400),
        const SizedBox(width: 4),
        Text(
          available ? 'Available' : 'Unavailable',
          style: TextStyle(
              fontSize: 11,
              color:
                  available ? Colors.green.shade700 : Colors.grey.shade500),
        ),
      ],
    );
  }
}
