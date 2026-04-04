package com.aflix.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity @Table(name = "watch_history")
public class WatchHistory {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @ManyToOne @JoinColumn(name = "user_id",  nullable = false) private User  user;
    @ManyToOne @JoinColumn(name = "movie_id", nullable = false) private Movie movie;
    @Column(name = "watched_at")       private LocalDateTime watchedAt = LocalDateTime.now();
    @Column(name = "progress_seconds") private Long progressSeconds    = 0L;
    @Column(name = "is_completed")     private Boolean isCompleted     = false;
}
