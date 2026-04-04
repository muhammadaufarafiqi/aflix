package com.aflix.controller;

import org.springframework.core.io.*;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import java.io.IOException;
import java.nio.file.*;

@RestController
@RequestMapping("/api/stream")
@CrossOrigin(origins = "*")
public class StreamController {

    private static final String VIDEO_DIR = "./uploads/videos/";

    @GetMapping("/{filename}")
    public ResponseEntity<Resource> stream(
            @PathVariable String filename,
            @RequestHeader(value = "Range", required = false) String rangeHeader) {
        try {
            Path path = Paths.get(VIDEO_DIR + filename);
            Resource res = new UrlResource(path.toUri());
            if (!res.exists()) return ResponseEntity.notFound().build();

            long fileSize = res.contentLength();
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.valueOf("video/mp4"));
            headers.add("Accept-Ranges", "bytes");

            if (rangeHeader == null) {
                headers.setContentLength(fileSize);
                return ResponseEntity.ok().headers(headers).body(res);
            }

            // Parse range header: "bytes=0-1048575"
            String[] parts = rangeHeader.replace("bytes=", "").split("-");
            long start = Long.parseLong(parts[0]);
            long end   = (parts.length > 1 && !parts[1].isEmpty())
                ? Long.parseLong(parts[1])
                : Math.min(start + 1_048_576L, fileSize - 1); // chunk 1MB

            headers.add("Content-Range", "bytes " + start + "-" + end + "/" + fileSize);
            headers.setContentLength(end - start + 1);

            return ResponseEntity.status(HttpStatus.PARTIAL_CONTENT)
                .headers(headers).body(res);
        } catch (IOException e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}
