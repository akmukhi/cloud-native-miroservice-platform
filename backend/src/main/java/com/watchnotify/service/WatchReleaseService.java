package com.watchnotify.service;

import com.watchnotify.dto.WatchReleaseDto;
import com.watchnotify.model.WatchRelease;
import com.watchnotify.repository.WatchReleaseRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class WatchReleaseService {
    
    private final WatchReleaseRepository watchReleaseRepository;
    
    public List<WatchReleaseDto> getAllWatchReleases() {
        return watchReleaseRepository.findAll().stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    public Optional<WatchReleaseDto> getWatchReleaseById(Long id) {
        return watchReleaseRepository.findById(id)
                .map(this::convertToDto);
    }
    
    public WatchReleaseDto createWatchRelease(WatchReleaseDto watchReleaseDto) {
        WatchRelease watchRelease = convertToEntity(watchReleaseDto);
        WatchRelease savedRelease = watchReleaseRepository.save(watchRelease);
        log.info("Created new watch release with ID: {}", savedRelease.getId());
        return convertToDto(savedRelease);
    }
    
    public WatchReleaseDto updateWatchRelease(Long id, WatchReleaseDto watchReleaseDto) {
        WatchRelease existingRelease = watchReleaseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Watch release not found with ID: " + id));
        
        existingRelease.setWatchName(watchReleaseDto.getWatchName());
        existingRelease.setBrand(watchReleaseDto.getBrand());
        existingRelease.setModelNumber(watchReleaseDto.getModelNumber());
        existingRelease.setDescription(watchReleaseDto.getDescription());
        existingRelease.setReleaseDate(watchReleaseDto.getReleaseDate());
        existingRelease.setPrice(watchReleaseDto.getPrice());
        existingRelease.setCurrency(watchReleaseDto.getCurrency());
        existingRelease.setFeatures(watchReleaseDto.getFeatures());
        existingRelease.setCategories(watchReleaseDto.getCategories());
        existingRelease.setImageUrl(watchReleaseDto.getImageUrl());
        existingRelease.setProductUrl(watchReleaseDto.getProductUrl());
        existingRelease.setIsLimitedEdition(watchReleaseDto.getIsLimitedEdition());
        existingRelease.setLimitedQuantity(watchReleaseDto.getLimitedQuantity());
        
        WatchRelease updatedRelease = watchReleaseRepository.save(existingRelease);
        log.info("Updated watch release with ID: {}", updatedRelease.getId());
        return convertToDto(updatedRelease);
    }
    
    public void deleteWatchRelease(Long id) {
        if (!watchReleaseRepository.existsById(id)) {
            throw new RuntimeException("Watch release not found with ID: " + id);
        }
        watchReleaseRepository.deleteById(id);
        log.info("Deleted watch release with ID: {}", id);
    }
    
    public List<WatchReleaseDto> getUnnotifiedReleases() {
        return watchReleaseRepository.findByIsNotifiedFalse().stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    public List<WatchReleaseDto> getReleasesByBrand(String brand) {
        return watchReleaseRepository.findByBrand(brand).stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    public List<WatchReleaseDto> getReleasesByBrands(List<String> brands) {
        return watchReleaseRepository.findByBrandIn(brands).stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    public List<WatchReleaseDto> getUpcomingReleases() {
        return watchReleaseRepository.findUpcomingReleases(LocalDateTime.now()).stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    public List<WatchReleaseDto> getLimitedEditionReleases() {
        return watchReleaseRepository.findByIsLimitedEditionTrue().stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    public void markAsNotified(Long id) {
        WatchRelease release = watchReleaseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Watch release not found with ID: " + id));
        
        release.setIsNotified(true);
        release.setNotificationSentAt(LocalDateTime.now());
        watchReleaseRepository.save(release);
        log.info("Marked watch release with ID: {} as notified", id);
    }
    
    public List<WatchReleaseDto> getReleasesByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        return watchReleaseRepository.findByReleaseDateBetween(startDate, endDate).stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    private WatchReleaseDto convertToDto(WatchRelease watchRelease) {
        WatchReleaseDto dto = new WatchReleaseDto();
        dto.setId(watchRelease.getId());
        dto.setWatchName(watchRelease.getWatchName());
        dto.setBrand(watchRelease.getBrand());
        dto.setModelNumber(watchRelease.getModelNumber());
        dto.setDescription(watchRelease.getDescription());
        dto.setReleaseDate(watchRelease.getReleaseDate());
        dto.setPrice(watchRelease.getPrice());
        dto.setCurrency(watchRelease.getCurrency());
        dto.setFeatures(watchRelease.getFeatures());
        dto.setCategories(watchRelease.getCategories());
        dto.setImageUrl(watchRelease.getImageUrl());
        dto.setProductUrl(watchRelease.getProductUrl());
        dto.setIsLimitedEdition(watchRelease.getIsLimitedEdition());
        dto.setLimitedQuantity(watchRelease.getLimitedQuantity());
        dto.setIsNotified(watchRelease.getIsNotified());
        dto.setNotificationSentAt(watchRelease.getNotificationSentAt());
        dto.setCreatedAt(watchRelease.getCreatedAt());
        dto.setUpdatedAt(watchRelease.getUpdatedAt());
        return dto;
    }
    
    private WatchRelease convertToEntity(WatchReleaseDto dto) {
        WatchRelease watchRelease = new WatchRelease();
        watchRelease.setId(dto.getId());
        watchRelease.setWatchName(dto.getWatchName());
        watchRelease.setBrand(dto.getBrand());
        watchRelease.setModelNumber(dto.getModelNumber());
        watchRelease.setDescription(dto.getDescription());
        watchRelease.setReleaseDate(dto.getReleaseDate());
        watchRelease.setPrice(dto.getPrice());
        watchRelease.setCurrency(dto.getCurrency());
        watchRelease.setFeatures(dto.getFeatures());
        watchRelease.setCategories(dto.getCategories());
        watchRelease.setImageUrl(dto.getImageUrl());
        watchRelease.setProductUrl(dto.getProductUrl());
        watchRelease.setIsLimitedEdition(dto.getIsLimitedEdition());
        watchRelease.setLimitedQuantity(dto.getLimitedQuantity());
        watchRelease.setIsNotified(dto.getIsNotified());
        watchRelease.setNotificationSentAt(dto.getNotificationSentAt());
        return watchRelease;
    }
}
