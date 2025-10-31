import 'package:easy_ph/app/app.logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/app.locator.dart';
import '../../../core/data/repositories/repository.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../core/data/models/referral_item.dart';
import '../../../core/utils/string_util.dart';

class ReferralsViewModel extends BaseViewModel {
  final _repo = locator<Repository>();
  final _log = getLogger("ReferralsViewModel");
  final _snackBar = locator<SnackbarService>();
  final _localStorage = locator<LocalStorage>();
  final _navigationService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _dialogService = locator<DialogService>();

  int totalReferrals = 0;
  int activeReferrals = 0;
  int bonusEarned = 0;
  
  String referralLink = 'https://www.easyopenhub.com/referral/1';
  String minPurchaseAmount = '₦50,000';

  String? referralId;
  String? referralCode;

  List<ReferralItem> referrals = [];

  int currentPage = 1;
  int totalPages = 1;
  bool hasMoreData = false;

  void initialize() async {
    await fetchReferralCode();
    await fetchReferralUsers();
    
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
    if (referralCode == null || referralCode!.isEmpty) {
      _snackBar.showSnackbar(
        message: 'Referral code not available',
      );
      return;
    }
    
    Share.share(
      'Join me on EasyOpenHub and get amazing products! 🎁\n\n'
      'Use my referral code: $referralCode\n'
      'Or click this link: $referralLink\n\n'
      'Sign up now and enjoy exclusive deals!',
      subject: 'Join EasyOpenHub with my referral code',
    );
  }

  Future<void> fetchReferralUsers({int page = 1, int limit = 10, String? status}) async {
    if (page == 1) {
      setBusy(true);
    }
    notifyListeners();

    try {
      final response = await _repo.getReferralUsers(
        page: page,
        limit: limit,
        status: status,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final pagination = response.data['pagination'];
        
        if (page == 1) {
          referrals = data.map((item) => ReferralItem.fromJson(item)).toList();
        } else {
          referrals.addAll(data.map((item) => ReferralItem.fromJson(item)).toList());
        }
        
        totalPages = pagination['totalPages'] ?? 1;
        currentPage = pagination['currentPage'] ?? 1;
        hasMoreData = currentPage < totalPages;
        
        totalReferrals = pagination['total'] ?? 0;
        activeReferrals = referrals.where((r) => 
          r.bonusStatus.toLowerCase() == 'in progress' || 
          r.bonusStatus.toLowerCase() == 'pending'
        ).length;
        
        bonusEarned = referrals.where((r) => 
          r.bonusStatus.toLowerCase() == 'completed'
        ).length;
        
        _log.i('Fetched ${referrals.length} referrals');
      } else {
        _snackBar.showSnackbar(
          message: response.data['message'] ?? 'Failed to fetch referrals',
        );
      }
    } catch (e) {
      _log.e('Error fetching referral users: $e');
      _snackBar.showSnackbar(
        message: 'Failed to load referrals',
      );
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> fetchReferralCode() async {
    setBusy(true);
    notifyListeners();
    
    try {
      final response = await _repo.getReferralCode();
      
      if (response.statusCode == 200) {
        referralId = response.data['data']['id'];
        referralCode = response.data['data']['referralCode'];
        
        referralLink = '$referralCode';
        
        _log.i('Referral code fetched: $referralCode');
      } else {
        _snackBar.showSnackbar(
          message: response.data['message'] ?? 'Failed to fetch referral code',
        );
      }
    } catch (e) {
      _log.e('Error fetching referral code: $e');
      _snackBar.showSnackbar(
        message: 'Failed to load referral code',
      );
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

}