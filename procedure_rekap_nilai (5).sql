-- ============================================================
-- FILE: procedure_rekap_nilai.sql
-- Projek UTS Pemrograman Basis Data
-- Kelompok 5 - Sistem Rekap Nilai Praktikum Mahasiswa
-- ============================================================
-- Jalankan SETELAH: database.sql, data_awal.sql
-- ============================================================

USE uts_pbd_kelompok_05;

-- ============================================================
-- Hapus procedure lama jika sudah ada
-- ============================================================
DROP PROCEDURE IF EXISTS rekap_semua_nilai;
DROP PROCEDURE IF EXISTS rekap_nilai_per_mk;

-- ============================================================
-- DELIMITER
-- ============================================================
DELIMITER $$

-- ============================================================
-- PROCEDURE 1: rekap_semua_nilai()
-- Menggunakan:
--   - Variabel lokal
--   - Explicit cursor (DECLARE CURSOR)
--   - Handler NOT FOUND
--   - Perulangan LOOP
--   - Percabangan CASE (grade, bobot, status_lulus)
--   - Implicit cursor (ROW_COUNT())
--   - Pencatatan ke log_rekap_nilai
-- ============================================================
CREATE PROCEDURE rekap_semua_nilai()
BEGIN

    -- --------------------------------------------------------
    -- Variabel lokal untuk menampung data cursor
    -- --------------------------------------------------------
    DECLARE v_id_nilai      INT;
    DECLARE v_nim           VARCHAR(15);
    DECLARE v_kode_mk       VARCHAR(10);
    DECLARE v_nilai_tugas   DECIMAL(5,2);
    DECLARE v_nilai_kuis    DECIMAL(5,2);
    DECLARE v_nilai_uts     DECIMAL(5,2);

    -- Variabel hasil perhitungan
    DECLARE v_nilai_akhir   DECIMAL(5,2);
    DECLARE v_grade         VARCHAR(5);
    DECLARE v_bobot         DECIMAL(4,2);
    DECLARE v_status_lulus  VARCHAR(15);
    DECLARE v_keterangan    VARCHAR(255);

    -- Variabel untuk implicit cursor (ROW_COUNT) dan counter
    DECLARE v_total_diproses INT DEFAULT 0;

    -- Flag selesai untuk handler cursor
    DECLARE done            BOOLEAN DEFAULT FALSE;

    -- --------------------------------------------------------
    -- Explicit Cursor: membaca semua data nilai_praktikum
    -- --------------------------------------------------------
    DECLARE cur_nilai CURSOR FOR
        SELECT id_nilai, nim, kode_mk, nilai_tugas, nilai_kuis, nilai_uts
        FROM nilai_praktikum;

    -- --------------------------------------------------------
    -- Handler: set done = TRUE jika tidak ada baris lagi
    -- --------------------------------------------------------
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- --------------------------------------------------------
    -- Buka cursor
    -- --------------------------------------------------------
    OPEN cur_nilai;

    -- --------------------------------------------------------
    -- Perulangan LOOP untuk memproses setiap baris cursor
    -- --------------------------------------------------------
    proses_loop: LOOP

        -- Ambil satu baris dari cursor ke variabel lokal
        FETCH cur_nilai INTO
            v_id_nilai,
            v_nim,
            v_kode_mk,
            v_nilai_tugas,
            v_nilai_kuis,
            v_nilai_uts;

        -- Jika sudah tidak ada data, keluar dari loop
        IF done THEN
            LEAVE proses_loop;
        END IF;

        -- --------------------------------------------------------
        -- Hitung nilai akhir menggunakan rumus:
        -- nilai_akhir = (tugas * 30%) + (kuis * 30%) + (uts * 40%)
        -- --------------------------------------------------------
        SET v_nilai_akhir = ROUND(
            (v_nilai_tugas * 0.30) +
            (v_nilai_kuis  * 0.30) +
            (v_nilai_uts   * 0.40),
        2);

        -- --------------------------------------------------------
        -- Percabangan CASE: tentukan grade berdasarkan nilai_akhir
        -- --------------------------------------------------------
        SET v_grade = CASE
            WHEN v_nilai_akhir BETWEEN 93.00 AND 100.00 THEN 'A'
            WHEN v_nilai_akhir BETWEEN 85.00 AND  92.99 THEN 'A-'
            WHEN v_nilai_akhir BETWEEN 81.00 AND  84.99 THEN 'B+'
            WHEN v_nilai_akhir BETWEEN 75.00 AND  80.99 THEN 'B'
            WHEN v_nilai_akhir BETWEEN 71.00 AND  74.99 THEN 'B-'
            WHEN v_nilai_akhir BETWEEN 66.00 AND  70.99 THEN 'C+'
            WHEN v_nilai_akhir BETWEEN 61.00 AND  65.99 THEN 'C'
            WHEN v_nilai_akhir BETWEEN 56.00 AND  60.99 THEN 'C-'
            WHEN v_nilai_akhir BETWEEN 40.00 AND  55.99 THEN 'D'
            ELSE 'E'
        END;

        -- --------------------------------------------------------
        -- Percabangan CASE: tentukan bobot berdasarkan grade
        -- --------------------------------------------------------
        SET v_bobot = CASE v_grade
            WHEN 'A'  THEN 4.00
            WHEN 'A-' THEN 3.75
            WHEN 'B+' THEN 3.50
            WHEN 'B'  THEN 3.25
            WHEN 'B-' THEN 3.00
            WHEN 'C+' THEN 2.75
            WHEN 'C'  THEN 2.50
            WHEN 'C-' THEN 2.00
            WHEN 'D'  THEN 1.00
            ELSE 0.00
        END;

        -- --------------------------------------------------------
        -- Percabangan IF: tentukan status kelulusan
        -- Lulus: A, A-, B+, B, B-, C+, C
        -- Tidak Lulus: C-, D, E
        -- --------------------------------------------------------
        IF v_grade IN ('A', 'A-', 'B+', 'B', 'B-', 'C+', 'C') THEN
            SET v_status_lulus = 'LULUS';
        ELSE
            SET v_status_lulus = 'TIDAK LULUS';
        END IF;

        -- --------------------------------------------------------
        -- Simpan hasil ke tabel nilai_praktikum
        -- --------------------------------------------------------
        UPDATE nilai_praktikum
        SET
            nilai_akhir  = v_nilai_akhir,
            grade        = v_grade,
            bobot        = v_bobot,
            status_lulus = v_status_lulus
        WHERE id_nilai = v_id_nilai;

        -- --------------------------------------------------------
        -- Implicit Cursor: ROW_COUNT() mengembalikan jumlah baris
        -- yang terpengaruh oleh UPDATE di atas
        -- --------------------------------------------------------
        IF ROW_COUNT() > 0 THEN
            SET v_total_diproses = v_total_diproses + 1;

            -- Buat keterangan log
            SET v_keterangan = CONCAT(
                'Rekap semua nilai: NIM ', v_nim,
                ', MK ', v_kode_mk,
                ', Nilai Akhir ', v_nilai_akhir,
                ', Grade ', v_grade,
                ', Status ', v_status_lulus
            );

            -- Catat ke tabel log_rekap_nilai
            INSERT INTO log_rekap_nilai
                (nim, kode_mk, nilai_akhir, grade, bobot, status_lulus, keterangan, waktu_proses)
            VALUES
                (v_nim, v_kode_mk, v_nilai_akhir, v_grade, v_bobot, v_status_lulus, v_keterangan, NOW());
        END IF;

    END LOOP proses_loop;

    -- --------------------------------------------------------
    -- Tutup cursor setelah selesai
    -- --------------------------------------------------------
    CLOSE cur_nilai;

    -- --------------------------------------------------------
    -- Tampilkan ringkasan hasil proses (implicit cursor)
    -- --------------------------------------------------------
    SELECT CONCAT('rekap_semua_nilai() selesai. Total data diproses: ', v_total_diproses) AS hasil_proses;

