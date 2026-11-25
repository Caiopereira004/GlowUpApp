import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/glowup_provider.dart';
import '../widgets/skin_quiz_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _pickProfileImage(BuildContext context, GlowUpProvider provider) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      provider.setAvatarFile(picked.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil atualizada!')),
        );
      }
    }
  }

  void _showLgpdDialog(BuildContext context, GlowUpProvider provider) {
    final c = provider.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: const Text('LGPD & Privacidade (Lei 13.709/2018)'),
        content: const Text(
          '1. Finalidade Exclusiva: Seus dados cadastrais, foto de perfil e preferências opcionais de pele são utilizados unicamente para personalizar suas rotinas diurna e noturna.

'
          '2. Segurança: Senhas seguem política de complexidade forte e você pode remover seu perfil de pele a qualquer momento.

'
          '3. Transparência Comercial: A curadoria redireciona diretamente para lojas parceiras oficiais.',
          style: TextStyle(fontSize: 13, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GlowUpProvider>();
    final c = provider.colors;
    final user = provider.currentUser!;
    final hasSkin = user.skinKey != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Meu Perfil', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c.text)),
          const SizedBox(height: 16),

          // Card de Perfil com Foto Alterável
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: c.border),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: c.primary,
                      backgroundImage: user.avatarPath != null ? FileImage(File(user.avatarPath!)) : null,
                      child: user.avatarPath == null
                          ? Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'G',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () => _pickProfileImage(context, provider),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: c.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: c.surface, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 15, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(user.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.text)),
                Text(user.email, style: TextStyle(fontSize: 12.5, color: c.textSub)),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _pickProfileImage(context, provider),
                  icon: const Icon(Icons.image_outlined, size: 16),
                  label: const Text('Alterar foto de perfil', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.primary,
                    side: BorderSide(color: c.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Card Questionário de Pele (Opcional)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 18, color: c.primary),
                        const SizedBox(width: 8),
                        Text('Questionário de Pele (Opcional)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: c.text)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: hasSkin ? c.sageSoft : c.primarySoft,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        hasSkin ? 'Personalizado' : 'Opcional',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: hasSkin ? c.sage : c.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  hasSkin ? '${user.skinLabel} • ${user.skinGoal}' : 'Nenhuma opção marcada • Toque para personalizar',
                  style: TextStyle(fontSize: 12.5, color: c.textSub),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => SkinQuizSheet.show(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          hasSkin ? 'Alterar respostas' : 'Responder questionário',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    if (hasSkin) ...[
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: provider.clearSkinProfile,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: c.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Limpar', style: TextStyle(fontSize: 12, color: c.textSub)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Aparência & Acessibilidade (Modo Escuro, Alto Contraste, Tamanho do Texto)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'APARÊNCIA & ACESSIBILIDADE',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: c.textSub),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(Icons.dark_mode_rounded, color: c.primary),
                  title: const Text('Modo Escuro', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  value: provider.darkMode,
                  activeColor: c.primary,
                  onChanged: provider.toggleDarkMode,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(Icons.contrast_rounded, color: c.primary),
                  title: const Text('Alto Contraste', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  value: provider.highContrast,
                  activeColor: c.primary,
                  onChanged: provider.toggleHighContrast,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(Icons.accessibility_new_rounded, color: c.primary),
                  title: const Text('Reduzir Animações', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  value: provider.reduceMotion,
                  activeColor: c.primary,
                  onChanged: provider.toggleReduceMotion,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tamanho do Texto', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('${provider.fontScale.round()}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: c.primary)),
                  ],
                ),
                Slider(
                  min: 90,
                  max: 125,
                  divisions: 7,
                  value: provider.fontScale,
                  activeColor: c.primary,
                  onChanged: provider.setFontScale,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Sobre & LGPD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sobre o GlowUp', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: c.text)),
                const SizedBox(height: 6),
                Text(
                  'O GlowUp integra rotinas personalizadas de cuidados faciais, curadoria inteligente de dermocosméticos e monitoramento térmico da GlowFridge para preservar a estabilidade dos seus ativos.',
                  style: TextStyle(fontSize: 12, color: c.textSub, height: 1.45),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLgpdDialog(context, provider),
                    icon: Icon(Icons.shield_outlined, size: 16, color: c.sage),
                    label: Text(
                      'LGPD & Privacidade • Lei 13.709/2018',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.sage),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: c.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: provider.logout,
              icon: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFE11D48)),
              label: const Text(
                'Sair da Conta',
                style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: const Color(0xFFE11D48).withValues(alpha: 0.35)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
