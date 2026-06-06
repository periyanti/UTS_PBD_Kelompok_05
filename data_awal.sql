USE uts_pbd_kelompok_05;


INSERT INTO dosen (kode_dosen, nama_dosen, email) VALUES
('D001', 'Abdul Malik, S.Kom., M.Cs.', 'abdulmalik@universitasmb.ac.id'),
('D002', 'Hasriani, S.Kom., M.Kom.',    'hasriani@universitasmb.ac.id');


INSERT INTO mata_kuliah (kode_mk, nama_mk, sks, semester, kode_dosen) VALUES
('MK001', 'Pemrograman Basis Data',  3, 4, 'D001'),
('MK002', 'Algoritma dan Struktur Data', 3, 3, 'D001'),
('MK003', 'Rekayasa Perangkat Lunak',    3, 5, 'D002');

INSERT INTO grade_nilai (grade, bobot, nilai_bawah, nilai_atas) VALUES
('A',   4.00,  93.00, 100.00),
('A-',  3.75,  85.00,  92.99),
('B+',  3.50,  81.00,  84.99),
('B',   3.25,  75.00,  80.99),
('B-',  3.00,  71.00,  74.99),
('C+',  2.75,  66.00,  70.99),
('C',   2.50,  61.00,  65.99),
('C-',  2.00,  56.00,  60.99),
('D',   1.00,  40.00,  55.99),
('E',   0.00,   0.00,  39.99);


INSERT INTO mahasiswa (nim, nama, kelas, angkatan) VALUES
('2411001', 'fadhila',         'IF-A', 2024),
('2411002', 'nur fahila',        'IF-A', 2024),
('2411003', 'ria',          'IF-A', 2024),
('2411004', 'periyanti',        'IF-A', 2024),
('2411005', 'hasriani',           'IF-A', 2024),
('2411006', 'hijriyanti',       'IF-B', 2024),
('2411007', 'rose',        'IF-B', 2024),
('2411008', 'elgiariel',       'IF-B', 2024),
('2411009', 'mifta',          'IF-B', 2024),
('2411010', 'lilis',         'IF-B', 2024),
('2411011', 'anandari',       'IF-A', 2024),
('2411012', 'octavia',        'IF-A', 2024),
('2411013', 'aziza',      'IF-A', 2024),
('2411014', 'rahma',       'IF-B', 2024),
('2411015', 'lisa',      'IF-B', 2024),
('2411016', 'faizah',        'IF-A', 2024),
('2411017', 'magfarani',        'IF-B', 2024),
('2411018', 'nadia',       'IF-A', 2024),
('2411019', 'aulia',     'IF-B', 2024),
('2411020', 'winda',        'IF-A', 2024);


INSERT INTO nilai_praktikum (nim, kode_mk, nilai_tugas, nilai_kuis, nilai_uts) VALUES
-- MK001 - Pemrograman Basis Data
('2411001', 'MK001',  95, 90, 97),   -- nilai_akhir ~93.9 -> A
('2411002', 'MK001',  85, 88, 90),   -- nilai_akhir ~88.1 -> A-
('2411003', 'MK001',  82, 80, 84),   -- nilai_akhir ~82.2 -> B+
('2411004', 'MK001',  78, 75, 79),   -- nilai_akhir ~77.5 -> B
('2411005', 'MK001',  72, 70, 73),   -- nilai_akhir ~71.8 -> B-
('2411006', 'MK001',  68, 66, 70),   -- nilai_akhir ~68.2 -> C+
('2411007', 'MK001',  63, 61, 65),   -- nilai_akhir ~63.2 -> C
('2411008', 'MK001',  58, 55, 60),   -- nilai_akhir ~57.9 -> C-
('2411009', 'MK001',  45, 42, 50),   -- nilai_akhir ~45.7 -> D
('2411010', 'MK001',  30, 25, 35),   -- nilai_akhir ~29.5 -> E
-- MK002 - Algoritma dan Struktur Data
('2411011', 'MK002',  96, 94, 98),   -- nilai_akhir ~95.8 -> A
('2411012', 'MK002',  87, 86, 89),   -- nilai_akhir ~87.5 -> A-
('2411013', 'MK002',  80, 82, 76),   -- nilai_akhir ~79.2 -> B
('2411014', 'MK002',  71, 73, 72),   -- nilai_akhir ~72.0 -> B-
('2411015', 'MK002',  67, 65, 68),   -- nilai_akhir ~66.8 -> C+
('2411016', 'MK002',  62, 60, 61),   -- nilai_akhir ~61.0 -> C
('2411017', 'MK002',  38, 35, 30),   -- nilai_akhir ~33.5 -> E
-- MK003 - Rekayasa Perangkat Lunak
('2411018', 'MK003',  90, 92, 95),   -- nilai_akhir ~92.6 -> A-
('2411019', 'MK003',  74, 76, 73),   -- nilai_akhir ~74.3 -> B-
('2411020', 'MK003',  56, 58, 55),   -- nilai_akhir ~56.2 -> C-
-- Tambahan agar distribusi richer
('2411001', 'MK002',  88, 85, 92),   -- mahasiswa 1 ambil MK002 juga
('2411002', 'MK003',  77, 79, 80);   -- mahasiswa 2 ambil MK003 juga
