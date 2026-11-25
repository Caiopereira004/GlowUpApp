import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/routine_model.dart';
import '../models/fridge_item_model.dart';
import '../models/lesson_model.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';

class GlowUpProvider extends ChangeNotifier {
  // Idioma & Autenticação
  String lang = 'pt';
  final List<UserModel> _registeredUsers = [];
  UserModel? currentUser;

  // Navegação e Rotinas
  int activeTabIndex = 0;
  String routinePeriod = 'morning'; // 'morning' | 'night'
  Map<String, List<RoutineStep>> routines = _cloneTemplate('universal');

  // Hidratação & Constância Semanal
  int waterMl = 1000;
  final int waterGoalMl = 2000;
  final List<WeekDayProgress> weekDays = [
    WeekDayProgress(day: 'Seg', done: true),
    WeekDayProgress(day: 'Ter', done: true),
    WeekDayProgress(day: 'Qua', done: true),
    WeekDayProgress(day: 'Qui', done: false),
    WeekDayProgress(day: 'Sex', done: false),
    WeekDayProgress(day: 'Sáb', done: false),
    WeekDayProgress(day: 'Dom', done: false),
  ];

  // GlowFridge (Controle térmico + Porta automática em 40s)
  double fridgeTemp = 6.0;
  bool fridgeDoorOpen = false;
  int fridgeDoorSeconds = 40;
  Timer? _doorTimer;

  final List<FridgeItem> fridgeItems = [
    FridgeItem(
      id: 'fi1',
      name: 'Sérum Vitamina C 10%',
      minTemp: 4.0,
      maxTemp: 6.0,
      validity: 'Validade: 45 dias',
    ),
    FridgeItem(
      id: 'fi2',
      name: 'Roll-on Olhos Cafeína',
      minTemp: 3.0,
      maxTemp: 5.5,
      validity: 'Validade: 60 dias',
    ),
    FridgeItem(
      id: 'fi3',
      name: 'Bruma Facial Calmante',
      minTemp: 4.0,
      maxTemp: 8.0,
      validity: 'Validade: 90 dias',
    ),
  ];

  // Aulas & Guias
  int activeLesson = 0;
  bool isLessonPlaying = false;
  final List<LessonModel> lessons = [
    LessonModel(
      module: 'MÓDULO 01 • ORDEM DE APLICAÇÃO',
      title: 'Camadas Inteligentes: Dia vs Noite',
      desc: 'Aprenda a aplicar ativos da textura mais aquosa para a mais densa para maximizar a permeação cutânea.',
      duration: '03:45',
      gradientColors: [0xFF6D283E, 0xFF9E4761, 0xFFC9738C],
      tips: [
        '1. Higienização com pH fisiológico',
        '2. Séruns aquosos (Vitamina C / Hialurônico)',
        '3. Hidratante selador',
        '4. Protetor Solar FPS 60 (apenas dia)',
      ],
    ),
    LessonModel(
      module: 'MÓDULO 02 • GLOWFRIDGE',
      title: 'Por que Refrigerar Antioxidantes?',
      desc: 'Descubra como manter séruns entre 4°C e 8°C reduz a oxidação da Vitamina C e potencializa o efeito calmante.',
      duration: '04:12',
      gradientColors: [0xFF1B2B3A, 0xFF274C6B, 0xFF3B7A9E],
      favorite: true,
      tips: [
        '• Faixa ideal: 4°C a 8°C',
        '• Retarda degradação por calor e luz',
        '• Reduz edema matinal na área dos olhos',
      ],
    ),
    LessonModel(
      module: 'MÓDULO 03 • BARREIRA CUTÂNEA',
      title: 'Recuperação Noturna com Ceramidas',
      desc: 'Como evitar o efeito rebote e fortalecer o manto hidrolipídico enquanto você dorme.',
      duration: '05:10',
      gradientColors: [0xFF3B2647, 0xFF663E7A, 0xFF9864B0],
      tips: [
        '• Evite água muito quente no rosto',
        '• Associe Pantenol e Niacinamida',
        '• Hidrate mesmo peles oleosas',
      ],
    ),
  ];

