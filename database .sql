
CREATE DATABASE IF NOT EXISTS uts_pbd_kelompok_05;
USE uts_pbd_kelompok_05;

CREATE TABLE IF NOT EXISTS dosen (
    kode_dosen  VARCHAR(10)  NOT NULL,
    nama_dosen  VARCHAR(100) NOT NULL,
    email       VARCHAR(100) NOT NULL,
    PRIMARY KEY (kode_dosen)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS mahasiswa (
    nim      VARCHAR(15)  NOT NULL,
    nama     VARCHAR(100) NOT NULL,
    kelas    VARCHAR(10)  NOT NULL,
    angkatan YEAR         NOT NULL,
    PRIMARY KEY (nim)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS mata_kuliah (
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


CREATE TABLE IF NOT EXISTS grade_nilai (
    grade       VARCHAR(5)     NOT NULL,
    bobot       DECIMAL(4,2)   NOT NULL,
    nilai_bawah DECIMAL(6,2)   NOT NULL,
    nilai_atas  DECIMAL(6,2)   NOT NULL,
    PRIMARY KEY (grade)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS nilai_praktikum (
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
    CONSTRAINT fk_np_nim FOREIGN KEY (nim)
        REFERENCES mahasiswa(nim) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_np_mk  FOREIGN KEY (kode_mk)
        REFERENCES mata_kuliah(kode_mk) ON UPDATE CASCADE ON DELETE RESTRICT
    -- fk_np_grade DIHAPUS: grade divalidasi via logika CASE di procedure
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS log_rekap_nilai (
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
