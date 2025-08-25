package com.watchnotify.config;

import com.watchnotify.model.User;
import com.watchnotify.model.WatchRelease;
import com.watchnotify.repository.UserRepository;
import com.watchnotify.repository.WatchReleaseRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

@Component
@RequiredArgsConstructor
@Slf4j
@Profile("!prod")
public class DataLoader implements CommandLineRunner {
    
    private final UserRepository userRepository;
    private final WatchReleaseRepository watchReleaseRepository;
    
    @Override
    public void run(String... args) throws Exception {
        log.info("Loading sample data...");
        
        // Create sample users
        createSampleUsers();
        
        // Create sample watch releases
        createSampleWatchReleases();
        
        log.info("Sample data loaded successfully!");
    }
    
    private void createSampleUsers() {
        if (userRepository.count() > 0) {
            log.info("Users already exist, skipping user creation");
            return;
        }
        
        User user1 = new User();
        user1.setFirstName("John");
        user1.setLastName("Doe");
        user1.setEmail("john.doe@example.com");
        user1.setPhoneNumber("+1234567890");
        user1.setIsActive(true);
        user1.setEmailNotificationsEnabled(true);
        user1.setSmsNotificationsEnabled(false);
        user1.setPushNotificationsEnabled(true);
        user1.setPreferences(new HashSet<>(Arrays.asList("luxury", "automatic", "swiss")));
        userRepository.save(user1);
        
        User user2 = new User();
        user2.setFirstName("Jane");
        user2.setLastName("Smith");
        user2.setEmail("jane.smith@example.com");
        user2.setPhoneNumber("+1987654321");
        user2.setIsActive(true);
        user2.setEmailNotificationsEnabled(true);
        user2.setSmsNotificationsEnabled(true);
        user2.setPushNotificationsEnabled(true);
        user2.setPreferences(new HashSet<>(Arrays.asList("sport", "quartz", "japanese")));
        userRepository.save(user2);
        
        User user3 = new User();
        user3.setFirstName("Mike");
        user3.setLastName("Johnson");
        user3.setEmail("mike.johnson@example.com");
        user3.setPhoneNumber("+1555123456");
        user3.setIsActive(true);
        user3.setEmailNotificationsEnabled(false);
        user3.setSmsNotificationsEnabled(true);
        user3.setPushNotificationsEnabled(true);
        user3.setPreferences(new HashSet<>(Arrays.asList("dive", "automatic", "german")));
        userRepository.save(user3);
        
        log.info("Created {} sample users", userRepository.count());
    }
    
    private void createSampleWatchReleases() {
        if (watchReleaseRepository.count() > 0) {
            log.info("Watch releases already exist, skipping watch release creation");
            return;
        }
        
        // Sample 1: Luxury Swiss Watch
        WatchRelease release1 = new WatchRelease();
        release1.setWatchName("Chronograph Master");
        release1.setBrand("Swiss Luxury");
        release1.setModelNumber("SL-2024-001");
        release1.setDescription("A premium automatic chronograph with moon phase complication");
        release1.setReleaseDate(LocalDateTime.now().plusDays(7));
        release1.setPrice(new BigDecimal("8500.00"));
        release1.setCurrency("USD");
        release1.setFeatures(new HashSet<>(Arrays.asList("automatic", "chronograph", "moon-phase", "sapphire-crystal")));
        release1.setCategories(new HashSet<>(Arrays.asList("luxury", "swiss", "automatic")));
        release1.setImageUrl("https://example.com/images/chronograph-master.jpg");
        release1.setProductUrl("https://example.com/watches/chronograph-master");
        release1.setIsLimitedEdition(true);
        release1.setLimitedQuantity(500);
        release1.setIsNotified(false);
        watchReleaseRepository.save(release1);
        
        // Sample 2: Sport Watch
        WatchRelease release2 = new WatchRelease();
        release2.setWatchName("Dive Pro 300");
        release2.setBrand("SportTech");
        release2.setModelNumber("ST-DP300-2024");
        release2.setDescription("Professional diving watch with 300m water resistance");
        release2.setReleaseDate(LocalDateTime.now().plusDays(3));
        release2.setPrice(new BigDecimal("1200.00"));
        release2.setCurrency("USD");
        release2.setFeatures(new HashSet<>(Arrays.asList("quartz", "dive", "luminous", "rotating-bezel")));
        release2.setCategories(new HashSet<>(Arrays.asList("sport", "dive", "quartz")));
        release2.setImageUrl("https://example.com/images/dive-pro-300.jpg");
        release2.setProductUrl("https://example.com/watches/dive-pro-300");
        release2.setIsLimitedEdition(false);
        release2.setIsNotified(false);
        watchReleaseRepository.save(release2);
        
        // Sample 3: Japanese Automatic
        WatchRelease release3 = new WatchRelease();
        release3.setWatchName("Seiko Presage");
        release3.setBrand("Seiko");
        release3.setModelNumber("SPB123J1");
        release3.setDescription("Elegant automatic watch with enamel dial");
        release3.setReleaseDate(LocalDateTime.now().minusDays(1));
        release3.setPrice(new BigDecimal("650.00"));
        release3.setCurrency("USD");
        release3.setFeatures(new HashSet<>(Arrays.asList("automatic", "enamel-dial", "sapphire-crystal", "date")));
        release3.setCategories(new HashSet<>(Arrays.asList("japanese", "automatic", "dress")));
        release3.setImageUrl("https://example.com/images/seiko-presage.jpg");
        release3.setProductUrl("https://example.com/watches/seiko-presage");
        release3.setIsLimitedEdition(false);
        release3.setIsNotified(false);
        watchReleaseRepository.save(release3);
        
        // Sample 4: German Precision
        WatchRelease release4 = new WatchRelease();
        release4.setWatchName("Precision Master");
        release4.setBrand("German Craft");
        release4.setModelNumber("GC-PM-2024");
        release4.setDescription("High-precision automatic movement with power reserve indicator");
        release4.setReleaseDate(LocalDateTime.now().plusDays(14));
        release4.setPrice(new BigDecimal("3200.00"));
        release4.setCurrency("USD");
        release4.setFeatures(new HashSet<>(Arrays.asList("automatic", "power-reserve", "german-movement", "sapphire-crystal")));
        release4.setCategories(new HashSet<>(Arrays.asList("german", "automatic", "luxury")));
        release4.setImageUrl("https://example.com/images/precision-master.jpg");
        release4.setProductUrl("https://example.com/watches/precision-master");
        release4.setIsLimitedEdition(true);
        release4.setLimitedQuantity(200);
        release4.setIsNotified(false);
        watchReleaseRepository.save(release4);
        
        log.info("Created {} sample watch releases", watchReleaseRepository.count());
    }
}
