package com.aflix.controller;

import com.aflix.dto.MovieRequest;
import com.aflix.model.*;
import com.aflix.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/movies")
@CrossOrigin(origins = "*")
public class MovieController {

    @Autowired MovieRepository movieRepo;
    @Autowired GenreRepository genreRepo;
    @Autowired UserRepository userRepo;
    @Autowired WatchHistoryRepository historyRepo;

    // --- PUBLIC ENDPOINTS ---

    @GetMapping
    public List<Movie> getAll() {
        return movieRepo.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Movie> getById(@PathVariable Long id) {
        return movieRepo.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/featured")
    public List<Movie> getFeatured() {
        return movieRepo.findByIsFeaturedTrue();
    }

    @GetMapping("/trending")
    public List<Movie> getTrending() {
        return movieRepo.findByIsTrendingTrue();
    }

    @GetMapping("/search")
    public List<Movie> search(@RequestParam String q) {
        return movieRepo.search(q);
    }

    // --- TRACKING VIEW COUNT ---

    @PostMapping("/{id}/view")
    public ResponseEntity<?> trackView(@PathVariable Long id, Authentication auth) {
        movieRepo.findById(id).ifPresent(m -> {
            m.setViewCount(m.getViewCount() == null ? 1L : m.getViewCount() + 1);
            movieRepo.save(m);
            if (auth != null) {
                userRepo.findByEmail(auth.getName()).ifPresent(user -> {
                    WatchHistory hist = historyRepo.findByUserIdAndMovieId(user.getId(), id)
                            .orElse(WatchHistory.builder().user(user).movie(m).build());
                    hist.setWatchedAt(LocalDateTime.now());
                    historyRepo.save(hist);
                });
            }
        });
        return ResponseEntity.ok().build();
    }

    // --- ADMIN CRUD ---

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Movie> create(@RequestBody MovieRequest req) {
        Movie movie = fromRequest(new Movie(), req);
        movie.setCreatedAt(LocalDateTime.now());
        return ResponseEntity.ok(movieRepo.save(movie));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Movie> update(@PathVariable Long id, @RequestBody MovieRequest req) {
        return movieRepo.findById(id)
                .map(m -> ResponseEntity.ok(movieRepo.save(fromRequest(m, req))))
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        if (!movieRepo.existsById(id)) return ResponseEntity.notFound().build();
        movieRepo.deleteById(id);
        return ResponseEntity.ok("Film berhasil dihapus");
    }

    // --- HELPER MAPPING (PENGHUBUNG REQUEST KE MODEL) ---
    private Movie fromRequest(Movie m, MovieRequest r) {
        if (r.getTitle() != null) m.setTitle(r.getTitle());
        if (r.getDescription() != null) m.setDescription(r.getDescription());
        if (r.getThumbnailUrl() != null) m.setThumbnailUrl(r.getThumbnailUrl());
        if (r.getBannerUrl() != null) m.setBannerUrl(r.getBannerUrl());
        if (r.getTrailerUrl() != null) m.setTrailerUrl(r.getTrailerUrl());
        if (r.getFullVideoUrl() != null) m.setFullVideoUrl(r.getFullVideoUrl());
        if (r.getReleaseYear() != null) m.setReleaseYear(r.getReleaseYear());
        if (r.getDuration() != null) m.setDuration(r.getDuration());
        if (r.getRating() != null) m.setRating(r.getRating());
        if (r.getAgeRating() != null) m.setAgeRating(r.getAgeRating());

        m.setIsFeatured(r.getIsFeatured() != null && r.getIsFeatured());
        m.setIsTrending(r.getIsTrending() != null && r.getIsTrending());

        // Konversi String ke Enum ContentType
        try {
            if (r.getContentType() != null)
                m.setContentType(Movie.ContentType.valueOf(r.getContentType().toUpperCase()));
        } catch (Exception ignored) {}

        // Konversi String ke Enum ContentAccess
        try {
            if (r.getContentAccess() != null)
                m.setContentAccess(Movie.ContentAccess.valueOf(r.getContentAccess().toUpperCase()));
        } catch (Exception ignored) {}

        // Mapping Genre berdasarkan GenreIds
        if (r.getGenreIds() != null) {
            List<Genre> genres = r.getGenreIds().stream()
                    .map(gid -> genreRepo.findById(gid).orElse(null))
                    .filter(g -> g != null)
                    .collect(Collectors.toList());
            m.setGenres(genres);
        }
        return m;
    }
}