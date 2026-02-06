import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spectrum_flutter/screens/meal_scan_screen.dart';
import 'package:spectrum_flutter/theme/app_colors.dart';
import 'package:spectrum_flutter/screens/analytics_screen.dart';
import 'package:spectrum_flutter/screens/profile_screen.dart';
import 'package:spectrum_flutter/screens/settings_screen.dart';
import 'package:spectrum_flutter/services/app_config_server.dart';
import 'package:spectrum_flutter/screens/barcode_scan_screen.dart';


class FitnessSyncDashboard extends StatefulWidget {
  const FitnessSyncDashboard({super.key});

  @override
  State<FitnessSyncDashboard> createState() => _FitnessSyncDashboardState();
}

class _FitnessSyncDashboardState extends State<FitnessSyncDashboard> {
  int _selectedIndex = 0;
  final _appConfig = AppConfigServer();

  @override
  void initState() {
    super.initState();
    _appConfig.addListener(_update);
  }

  @override
  void dispose() {
    _appConfig.removeListener(_update);
    super.dispose();
  }

  void _update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final bool isDark = _appConfig.isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeDashboard(context),
          const BarcodeScanScreen(),
          const AnalyticsScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final bool isDark = _appConfig.isDarkMode;
    return SizedBox(
      height: 110, // Increased height to prevent FAB clipping
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none, // Allow FAB to overflow
        children: [
          Container(
            height: 80,
            margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.lightGrey.withAlpha(isDark ? 20 : 128)),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 0 : 5), blurRadius: 20)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_outlined, AppConfigServer().translate('home'), 0),
                _buildNavItem(Icons.qr_code_scanner_rounded, _appConfig.translate('stats') == "आँकड़े" ? "बारकोड" : "Barcode", 1),
                const SizedBox(width: 60), // Space for FAB
                _buildNavItem(Icons.bar_chart_rounded, AppConfigServer().translate('stats'), 2),
                _buildNavItem(Icons.settings_outlined, AppConfigServer().translate('settings'), 3),
              ],
            ),
          ),
          Positioned(
            bottom: 25, // Centered properly relative to the white bar
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MealScanScreen())),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Color(0x661DB98D), blurRadius: 15, offset: Offset(0, 5))],
                ),
                child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.transparent, // Better tap target
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? AppColors.accent : AppColors.grey, size: 24),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.outfit(color: isActive ? AppColors.accent : AppColors.grey, fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final bool isDark = _appConfig.isDarkMode;
    final user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? 'User';
    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, $displayName', 
                style: GoogleFonts.outfit(color: AppColors.accent, fontSize: 24, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              Text(AppConfigServer().translate('ai_powered_analysis'), 
                style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Icon(Icons.notifications_none_outlined, color: isDark ? Colors.white : AppColors.black),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.accent,
                backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                child: user?.photoURL == null 
                  ? Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                  : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyTip(bool isDark) {
    int tipIndex = (DateTime.now().day % 3) + 1;
    String tipKey = 'tip_$tipIndex';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_appConfig.translate('daily_tip'), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.accent, fontSize: 12)),
                const SizedBox(height: 4),
                Text(_appConfig.translate(tipKey), style: GoogleFonts.outfit(color: isDark ? Colors.white : AppColors.black, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeDashboard(BuildContext context) {
    final bool isDark = _appConfig.isDarkMode;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildDailyTip(isDark),

            const SizedBox(height: 24),

            // Today's Progress Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.lightGrey.withAlpha(isDark ? 20 : 128)),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 0 : 8), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_appConfig.translate('progress_title'), style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: '1261', style: GoogleFonts.outfit(color: isDark ? Colors.white : AppColors.black, fontSize: 32, fontWeight: FontWeight.bold)),
                            TextSpan(text: ' / 2000 kcal', style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 18)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.accent.withAlpha(26), shape: BoxShape.circle),
                        child: const Icon(Icons.track_changes_rounded, color: AppColors.accent, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Row(
                      children: [
                        Expanded(flex: 1261, child: Container(height: 10, color: AppColors.accent)),
                        Expanded(flex: 739, child: Container(height: 10, color: isDark ? Colors.white10 : AppColors.remainingColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('739 ${_appConfig.translate('kcal_remaining')}', style: GoogleFonts.outfit(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('2 ${_appConfig.translate('meals_logged')}', style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Scan Your Meal Action
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MealScanScreen())),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightGrey.withAlpha(isDark ? 20 : 128)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(_appConfig.translate('scan_meal'), style: GoogleFonts.outfit(color: isDark ? Colors.white : AppColors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.orange.withAlpha(26), borderRadius: BorderRadius.circular(4)),
                                child: const Text('✨ AI', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          Text(_appConfig.translate('scan_desc'), style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BarcodeScanScreen())),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightGrey.withAlpha(isDark ? 20 : 128)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Scan Barcode', style: GoogleFonts.outfit(color: isDark ? Colors.white : AppColors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Get instant facts from product barcodes', style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Today's Meals Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_appConfig.translate('todays_meals'), style: GoogleFonts.outfit(color: isDark ? Colors.white : AppColors.black, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildMealListItem(context, _appConfig.translate('breakfast'), '8:09 AM', '685 kcal', 0.6, Icons.wb_sunny_rounded, Colors.orange),
            _buildMealListItem(context, _appConfig.translate('lunch'), '1:41 PM', '576 kcal', 0.45, Icons.cloud_outlined, AppColors.accent),
            _buildMealListItem(context, _appConfig.translate('dinner'), '7:30 PM', '420 kcal', 0.3, Icons.nightlight_round, Colors.indigo),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMealListItem(BuildContext context, String title, String time, String kcal, double progress, IconData icon, Color iconColor) {
    final bool isDark = _appConfig.isDarkMode;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightGrey.withAlpha(isDark ? 20 : 128)),
      ),
      child: Column(
        children: [
          Row(
            children: [
               CircleAvatar(radius: 20, backgroundColor: AppColors.background, child: Icon(icon, color: iconColor, size: 20)),
               const SizedBox(width: 16),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Row(
                        children: [
                          Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : AppColors.black)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.orange.withAlpha(26), borderRadius: BorderRadius.circular(4)),
                            child: Text(_appConfig.translate('moderate'), style: const TextStyle(color: Colors.orange, fontSize: 10)),
                          ),
                        ],
                      ),
                      Text('$time  •  $kcal', style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 12)),
                   ],
                 ),
               ),
               const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.lightGrey,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}
