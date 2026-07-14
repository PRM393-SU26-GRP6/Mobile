part of '../api_service.dart';

extension AuthVenueApiFacade on ApiServiceImpl {
  Future<LoginResponseModel> login(String email, String password) =>
      authService.login(email, password);

  Future<LoginResponseModel> registerCustomer({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) =>
      authService.registerCustomer(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        confirmPassword: confirmPassword,
      );

  Future<LoginResponseModel> registerOwner({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) =>
      authService.registerOwner(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        confirmPassword: confirmPassword,
      );

  Future<LoginResponseModel> verifyOtp(String email, String otp) =>
      authService.verifyOtp(email, otp);
  Future<void> resendOtp(String email) => authService.resendOtp(email);
  Future<void> logout() => authService.logout();
  Future<bool> refreshToken() => authService.refreshToken();
  Future<String?> getAccessToken() => authService.getAccessToken();
  Future<String?> getUserRole() => authService.getUserRole();
  Future<String?> getUserId() => authService.getUserId();

  Future<List<VenueModel>> getVenues({
    String? q,
    String? fieldType,
    String? amenityIds,
    double? minRating,
    double? priceMin,
    double? priceMax,
    double? userLatitude,
    double? userLongitude,
    double? radiusInKm,
    String? sort,
    int page = 1,
    int pageSize = 20,
  }) =>
      venueService.getVenues(
        q: q,
        fieldType: fieldType,
        amenityIds: amenityIds,
        minRating: minRating,
        priceMin: priceMin,
        priceMax: priceMax,
        userLatitude: userLatitude,
        userLongitude: userLongitude,
        radiusInKm: radiusInKm,
        sort: sort,
        page: page,
        pageSize: pageSize,
      );

  Future<List<VenueModel>> searchVenues({
    String? q,
    int page = 1,
    int pageSize = 20,
  }) =>
      venueService.searchVenues(q: q, page: page, pageSize: pageSize);

  Future<List<AmenityModel>> getAllAmenities() =>
      venueService.getAllAmenities();
  Future<List<FootballFieldDto>> getFieldsByVenue(String venueId) =>
      venueService.getFieldsByVenue(venueId);
  Future<VenueModel?> getVenueById(String id) => venueService.getVenueById(id);

  Future<List<VenueModel>> getMyVenues({
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  }) =>
      venueOwnerService.getMyVenues(
        isActive: isActive,
        page: page,
        pageSize: pageSize,
      );

  Future<VenueModel> createVenue({
    required String venueName,
    required String address,
    double? latitude,
    double? longitude,
    String? description,
    String? openingHours,
    String? phoneContact,
  }) =>
      venueOwnerService.createVenue(
        venueName: venueName,
        address: address,
        latitude: latitude,
        longitude: longitude,
        description: description,
        openingHours: openingHours,
        phoneContact: phoneContact,
      );

  Future<VenueModel> updateVenue({
    required String venueId,
    String? venueName,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    String? openingHours,
    String? phoneContact,
  }) =>
      venueOwnerService.updateVenue(
        venueId: venueId,
        venueName: venueName,
        address: address,
        latitude: latitude,
        longitude: longitude,
        description: description,
        openingHours: openingHours,
        phoneContact: phoneContact,
      );

  Future<void> updateVenueStatus(String venueId, bool isActive) =>
      venueOwnerService.updateVenueStatus(venueId, isActive);
}
