package com.aflix.controller;

import com.aflix.dto.*;
import com.aflix.model.*;
import com.aflix.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.List;

/**
 * AdminController — semua endpoint di sini hanya bisa diakses oleh ADMIN
 * Base URL: /api/admin
 */
@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    @Autowired UserRepository        userRepo;
    @Autowired MovieRepository       movieRepo;
    @Autowired GenreRepository       genreRepo;
    @Autowired WatchHistoryRepository historyRepo;

    // ════════════════════════════════════════════
    // DASHBOARD STATS
    // ════════════════════════════════════════════

    @GetMapping("/dashboard")
    public DashboardStats getDashboard() {
        long totalViews = movieRepo.findAll().stream()
            .mapToLong(m -> m.getViewCount() != null ? m.getViewCount() : 0L).sum();
        return new DashboardStats(
            userRepo.count(),
            movieRepo.count(),
            userRepo.countBySubscriptionType(User.SubscriptionType.PREMIUM),
            movieRepo.countByContentAccess(Movie.ContentAccess.FREE),
            movieRepo.countByContentAccess(Movie.ContentAccess.PREMIUM),
            totalViews
        );
    }

    // ════════════════════════════════════════════
    // USERS — CRUD
    // ════════════════════════════════════════════

    /** GET semua user */
    @GetMapping("/users")
    public List<User> getAllUsers() { return userRepo.findAll(); }

    /** GET user by id */
    @GetMapping("/users/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        return userRepo.findById(id).map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    /** UPDATE user (nama, email, role, subscription) */
    @PutMapping("/users/{id}")
    public ResponseEntity<?> updateUser(@PathVariable Long id,
                                         @RequestBody UserUpdateRequest req) {
        return userRepo.findById(id).map(u -> {
            if (req.getName()  != null) u.setName(req.getName());
            if (req.getEmail() != null) u.setEmail(req.getEmail());
            if (req.getRole()  != null) {
                try { u.setRole(User.Role.valueOf(req.getRole().toUpperCase())); }
                catch (Exception e) { return ResponseEntity.badRequest().body("Role tidak valid"); }
            }
            if (req.getSubscriptionType() != null) {
                try { u.setSubscriptionType(User.SubscriptionType.valueOf(
                    req.getSubscriptionType().toUpperCase())); }
                catch (Exception e) { return ResponseEntity.badRequest().body("Subscription tidak valid"); }
            }
            return ResponseEntity.ok(userRepo.save(u));
        }).orElse(ResponseEntity.notFound().build());
    }

    /** DELETE user */
    @DeleteMapping("/users/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable Long id) {
        if (!userRepo.existsById(id)) return ResponseEntity.notFound().build();
        userRepo.deleteById(id);
        return ResponseEntity.ok("User berhasil dihapus");
    }

    /** Upgrade / downgrade subscription cepat */
    @PutMapping("/users/{id}/subscription")
    public ResponseEntity<?> changeSubscription(@PathVariable Long id,
                                                  @RequestParam String type) {
        return userRepo.findById(id).map(u -> {
            try {
                u.setSubscriptionType(User.SubscriptionType.valueOf(type.toUpperCase()));
                return ResponseEntity.ok(userRepo.save(u));
            } catch (Exception e) {
                return ResponseEntity.badRequest().body("Tipe tidak valid: FREE / BASIC / PREMIUM");
            }
        }).orElse(ResponseEntity.notFound().build());
    }

    /** Ganti role user */
    @PutMapping("/users/{id}/role")
    public ResponseEntity<?> changeRole(@PathVariable Long id, @RequestParam String role) {
        return userRepo.findById(id).map(u -> {
            try {
                u.setRole(User.Role.valueOf(role.toUpperCase()));
                return ResponseEntity.ok(userRepo.save(u));
            } catch (Exception e) {
                return ResponseEntity.badRequest().body("Role tidak valid: USER / ADMIN");
            }
        }).orElse(ResponseEntity.notFound().build());
    }

    // ════════════════════════════════════════════
    // MOVIES — READ (CRUD ada di MovieController)
    // ════════════════════════════════════════════

    @GetMapping("/movies")
    public List<Movie> getAllMovies() { return movieRepo.findAll(); }

    // ════════════════════════════════════════════
    // GENRES — CRUD
    // ════════════════════════════════════════════

    @GetMapping("/genres")
    public List<Genre> getAllGenres() { return genreRepo.findAll(); }

    @PostMapping("/genres")
    public ResponseEntity<Genre> createGenre(@RequestBody Genre genre) {
        return ResponseEntity.ok(genreRepo.save(genre));
    }

    @PutMapping("/genres/{id}")
    public ResponseEntity<?> updateGenre(@PathVariable Long id, @RequestBody Genre updated) {
        return genreRepo.findById(id).map(g -> {
            g.setName(updated.getName());
            g.setIcon(updated.getIcon());
            return ResponseEntity.ok(genreRepo.save(g));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/genres/{id}")
    public ResponseEntity<?> deleteGenre(@PathVariable Long id) {
        if (!genreRepo.existsById(id)) return ResponseEntity.notFound().build();
        genreRepo.deleteById(id);
        return ResponseEntity.ok("Genre dihapus");
    }

    // ════════════════════════════════════════════
    // WATCH HISTORY
    // ════════════════════════════════════════════

    @GetMapping("/history")
    public List<WatchHistory> getAllHistory() { return historyRepo.findAll(); }

    @GetMapping("/history/user/{userId}")
    public List<WatchHistory> getUserHistory(@PathVariable Long userId) {
        return historyRepo.findByUserIdOrderByWatchedAtDesc(userId);
    }
}
