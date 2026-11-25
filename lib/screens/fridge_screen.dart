import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/glowup_provider.dart';

class FridgeScreen extends StatelessWidget {
  const FridgeScreen({super.key});

  void _openAddItemModal(BuildContext context, GlowUpProvider provider) {
    final nameCtrl = TextEditingController();
    final minCtrl = TextEditingController(text: '4');
    final maxCtrl = TextEditingController(text: '7');
    final valCtrl = TextEditingController(text: 'Validade: 60 dias');
    final c = provider.colors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cadastrar Cosmético na GlowFridge',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c.text),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome do Cosmético', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Temp. Mín (°C)', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: maxCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Temp. Máx (°C)', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: valCtrl,
                decoration: const InputDecoration(labelText: 'Validade após aberto', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final minT = double.tryParse(minCtrl.text) ?? 4.0;
                    final maxT = double.tryParse(maxCtrl.text) ?? 7.0;
                    if (nameCtrl.text.trim().isNotEmpty) {
                      provider.addFridgeItem(nameCtrl.text.trim(), minT, maxT, valCtrl.text.trim());
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: c.primary, foregroundColor: Colors.white),
                  child: const Text('Salvar na Geladeira'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GlowUpProvider>();
    final c = provider.colors;
    final ideal = provider.fridgeTemp >= 4.0 && provider.fridgeTemp <= 8.0;
    final warmingCount = provider.warmingItemsCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GlowFridge', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c.text)),
          Text('Controle térmico inteligente para ativos sensíveis', style: TextStyle(fontSize: 13, color: c.textSub)),
          const SizedBox(height: 16),

          // Painel Térmico + Simulador Porta 40s
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1C2430), Color(0xFF0E131A)],
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'TEMPERATURA INTERNA',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: Colors.white60),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => provider.updateFridgeTemp(provider.fridgeTemp - 0.5),
                      style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.12)),
                      icon: const Icon(Icons.remove, color: Colors.white),
                    ),
                    const SizedBox(width: 18),
                    Text(
                      '${provider.fridgeTemp.toStringAsFixed(1)}°C',
                      style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(width: 18),
                    IconButton(
                      onPressed: () => provider.updateFridgeTemp(provider.fridgeTemp + 0.5),
                      style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.12)),
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
                Text(
                  ideal
                      ? 'Faixa ideal para antioxidantes (4°C – 8°C)'
                      : 'Atenção: temperatura fora da faixa ideal (4°C – 8°C)',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: ideal ? Colors.greenAccent.shade200 : Colors.amber.shade300,
                  ),
                ),
                const SizedBox(height: 14),
                Slider(
                  min: 2.0,
                  max: 15.0,
                  divisions: 26,
                  value: provider.fridgeTemp,
                  activeColor: Colors.lightBlueAccent,
                  onChanged: provider.updateFridgeTemp,
                ),
                Divider(color: Colors.white.withValues(alpha: 0.12), height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Porta: ${provider.fridgeDoorOpen ? 'Aberta' : 'Fechada'}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          Text(
                            provider.fridgeDoorOpen
                                ? 'Fechamento automático em ${provider.fridgeDoorSeconds}s'
                                : 'Sensor magnético de segurança ativo (40s)',
                            style: const TextStyle(color: Colors.white60, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => provider.toggleFridgeDoor(
                        onAutoClose: () {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.lock_outline, size: 18, color: Colors.white),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text('Porta fechada automaticamente após 40s para proteger seus cosméticos!'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: provider.fridgeDoorOpen ? Colors.amber : Colors.white.withValues(alpha: 0.16),
                        foregroundColor: provider.fridgeDoorOpen ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        provider.fridgeDoorOpen ? 'Fechar Agora' : 'Simular Abertura',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Alerta caso algum cosmético aqueça
          if (warmingCount > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.amber.shade700),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$warmingCount ${warmingCount == 1 ? 'produto aqueceu' : 'produtos aqueceram'} e está fora da temperatura certa!',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.amber.shade900),
                    ),
                  ),
                ],
              ),
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cosméticos Armazenados', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: c.text)),
              TextButton(
                onPressed: () => _openAddItemModal(context, provider),
                style: TextButton.styleFrom(
                  backgroundColor: c.primarySoft,
                  foregroundColor: c.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('+ Cadastrar item', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ...provider.fridgeItems.map((item) {
            final isWarming = provider.fridgeTemp > item.maxTemp;
            final isCold = provider.fridgeTemp < item.minTemp;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isWarming ? Colors.amber.withValues(alpha: 0.08) : c.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isWarming ? Colors.amber.shade600 : c.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: (isWarming ? Colors.amber : Colors.lightBlue).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.science_rounded,
                      color: isWarming ? Colors.amber.shade800 : Colors.lightBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: c.text)),
                        Text(
                          'Faixa ideal: ${item.minTemp}°C – ${item.maxTemp}°C • ${item.validity}',
                          style: TextStyle(fontSize: 12, color: c.textSub),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isWarming
                                ? Colors.amber.withValues(alpha: 0.2)
                                : (isCold ? Colors.lightBlue.withValues(alpha: 0.2) : c.sageSoft),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isWarming
                                    ? Icons.warning_amber_rounded
                                    : (isCold ? Icons.ac_unit : Icons.check_circle_outline),
                                size: 13,
                                color: isWarming
                                    ? Colors.amber.shade900
                                    : (isCold ? Colors.lightBlue.shade800 : c.sage),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isWarming
                                    ? 'Aquecendo • Fora da temperatura certa'
                                    : (isCold ? 'Muito Frio' : 'Temperatura Ideal'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isWarming
                                      ? Colors.amber.shade900
                                      : (isCold ? Colors.lightBlue.shade800 : c.sage),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => provider.removeFridgeItem(item.id),
                    icon: Icon(Icons.close_rounded, size: 18, color: c.textSub),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
