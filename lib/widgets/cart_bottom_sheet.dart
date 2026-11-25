import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/glowup_provider.dart';

class CartBottomSheet extends StatelessWidget {
  const CartBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CartBottomSheet(),
    );
  }

  Future<void> _openPartnerUrl(BuildContext context, String url, String label) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir $label ($url)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GlowUpProvider>();
    final c = provider.colors;

    final uniqueStores = <String, String>{};
    for (final item in provider.cart) {
      uniqueStores[item.store] = item.url;
    }

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: c.border),
      ),
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: c.text.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sua Sacola',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.text),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close_rounded, color: c.textSub),
              ),
            ],
          ),
          if (provider.cart.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'Sua sacola está vazia no momento.',
                style: TextStyle(color: c.textSub, fontSize: 14),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.tint,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.open_in_new_rounded, size: 16, color: c.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Toque em "Comprar ↗" para acessar diretamente o site oficial da loja parceira.',
                      style: TextStyle(fontSize: 12, color: c.textSub),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: provider.cart.length,
                separatorBuilder: (_, __) => Divider(color: c.border, height: 1),
                itemBuilder: (context, index) {
                  final item = provider.cart[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  color: c.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.store} • R\$ ${item.price.toStringAsFixed(2).replaceAll('.', ',')}',
                                style: TextStyle(fontSize: 12, color: c.primary, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _openPartnerUrl(context, item.url, item.store),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: c.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Comprar ↗', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          onPressed: () => provider.removeFromCart(index),
                          icon: Icon(Icons.delete_outline_rounded, size: 18, color: c.textSub),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Estimado (${provider.cart.length} itens)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: c.text)),
                  Text(
                    'R\$ ${provider.cartTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: c.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...uniqueStores.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openPartnerUrl(context, entry.value, entry.key),
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: Text('Ir para ${entry.key}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.primaryDeep,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
