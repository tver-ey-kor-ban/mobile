import 'package:flutter/material.dart';
import '../../data/models/shop_model.dart';
import '../../data/models/browse_models.dart';
import '../../../booking/presentation/pages/booking_page.dart';

void showProductDetail(
    BuildContext context, ShopProduct product, ShopResponse shop) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ProductDetailSheet(product: product, shop: shop),
  );
}

void showServiceDetail(
    BuildContext context, ShopServiceItem service, ShopResponse shop) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ServiceDetailSheet(service: service, shop: shop),
  );
}

// ─── Product detail ───────────────────────────────────────────────────────────

class _ProductDetailSheet extends StatelessWidget {
  final ShopProduct product;
  final ShopResponse shop;
  const _ProductDetailSheet({required this.product, required this.shop});

  @override
  Widget build(BuildContext context) {
    final available = product.isAvailable;
    return _SheetScaffold(
      accentColor: Colors.blue,
      icon: Icons.inventory_2_outlined,
      header: Column(
        children: [
          Text(
            product.name,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Availability + stock
          Row(
            children: [
              _StatusChip(
                label: available ? 'In Stock' : 'Out of Stock',
                color: available ? Colors.green : Colors.grey,
              ),
              if (product.stockQuantity != null) ...[
                const SizedBox(width: 8),
                _StatusChip(
                  label: '${product.stockQuantity} units',
                  color: Colors.blue,
                ),
              ],
              if (product.rating != null) ...[
                const SizedBox(width: 8),
                _RatingChip(
                    rating: product.rating!, count: product.ratingCount),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Brand / category
          if (product.brand != null || product.category != null) ...[
            _DetailRow(
              icon: Icons.label_outline,
              label: 'Brand / Category',
              value: [product.brand, product.category]
                  .whereType<String>()
                  .join(' · '),
            ),
            const SizedBox(height: 12),
          ],

          // Shop
          _DetailRow(
            icon: Icons.store_outlined,
            label: 'Shop',
            value: shop.name,
          ),
          const SizedBox(height: 16),

          // Description
          if (product.description != null) ...[
            const Text('Description',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            Text(
              product.description!,
              style: TextStyle(
                  fontSize: 14, color: Colors.grey.shade600, height: 1.6),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
      ctaLabel: 'Order Now',
      ctaIcon: Icons.shopping_cart_outlined,
      ctaEnabled: available,
      onCta: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  BookingPage(shopId: shop.id, shopName: shop.name)),
        );
      },
    );
  }
}

// ─── Service detail ───────────────────────────────────────────────────────────

class _ServiceDetailSheet extends StatelessWidget {
  final ShopServiceItem service;
  final ShopResponse shop;
  const _ServiceDetailSheet({required this.service, required this.shop});

  @override
  Widget build(BuildContext context) {
    final available = service.isAvailable;
    return _SheetScaffold(
      accentColor: Colors.orange,
      icon: Icons.build_outlined,
      header: Column(
        children: [
          Text(
            service.name,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            '\$${service.price.toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status chips
          Row(
            children: [
              _StatusChip(
                label: available ? 'Available' : 'Unavailable',
                color: available ? Colors.green : Colors.grey,
              ),
              if (service.estimatedMinutes != null) ...[
                const SizedBox(width: 8),
                _StatusChip(
                  label: '${service.estimatedMinutes} min',
                  color: Colors.orange,
                  icon: Icons.schedule_outlined,
                ),
              ],
              if (service.rating != null) ...[
                const SizedBox(width: 8),
                _RatingChip(
                    rating: service.rating!, count: service.ratingCount),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Shop
          _DetailRow(
            icon: Icons.store_outlined,
            label: 'Shop',
            value: shop.name,
          ),
          const SizedBox(height: 12),

          // Duration breakdown
          if (service.estimatedMinutes != null) ...[
            _DetailRow(
              icon: Icons.timer_outlined,
              label: 'Estimated Duration',
              value: _formatDuration(service.estimatedMinutes!),
            ),
            const SizedBox(height: 16),
          ],

          // Description
          if (service.description != null) ...[
            const Text('Description',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            Text(
              service.description!,
              style: TextStyle(
                  fontSize: 14, color: Colors.grey.shade600, height: 1.6),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
      ctaLabel: 'Book Now',
      ctaIcon: Icons.calendar_today_outlined,
      ctaEnabled: available,
      onCta: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  BookingPage(shopId: shop.id, shopName: shop.name)),
        );
      },
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes minutes';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '$h hour${h > 1 ? 's' : ''}' : '$h h $m min';
  }
}

// ─── Shared sheet scaffold ────────────────────────────────────────────────────

class _SheetScaffold extends StatelessWidget {
  final Color accentColor;
  final IconData icon;
  final Widget header;
  final Widget body;
  final String ctaLabel;
  final IconData ctaIcon;
  final bool ctaEnabled;
  final VoidCallback onCta;

  const _SheetScaffold({
    required this.accentColor,
    required this.icon,
    required this.header,
    required this.body,
    required this.ctaLabel,
    required this.ctaIcon,
    required this.ctaEnabled,
    required this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Gradient header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.85),
                    accentColor.withValues(alpha: 0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 14),
                  header,
                ],
              ),
            ),

            // Scrollable detail body
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: EdgeInsets.fromLTRB(
                    20, 20, 20, 16 + bottomPadding),
                children: [body],
              ),
            ),

            // CTA button
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomPadding),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: ctaEnabled ? onCta : null,
                  icon: Icon(ctaIcon, size: 20),
                  label: Text(ctaLabel,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        ctaEnabled ? Colors.red.shade700 : Colors.grey.shade300,
                    foregroundColor:
                        ctaEnabled ? Colors.white : Colors.grey.shade500,
                    elevation: ctaEnabled ? 2 : 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small reusable chips / rows ──────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const _StatusChip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  final double rating;
  final int? count;
  const _RatingChip({required this.rating, this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 13, color: Colors.amber),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
                fontSize: 12,
                color: Colors.amber,
                fontWeight: FontWeight.w700),
          ),
          if (count != null)
            Text(' ($count)',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade400),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
