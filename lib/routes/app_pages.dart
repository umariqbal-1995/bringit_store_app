import 'package:get/get.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/send_otp_view.dart';
import '../modules/auth/views/verify_otp_view.dart';
import '../modules/auth/views/store_type_view.dart';
import '../modules/auth/views/store_setup_view.dart';
import '../modules/auth/views/store_location_view.dart';
import '../modules/auth/views/store_banner_view.dart';
import '../modules/auth/views/store_id_card_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/orders/bindings/order_binding.dart';
import '../modules/orders/views/order_list_view.dart';
import '../modules/orders/views/order_detail_view.dart';
import '../modules/products/bindings/product_binding.dart';
import '../modules/products/views/product_list_view.dart';
import '../modules/products/views/add_product_view.dart';
import '../modules/menu/bindings/menu_binding.dart';
import '../modules/menu/views/add_menu_item_view.dart';
import '../modules/riders/bindings/rider_binding.dart';
import '../modules/riders/views/rider_list_view.dart';
import '../modules/notifications/bindings/notification_binding.dart';
import '../modules/notifications/views/notification_view.dart';
import '../modules/analytics/bindings/analytics_binding.dart';
import '../modules/analytics/views/analytics_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),
    GetPage(
      name: AppRoutes.sendOtp,
      page: () => const SendOtpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.verifyOtp,
      page: () => const VerifyOtpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.storeTypeOnboarding,
      page: () => const StoreTypeView(),
    ),
    GetPage(
      name: AppRoutes.storeSetup,
      page: () => const StoreSetupView(),
    ),
    GetPage(
      name: AppRoutes.storeLocation,
      page: () => const StoreLocationView(),
    ),
    GetPage(
      name: AppRoutes.storeBanner,
      page: () => const StoreBannerView(),
    ),
    GetPage(
      name: AppRoutes.storeIdCard,
      page: () => const StoreIdCardView(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      bindings: [
        DashboardBinding(),
        OrderBinding(),
        ProductBinding(),
        MenuBinding(),
        AnalyticsBinding(),
        NotificationBinding(),
        SettingsBinding(),
        RiderBinding(),
      ],
    ),
    GetPage(
      name: AppRoutes.orderDetail,
      page: () => const OrderDetailView(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: AppRoutes.addProduct,
      page: () => const AddProductView(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.editProduct,
      page: () => const AddProductView(isEditing: true),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.addMenuItem,
      page: () => const AddMenuItemView(),
      binding: MenuBinding(),
    ),
    GetPage(
      name: AppRoutes.editMenuItem,
      page: () => const AddMenuItemView(isEditing: true),
      binding: MenuBinding(),
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrderListView(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: AppRoutes.products,
      page: () => const ProductListView(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.analytics,
      page: () => const AnalyticsView(),
      binding: AnalyticsBinding(),
    ),
    GetPage(
      name: AppRoutes.riders,
      page: () => const RiderListView(),
      binding: RiderBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
  ];
}
