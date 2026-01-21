import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PeriodInputSheet extends StatefulWidget {
  final bool isPeriodActive; // true = today marked red, false = today not marked red
  final Function(String type, DateTime date) onSaved; // type: 'start' or 'end'

  const PeriodInputSheet({
    super.key,
    required this.isPeriodActive,
    required this.onSaved,
  });

  @override
  State<PeriodInputSheet> createState() => _PeriodInputSheetState();
}

class _PeriodInputSheetState extends State<PeriodInputSheet> {
  int _selectedDaysAgo = 0; // 0 = today, 1 = yesterday, etc.
  bool _answered = false;

  @override
  Widget build(BuildContext context) {
    final selectedDate = DateTime.now().subtract(Duration(days: _selectedDaysAgo));

    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  widget.isPeriodActive
                      ? 'Has your period stopped?'
                      : 'Did your period start?',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // If already answered, show date selector
                if (_answered)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isPeriodActive ? 'When did it stop?' : 'When did it start?',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDateOptions(),
                      const SizedBox(height: 20),
                      Text(
                        'Selected: ${_formatDate(selectedDate)}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.pink.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                else
                  // Yes/No buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildYesNoButton(
                          'No',
                          false,
                          () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildYesNoButton(
                          'Yes',
                          true,
                          () => setState(() => _answered = true),
                        ),
                      ),
                    ],
                  ),

                if (_answered) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final type = widget.isPeriodActive ? 'end' : 'start';
                        widget.onSaved(type, selectedDate);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Save',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYesNoButton(String label, bool isYes, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isYes ? Colors.pink.shade400 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: !isYes ? Border.all(color: Colors.grey.shade300) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isYes ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateOptions() {
    final options = [0, 1, 2, 3];
    final labels = ['Today', 'Yesterday', '2 days ago', '3+ days ago'];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(options.length, (index) {
        final isSelected = _selectedDaysAgo == options[index];
        return GestureDetector(
          onTap: () => setState(() => _selectedDaysAgo = options[index]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.pink.shade400 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(color: Colors.pink.shade600, width: 2)
                  : null,
            ),
            child: Text(
              labels[index],
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
            ),
          ),
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }
}
