-- add extension uuid
create extension if not exists "uuid-ossp";
--ddl for creating tables
create table if not exists nasabah (
   id uuid default uuid_generate_v4(),
   name varchar(255) not null,
   nik varchar(16) primary key not null,
   alamat text,
   tempat_lahir varchar(255) not null,
   tanggal_lahir date not null,
  telephone varchar(15),
  nama_ibu_kandung varchar(255) not null,
  createdat timestamp not null default now() ,
  updatedat timestamp default now(),
  deletedat timestamp
);
create type jenis_akun as enum ('tabungan', 'giro', 'deposito');
create table if not exists akun (
  id uuid primary key default uuid_generate_v4(),
  nomor_akun varchar(20),
  jenis_akun jenis_akun,
  pemilik_id varchar(16) ,
  pin varchar(6),
  createdat timestamp not null default now() ,
  updatedat timestamp default now(),
  deletedat timestamp
);
create type jenis_transaksi as enum ('penarikan', 'setoran', 'transfer');
create table if not exists transaksi (
  id uuid primary key default uuid_generate_v4(),
  tanggal_transaksi timestamp,
  jenis_transaksi jenis_transaksi ,
  jumlah int,
  akun_asal varchar(20),
  akun_tujuan varchar(20) 
);

-- Alter table
-- Tambahkan UNIQUE constraint ke kolom 'nik' yang dihapus dengan deletedat yang tidak null.
-- alter ini untuk  memastikan bahwa tidak ada dua baris data dengan NIK yang sama yang memiliki nilai deletedat yang tidak null.
alter table nasabah 
add constraint uq_nik unique (nik);
alter table nasabah  
add constraint uq_id unique (id);
alter table akun  
add constraint uq_akun_asal unique (nomor_akun);
-- alter table set fk
alter table akun
add constraint fk_akun_nasabah foreign key (pemilik_id) references nasabah(nik);
alter table transaksi 
add constraint fk_transaksi_akun foreign key (akun_asal) references akun (nomor_akun);
-- alter table modify
alter table transaksi
alter column tanggal_transaksi set default now();

-- Indexing
create index idx_akun_no_akun
on akun(nomor_akun);

create index idx_tr_tujuan
on transaksi(akun_tujuan);


-- dml
-- queries insert
insert into nasabah (name, nik, alamat, tempat_lahir, tanggal_lahir, telephone, nama_ibu_kandung)
values 
('jesika marni', '1658457896251367', 'jakarta selatan', 'depok', '1983-11-23','081458717745','mpok ati');
insert into nasabah (name, nik, alamat, tempat_lahir, tanggal_lahir, telephone, nama_ibu_kandung)
values 
('sambalado ferdi', '1658457896251456', 'bogor barat', 'depok', '1970-01-20','089458715445','irinah'),
('donny j plade'  , '1658457655484654', 'jakarta selatan', 'margonda', '1980-11-21','0845781654235','tin');


insert into akun (nomor_akun, jenis_akun, pemilik_id, pin)
values 
('25061000000000000001','tabungan', '1658457896251456','123456'), --sambalado
('25061000000000000002','tabungan', '1658457655484654','000000'); -- donny

insert into akun (nomor_akun, jenis_akun, pemilik_id, pin)
values 
('25061000000000000003','tabungan', '1658457896251367','421323'), --jesika
('25161000000000000003','giro', '1658457896251367','221323'),
('25261000000000000001','deposito', '1658457896251367','551232');

-- insert transaksi dimana akun_asal tidak terdatfar (expected error)
insert into transaksi (jenis_transaksi, jumlah, akun_asal)
values
('setoran', 1000000, '25261000000000004001');

-- setoran awal tabungan
insert into transaksi (jenis_transaksi, jumlah, akun_asal)
values
('setoran', 10000000, '25061000000000000001'), --sambalado
('setoran', 500000, '25061000000000000002'),-- donny
('setoran', 1500000, '25061000000000000003');--jesika

