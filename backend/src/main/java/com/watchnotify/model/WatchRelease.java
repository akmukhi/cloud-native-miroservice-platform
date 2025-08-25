package com.watchnotify.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "watch_releases")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class WatchRelease {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotBlank(message = "Watch name is required")
    @Column(name = "watch_name")
    private String watchName;
    
    @NotBlank(message = "Brand is required")
    private String brand;
    
    @Column(name = "model_number")
    private String modelNumber;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @Column(name = "release_date")
    private LocalDateTime releaseDate;
    
    @Column(name = "price")
    private BigDecimal price;
    
    @Column(name = "currency")
    private String currency = "USD";
    
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "watch_features", joinColumns = @JoinColumn(name = "watch_id"))
    @Column(name = "feature")
    private Set<String> features = new HashSet<>();
    
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "watch_categories", joinColumns = @JoinColumn(name = "watch_id"))
    @Column(name = "category")
    private Set<String> categories = new HashSet<>();
    
    @Column(name = "image_url")
    private String imageUrl;
    
    @Column(name = "product_url")
    private String productUrl;
    
    @Column(name = "is_limited_edition")
    private Boolean isLimitedEdition = false;
    
    @Column(name = "limited_quantity")
    private Integer limitedQuantity;
    
    @Column(name = "is_notified")
    private Boolean isNotified = false;
    
    @Column(name = "notification_sent_at")
    private LocalDateTime notificationSentAt;
    
    @CreationTimestamp
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
