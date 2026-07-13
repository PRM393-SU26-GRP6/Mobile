class GeocodingResult {
  const GeocodingResult({
    required this.latitude,
    required this.longitude,
    required this.displayName,
    this.isApproximate = false,
  });

  final double latitude;
  final double longitude;
  final String displayName;
  final bool isApproximate;

  GeocodingResult asApproximate() {
    return GeocodingResult(
      latitude: latitude,
      longitude: longitude,
      displayName: displayName,
      isApproximate: true,
    );
  }

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    return GeocodingResult(
      latitude: double.parse(json['lat'].toString()),
      longitude: double.parse(json['lon'].toString()),
      displayName: json['display_name']?.toString() ?? '',
    );
  }
}
