package com.aflix.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "movies")
public class Movie {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "thumbnail_url")
    private String thumbnailUrl;

    @Column(name = "banner_url")
    private String bannerUrl;

    @Column(name = "trailer_url")
    private String trailerUrl;

    @Column(name = "full_video_url")
    private String fullVideoUrl;

    @Column(name = "release_year")
    private Integer releaseYear;

    private String duration;
    private Double rating;

    @Column(name = "age_rating")
    private String ageRating;

    @Enumerated(EnumType.STRING)
    @Column(name = "content_type", nullable = false)
    private ContentType contentType = ContentType.MOVIE;

    @Enumerated(EnumType.STRING)
    @Column(name = "content_access", nullable = false)
    private ContentAccess contentAccess = ContentAccess.FREE;

    @Column(name = "is_featured")  private Boolean isFeatured = false;
    @Column(name = "is_trending")  private Boolean isTrending = false;
    @Column(name = "view_count")   private Long    viewCount  = 0L;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(name = "movie_genres",
            joinColumns = @JoinColumn(name = "movie_id"),
            inverseJoinColumns = @JoinColumn(name = "genre_id"))
    private List<Genre> genres;

    public enum ContentType   { MOVIE, SERIES, DOCUMENTARY, ANIME }
    public enum ContentAccess { FREE, PREMIUM }
}