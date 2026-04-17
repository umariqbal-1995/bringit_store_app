import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/storage/storage_service.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final phone = ''.obs;

  Future<void> sendOtp(String phoneNumber) async {
    isLoading.value = true;
    try {
      await DioClient.instance.post('/store/auth/send-otp', data: {
        'phone': phoneNumber,
      });
      phone.value = phoneNumber;
      Get.toNamed(AppRoutes.verifyOtp);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send OTP. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String otp) async {
    isLoading.value = true;
    try {
      final response = await DioClient.instance.post('/store/auth/verify-otp', data: {
        'phone': phone.value,
        'otp': otp,
      });
      final token = response.data['token'] ?? response.data['data']?['token'];
      final storeId = response.data['store']?['id'] ?? response.data['data']?['store']?['id'];
      if (token != null) {
        StorageService.setToken(token);
        if (storeId != null) StorageService.setStoreId(storeId.toString());
        final storeData = response.data['store'] ?? response.data['data']?['store'];
        final storeType = storeData?['type']?.toString();
        final isNew = response.data['isNew'] == true || response.data['data']?['isNew'] == true;
        if (storeType != null && storeType != 'null') StorageService.setStoreType(storeType);

        // Register FCM token with backend after successful login
        unawaited(NotificationService().registerTokenAfterLogin());

        if (isNew || storeType == null) {
          Get.offAllNamed(AppRoutes.storeTypeOnboarding);
        } else {
          Get.offAllNamed(AppRoutes.home);
        }
      } else {
        Get.snackbar('Error', 'Invalid OTP. Please try again.',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Invalid OTP. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
