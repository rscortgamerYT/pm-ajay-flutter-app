/// Granular permissions for role-based access control (RBAC)
enum Permission {
  // Project permissions
  viewProjects,
  createProjects,
  editProjects,
  deleteProjects,
  approveProjects,
  
  // Fund permissions
  viewFunds,
  createFunds,
  editFunds,
  approveFunds,
  allocateFunds,
  
  // Agency permissions
  viewAgencies,
  createAgencies,
  editAgencies,
  deleteAgencies,
  manageAgencyCoordination,
  
  // Report permissions
  viewReports,
  viewOwnReports,
  submitReports,
  generateReports,
  approveReports,
  
  // AI & Analytics permissions
  viewAIInsights,
  configureAI,
  exportAnalytics,
  
  // User management permissions
  viewUsers,
  createUsers,
  editUsers,
  deleteUsers,
  manageRoles,
  
  // System permissions
  viewSystemSettings,
  editSystemSettings,
  viewAuditLogs,
  manageIntegrations,
  
  // Blockchain permissions
  viewBlockchainRecords,
  verifyBlockchainRecords,
  
  // Communication permissions
  sendNotifications,
  manageAlerts,
  accessMessaging,
  
  // Document permissions
  viewDocuments,
  uploadDocuments,
  deleteDocuments,
  approveDocuments,
}

extension PermissionExtension on Permission {
  String get displayName {
    switch (this) {
      case Permission.viewProjects:
        return 'View Projects';
      case Permission.createProjects:
        return 'Create Projects';
      case Permission.editProjects:
        return 'Edit Projects';
      case Permission.deleteProjects:
        return 'Delete Projects';
      case Permission.approveProjects:
        return 'Approve Projects';
        
      case Permission.viewFunds:
        return 'View Funds';
      case Permission.createFunds:
        return 'Create Funds';
      case Permission.editFunds:
        return 'Edit Funds';
      case Permission.approveFunds:
        return 'Approve Funds';
      case Permission.allocateFunds:
        return 'Allocate Funds';
        
      case Permission.viewAgencies:
        return 'View Agencies';
      case Permission.createAgencies:
        return 'Create Agencies';
      case Permission.editAgencies:
        return 'Edit Agencies';
      case Permission.deleteAgencies:
        return 'Delete Agencies';
      case Permission.manageAgencyCoordination:
        return 'Manage Agency Coordination';
        
      case Permission.viewReports:
        return 'View All Reports';
      case Permission.viewOwnReports:
        return 'View Own Reports';
      case Permission.submitReports:
        return 'Submit Reports';
      case Permission.generateReports:
        return 'Generate Reports';
      case Permission.approveReports:
        return 'Approve Reports';
        
      case Permission.viewAIInsights:
        return 'View AI Insights';
      case Permission.configureAI:
        return 'Configure AI';
      case Permission.exportAnalytics:
        return 'Export Analytics';
        
      case Permission.viewUsers:
        return 'View Users';
      case Permission.createUsers:
        return 'Create Users';
      case Permission.editUsers:
        return 'Edit Users';
      case Permission.deleteUsers:
        return 'Delete Users';
      case Permission.manageRoles:
        return 'Manage Roles';
        
      case Permission.viewSystemSettings:
        return 'View System Settings';
      case Permission.editSystemSettings:
        return 'Edit System Settings';
      case Permission.viewAuditLogs:
        return 'View Audit Logs';
      case Permission.manageIntegrations:
        return 'Manage Integrations';
        
      case Permission.viewBlockchainRecords:
        return 'View Blockchain Records';
      case Permission.verifyBlockchainRecords:
        return 'Verify Blockchain Records';
        
      case Permission.sendNotifications:
        return 'Send Notifications';
      case Permission.manageAlerts:
        return 'Manage Alerts';
      case Permission.accessMessaging:
        return 'Access Messaging';
        
      case Permission.viewDocuments:
        return 'View Documents';
      case Permission.uploadDocuments:
        return 'Upload Documents';
      case Permission.deleteDocuments:
        return 'Delete Documents';
      case Permission.approveDocuments:
        return 'Approve Documents';
    }
  }