  // Loja (40 produtos com links diretos)
  String shopSearch = '';
  String shopCategory = 'Todos';
  bool onlyForMySkin = false;
  final List<ProductModel> cart = [];

  // Acessibilidade & Aparência
  bool darkMode = false;
  bool highContrast = false;
  bool reduceMotion = false;
  double fontScale = 100.0;

  AppColors get colors => AppColors.of(
        darkMode: darkMode,
        highContrastMode: highContrast,
      );

  void toggleLanguage() {
    lang = lang == 'pt' ? 'en' : 'pt';
    notifyListeners();
  }

  // Autenticação
  String? registerUser({
    required String name,
    required String email,
    required String password,
  }) {
    final cleanEmail = email.trim().toLowerCase();
    if (_registeredUsers.any((u) => u.email == cleanEmail)) {
      return lang == 'pt'
          ? 'Este e-mail já está cadastrado.'
          : 'This email is already registered.';
    }
    final user = UserModel(
      name: name.trim(),
      email: cleanEmail,
      password: password,
    );
    _registeredUsers.add(user);
    currentUser = user.copyWith();
    routines = _cloneTemplate('universal');
    activeTabIndex = 0;
    notifyListeners();
    return null;
  }

  String? loginUser({
    required String email,
    required String password,
  }) {
    final cleanEmail = email.trim().toLowerCase();
    final idx = _registeredUsers.indexWhere((u) => u.email == cleanEmail);
    if (idx == -1) {
      return lang == 'pt'
          ? 'Conta não encontrada. Crie uma conta primeiro.'
          : 'Account not found. Please create an account first.';
    }
    if (_registeredUsers[idx].password != password) {
      return lang == 'pt'
          ? 'Senha incorreta. Verifique e tente novamente.'
          : 'Incorrect password. Please check and try again.';
    }
    currentUser = _registeredUsers[idx].copyWith();
    routines = _cloneTemplate(currentUser!.skinKey ?? 'universal');
    activeTabIndex = 0;
    notifyListeners();
    return null;
  }

  void logout() {
    _doorTimer?.cancel();
    fridgeDoorOpen = false;
    fridgeDoorSeconds = 40;
    currentUser = null;
    onlyForMySkin = false;
    notifyListeners();
  }

  void _syncUser() {
    if (currentUser == null) return;
    final idx = _registeredUsers.indexWhere((u) => u.email == currentUser!.email);
    if (idx != -1) {
      _registeredUsers[idx] = currentUser!.copyWith();
    }
  }

  // Questionário Opcional
  void applySkinProfile(String key, String label, String goal) {
    if (currentUser == null) return;
    currentUser = currentUser!.copyWith(
      skinKey: key,
      skinLabel: label,
      skinGoal: goal,
    );
    routines = _cloneTemplate(key);
    _syncUser();
    notifyListeners();
  }

  void clearSkinProfile() {
    if (currentUser == null) return;
    currentUser = currentUser!.copyWith(clearSkin: true);
    onlyForMySkin = false;
    routines = _cloneTemplate('universal');
    _syncUser();
    notifyListeners();
  }

  // Foto de Perfil
  void setAvatarFile(String path) {
    if (currentUser == null) return;
    currentUser = currentUser!.copyWith(avatarPath: path);
    currentUser!.avatarPresetId = null;
    _syncUser();
    notifyListeners();
  }

  void setAvatarPreset(String presetId) {
    if (currentUser == null) return;
    currentUser = currentUser!.copyWith(avatarPresetId: presetId);
    currentUser!.avatarPath = null;
    _syncUser();
    notifyListeners();
  }

  void resetAvatar() {
    if (currentUser == null) return;
    currentUser = currentUser!.copyWith(clearAvatar: true);
    _syncUser();
    notifyListeners();
  }

  // Navegação e Rotinas
  void setTab(int index) {
    activeTabIndex = index;
    isLessonPlaying = false;
    notifyListeners();
  }

