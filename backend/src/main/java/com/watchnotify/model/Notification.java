package com.watchnotify.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Notification {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "watch_release_id")
    private WatchRelease watchRelease;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "notification_type")
    private NotificationType notificationType;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private NotificationStatus status = NotificationStatus.PENDING;
    
    @Column(name = "subject")
    private String subject;
    
    @Column(columnDefinition = "TEXT")
    private String message;
    
    @Column(name = "recipient")
    private String recipient;
    
    @Column(name = "sent_at")
    private LocalDateTime sentAt;
    
    @Column(name = "error_message")
    private String errorMessage;
    
    @Column(name = "retry_count")
    private Integer retryCount = 0;
    
    @CreationTimestamp
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    public enum NotificationType {
        EMAIL, SMS, PUSH
    }
    
    public enum NotificationStatus {
        PENDING, SENT, FAILED, CANCELLED
    }
}
