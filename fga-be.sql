-- add extension uuid
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
--DDL for creating tables
CREATE table if not EXISTS Nasabah (
   id uuid PRIMARY key default uuid_generate_v4(),
   name varchar(255) not null,
   nik varchar(16) not null,
   alamat text,
   tempat_lahir varchar(255) not null,
   tanggal_lahir date not null,
  telephone varchar(15),
  nama_ibu_kandung varchar(255) not null,
  createdAt timestamp not null default now() ,
  updatedAt timestamp default now(),
  deletedAt timestamp
);
create type jenis_akun as enum ('tabungan', 'giro', 'deposito');
CREATE table if not EXISTS Akun (
  id uuid PRIMARY key default uuid_generate_v4(),
  nomor_akun varchar(20),
  jenis_akun jenis_akun,
  pemilik_id uuid ,
  pin varchar(6),
  createdAt timestamp not null default now() ,
  updatedAt timestamp default now(),
  deletedAt timestamp
);
create type jenis_transaksi as enum ('penarikan', 'setoran', 'transfer');
CREATE table if not EXISTS Transaksi (
  id uuid PRIMARY key default uuid_generate_v4(),
  tanggal_transaksi timestamp,
  jenis_transaksi jenis_transaksi ,
  jumlah int,
  akun_asal varchar(20),
  akun_tujuan varchar(20) 
);
-- alter table set unique
ALTER TABLE Akun
ADD CONSTRAINT UQ_Akun_nomor_akun UNIQUE (nomor_akun);
ALTER TABLE nasabah 
ADD CONSTRAINT UQ_nik UNIQUE (nik);
-- alter table set FK
ALTER TABLE Akun
ADD CONSTRAINT FK_Akun_Nasabah FOREIGN KEY (pemilik_id) REFERENCES Nasabah(id);
alter table Transaksi 
ADD constraint FK_Transaksi_Akun foreign key (akun_asal) REFERENCES Akun (nomor_akun);
-- alter table modify
ALTER TABLE Transaksi
ALTER COLUMN tanggal_transaksi SET DEFAULT now();

-- DML
-- QUERIES INSERT
insert into nasabah (name, nik, alamat, tempat_lahir, tanggal_lahir, telephone, nama_ibu_kandung)
values 
('Sambalado ferdi', 1658457896251456, 'Bogor Barat', 'Depok', '1970-01-20','089458715445','Irinah'),
('Donny J plade'  , 1658457655484654, 'Jakarta Selatan', 'Margonda', '1980-11-21','0845781654235','Tin');

insert into akun (nomor_akun, jenis_akun, pemilik_id, pin)
values 
('25061000000000000001','tabungan', '3b343133-261e-4970-bd6c-35d81140647c','123456'),
('25061000000000000002','tabungan', 'ab1a5e66-2f95-410b-9f9f-2c432ad491dc','000000');

-- setoran awal
insert into transaksi (jenis_transaksi, jumlah, akun_asal)
('setoran', 10000000, '3b343133-261e-4970-bd6c-35d81140647c'),
('setoran', 500000, 'ab1a5e66-2f95-410b-9f9f-2c432ad491dc'),


-- transaksi transfer 
insert into