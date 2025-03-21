import 'package:easyph/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

class EmptyTabContent extends StatelessWidget {

  final String title;
  final String description;
  final List<String> rules;

  const EmptyTabContent({
    Key? key,

    required this.title,
    required this.description,
    required this.rules,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20), // Adjust padding as needed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          verticalSpaceMedium,
          const Image(image: AssetImage('assets/images/ticket_tag.png')),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rules',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Panchang"),
                  ),
                  ...rules.map(
                        (rule) => Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(rule, style: const TextStyle(fontSize: 10),),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
