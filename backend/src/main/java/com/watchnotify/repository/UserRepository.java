package com.watchnotify.repository;

import com.watchnotify.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    Optional<User> findByEmail(String email);
    
    List<User> findByIsActiveTrue();
    
    List<User> findByEmailNotificationsEnabledTrueAndIsActiveTrue();
    
    List<User> findBySmsNotificationsEnabledTrueAndIsActiveTrue();
    
    List<User> findByPushNotificationsEnabledTrueAndIsActiveTrue();
    
    @Query("SELECT u FROM User u WHERE u.isActive = true AND " +
           "(:categories IS NULL OR EXISTS (SELECT p FROM u.preferences p WHERE p IN :categories))")
    List<User> findActiveUsersWithPreferences(@Param("categories") List<String> categories);
    
    @Query("SELECT u FROM User u WHERE u.isActive = true AND " +
           "u.emailNotificationsEnabled = true AND " +
           "(:brands IS NULL OR EXISTS (SELECT p FROM u.preferences p WHERE p IN :brands))")
    List<User> findActiveUsersForEmailNotifications(@Param("brands") List<String> brands);
    
    boolean existsByEmail(String email);
}
