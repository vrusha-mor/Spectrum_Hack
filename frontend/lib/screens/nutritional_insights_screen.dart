import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class NutritionalInsightsScreen extends StatelessWidget {
  final Map<String, dynamic> apiResult;

  const NutritionalInsightsScreen({super.key, required this.apiResult});

  @override
  Widget build(BuildContext context) {
    final String foodName = apiResult['food_name'] ?? 'Unknown Meal';
    final String classification = apiResult['classification'] ?? 'Unknown';
    final Map<String, dynamic> nutrition = apiResult['nutrition_per_100g'] ?? {};
    final Map<String, dynamic> ingredients = apiResult['ingredients'] ?? {};
    final List<dynamic> allergies = apiResult['allergies'] ?? [];
    
    final Map<String, dynamic> calRange = nutrition['calories_range_per_100g'] ?? {'min': 0, 'max': 0};
    final double carbs = (nutrition['carbs_g_per_100g'] ?? 0).toDouble();
    final double protein = (nutrition['protein_g_per_100g'] ?? 0).toDouble();
    final double fat = (nutrition['fat_g_per_100g'] ?? 0).toDouble();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Meal Insights', 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildHeader(foodName, classification),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Calorie Estimate (per 100g)'),
            const SizedBox(height: 16),
            _buildCalorieCard(calRange),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Macronutrients Breakdown'),
            const SizedBox(height: 24),
            _buildMacrosChart(carbs, protein, fat),
            
            const SizedBox(height: 40),
            _buildSectionTitle('Ingredients Breakdown'),
            const SizedBox(height: 16),
            _buildIngredientsGrid(ingredients),
            
            if (allergies.isNotEmpty) ...[
              const SizedBox(height: 32),
              _buildSectionTitle('Allergy Warnings'),
              const SizedBox(height: 12),
              _buildAllergyChips(allergies),
            ],
            
            const SizedBox(height: 48),
            _buildDisclaimer(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String classification) {
    bool isVeg = classification.toLowerCase().contains('veg') && !classification.toLowerCase().contains('non');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, 
          style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isVeg ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isVeg ? Colors.green[100]! : Colors.red[100]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isVeg ? Icons.eco_rounded : Icons.restaurant_rounded, 
                size: 14, 
                color: isVeg ? Colors.green[700] : Colors.red[700]
              ),
              const SizedBox(width: 6),
              Text(classification, 
                style: GoogleFonts.outfit(
                  fontSize: 13, 
                  fontWeight: FontWeight.bold, 
                  color: isVeg ? Colors.green[700] : Colors.red[700]
                )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, 
      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  Widget _buildCalorieCard(Map<String, dynamic> range) {
    final min = range['min'] ?? 0;
    final max = range['max'] ?? 0;
    final avg = (min + max) / 2;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange[100]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Average', style: GoogleFonts.outfit(color: Colors.orange[700], fontSize: 13)),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: avg.toStringAsFixed(0), 
                          style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.orange[900])),
                        TextSpan(text: ' kcal', 
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.orange[800])),
                      ],
                    ),
                  ),
                ],
              ),
              const Icon(Icons.flash_on_rounded, color: Colors.orange, size: 40),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(4)),
              ),
              Container(
                height: 8,
                width: 200, // Visual representation
                decoration: BoxDecoration(color: Colors.orange[400], borderRadius: BorderRadius.circular(4)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Min: $min kcal', style: GoogleFonts.outfit(fontSize: 12, color: Colors.orange[700])),
              Text('Max: $max kcal', style: GoogleFonts.outfit(fontSize: 12, color: Colors.orange[700])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacrosChart(double carbs, double protein, double fat) {
    final total = carbs + protein + fat;
    if (total == 0) return const Center(child: Text('No macro data available'));

    return Row(
      children: [
        SizedBox(
          height: 150,
          width: 150,
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(value: carbs, color: Colors.blueAccent, title: '', radius: 25),
                PieChartSectionData(value: protein, color: Colors.greenAccent[700], title: '', radius: 25),
                PieChartSectionData(value: fat, color: Colors.redAccent, title: '', radius: 25),
              ],
            ),
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            children: [
              _buildMacroItem('Carbohydrates', carbs, Colors.blueAccent),
              const SizedBox(height: 12),
              _buildMacroItem('Proteins', protein, Colors.greenAccent[700]!),
              const SizedBox(height: 12),
              _buildMacroItem('Fats', fat, Colors.redAccent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroItem(String label, double value, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[600])),
            Text('${value.toStringAsFixed(1)} g', 
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ],
    );
  }

  Widget _buildIngredientsGrid(Map<String, dynamic> groups) {
    List<Widget> rows = [];
    groups.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(key.replaceAll('_', ' ').toUpperCase(), 
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey[500], letterSpacing: 1.1)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: value.map((ing) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(ing.toString(), style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87)),
                  )).toList(),
                ),
              ],
            ),
          )
        );
      }
    });

    return Column(children: rows);
  }

  Widget _buildAllergyChips(List<dynamic> allergies) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allergies.map((allergy) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[100]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red),
            const SizedBox(width: 8),
            Text(allergy.toString(), 
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red[700])),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Note: Calories and nutritional values are estimated by AI based on visual identification and average recipes. Serving sizes may vary.',
        style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
      ),
    );
  }
}
