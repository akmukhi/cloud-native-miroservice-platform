package com.watchnotify.controller;

import com.watchnotify.dto.UserDto;
import com.watchnotify.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class UserController {
    
    private final UserService userService;
    
    @GetMapping
    public ResponseEntity<List<UserDto>> getAllUsers() {
        List<UserDto> users = userService.getAllUsers();
        return ResponseEntity.ok(users);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<UserDto> getUserById(@PathVariable Long id) {
        Optional<UserDto> user = userService.getUserById(id);
        return user.map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/email/{email}")
    public ResponseEntity<UserDto> getUserByEmail(@PathVariable String email) {
        Optional<UserDto> user = userService.getUserByEmail(email);
        return user.map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @PostMapping
    public ResponseEntity<UserDto> createUser(@Valid @RequestBody UserDto userDto) {
        try {
            UserDto createdUser = userService.createUser(userDto);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdUser);
        } catch (RuntimeException e) {
            log.error("Error creating user: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<UserDto> updateUser(@PathVariable Long id, @Valid @RequestBody UserDto userDto) {
        try {
            UserDto updatedUser = userService.updateUser(id, userDto);
            return ResponseEntity.ok(updatedUser);
        } catch (RuntimeException e) {
            log.error("Error updating user: {}", e.getMessage());
            return ResponseEntity.notFound().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        try {
            userService.deleteUser(id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            log.error("Error deleting user: {}", e.getMessage());
            return ResponseEntity.notFound().build();
        }
    }
    
    @GetMapping("/active")
    public ResponseEntity<List<UserDto>> getActiveUsers() {
        List<UserDto> activeUsers = userService.getActiveUsers();
        return ResponseEntity.ok(activeUsers);
    }
    
    @GetMapping("/email-notifications")
    public ResponseEntity<List<UserDto>> getUsersForEmailNotifications() {
        List<UserDto> users = userService.getUsersForEmailNotifications();
        return ResponseEntity.ok(users);
    }
    
    @GetMapping("/sms-notifications")
    public ResponseEntity<List<UserDto>> getUsersForSmsNotifications() {
        List<UserDto> users = userService.getUsersForSmsNotifications();
        return ResponseEntity.ok(users);
    }
    
    @GetMapping("/push-notifications")
    public ResponseEntity<List<UserDto>> getUsersForPushNotifications() {
        List<UserDto> users = userService.getUsersForPushNotifications();
        return ResponseEntity.ok(users);
    }
    
    @GetMapping("/preferences")
    public ResponseEntity<List<UserDto>> getUsersWithPreferences(@RequestParam List<String> categories) {
        List<UserDto> users = userService.getUsersWithPreferences(categories);
        return ResponseEntity.ok(users);
    }
}
