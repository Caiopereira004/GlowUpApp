import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/glowup_provider.dart';
import '../widgets/skin_quiz_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openAddStepDialog(BuildContext context, GlowUpProvider provider) {
    final stepCtrl = TextEditingController();
    final activeCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
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
                'Nova Etapa • ${provider.routinePeriod == 'morning' ? 'Rotina da Manhã' : 'Rotina da Noite'}',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c.text),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: stepCtrl,
                decoration: const InputDecoration(labelText: 'Nome da etapa', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: activeCtrl,
                decoration: const InputDecoration(labelText: 'Produto / Ativo', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'Observação (opcional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (stepCtrl.text.trim().isNotEmpty && activeCtrl.text.trim().isNotEmpty) {
                      provider.addCustomStep(
                        stepCtrl.text.trim(),
                        activeCtrl.text.trim(),
                        noteCtrl.text.trim(),
                      );
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: c.primary, foregroundColor: Colors.white),
                  child: const Text('Adicionar Etapa'),
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
    final user = provider.currentUser!;
    final hasSkin = user.skinKey != null;

    final steps = provider.routines[provider.routinePeriod] ?? [];
    final doneCount = steps.where((s) => s.done).length;
    final progress = steps.isEmpty ? 0.0 : doneCount / steps.length;
    final waterProgress = (provider.waterMl / provider.waterGoalMl).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saudação Refinada em Dois Níveis
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6E2B40), Color(0xFF9E4761), Color(0xFFC9768E)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.lang == 'pt' ? 'Olá,' : 'Hello,',
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 23,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFF9DFC2),
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => provider.setTab(4),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        backgroundImage: user.avatarPath != null ? FileImage(File(user.avatarPath!)) : null,
                        child: user.avatarPath == null
                            ? Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'G',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
                const SizedBox(height: 12),
                if (hasSkin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PERFIL ATIVO',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFFF9DFC2)),
                            ),
                            Text(
                              '${user.skinLabel} • ${user.skinGoal}',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => SkinQuizSheet.show(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Alterar', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  )
                else ...[
                  Text(
                    'Sua rotina essencial está pronta. Se desejar, responda ao questionário opcional para adaptar cada etapa à sua pele.',
                    style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.92), height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => SkinQuizSheet.show(context),
                      icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                      label: const Text('Personalizar minha rotina (Opcional)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF7A3248),
                        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Alternância Rotina da Manhã / Noite
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.border),
                ),
                child: Row(
                  children: [
                    _periodButton('morning', 'Rotina da Manhã', Icons.wb_sunny_rounded, provider),
                    _periodButton('night', 'Rotina da Noite', Icons.nightlight_round, provider),
                  ],
                ),
              ),
              Text(
                '$doneCount/${steps.length}',
                style: TextStyle(fontWeight: FontWeight.w800, color: c.primary, fontSize: 13.5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: c.primarySoft,
              valueColor: AlwaysStoppedAnimation(c.primary),
            ),
          ),
          const SizedBox(height: 14),

          // Etapas
          ...steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => provider.toggleRoutineStep(step.id),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: step.done ? c.tint : c.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: step.done ? c.primary : c.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: step.done ? c.primary : Colors.transparent,
                          border: Border.all(color: step.done ? c.primary : c.border, width: 2),
                        ),
                        child: step.done ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.step,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                decoration: step.done ? TextDecoration.lineThrough : null,
                                color: c.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              step.active,
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.primary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              step.note,
                              style: TextStyle(fontSize: 12, color: c.textSub),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _openAddStepDialog(context, provider),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: c.primary),
                backgroundColor: c.tint,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                '+ Adicionar etapa personalizada',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Hidratação Diária
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_drink_rounded, color: Colors.lightBlue, size: 18),
                        const SizedBox(width: 8),
                        Text('Hidratação Diária', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: c.text)),
                      ],
                    ),
                    Text(
                      '${provider.waterMl} / ${provider.waterGoalMl} ml',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.lightBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: waterProgress,
                    minHeight: 7,
                    backgroundColor: Colors.lightBlue.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation(Colors.lightBlue),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: provider.addWater,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.lightBlue.withValues(alpha: 0.12),
                      foregroundColor: Colors.lightBlue.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('+ 250 ml', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Constância Semanal
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Constância Semanal', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: c.text)),
                    Text(
                      '${provider.weekDays.where((d) => d.done).length}/7 dias',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: c.sage),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(provider.weekDays.length, (idx) {
                    final day = provider.weekDays[idx];
                    return GestureDetector(
                      onTap: () => provider.toggleWeekDay(idx),
                      child: Column(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: day.done ? c.sage : c.bg,
                              border: Border.all(color: day.done ? c.sage : c.border),
                            ),
                            child: Center(
                              child: day.done
                                  ? const Icon(Icons.check, size: 15, color: Colors.white)
                                  : Text(day.day[0], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.textSub)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(day.day, style: TextStyle(fontSize: 11, color: c.textSub, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodButton(String key, String label, IconData icon, GlowUpProvider provider) {
    final active = provider.routinePeriod == key;
    final c = provider.colors;

    return GestureDetector(
      onTap: () => provider.setRoutinePeriod(key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? c.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 13, color: active ? Colors.white : c.textSub),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : c.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
