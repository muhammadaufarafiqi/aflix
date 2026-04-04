package com.aflix.repository;

import com.aflix.model.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface FavoriteRepository extends JpaRepository<Favorite, Long> {

    // Untuk mengambil daftar film yang disukai user tertentu
    List<Favorite> findByUserId(Long userId);

    // Untuk mengecek apakah film sudah ada di daftar favorit user tersebut
    Optional<Favorite> findByUserIdAndMovieId(Long userId, Long movieId);
}