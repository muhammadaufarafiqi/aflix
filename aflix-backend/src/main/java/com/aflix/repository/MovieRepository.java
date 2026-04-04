package com.aflix.repository;

import com.aflix.model.Movie;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface MovieRepository extends JpaRepository<Movie, Long> {
    List<Movie> findByIsFeaturedTrue();
    List<Movie> findByIsTrendingTrue();
    List<Movie> findByContentType(Movie.ContentType type);
    List<Movie> findTop10ByOrderByViewCountDesc();
    List<Movie> findTop10ByOrderByCreatedAtDesc();
    long countByContentAccess(Movie.ContentAccess access);

    @Query("SELECT m FROM Movie m WHERE " +
           "LOWER(m.title) LIKE LOWER(CONCAT('%',:q,'%')) OR " +
           "LOWER(m.description) LIKE LOWER(CONCAT('%',:q,'%'))")
    List<Movie> search(@Param("q") String q);

    @Query("SELECT m FROM Movie m JOIN m.genres g WHERE g.name = :genre")
    List<Movie> findByGenreName(@Param("genre") String genre);
}
