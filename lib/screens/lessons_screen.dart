import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/glowup_provider.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GlowUpProvider>();
    final c = provider.colors;
    final current = provider.lessons[provider.activeLesson];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aulas & Guias', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c.text)),
          Text('Tutoriais práticos para potencializar seus resultados', style: TextStyle(fontSize: 13, color: c.textSub)),
          const SizedBox(height: 16),

          // Player Interativo
          Container(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: c.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: provider.toggleLessonPlay,
                  child: Container(
                    height: 195,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: current.gradientColors.map((hex) => Color(hex)).toList(),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'GLOWUP ACADEMY',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black38,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    current.duration,
                                    style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () => provider.toggleLessonFavorite(provider.activeLesson),
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.white.withValues(alpha: 0.22),
                                    child: Icon(
                                      current.favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      color: current.favorite ? Colors.pinkAccent.shade100 : Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (provider.isLessonPlaying)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Resumo Prático:',
                                  style: TextStyle(color: Color(0xFFF9DFC2), fontSize: 11.5, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                ...current.tips.map(
                                  (tip) => Text(tip, style: const TextStyle(color: Colors.white, fontSize: 11.5)),
                                ),
                              ],
                            ),
                          )
                        else
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white.withValues(alpha: 0.25),
                            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                          ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: provider.isLessonPlaying ? 0.65 : 0.18,
                            minHeight: 4,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation(Color(0xFFF9DFC2)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: c.primarySoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          current.module,
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: c.primary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(current.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c.text)),
                      const SizedBox(height: 4),
                      Text(current.desc, style: TextStyle(fontSize: 12.5, color: c.textSub, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Trilha de Módulos
          ...List.generate(provider.lessons.length, (idx) {
            final lesson = provider.lessons[idx];
            final active = idx == provider.activeLesson;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => provider.selectLesson(idx),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: active ? c.tint : c.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: active ? c.primary : c.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: active ? c.primary : c.primarySoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          active ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                          color: active ? Colors.white : c.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lesson.title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: c.text)),
                            Text('${lesson.duration} min', style: TextStyle(fontSize: 12, color: c.textSub)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => provider.toggleLessonFavorite(idx),
                        icon: Icon(
                          lesson.favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: lesson.favorite ? Colors.pink : c.textSub,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
