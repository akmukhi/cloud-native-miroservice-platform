package com.watchnotify.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Set;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserDto {
    
    private Long id;
    
    @NotBlank(message = "First name is required")
    private String firstName;
    
    @NotBlank(message = "Last name is required")
    private String lastName;
    
    @Email(message = "Email should be valid")
    @NotBlank(message = "Email is required")
    private String email;
    
    private String phoneNumber;
    
    private Boolean isActive = true;
    
    private Boolean emailNotificationsEnabled = true;
    
    private Boolean smsNotificationsEnabled = false;
    
    private Boolean pushNotificationsEnabled = true;
    
    private Set<String> preferences;
}
