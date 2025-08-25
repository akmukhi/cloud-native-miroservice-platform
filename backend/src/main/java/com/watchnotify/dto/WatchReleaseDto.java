package com.watchnotify.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Set;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class WatchReleaseDto {
    
    private Long id;
    
    @NotBlank(message = "Watch name is required")
    private String watchName;
    
    @NotBlank(message = "Brand is required")
    private String brand;
    
    private String modelNumber;
    
    private String description;
    
    private LocalDateTime releaseDate;
    
    private BigDecimal price;
    
    private String currency = "USD";
    
    private Set<String> features;
    
    private Set<String> categories;
    
    private String imageUrl;
    
    private String productUrl;
    
    private Boolean isLimitedEdition = false;
    
    private Integer limitedQuantity;
    
    private Boolean isNotified = false;
    
    private LocalDateTime notificationSentAt;
    
    private LocalDateTime createdAt;
    
    private LocalDateTime updatedAt;
}
