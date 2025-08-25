package com.watchnotify.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotBlank(message = "First name is required")
    @Column(name = "first_name")
    private String firstName;
    
    @NotBlank(message = "Last name is required")
    @Column(name = "last_name")
    private String lastName;
    
    @Email(message = "Email should be valid")
    @NotBlank(message = "Email is required")
    @Column(unique = true)
    private String email;
    
    @Column(name = "phone_number")
    private String phoneNumber;
    
    @Column(name = "is_active")
    private Boolean isActive = true;
    
    @Column(name = "email_notifications_enabled")
    private Boolean emailNotificationsEnabled = true;
    
    @Column(name = "sms_notifications_enabled")
    private Boolean smsNotificationsEnabled = false;
    
    @Column(name = "push_notifications_enabled")
    private Boolean pushNotificationsEnabled = true;
    
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "user_preferences", joinColumns = @JoinColumn(name = "user_id"))
    @Column(name = "preference")
    private Set<String> preferences = new HashSet<>();
    
    @CreationTimestamp
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
