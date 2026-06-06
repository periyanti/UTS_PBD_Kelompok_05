USE uts_pbd_kelompok_05;


SELECT '========== DATA MAHASISWA ==========' AS '---';
SELECT * FROM mahasiswa;

SELECT '========== DATA DOSEN ==========' AS '---';
SELECT * FROM dosen;

SELECT '========== DATA MATA KULIAH ==========' AS '---';
SELECT * FROM mata_kuliah;

SELECT '========== STANDAR GRADE NILAI ==========' AS '---';
SELECT * FROM grade_nilai ORDER BY bobot DESC;

SELECT '========== NILAI PRAKTIKUM (SEBELUM REKAP) ==========' AS '---';
SELECT * FROM nilai_praktikum;

SELECT '========== LOG REKAP NILAI (KOSONG DI AWAL) ==========' AS '---';
SELECT * FROM log_rekap_nilai;

SELECT '========== MENJALANKAN rekap_semua_nilai() ==========' AS '---';
CALL rekap_semua_nilai();


SELECT '========== NILAI PRAKTIKUM SETELAH rekap_semua_nilai() ==========' AS '---';
SELECT
    np.id_nilai,
    np.nim,
    m.nama           AS nama_mahasiswa,
    np.kode_mk,
    mk.nama_mk,
    np.nilai_tugas,
    np.nilai_kuis,
    np.nilai_uts,
    np.nilai_akhir,
    np.grade,
    np.bobot,
    np.status_lulus
FROM nilai_praktikum np
JOIN mahasiswa   m  ON np.nim     = m.nim
JOIN mata_kuliah mk ON np.kode_mk = mk.kode_mk
ORDER BY np.kode_mk, np.id_nilai;

SELECT '========== LOG REKAP NILAI SETELAH rekap_semua_nilai() ==========' AS '---';
SELECT * FROM log_rekap_nilai ORDER BY id_log;


SELECT '========== MENJALANKAN rekap_nilai_per_mk("MK001") ==========' AS '---';
CALL rekap_nilai_per_mk('MK001');

SELECT '========== MENJALANKAN rekap_nilai_per_mk("MK002") ==========' AS '---';
CALL rekap_nilai_per_mk('MK002');

SELECT '========== MENJALANKAN rekap_nilai_per_mk("MK003") ==========' AS '---';
CALL rekap_nilai_per_mk('MK003');


SELECT '========== LOG REKAP NILAI (LENGKAP) ==========' AS '---';
SELECT * FROM log_rekap_nilai ORDER BY id_log;



SELECT '========== RINGKASAN PER MATA KULIAH ==========' AS '---';
SELECT
    np.kode_mk,
    mk.nama_mk,
    COUNT(np.id_nilai)                                               AS jumlah_mahasiswa,
    ROUND(AVG(np.nilai_akhir), 2)                                    AS rata_nilai_akhir,
    SUM(CASE WHEN np.status_lulus = 'LULUS'       THEN 1 ELSE 0 END) AS jumlah_lulus,
    SUM(CASE WHEN np.status_lulus = 'TIDAK LULUS' THEN 1 ELSE 0 END) AS jumlah_tidak_lulus
FROM nilai_praktikum np
JOIN mata_kuliah mk ON np.kode_mk = mk.kode_mk
GROUP BY np.kode_mk, mk.nama_mk
ORDER BY np.kode_mk;

SELECT '========== DISTRIBUSI GRADE ==========' AS '---';
SELECT
    grade,
    bobot,
    status_lulus,
    COUNT(*) AS jumlah_mahasiswa
FROM nilai_praktikum
GROUP BY grade, bobot, status_lulus
ORDER BY bobot DESC;