  String get description {
    switch (this) {
      case Permission.viewProjects:
        return 'Ability to view project details and status';
      case Permission.createProjects:
        return 'Ability to create new projects';
      case Permission.editProjects:
        return 'Ability to modify existing projects';
      case Permission.deleteProjects:
        return 'Ability to delete projects';
      case Permission.approveProjects:
        return 'Ability to approve or reject projects';
        
      case Permission.viewFunds:
        return 'Ability to view fund allocations and status';
      case Permission.createFunds:
        return 'Ability to create new fund allocations';
      case Permission.editFunds:
        return 'Ability to modify fund allocations';
      case Permission.approveFunds:
        return 'Ability to approve fund releases';
      case Permission.allocateFunds:
        return 'Ability to allocate funds to projects';
        
      case Permission.viewAgencies:
        return 'Ability to view agency information';
      case Permission.createAgencies:
        return 'Ability to register new agencies';
      case Permission.editAgencies:
        return 'Ability to update agency details';
      case Permission.deleteAgencies:
        return 'Ability to remove agencies from system';
      case Permission.manageAgencyCoordination:
        return 'Ability to manage inter-agency coordination';
        
      case Permission.viewReports:
        return 'Ability to view all system reports';
      case Permission.viewOwnReports:
        return 'Ability to view only own submitted reports';
      case Permission.submitReports:
        return 'Ability to submit new reports';
      case Permission.generateReports:
        return 'Ability to generate custom reports';
      case Permission.approveReports:
        return 'Ability to approve or reject reports';
        
      case Permission.viewAIInsights:
        return 'Ability to view AI-generated insights';
      case Permission.configureAI:
        return 'Ability to configure AI parameters';
      case Permission.exportAnalytics:
        return 'Ability to export analytics data';
        
      case Permission.viewUsers:
        return 'Ability to view user accounts';
      case Permission.createUsers:
        return 'Ability to create new user accounts';
      case Permission.editUsers:
        return 'Ability to modify user accounts';
      case Permission.deleteUsers:
        return 'Ability to delete user accounts';
      case Permission.manageRoles:
        return 'Ability to assign roles and permissions';
        
      case Permission.viewSystemSettings:
        return 'Ability to view system configuration';
      case Permission.editSystemSettings:
        return 'Ability to modify system settings';
      case Permission.viewAuditLogs:
        return 'Ability to view audit trail';
      case Permission.manageIntegrations:
        return 'Ability to manage third-party integrations';
        
      case Permission.viewBlockchainRecords:
        return 'Ability to view blockchain transactions';
      case Permission.verifyBlockchainRecords:
        return 'Ability to verify blockchain records';
        
      case Permission.sendNotifications:
        return 'Ability to send system notifications';
      case Permission.manageAlerts:
        return 'Ability to configure alert rules';
      case Permission.accessMessaging:
        return 'Ability to use inter-agency messaging';
        
      case Permission.viewDocuments:
        return 'Ability to view documents';
      case Permission.uploadDocuments:
        return 'Ability to upload new documents';
      case Permission.deleteDocuments:
        return 'Ability to delete documents';
      case Permission.approveDocuments:
        return 'Ability to approve document submissions';
    }
  }

  PermissionCategory get category {
    if (name.contains('Project')) return PermissionCategory.projects;
    if (name.contains('Fund')) return PermissionCategory.funds;
    if (name.contains('Agenc')) return PermissionCategory.agencies;
    if (name.contains('Report')) return PermissionCategory.reports;
    if (name.contains('AI') || name.contains('Analytics')) return PermissionCategory.analytics;
    if (name.contains('User') || name.contains('Role')) return PermissionCategory.userManagement;
    if (name.contains('System') || name.contains('Audit') || name.contains('Integration')) {
      return PermissionCategory.system;
    }
    if (name.contains('Blockchain')) return PermissionCategory.blockchain;
    if (name.contains('Notification') || name.contains('Alert') || name.contains('Messaging')) {
      return PermissionCategory.communication;
    }
    if (name.contains('Document')) return PermissionCategory.documents;
    return PermissionCategory.other;
  }
}

enum PermissionCategory {
  projects,
  funds,
  agencies,
  reports,
  analytics,
  userManagement,
  system,
  blockchain,
  communication,
  documents,
  other,
}

extension PermissionCategoryExtension on PermissionCategory {
  String get displayName {
    switch (this) {
      case PermissionCategory.projects:
        return 'Project Management';
      case PermissionCategory.funds:
        return 'Fund Management';
      case PermissionCategory.agencies:
        return 'Agency Management';
      case PermissionCategory.reports:
        return 'Reporting';
      case PermissionCategory.analytics:
        return 'AI & Analytics';
      case PermissionCategory.userManagement:
        return 'User Management';
      case PermissionCategory.system:
        return 'System Administration';
      case PermissionCategory.blockchain:
        return 'Blockchain';
      case PermissionCategory.communication:
        return 'Communication';
      case PermissionCategory.documents:
        return 'Document Management';
      case PermissionCategory.other:
        return 'Other';
    }
  }
}