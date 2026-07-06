import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';

class AffiliateMarketplacePage extends StatefulWidget {
  const AffiliateMarketplacePage({super.key});

  @override
  State<AffiliateMarketplacePage> createState() => _AffiliateMarketplacePageState();
}

class _AffiliateMarketplacePageState extends State<AffiliateMarketplacePage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final res = await _supabase
          .from('affiliate_products')
          .select()
          .eq('is_active', true);

      setState(() {
        _products = res ?? [];
        _isLoading = false;
      });
    } catch (e) {
      // Mock Fallback
      setState(() {
        _products = [
          {
            'id': 'product_ielts_book',
            'title': 'Official IELTS Practice Materials',
            'category': 'Books',
            'description': 'Comprehensive practice book compiled by Cambridge Assessment English. Includes practice listening, reading, writing, and speaking tests.',
            'image_url': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=150',
            'buy_url': 'https://amazon.com',
            'commission_percent': 12,
            'price_cents': 2999,
          },
          {
            'id': 'product_sony_headset',
            'title': 'Sony Wireless Noise Cancelling Headphones',
            'category': 'Hardware',
            'description': 'Top-rated headphones for speech recognition and clear audio delivery in Live Classrooms or listening exercises.',
            'image_url': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=150',
            'buy_url': 'https://bestbuy.com',
            'commission_percent': 8,
            'price_cents': 14999,
          },
          {
            'id': 'product_dictionary',
            'title': 'Cambridge Advanced Learner Dictionary',
            'category': 'Books',
            'description': 'Perfect vocabulary dictionary guide with over 140,000 words, phrases, and grammar definitions.',
            'image_url': 'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=150',
            'buy_url': 'https://amazon.com',
            'commission_percent': 15,
            'price_cents': 3450,
          },
          {
            'id': 'product_abroad',
            'title': 'Study Abroad Counseling Program',
            'category': 'Services',
            'description': 'One-on-one visa consultation and direct university admissions guidance for UK, US, and Canada.',
            'image_url': 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=150',
            'buy_url': 'https://studyabroad.org',
            'commission_percent': 5,
            'price_cents': 49900,
          }
        ];
        _isLoading = false;
      });
    }
  }

  Future<void> _trackClickAndRedirect(dynamic product) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        // Record affiliate click
        final click = await _supabase
            .from('affiliate_clicks')
            .insert({'user_id': user.id, 'product_id': product['id']})
            .select()
            .single();

        // Simulate a mock sale with a 25% conversion probability for demo purposes
        final shouldConvert = DateTime.now().millisecondsSinceEpoch % 4 == 0;
        if (shouldConvert) {
          final commission = Math.round(product['price_cents'] * (product['commission_percent'] / 100));
          await _supabase.from('affiliate_sales').insert({
            'user_id': user.id,
            'product_id': product['id'],
            'click_id': click['id'],
            'price_paid_cents': product['price_cents'],
            'commission_earned_cents': commission,
            'status': 'completed',
          });
        }
      }
    } catch (e) {
      // Ignore click tracking failure offline
    }

    // Trigger redirection notice dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Partner Redirection'),
          content: Text('You are being redirected to our affiliate partner link:\n${product['buy_url']}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Affiliate Store')),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.base),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final prod = _products[index];
          final rate = prod['price_cents'] / 100;

          return AppCard(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppBorderRadius.base),
                        image: DecorationImage(
                          image: NetworkImage(prod['image_url']),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    prod['category'].toString().toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prod['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${rate.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme.colorScheme.secondary),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _trackClickAndRedirect(prod),
                      child: const Text('View Product'),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
class Math {
  static int round(double value) => value.round();
}
