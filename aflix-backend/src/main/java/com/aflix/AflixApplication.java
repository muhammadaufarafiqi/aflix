package com.aflix;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class AflixApplication {
    public static void main(String[] args) {
        SpringApplication.run(AflixApplication.class, args);
        System.out.println("\n✅ Aflix Backend berjalan di http://localhost:8080");
        System.out.println("   Admin API : http://localhost:8080/api/admin/dashboard");
        System.out.println("   Login     : POST http://localhost:8080/api/auth/login\n");
    }
}
