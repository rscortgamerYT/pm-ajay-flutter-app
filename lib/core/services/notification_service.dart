import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../domain/entities/agency.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/fund.dart';

/// Multi-level communication engine with context-aware notifications
class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Notification channels
  static const String channelHighPriority = 'high_priority';
  static const String channelMediumPriority = 'medium_priority';
  static const String channelLowPriority = 'low_priority';

  Future<void> initialize() async {
    // Request permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // Create notification channels
    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    // High priority channel
    const highPriorityChannel = AndroidNotificationChannel(
      channelHighPriority,
      'Critical Notifications',
      description: 'Critical alerts requiring immediate attention',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    // Medium priority channel
    const mediumPriorityChannel = AndroidNotificationChannel(
      channelMediumPriority,
      'Important Notifications',
      description: 'Important updates and alerts',
      importance: Importance.high,
      playSound: true,
    );

    // Low priority channel
    const lowPriorityChannel = AndroidNotificationChannel(
      channelLowPriority,
      'General Notifications',
      description: 'General information and updates',
      importance: Importance.defaultImportance,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(highPriorityChannel);
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(mediumPriorityChannel);
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(lowPriorityChannel);
  }

  /// Send context-aware notification to relevant stakeholders
  Future<void> sendContextAwareNotification(
    NotificationContext context,
    List<String> recipientIds,
    {bool escalate = false}
  ) async {
    final notification = _buildContextualNotification(context);
    
    for (final recipientId in recipientIds) {
      // Send via multiple channels based on priority
      await _sendInAppNotification(notification, recipientId);
      
      if (notification.priority == NotificationPriority.high || escalate) {
        await _sendEmailNotification(notification, recipientId);
        await _sendWhatsAppNotification(notification, recipientId);
      } else if (notification.priority == NotificationPriority.medium) {
        await _sendEmailNotification(notification, recipientId);
      }

      // Log notification for tracking
      await _logNotification(notification, recipientId);
    }
  }

  /// Send automated notification for project updates
  Future<void> notifyProjectUpdate(
    Project project,
    ProjectUpdateType updateType,
    List<Agency> stakeholders,
  ) async {
    final context = NotificationContext(
      type: NotificationType.projectUpdate,
      title: _getProjectUpdateTitle(updateType),
      body: _getProjectUpdateBody(project, updateType),
      priority: _getProjectUpdatePriority(updateType),
      data: {
        'projectId': project.id,
        'projectName': project.name,
        'updateType': updateType.name,
        'status': project.status.name,
      },
      actionUrl: '/projects/${project.id}',
    );

    final recipientIds = stakeholders.map((a) => a.id).toList();
    await sendContextAwareNotification(context, recipientIds);
  }

  /// Send automated notification for fund flow updates
  Future<void> notifyFundUpdate(
    Fund fund,
    FundUpdateType updateType,
    List<Agency> stakeholders,
  ) async {
    final context = NotificationContext(
      type: NotificationType.fundUpdate,
      title: _getFundUpdateTitle(updateType),
      body: _getFundUpdateBody(fund, updateType),
      priority: _getFundUpdatePriority(updateType),
      data: {
        'fundId': fund.id,
        'fundName': fund.name,
        'updateType': updateType.name,
        'status': fund.status.name,
        'amount': fund.amount.toString(),
      },
      actionUrl: '/funds/${fund.id}',
    );

    final recipientIds = stakeholders.map((a) => a.id).toList();
    await sendContextAwareNotification(context, recipientIds);
  }

  /// Send escalation notification for critical issues
  Future<void> escalateIssue(
    String issueId,
    String issueDescription,
    AlertSeverity severity,
    List<String> supervisorIds,
  ) async {
    final context = NotificationContext(
      type: NotificationType.escalation,
      title: '🚨 ESCALATION: ${severity.name.toUpperCase()}',
      body: issueDescription,
      priority: NotificationPriority.critical,
      data: {
        'issueId': issueId,
        'severity': severity.name,
        'requiresAction': 'true',
      },
      actionUrl: '/alerts/$issueId',
    );

    await sendContextAwareNotification(
      context,
      supervisorIds,
      escalate: true,
    );
  }

  /// Send delay prediction alert
  Future<void> notifyDelayPrediction(
    String entityId,
    String entityName,
    String entityType,
    int estimatedDelayDays,
    double probability,
    List<String> recipientIds,
  ) async {
    final context = NotificationContext(
      type: NotificationType.aiInsight,
      title: '⚠️ Delay Prediction Alert',
      body: '$entityName may be delayed by $estimatedDelayDays days (${(probability * 100).toStringAsFixed(0)}% probability)',
      priority: probability > 0.7 ? NotificationPriority.high : NotificationPriority.medium,
      data: {
        'entityId': entityId,
        'entityType': entityType,
        'delayDays': estimatedDelayDays.toString(),
        'probability': probability.toString(),
      },
      actionUrl: '/$entityType/$entityId',
    );

    await sendContextAwareNotification(context, recipientIds);
  }

  // Private methods for multi-channel delivery

  Future<void> _sendInAppNotification(
    ContextualNotification notification,
    String recipientId,
  ) async {
    final channelId = notification.priority == NotificationPriority.critical
        ? channelHighPriority
        : notification.priority == NotificationPriority.high
            ? channelHighPriority
            : notification.priority == NotificationPriority.medium
                ? channelMediumPriority
                : channelLowPriority;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          importance: _getImportance(notification.priority),
          priority: _getPriority(notification.priority),
          playSound: true,
          enableVibration: notification.priority != NotificationPriority.low,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: notification.priority == NotificationPriority.critical
              ? InterruptionLevel.critical
              : notification.priority == NotificationPriority.high
                  ? InterruptionLevel.timeSensitive
                  : InterruptionLevel.active,
        ),
      ),
      payload: notification.context.actionUrl,
    );
  }

  Future<void> _sendEmailNotification(
    ContextualNotification notification,
    String recipientId,
  ) async {
    // TODO: Integrate with email service (SendGrid/AWS SES)
    // This would send formatted HTML email to the recipient
    print('Email notification sent to $recipientId: ${notification.title}');
  }

  Future<void> _sendWhatsAppNotification(
    ContextualNotification notification,
    String recipientId,
  ) async {
    // TODO: Integrate with Twilio WhatsApp API
    // This would send WhatsApp message to the recipient
    print('WhatsApp notification sent to $recipientId: ${notification.title}');
  }

  Future<void> _logNotification(
    ContextualNotification notification,
    String recipientId,
  ) async {
    // TODO: Log to database for tracking and analytics
    print('Notification logged: ${notification.title} -> $recipientId');
  }

  ContextualNotification _buildContextualNotification(NotificationContext context) {
    return ContextualNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      context: context,
      title: context.title,
      body: context.body,
      priority: context.priority,
      timestamp: DateTime.now(),
      isRead: false,
    );
  }

  // Helper methods for project updates

  String _getProjectUpdateTitle(ProjectUpdateType type) {
    switch (type) {
      case ProjectUpdateType.statusChange:
        return '📊 Project Status Updated';
      case ProjectUpdateType.milestoneCompleted:
        return '✅ Milestone Completed';
      case ProjectUpdateType.delayDetected:
        return '⚠️ Project Delay Detected';
      case ProjectUpdateType.fundAllocated:
        return '💰 Funds Allocated';
      case ProjectUpdateType.alertCreated:
        return '🚨 New Alert';
    }
  }

  String _getProjectUpdateBody(Project project, ProjectUpdateType type) {
    switch (type) {
      case ProjectUpdateType.statusChange:
        return '${project.name} status changed to ${project.status.name}';
      case ProjectUpdateType.milestoneCompleted:
        return 'Milestone completed for ${project.name}';
      case ProjectUpdateType.delayDetected:
        return '${project.name} is experiencing delays';
      case ProjectUpdateType.fundAllocated:
        return 'Funds allocated to ${project.name}';
      case ProjectUpdateType.alertCreated:
        return 'New alert created for ${project.name}';
    }
  }

  NotificationPriority _getProjectUpdatePriority(ProjectUpdateType type) {
    switch (type) {
      case ProjectUpdateType.delayDetected:
      case ProjectUpdateType.alertCreated:
        return NotificationPriority.high;
      case ProjectUpdateType.milestoneCompleted:
      case ProjectUpdateType.fundAllocated:
        return NotificationPriority.medium;
      case ProjectUpdateType.statusChange:
        return NotificationPriority.low;
    }
  }

  // Helper methods for fund updates

  String _getFundUpdateTitle(FundUpdateType type) {
    switch (type) {
      case FundUpdateType.approved:
        return '✅ Fund Approved';
      case FundUpdateType.released:
        return '💸 Fund Released';
      case FundUpdateType.allocated:
        return '📊 Fund Allocated';
      case FundUpdateType.delayPredicted:
        return '⚠️ Fund Delay Predicted';
    }
  }

  String _getFundUpdateBody(Fund fund, FundUpdateType type) {
    switch (type) {
      case FundUpdateType.approved:
        return '${fund.name} (₹${(fund.amount / 10000000).toStringAsFixed(2)}Cr) has been approved';
      case FundUpdateType.released:
        return '${fund.name} (₹${(fund.amount / 10000000).toStringAsFixed(2)}Cr) has been released';
      case FundUpdateType.allocated:
        return '${fund.name} has been allocated to projects';
      case FundUpdateType.delayPredicted:
        return 'Potential delay predicted for ${fund.name}';
    }
  }

  NotificationPriority _getFundUpdatePriority(FundUpdateType type) {
    switch (type) {
      case FundUpdateType.delayPredicted:
        return NotificationPriority.high;
      case FundUpdateType.approved:
      case FundUpdateType.released:
        return NotificationPriority.medium;
      case FundUpdateType.allocated:
        return NotificationPriority.low;
    }
  }

  Importance _getImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return Importance.max;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.medium:
        return Importance.defaultImportance;
      case NotificationPriority.low:
        return Importance.low;
    }
  }

  Priority _getPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return Priority.max;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.medium:
        return Priority.defaultPriority;
      case NotificationPriority.low:
        return Priority.low;
    }
  }
}

// Supporting classes

class NotificationContext {
  final NotificationType type;
  final String title;
  final String body;
  final NotificationPriority priority;
  final Map<String, dynamic> data;
  final String actionUrl;

  NotificationContext({
    required this.type,
    required this.title,
    required this.body,
    required this.priority,
    required this.data,
    required this.actionUrl,
  });
}

class ContextualNotification {
  final String id;
  final NotificationContext context;
  final String title;
  final String body;
  final NotificationPriority priority;
  final DateTime timestamp;
  final bool isRead;

  ContextualNotification({
    required this.id,
    required this.context,
    required this.title,
    required this.body,
    required this.priority,
    required this.timestamp,
    required this.isRead,
  });
}

enum NotificationType {
  projectUpdate,
  fundUpdate,
  aiInsight,
  escalation,
  citizenReport,
  systemAlert,
}

enum NotificationPriority {
  low,
  medium,
  high,
  critical,
}

enum ProjectUpdateType {
  statusChange,
  milestoneCompleted,
  delayDetected,
  fundAllocated,
  alertCreated,
}

enum FundUpdateType {
  approved,
  released,
  allocated,
  delayPredicted,
}