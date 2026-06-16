import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../shop/services/shop_api_service.dart';
import '../../../shop/data/models/shop_model.dart';
import '../../../../shared/widgets/image_picker_widget.dart';
import '../../services/image_search_service.dart';
import '../../../shop/presentation/widgets/item_detail_sheet.dart';
import 'package:my_app/shared/widgets/item_image.dart';

/// Page for searching products by image
class ImageSearchPage extends StatefulWidget {
  final int? shopId;
  const ImageSearchPage({super.key, this.shopId});

  @override
  State<ImageSearchPage> createState() => _ImageSearchPageState();
}

class _ImageSearchPageState extends State<ImageSearchPage> {
  final ImageSearchService _searchService = ImageSearchService();
  final ShopApiService _shopService = ShopApiService();

  File? _selectedImage;
  ImageSearchResult? _searchResult;
  bool _isSearching = false;
  String? _errorMessage;

  List<ShopResponse> _shops = [];
  ShopResponse? _selectedShop;
  bool _loadingShops = false;
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;
    
    final auth = context.read<AuthService>();
    if (auth.token != null) {
      _shopService.setAuthToken(auth.token!);
    }
    
    if (widget.shopId != null) {
      _loadSingleShop(widget.shopId!);
    } else {
      _loadShops();
    }
  }

  Future<void> _loadSingleShop(int id) async {
    setState(() => _loadingShops = true);
    try {
      final shop = await _shopService.getShopById(id);
      if (!mounted) return;
      setState(() {
        _selectedShop = shop;
        _loadingShops = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingShops = false);
    }
  }

  Future<void> _loadShops() async {
    setState(() => _loadingShops = true);
    try {
      final res = await _shopService.getShops(limit: 50);
      if (!mounted) return;
      setState(() {
        _shops = res.shops.where((s) => s.isActive).toList();
        if (_shops.isNotEmpty) {
          _selectedShop = _shops.first;
        }
        _loadingShops = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingShops = false);
    }
  }

  Future<void> _searchByImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    if (_selectedShop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a garage/shop first')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _searchResult = null;
    });

    try {
      final result = await _searchService.searchByImage(
        _selectedImage!,
        _selectedShop!.id,
      );

      if (mounted) {
        setState(() {
          _searchResult = result;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search by Image'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Take a photo or upload an image to find similar products',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Shop Selector
            if (_loadingShops)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue,
                  ),
                ),
              )
            else if (_shops.isNotEmpty && widget.shopId == null) ...[
              const Text(
                'Select Garage / Shop to Search',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ShopResponse>(
                    value: _selectedShop,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                    items: _shops.map((shop) {
                      return DropdownMenuItem<ShopResponse>(
                        value: shop,
                        child: Text(
                          shop.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (shop) {
                      setState(() {
                        _selectedShop = shop;
                        _searchResult = null;
                        _errorMessage = null;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ] else if (_selectedShop != null && widget.shopId != null) ...[
              Row(
                children: [
                  const Icon(Icons.storefront, size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Searching inside: ${_selectedShop!.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Image Picker
            ImagePickerWidget(
              onImageSelected: (File? image) {
                setState(() {
                  _selectedImage = image;
                  _searchResult = null;
                  _errorMessage = null;
                });
              },
              initialImage: _selectedImage,
              height: 250,
              placeholderText: 'Tap to take or select photo',
            ),
            const SizedBox(height: 24),

            // Search Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSearching ? null : _searchByImage,
                icon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(_isSearching ? 'Searching...' : 'Search Products'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Error Message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            // Search Results
            if (_searchResult != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Found ${_searchResult!.totalResults} products',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_searchResult!.products.isNotEmpty)
                    Text(
                      'Top ${_searchResult!.products.length} matches',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (_searchResult!.products.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No similar products found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchResult!.products.length,
                  itemBuilder: (context, index) {
                    final product = _searchResult!.products[index];
                    return _ProductCard(
                      product: product,
                      shop: _selectedShop!,
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Card widget to display a similar product
class _ProductCard extends StatelessWidget {
  final SimilarProduct product;
  final ShopResponse shop;

  const _ProductCard({required this.product, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          showProductDetail(context, product.toShopProduct(), shop);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image
              ItemImage(
                imageUrl: product.imageUrl,
                size: 80,
                borderRadius: 8,
                fallbackIcon: Icons.inventory_2_outlined,
                fallbackBg: Colors.blue.shade50,
                fallbackColor: Colors.blue.shade400,
              ),
              const SizedBox(width: 16),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.brand != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        product.brand!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.formattedPrice,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.similarityPercentage,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
