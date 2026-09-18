import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:aajhee/src/features/home/data/models/map_branch_model.dart';

extension MapBranchMapX on MapBranchModel {
  LatLng get mapPosition => LatLng(latitude, longitude);

  int get discountPercentInt => highestDiscountPercent.round();
}
