class AppConstants {
  // App Information
  static const String appName = 'PM-AJAY';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'PM-AJAY Government Project Management System';
  
  // API Configuration
  static const String baseUrl = 'https://api.pmajay.gov.in';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  
  // Hive Box Names
  static const String agencyBoxName = 'agencies';
  static const String projectBoxName = 'projects';
  static const String fundBoxName = 'funds';
  static const String notificationBoxName = 'notifications';
  static const String userBoxName = 'users';
  
  // User Roles
  static const String roleCentre = 'CENTRE';
  static const String roleState = 'STATE';
  static const String roleUT = 'UT';
  static const String roleAgency = 'AGENCY';
  static const String roleExecuting = 'EXECUTING_AGENCY';
  
  // Project Components
  static const String componentAdarshGram = 'ADARSH_GRAM';
  static const String componentGIA = 'GIA';
  static const String componentHostel = 'HOSTEL';
  
  // Project Status
  static const String statusPending = 'PENDING';
  static const String statusInProgress = 'IN_PROGRESS';
  static const String statusCompleted = 'COMPLETED';
  static const String statusOnHold = 'ON_HOLD';
  static const String statusCancelled = 'CANCELLED';
  
  // Fund Status
  static const String fundStatusPending = 'PENDING_APPROVAL';
  static const String fundStatusApproved = 'APPROVED';
  static const String fundStatusDisbursed = 'DISBURSED';
  static const String fundStatusRejected = 'REJECTED';
  
  // Notification Types
  static const String notificationFundApproval = 'FUND_APPROVAL';
  static const String notificationProjectUpdate = 'PROJECT_UPDATE';
  static const String notificationTaskAssignment = 'TASK_ASSIGNMENT';
  static const String notificationDeadline = 'DEADLINE_REMINDER';
  static const String notificationSystemAlert = 'SYSTEM_ALERT';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File Upload
  static const int maxFileSizeMB = 10;
  static const List<String> allowedFileTypes = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'jpg',
    'jpeg',
    'png',
  ];
  
  // Date Formats
  static const String dateFormatDisplay = 'dd MMM yyyy';
  static const String dateFormatApi = 'yyyy-MM-dd';
  static const String dateTimeFormatDisplay = 'dd MMM yyyy, hh:mm a';
  static const String dateTimeFormatApi = 'yyyy-MM-dd HH:mm:ss';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  
  // Cache Duration
  static const Duration cacheShortDuration = Duration(minutes: 5);
  static const Duration cacheMediumDuration = Duration(hours: 1);
  static const Duration cacheLongDuration = Duration(days: 1);
  
  // Error Messages
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorTimeout = 'Request timeout. Please try again.';
  static const String errorUnauthorized = 'Unauthorized access. Please login again.';
  static const String errorServerError = 'Server error. Please try again later.';
  static const String errorUnknown = 'An unexpected error occurred.';
  
  // Success Messages
  static const String successLogin = 'Login successful';
  static const String successLogout = 'Logout successful';
  static const String successDataSaved = 'Data saved successfully';
  static const String successDataUpdated = 'Data updated successfully';
  static const String successDataDeleted = 'Data deleted successfully';
}