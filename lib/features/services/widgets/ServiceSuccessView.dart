import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../ui/common/ui_helpers.dart';

class SuccessView extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const SuccessView({
    Key? key,
    this.title = 'Success!',
    this.subtitle = 'Operation completed successfully',
    this.icon = Icons.check,
    this.iconColor = Colors.green,
    this.buttonText = 'CONTINUE',
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              
              verticalSpaceLarge,
              
              Text(
                title,
                style: GoogleFonts.redHatDisplay(
                  textStyle: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              
              verticalSpaceSmall,
              
              Text(
                subtitle,
                style: GoogleFonts.redHatDisplay(
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    buttonText,
                    style: GoogleFonts.redHatDisplay(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              
              verticalSpaceMedium,
            ],
          ),
        ),
      ),
    );
  }

  factory SuccessView.serviceScheduled({
    required VoidCallback onButtonPressed,
  }) {
    return SuccessView(
      title: 'Success!',
      subtitle: 'You have successfully scheduled a Service',
      icon: Icons.check,
      iconColor: Colors.green,
      buttonText: 'VIEW SERVICES',
      onButtonPressed: onButtonPressed,
    );
  }

  // Factory constructor for order success
  factory SuccessView.orderPlaced({
    required VoidCallback onButtonPressed,
  }) {
    return SuccessView(
      title: 'Order Placed!',
      subtitle: 'Your order has been placed successfully',
      icon: Icons.shopping_bag,
      iconColor: Colors.blue,
      buttonText: 'VIEW ORDERS',
      onButtonPressed: onButtonPressed,
    );
  }

  // Factory constructor for payment success
  factory SuccessView.paymentCompleted({
    required VoidCallback onButtonPressed,
  }) {
    return SuccessView(
      title: 'Payment Successful!',
      subtitle: 'Your payment has been processed',
      icon: Icons.credit_card,
      iconColor: Colors.green,
      buttonText: 'CONTINUE',
      onButtonPressed: onButtonPressed,
    );
  }

}