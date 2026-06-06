USE uts_pbd_kelompok_05;


SET @fk_exists = (
    SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = 'uts_pbd_kelompok_05'
      AND TABLE_NAME        = 'nilai_praktikum'
      AND CONSTRAINT_NAME   = 'fk_np_grade'
      AND CONSTRAINT_TYPE   = 'FOREIGN KEY'
);

SET @sql = IF(@fk_exists > 0,
    'ALTER TABLE nilai_praktikum DROP FOREIGN KEY fk_np_grade',
    'SELECT "fk_np_grade tidak ditemukan, tidak perlu dihapus" AS info'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

DROP PROCEDURE IF EXISTS rekap_semua_nilai;
DROP PROCEDURE IF EXISTS rekap_nilai_per_mk;


CREATE PROCEDURE rekap_semua_nilai()
BEGIN

    DECLARE v_id_nilai      INT;
    DECLARE v_nim           VARCHAR(15);
    DECLARE v_kode_mk       VARCHAR(10);
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

    -- Explicit Cursor
    DECLARE cur_nilai CURSOR FOR
        SELECT id_nilai, nim, kode_mk, nilai_tugas, nilai_kuis, nilai_uts
        FROM nilai_praktikum;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur_nilai;

    proses_loop: LOOP

        FETCH cur_nilai INTO
            v_id_nilai, v_nim, v_kode_mk,
            v_nilai_tugas, v_nilai_kuis, v_nilai_uts;

        IF done THEN
            LEAVE proses_loop;
        END IF;

        -- Hitung nilai akhir
        SET v_nilai_akhir = ROUND(
            (v_nilai_tugas * 0.30) +
            (v_nilai_kuis  * 0.30) +
            (v_nilai_uts   * 0.40),
        2);

        -- Tentukan grade
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

        -- Tentukan bobot
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

        -- Tentukan status lulus
        IF v_grade IN ('A', 'A-', 'B+', 'B', 'B-', 'C+', 'C') THEN
            SET v_status_lulus = 'LULUS';
        ELSE
            SET v_status_lulus = 'TIDAK LULUS';
        END IF;

        -- Update tabel nilai_praktikum
        UPDATE nilai_praktikum
        SET
            nilai_akhir  = v_nilai_akhir,
            grade        = v_grade,
            bobot        = v_bobot,
            status_lulus = v_status_lulus
        WHERE id_nilai = v_id_nilai;

        -- FIX: Gunakan counter manual, lebih reliable dari ROW_COUNT()
        SET v_total_diproses = v_total_diproses + 1;

        SET v_keterangan = CONCAT(
            'Rekap semua nilai: NIM ', v_nim,
            ', MK ', v_kode_mk,
            ', Nilai Akhir ', v_nilai_akhir,
            ', Grade ', v_grade,
            ', Status ', v_status_lulus
        );

        INSERT INTO log_rekap_nilai
            (nim, kode_mk, nilai_akhir, grade, bobot, status_lulus, keterangan, waktu_proses)
        VALUES
            (v_nim, v_kode_mk, v_nilai_akhir, v_grade, v_bobot, v_status_lulus, v_keterangan, NOW());

    END LOOP proses_loop;

    CLOSE cur_nilai;

    SELECT CONCAT('rekap_semua_nilai() selesai. Total data diproses: ', v_total_diproses) AS hasil_proses;

END$$



CREATE PROCEDURE rekap_nilai_per_mk(IN p_kode_mk VARCHAR(10))
BEGIN

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

    DECLARE cur_nilai_mk CURSOR FOR
        SELECT id_nilai, nim, nilai_tugas, nilai_kuis, nilai_uts
        FROM nilai_praktikum
        WHERE kode_mk = p_kode_mk;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur_nilai_mk;

    proses_mk_loop: LOOP

        FETCH cur_nilai_mk INTO
            v_id_nilai, v_nim,
            v_nilai_tugas, v_nilai_kuis, v_nilai_uts;

        IF done THEN
            LEAVE proses_mk_loop;
        END IF;

        SET v_nilai_akhir = ROUND(
            (v_nilai_tugas * 0.30) +
            (v_nilai_kuis  * 0.30) +
            (v_nilai_uts   * 0.40),
        2);

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

        IF v_grade IN ('A', 'A-', 'B+', 'B', 'B-', 'C+', 'C') THEN
            SET v_status_lulus = 'LULUS';
        ELSE
            SET v_status_lulus = 'TIDAK LULUS';
        END IF;

        UPDATE nilai_praktikum
        SET
            nilai_akhir  = v_nilai_akhir,
            grade        = v_grade,
            bobot        = v_bobot,
            status_lulus = v_status_lulus
        WHERE id_nilai = v_id_nilai;

        -- FIX: Gunakan counter manual, lebih reliable dari ROW_COUNT()
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

    END LOOP proses_mk_loop;

    CLOSE cur_nilai_mk;

    SELECT CONCAT('rekap_nilai_per_mk(', p_kode_mk, ') selesai. Total data diproses: ', v_total_diproses) AS hasil_proses;

END$$

DELIMITER ;
