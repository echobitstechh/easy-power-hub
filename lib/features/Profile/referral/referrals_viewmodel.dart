import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
// import 'package:share_plus/share_plus.dart';

class ReferralItem {
  final String name;
  final String dateJoined;
  final String reward;
  final String status;

  ReferralItem({
    required this.name,
    required this.dateJoined,
    required this.reward,
    required this.status,
  });
}

class ReferralsViewModel extends BaseViewModel {
  int totalReferrals = 0;
  int activeReferrals = 0;
  int bonusEarned = 0;
  
  String referralLink = 'https://www.easyopenhub.com/referral/1';
  String minPurchaseAmount = '₦50,000';

  List<ReferralItem> referrals = [
    ReferralItem(
      name: 'Usman Gibran',
      dateJoined: 'Oct 2...',
      reward: '₦500',
      status: 'Paid',
    ),
    ReferralItem(
      name: 'Maxy Obi',
      dateJoined: 'Oct 10...',
      reward: '₦1,000',
      status: 'Pending',
    ),
    ReferralItem(
      name: 'David John',
      dateJoined: 'Oct 15...',
      reward: '₦2,000',
      status: 'Paid',
    ),
  ];

  // Initialize - This is where you'll fetch data from API later
  void initialize() {
    // TODO: Fetch referral stats from API
    // TODO: Fetch referral timeline from API
    
    // Mock data for now
    totalReferrals = referrals.length;
    activeReferrals = referrals.where((r) => r.status.toLowerCase() == 'pending').length;
    bonusEarned = 0;
    
    notifyListeners();
  }

  void copyReferralLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: referralLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral link copied to clipboard!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void shareReferralLink() {
    // Share.share(
    //   'Join me on EasyOpenHub and get amazing products! Use my referral link: $referralLink',
    //   subject: 'Join EasyOpenHub',
    // );
  }

  Future<void> fetchReferrals() async {
    setBusy(true);
    
    try {
      // TODO: Replace with actual API call
      // final response = await _apiService.getReferrals();
      // referrals = response.data;
      // totalReferrals = response.totalReferrals;
      // activeReferrals = response.activeReferrals;
      // bonusEarned = response.bonusEarned;
      
      await Future.delayed(const Duration(seconds: 1)); // Mock delay
      
      notifyListeners();
    } catch (e) {
      // Handle error
      debugPrint('Error fetching referrals: $e');
    } finally {
      setBusy(false);
    }
  }
}