-- setoran awal giro dan deposito jesika
insert into transaksi (jenis_transaksi, jumlah, akun_asal)
values
('setoran', 1000000, '25161000000000000003'),
('setoran', 12500000, '25061000000000000002');

insert into transaksi (jenis_transaksi, jumlah, akun_asal)
values
('setoran', 1000000, '25261000000000000001');

-- transaksi transfer jesika to sambalado dan sambalado donny
insert into transaksi (jenis_transaksi, jumlah, akun_asal, akun_tujuan)
values
('transfer', 100000, '25061000000000000003', '25061000000000000001'),
('transfer', 500000, '25061000000000000001', '25061000000000000002');


insert into transaksi (jenis_transaksi, jumlah, akun_asal, akun_tujuan)
values
('transfer', 5000000, '25061000000000000001', '25061000000000000002');
-- transaksi tarik tunai donny j plade
insert into transaksi (jenis_transaksi, jumlah, akun_asal)
values
('penarikan', 200000, '25061000000000000002');

-- crud
-- getsaldo sambalado 25061000000000000001
with totalbyjenis as (
	select
		akun_asal,
		akun_tujuan,
		"jenis_transaksi",
		sum(case
			when "jenis_transaksi" = 'setoran' then jumlah
			when "jenis_transaksi" = 'transfer' and akun_asal = '25061000000000000001' then -jumlah
			when "jenis_transaksi" = 'transfer' and akun_tujuan = '25061000000000000001' then jumlah
			else 0
		end) as saldo
	from transaksi t
	group by akun_asal, akun_tujuan, "jenis_transaksi"
)
select
	sum(saldo) as saldo
from totalbyjenis
where akun_asal = '25061000000000000001' or akun_tujuan = '25061000000000000001';
-- membuat stored procedure
create or replace function getsaldo(nomor_rekening varchar)
returns numeric as $$
declare
    saldo numeric;
begin
    with totalbyjenis as (
        select
            akun_asal,
            akun_tujuan,
            "jenis_transaksi",
            sum(case
                when "jenis_transaksi" = 'setoran' then jumlah
                when "jenis_transaksi" = 'transfer' and akun_asal = nomor_rekening then -jumlah
                when "jenis_transaksi" = 'transfer' and akun_tujuan = nomor_rekening then jumlah
                else 0
            end) as saldo_cetak -- memberikan alias ke kolom saldo
        from transaksi t
        group by akun_asal, akun_tujuan, "jenis_transaksi"
    )
    
    select sum(saldo_cetak) into saldo
    from totalbyjenis
    where akun_asal = nomor_rekening or akun_tujuan = nomor_rekening;
    
    return saldo;
end;
$$ language plpgsql;

-- memanggil stored procedure
select getsaldo('25061000000000000001'); -- sambalado
select getsaldo('25061000000000000002'); -- donny
select getsaldo('25061000000000000003'); -- jesica tabungan
select getsaldo('25161000000000000003'); -- jesica tabungan
select getsaldo('25261000000000000001'); -- jesica deposito

-- Update data nasabah
update nasabah
set tempat_lahir ='Medan',
updatedat=now()
where id='e136fbc3-b3a7-48ed-b58c-872c4fed7154';
select * from nasabah n ;
-- insert new data
create or replace procedure addClient(name varchar, nik varchar, alamat text, tempat_lahir text, tanggal_lahir date, telephone varchar, nama_ibu_kandung varchar)
language plpgsql
as $$
begin 
	insert into nasabah (name, nik, alamat, tempat_lahir, tanggal_lahir, telephone, nama_ibu_kandung)
		values 
		(name, nik, alamat, tempat_lahir, tanggal_lahir, telephone, nama_ibu_kandung);
end;$$

call addclient('Derry', '3672051709970003', 'Cilegon', 'Cilegon', '1997-09-17', '089677816465', 'sri') ;

-- delete data nasabah soft delete
update nasabah set deletedat = now()
where nik='3672051709970003';
-- delete data nasabah hard delete
delete from nasabah
where nik='3672051709970003';
select * from nasabah n ;
