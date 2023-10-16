CREATE TABLE "Nasabah" (
  "id" uuid PRIMARY KEY,
  "name" varchar(255),
  "nik" varchar(16),
  "alamat" text,
  "tempat_lahir" varchar(255),
  "tanggal_lahir" date,
  "telephone" varchar(15),
  "nama_ibu_kandung" varchar(255)
);

CREATE TABLE "Akun" (
  "nomor_akun" varchar(20) PRIMARY KEY,
  "jenis_akun" varchar(50),
  "pemilik_id" uuid
);

CREATE TABLE "Transaksi" (
  "id" uuid PRIMARY KEY,
  "tanggal_transaksi" date,
  "jenis_transaksi" varchar(50),
  "jumlah" "decimal(10, 2)",
  "akun_asal" varchar(20),
  "akun_tujuan" varchar(20)
);



-- ALTER TABLE
ALTER TABLE "Akun" ADD FOREIGN KEY ("pemilik_id") REFERENCES "Nasabah" ("id");

ALTER TABLE "Transaksi" ADD FOREIGN KEY ("akun_asal") REFERENCES "Akun" ("nomor_akun");


-- Index untuk tabel Nasabah
CREATE INDEX idx_nasabah_nik ON "Nasabah" ("nik");
CREATE INDEX idx_nasabah_tempat_lahir ON "Nasabah" ("tempat_lahir");

-- Index untuk tabel Akun
CREATE INDEX idx_akun_pemilik_id ON "Akun" ("pemilik_id");

-- Index untuk tabel Transaksi
CREATE INDEX idx_transaksi_akun_asal ON "Transaksi" ("akun_asal");
CREATE INDEX idx_transaksi_akun_tujuan ON "Transaksi" ("akun_tujuan");


COMMENT ON COLUMN "Nasabah"."id" IS 'using uuid-v4';

COMMENT ON COLUMN "Akun"."nomor_akun" IS 'Nomor akun nasabah, bisa berupa string unik';

COMMENT ON COLUMN "Akun"."jenis_akun" IS 'Misalnya: Tabungan, Giro, Deposito';

COMMENT ON COLUMN "Akun"."saldo" IS 'Saldo dalam bentuk angka desimal';

COMMENT ON COLUMN "Akun"."pemilik_id" IS 'ID nasabah yang memiliki akun ini';

COMMENT ON COLUMN "Transaksi"."id" IS 'using uuid-v4';

COMMENT ON COLUMN "Transaksi"."jenis_transaksi" IS 'Misalnya: Penarikan, Setoran, Transfer';

COMMENT ON COLUMN "Transaksi"."jumlah" IS 'Jumlah transaksi dalam bentuk angka desimal';

COMMENT ON COLUMN "Transaksi"."akun_asal" IS 'Nomor akun asal jika ada';

COMMENT ON COLUMN "Transaksi"."akun_tujuan" IS 'Nomor akun tujuan jika ada';