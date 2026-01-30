import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_colors.dart';

class ProcessStep {
  final IconData icon;
  final String label;

  const ProcessStep({
    required this.icon,
    required this.label,
  });
}

const List<ProcessStep> defaultStep = [
  ProcessStep(icon: Icons.event_available, label: "Đặt lịch"),
  ProcessStep(icon: Icons.verified, label: "Xác nhận"),
  ProcessStep(icon: Icons.engineering, label: "Thợ đến làm"),
  ProcessStep(icon: Icons.task_alt, label: "Nghiệm thu"),
];

class ProcessStepsSection extends StatelessWidget {
  final List<ProcessStep>? steps;
  const ProcessStepsSection({super.key, this.steps});
  List<ProcessStep> get _steps => steps ?? defaultStep;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStepsRow()
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.route,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        const Text(
          "Quy trình làm việc",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepsRow() {
    return LayoutBuilder(builder: (context, constrains) {
      final stepWidth = constrains.maxWidth / _steps.length;
      final iconSize = 40;
      return Stack(
        children: [
          Positioned(
            top: iconSize / 2,
            left: stepWidth / 2,
            right: stepWidth / 2,
            child: Container(
              height: 1,
              color: AppColors.primary.withOpacity(0.3),
            ),
          ),
          Row(
            children: List.generate(_steps.length, (index) {
              return Expanded(
                child: _StepItem(
                  step: _steps[index],
                  stepNumber: index + 1,
                ),
              );
            }),
          ),
        ],
      );
    });
  }
}

class _StepItem extends StatelessWidget {
  final ProcessStep step;
  final int stepNumber;
  const _StepItem({
    required this.step,
    required this.stepNumber,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 2,
              )),
          child: Icon(
            step.icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Bước $stepNumber",
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          step.label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
