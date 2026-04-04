package com.aflix.dto;

import jakarta.validation.constraints.*;
import lombok.Data;
import java.util.List;

@Data
public class MovieRequest {

    @NotBlank(message = "Judul tidak boleh kosong")
    private String title;

    private String description;

    @NotBlank(message = "Thumbnail URL diperlukan untuk tampilan dashboard")
    private String thumbnailUrl;

    @NotBlank(message = "Banner URL diperlukan untuk tampilan detail")
    private String bannerUrl;

    private String trailerUrl;

    @NotBlank(message = "Full Video URL diperlukan untuk player")
    private String fullVideoUrl;

    private Integer releaseYear;
    private String duration;
    private Double rating;
    private String ageRating;

    private String contentType;    // MOVIE, SERIES, dsb.
    private String contentAccess;  // FREE, PREMIUM

    private Boolean isFeatured = false;
    private Boolean isTrending = false;

    private List<Long> genreIds;
}