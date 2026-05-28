import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/widgets/item_image.dart';
import '../../data/models/shop_model.dart';
import '../../data/models/browse_models.dart';
import '../../services/browse_api_service.dart';
import '../widgets/item_detail_sheet.dart';

class ShopProductsPage extends StatefulWidget {
  final ShopResponse shop;
  // 0 = Products tab, 1 = Services tab
  final int initialTab;

  const ShopProductsPage({super.key, required this.shop, this.initialTab = 0});

  @override
  State<ShopProductsPage> createState() => _ShopProductsPageState();
}

class _ShopProductsPageState extends State<ShopProductsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final BrowseApiService _service = BrowseApiService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<ShopProduct> _products = [];
  List<ShopProduct> _filteredProducts = [];
  List<ShopServiceItem> _services = [];
  List<ShopServiceItem> _filteredServices = [];

  bool _loadingProducts = true;
  bool _loadingServices = true;
  String? _productError;
  String? _serviceError;

  bool _didLoad = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    final auth = context.read<AuthService>();
    if (auth.token != null) _service.setAuthToken(auth.token!);
    _loadProducts();
    _loadServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loadingProducts = true;
      _productError = null;
    });
    try {
      final res = await _service.getShopProducts(widget.shop.id);
      if (!mounted) return;
      setState(() {
        _products = res.products;
        _filteredProducts = _products;
        _loadingProducts = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _productError = e.toString();
        _loadingProducts = false;
      });
    }
  }

  Future<void> _loadServices() async {
    setState(() {
      _loadingServices = true;
      _serviceError = null;
    });
    try {
      final res = await _service.getShopServices(widget.shop.id);
      if (!mounted) return;
      setState(() {
        _services = res.services;
        _filteredServices = _services;
        _loadingServices = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _serviceError = e.toString();
        _loadingServices = false;
      });
    }
  }

  void _onSearch(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((p) {
        return p.name.toLowerCase().contains(q) ||
            (p.description?.toLowerCase().contains(q) ?? false) ||
            (p.category?.toLowerCase().contains(q) ?? false) ||
            (p.brand?.toLowerCase().contains(q) ?? false);
      }).toList();
      _filteredServices = _services.where((s) {
        return s.name.toLowerCase().contains(q) ||
            (s.description?.toLowerCase().contains(q) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.shop.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Products & Services',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8))),
              ],
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text('Products'
                          '${_loadingProducts ? '' : ' (${_filteredProducts.length})'}'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.build_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text('Services'
                          '${_loadingServices ? '' : ' (${_filteredServices.length})'}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: 'Search products & services...',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon:
                      Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          color: Colors.grey,
                          onPressed: () {
                            _searchCtrl.clear();
                            _onSearch('');
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
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProductsList(),
            _buildServicesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    if (_loadingProducts) {
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }
    if (_productError != null) {
      return _buildError(_productError!, _loadProducts);
    }
    if (_filteredProducts.isEmpty) {
      return _buildEmpty(
        icon: Icons.inventory_2_outlined,
        message: _searchCtrl.text.isEmpty
            ? 'No products available'
            : 'No products match "${_searchCtrl.text}"',
      );
    }
    return RefreshIndicator(
      color: Colors.red,
      onRefresh: _loadProducts,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredProducts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _ProductCard(
          product: _filteredProducts[i],
          shop: widget.shop,
        ),
      ),
    );
  }

  Widget _buildServicesList() {
    if (_loadingServices) {
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }
    if (_serviceError != null) {
      return _buildError(_serviceError!, _loadServices);
    }
    if (_filteredServices.isEmpty) {
      return _buildEmpty(
        icon: Icons.build_outlined,
        message: _searchCtrl.text.isEmpty
            ? 'No services available'
            : 'No services match "${_searchCtrl.text}"',
      );
    }
    return RefreshIndicator(
      color: Colors.red,
      onRefresh: _loadServices,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredServices.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _ServiceCard(
          service: _filteredServices[i],
          shop: widget.shop,
        ),
      ),
    );
  }

  Widget _buildError(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(error,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
        ],
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
            ItemImage(
              imageUrl: product.imageUrl,
              size: 62,
              borderRadius: 12,
              fallbackIcon: Icons.inventory_2_outlined,
              fallbackBg: Colors.blue.shade50,
              fallbackColor: Colors.blue.shade400,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  if (product.brand != null || product.category != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      [product.brand, product.category]
                          .whereType<String>()
                          .join(' · '),
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                  if (product.description != null) ...[
                    const SizedBox(height: 3),
                    Text(product.description!,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.red.shade700),
                      ),
                      const Spacer(),
                      if (product.rating != null) ...[
                        const Icon(Icons.star_rounded,
                            size: 13, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(product.rating!.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                      ],
                      _StockBadge(available: product.isAvailable),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _BookButton(
              available: product.isAvailable,
              icon: Icons.shopping_cart_outlined,
              onTap: () => showProductDetail(context, product, shop),
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
            ItemImage(
              imageUrl: service.imageUrl,
              size: 62,
              borderRadius: 12,
              fallbackIcon: Icons.build_outlined,
              fallbackBg: Colors.orange.shade50,
              fallbackColor: Colors.orange.shade400,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  if (service.description != null) ...[
                    const SizedBox(height: 3),
                    Text(service.description!,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '\$${service.price.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.red.shade700),
                      ),
                      if (service.estimatedMinutes != null) ...[
                        const SizedBox(width: 10),
                        Icon(Icons.schedule_outlined,
                            size: 13, color: Colors.grey.shade400),
                        const SizedBox(width: 3),
                        Text('${service.estimatedMinutes} min',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500)),
                      ],
                      const Spacer(),
                      if (service.rating != null) ...[
                        const Icon(Icons.star_rounded,
                            size: 13, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(service.rating!.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                      ],
                      _StockBadge(available: service.isAvailable),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _BookButton(
              available: service.isAvailable,
              icon: Icons.calendar_today_outlined,
              onTap: () => showServiceDetail(context, service, shop),
            ),
          ],
        ),
      ),
    );
  }
}


class _StockBadge extends StatelessWidget {
  final bool available;
  const _StockBadge({required this.available});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: available ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        available ? 'Available' : 'Unavailable',
        style: TextStyle(
          fontSize: 11,
          color: available ? Colors.green.shade700 : Colors.grey.shade500,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _BookButton extends StatelessWidget {
  final bool available;
  final IconData icon;
  final VoidCallback onTap;

  const _BookButton(
      {required this.available, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: available ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: available ? Colors.red.shade700 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: available ? Colors.white : Colors.grey.shade400,
        ),
      ),
    );
  }
}
