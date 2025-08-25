package com.watchnotify.repository;

import com.watchnotify.model.WatchRelease;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface WatchReleaseRepository extends JpaRepository<WatchRelease, Long> {
    
    List<WatchRelease> findByIsNotifiedFalse();
    
    List<WatchRelease> findByReleaseDateBetween(LocalDateTime startDate, LocalDateTime endDate);
    
    List<WatchRelease> findByBrand(String brand);
    
    List<WatchRelease> findByBrandIn(List<String> brands);
    
    @Query("SELECT wr FROM WatchRelease wr WHERE wr.isNotified = false AND " +
           "(:brands IS NULL OR wr.brand IN :brands) AND " +
           "(:categories IS NULL OR EXISTS (SELECT c FROM wr.categories c WHERE c IN :categories))")
    List<WatchRelease> findUnnotifiedReleasesByBrandsAndCategories(
            @Param("brands") List<String> brands,
            @Param("categories") List<String> categories);
    
    @Query("SELECT wr FROM WatchRelease wr WHERE wr.releaseDate >= :date ORDER BY wr.releaseDate ASC")
    List<WatchRelease> findUpcomingReleases(@Param("date") LocalDateTime date);
    
    List<WatchRelease> findByIsLimitedEditionTrue();
}
