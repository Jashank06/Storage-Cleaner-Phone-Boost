import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/app_theme.dart';
import '../models/storage_breakdown.dart';
import '../core/utils/format_utils.dart';

/// Storage breakdown donut chart with 3D glass segments
class StorageBreakdownChart extends StatefulWidget {
  final StorageBreakdown breakdown;
  final double size;
  
  const StorageBreakdownChart({
    super.key,
    required this.breakdown,
    this.size = 200,
  });
  
  @override
  State<StorageBreakdownChart> createState() => _StorageBreakdownChartState();
}

class _StorageBreakdownChartState extends State<StorageBreakdownChart> {
  int touchedIndex = -1;
  
  // Centralized category definitions for consistency
  List<_CategoryData> _getCategories() {
    return [
      _CategoryData(
        'Apps',
        const LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF2979FF)], 
          begin: Alignment.topLeft, end: Alignment.bottomRight
        ),
        widget.breakdown.appsBytes
      ),      
      _CategoryData(
        'Photos', 
        const LinearGradient(
          colors: [Color(0xFFD500F9), Color(0xFF651FFF)], 
          begin: Alignment.topLeft, end: Alignment.bottomRight
        ),
        widget.breakdown.photosBytes
      ),  
      _CategoryData(
        'Videos', 
        const LinearGradient(
          colors: [Color(0xFFFFD600), Color(0xFFFF6D00)], 
          begin: Alignment.topLeft, end: Alignment.bottomRight
        ),
        widget.breakdown.videosBytes
      ), 
      _CategoryData(
        'WhatsApp', 
        const LinearGradient(
          colors: [Color(0xFF00E676), Color(0xFF00C853)], 
          begin: Alignment.topLeft, end: Alignment.bottomRight
        ),
        widget.breakdown.whatsappBytes
      ), 
      _CategoryData(
        'Docs', 
        const LinearGradient(
          colors: [Color(0xFF00BFA5), Color(0xFF00897B)], 
          begin: Alignment.topLeft, end: Alignment.bottomRight
        ),
        widget.breakdown.documentsBytes
      ), 
      _CategoryData(
        'Other', 
        const LinearGradient(
          colors: [Color(0xFFFF4081), Color(0xFFC51162)], 
          begin: Alignment.topLeft, end: Alignment.bottomRight
        ),
        widget.breakdown.otherBytes
      ),     
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: widget.size,
            width: widget.size,
            child: PieChart(
              PieChartData(
                sections: _getSections(),
                sectionsSpace: 4,
                centerSpaceRadius: widget.size * 0.3,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildLegend(),
      ],
    );
  }
  
  List<PieChartSectionData> _getSections() {
    final categories = _getCategories();
    final sectionRadius = widget.size * 0.35;
    
    return List.generate(categories.length, (i) {
      final isTouch = i == touchedIndex;
      final fontSize = isTouch ? 16.0 : 13.0;
      final radius = isTouch ? sectionRadius + 8 : sectionRadius;
      final category = categories[i];
      
      if (category.bytes == 0) {
        return PieChartSectionData(
          color: Colors.transparent,
          value: 0,
          title: '',
          radius: 0,
        );
      }
      
      final percentage = widget.breakdown.totalBytes > 0
          ? (category.bytes / widget.breakdown.totalBytes) * 100
          : 0.0;
      
      return PieChartSectionData(
        gradient: category.gradient,
        value: category.bytes.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 4,
            ),
          ],
        ),
        badgeWidget: isTouch ? _buildBadge(category.gradient) : null,
        badgePositionPercentageOffset: 1.1,
      );
    });
  }

  Widget _buildBadge(Gradient gradient) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: gradient.colors.first, width: 2),
        boxShadow: [
          BoxShadow(color: gradient.colors.first.withOpacity(0.5), blurRadius: 4),
        ],
      ),
    );
  }
  
  Widget _buildLegend() {
    final categories = _getCategories();
    
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: categories.map((cat) {
        if (cat.bytes == 0) return const SizedBox.shrink();
        final isSelected = categories.indexOf(cat) == touchedIndex;
        
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: touchedIndex == -1 || isSelected ? 1 : 0.5,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  gradient: cat.gradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: cat.gradient.colors.first.withOpacity(0.4), blurRadius: 4),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${cat.name}: ${FormatUtils.formatBytes(cat.bytes)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(isSelected ? 1 : 0.7),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CategoryData {
  final String name;
  final Gradient gradient;
  final int bytes;
  
  _CategoryData(this.name, this.gradient, this.bytes);
}
