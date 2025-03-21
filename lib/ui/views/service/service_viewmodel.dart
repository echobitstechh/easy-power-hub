import 'package:easyph/app/app.locator.dart';
import 'package:easyph/app/app.logger.dart';
import 'package:easyph/core/data/repositories/repository.dart';
import 'package:easyph/core/network/api_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';

import '../../../core/data/models/app_notification.dart';
import '../../../core/data/models/category.dart';
import '../../../core/data/models/project.dart';
import '../../../core/data/models/service.dart';
import '../../../core/utils/local_store_dir.dart';
import '../../../core/utils/local_stotage.dart';
import '../../../state.dart';

class ServicesviewModel extends BaseViewModel {
  final repo = locator<Repository>();
  final log = getLogger("ServicesviewModel");
  String loadingId = "";

  final dateController = TextEditingController();
  final timeController = TextEditingController();

  String searchQuery = '';
  List<Service> services = [];
  List<Service> filteredServices = [];

  Future<void> init() async {
    setBusy(true);
    // await loadDonationCategories();
    await getServices();
    setBusy(false);
    notifyListeners();
  }

  Future<void> getServices() async {
    setBusy(true);
    notifyListeners();

    try {
      ApiResponse res = await repo.getServices();
      if (res.statusCode == 200 && res.data != null) {
        List<dynamic> servicesData = res.data['services'];
        services = servicesData.map((data) => Service.fromJson(data)).toList();
        filteredServices = services;
      } else {
        debugPrint('Unexpected API response: ${res.data}');
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }


  void updateSearchQuery(String query) {
    if (query.isEmpty) {
      filteredServices = services;
    } else {
      filteredServices = services.where((service) {
        final name = service.name.toLowerCase();
        final category = service.category.toLowerCase();
        final searchQuery = query.toLowerCase();
        return name.contains(searchQuery) || category.contains(searchQuery);
      }).toList();
    }
    notifyListeners();
  }

}
