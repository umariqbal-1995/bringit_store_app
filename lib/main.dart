import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAQY1SQeZwn5Z5EPgryh4j_M_SKadyoRBo',
      appId: '1:760074919513:ios:97ce25cb9e800d450cdb48',
      messagingSenderId: '760074919513',
      projectId: 'bringit-5fc69',
      storageBucket: 'bringit-5fc69.firebasestorage.app',
      iosBundleId: 'com.bringit.bringitStoreApp',
    ),
  );
  await NotificationService().initialize();
  runApp(const BringItStoreApp());
}

class BringItStoreApp extends StatelessWidget {
  const BringItStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BringIt Store',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
    );
  }
}
