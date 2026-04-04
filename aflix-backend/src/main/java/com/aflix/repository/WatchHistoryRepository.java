package com.aflix.repository;

import com.aflix.model.WatchHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface WatchHistoryRepository extends JpaRepository<WatchHistory, Long> {
    List<WatchHistory> findByUserIdOrderByWatchedAtDesc(Long userId);
    Optional<WatchHistory> findByUserIdAndMovieId(Long userId, Long movieId);
}
