import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/glowup_provider.dart';
import '../widgets/brand_logo.dart';
import '../widgets/cart_bottom_sheet.dart';
import 'home_screen.dart';
import 'fridge_screen.dart';
import 'lessons_screen.dart';
import 'shop_screen.dart';
import 'profile_screen.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GlowUpProvider>();
    final c = provider.colors;

    const screens = [
      HomeScreen(),
      FridgeScreen(),
      LessonsScreen(),
      ShopScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        titleSpacing: 18,
        title: Row(
          children: [
            const BrandLogo(size: 34),
            const SizedBox(width: 8),
            Text(
              'Glow',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: c.text),
            ),
            Text(
              'Up',
              style: GoogleFonts.cormorantGaramond(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                fontSize: 24,
                color: c.primary,
              ),
            ),
          ],
        ),
        actions: [
          InkWell(
            onTap: provider.toggleLanguage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.border),
              ),
              child: Text(
                provider.lang == 'pt' ? 'PT/EN' : 'EN/PT',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: c.primary),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Stack(
            children: [
              IconButton(
                onPressed: () => CartBottomSheet.show(context),
                icon: Icon(Icons.shopping_bag_outlined, color: c.text),
              ),
              if (provider.cart.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: c.primary,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${provider.cart.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: provider.activeTabIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(top: BorderSide(color: c.border)),
        ),
        child: NavigationBar(
          height: 66,
          backgroundColor: c.surface,
          indicatorColor: c.primarySoft,
          selectedIndex: provider.activeTabIndex,
          onDestinationSelected: provider.setTab,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: c.textSub),
              selectedIcon: Icon(Icons.home_rounded, color: c.primary),
              label: provider.lang == 'pt' ? 'Início' : 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.ac_unit_rounded, color: c.textSub),
              selectedIcon: Icon(Icons.ac_unit_rounded, color: c.primary),
              label: 'GlowFridge',
            ),
            NavigationDestination(
              icon: Icon(Icons.play_circle_outline_rounded, color: c.textSub),
              selectedIcon: Icon(Icons.play_circle_filled_rounded, color: c.primary),
              label: provider.lang == 'pt' ? 'Aulas' : 'Lessons',
            ),
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined, color: c.textSub),
              selectedIcon: Icon(Icons.storefront_rounded, color: c.primary),
              label: provider.lang == 'pt' ? 'Loja' : 'Shop',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: c.textSub),
              selectedIcon: Icon(Icons.person_rounded, color: c.primary),
              label: provider.lang == 'pt' ? 'Perfil' : 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
