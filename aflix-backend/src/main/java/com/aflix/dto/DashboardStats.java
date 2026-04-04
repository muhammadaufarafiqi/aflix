package com.aflix.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

// ── Dashboard Stats ───────────────────────────────────
@Data
@AllArgsConstructor
@NoArgsConstructor
public class DashboardStats {

    private long totalUsers;
    private long totalMovies;
    private long premiumUsers;
    private long freeMovies;
    private long premiumMovies;
    private long totalViews;
}
