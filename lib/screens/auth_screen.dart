import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/glowup_provider.dart';
import '../widgets/brand_logo.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginMode = true;
  bool _obscurePassword = true;
  String? _errorMsg;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool get _hasMinLen => _passwordCtrl.text.length >= 8;
  bool get _hasUpper => RegExp(r'[A-Z]').hasMatch(_passwordCtrl.text);
  bool get _hasLower => RegExp(r'[a-z]').hasMatch(_passwordCtrl.text);
  bool get _hasNum => RegExp(r'[0-9]').hasMatch(_passwordCtrl.text);
  bool get _hasSpec => RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\;/~`]').hasMatch(_passwordCtrl.text);

  bool get _isPasswordStrong =>
      _hasMinLen && _hasUpper && _hasLower && _hasNum && _hasSpec;

  void _submit(GlowUpProvider provider) {
    setState(() => _errorMsg = null);
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pwd = _passwordCtrl.text;

    if (!_isLoginMode && name.length < 2) {
      setState(() => _errorMsg = 'Informe seu nome (mínimo de 2 caracteres).');
      return;
    }
    if (!email.contains('@') || !email.contains('.') || email.length < 5) {
      setState(() => _errorMsg = 'Digite um e-mail válido contendo @ e domínio.');
      return;
    }
    if (pwd.isEmpty) {
      setState(() => _errorMsg = 'Informe sua senha.');
      return;
    }

    if (!_isLoginMode) {
      if (!_isPasswordStrong) {
        setState(() => _errorMsg = 'Sua senha precisa atender a todos os requisitos acima.');
        return;
      }
      final err = provider.registerUser(name: name, email: email, password: pwd);
      if (err != null) {
        setState(() => _errorMsg = err);
      }
    } else {
      final err = provider.loginUser(email: email, password: pwd);
      if (err != null) {
        setState(() => _errorMsg = err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GlowUpProvider>();
    final c = provider.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            children: [
              // Botão Idioma PT-BR / EN
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: provider.toggleLanguage,
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: c.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.language_rounded, size: 15, color: c.primary),
                        const SizedBox(width: 6),
                        Text(
                          provider.lang == 'pt' ? 'PT-BR' : 'EN',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.text),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Identidade Visual Minimalista
              const BrandLogo(size: 66),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'Glow',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: c.text),
                  ),
                  Text(
                    'Up',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 35,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: c.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _isLoginMode
                    ? (provider.lang == 'pt'
                        ? 'Sua rotina inteligente de skincare e controle térmico GlowFridge.'
                        : 'Your smart skincare routine and GlowFridge thermal control.')
                    : (provider.lang == 'pt'
                        ? 'Cadastre-se para personalizar suas rotinas diurna e noturna'
                        : 'Sign up to tailor your morning and night routines'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: c.textSub, height: 1.4),
              ),
              const SizedBox(height: 22),

              // Card de Formulário (100% vazio por padrão)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: c.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isLoginMode) ...[
                      Text('Nome completo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.textSub)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _nameCtrl,
                        decoration: _inputDecoration(c, 'Como gostaria de ser chamado(a)?', Icons.person_outline_rounded),
                      ),
                      const SizedBox(height: 14),
                    ],
                    Text('E-mail', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.textSub)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration(c, 'voce@exemplo.com', Icons.mail_outline_rounded),
                    ),
                    const SizedBox(height: 14),
                    Text('Senha', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.textSub)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      onChanged: (_) => setState(() {}),
                      decoration: _inputDecoration(
                        c,
                        'Digite sua senha',
                        Icons.lock_outline_rounded,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 18,
                            color: c.textSub,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    if (!_isLoginMode) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: c.bg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: c.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Requisitos de segurança da senha:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: c.text)),
                            const SizedBox(height: 6),
                            _reqItem('Mínimo de 8 caracteres', _hasMinLen, c),
                            _reqItem('Uma letra maiúscula (A-Z)', _hasUpper, c),
                            _reqItem('Uma letra minúscula (a-z)', _hasLower, c),
                            _reqItem('Um número (0-9)', _hasNum, c),
                            _reqItem('Um caractere especial (!@#\$%&*)', _hasSpec, c),
                          ],
                        ),
                      ),
                    ],
                    if (_errorMsg != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE11D48).withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Color(0xFFE11D48), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMsg!,
                                style: const TextStyle(color: Color(0xFFE11D48), fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _submit(provider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          _isLoginMode ? 'Entrar' : 'Criar Conta',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoginMode = !_isLoginMode;
                    _errorMsg = null;
                    _nameCtrl.clear();
                    _emailCtrl.clear();
                    _passwordCtrl.clear();
                  });
                },
                child: Text(
                  _isLoginMode ? 'Ainda não tem conta? Criar Conta' : 'Já possui conta? Entrar',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(dynamic c, String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13.5, color: c.textSub.withValues(alpha: 0.6)),
      prefixIcon: Icon(icon, size: 18, color: c.textSub),
      suffixIcon: suffix,
      filled: true,
      fillColor: c.bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: c.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: c.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: c.primary, width: 1.5),
      ),
    );
  }

  Widget _reqItem(String label, bool met, dynamic c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 14,
            color: met ? const Color(0xFF2E7D5B) : c.textSub.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: met ? FontWeight.w600 : FontWeight.w400,
              color: met ? const Color(0xFF2E7D5B) : c.textSub,
            ),
          ),
        ],
      ),
    );
  }
}
