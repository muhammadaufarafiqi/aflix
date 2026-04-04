package com.aflix.controller;

import com.aflix.model.Genre;
import com.aflix.repository.GenreRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/genres")
@CrossOrigin(origins = "*")
public class GenreController {
    @Autowired GenreRepository genreRepo;

    @GetMapping
    public List<Genre> getAll() { return genreRepo.findAll(); }

    @GetMapping("/{id}")
    public ResponseEntity<Genre> getById(@PathVariable Long id) {
        return genreRepo.findById(id).map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
}
