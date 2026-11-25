import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/glowup_provider.dart';
import '../widgets/skin_quiz_sheet.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  Future<void> _launchPartner(BuildContext context, String url, String store) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Abrindo $store: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GlowUpProvider>();
    final c = provider.colors;

    const categories = ['Todos', 'Limpeza Facial', 'Hidratação', 'Proteção Solar', 'Antioxidantes'];
    final q = provider.shopSearch.trim().toLowerCase();

    final filtered = GlowUpProvider.catalog.where((p) {
      final matchCat = provider.shopCategory == 'Todos' || p.category == provider.shopCategory;
      final matchQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.store.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
      final matchSkin = !provider.onlyForMySkin ||
          provider.currentUser?.skinKey == null ||
          p.skinTag == provider.currentUser!.skinKey;
      return matchCat && matchQuery && matchSkin;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Curadoria GlowUp', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c.text)),
                    Text('40 dermocosméticos com encaminhamento direto', style: TextStyle(fontSize: 12.5, color: c.textSub)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: c.sageSoft, borderRadius: BorderRadius.circular(99)),
                child: Text(
                  '${filtered.length} itens',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: c.sage),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Campo de Busca
          TextField(
            onChanged: provider.setShopSearch,
            decoration: InputDecoration(
              hintText: 'Buscar ativo, produto ou loja...',
              prefixIcon: Icon(Icons.search_rounded, size: 19, color: c.textSub),
              filled: true,
              fillColor: c.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: c.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: c.border),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Chips de Categoria + Filtro "Para Sua Pele"
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: provider.onlyForMySkin,
                    avatar: Icon(
                      Icons.auto_awesome,
                      size: 15,
                      color: provider.onlyForMySkin ? Colors.white : c.primary,
                    ),
                    label: const Text('Para Sua Pele'),
                    selectedColor: c.primary,
                    backgroundColor: c.tint,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: provider.onlyForMySkin ? Colors.white : c.primary,
                    ),
                    onSelected: (_) {
                      if (provider.currentUser?.skinKey == null) {
                        SkinQuizSheet.show(context);
                      } else {
                        provider.toggleForMySkin();
                      }
                    },
                  ),
                ),
                ...categories.map((cat) {
                  final active = provider.shopCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: active,
                      label: Text(cat),
                      selectedColor: c.primary,
                      backgroundColor: c.surface,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : c.textSub,
                      ),
                      onSelected: (_) => provider.setShopCategory(cat),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Lista de Dermocosméticos
          ...filtered.map(
            (prod) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: c.tint,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.spa_rounded, color: c.primary, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: c.surfaceSoft,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    prod.store,
                                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: c.textSub),
                                  ),
                                  const SizedBox(width: 3),
                                  Icon(Icons.open_in_new, size: 10.5, color: c.textSub),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.ac_unit, size: 12, color: Colors.lightBlue),
                                const SizedBox(width: 3),
                                Text(
                                  prod.temp,
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.lightBlue),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prod.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: c.text),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'R\$ ${prod.price.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: c.primary),
                            ),
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: () => _launchPartner(context, prod.url, prod.store),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: c.primary),
                                    backgroundColor: c.tint,
                                    foregroundColor: c.primary,
                                    minimumSize: Size.zero,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Loja ↗', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                                const SizedBox(width: 6),
                                ElevatedButton(
                                  onPressed: () {
                                    provider.addToCart(prod);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${prod.name} adicionado à sacola!')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: c.primary,
                                    foregroundColor: Colors.white,
                                    minimumSize: Size.zero,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('+ Sacola', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
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
