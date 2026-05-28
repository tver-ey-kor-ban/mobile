import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/widgets/custom_bottom_nav.dart';
import '../../../../shared/widgets/item_image.dart';
import '../../data/models/shop_model.dart';
import '../../services/shop_api_service.dart';
import '../../../search/data/models/search_result_model.dart';
import '../../../search/services/global_search_service.dart';
import 'shop_products_page.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage>
    with SingleTickerProviderStateMixin {
  final ShopApiService _shopService = ShopApiService();
  final GlobalSearchService _searchService = GlobalSearchService();
  final TextEditingController _searchCtrl = TextEditingController();
  late final TabController _tabController;
  Timer? _debounce;

  List<ShopResponse> _shops = [];
  bool _loadingShops = true;
  bool _searching = false;
  SearchResponse? _searchResult;
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
    if (auth.token != null) _shopService.setAuthToken(auth.token!);
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
        _searchResult = null;
        _lastQuery = '';
      });
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().length >= 1) _runSearch(value.trim());
    });
  }

  Future<void> _runSearch(String query) async {
    if (query == _lastQuery) return;
    _lastQuery = query;
    setState(() => _searching = true);

    final result = await _searchService.search(query: query, limit: 50);
    if (!mounted) return;
    setState(() {
      _searchResult = result;
      _searching = false;
    });
  }

  List<SearchResultItem> get _allItems => _searchResult?.items ?? [];
  List<SearchResultItem> get _products =>
      _allItems.where((i) => i.isProduct).toList();
  List<SearchResultItem> get _services =>
      _allItems.where((i) => i.isService).toList();
  int get _totalResults => _searchResult?.total ?? 0;

  @override
  Widget build(BuildContext context) {
    final hasQuery = _searchCtrl.text.isNotEmpty;
    final showTabs = hasQuery &&
        !_searching &&
        _lastQuery.isNotEmpty &&
        _allItems.isNotEmpty;

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
                if (v.trim().isNotEmpty) _runSearch(v.trim());
              },
              decoration: InputDecoration(
                hintText: 'Search products & services across all shops...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon:
                    Icon(Icons.search, color: Colors.red.shade400, size: 22),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        color: Colors.grey,
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {
                            _searchResult = null;
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

          // Tabs — visible only when results are loaded
          if (showTabs)
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.red.shade700,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.red.shade700,
                indicatorWeight: 2.5,
                labelStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: 'All ($_totalResults)'),
                  Tab(text: 'Products (${_products.length})'),
                  Tab(text: 'Services (${_services.length})'),
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
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.red, strokeWidth: 2.5),
            SizedBox(height: 16),
            Text('Searching...',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
    }

    if (_lastQuery.isNotEmpty && (_searchResult == null || _allItems.isEmpty)) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No results for "$_lastQuery"',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
            const SizedBox(height: 6),
            Text('Try a different search term',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          ],
        ),
      );
    }

    if (!showTabs) return const SizedBox.shrink();

    return TabBarView(
      controller: _tabController,
      children: [
        _buildResultList(_allItems),
        _buildResultList(_products),
        _buildResultList(_services),
      ],
    );
  }

  Widget _buildResultList(List<SearchResultItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Text('No results',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _SearchResultCard(item: items[i]),
    );
  }

  Widget _buildShopBrowser() {
    if (_loadingShops) {
      return const Center(
          child:
              CircularProgressIndicator(color: Colors.red, strokeWidth: 2.5));
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

// ---------- Search result card ----------

class _SearchResultCard extends StatelessWidget {
  final SearchResultItem item;
  const _SearchResultCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isProduct = item.isProduct;
    final iconColor = isProduct ? Colors.blue.shade400 : Colors.orange.shade400;
    final bgColor = isProduct ? Colors.blue.shade50 : Colors.orange.shade50;
    final icon = isProduct ? Icons.inventory_2_outlined : Icons.build_outlined;

    return Container(
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
            imageUrl: item.imageUrl,
            size: 56,
            borderRadius: 12,
            fallbackIcon: icon,
            fallbackBg: bgColor,
            fallbackColor: iconColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isProduct
                            ? Colors.blue.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isProduct ? 'Product' : 'Service',
                        style: TextStyle(
                            fontSize: 9,
                            color: iconColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.store_rounded,
                        size: 11, color: Colors.grey.shade400),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        item.shop.name,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.shop.address != null)
                      Text(
                        item.shop.address!,
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade400),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('\$${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.red.shade700)),
                    if (item.rating != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.star_rounded,
                          size: 13, color: Colors.amber.shade600),
                      const SizedBox(width: 2),
                      Text(item.rating!.toStringAsFixed(1),
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500)),
                      if (item.ratingCount > 0)
                        Text(' (${item.ratingCount})',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey.shade400)),
                    ],
                    const Spacer(),
                    _AvailabilityDot(available: item.isAvailable),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Shop browser card ----------

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
              color: available ? Colors.green.shade700 : Colors.grey.shade500),
        ),
      ],
    );
  }
}
