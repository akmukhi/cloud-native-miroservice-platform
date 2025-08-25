package com.watchnotify.controller;

import com.watchnotify.dto.WatchReleaseDto;
import com.watchnotify.service.WatchReleaseService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/watch-releases")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class WatchReleaseController {
    
    private final WatchReleaseService watchReleaseService;
    
    @GetMapping
    public ResponseEntity<List<WatchReleaseDto>> getAllWatchReleases() {
        List<WatchReleaseDto> releases = watchReleaseService.getAllWatchReleases();
        return ResponseEntity.ok(releases);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<WatchReleaseDto> getWatchReleaseById(@PathVariable Long id) {
        Optional<WatchReleaseDto> release = watchReleaseService.getWatchReleaseById(id);
        return release.map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @PostMapping
    public ResponseEntity<WatchReleaseDto> createWatchRelease(@Valid @RequestBody WatchReleaseDto watchReleaseDto) {
        try {
            WatchReleaseDto createdRelease = watchReleaseService.createWatchRelease(watchReleaseDto);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdRelease);
        } catch (RuntimeException e) {
            log.error("Error creating watch release: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<WatchReleaseDto> updateWatchRelease(@PathVariable Long id, @Valid @RequestBody WatchReleaseDto watchReleaseDto) {
        try {
            WatchReleaseDto updatedRelease = watchReleaseService.updateWatchRelease(id, watchReleaseDto);
            return ResponseEntity.ok(updatedRelease);
        } catch (RuntimeException e) {
            log.error("Error updating watch release: {}", e.getMessage());
            return ResponseEntity.notFound().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteWatchRelease(@PathVariable Long id) {
        try {
            watchReleaseService.deleteWatchRelease(id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            log.error("Error deleting watch release: {}", e.getMessage());
            return ResponseEntity.notFound().build();
        }
    }
    
    @GetMapping("/unnotified")
    public ResponseEntity<List<WatchReleaseDto>> getUnnotifiedReleases() {
        List<WatchReleaseDto> releases = watchReleaseService.getUnnotifiedReleases();
        return ResponseEntity.ok(releases);
    }
    
    @GetMapping("/brand/{brand}")
    public ResponseEntity<List<WatchReleaseDto>> getReleasesByBrand(@PathVariable String brand) {
        List<WatchReleaseDto> releases = watchReleaseService.getReleasesByBrand(brand);
        return ResponseEntity.ok(releases);
    }
    
    @GetMapping("/brands")
    public ResponseEntity<List<WatchReleaseDto>> getReleasesByBrands(@RequestParam List<String> brands) {
        List<WatchReleaseDto> releases = watchReleaseService.getReleasesByBrands(brands);
        return ResponseEntity.ok(releases);
    }
    
    @GetMapping("/upcoming")
    public ResponseEntity<List<WatchReleaseDto>> getUpcomingReleases() {
        List<WatchReleaseDto> releases = watchReleaseService.getUpcomingReleases();
        return ResponseEntity.ok(releases);
    }
    
    @GetMapping("/limited-edition")
    public ResponseEntity<List<WatchReleaseDto>> getLimitedEditionReleases() {
        List<WatchReleaseDto> releases = watchReleaseService.getLimitedEditionReleases();
        return ResponseEntity.ok(releases);
    }
    
    @GetMapping("/date-range")
    public ResponseEntity<List<WatchReleaseDto>> getReleasesByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        List<WatchReleaseDto> releases = watchReleaseService.getReleasesByDateRange(startDate, endDate);
        return ResponseEntity.ok(releases);
    }
    
    @PutMapping("/{id}/mark-notified")
    public ResponseEntity<Void> markAsNotified(@PathVariable Long id) {
        try {
            watchReleaseService.markAsNotified(id);
            return ResponseEntity.ok().build();
        } catch (RuntimeException e) {
            log.error("Error marking watch release as notified: {}", e.getMessage());
            return ResponseEntity.notFound().build();
        }
    }
}