  void setRoutinePeriod(String period) {
    routinePeriod = period;
    notifyListeners();
  }

  void toggleRoutineStep(String stepId) {
    final list = routines[routinePeriod] ?? [];
    for (final item in list) {
      if (item.id == stepId) {
        item.done = !item.done;
        break;
      }
    }
    notifyListeners();
  }

  void addCustomStep(String step, String active, String note) {
    routines[routinePeriod]?.add(
      RoutineStep(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        step: step,
        active: active,
        note: note.isEmpty ? 'Etapa personalizada' : note,
      ),
    );
    notifyListeners();
  }

  void addWater() {
    waterMl = (waterMl + 250).clamp(0, waterGoalMl + 500);
    notifyListeners();
  }

  void toggleWeekDay(int index) {
    weekDays[index].done = !weekDays[index].done;
    notifyListeners();
  }

  // GlowFridge
  int get warmingItemsCount =>
      fridgeItems.where((it) => fridgeTemp > it.maxTemp).length;

  void updateFridgeTemp(double value) {
    fridgeTemp = double.parse(value.clamp(2.0, 15.0).toStringAsFixed(1));
    notifyListeners();
  }

  void addFridgeItem(String name, double minT, double maxT, String validity) {
    fridgeItems.insert(
      0,
      FridgeItem(
        id: 'fi_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        minTemp: minT <= maxT ? minT : maxT,
        maxTemp: minT <= maxT ? maxT : minT,
        validity: validity.isEmpty ? 'Validade: 60 dias' : validity,
      ),
    );
    notifyListeners();
  }

