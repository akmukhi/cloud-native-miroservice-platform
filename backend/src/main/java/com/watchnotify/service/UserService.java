package com.watchnotify.service;

import com.watchnotify.dto.UserDto;
import com.watchnotify.model.User;
import com.watchnotify.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class UserService {
    
    private final UserRepository userRepository;
    
    public List<UserDto> getAllUsers() {
        return userRepository.findAll().stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    public Optional<UserDto> getUserById(Long id) {
        return userRepository.findById(id)
                .map(this::convertToDto);
    }
    
    public Optional<UserDto> getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .map(this::convertToDto);
    }
    
    public UserDto createUser(UserDto userDto) {
        if (userRepository.existsByEmail(userDto.getEmail())) {
            throw new RuntimeException("User with email " + userDto.getEmail() + " already exists");
        }
        
        User user = convertToEntity(userDto);
        User savedUser = userRepository.save(user);
        log.info("Created new user with ID: {}", savedUser.getId());
        return convertToDto(savedUser);
    }
    
    public UserDto updateUser(Long id, UserDto userDto) {
        User existingUser = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + id));
        
        existingUser.setFirstName(userDto.getFirstName());
        existingUser.setLastName(userDto.getLastName());
        existingUser.setEmail(userDto.getEmail());
        existingUser.setPhoneNumber(userDto.getPhoneNumber());
        existingUser.setIsActive(userDto.getIsActive());
        existingUser.setEmailNotificationsEnabled(userDto.getEmailNotificationsEnabled());
        existingUser.setSmsNotificationsEnabled(userDto.getSmsNotificationsEnabled());
        existingUser.setPushNotificationsEnabled(userDto.getPushNotificationsEnabled());
        existingUser.setPreferences(userDto.getPreferences());
        
        User updatedUser = userRepository.save(existingUser);
        log.info("Updated user with ID: {}", updatedUser.getId());
        return convertToDto(updatedUser);
    }
    
    public void deleteUser(Long id) {
        if (!userRepository.existsById(id)) {
            throw new RuntimeException("User not found with ID: " + id);
        }
        userRepository.deleteById(id);
        log.info("Deleted user with ID: {}", id);
    }
    
    public List<UserDto> getActiveUsers() {
        return userRepository.findByIsActiveTrue().stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    public List<UserDto> getUsersForEmailNotifications() {
        return userRepository.findByEmailNotificationsEnabledTrueAndIsActiveTrue().stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    public List<UserDto> getUsersForSmsNotifications() {
        return userRepository.findBySmsNotificationsEnabledTrueAndIsActiveTrue().stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    public List<UserDto> getUsersForPushNotifications() {
        return userRepository.findByPushNotificationsEnabledTrueAndIsActiveTrue().stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    public List<UserDto> getUsersWithPreferences(List<String> categories) {
        return userRepository.findActiveUsersWithPreferences(categories).stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    private UserDto convertToDto(User user) {
        UserDto dto = new UserDto();
        dto.setId(user.getId());
        dto.setFirstName(user.getFirstName());
        dto.setLastName(user.getLastName());
        dto.setEmail(user.getEmail());
        dto.setPhoneNumber(user.getPhoneNumber());
        dto.setIsActive(user.getIsActive());
        dto.setEmailNotificationsEnabled(user.getEmailNotificationsEnabled());
        dto.setSmsNotificationsEnabled(user.getSmsNotificationsEnabled());
        dto.setPushNotificationsEnabled(user.getPushNotificationsEnabled());
        dto.setPreferences(user.getPreferences());
        return dto;
    }
    
    private User convertToEntity(UserDto dto) {
        User user = new User();
        user.setId(dto.getId());
        user.setFirstName(dto.getFirstName());
        user.setLastName(dto.getLastName());
        user.setEmail(dto.getEmail());
        user.setPhoneNumber(dto.getPhoneNumber());
        user.setIsActive(dto.getIsActive());
        user.setEmailNotificationsEnabled(dto.getEmailNotificationsEnabled());
        user.setSmsNotificationsEnabled(dto.getSmsNotificationsEnabled());
        user.setPushNotificationsEnabled(dto.getPushNotificationsEnabled());
        user.setPreferences(dto.getPreferences());
        return user;
    }
}
