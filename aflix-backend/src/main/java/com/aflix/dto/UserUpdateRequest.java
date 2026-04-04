package com.aflix.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO untuk menangani permintaan pembaruan data pengguna (User Update).
 * Field 'name' disamakan dengan field di Model User agar tidak terjadi error method.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserUpdateRequest {

    private String name;             // Nama lengkap (Sesuai model User)
    private String email;            // Alamat email pengguna
    private String password;         // Password baru jika ingin diubah
    private String profileImage;      // URL atau base64 foto profil
    private String role;             // Role user (USER/ADMIN)
    private String subscriptionType; // Tipe langganan (FREE/PREMIUM)

}