  void removeFridgeItem(String id) {
    fridgeItems.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void toggleFridgeDoor({VoidCallback? onAutoClose}) {
    if (fridgeDoorOpen) {
      _doorTimer?.cancel();
      fridgeDoorOpen = false;
      fridgeDoorSeconds = 40;
      notifyListeners();
      return;
    }
    fridgeDoorOpen = true;
    fridgeDoorSeconds = 40;
    notifyListeners();

    _doorTimer?.cancel();
    _doorTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      fridgeDoorSeconds -= 1;
      if (fridgeDoorSeconds <= 0) {
        timer.cancel();
        fridgeDoorOpen = false;
        fridgeDoorSeconds = 40;
        notifyListeners();
        onAutoClose?.call();
      } else {
        notifyListeners();
      }
    });
  }

  // Aulas
  void selectLesson(int index) {
    activeLesson = index;
    isLessonPlaying = false;
    notifyListeners();
  }

  void toggleLessonPlay() {
    isLessonPlaying = !isLessonPlaying;
    notifyListeners();
  }

  void toggleLessonFavorite(int index) {
    lessons[index].favorite = !lessons[index].favorite;
    notifyListeners();
  }

  // Loja & Sacola
  void setShopSearch(String value) {
    shopSearch = value;
    notifyListeners();
  }

  void setShopCategory(String category) {
    shopCategory = category;
    notifyListeners();
  }

  void toggleForMySkin() {
    onlyForMySkin = !onlyForMySkin;
    notifyListeners();
  }

  void addToCart(ProductModel product) {
    cart.add(product);
    notifyListeners();
  }

  void removeFromCart(int index) {
    cart.removeAt(index);
    notifyListeners();
  }

  double get cartTotal => cart.fold(0.0, (sum, item) => sum + item.price);

  // Aparência & Acessibilidade
  void toggleDarkMode(bool value) {
    darkMode = value;
    if (darkMode) highContrast = false;
    notifyListeners();
  }

  void toggleHighContrast(bool value) {
    highContrast = value;
    if (highContrast) darkMode = false;
    notifyListeners();
  }

  void toggleReduceMotion(bool value) {
    reduceMotion = value;
    notifyListeners();
  }

  void setFontScale(double value) {
    fontScale = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _doorTimer?.cancel();
    super.dispose();
  }

  // Templates de Rotinas
  static Map<String, List<RoutineStep>> _cloneTemplate(String key) {
    final source = _templates[key] ?? _templates['universal']!;
    return {
      'morning': source['morning']!.map((e) => e.copy()).toList(),
      'night': source['night']!.map((e) => e.copy()).toList(),
    };
  }

  static final Map<String, Map<String, List<RoutineStep>>> _templates = {
    'universal': {
      'morning': [
        RoutineStep(id: 'u_m1', step: 'Limpeza Suave Equilibrante', active: 'Gel Micelar pH 5.5', note: 'Remove impurezas noturnas sem agredir a barreira'),
        RoutineStep(id: 'u_m2', step: 'Hidratação Leve Diária', active: 'Ácido Hialurônico + Pantenol', note: 'Mantém o viço e a elasticidade ao longo do dia'),
        RoutineStep(id: 'u_m3', step: 'Fotoproteção Ampla', active: 'Protetor Solar FPS 60', note: 'Proteção essencial contra raios UVA/UVB'),
      ],
      'night': [
        RoutineStep(id: 'u_n1', step: 'Demaquilante & Limpeza', active: 'Espuma Suave de Camomila', note: 'Elimina resíduos de poluição e filtro solar'),
        RoutineStep(id: 'u_n2', step: 'Sérum Reparador Noturno', active: 'Niacinamida 5% (GlowFridge 6°C)', note: 'Uniformiza o tom e acalma a pele durante o sono'),
        RoutineStep(id: 'u_n3', step: 'Selagem Hidratante', active: 'Creme Noturno com Esqualano', note: 'Previne a perda de água transepidérmica'),
      ],
    },
    'oleosa': {
      'morning': [
        RoutineStep(id: 'o_m1', step: 'Limpeza Purificante', active: 'Gel com Ácido Salicílico 2%', note: 'Desobstrui poros e controla o brilho excessivo'),
        RoutineStep(id: 'o_m2', step: 'Sérum Seborregulador', active: 'Niacinamida 10% + Zinco PCA', note: 'Minimiza poros dilatados e equilibra a oleosidade'),
        RoutineStep(id: 'o_m3', step: 'Proteção Matte Antibrilho', active: 'Protetor Fluido Toque Seco FPS 60', note: 'Acabamento invisível resistente à umidade'),
      ],
      'night': [
        RoutineStep(id: 'o_n1', step: 'Dupla Limpeza Oil-Free', active: 'Água Micelar + Gel Purificante', note: 'Remove sebo acumulado sem efeito rebote'),
        RoutineStep(id: 'o_n2', step: 'Renovação Celular Leve', active: 'Ácido Mandélico 5% (GlowFridge 5°C)', note: 'Afina a textura da pele e previne cravos'),
        RoutineStep(id: 'o_n3', step: 'Hidratação Aqua-Gel', active: 'Gel-Creme Oil-Free com Pepino', note: 'Hidrata sem pesar ou obstruir os poros'),
      ],
    },
    'mista': {
      'morning': [
        RoutineStep(id: 'm_m1', step: 'Espuma Suave Equilibrante', active: 'Extrato de Chá Verde & Aminoácidos', note: 'Limpa a zona T sem ressecar as bochechas'),
        RoutineStep(id: 'm_m2', step: 'Antioxidante Iluminador', active: 'Sérum Vitamina C 10% (GlowFridge 5°C)', note: 'Devolve luminosidade e protege contra radicais livres'),
        RoutineStep(id: 'm_m3', step: 'Protetor Solar Equilíbrio', active: 'Fluido Hidratante FPS 60', note: 'Textura leve de rápida absorção'),
      ],
      'night': [
        RoutineStep(id: 'm_n1', step: 'Higienização Delicada', active: 'Gel de Limpeza pH Fisiológico', note: 'Preserva o manto hidrolipídico natural'),
        RoutineStep(id: 'm_n2', step: 'Hidratação Inteligente', active: 'Multi-Ácido Hialurônico + B5', note: 'Equilibra áreas secas e controla a zona T'),
        RoutineStep(id: 'm_n3', step: 'Reparação Noturna Suave', active: 'Sérum Peptídeos & Niacinamida 5%', note: 'Fortalece a textura uniforme ao acordar'),
      ],
    },
    'seca': {
      'morning': [
        RoutineStep(id: 's_m1', step: 'Limpeza Cremosa Calmante', active: 'Loção de Limpeza com Aveia Coloidal', note: 'Higieniza sem sensação de repuxamento'),
        RoutineStep(id: 's_m2', step: 'Hidratação Profunda', active: 'Ácido Hialurônico + Pantenol (6°C)', note: 'Atrai e retém umidade nas camadas superficiais'),
        RoutineStep(id: 's_m3', step: 'Protetor Solar Nutritivo', active: 'Creme Solar FPS 60 com Vitamina E', note: 'Protege e mantém a maciez o dia inteiro'),
      ],
      'night': [
        RoutineStep(id: 's_n1', step: 'Cleansing Balm Suave', active: 'Bálsamo Demaquilante Vegetal', note: 'Dissolve impurezas nutrindo a pele sensível'),
        RoutineStep(id: 's_n2', step: 'Sérum Calmante Antivermelhidão', active: 'Centella Asiática + Madecassoside', note: 'Acalma sensibilizações e reforça a barreira'),
        RoutineStep(id: 's_n3', step: 'Restauração Lipídica', active: 'Creme Rico em Ceramidas & Karité', note: 'Recuperação intensiva durante o descanso'),
      ],
    },
  };

  // Catálogo com 40 Dermocosméticos
  static const List<ProductModel> catalog = [
    // Limpeza Facial (10)
    ProductModel(id: 'l1', name: 'Gel de Limpeza Facial GL-01', category: 'Limpeza Facial', skinTag: 'oleosa', store: 'Creamy', url: 'https://www.creamy.com.br', price: 54.90, temp: 'Ambiente'),
    ProductModel(id: 'l2', name: 'Limpador Facial Antioleosidade', category: 'Limpeza Facial', skinTag: 'oleosa', store: 'Sallve', url: 'https://www.sallve.com.br', price: 49.90, temp: 'Ambiente'),
    ProductModel(id: 'l3', name: 'Effaclar Gel Concentrado 300g', category: 'Limpeza Facial', skinTag: 'oleosa', store: 'Drogasil', url: 'https://www.drogasil.com.br', price: 99.90, temp: 'Ambiente'),
    ProductModel(id: 'l4', name: 'Sensibio Gel Moussant Suave', category: 'Limpeza Facial', skinTag: 'seca', store: 'Época Cosméticos', url: 'https://www.epocacosmeticos.com.br', price: 84.00, temp: 'Ambiente'),
    ProductModel(id: 'l5', name: 'Loção de Limpeza Hidratante', category: 'Limpeza Facial', skinTag: 'seca', store: 'Amazon Beauty', url: 'https://www.amazon.com.br', price: 62.90, temp: 'Ambiente'),
    ProductModel(id: 'l6', name: 'Espuma de Limpeza Micelar Rosé', category: 'Limpeza Facial', skinTag: 'mista', store: 'Beleza na Web', url: 'https://www.belezanaweb.com.br', price: 58.00, temp: 'Ambiente'),
    ProductModel(id: 'l7', name: 'Gel de Limpeza Glicerina + B5', category: 'Limpeza Facial', skinTag: 'mista', store: 'Drogasil', url: 'https://www.drogasil.com.br', price: 44.00, temp: 'Ambiente'),
    ProductModel(id: 'l8', name: 'Cleansing Oil Demaquilante Leve', category: 'Limpeza Facial', skinTag: 'seca', store: 'Sephora', url: 'https://www.sephora.com.br', price: 115.00, temp: 'Ambiente'),
    ProductModel(id: 'l9', name: 'Sabonete Líquido Ácido Salicílico', category: 'Limpeza Facial', skinTag: 'oleosa', store: 'Drogasil', url: 'https://www.drogasil.com.br', price: 52.50, temp: 'Ambiente'),
    ProductModel(id: 'l10', name: 'Água Micelar Solução de Limpeza', category: 'Limpeza Facial', skinTag: 'mista', store: 'Amazon Beauty', url: 'https://www.amazon.com.br', price: 39.90, temp: '6°C'),
    // Hidratação (10)
    ProductModel(id: 'h1', name: 'Calming Cream Hidratante', category: 'Hidratação', skinTag: 'seca', store: 'Creamy', url: 'https://www.creamy.com.br', price: 59.90, temp: '6°C'),
    ProductModel(id: 'h2', name: 'Hidratante Firmador Ácido Hialurônico', category: 'Hidratação', skinTag: 'mista', store: 'Sallve', url: 'https://www.sallve.com.br', price: 79.90, temp: '5°C'),
    ProductModel(id: 'h3', name: 'Hydro Boost Water Gel Facial', category: 'Hidratação', skinTag: 'oleosa', store: 'Drogasil', url: 'https://www.drogasil.com.br', price: 74.90, temp: '5°C'),
    ProductModel(id: 'h4', name: 'Minéral 89 Fortificante Diário', category: 'Hidratação', skinTag: 'mista', store: 'Época Cosméticos', url: 'https://www.epocacosmeticos.com.br', price: 159.90, temp: '5°C'),
    ProductModel(id: 'h5', name: 'Cicaplast Baume B5+ Reparador', category: 'Hidratação', skinTag: 'seca', store: 'Drogasil', url: 'https://www.drogasil.com.br', price: 72.00, temp: 'Ambiente'),
    ProductModel(id: 'h6', name: 'Creme Hidratante Ceramidas Triplas', category: 'Hidratação', skinTag: 'seca', store: 'Amazon Beauty', url: 'https://www.amazon.com.br', price: 85.00, temp: '6°C'),
    ProductModel(id: 'h7', name: 'Emulsão Hidratante Oil-Free', category: 'Hidratação', skinTag: 'oleosa', store: 'Beleza na Web', url: 'https://www.belezanaweb.com.br', price: 68.00, temp: '5°C'),
    ProductModel(id: 'h8', name: 'Sérum Multi-Hialurônico 2% + B5', category: 'Hidratação', skinTag: 'mista', store: 'Sephora', url: 'https://www.sephora.com.br', price: 96.00, temp: '5°C'),
    ProductModel(id: 'h9', name: 'Bruma Facial Hidratante Calmante', category: 'Hidratação', skinTag: 'seca', store: 'Creamy', url: 'https://www.creamy.com.br', price: 48.90, temp: '4°C'),
    ProductModel(id: 'h10', name: 'Gel-Creme Hidratante Niacinamida', category: 'Hidratação', skinTag: 'oleosa', store: 'Sallve', url: 'https://www.sallve.com.br', price: 64.90, temp: '6°C'),
    // Proteção Solar (10)
    ProductModel(id: 's1', name: 'Protetor Solar Watery Lotion FPS 60', category: 'Proteção Solar', skinTag: 'mista', store: 'Creamy', url: 'https://www.creamy.com.br', price: 64.90, temp: 'Ambiente'),
    ProductModel(id: 's2', name: 'Protetor Solar Toque Seco FPS 60', category: 'Proteção Solar', skinTag: 'oleosa', store: 'Sallve', url: 'https://www.sallve.com.br', price: 69.90, temp: 'Ambiente'),
    ProductModel(id: 's3', name: 'Anthelios Airlicium FPS 80', category: 'Proteção Solar', skinTag: 'oleosa', store: 'Drogasil', url: 'https://www.drogasil.com.br', price: 94.90, temp: 'Ambiente'),
    ProductModel(id: 's4', name: 'Bioré UV Aqua Rich Watery Essence', category: 'Proteção Solar', skinTag: 'mista', store: 'Drogasil', url: 'https://www.drogasil.com.br', price: 76.90, temp: 'Ambiente'),
    ProductModel(id: 's5', name: 'Fusion Water Oil Control FPS 60', category: 'Proteção Solar', skinTag: 'oleosa', store: 'Época Cosméticos', url: 'https://www.epocacosmeticos.com.br', price: 109.90, temp: 'Ambiente'),
    ProductModel(id: 's6', name: 'Protetor Solar Hidratante FPS 60', category: 'Proteção Solar', skinTag: 'seca', store: 'Beleza na Web', url: 'https://www.belezanaweb.com.br', price: 78.00, temp: 'Ambiente'),
    ProductModel(id: 's7', name: 'Capital Soleil UV-Clear FPS 60', category: 'Proteção Solar', skinTag: 'oleosa', store: 'Drogasil', url: 'https://www.drogasil.com.br', price: 89.90, temp: 'Ambiente'),
    ProductModel(id: 's8', name: 'Protetor Mineral Calmante FPS 50', category: 'Proteção Solar', skinTag: 'seca', store: 'Sephora', url: 'https://www.sephora.com.br', price: 129.00, temp: 'Ambiente'),
    ProductModel(id: 's9', name: 'Fluido Fotoprotetor Invisível FPS 70', category: 'Proteção Solar', skinTag: 'mista', store: 'Amazon Beauty', url: 'https://www.amazon.com.br', price: 72.50, temp: 'Ambiente'),
    ProductModel(id: 's10', name: 'Bastão Solar Transparente FPS 65', category: 'Proteção Solar', skinTag: 'mista', store: 'Sallve', url: 'https://www.sallve.com.br', price: 79.90, temp: 'Ambiente'),
    // Antioxidantes (10)
    ProductModel(id: 'a1', name: 'Vitamina C 10% Sérum Iluminador', category: 'Antioxidantes', skinTag: 'mista', store: 'Creamy', url: 'https://www.creamy.com.br', price: 78.90, temp: '5°C'),
    ProductModel(id: 'a2', name: 'Antioxidante Hidratante Vitamina C', category: 'Antioxidantes', skinTag: 'mista', store: 'Sallve', url: 'https://www.sallve.com.br', price: 69.90, temp: '5°C'),
    ProductModel(id: 'a3', name: 'Sérum Vitamina C 10% + Ferúlico', category: 'Antioxidantes', skinTag: 'oleosa', store: 'Beleza na Web', url: 'https://www.belezanaweb.com.br', price: 59.00, temp: '5°C'),
    ProductModel(id: 'a4', name: 'Pure Vitamin C10 Antioxidante', category: 'Antioxidantes', skinTag: 'seca', store: 'Época Cosméticos', url: 'https://www.epocacosmeticos.com.br', price: 179.90, temp: '5°C'),
    ProductModel(id: 'a5', name: 'Ivy C10 Gel Creme Antioxidante', category: 'Antioxidantes', skinTag: 'oleosa', store: 'Drogasil', url: 'https://www.drogasil.com.br', price: 149.90, temp: '6°C'),
    ProductModel(id: 'a6', name: 'Sérum Niacinamida 10% + Zinco', category: 'Antioxidantes', skinTag: 'oleosa', store: 'Amazon Beauty', url: 'https://www.amazon.com.br', price: 54.00, temp: '6°C'),
    ProductModel(id: 'a7', name: 'Sérum Ácido Mandélico 10%', category: 'Antioxidantes', skinTag: 'oleosa', store: 'Creamy', url: 'https://www.creamy.com.br', price: 68.90, temp: '5°C'),
    ProductModel(id: 'a8', name: 'Roll-on Olhos Cafeína + Peptídeos', category: 'Antioxidantes', skinTag: 'mista', store: 'Sallve', url: 'https://www.sallve.com.br', price: 64.90, temp: '4°C'),
    ProductModel(id: 'a9', name: 'Revitalift Pró-Retinol Sérum', category: 'Antioxidantes', skinTag: 'seca', store: 'Drogasil', url: 'https://www.drogasil.com.br', price: 89.90, temp: '6°C'),
    ProductModel(id: 'a10', name: 'C E Ferulic Sérum Antioxidante', category: 'Antioxidantes', skinTag: 'seca', store: 'Sephora', url: 'https://www.sephora.com.br', price: 389.00, temp: '5°C'),
  ];
}
