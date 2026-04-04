package com.aflix.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

// ── Auth Response (token + user info) ─────────────────
@Data
@AllArgsConstructor
@NoArgsConstructor
public class AuthResponse {

    private String token;
    private Long id;
    private String name;
    private String email;
    private String role;
    private String subscriptionType;
}
