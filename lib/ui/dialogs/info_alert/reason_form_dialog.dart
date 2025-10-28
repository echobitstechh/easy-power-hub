import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:google_fonts/google_fonts.dart';

class ReasonFormDialog extends StatefulWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const ReasonFormDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  State<ReasonFormDialog> createState() => _ReasonFormDialogState();
}

class _ReasonFormDialogState extends State<ReasonFormDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.request.title ?? "Enter Reason",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                // fillColor: Colors.grey[600],
                // filled: true,
                hintText: widget.request.description ?? "Write your reason here...",
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => widget.completer(
                    DialogResponse(confirmed: false),
                  ),
                  child: Text(
                    widget.request.secondaryButtonTitle ?? 'Cancel',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final text = _reasonController.text.trim();
                    if (text.isEmpty) return;
                    widget.completer(
                      DialogResponse(
                        confirmed: true,
                        data: text,
                      ),
                    );
                  },
                  child: Text(widget.request.mainButtonTitle ?? 'Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
