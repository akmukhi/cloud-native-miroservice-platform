package com.watchnotify.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Set;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NotificationRequestDto {
    
    private Long watchReleaseId;
    
    private Set<String> categories;
    
    private Set<String> brands;
    
    private Boolean sendEmail = true;
    
    private Boolean sendSms = false;
    
    private Boolean sendPush = true;
    
    private String customMessage;
}
