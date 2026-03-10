import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 1. Section Header (The Title and Subtitle at the top)
class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const SectionHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.dark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.grey,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// 2. AppInputField (The Styled Text Box)
class AppInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType; // 1. Add this field

  const AppInputField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType, // 2. Add to constructor
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType, // 3. Assign it here
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

/// 3. PrimaryButton (The Main 'Analyze' Button)
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? bgColor; // Added this

  const PrimaryButton(
      {super.key, required this.label, required this.onTap, this.bgColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor ?? AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

/// New AppProgressBar for Credit Score visualization
class AppProgressBar extends StatelessWidget {
  final double value; // Ensure this is double, not num
  final Color color;
  final double height;

  const AppProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}

/// 4. InsightCard (The AI Recommendation Boxes)
class InsightCard extends StatelessWidget {
  final String icon;
  final String text;
  final Color bgColor;
  final Color textColor;

  const InsightCard(
      {super.key,
      required this.icon,
      required this.text,
      required this.bgColor,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 1. The Main Gradient Header Card
class GradientCard extends StatelessWidget {
  final List<Color> colors;
  final double radius;
  final Widget child;
  final EdgeInsets padding;

  const GradientCard({
    super.key,
    required this.colors,
    required this.child,
    this.radius = 24,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 2. Standard White Card for Content
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color; // 1. Add the color field

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color, // 2. Add to constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // 3. Use the passed color, or fall back to white
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 3. Missing StatCard for Income/Expenses
class StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String trend;
  final bool trendUp;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.trend,
    required this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          FittedBox(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800))),
          const SizedBox(height: 4),
          Text(trend,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: trendUp ? Colors.green : Colors.red)),
        ],
      ),
    );
  }
}

/// 4. Tag Badge for Risk Levels
class AppTag extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color bgColor;

  const AppTag(
      {super.key,
      required this.label,
      required this.textColor,
      required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: TextStyle(
              color: textColor, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }
}

/// 5. Feature Buttons for the Grid
class FeatureButton extends StatelessWidget {
  final String icon;
  final String label;
  final Color bgColor;
  final Color accentColor;
  final VoidCallback onTap;

  const FeatureButton({
    super.key,
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: Text(icon, style: const TextStyle(fontSize: 18)),
            ),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accentColor.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}
