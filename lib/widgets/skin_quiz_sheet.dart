import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/glowup_provider.dart';

class SkinQuizSheet extends StatelessWidget {
  const SkinQuizSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SkinQuizSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GlowUpProvider>();
    final c = provider.colors;
    final currentKey = provider.currentUser?.skinKey;

    final profiles = [
      {
        'key': 'oleosa',
        'label': 'Pele Oleosa',
        'goal': 'Controle de Oleosidade & Poros',
        'desc': 'Brilho intenso na zona T, poros aparentes e tendência a cravos.',
        'icon': Icons.water_drop_rounded,
      },
      {
        'key': 'mista',
        'label': 'Pele Mista',
        'goal': 'Equilíbrio & Luminosidade',
        'desc': 'Oleosidade concentrada na zona T e bochechas normais ou secas.',
        'icon': Icons.auto_awesome_rounded,
      },
      {
        'key': 'seca',
        'label': 'Pele Seca / Sensível',
        'goal': 'Hidratação & Barreira Cutânea',
        'desc': 'Sensação de repuxamento, opacidade ou vermelhidão fácil.',
        'icon': Icons.spa_rounded,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: c.border),
      ),
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.text.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: c.primarySoft,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              'OPCIONAL',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: c.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Perfil de Pele (Opcional)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: c.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Escolha seu tipo de pele para adaptar automaticamente sua rotina da manhã e da noite, ou pule esta etapa:',
            style: TextStyle(fontSize: 12.5, color: c.textSub, height: 1.4),
          ),
          const SizedBox(height: 16),
          ...profiles.map((p) {
            final isSelected = currentKey == p['key'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  provider.applySkinProfile(
                    p['key'] as String,
                    p['label'] as String,
                    p['goal'] as String,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rotinas diurna e noturna personalizadas!'),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? c.tint : c.bg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? c.primary : c.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: c.primarySoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(p['icon'] as IconData, color: c.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  p['label'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: c.text,
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle, size: 18, color: c.primary),
                              ],
                            ),
                            Text(
                              p['goal'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: c.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              p['desc'] as String,
                              style: TextStyle(fontSize: 11.5, color: c.textSub),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (currentKey != null) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  provider.clearSkinProfile();
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: c.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Desmarcar opções (Voltar à rotina universal)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.textSub),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: c.surfaceSoft,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Manter rotina universal (Pular)',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
