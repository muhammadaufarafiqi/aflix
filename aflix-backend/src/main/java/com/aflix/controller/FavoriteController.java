package com.aflix.controller;

import com.aflix.model.*;
import com.aflix.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/favorites")
@CrossOrigin(origins = "*")
public class FavoriteController {

    @Autowired FavoriteRepository favRepo;
    @Autowired UserRepository userRepo;
    @Autowired MovieRepository movieRepo;

    // GET: List film favorit saya
    @GetMapping
    public List<Movie> getMyFavorites(Authentication auth) {
        User user = userRepo.findByEmail(auth.getName()).orElseThrow();
        return favRepo.findByUserId(user.getId())
                .stream()
                .map(Favorite::getMovie)
                .collect(Collectors.toList());
    }

    // POST: Tambah atau hapus favorit (Toggle)
    @PostMapping("/{movieId}")
    public ResponseEntity<?> toggleFavorite(@PathVariable Long movieId, Authentication auth) {
        User user = userRepo.findByEmail(auth.getName())
                .orElseThrow(() -> new RuntimeException("User tidak ditemukan"));
        Movie movie = movieRepo.findById(movieId)
                .orElseThrow(() -> new RuntimeException("Film tidak ditemukan"));

        var existing = favRepo.findByUserIdAndMovieId(user.getId(), movieId);

        if (existing.isPresent()) {
            favRepo.delete(existing.get());
            return ResponseEntity.ok("Berhasil dihapus dari favorit");
        } else {
            Favorite fav = Favorite.builder()
                    .user(user)
                    .movie(movie)
                    .build();
            favRepo.save(fav);
            return ResponseEntity.ok("Berhasil ditambahkan ke favorit");
        }
    }

    // GET: Cek status (apakah sudah favorit atau belum)
    @GetMapping("/{movieId}/status")
    public ResponseEntity<Boolean> checkStatus(@PathVariable Long movieId, Authentication auth) {
        User user = userRepo.findByEmail(auth.getName()).orElseThrow();
        boolean isFav = favRepo.findByUserIdAndMovieId(user.getId(), movieId).isPresent();
        return ResponseEntity.ok(isFav);
    }
}