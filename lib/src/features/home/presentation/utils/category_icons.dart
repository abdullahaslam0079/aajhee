import 'package:goluto/src/imports/core_imports.dart';

IconData categoryIconForName(String name) {
  final normalized = name.trim().toLowerCase();

  return switch (normalized) {
    'food' => Icons.restaurant_rounded,
    'fashion' || 'fasion' => Icons.checkroom_outlined,
    'beauty & cosmetics' => Icons.spa_outlined,
    'entertainment' => Icons.movie_outlined,
    'salon & spa' => Icons.content_cut_outlined,
    'health' || 'heatlth' => Icons.health_and_safety_outlined,
    'travel' => Icons.flight_outlined,
    'fitness' => Icons.fitness_center_outlined,
    'home & living' => Icons.home_outlined,
    'lifestyle & hobbies' || 'lifeStyle & hobbies' =>
      Icons.palette_outlined,
    'electronics' => Icons.devices_outlined,
    'mother & babycare' => Icons.child_care_outlined,
    'education' => Icons.school_outlined,
    'gift & specialty' => Icons.card_giftcard_outlined,
    'vehicles & auto' => Icons.directions_car_outlined,
    'professional services' => Icons.work_outline_rounded,
    'grocery' => Icons.shopping_basket_outlined,
    'nicotine' => Icons.smoke_free_outlined,
    'financial & legal services' => Icons.account_balance_outlined,
    'logistics' => Icons.local_shipping_outlined,
    _ => Icons.category_outlined,
  };
}
