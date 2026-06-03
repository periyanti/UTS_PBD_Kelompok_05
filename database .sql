-- ============================================================
-- FILE: database.sql
-- Projek UTS Pemrograman Basis Data
-- Sistem Rekap Nilai Praktikum Mahasiswa
-- ============================================================

-- Buat dan gunakan database
CREATE DATABASE IF NOT EXISTS uts_pbd_kelompok_05;
USE uts_pbd_kelompok_05;

-- ============================================================
-- TABEL 1: dosen
-- ============================================================
CREATE TABLE dosen (
    kode_dosen  VARCHAR(10)  NOT NULL,
    nama_dosen  VARCHAR(100) NOT NULL,
    email       VARCHAR(100) NOT NULL,
    PRIMARY KEY (kode_dosen)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABEL 2: mahasiswa
-- ============================================================
CREATE TABLE mahasiswa (
    nim      VARCHAR(15)  NOT NULL,
    nama     VARCHAR(100) NOT NULL,
    kelas    VARCHAR(10)  NOT NULL,
    angkatan YEAR         NOT NULL,
    PRIMARY KEY (nim)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABEL 3: mata_kuliah
-- ============================================================
CREATE TABLE mata_kuliah (
    kode_mk    VARCHAR(10)  NOT NULL,
    nama_mk    VARCHAR(100) NOT NULL,
    sks        TINYINT      NOT NULL,
    semester   TINYINT      NOT NULL,
    kode_dosen VARCHAR(10)  NOT NULL,
    PRIMARY KEY (kode_mk),
    CONSTRAINT fk_mk_dosen FOREIGN KEY (kode_dosen)
        REFERENCES dosen(kode_dosen)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABEL 4: grade_nilai
-- ============================================================
CREATE TABLE grade_nilai (
    grade       VARCHAR(5)     NOT NULL,
    bobot       DECIMAL(4,2)   NOT NULL,
    nilai_bawah DECIMAL(6,2)   NOT NULL,
    nilai_atas  DECIMAL(6,2)   NOT NULL,
    PRIMARY KEY (grade)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABEL 5: nilai_praktikum
-- ============================================================
CREATE TABLE nilai_praktikum (
    id_nilai     INT            NOT NULL AUTO_INCREMENT,
    nim          VARCHAR(15)    NOT NULL,
    kode_mk      VARCHAR(10)    NOT NULL,
    nilai_tugas  DECIMAL(5,2)   NOT NULL,
    nilai_kuis   DECIMAL(5,2)   NOT NULL,
    nilai_uts    DECIMAL(5,2)   NOT NULL,
    nilai_akhir  DECIMAL(5,2)   DEFAULT NULL,
    grade        VARCHAR(5)     DEFAULT NULL,
    bobot        DECIMAL(4,2)   DEFAULT NULL,
    status_lulus VARCHAR(15)    DEFAULT NULL,
    PRIMARY KEY (id_nilai),
    CONSTRAINT fk_np_nim    FOREIGN KEY (nim)     REFERENCES mahasiswa(nim)      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_np_mk     FOREIGN KEY (kode_mk) REFERENCES mata_kuliah(kode_mk) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_np_grade  FOREIGN KEY (grade)   REFERENCES grade_nilai(grade)   ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABEL 6: log_rekap_nilai
-- ============================================================
CREATE TABLE log_rekap_nilai (
    id_log       INT            NOT NULL AUTO_INCREMENT,
    nim          VARCHAR(15)    NOT NULL,
    kode_mk      VARCHAR(10)    NOT NULL,
    nilai_akhir  DECIMAL(5,2)   NOT NULL,
    grade        VARCHAR(5)     NOT NULL,
    bobot        DECIMAL(4,2)   NOT NULL,
    status_lulus VARCHAR(15)    NOT NULL,
    keterangan   VARCHAR(255)   NOT NULL,
    waktu_proses DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_log)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
