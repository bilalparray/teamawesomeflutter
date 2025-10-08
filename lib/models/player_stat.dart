class PlayerStat {
  final String? id;
  final String? name;
  final String? role;
  final String? imageUrl; // Now expects a URL
  final int count; // metric count

  PlayerStat(
      {this.id, this.name, this.role, this.imageUrl, required this.count});

  factory PlayerStat.fromJson(Map<String, dynamic> json) {
    return PlayerStat(
      id: json['_id']?.toString(),
      name: json['name'] as String?,
      role: json['role'] as String?,
      imageUrl:
          json['image'] as String?, // server should return image URL in `image`
      count: (json['count'] is int)
          ? json['count'] as int
          : int.tryParse(json['count']?.toString() ?? '') ??
              int.tryParse(json['fiftiesCount']?.toString() ?? '') ??
              int.tryParse(json['hundredsCount']?.toString() ?? '') ??
              int.tryParse(json['wicketsCount']?.toString() ?? '') ??
              0,
    );
  }
}
