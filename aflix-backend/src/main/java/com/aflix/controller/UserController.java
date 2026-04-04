package com.aflix.controller;

import com.aflix.dto.UserUpdateRequest;
import com.aflix.model.User;
import com.aflix.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private UserRepository userRepo;

    @Autowired
    private PasswordEncoder passwordEncoder;

    /**
     * GET: Ambil profil pengguna yang sedang login.
     * Menggunakan Authentication untuk mengambil email dari token.
     */
    @GetMapping("/me")
    public ResponseEntity<?> getMyProfile(Authentication auth) {
        return userRepo.findByEmail(auth.getName())
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * PUT: Update Profil (Nama, Email, Password, Foto, dll).
     * Method ini menangani konversi String dari DTO ke Enum di Model.
     */
    @PutMapping("/update")
    public ResponseEntity<?> updateProfile(@RequestBody UserUpdateRequest request, Authentication auth) {
        try {
            User user = userRepo.findByEmail(auth.getName())
                    .orElseThrow(() -> new RuntimeException("User tidak ditemukan"));

            // 1. Update Nama (Sesuai field 'name' di DTO & Model)
            if (request.getName() != null && !request.getName().isEmpty()) {
                user.setName(request.getName());
            }

            // 2. Update Email (Hati-hati: Email biasanya digunakan sebagai ID login)
            if (request.getEmail() != null && !request.getEmail().isEmpty()) {
                user.setEmail(request.getEmail());
            }

            // 3. Update Password (Hanya jika field password diisi)
            if (request.getPassword() != null && !request.getPassword().isEmpty()) {
                user.setPassword(passwordEncoder.encode(request.getPassword()));
            }

            // 4. Update Profile Image URL
            if (request.getProfileImage() != null) {
                user.setProfileImage(request.getProfileImage());
            }

            // 5. Update Role (Konversi String "USER"/"ADMIN" ke Enum Role)
            if (request.getRole() != null && !request.getRole().isEmpty()) {
                try {
                    user.setRole(User.Role.valueOf(request.getRole().toUpperCase()));
                } catch (IllegalArgumentException e) {
                    return ResponseEntity.badRequest().body("Role tidak valid");
                }
            }

            // 6. Update Subscription (Konversi String "FREE"/"PREMIUM" ke Enum SubscriptionType)
            if (request.getSubscriptionType() != null && !request.getSubscriptionType().isEmpty()) {
                try {
                    user.setSubscriptionType(User.SubscriptionType.valueOf(request.getSubscriptionType().toUpperCase()));
                } catch (IllegalArgumentException e) {
                    return ResponseEntity.badRequest().body("Tipe langganan tidak valid");
                }
            }

            // Simpan perubahan ke Database MySQL via UserRepository
            userRepo.save(user);

            return ResponseEntity.ok(Map.of("message", "Profil berhasil diperbarui"));

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Gagal memperbarui profil: " + e.getMessage());
        }
    }
}