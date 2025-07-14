import 'package:workmanager/workmanager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'features/documents/services/sync_service.dart';

const String syncTask = "syncTask";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // No connection, fail silently
      return Future.value(true);
    }

    // Call your sync service
    try {
      await SyncService().fetchAndStoreAll();
    } catch (e) {
      // Fail silently
    }
    return Future.value(true);
  });
} 