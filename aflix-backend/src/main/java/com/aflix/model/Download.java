package com.aflix.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "downloads")
public class Download {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne
    @JoinColumn(name = "movie_id", nullable = false)
    private Movie movie;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private DownloadStatus status = DownloadStatus.COMPLETED;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    public enum DownloadStatus { PENDING, DOWNLOADING, COMPLETED, FAILED }
}