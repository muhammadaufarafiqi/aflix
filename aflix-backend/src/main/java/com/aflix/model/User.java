package com.aflix.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity @Table(name = "users")
public class User {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(name = "profile_image")
    private String profileImage;

    @Builder.Default
    @Enumerated(EnumType.STRING) @Column(nullable = false)
    private Role role = Role.USER;

    @Builder.Default
    @Enumerated(EnumType.STRING) @Column(name = "subscription_type", nullable = false)
    private SubscriptionType subscriptionType = SubscriptionType.FREE;

    @Builder.Default
    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(name = "user_watchlist",
            joinColumns = @JoinColumn(name = "user_id"),
            inverseJoinColumns = @JoinColumn(name = "movie_id"))
    private List<Movie> watchlist;

    public enum Role             { USER, ADMIN }
    public enum SubscriptionType { FREE, BASIC, PREMIUM }
}