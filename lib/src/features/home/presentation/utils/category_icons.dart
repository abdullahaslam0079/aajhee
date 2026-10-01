import 'package:aajhee/src/imports/core_imports.dart';

IconData categoryIconForName(String name) {
  final normalized = name.trim().toLowerCase();

  return switch (normalized) {
    'grocery & food' || 'grocery' || 'food' => Icons.shopping_basket_outlined,
    'fresh produce' || 'dairy & eggs' || 'bakery' || 'beverages' || 'snacks' ||
    'meat & seafood' =>
      Icons.restaurant_rounded,
    'electronics' || 'mobiles' || 'laptops' || 'audio' || 'accessories' ||
    'home appliances' || 'electronics accessories' =>
      Icons.smartphone_outlined,
    'fashion' || 'fasion' || 'men' || 'women' || 'kids' || 'footwear' ||
    'bags & accessories' =>
      Icons.checkroom_outlined,
    'home & living' || 'furniture' || 'kitchen' || 'decor' || 'bedding' =>
      Icons.home_outlined,
    'beauty' || 'beauty & cosmetics' || 'makeup' || 'skincare' || 'haircare' ||
    'fragrance' =>
      Icons.brush_outlined,
    'more' => Icons.apps_outlined,
    'gifts' || 'gift & specialty' || 'flowers' || 'personalized' || 'occasions' =>
      Icons.card_giftcard_outlined,
    'health' || 'heatlth' || 'pharmacy' || 'wellness' || 'personal care' =>
      Icons.health_and_safety_outlined,
    'other' || 'misc' => Icons.category_outlined,
    'entertainment' => Icons.movie_outlined,
    'salon & spa' => Icons.content_cut_outlined,
    'travel' => Icons.flight_outlined,
    'fitness' => Icons.fitness_center_outlined,
    'lifestyle & hobbies' || 'lifestyle & hobbies' => Icons.palette_outlined,
    'mother & babycare' => Icons.child_care_outlined,
    'education' => Icons.school_outlined,
    'vehicles & auto' => Icons.directions_car_outlined,
    'professional services' => Icons.work_outline_rounded,
    'nicotine' => Icons.smoke_free_outlined,
    'financial & legal services' => Icons.account_balance_outlined,
    'logistics' => Icons.local_shipping_outlined,
    _ => Icons.category_outlined,
  };
}
