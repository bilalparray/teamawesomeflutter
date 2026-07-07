/// Semantic version helpers for force-update checks.
class VersionUtils {
  /// Strips build metadata (e.g. `1.0.10+20` → `1.0.10`).
  static String normalize(String version) {
    return version.split('+').first.trim();
  }

  /// Returns negative if [a] < [b], zero if equal, positive if [a] > [b].
  static int compare(String a, String b) {
    final aParts = _parseParts(normalize(a));
    final bParts = _parseParts(normalize(b));
    final length = aParts.length > bParts.length ? aParts.length : bParts.length;

    for (var i = 0; i < length; i++) {
      final av = i < aParts.length ? aParts[i] : 0;
      final bv = i < bParts.length ? bParts[i] : 0;
      if (av != bv) return av.compareTo(bv);
    }
    return 0;
  }

  static bool isBelowMinimum(String current, String minimum) {
    final min = normalize(minimum);
    if (min.isEmpty) return false;
    return compare(current, min) < 0;
  }

  static List<int> _parseParts(String version) {
    if (version.isEmpty) return [0];
    return version
        .split('.')
        .map((part) => int.tryParse(part.trim()) ?? 0)
        .toList();
  }
}
