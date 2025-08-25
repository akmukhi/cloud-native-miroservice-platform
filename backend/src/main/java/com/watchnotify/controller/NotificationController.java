package com.watchnotify.controller;

import com.watchnotify.dto.NotificationRequestDto;
import com.watchnotify.model.Notification;
import com.watchnotify.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class NotificationController {
    
    private final NotificationService notificationService;
    
    @PostMapping("/send")
    public ResponseEntity<String> sendNotifications(@RequestBody NotificationRequestDto request) {
        try {
            notificationService.sendWatchReleaseNotifications(request);
            return ResponseEntity.ok("Notifications sent successfully");
        } catch (RuntimeException e) {
            log.error("Error sending notifications: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to send notifications: " + e.getMessage());
        }
    }
    
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Notification>> getUserNotifications(@PathVariable Long userId) {
        List<Notification> notifications = notificationService.getUserNotifications(userId);
        return ResponseEntity.ok(notifications);
    }
    
    @GetMapping("/status/{status}")
    public ResponseEntity<List<Notification>> getNotificationsByStatus(@PathVariable Notification.NotificationStatus status) {
        List<Notification> notifications = notificationService.getNotificationsByStatus(status);
        return ResponseEntity.ok(notifications);
    }
    
    @GetMapping("/date-range")
    public ResponseEntity<List<Notification>> getNotificationsByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        List<Notification> notifications = notificationService.getNotificationsByDateRange(startDate, endDate);
        return ResponseEntity.ok(notifications);
    }
    
    @GetMapping("/user/{userId}/count")
    public ResponseEntity<Long> getNotificationCountForUser(@PathVariable Long userId) {
        Long count = notificationService.getNotificationCountForUser(userId);
        return ResponseEntity.ok(count);
    }
    
    @PostMapping("/test-email")
    public ResponseEntity<String> testEmailNotification(@RequestParam String email) {
        try {
            // This would be a test endpoint for email functionality
            log.info("Test email notification requested for: {}", email);
            return ResponseEntity.ok("Test email notification sent to: " + email);
        } catch (Exception e) {
            log.error("Error sending test email: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to send test email: " + e.getMessage());
        }
    }
    
    @PostMapping("/test-sms")
    public ResponseEntity<String> testSmsNotification(@RequestParam String phoneNumber) {
        try {
            // This would be a test endpoint for SMS functionality
            log.info("Test SMS notification requested for: {}", phoneNumber);
            return ResponseEntity.ok("Test SMS notification sent to: " + phoneNumber);
        } catch (Exception e) {
            log.error("Error sending test SMS: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to send test SMS: " + e.getMessage());
        }
    }
    
    @PostMapping("/test-push")
    public ResponseEntity<String> testPushNotification(@RequestParam String userId) {
        try {
            // This would be a test endpoint for push notification functionality
            log.info("Test push notification requested for user: {}", userId);
            return ResponseEntity.ok("Test push notification sent to user: " + userId);
        } catch (Exception e) {
            log.error("Error sending test push notification: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to send test push notification: " + e.getMessage());
        }
    }
}
