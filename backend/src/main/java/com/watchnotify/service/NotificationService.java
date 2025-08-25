package com.watchnotify.service;

import com.watchnotify.dto.NotificationRequestDto;
import com.watchnotify.model.Notification;
import com.watchnotify.model.User;
import com.watchnotify.model.WatchRelease;
import com.watchnotify.repository.NotificationRepository;
import com.watchnotify.repository.UserRepository;
import com.watchnotify.repository.WatchReleaseRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class NotificationService {
    
    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;
    private final WatchReleaseRepository watchReleaseRepository;
    private final JavaMailSender emailSender;
    
    @Async
    public void sendWatchReleaseNotifications(NotificationRequestDto request) {
        try {
            WatchRelease watchRelease = watchReleaseRepository.findById(request.getWatchReleaseId())
                    .orElseThrow(() -> new RuntimeException("Watch release not found"));
            
            List<User> targetUsers = getTargetUsers(request);
            
            for (User user : targetUsers) {
                sendNotificationToUser(user, watchRelease, request);
            }
            
            // Mark the release as notified
            watchRelease.setIsNotified(true);
            watchRelease.setNotificationSentAt(LocalDateTime.now());
            watchReleaseRepository.save(watchRelease);
            
            log.info("Sent notifications for watch release: {} to {} users", 
                    watchRelease.getWatchName(), targetUsers.size());
                    
        } catch (Exception e) {
            log.error("Error sending watch release notifications", e);
            throw new RuntimeException("Failed to send notifications", e);
        }
    }
    
    @Async
    public void sendNotificationToUser(User user, WatchRelease watchRelease, NotificationRequestDto request) {
        try {
            // Send email notification
            if (request.getSendEmail() && user.getEmailNotificationsEnabled()) {
                sendEmailNotification(user, watchRelease, request.getCustomMessage());
            }
            
            // Send SMS notification
            if (request.getSendSms() && user.getSmsNotificationsEnabled() && user.getPhoneNumber() != null) {
                sendSmsNotification(user, watchRelease, request.getCustomMessage());
            }
            
            // Send push notification
            if (request.getSendPush() && user.getPushNotificationsEnabled()) {
                sendPushNotification(user, watchRelease, request.getCustomMessage());
            }
            
        } catch (Exception e) {
            log.error("Error sending notification to user: {}", user.getEmail(), e);
            saveFailedNotification(user, watchRelease, "Failed to send notification: " + e.getMessage());
        }
    }
    
    private void sendEmailNotification(User user, WatchRelease watchRelease, String customMessage) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(user.getEmail());
            message.setSubject("New Watch Release: " + watchRelease.getWatchName());
            
            String emailContent = buildEmailContent(user, watchRelease, customMessage);
            message.setText(emailContent);
            
            emailSender.send(message);
            
            saveNotification(user, watchRelease, Notification.NotificationType.EMAIL, 
                    "New Watch Release: " + watchRelease.getWatchName(), emailContent, user.getEmail());
            
            log.info("Email notification sent to: {}", user.getEmail());
            
        } catch (Exception e) {
            log.error("Failed to send email notification to: {}", user.getEmail(), e);
            saveFailedNotification(user, watchRelease, "Email sending failed: " + e.getMessage());
        }
    }
    
    private void sendSmsNotification(User user, WatchRelease watchRelease, String customMessage) {
        try {
            // This would integrate with an SMS service like Twilio
            String smsContent = buildSmsContent(user, watchRelease, customMessage);
            
            // Placeholder for SMS sending logic
            log.info("SMS notification would be sent to: {} with content: {}", user.getPhoneNumber(), smsContent);
            
            saveNotification(user, watchRelease, Notification.NotificationType.SMS, 
                    "New Watch Release", smsContent, user.getPhoneNumber());
            
        } catch (Exception e) {
            log.error("Failed to send SMS notification to: {}", user.getPhoneNumber(), e);
            saveFailedNotification(user, watchRelease, "SMS sending failed: " + e.getMessage());
        }
    }
    
    private void sendPushNotification(User user, WatchRelease watchRelease, String customMessage) {
        try {
            // This would integrate with a push notification service like Firebase
            String pushContent = buildPushContent(user, watchRelease, customMessage);
            
            // Placeholder for push notification logic
            log.info("Push notification would be sent to user: {} with content: {}", user.getEmail(), pushContent);
            
            saveNotification(user, watchRelease, Notification.NotificationType.PUSH, 
                    "New Watch Release", pushContent, user.getEmail());
            
        } catch (Exception e) {
            log.error("Failed to send push notification to user: {}", user.getEmail(), e);
            saveFailedNotification(user, watchRelease, "Push notification failed: " + e.getMessage());
        }
    }
    
    private String buildEmailContent(User user, WatchRelease watchRelease, String customMessage) {
        StringBuilder content = new StringBuilder();
        content.append("Dear ").append(user.getFirstName()).append(",\n\n");
        
        if (customMessage != null && !customMessage.trim().isEmpty()) {
            content.append(customMessage).append("\n\n");
        }
        
        content.append("We're excited to announce a new watch release!\n\n");
        content.append("Watch: ").append(watchRelease.getWatchName()).append("\n");
        content.append("Brand: ").append(watchRelease.getBrand()).append("\n");
        
        if (watchRelease.getModelNumber() != null) {
            content.append("Model: ").append(watchRelease.getModelNumber()).append("\n");
        }
        
        if (watchRelease.getPrice() != null) {
            content.append("Price: ").append(watchRelease.getCurrency()).append(" ").append(watchRelease.getPrice()).append("\n");
        }
        
        if (watchRelease.getDescription() != null) {
            content.append("Description: ").append(watchRelease.getDescription()).append("\n");
        }
        
        if (watchRelease.getProductUrl() != null) {
            content.append("Learn more: ").append(watchRelease.getProductUrl()).append("\n");
        }
        
        content.append("\nBest regards,\nWatch Notification Service");
        
        return content.toString();
    }
    
    private String buildSmsContent(User user, WatchRelease watchRelease, String customMessage) {
        StringBuilder content = new StringBuilder();
        content.append("New watch release: ").append(watchRelease.getWatchName());
        content.append(" by ").append(watchRelease.getBrand());
        
        if (watchRelease.getPrice() != null) {
            content.append(" - ").append(watchRelease.getCurrency()).append(" ").append(watchRelease.getPrice());
        }
        
        if (customMessage != null && !customMessage.trim().isEmpty()) {
            content.append(" - ").append(customMessage);
        }
        
        return content.toString();
    }
    
    private String buildPushContent(User user, WatchRelease watchRelease, String customMessage) {
        return "New " + watchRelease.getBrand() + " watch: " + watchRelease.getWatchName() + " is now available!";
    }
    
    private List<User> getTargetUsers(NotificationRequestDto request) {
        if (request.getCategories() != null && !request.getCategories().isEmpty()) {
            return userRepository.findActiveUsersWithPreferences(request.getCategories().stream().toList());
        } else if (request.getBrands() != null && !request.getBrands().isEmpty()) {
            return userRepository.findActiveUsersForEmailNotifications(request.getBrands().stream().toList());
        } else {
            return userRepository.findByIsActiveTrue();
        }
    }
    
    private void saveNotification(User user, WatchRelease watchRelease, Notification.NotificationType type, 
                                String subject, String message, String recipient) {
        Notification notification = new Notification();
        notification.setUser(user);
        notification.setWatchRelease(watchRelease);
        notification.setNotificationType(type);
        notification.setStatus(Notification.NotificationStatus.SENT);
        notification.setSubject(subject);
        notification.setMessage(message);
        notification.setRecipient(recipient);
        notification.setSentAt(LocalDateTime.now());
        
        notificationRepository.save(notification);
    }
    
    private void saveFailedNotification(User user, WatchRelease watchRelease, String errorMessage) {
        Notification notification = new Notification();
        notification.setUser(user);
        notification.setWatchRelease(watchRelease);
        notification.setStatus(Notification.NotificationStatus.FAILED);
        notification.setErrorMessage(errorMessage);
        
        notificationRepository.save(notification);
    }
    
    public List<Notification> getUserNotifications(Long userId) {
        return notificationRepository.findByUserId(userId);
    }
    
    public List<Notification> getNotificationsByStatus(Notification.NotificationStatus status) {
        return notificationRepository.findByStatus(status);
    }
    
    public List<Notification> getNotificationsByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        return notificationRepository.findNotificationsByDateRange(startDate, endDate);
    }
    
    public Long getNotificationCountForUser(Long userId) {
        return notificationRepository.countSentNotificationsByUser(userId);
    }
}
