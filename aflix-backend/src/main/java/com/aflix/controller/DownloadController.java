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
@RequestMapping("/api/downloads")
@CrossOrigin(origins = "*")
public class DownloadController {

    @Autowired DownloadRepository downloadRepo;
    @Autowired UserRepository userRepo;
    @Autowired MovieRepository movieRepo;

    // GET: Daftar film yang diunduh user
    @GetMapping
    public List<Movie> getMyDownloads(Authentication auth) {
        User user = userRepo.findByEmail(auth.getName()).orElseThrow();
        return downloadRepo.findByUserId(user.getId())
                .stream()
                .map(Download::getMovie)
                .collect(Collectors.toList());
    }

    // POST: Tambah ke daftar unduhan
    @PostMapping("/{movieId}")
    public ResponseEntity<?> addDownload(@PathVariable Long movieId, Authentication auth) {
        User user = userRepo.findByEmail(auth.getName())
                .orElseThrow(() -> new RuntimeException("User tidak ditemukan"));
        Movie movie = movieRepo.findById(movieId)
                .orElseThrow(() -> new RuntimeException("Film tidak ditemukan"));

        var existing = downloadRepo.findByUserIdAndMovieId(user.getId(), movieId);
        if (existing.isPresent()) {
            return ResponseEntity.ok("Film sudah ada di daftar unduhan");
        }

        Download dl = Download.builder()
                .user(user)
                .movie(movie)
                .status(Download.DownloadStatus.COMPLETED)
                .build();
        downloadRepo.save(dl);
        return ResponseEntity.ok("Berhasil ditambahkan ke daftar unduhan");
    }

    // DELETE: Hapus dari daftar unduhan
    @DeleteMapping("/{movieId}")
    public ResponseEntity<?> removeDownload(@PathVariable Long movieId, Authentication auth) {
        User user = userRepo.findByEmail(auth.getName()).orElseThrow();
        var existing = downloadRepo.findByUserIdAndMovieId(user.getId(), movieId);

        if (existing.isPresent()) {
            downloadRepo.delete(existing.get());
            return ResponseEntity.ok("Berhasil dihapus dari unduhan");
        }
        return ResponseEntity.status(404).body("Data tidak ditemukan");
    }

    // GET: Cek status download film tertentu ✅
    @GetMapping("/{movieId}/status")
    public ResponseEntity<Boolean> checkDownloadStatus(
            @PathVariable Long movieId, Authentication auth) {
        if (auth == null) return ResponseEntity.ok(false);
        User user = userRepo.findByEmail(auth.getName()).orElse(null);
        if (user == null) return ResponseEntity.ok(false);
        boolean exists = downloadRepo.findByUserIdAndMovieId(
                user.getId(), movieId).isPresent();
        return ResponseEntity.ok(exists);
    }
}