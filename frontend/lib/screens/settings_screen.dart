import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spectrum_flutter/screens/profile_screen.dart';
import 'package:spectrum_flutter/services/app_config_server.dart';
import 'package:spectrum_flutter/theme/app_colors.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedGoal = 'Build Muscle';
  double _calorieTarget = 2500;
  double _proteinPercent = 35;
  double _carbsPercent = 38;
  double _fatsPercent = 27;

  bool _isStravaConnected = true;
  bool _autoSync = true;
  bool _isSaving = false;
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

  void _onGoalSelected(String goal) {
    setState(() {
      _selectedGoal = goal;
      if (goal == 'Lose Weight') {
        _calorieTarget = 1800;
        _proteinPercent = 40;
        _carbsPercent = 30;
        _fatsPercent = 30;
      } else if (goal == 'Build Muscle') {
        _calorieTarget = 2800;
        _proteinPercent = 30;
        _carbsPercent = 50;
        _fatsPercent = 20;
      } else if (goal == 'Manage Diabetes') {
        _calorieTarget = 2000;
        _proteinPercent = 25;
        _carbsPercent = 25;
        _fatsPercent = 50;
      } else {
        _calorieTarget = 2200;
        _proteinPercent = 20;
        _carbsPercent = 50;
        _fatsPercent = 30;
      }
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings saved successfully for $_selectedGoal!', style: GoogleFonts.outfit()),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = _appConfig.isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 24),
              Text(_appConfig.translate('settings'), style: GoogleFonts.outfit(color: isDark ? Colors.white : AppColors.black, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // Your Goal Section
              _buildSectionTitle(_appConfig.translate('your_goal'), _appConfig.translate('goal_desc')),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _buildGoalCard(_appConfig.translate('weight_loss'), _appConfig.translate('calorie_deficit'), Icons.scale_outlined),
                  _buildGoalCard(_appConfig.translate('muscle_build'), _appConfig.translate('high_protein'), Icons.fitness_center_outlined),
                  _buildGoalCard(_appConfig.translate('maintain_weight'), _appConfig.translate('balanced_nutrition_lifestyle'), Icons.track_changes_outlined),
                  _buildGoalCard(_appConfig.translate('manage_diabetes'), _appConfig.translate('low_carb_balanced'), Icons.favorite_border_rounded),
                ],
              ),

              const SizedBox(height: 32),

              // Daily Calorie Target
              _buildSectionTitle(_appConfig.translate('daily_target'), null),
              const SizedBox(height: 16),
              _buildCalorieSlider(),

              const SizedBox(height: 32),

              // Macro Distribution
              _buildSectionTitle(_appConfig.translate('macro_distribution'), _appConfig.translate('macro_desc')),
              const SizedBox(height: 16),
              _buildMacroDistribution(),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSaving 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_appConfig.translate('save_goals'), style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 48),

              // Fitness Integration
              Text(_appConfig.translate('fitness_sync'), style: GoogleFonts.outfit(color: isDark ? Colors.white : AppColors.black, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildFitnessIntegration(),

              const SizedBox(height: 32),

              // Today's Activity
              _buildSectionTitle(_appConfig.translate('today_activity'), null),
              const SizedBox(height: 16),
              _buildActivityStats(),

              const SizedBox(height: 32),

              // Recent Workouts
              _buildSectionTitle(_appConfig.translate('recent_workouts'), null),
              const SizedBox(height: 16),
              _buildWorkoutItem(_appConfig.translate('morning_run'), '22 min • 250 kcal', Icons.directions_run_rounded),
              _buildWorkoutItem(_appConfig.translate('strength_training'), '45 min • 180 kcal', Icons.fitness_center_rounded),

              const SizedBox(height: 32),

              // Info Box
              _buildInfoBox(),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final bool isDark = _appConfig.isDarkMode;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_appConfig.translate('app_name'), style: GoogleFonts.outfit(color: AppColors.accent, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(_appConfig.translate('ai_powered_analysis'), style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 13)),
          ],
        ),
        Row(
          children: [
            Stack(
              children: [
                Icon(Icons.notifications_none_outlined, color: isDark ? Colors.white : AppColors.black, size: 28),
                Positioned(right: 4, top: 4, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
              ],
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
              child: Icon(Icons.person_outline_rounded, color: isDark ? Colors.white : AppColors.black, size: 28),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, String? subtitle) {
    final bool isDark = _appConfig.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.outfit(color: isDark ? Colors.white : AppColors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 12)),
        ],
      ],
    );
  }

  Widget _buildGoalCard(String title, String subtitle, IconData icon) {
    final bool isDark = _appConfig.isDarkMode;
    bool isSelected = _selectedGoal == title;
    return GestureDetector(
      onTap: () => _onGoalSelected(title),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.accent : AppColors.lightGrey.withAlpha(isDark ? 20 : 128), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: isDark ? Colors.black26 : AppColors.background, shape: BoxShape.circle),
                  child: Icon(icon, color: AppColors.grey, size: 16),
                ),
                if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 18),
              ],
            ),
            const Spacer(),
            Text(title, style: GoogleFonts.outfit(color: isDark ? Colors.white : AppColors.black, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 9), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieSlider() {
    final bool isDark = _appConfig.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lightGrey.withAlpha(isDark ? 20 : 128)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${_calorieTarget.toInt()}', style: GoogleFonts.outfit(color: AppColors.accent, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text(_appConfig.translate('kcal_per_day'), style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: Colors.orange.withAlpha(77),
              thumbColor: Colors.white,
              overlayColor: AppColors.accent.withAlpha(26),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 4),
            ),
            child: Slider(
              value: _calorieTarget,
              min: 1200,
              max: 4000,
              onChanged: (val) => setState(() => _calorieTarget = val),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1,200', style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 10)),
              Text('4,000', style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroDistribution() {
    final bool isDark = _appConfig.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lightGrey.withAlpha(isDark ? 20 : 128)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(flex: _proteinPercent.toInt(), child: Container(height: 12, color: AppColors.protein)),
                Expanded(flex: _carbsPercent.toInt(), child: Container(height: 12, color: Colors.orange)),
                Expanded(flex: _fatsPercent.toInt(), child: Container(height: 12, color: Colors.pink)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildMacroSlider(_appConfig.translate('protein'), _proteinPercent, AppColors.protein, '219g ${_appConfig.translate('per_day')}', (v) => setState(() => _proteinPercent = v)),
          const SizedBox(height: 20),
          _buildMacroSlider(_appConfig.translate('carbs'), _carbsPercent, Colors.orange, '238g ${_appConfig.translate('per_day')}', (v) => setState(() => _carbsPercent = v)),
          const SizedBox(height: 20),
          _buildMacroSlider(_appConfig.translate('fats'), _fatsPercent, Colors.pink, '75g ${_appConfig.translate('per_day')}', (v) => setState(() => _fatsPercent = v)),
        ],
      ),
    );
  }

  Widget _buildMacroSlider(String label, double val, Color color, String sub, Function(double) onChanged) {
    final bool isDark = _appConfig.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(label, style: GoogleFonts.outfit(color: isDark ? Colors.white : AppColors.black, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            Text('${val.toInt()}%', style: GoogleFonts.outfit(color: isDark ? Colors.white : AppColors.black, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.accent,
            inactiveTrackColor: Colors.orange.withAlpha(51),
            thumbColor: Colors.white,
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(value: val, min: 0, max: 100, onChanged: onChanged),
        ),
        Text(sub, style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildFitnessIntegration() {
    final bool isDark = _appConfig.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accent.withAlpha(isDark ? 51 : 128), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.sync_rounded, color: AppColors.grey, size: 16),
                  const SizedBox(width: 8),
                  Text('Fitness Sync', style: GoogleFonts.outfit(color: isDark ? Colors.white : AppColors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(_appConfig.translate('connected'), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(_appConfig.translate('sync_workouts'), style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 10)),
          const SizedBox(height: 20),
          _buildIntegrationItem('Strava', _isStravaConnected ? 'Last synced: Just now' : _appConfig.translate('not_connected'), _isStravaConnected ? _appConfig.translate('disconnect') : _appConfig.translate('connect'), () {
            setState(() => _isStravaConnected = !_isStravaConnected);
          }),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_appConfig.translate('auto_sync'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.black)),
              Switch(value: _autoSync, onChanged: (v) => setState(() => _autoSync = v), activeColor: AppColors.accent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationItem(String title, String sub, String btnText, VoidCallback onTap) {
    final bool isDark = _appConfig.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: isDark ? Colors.black26 : AppColors.background.withAlpha(128), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          CircleAvatar(radius: 16, backgroundColor: isDark ? Colors.white12 : Colors.white, child: Icon(Icons.directions_run_rounded, size: 16, color: title == 'Strava' ? Colors.orange : AppColors.accent)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : AppColors.black)),
                Text(sub, style: const TextStyle(color: AppColors.grey, fontSize: 10)),
              ],
            ),
          ),
          TextButton(onPressed: onTap, child: Text(btnText, style: TextStyle(color: btnText == 'Disconnect' ? Colors.redAccent.withAlpha(178) : AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildActivityStats() {
    return Row(
      children: [
        Expanded(child: _buildActivityCard('487', _appConfig.translate('burned'), Icons.bolt_rounded, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _buildActivityCard('8,432', _appConfig.translate('steps'), Icons.favorite_rounded, Colors.redAccent)),
        const SizedBox(width: 12),
        Expanded(child: _buildActivityCard('45', _appConfig.translate('active_min'), Icons.timer_rounded, AppColors.accent)),
      ],
    );
  }

  Widget _buildActivityCard(String val, String label, IconData icon, Color color) {
    final bool isDark = _appConfig.isDarkMode;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1F2937) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.lightGrey.withAlpha(isDark ? 20 : 128))),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(val, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : AppColors.black)),
          Text(label, style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildWorkoutItem(String title, String sub, IconData icon) {
    final bool isDark = _appConfig.isDarkMode;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1F2937) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.lightGrey.withAlpha(isDark ? 20 : 128))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.accent.withAlpha(26), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppColors.black)),
                Text(sub, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
              ],
            ),
          ),
          Text(_appConfig.translate('synced'), style: const TextStyle(color: AppColors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    final bool isDark = _appConfig.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.orange.withAlpha(13), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orange.withAlpha(51))),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.withAlpha(26), shape: BoxShape.circle), child: const Icon(Icons.bolt_rounded, color: Colors.orange, size: 16)),
          const SizedBox(width: 16),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.outfit(color: isDark ? Colors.white70 : AppColors.grey, fontSize: 11, height: 1.4),
                children: [
                  TextSpan(text: '${_appConfig.translate('calorie_budget_adjusted')}\n', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  TextSpan(text: _appConfig.translate('based_on_burned')),
                  const TextSpan(text: '341 kcal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  TextSpan(text: ' ${_appConfig.translate('meet_goals')}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
