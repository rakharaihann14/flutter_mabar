// API Endpoints Configuration
class ApiEndpoints {
  // Base URL - Update this to your Laravel server
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Auth endpoints
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String forgotPassword = '$baseUrl/forgot-password';
  static const String logout = '$baseUrl/logout';
  static const String me = '$baseUrl/me';
  
  // Event endpoints
  static const String events = '$baseUrl/events';
  
  // Registration endpoints
  static const String registrations = '$baseUrl/registrations';
  static const String myRegistrations = '$baseUrl/registrations/me';
  
  // Notification endpoints
  static const String notifications = '$baseUrl/notifications';
  
  // Admin endpoints
  static const String adminDashboard = '$baseUrl/admin/dashboard';
  static const String adminEvents = '$baseUrl/admin/events';
  static const String adminRegistrations = '$baseUrl/admin/registrations';
  static const String adminSchedules = '$baseUrl/admin/schedules';
}
