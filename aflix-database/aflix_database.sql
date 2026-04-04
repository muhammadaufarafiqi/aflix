-- ================================================================
--  AFLIX DATABASE - XAMPP MySQL
--  Cara Pakai:
--  1. Buka http://localhost/phpmyadmin
--  2. Klik tab "SQL"
--  3. Paste semua isi file ini → klik Go
-- ================================================================

DROP DATABASE IF EXISTS aflix_db;
CREATE DATABASE aflix_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE aflix_db;

-- ================================================================
-- TABEL USERS
-- ================================================================
CREATE TABLE users (
  id                BIGINT AUTO_INCREMENT PRIMARY KEY,
  name              VARCHAR(100)  NOT NULL,
  email             VARCHAR(150)  NOT NULL UNIQUE,
  password          VARCHAR(255)  NOT NULL,
  profile_image     VARCHAR(500)  DEFAULT NULL,
  role              ENUM('USER','ADMIN') NOT NULL DEFAULT 'USER',
  subscription_type ENUM('FREE','BASIC','PREMIUM') NOT NULL DEFAULT 'FREE',
  created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- TABEL GENRES
-- ================================================================
CREATE TABLE genres (
  id   BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  icon VARCHAR(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- TABEL MOVIES
-- ================================================================
CREATE TABLE movies (
  id             BIGINT AUTO_INCREMENT PRIMARY KEY,
  title          VARCHAR(255) NOT NULL,
  description    TEXT         DEFAULT NULL,
  thumbnail_url  VARCHAR(500) DEFAULT NULL,
  banner_url     VARCHAR(500) DEFAULT NULL,
  trailer_url    VARCHAR(500) DEFAULT NULL,
  full_video_url VARCHAR(500) DEFAULT NULL,
  release_year   INT          DEFAULT NULL,
  duration       VARCHAR(20)  DEFAULT NULL,
  rating         DOUBLE       DEFAULT NULL,
  age_rating     VARCHAR(10)  DEFAULT NULL,
  content_type   ENUM('MOVIE','SERIES','DOCUMENTARY','ANIME') NOT NULL DEFAULT 'MOVIE',
  content_access ENUM('FREE','PREMIUM') NOT NULL DEFAULT 'FREE',
  is_featured    TINYINT(1)   NOT NULL DEFAULT 0,
  is_trending    TINYINT(1)   NOT NULL DEFAULT 0,
  view_count     BIGINT       NOT NULL DEFAULT 0,
  created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- TABEL MOVIE_GENRES (many-to-many)
-- ================================================================
CREATE TABLE movie_genres (
  movie_id BIGINT NOT NULL,
  genre_id BIGINT NOT NULL,
  PRIMARY KEY (movie_id, genre_id),
  FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE,
  FOREIGN KEY (genre_id) REFERENCES genres(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ================================================================
-- TABEL USER_WATCHLIST (many-to-many)
-- ================================================================
CREATE TABLE user_watchlist (
  user_id  BIGINT NOT NULL,
  movie_id BIGINT NOT NULL,
  PRIMARY KEY (user_id, movie_id),
  FOREIGN KEY (user_id)  REFERENCES users(id)  ON DELETE CASCADE,
  FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ================================================================
-- TABEL WATCH_HISTORY
-- ================================================================
CREATE TABLE watch_history (
  id               BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id          BIGINT     NOT NULL,
  movie_id         BIGINT     NOT NULL,
  watched_at       DATETIME   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  progress_seconds BIGINT     NOT NULL DEFAULT 0,
  is_completed     TINYINT(1) NOT NULL DEFAULT 0,
  FOREIGN KEY (user_id)  REFERENCES users(id)  ON DELETE CASCADE,
  FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ================================================================
-- DATA GENRES
-- ================================================================
INSERT INTO genres (name, icon) VALUES
('Action',      '💥'),
('Drama',       '🎭'),
('Comedy',      '😂'),
('Horror',      '👻'),
('Sci-Fi',      '🚀'),
('Romance',     '❤️'),
('Documentary', '📹'),
('Animation',   '🎨'),
('Thriller',    '😱'),
('Fantasy',     '🧙');

-- ================================================================
-- DATA USERS
-- Password BCrypt:
--   admin123  → admin@aflix.com
--   demo123   → demo@aflix.com
--   user123   → user@aflix.com
-- ================================================================
INSERT INTO users (name, email, password, role, subscription_type) VALUES
('Admin Aflix',  'admin@aflix.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ADMIN', 'PREMIUM'),
('Demo User',    'demo@aflix.com',  '$2a$10$EblZqNptyYvcLm/VwDCVAuBjzZOI7khzdyGPBr08PkiqtWZpyPeSS', 'USER',  'FREE'),
('Premium User', 'user@aflix.com',  '$2a$10$2gkZkSz.kMXJpAzF1jnpg.xXL4a9y1GQx8zEkVH4u7n4dZL4AGKZK', 'USER',  'PREMIUM');

-- ================================================================
-- DATA MOVIES (10 film, video dari Google CDN - selalu online)
-- ================================================================
INSERT INTO movies (title, description, thumbnail_url, banner_url, trailer_url, full_video_url, release_year, duration, rating, age_rating, content_type, content_access, is_featured, is_trending, view_count) VALUES
('Big Buck Bunny',
 'Kelinci besar dan penyayang menghadapi gangguan dari makhluk hutan kecil. Animasi open-source legendaris dari Blender Foundation.',
 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Big_buck_bunny_poster_big.jpg/220px-Big_buck_bunny_poster_big.jpg',
 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Big_buck_bunny_poster_big.jpg/800px-Big_buck_bunny_poster_big.jpg',
 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
 2008, '9:56', 8.5, 'G', 'MOVIE', 'FREE', 1, 1, 152000),

('Elephant Dream',
 'Dua orang menjelajahi dunia mimpi yang aneh dan penuh kejutan. Film animasi open-source pertama dari Blender.',
 'https://orange.blender.org/wp-content/themes/orange/images/media/elephants_dream_stills_01.jpg',
 'https://orange.blender.org/wp-content/themes/orange/images/media/elephants_dream_stills_01.jpg',
 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
 2006, '10:54', 7.8, 'PG', 'MOVIE', 'FREE', 1, 0, 89000),

('Tears of Steel',
 'Sekelompok pejuang mencoba melawan pasukan robot untuk menyelamatkan masa depan. Visual efek memukau.',
 'https://mango.blender.org/wp-content/gallery/4k-renders/05_thom_constable.jpg',
 'https://mango.blender.org/wp-content/gallery/4k-renders/05_thom_constable.jpg',
 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
 2012, '12:14', 8.1, 'PG-13', 'MOVIE', 'PREMIUM', 1, 1, 210000),

('For Bigger Blazes',
 'Aksi menegangkan dengan visual memukau dan ketegangan yang terus meningkat sepanjang film.',
 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg',
 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg',
 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
 2013, '0:15', 7.2, 'PG-13', 'MOVIE', 'FREE', 0, 1, 45000),

('For Bigger Escapes',
 'Petualangan seru penuh kejutan dengan aksi non-stop yang bikin kamu terpaku di layar.',
 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg',
 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg',
 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
 2013, '0:15', 7.0, 'PG', 'MOVIE', 'FREE', 0, 1, 38000),

('For Bigger Fun',
 'Komedi ringan yang menghibur dengan karakter-karakter lucu dan alur cerita menyenangkan.',
 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerFun.jpg',
 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerFun.jpg',
 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
 2013, '1:00', 6.8, 'G', 'MOVIE', 'FREE', 0, 0, 29000),

('For Bigger Joyrides',
 'Perjalanan seru penuh adrenalin dengan pemandangan indah dan momen tak terlupakan.',
 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerJoyrides.jpg',
 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerJoyrides.jpg',
 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
 2013, '0:15', 7.4, 'G', 'MOVIE', 'FREE', 0, 1, 55000),

('Subaru Outback Adventure',
 'Dokumenter visual perjalanan melintasi alam bebas dengan semangat petualangan yang membara.',
 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/SubaruOutbackOnStreetAndDirt.jpg',
 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/SubaruOutbackOnStreetAndDirt.jpg',
 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
 2013, '1:00', 6.5, 'G', 'DOCUMENTARY', 'FREE', 0, 0, 32000),

('Volkswagen GTI Review',
 'Review mendalam performa dan desain Volkswagen GTI. Dokumenter otomotif berkualitas tinggi.',
 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/VolkswagenGTIReview.jpg',
 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/VolkswagenGTIReview.jpg',
 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4',
 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4',
 2013, '1:00', 6.9, 'G', 'DOCUMENTARY', 'FREE', 0, 0, 21000),

('We Are Going On Bullrun',
 'Ikuti perjalanan epik Bullrun - balapan lintas negara penuh semangat dan persahabatan.',
 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/WeAreGoingOnBullrun.jpg',
 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/WeAreGoingOnBullrun.jpg',
 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
 2013, '1:00', 7.1, 'G', 'DOCUMENTARY', 'PREMIUM', 1, 0, 67000);

-- ================================================================
-- DATA MOVIE_GENRES
-- ================================================================
INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.id FROM movies m JOIN genres g ON (
  (m.title='Big Buck Bunny'         AND g.name IN ('Animation','Comedy'))  OR
  (m.title='Elephant Dream'         AND g.name IN ('Animation','Fantasy')) OR
  (m.title='Tears of Steel'         AND g.name IN ('Action','Sci-Fi'))     OR
  (m.title='For Bigger Blazes'      AND g.name IN ('Action','Thriller'))   OR
  (m.title='For Bigger Escapes'     AND g.name IN ('Action','Thriller'))   OR
  (m.title='For Bigger Fun'         AND g.name IN ('Comedy'))              OR
  (m.title='For Bigger Joyrides'    AND g.name IN ('Action'))              OR
  (m.title='Subaru Outback Adventure' AND g.name IN ('Documentary'))       OR
  (m.title='Volkswagen GTI Review'  AND g.name IN ('Documentary'))         OR
  (m.title='We Are Going On Bullrun' AND g.name IN ('Documentary','Action'))
);

-- ================================================================
-- VERIFIKASI
-- ================================================================
SELECT CONCAT('✅ Users   : ', COUNT(*)) AS status FROM users   UNION ALL
SELECT CONCAT('✅ Movies  : ', COUNT(*))            FROM movies  UNION ALL
SELECT CONCAT('✅ Genres  : ', COUNT(*))            FROM genres;

SELECT '----------------------------------------' AS '';
SELECT '  Login Admin  : admin@aflix.com / admin123' AS 'Akun';
SELECT '  Login Demo   : demo@aflix.com  / demo123'  AS 'Akun';
SELECT '  Login Premium: user@aflix.com  / user123'  AS 'Akun';
SELECT '----------------------------------------' AS '';
