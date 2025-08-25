package com.watchnotify.repository;

import com.watchnotify.model.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    
    List<Notification> findByUserId(Long userId);
    
    List<Notification> findByStatus(Notification.NotificationStatus status);
    
    List<Notification> findByUserIdAndStatus(Long userId, Notification.NotificationStatus status);
    
    List<Notification> findByWatchReleaseId(Long watchReleaseId);
    
    @Query("SELECT n FROM Notification n WHERE n.status = 'PENDING' AND n.retryCount < :maxRetries")
    List<Notification> findPendingNotificationsWithRetryLimit(@Param("maxRetries") Integer maxRetries);
    
    @Query("SELECT n FROM Notification n WHERE n.createdAt >= :startDate AND n.createdAt <= :endDate")
    List<Notification> findNotificationsByDateRange(@Param("startDate") LocalDateTime startDate, 
                                                   @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT COUNT(n) FROM Notification n WHERE n.user.id = :userId AND n.status = 'SENT'")
    Long countSentNotificationsByUser(@Param("userId") Long userId);
}
