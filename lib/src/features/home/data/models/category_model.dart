class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    this.slug,
    this.parentId,
    this.sortOrder = 0,
    this.isActive = true,
    this.children = const [],
  });

  final int id;
  final String name;
  final String? slug;
  final int? parentId;
  final int sortOrder;
  final bool isActive;
  final List<CategoryModel> children;

  bool get isRoot => parentId == null;
  bool get hasChildren => children.isNotEmpty;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    final children = rawChildren is List
        ? rawChildren
            .whereType<Map>()
            .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : const <CategoryModel>[];
    return CategoryModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      name: '${json['name'] ?? ''}',
      slug: json['slug'] as String?,
      parentId: json['parent_id'] is int
          ? json['parent_id'] as int
          : int.tryParse('${json['parent_id'] ?? ''}'),
      sortOrder: json['sort_order'] is int
          ? json['sort_order'] as int
          : int.tryParse('${json['sort_order'] ?? 0}') ?? 0,
      isActive: json['is_active'] != false,
      children: children,
    );
  }
}
