import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../../riders/controllers/rider_controller.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderController>(() => OrderController());
    Get.lazyPut<RiderController>(() => RiderController());
  }
}
