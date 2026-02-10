import 'package:flutter/material.dart';
import '../../../core/theme/liora_theme.dart';

/// Wellness Shop Screen - Curated Product Cards
///
/// Features:
/// - Static curated list
/// - Beautiful product cards
/// - No health data linkage
class WellnessShopScreen extends StatelessWidget {
  const WellnessShopScreen({super.key});

  static const List<Map<String, dynamic>> _products = [
    {
      'name': 'Organic Cotton Pads',
      'description': 'Gentle on skin, kind to nature',
      'price': '\$12.99',
      'emoji': '🌿',
      'color': Color(0xFFE8F5E9),
    },
    {
      'name': 'Menstrual Cup',
      'description': 'Reusable, eco-friendly protection',
      'price': '\$29.99',
      'emoji': '💧',
      'color': Color(0xFFE3F2FD),
    },
    {
      'name': 'Heating Pad',
      'description': 'Soothe cramps naturally',
      'price': '\$24.99',
      'emoji': '🔥',
      'color': Color(0xFFFFF3E0),
    },
    {
      'name': 'Herbal Tea Blend',
      'description': 'Calming chamomile & ginger',
      'price': '\$14.99',
      'emoji': '🍵',
      'color': Color(0xFFF3E5F5),
    },
    {
      'name': 'Period Underwear',
      'description': 'Comfortable leak protection',
      'price': '\$32.99',
      'emoji': '👙',
      'color': Color(0xFFFCE4EC),
    },
    {
      'name': 'Essential Oil Set',
      'description': 'Lavender & peppermint relief',
      'price': '\$19.99',
      'emoji': '🌸',
      'color': Color(0xFFE8EAF6),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LioraColors.primaryGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                title: Text(
                  'Wellness Shop',
                  style: LioraTextStyles.h2,
                ),
                centerTitle: true,
              ),

              // Intro
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(LioraSpacing.lg),
                  child: Text(
                    'Curated products for your comfort and wellbeing 💝',
                    style: LioraTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // Product Grid
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: LioraSpacing.lg),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: LioraSpacing.md,
                    crossAxisSpacing: LioraSpacing.md,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildProductCard(_products[index]),
                    childCount: _products.length,
                  ),
                ),
              ),

              // Footer
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(LioraSpacing.xl),
                  child: Column(
                    children: [
                      Text(
                        '🌸',
                        style: TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'More products coming soon',
                        style: LioraTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LioraRadius.xl),
        boxShadow: LioraShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product image/emoji
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: product['color'] as Color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(LioraRadius.xl),
                ),
              ),
              child: Center(
                child: Text(
                  product['emoji'] as String,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
          ),

          // Product info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(LioraSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] as String,
                    style: LioraTextStyles.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: Text(
                      product['description'] as String,
                      style: LioraTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    product['price'] as String,
                    style: LioraTextStyles.label.copyWith(
                      color: LioraColors.deepRose,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
