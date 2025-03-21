import 'package:easyph/ui/common/app_colors.dart';
import 'package:flutter/material.dart';

import '../app/app.locator.dart';
import '../core/utils/local_store_dir.dart';
import '../core/utils/local_stotage.dart';

class AdventureModal extends StatelessWidget {
  const AdventureModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Red box
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            const Text(
              "Welcome to Your Adventure!",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: kcSecondaryColor,
              ),
            ),
            const SizedBox(height: 10),
            // Description
            const Text(
              "Congratulations, adventurer! You’re about to dive into a world of thrilling draws, exciting prizes, and rewarding points.\n\n"
                  "With each ticket you buy, you not only have a chance to win but also earn points to support noble causes or treat yourself in our store.",
              style: TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            // Buttons (Skip and Next)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    print('skip card');
                    Navigator.of(context).pop(); // Close the modal

                    // Update onboarded status after showing the modal
                    locator<LocalStorage>().save(LocalStorageDir.onboarded, true);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.black26),
                    ),
                  ),
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    print('next button');
                    Navigator.of(context).pop();

                    // Update onboarded status after showing the modal
                    locator<LocalStorage>().save(LocalStorageDir.onboarded, true);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    backgroundColor: kcSecondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Next", style: TextStyle(color: kcBlackColor),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
