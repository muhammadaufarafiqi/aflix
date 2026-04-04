package com.aflix.controller;

import com.aflix.dto.AuthRequest;
import com.aflix.dto.AuthResponse;
import com.aflix.dto.RegisterRequest;
import com.aflix.model.User;
import com.aflix.repository.UserRepository;
import com.aflix.security.JwtUtils;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired AuthenticationManager authManager;
    @Autowired UserRepository        userRepo;
    @Autowired PasswordEncoder       encoder;
    @Autowired JwtUtils              jwt;

    // ── REGISTER ──────────────────────────────────────────
    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest req) {
        System.out.println("DEBUG: Menerima request register untuk email: " + req.getEmail());

        if (userRepo.existsByEmail(req.getEmail())) {
            System.out.println("DEBUG: Gagal, email sudah ada di database.");
            return ResponseEntity.badRequest().body("Email sudah terdaftar");
        }

        try {
            var user = User.builder()
                    .name(req.getName())
                    .email(req.getEmail())
                    .password(encoder.encode(req.getPassword()))
                    .role(User.Role.USER)
                    .subscriptionType(User.SubscriptionType.FREE)
                    .build();

            System.out.println("DEBUG: Mencoba menyimpan user ke database...");
            User savedUser = userRepo.save(user);
            System.out.println("DEBUG: Berhasil simpan user dengan ID: " + savedUser.getId());

            String token = jwt.generateToken(savedUser.getEmail());

            return ResponseEntity.ok(new AuthResponse(
                    token,
                    savedUser.getId(),
                    savedUser.getName(),
                    savedUser.getEmail(),
                    savedUser.getRole().name(),
                    savedUser.getSubscriptionType().name()
            ));
        } catch (Exception e) {
            System.out.println("DEBUG: Error saat menyimpan ke database: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Gagal menyimpan data ke database");
        }
    }

    // ── LOGIN ─────────────────────────────────────────────
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody AuthRequest req) {
        try {
            authManager.authenticate(
                    new UsernamePasswordAuthenticationToken(req.getEmail(), req.getPassword()));

            var user = userRepo.findByEmail(req.getEmail()).orElseThrow();
            return ResponseEntity.ok(new AuthResponse(
                    jwt.generateToken(user.getEmail()),
                    user.getId(), user.getName(), user.getEmail(),
                    user.getRole().name(), user.getSubscriptionType().name()
            ));
        } catch (BadCredentialsException e) {
            return ResponseEntity.status(401).body("Email atau password salah");
        }
    }
}