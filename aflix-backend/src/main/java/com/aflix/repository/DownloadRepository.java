package com.aflix.repository;

import com.aflix.model.Download;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface DownloadRepository extends JpaRepository<Download, Long> {

    // Ambil semua daftar download milik user tertentu
    List<Download> findByUserId(Long userId);

    // Cek apakah film ini sudah ada di daftar download user
    Optional<Download> findByUserIdAndMovieId(Long userId, Long movieId);
}