END$$


-- ============================================================
-- PROCEDURE 2: rekap_nilai_per_mk(p_kode_mk)
-- Cursor dengan parameter: memfilter berdasarkan kode_mk
-- Menggunakan:
--   - Parameter input stored procedure
--   - Explicit cursor (query menggunakan parameter)
--   - Variabel lokal
--   - Perulangan LOOP
--   - Percabangan CASE dan IF
--   - Implicit cursor (ROW_COUNT())
--   - Pencatatan ke log_rekap_nilai
--   - Idempoten: bisa dijalankan berulang kali
-- ============================================================
CREATE PROCEDURE rekap_nilai_per_mk(IN p_kode_mk VARCHAR(10))
BEGIN

    -- --------------------------------------------------------
    -- Variabel lokal
    -- --------------------------------------------------------
    DECLARE v_id_nilai      INT;
    DECLARE v_nim           VARCHAR(15);
    DECLARE v_nilai_tugas   DECIMAL(5,2);
    DECLARE v_nilai_kuis    DECIMAL(5,2);
    DECLARE v_nilai_uts     DECIMAL(5,2);

    DECLARE v_nilai_akhir   DECIMAL(5,2);
    DECLARE v_grade         VARCHAR(5);
    DECLARE v_bobot         DECIMAL(4,2);
    DECLARE v_status_lulus  VARCHAR(15);
    DECLARE v_keterangan    VARCHAR(255);

    DECLARE v_total_diproses INT DEFAULT 0;

    DECLARE done            BOOLEAN DEFAULT FALSE;

    -- --------------------------------------------------------
    -- Cursor dengan parameter: filter berdasarkan p_kode_mk
    -- Catatan: MySQL tidak mendukung parameter langsung pada CURSOR,
    -- sehingga parameter procedure digunakan pada query cursor.
    -- --------------------------------------------------------
    DECLARE cur_nilai_mk CURSOR FOR
        SELECT id_nilai, nim, nilai_tugas, nilai_kuis, nilai_uts
        FROM nilai_praktikum
        WHERE kode_mk = p_kode_mk;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- --------------------------------------------------------
    -- Buka cursor
    -- --------------------------------------------------------
    OPEN cur_nilai_mk;

    -- --------------------------------------------------------
    -- Perulangan LOOP
    -- --------------------------------------------------------
    proses_mk_loop: LOOP

        FETCH cur_nilai_mk INTO
            v_id_nilai,
            v_nim,
            v_nilai_tugas,
            v_nilai_kuis,
            v_nilai_uts;

        IF done THEN
            LEAVE proses_mk_loop;
        END IF;

        -- --------------------------------------------------------
        -- Hitung nilai akhir
        -- --------------------------------------------------------
        SET v_nilai_akhir = ROUND(
            (v_nilai_tugas * 0.30) +
            (v_nilai_kuis  * 0.30) +
            (v_nilai_uts   * 0.40),
        2);

        -- --------------------------------------------------------
        -- Tentukan grade
        -- --------------------------------------------------------
        SET v_grade = CASE
            WHEN v_nilai_akhir BETWEEN 93.00 AND 100.00 THEN 'A'
            WHEN v_nilai_akhir BETWEEN 85.00 AND  92.99 THEN 'A-'
            WHEN v_nilai_akhir BETWEEN 81.00 AND  84.99 THEN 'B+'
            WHEN v_nilai_akhir BETWEEN 75.00 AND  80.99 THEN 'B'
            WHEN v_nilai_akhir BETWEEN 71.00 AND  74.99 THEN 'B-'
            WHEN v_nilai_akhir BETWEEN 66.00 AND  70.99 THEN 'C+'
            WHEN v_nilai_akhir BETWEEN 61.00 AND  65.99 THEN 'C'
            WHEN v_nilai_akhir BETWEEN 56.00 AND  60.99 THEN 'C-'
            WHEN v_nilai_akhir BETWEEN 40.00 AND  55.99 THEN 'D'
            ELSE 'E'
        END;

        -- --------------------------------------------------------
        -- Tentukan bobot
        -- --------------------------------------------------------
        SET v_bobot = CASE v_grade
            WHEN 'A'  THEN 4.00
            WHEN 'A-' THEN 3.75
            WHEN 'B+' THEN 3.50
            WHEN 'B'  THEN 3.25
            WHEN 'B-' THEN 3.00
            WHEN 'C+' THEN 2.75
            WHEN 'C'  THEN 2.50
            WHEN 'C-' THEN 2.00
            WHEN 'D'  THEN 1.00
            ELSE 0.00
        END;

        -- --------------------------------------------------------
        -- Tentukan status kelulusan
        -- --------------------------------------------------------
        IF v_grade IN ('A', 'A-', 'B+', 'B', 'B-', 'C+', 'C') THEN
            SET v_status_lulus = 'LULUS';
        ELSE
            SET v_status_lulus = 'TIDAK LULUS';
        END IF;

        -- --------------------------------------------------------
        -- Update tabel nilai_praktikum
        -- --------------------------------------------------------
        UPDATE nilai_praktikum
        SET
            nilai_akhir  = v_nilai_akhir,
            grade        = v_grade,
            bobot        = v_bobot,
            status_lulus = v_status_lulus
        WHERE id_nilai = v_id_nilai;

        -- --------------------------------------------------------
        -- Implicit cursor: cek ROW_COUNT() lalu catat ke log
        -- --------------------------------------------------------
        IF ROW_COUNT() > 0 THEN
            SET v_total_diproses = v_total_diproses + 1;

            SET v_keterangan = CONCAT(
                'Rekap per MK (', p_kode_mk, '): NIM ', v_nim,
                ', Nilai Akhir ', v_nilai_akhir,
                ', Grade ', v_grade,
                ', Status ', v_status_lulus
            );

            INSERT INTO log_rekap_nilai
                (nim, kode_mk, nilai_akhir, grade, bobot, status_lulus, keterangan, waktu_proses)
            VALUES
                (v_nim, p_kode_mk, v_nilai_akhir, v_grade, v_bobot, v_status_lulus, v_keterangan, NOW());
        END IF;

    END LOOP proses_mk_loop;

    -- --------------------------------------------------------
    -- Tutup cursor
    -- --------------------------------------------------------
    CLOSE cur_nilai_mk;

    -- --------------------------------------------------------
    -- Tampilkan ringkasan
    -- --------------------------------------------------------
    SELECT CONCAT('rekap_nilai_per_mk(', p_kode_mk, ') selesai. Total data diproses: ', v_total_diproses) AS hasil_proses;

END$$

DELIMITER ;
