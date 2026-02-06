import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:spectrum_flutter/screens/profile_screen.dart';
import 'package:spectrum_flutter/services/app_config_server.dart';
import 'package:spectrum_flutter/theme/app_colors.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _hoveredDay = 2; // Default to Mon (0=Sat, 1=Sun, 2=Mon...)
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // NutriScan Header (Image 1)
              _buildHeader(),
              const SizedBox(height: 24),
              Text(AppConfigServer().translate('stats'), style: GoogleFonts.outfit(color: AppColors.black, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // Summary Cards (Consumed, Burned, Balance)
              Row(
                children: [
                  Expanded(child: _buildSummaryCard('1242', AppConfigServer().translate('consumed'), Icons.local_fire_department_rounded, Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSummaryCard('440', AppConfigServer().translate('burned'), Icons.bolt_rounded, AppColors.accent)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSummaryCard('+802', AppConfigServer().translate('balance'), Icons.track_changes_rounded, Colors.redAccent, isPositive: true)),
                ],
              ),

              const SizedBox(height: 24),

              // Today's Macros (Image 1)
              _buildMacrosCard(),

              const SizedBox(height: 24),

              // Weekly Calories (Image 2)
              _buildWeeklyChart(),

              const SizedBox(height: 24),

              // Weekly Insights (Image 3)
              _buildWeeklyInsights(),

              const SizedBox(height: 100),
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
            Text(AppConfigServer().translate('app_name'), 
              style: GoogleFonts.outfit(color: AppColors.accent, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(AppConfigServer().translate('ai_powered_analysis'), 
              style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 13),
            ),
          ],
        ),
        Row(
          children: [
            Icon(Icons.notifications_none_outlined, color: isDark ? Colors.white : AppColors.black),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
              child: Icon(Icons.person_outline_rounded, color: isDark ? Colors.white : AppColors.black),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String value, String label, IconData icon, Color iconColor, {bool isPositive = false}) {
    final bool isDark = _appConfig.isDarkMode;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightGrey.withAlpha(isDark ? 20 : 128)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.outfit(
            color: isPositive ? Colors.redAccent : (isDark ? Colors.white : AppColors.black), 
            fontSize: 20, 
            fontWeight: FontWeight.bold
          )),
          Text(label, style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMacrosCard() {
    final bool isDark = _appConfig.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lightGrey.withAlpha(isDark ? 20 : 128)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppConfigServer().translate('todays_macros'), style: GoogleFonts.outfit(color: isDark ? Colors.white : AppColors.black, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('62% ${AppConfigServer().translate('percentage_of_goal')}', style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              SizedBox(
                height: 120, width: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(color: AppColors.protein, value: 30, radius: 20, showTitle: false),
                      PieChartSectionData(color: Colors.orange, value: 45, radius: 20, showTitle: false),
                      PieChartSectionData(color: Colors.pink, value: 25, radius: 20, showTitle: false),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _buildMacroRow(AppConfigServer().translate('protein'), '99g / 150g', AppColors.protein),
                    const SizedBox(height: 12),
                    _buildMacroRow(AppConfigServer().translate('carbs'), '149g / 225g', Colors.orange),
                    const SizedBox(height: 12),
                    _buildMacroRow(AppConfigServer().translate('fats'), '50g / 56g', Colors.pink),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String label, String value, Color color) {
    final bool isDark = _appConfig.isDarkMode;
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(label, style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 12), overflow: TextOverflow.ellipsis)),
              Text(value, style: GoogleFonts.outfit(color: isDark ? Colors.white : AppColors.black, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart() {
    final days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final values = [1600.0, 1200.0, 1715.0, 1500.0, 1800.0, 1950.0, 1400.0];

    final bool isDark = _appConfig.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lightGrey.withAlpha(isDark ? 20 : 128)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppConfigServer().translate('weekly_calories'), style: GoogleFonts.outfit(color: isDark ? Colors.white : AppColors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                // Target Line
                Positioned(
                  top: 20, left: 0, right: 0,
                  child: SizedBox(
                    height: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(50, (i) => Expanded(child: Container(color: i % 2 == 0 ? AppColors.accent.withValues(alpha: 0.2) : Colors.transparent, height: 1))),
                    ),
                  ),
                ),
                BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceEvenly,
                    maxY: 2500,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchCallback: (event, response) {
                        if (response != null && response.spot != null) {
                          setState(() => _hoveredDay = response.spot!.touchedBarGroupIndex);
                        }
                      },
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => Colors.white,
                        tooltipBorder: const BorderSide(color: AppColors.lightGrey),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${days[groupIndex]}\n',
                            GoogleFonts.outfit(color: AppColors.grey, fontSize: 12),
                            children: [
                              TextSpan(
                                text: 'Calories : ${rod.toY.toInt()} kcal',
                                style: GoogleFonts.outfit(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(days[value.toInt()], style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 11)),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(7, (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: values[i],
                          color: AppColors.accent,
                          width: 28, // Reduced width for better spacing
                          borderRadius: BorderRadius.circular(8),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: i == _hoveredDay,
                            toY: 2500,
                            color: AppColors.lightGrey.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    )),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendNode(AppColors.accent, AppConfigServer().translate('daily_intake')),
              const SizedBox(width: 24),
              _buildLegendNode(AppColors.accent.withValues(alpha: 0.5), AppConfigServer().translate('target'), isDashed: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendNode(Color color, String label, {bool isDashed = false}) {
    return Row(
      children: [
        Container(
          width: 12, height: isDashed ? 2 : 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.outfit(color: AppColors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildWeeklyInsights() {
    final daysFull = ['Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    final values = [1600, 1200, 1715, 1500, 1800, 1950, 1400];
    
    // Day specific analysis
    String getDayAnalysis() {
      int val = values[_hoveredDay];
      if (val > 1800) return AppConfigServer().translate('high_intake_analysis');
      if (val < 1300) return AppConfigServer().translate('light_day_analysis');
      return AppConfigServer().translate('balanced_day_analysis');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppConfigServer().translate('weekly_insights'), style: GoogleFonts.outfit(color: AppColors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        
        // Dynamic Point 1: Day Name & Calories (Green/Emerald)
        _buildInsightCard(
          '${daysFull[_hoveredDay]} ${AppConfigServer().translate('analysis_suffix')}', 
          'Total of ${values[_hoveredDay]} ${AppConfigServer().translate('kcal_unit')} ${AppConfigServer().translate('consumed').toLowerCase()}. ${getDayAnalysis()}', 
          AppColors.accent, 
          Icons.calendar_today_rounded
        ),

        // Dynamic Point 2: Trend (Yellow/Orange)
        _buildInsightCard(
          _hoveredDay >= 5 ? AppConfigServer().translate('weekend_caution') : AppConfigServer().translate('weekday_progress'), 
          _hoveredDay >= 5 
            ? AppConfigServer().translate('weekend_tip') 
            : AppConfigServer().translate('consistent_routine'),
          Colors.orange, 
          _hoveredDay >= 5 ? Icons.warning_amber_rounded : Icons.check_circle_outline
        ),

        // Dynamic Point 3: Macro Focus
        _buildInsightCard(
          AppConfigServer().translate('macro_balance'), 
          AppConfigServer().translate('protein_optimal'), 
          AppColors.accent, 
          Icons.fitness_center_rounded
        ),

        // Dynamic Point 4: Suggestion
        _buildInsightCard(
          AppConfigServer().translate('aura_point_tip'), 
          _hoveredDay == 5 ? AppConfigServer().translate('cheat_meal_tip') : AppConfigServer().translate('early_dinner_tip'), 
          Colors.orange, 
          Icons.lightbulb_outline_rounded
        ),
      ],
    );
  }

  Widget _buildInsightCard(String title, String sub, Color color, IconData icon) {
    final bool isDark = _appConfig.isDarkMode;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(26)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withAlpha(26), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(color: isDark ? Colors.white : AppColors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(sub, style: GoogleFonts.outfit(color: isDark ? Colors.white70 : AppColors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
