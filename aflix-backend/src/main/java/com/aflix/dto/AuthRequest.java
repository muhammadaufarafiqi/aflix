package com.aflix.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

// ── Login Request ─────────────────────────────────────
@Data
public class AuthRequest {

    @NotBlank
    @Email
    private String email;

    @NotBlank
    private String password;
}
