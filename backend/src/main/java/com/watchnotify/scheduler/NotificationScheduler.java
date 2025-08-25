package com.watchnotify.scheduler;

import com.watchnotify.dto.NotificationRequestDto;
import com.watchnotify.service.NotificationService;
import com.watchnotify.service.WatchReleaseService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
@Slf4j
public class NotificationScheduler {
    
    private final NotificationService notificationService;
    private final WatchReleaseService watchReleaseService;
    
    /**
     * Scheduled task to check for unnotified watch releases and send notifications
     * Runs every 30 minutes
     */
    @Scheduled(fixedRate = 1800000) // 30 minutes
    public void sendNotificationsForNewReleases() {
        log.info("Starting scheduled notification check for new watch releases");
        
        try {
            List<com.watchnotify.dto.WatchReleaseDto> unnotifiedReleases = watchReleaseService.getUnnotifiedReleases();
            
            if (unnotifiedReleases.isEmpty()) {
                log.info("No unnotified watch releases found");
                return;
            }
            
            log.info("Found {} unnotified watch releases", unnotifiedReleases.size());
            
            for (com.watchnotify.dto.WatchReleaseDto release : unnotifiedReleases) {
                NotificationRequestDto request = new NotificationRequestDto();
                request.setWatchReleaseId(release.getId());
                request.setSendEmail(true);
                request.setSendSms(false);
                request.setSendPush(true);
                request.setCustomMessage("A new watch release is now available!");
                
                try {
                    notificationService.sendWatchReleaseNotifications(request);
                    log.info("Sent notifications for watch release: {}", release.getWatchName());
                } catch (Exception e) {
                    log.error("Failed to send notifications for watch release: {}", release.getWatchName(), e);
                }
            }
            
        } catch (Exception e) {
            log.error("Error in scheduled notification task", e);
        }
    }
    
    /**
     * Scheduled task to send reminder notifications for upcoming releases
     * Runs every hour
     */
    @Scheduled(fixedRate = 3600000) // 1 hour
    public void sendRemindersForUpcomingReleases() {
        log.info("Starting scheduled reminder check for upcoming watch releases");
        
        try {
            List<com.watchnotify.dto.WatchReleaseDto> upcomingReleases = watchReleaseService.getUpcomingReleases();
            
            if (upcomingReleases.isEmpty()) {
                log.info("No upcoming watch releases found");
                return;
            }
            
            log.info("Found {} upcoming watch releases", upcomingReleases.size());
            
            for (com.watchnotify.dto.WatchReleaseDto release : upcomingReleases) {
                NotificationRequestDto request = new NotificationRequestDto();
                request.setWatchReleaseId(release.getId());
                request.setSendEmail(true);
                request.setSendSms(false);
                request.setSendPush(true);
                request.setCustomMessage("Don't miss out! This watch will be released soon.");
                
                try {
                    notificationService.sendWatchReleaseNotifications(request);
                    log.info("Sent reminder notifications for upcoming release: {}", release.getWatchName());
                } catch (Exception e) {
                    log.error("Failed to send reminder notifications for upcoming release: {}", release.getWatchName(), e);
                }
            }
            
        } catch (Exception e) {
            log.error("Error in scheduled reminder task", e);
        }
    }
    
    /**
     * Scheduled task to send notifications for limited edition releases
     * Runs every 15 minutes
     */
    @Scheduled(fixedRate = 900000) // 15 minutes
    public void sendNotificationsForLimitedEditions() {
        log.info("Starting scheduled notification check for limited edition releases");
        
        try {
            List<com.watchnotify.dto.WatchReleaseDto> limitedEditions = watchReleaseService.getLimitedEditionReleases();
            
            if (limitedEditions.isEmpty()) {
                log.info("No limited edition releases found");
                return;
            }
            
            log.info("Found {} limited edition releases", limitedEditions.size());
            
            for (com.watchnotify.dto.WatchReleaseDto release : limitedEditions) {
                if (release.getIsNotified() == null || !release.getIsNotified()) {
                    NotificationRequestDto request = new NotificationRequestDto();
                    request.setWatchReleaseId(release.getId());
                    request.setSendEmail(true);
                    request.setSendSms(true);
                    request.setSendPush(true);
                    request.setCustomMessage("Limited edition alert! Only " + release.getLimitedQuantity() + " pieces available.");
                    
                    try {
                        notificationService.sendWatchReleaseNotifications(request);
                        log.info("Sent limited edition notifications for: {}", release.getWatchName());
                    } catch (Exception e) {
                        log.error("Failed to send limited edition notifications for: {}", release.getWatchName(), e);
                    }
                }
            }
            
        } catch (Exception e) {
            log.error("Error in scheduled limited edition notification task", e);
        }
    }
}
