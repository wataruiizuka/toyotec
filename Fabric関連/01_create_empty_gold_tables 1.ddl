-- Run first: create empty Gold tables
-- Generated targets: 99
-- Internal dx_ve references matching generated targets are redirected to gold.
-- Statements are ordered so every generated Gold dependency is available first.

-- LIMIT 0 preserves the SELECT-derived schema while inserting no rows.

-- [001/099] level=0 target=gold.vbi000001_en
-- Gold dependencies: none
-- Source file: 000_市場処置の実施状況と部品管理見える化/recallslim_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi000001_en AS
select
	--ソート順
	row_number() over(order by t201m.cd_hansya, t201m.cd_kaisya, t9003m.mj_sortjyun, t201m.cd_tenpo) as mj_sortjyun,
	--販社コード
	t201m.cd_hansya,
	--会社コード
	t201m.cd_kaisya,
	--店舗コード
	t201m.cd_tenpo,
	--店舗名称
	regexp_replace(t201m.kj_tenpomei, '　+$', '') as kj_tenpomei
--共通店舗DB
from ai21rep_ve_dx.tbv0201m t201m
-- 店舗表示設定
inner join dx_ve.tbi999003m t9003m on t9003m.cd_hansya = t201m.cd_hansya
and t9003m.cd_kaisya = t201m.cd_kaisya
and t9003m.cd_tenpo = t201m.cd_tenpo
and t9003m.mj_cyohyoid = '000'
and t9003m.kb_tenji = 1
LIMIT 0;

-- [002/099] level=1 target=gold.vbi000001
-- Gold dependencies: gold.vbi000001_en
-- Source file: 000_市場処置の実施状況と部品管理見える化/recallslim_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi000001 AS
select
	--ソート順
	mj_sortjyun as `ソート順`,
	--販社コード
	cd_hansya as `販社コード`,
	--会社コード
	cd_kaisya as `会社コード`,
	--店舗コード
	cd_tenpo as `店舗コード`,
	--店舗名称
	kj_tenpomei as `店舗名称`
from gold.vbi000001_en
LIMIT 0;

-- [003/099] level=0 target=gold.vbi000002_en
-- Gold dependencies: none
-- Source file: 000_市場処置の実施状況と部品管理見える化/recallslim_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi000002_en AS
select
	--販社コード
	t206m.cd_hansya,
	--会社コード
	t206m.cd_kaisya,
	--取替部品品番
	trim(t206m.mj_toribhhn) as mj_toribhhn,
	--取替部品品名
	max(t022g.mj_torihnme) as mj_torihnme
--リコール展開明細ＤＢ
from ai21rep_ve_dx.tbfy206m t206m
--市場処置部品集計ＤＢ
left join ai21rep_ve_dx.tbfj022g t022g on t022g.cd_hansya = t206m.cd_hansya
and t022g.cd_kaisya = t206m.cd_kaisya
and trim(t022g.mj_toribhhn) = trim(t206m.mj_toribhhn)
and nvl(trim(t022g.mj_torihnme), '') <> ''
--取替部品品番の前三桁 = '040'： 市場処置部品
where left(t206m.mj_toribhhn, 3) = '040'
group by t206m.cd_hansya, t206m.cd_kaisya, trim(t206m.mj_toribhhn)
LIMIT 0;

-- [004/099] level=1 target=gold.vbi000002
-- Gold dependencies: gold.vbi000002_en
-- Source file: 000_市場処置の実施状況と部品管理見える化/recallslim_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi000002 AS
select
	--販社コード
	cd_hansya as `販社コード`,
	--会社コード
	cd_kaisya as `会社コード`,
	--取替部品品番
	mj_toribhhn as `取替部品品番`,
	--取替部品品名
	mj_torihnme as `取替部品品名`
from gold.vbi000002_en
LIMIT 0;

-- [005/099] level=0 target=gold.vbi000003
-- Gold dependencies: none
-- Source file: 000_市場処置の実施状況と部品管理見える化/recallslim_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi000003 AS
select
	--販社コード
 	t001g.cd_hansya as `販社コード`,
 	--会社コード
 	t001g.cd_kaisya as `会社コード`,
 	--整理ＮＯ
	t001g.no_seiri as `整理ＮＯ`,
	--フレーム型式
	t001g.mj_framekat as `フレーム型式`,
	--データ分類
	if (
		max(t205m.dd_tekkikst) >= months_sub(cast(from_utc_timestamp(utc_timestamp(), 'JST') as date), 24),
		'2年のみ',
		'過去全部'
	) as `データ分類`
--リコールメインＤＢ
from ai21rep_ve_dx.tbfj001g t001g
--ストール予約ＤＢ
left join ai21rep_ve_dx.tbsa001g ta001g on ta001g.cd_hansya = t001g.cd_hansya
and ta001g.cd_kaisya = t001g.cd_kaisya
and ta001g.no_aijutyu = t001g.no_jucyu
--リコール展開名称ＤＢ
left join ai21rep_ve_dx.tbfy205m t205m on t205m.cd_hansya = t001g.cd_hansya
and t205m.cd_kaisya = t001g.cd_kaisya
and t205m.no_seiri = t001g.no_seiri
and trim(t205m.mj_framekat) = trim(t001g.mj_framekat)
group by t001g.cd_hansya, t001g.cd_kaisya, t001g.no_seiri, t001g.mj_framekat
LIMIT 0;

-- [006/099] level=0 target=gold.vbi000004_en
-- Gold dependencies: none
-- Source file: 000_市場処置の実施状況と部品管理見える化/recallslim_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi000004_en AS
select
	--販社コード
	t022g.cd_hansya,
	--会社コード
	t022g.cd_kaisya,
	--整理ＮＯ
	t022g.no_seiri,
	--リコール名称
	max(t022g.kj_recallme) as kj_recallme
--市場処置部品集計ＤＢ
from ai21rep_ve_dx.tbfj022g t022g
group by t022g.cd_hansya, t022g.cd_kaisya, t022g.no_seiri
LIMIT 0;

-- [007/099] level=1 target=gold.vbi000004
-- Gold dependencies: gold.vbi000004_en
-- Source file: 000_市場処置の実施状況と部品管理見える化/recallslim_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi000004 AS
select
	cd_hansya as `販社コード`,
	cd_kaisya as `会社コード`,
	no_seiri as `整理ＮＯ`,
	kj_recallme as `リコール名称`
from gold.vbi000004_en
LIMIT 0;

-- [008/099] level=1 target=gold.vbi000005
-- Gold dependencies: gold.vbi000004_en
-- Source file: 000_市場処置の実施状況と部品管理見える化/recallslim_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi000005 AS
select
	--販社コード
 	t001g.cd_hansya as `販社コード`,
 	--会社コード
 	t001g.cd_kaisya as `会社コード`,
 	--フォロー店舗コード
 	t001g.cd_flwtenp as `フォロー店舗コード`,
 	--入庫予定店舗
 	t001g.cd_nyuukoyt as `入庫予定店舗 `,
 	--整理ＮＯ
	t001g.no_seiri as `整理ＮＯ`,
	--フレーム型式
	t001g.mj_framekat as `フレーム型式`,
	--リコール名称
	v0004.kj_recallme as `リコール名称`,
	--適用期間始期
	t205m.dd_tekkikst as `適用期間始期`,
	--一時抹消: [抹消区分]="1" && [実施区分]="0"
	sum(t001g.kb_massyo = '1' and t001g.kb_jissi= '0') as `一時抹消`
--リコールメインＤＢ
from ai21rep_ve_dx.tbfj001g t001g
-- 店舗表示設定
left semi join dx_ve.tbi999003m t9003m on (t9003m.cd_hansya = t001g.cd_hansya
and t9003m.cd_kaisya = t001g.cd_kaisya
and t9003m.cd_tenpo = t001g.cd_nyuukoyt
and t9003m.mj_cyohyoid = '000'
and t9003m.kb_tenji = 1) or trim(t001g.cd_nyuukoyt) = ''
--リコール展開明細ＤＢ
--left semi join ai21rep_ve_dx.tbfy206m t206m on t206m.cd_hansya = t001g.cd_hansya
--and t206m.cd_kaisya = t001g.cd_kaisya
--and t206m.no_seiri = t001g.no_seiri
--リコール名称
left join gold.vbi000004_en v0004 on v0004.cd_hansya = t001g.cd_hansya
and v0004.cd_kaisya = t001g.cd_kaisya
and v0004.no_seiri = t001g.no_seiri
left join (
	select
		t205m.cd_hansya,
		t205m.cd_kaisya,
		t205m.no_seiri,
		trim(t205m.mj_framekat) as mj_framekat,
		max(t205m.dd_tekkikst) as dd_tekkikst
	--リコール展開名称ＤＢ
	from ai21rep_ve_dx.tbfy205m t205m
	group by t205m.cd_hansya, t205m.cd_kaisya, t205m.no_seiri, trim(t205m.mj_framekat)
) t205m on t205m.cd_hansya = t001g.cd_hansya
and t205m.cd_kaisya = t001g.cd_kaisya
and t205m.no_seiri = t001g.no_seiri
and trim(t205m.mj_framekat) = trim(t001g.mj_framekat)
group by t001g.cd_hansya, t001g.cd_kaisya, t001g.cd_flwtenp, t001g.cd_nyuukoyt, t001g.no_seiri, t001g.mj_framekat, v0004.kj_recallme, t205m.dd_tekkikst
LIMIT 0;

-- [009/099] level=0 target=gold.vbi000006
-- Gold dependencies: none
-- Source file: 000_市場処置の実施状況と部品管理見える化/recallslim_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi000006 AS
select
	--販社コード
 	t003g.cd_hansya as `販社コード`,
 	--会社コード
 	t003g.cd_kaisya as `会社コード`,
 	--店舗コード
 	t003g.cd_tenpo as `店舗コード`,
 	--整理ＮＯ
	t003g.no_seiri as `整理ＮＯ`,
	--対象車両台数
	sum(t003g.su_taisyasu) as `対象車両台数`,
	--自店実施台数
	sum(t003g.su_jitejida) as `自店実施台数`,
	--他店実施台数
	sum(t003g.su_tatenjis) as `他店実施台数`,
	--他社実施台数
	sum(t003g.su_tasyjiss) as `他社実施台数`
--リコール店舗実施ＤＢ
from ai21rep_ve_dx.tbfj003g t003g
-- 店舗表示設定
left semi join dx_ve.tbi999003m t9003m on t9003m.cd_hansya = t003g.cd_hansya
and t9003m.cd_kaisya = t003g.cd_kaisya
and t9003m.cd_tenpo = t003g.cd_tenpo
and t9003m.mj_cyohyoid = '000'
and t9003m.kb_tenji = 1
--where t003g.no_seiri = '5GT31'
group by t003g.cd_hansya, t003g.cd_kaisya, t003g.cd_tenpo, t003g.no_seiri
LIMIT 0;

-- [010/099] level=0 target=gold.vbi000007
-- Gold dependencies: none
-- Source file: 000_市場処置の実施状況と部品管理見える化/recallslim_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi000007 AS
select
	--販社コード
 	t001g.cd_hansya as `販社コード`,
 	--会社コード
 	t001g.cd_kaisya as `会社コード`,
 	--店舗コード
 	ta001g.cd_tenpo as `店舗コード`,
 	--整理ＮＯ
	t001g.no_seiri as `整理ＮＯ`,
	--入庫予定日0
	concat(from_timestamp(ta001g.dt_nyuukoyt, 'yyyyMM'), '0') as `入庫予定日0`,
	--予約済台数
	count(*) as `予約済台数`
--リコールメインＤＢ
from ai21rep_ve_dx.tbfj001g t001g
inner join ai21rep_ve_dx.tbsa001g ta001g on ta001g.cd_hansya = t001g.cd_hansya
and ta001g.cd_kaisya = t001g.cd_kaisya
and ta001g.no_aijutyu = t001g.no_jucyu
-- 店舗表示設定
left semi join dx_ve.tbi999003m t9003m on t9003m.cd_hansya = ta001g.cd_hansya
and t9003m.cd_kaisya = ta001g.cd_kaisya
and t9003m.cd_tenpo = ta001g.cd_tenpo
and t9003m.mj_cyohyoid = '000'
and t9003m.kb_tenji = 1
--受注明細ＤＢ
inner join ai21rep_ve_dx.tbfa008g t008g on t008g.cd_hansya = t001g.cd_hansya
and t008g.cd_kaisya = t001g.cd_kaisya
and t008g.cd_tenpo = ta001g.cd_tenpo
and left(t008g.cd_seibi, 5) = t001g.no_seiri
and t008g.no_jucyu = t001g.no_jucyu
--リコール展開明細ＤＢ
left semi join ai21rep_ve_dx.tbfy206m t206m on t206m.cd_hansya = t001g.cd_hansya
and t206m.cd_kaisya = t001g.cd_kaisya
and t206m.no_seiri = t001g.no_seiri
and trim(t206m.mj_framekat) = trim(t001g.mj_framekat)
and t206m.kb_siharai = right(trim(t008g.cd_seibi), 1)
--入庫予定日が現在の日付から6ヶ月以内の範囲
where ta001g.dt_nyuukoyt > cast(from_utc_timestamp(utc_timestamp(), 'JST') as date)
and ta001g.dt_nyuukoyt < months_add(cast(from_utc_timestamp(utc_timestamp(), 'JST') as date), 6)
group by t001g.cd_hansya, t001g.cd_kaisya, ta001g.cd_tenpo, t001g.no_seiri, ta001g.dt_nyuukoyt
LIMIT 0;

-- [011/099] level=1 target=gold.vbi000008
-- Gold dependencies: gold.vbi000001_en, gold.vbi000002_en
-- Source file: 000_市場処置の実施状況と部品管理見える化/recallslim_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi000008 AS
select
	--販社コード
 	t001g.cd_hansya as `販社コード`,
 	--会社コード
 	t001g.cd_kaisya as `会社コード`,
 	--店舗コード
 	t001g.cd_tenpo as `店舗コード`,
 	--品番
	trim(t001g.mj_hinban) as `品番`,
	--在庫数
	sum(t001g.su_zaikosu) as `在庫数`,
	--発注数
	sum(t001g.su_hacyusu) as `発注数`
--部品在庫ＤＢ
from ai21rep_ve_dx.tbfb001g t001g
-- 店舗表示設定
left semi join dx_ve.tbi999003m t9003m on t9003m.cd_hansya = t001g.cd_hansya
and t9003m.cd_kaisya = t001g.cd_kaisya
and t9003m.cd_tenpo = t001g.cd_tenpo
and t9003m.mj_cyohyoid = '000'
and t9003m.kb_tenji = 1
--部品品名マスタ
left semi join gold.vbi000002_en v0002 on v0002.cd_hansya = t001g.cd_hansya
and v0002.cd_kaisya = t001g.cd_kaisya
and v0002.mj_toribhhn = trim(t001g.mj_hinban)
--店舗
left semi join gold.vbi000001_en v0001 on v0001.cd_hansya = t001g.cd_hansya
and v0001.cd_kaisya = t001g.cd_kaisya
and v0001.cd_tenpo = t001g.cd_tenpo
group by t001g.cd_hansya, t001g.cd_kaisya, t001g.cd_tenpo, trim(t001g.mj_hinban)
LIMIT 0;

-- [012/099] level=1 target=gold.vbi000009
-- Gold dependencies: gold.vbi000002_en
-- Source file: 000_市場処置の実施状況と部品管理見える化/recallslim_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi000009 AS
select
	--販社コード
	t206m.cd_hansya as `販社コード`,
	--会社コード
	t206m.cd_kaisya as `会社コード`,
	--整理ＮＯ
	t206m.no_seiri as `整理ＮＯ`,
	--フレーム型式
	t206m.mj_framekat as `フレーム型式`,
	--支払区分
	t206m.kb_siharai as `支払区分`,
	--取替部品品番
	trim(t206m.mj_toribhhn) as `取替部品品番`,
	--取替部品個数
	t206m.su_toribhsu as `取替部品個数`,
	--販社会社整理ＮＯフレーム型式支払区分
	concat(t206m.cd_hansya, t206m.cd_kaisya, t206m.no_seiri, trim(t206m.mj_framekat),t206m.kb_siharai) as `販社会社整理ＮＯフレーム型式支払区分`
--リコール展開明細ＤＢ
from ai21rep_ve_dx.tbfy206m t206m
--部品品名マスタ
left semi join gold.vbi000002_en v0002 on v0002.cd_hansya = t206m.cd_hansya
and v0002.cd_kaisya = t206m.cd_kaisya
and v0002.mj_toribhhn = trim(t206m.mj_toribhhn)
LIMIT 0;

-- [013/099] level=1 target=gold.vbi000010
-- Gold dependencies: gold.vbi000001_en
-- Source file: 000_市場処置の実施状況と部品管理見える化/recallslim_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi000010 AS
select
	--販社コード
	t001g.cd_hansya as `販社コード`,
 	--会社コード
 	t001g.cd_kaisya as `会社コード`,
 	--店舗コード
 	ta001g.cd_tenpo as `店舗コード`,
 	--整理ＮＯ
	t001g.no_seiri as `整理ＮＯ`,
	--フレーム型式
	t001g.mj_framekat as `フレーム型式`,
	--支払区分
	right(trim(t008g.cd_seibi), 1) as `支払区分`,
	--販社会社整理ＮＯフレーム型式支払区分
	concat(t001g.cd_hansya, t001g.cd_kaisya, t001g.no_seiri, trim(t001g.mj_framekat), right(trim(t008g.cd_seibi), 1)) as `販社会社整理ＮＯフレーム型式支払区分`,
	--入庫予定日0
	concat(from_timestamp(ta001g.dt_nyuukoyt, 'yyyyMM'), '0') as `入庫予定日0`,
	--台数
	count(*) as `台数`
--リコールメインＤＢ
from ai21rep_ve_dx.tbfj001g t001g
--ストール予約ＤＢ
inner join ai21rep_ve_dx.tbsa001g ta001g on ta001g.cd_hansya = t001g.cd_hansya
and ta001g.cd_kaisya = t001g.cd_kaisya
and ta001g.no_aijutyu = t001g.no_jucyu
--店舗
left semi join gold.vbi000001_en v0001 on v0001.cd_hansya = ta001g.cd_hansya
and v0001.cd_kaisya = ta001g.cd_kaisya
and v0001.cd_tenpo = ta001g.cd_tenpo
--受注明細ＤＢ
inner join ai21rep_ve_dx.tbfa008g t008g on t008g.cd_hansya = t001g.cd_hansya
and t008g.cd_kaisya = t001g.cd_kaisya
and t008g.cd_tenpo = ta001g.cd_tenpo
and left(t008g.cd_seibi, 5) = t001g.no_seiri
and t008g.no_jucyu = t001g.no_jucyu
--リコール展開明細ＤＢ
left semi join ai21rep_ve_dx.tbfy206m t206m on t206m.cd_hansya = t001g.cd_hansya
and t206m.cd_kaisya = t001g.cd_kaisya
and t206m.no_seiri = t001g.no_seiri
and trim(t206m.mj_framekat) = trim(t001g.mj_framekat)
and t206m.kb_siharai = right(trim(t008g.cd_seibi), 1)
--入庫予定日が現在の日付から6ヶ月以内の範囲
where ta001g.dt_nyuukoyt > cast(from_utc_timestamp(utc_timestamp(), 'JST') as date)
and ta001g.dt_nyuukoyt < months_add(cast(from_utc_timestamp(utc_timestamp(), 'JST') as date), 6)
group by t001g.cd_hansya, t001g.cd_kaisya, ta001g.cd_tenpo, t001g.no_seiri, t001g.mj_framekat, right(trim(t008g.cd_seibi), 1), ta001g.dt_nyuukoyt
LIMIT 0;

-- [014/099] level=1 target=gold.vbi000011
-- Gold dependencies: gold.vbi000002_en
-- Source file: 000_市場処置の実施状況と部品管理見える化/recallslim_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi000011 AS
select
	--販社コード
 	t206m.cd_hansya as `販社コード`,
 	--会社コード
 	t206m.cd_kaisya as `会社コード`,
 	--店舗コード
 	ta001g.cd_tenpo as `店舗コード`,
 	--取替部品品番
 	trim(t206m.mj_toribhhn) as `取替部品品番`,
 	--整理ＮＯ
	t206m.no_seiri as `整理ＮＯ`,
	--フレーム型式
 	t206m.mj_framekat as `フレーム型式`,
 	--支払区分
	right(trim(t008g.cd_seibi), 1) as `支払区分`,
	--販社会社整理ＮＯフレーム型式支払区分
	concat(t206m.cd_hansya, t206m.cd_kaisya, t206m.no_seiri, trim(t206m.mj_framekat), right(trim(t008g.cd_seibi), 1)) as `販社会社整理ＮＯフレーム型式支払区分`,
	--取替部品個数
	t206m.su_toribhsu as `取替部品個数`,
	--取替部品品名
	v0002.mj_torihnme as `取替部品品名`
--リコールメインＤＢ
from ai21rep_ve_dx.tbfj001g t001g
--ストール予約ＤＢ
inner join ai21rep_ve_dx.tbsa001g ta001g on ta001g.cd_hansya = t001g.cd_hansya
and ta001g.cd_kaisya = t001g.cd_kaisya
and ta001g.no_aijutyu = t001g.no_jucyu
-- 店舗表示設定
left semi join dx_ve.tbi999003m t9003m on t9003m.cd_hansya = ta001g.cd_hansya
and t9003m.cd_kaisya = ta001g.cd_kaisya
and t9003m.cd_tenpo = ta001g.cd_tenpo
and t9003m.mj_cyohyoid = '000'
and t9003m.kb_tenji = 1
--受注明細ＤＢ
inner join ai21rep_ve_dx.tbfa008g t008g on t008g.cd_hansya = t001g.cd_hansya
and t008g.cd_kaisya = t001g.cd_kaisya
and t008g.cd_tenpo = ta001g.cd_tenpo
and left(t008g.cd_seibi, 5) = t001g.no_seiri
and t008g.no_jucyu = t001g.no_jucyu
--リコール展開明細ＤＢ
inner join ai21rep_ve_dx.tbfy206m t206m on t206m.cd_hansya = t001g.cd_hansya
and t206m.cd_kaisya = t001g.cd_kaisya
and t206m.no_seiri = t001g.no_seiri
and trim(t206m.mj_framekat) = (t001g.mj_framekat)
and t206m.kb_siharai = right(trim(t008g.cd_seibi), 1)
and left(t206m.mj_toribhhn, 3) = '040'
--部品品名マスタ
left join gold.vbi000002_en v0002 on v0002.cd_hansya = t206m.cd_hansya
and v0002.cd_kaisya = t206m.cd_kaisya
and v0002.mj_toribhhn = trim(t206m.mj_toribhhn)
group by t206m.cd_hansya, t206m.cd_kaisya, ta001g.cd_tenpo, trim(t206m.mj_toribhhn), t206m.no_seiri, t206m.mj_framekat, right(trim(t008g.cd_seibi), 1), t206m.su_toribhsu, v0002.mj_torihnme
LIMIT 0;

-- [015/099] level=1 target=gold.vbi000012
-- Gold dependencies: gold.vbi000001_en
-- Source file: 000_市場処置の実施状況と部品管理見える化/recallslim_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi000012 AS
select
	--ソート順
	v0001.mj_sortjyun as `ソート順`,
	--販社コード
 	t001g.cd_hansya as `販社コード`,
 	--会社コード
 	t001g.cd_kaisya as `会社コード`,
 	--店舗コード
 	ta001g.cd_tenpo as `店舗コード`,
 	--店舗名称
 	v0001.kj_tenpomei as `店舗名称`,
 	--整理ＮＯ
	t001g.no_seiri as `整理ＮＯ`,
	--フレーム型式
	t001g.mj_framekat as `フレーム型式`,
	--フレームＮＯ
	t001g.no_frame as `フレームＮＯ`,
	--受注ＮＯ
	t001g.no_jucyu as `受注ＮＯ`,
	--入庫予定日時
	ta001g.dt_nyuukoyt as `入庫予定日時`,
	--販社会社整理ＮＯフレーム型式支払区分
	concat(t001g.cd_hansya, t001g.cd_kaisya, t001g.no_seiri, trim(t001g.mj_framekat), right(trim(t008g.cd_seibi), 1)) as `販社会社整理ＮＯフレーム型式支払区分`,
	--入庫予定日0
	concat(from_timestamp(ta001g.dt_nyuukoyt, 'yyyyMM'), '0') as `入庫予定日0`,
	--台数
	1 as `台数`
--リコールメインＤＢ
from ai21rep_ve_dx.tbfj001g t001g
--ストール予約ＤＢ
inner join ai21rep_ve_dx.tbsa001g ta001g on ta001g.cd_hansya = t001g.cd_hansya
and ta001g.cd_kaisya = t001g.cd_kaisya
and ta001g.no_aijutyu = t001g.no_jucyu
--受注明細ＤＢ
inner join ai21rep_ve_dx.tbfa008g t008g on t008g.cd_hansya = ta001g.cd_hansya
and t008g.cd_kaisya = ta001g.cd_kaisya
and t008g.cd_tenpo = ta001g.cd_tenpo
and left(t008g.cd_seibi, 5) = t001g.no_seiri
and t008g.no_jucyu = t001g.no_jucyu
--リコール展開明細ＤＢ
left semi join ai21rep_ve_dx.tbfy206m t206m on t206m.cd_hansya = t001g.cd_hansya
and t206m.cd_kaisya = t001g.cd_kaisya
and t206m.no_seiri = t001g.no_seiri
and trim(t206m.mj_framekat) = trim(t001g.mj_framekat)
and t206m.kb_siharai = right(trim(t008g.cd_seibi), 1)
--店舗
inner join gold.vbi000001_en v0001 on v0001.cd_hansya =  ta001g.cd_hansya
and v0001.cd_kaisya = ta001g.cd_kaisya
and v0001.cd_tenpo = ta001g.cd_tenpo
--入庫予定日が現在の日付から6ヶ月以内の範囲
where ta001g.dt_nyuukoyt > cast(from_utc_timestamp(utc_timestamp(), 'JST') as date)
and ta001g.dt_nyuukoyt < months_add(cast(from_utc_timestamp(utc_timestamp(), 'JST') as date), 6)
LIMIT 0;

-- [016/099] level=1 target=gold.vbi000013
-- Gold dependencies: gold.vbi000001_en, gold.vbi000002_en
-- Source file: 000_市場処置の実施状況と部品管理見える化/recallslim_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi000013 AS
select
	--ソート順
	v0001.mj_sortjyun as `ソート順`,
	--販社コード
 	t001g.cd_hansya as `販社コード`,
 	--会社コード
 	t001g.cd_kaisya as `会社コード`,
 	--店舗コード
 	t001g.cd_tenpo as `店舗コード`,
 	--店舗名称
 	v0001.kj_tenpomei as `店舗名称`,
 	--品番
 	trim(t001g.mj_hinban) as `品番`,
 	--品名
 	t001g.mj_hinmei as `品名`,
 	--在庫数
 	t001g.su_zaikosu as `在庫数`
--部品在庫ＤＢ
from ai21rep_ve_dx.tbfb001g t001g
--部品品名マスタ
left semi join gold.vbi000002_en v0002 on v0002.cd_hansya = t001g.cd_hansya
and v0002.cd_kaisya = t001g.cd_kaisya
and v0002.mj_toribhhn = trim(t001g.mj_hinban)
--店舗
inner join gold.vbi000001_en v0001 on v0001.cd_hansya = t001g.cd_hansya
and v0001.cd_kaisya = t001g.cd_kaisya
and v0001.cd_tenpo = t001g.cd_tenpo
--在庫数>0
where t001g.su_zaikosu > 0
LIMIT 0;

-- [017/099] level=0 target=gold.vbi001001
-- Gold dependencies: none
-- Source file: 001_新車車両日報/新車車両日報_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi001001 AS
SELECT
	--販社コード
	cd_hansya,
	--会社コード
	cd_kaisya,
	--店舗コード
	cd_tenpo,
	--日付
    CAST(to_date(dd_date) AS DATE) AS dd_date,
	--車名コード
	cd_ncsyamei,
	--車名
	kn_syame,
	--新車受注実績
	NULLIFZERO(SUM(su_sinsya_jucyu)) AS su_sinsya_jucyu,
	--新車受注取消
	NULLIFZERO(SUM(su_sinsya_jucyu_torikesi)) AS su_sinsya_jucyu_torikesi,
	--新車受注合計
	NULLIFZERO(SUM(su_sinsya_jucyu) - SUM(su_sinsya_jucyu_torikesi)) AS su_sinsya_jucyu_goukei,
	--新車受注残
	NULLIFZERO(SUM(su_sinsya_jucyucan)) AS su_sinsya_jucyucan
FROM
	(
	SELECT
		--販社コード
		tg.cd_hansya,
		--会社コード
		tg.cd_kaisya,
		--店舗コード
		tg.cd_tenpo,
		--日付
		tg.dd_jucyuke AS dd_date,
		--車名コード
		tbbf001m.cd_ncsyamei,
		--車名
		UPPER(NVL(tbbf001m.kn_syame, '')) AS kn_syame,
		--新車受注実績
        CASE
			WHEN tg.dd_jucyuke IS NOT NULL THEN 1
			ELSE 0
		END AS su_sinsya_jucyu,
		--新車受注取消
        0 AS su_sinsya_jucyu_torikesi,
        --新車受注残
		CASE
			WHEN tg.dd_jucyuke IS NOT NULL
			AND tg.dd_touroku IS NULL THEN 1
			ELSE 0
		END AS su_sinsya_jucyucan
	FROM
		ai21rep_ve_dx.tbba001g tg	-- 新車受注基本情報ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbbf008m tbbf008m	-- 車両スペック２ＤＢ
        ON
		tg.cd_kaisya = tbbf008m.cd_kaisya
		AND tg.cd_hansya = tbbf008m.cd_hansya
		AND tg.mj_sinkysed = tbbf008m.mj_sinkysed
		AND tg.mj_gaihansy = tbbf008m.cd_spec
		AND tg.mj_hantenkt = tbbf008m.mj_hantenkt
		-- スペック区分が 「G」 である
		AND tbbf008m.kb_spec = 'G'
	LEFT JOIN ai21rep_ve_dx.tbbf001m tbbf001m -- 車名ＤＢ
        ON
		tbbf001m.cd_kaisya = tbbf008m.cd_kaisya
		AND tbbf001m.cd_hansya = tbbf008m.cd_hansya
		AND tbbf001m.cd_ncsyamei = tbbf008m.mj_syamei
	WHERE
		-- 払出区分が　「00」　「40」　以外である
		tg.kb_haraidas NOT IN ('00', '40')
		-- 受注計上日が空ではない
		AND tg.dd_jucyuke IS NOT NULL
		-- 受注計上日が前月1日より大きい
		AND from_timestamp(tg.dd_jucyuke, 'yyyyMM') >= from_timestamp(
            add_months(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 
            'yyyyMM'
        )
UNION ALL
	SELECT
		--販社コード
		tg.cd_hansya,
		--会社コード
		tg.cd_kaisya,
		--店舗コード
		tg.cd_tenpo,
		--日付
		tg.dd_torikesi AS dd_date,
		--車名コード
		tbbf001m.cd_ncsyamei,
		--車名
		UPPER(NVL(tbbf001m.kn_syame, '')) AS kn_syame,
		--新車受注実績
		0 AS su_sinsya_jucyu,
		--新車受注取消
		CASE
			WHEN tg.dd_torikesi IS NOT NULL THEN 1
			ELSE 0
		END AS su_sinsya_jucyu_torikesi,
		--新車受注残
		0 AS su_sinsya_jucyucan
	FROM
		ai21rep_ve_dx.tbba001g tg -- 新車受注基本情報ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbbf008m tbbf008m -- 車両スペック２ＤＢ
        ON
		tg.cd_kaisya = tbbf008m.cd_kaisya
		AND tg.cd_hansya = tbbf008m.cd_hansya
		AND tg.mj_sinkysed = tbbf008m.mj_sinkysed
		AND tg.mj_gaihansy = tbbf008m.cd_spec
		AND tg.mj_hantenkt = tbbf008m.mj_hantenkt
		-- スペック区分が 「G」 である
		AND tbbf008m.kb_spec = 'G'
	LEFT JOIN ai21rep_ve_dx.tbbf001m tbbf001m -- 車名ＤＢ
        ON
		tbbf001m.cd_kaisya = tbbf008m.cd_kaisya
		AND tbbf001m.cd_hansya = tbbf008m.cd_hansya
		AND tbbf001m.cd_ncsyamei = tbbf008m.mj_syamei
	WHERE
		-- 払出区分が　「00」　「40」　以外である
		tg.kb_haraidas NOT IN ('00', '40')
		-- 取消日が空ではない
		AND tg.dd_torikesi IS NOT NULL
		-- 取消日が前月1日より大きい
		AND from_timestamp(tg.dd_torikesi, 'yyyyMM') >= from_timestamp(
            add_months(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 
            'yyyyMM'
        )
) combined
GROUP BY
	cd_hansya,
	cd_kaisya,
	cd_tenpo,
	to_date(dd_date),
	cd_ncsyamei,
	kn_syame
LIMIT 0;

-- [018/099] level=0 target=gold.vbi001002
-- Gold dependencies: none
-- Source file: 001_新車車両日報/新車車両日報_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi001002 AS
SELECT
	--販社コード
    cd_hansya,
    --会社コード
    cd_kaisya,
    --店舗コード
    cd_tenpo,
    --車名コード
    cd_ncsyamei,
    --車名
    kn_syame,
    --日付
    CAST(to_date(dd_date) AS DATE) AS dd_date,
    --新車販売実績
    NULLIFZERO(SUM(su_sinsya_hanbai)) AS su_sinsya_hanbai,
    --新車販売取消
    NULLIFZERO(SUM(su_sinsya_torikesi)) AS su_sinsya_hanbai_torikesi,
    --新車販売合計
    NULLIFZERO(SUM(su_sinsya_hanbai) - SUM(su_sinsya_torikesi)) AS su_sinsya_hanbai_goukei
FROM (
    SELECT 
    	--販社コード
        tg.cd_hansya,
        --会社コード
        tg.cd_kaisya,
        --店舗コード
        tg.cd_tenpo,
        --車名コード
        tbbf001m.cd_ncsyamei,
        --車名
        UPPER(NVL(tbbf001m.kn_syame, '')) AS kn_syame,
        --日付
        (CASE 
            WHEN ft168g.dd_torokei IS NULL THEN tg.dd_uriagekj 
            ELSE ft168g.dd_torokei 
         END) AS dd_date,
        --新車販売実績
        COUNT(*) AS su_sinsya_hanbai,
        --新車販売取消
        0 AS su_sinsya_torikesi
    FROM ai21rep_ve_dx.tbba001g tg  -- 新車受注基本情報ＤＢ
    LEFT JOIN ai21rep_ve_dx.tbbf008m tbbf008m  -- 車両スペック２ＤＢ
        ON tg.cd_kaisya = tbbf008m.cd_kaisya 
        AND tg.cd_hansya = tbbf008m.cd_hansya 
        AND tg.mj_sinkysed = tbbf008m.mj_sinkysed 
        AND tg.mj_gaihansy = tbbf008m.cd_spec 
        AND tg.mj_hantenkt = tbbf008m.mj_hantenkt
        -- スペック区分が 「G」 である
        AND tbbf008m.kb_spec = 'G'
    LEFT JOIN ai21rep_ve_dx.tbbf001m tbbf001m  -- 車名ＤＢ
        ON tbbf001m.cd_kaisya = tbbf008m.cd_kaisya 
        AND tbbf001m.cd_hansya = tbbf008m.cd_hansya 
        AND tbbf001m.cd_ncsyamei = tbbf008m.mj_syamei
    LEFT JOIN (
        SELECT 
            t168g.cd_hansya,
            t168g.cd_kaisya,
            t168g.no_cyumon,
            MIN(t168g.dd_torokei) AS dd_torokei
        FROM ai21rep_ve_dx.tbbg168g t168g  -- 履歴登録ＤＢ
        WHERE 
            -- 業務ＮＯが 07 である
            t168g.no_gyomu = '07' 
            -- 処理ＮＯが 01 である
            AND t168g.no_syori = '01'
        GROUP BY 
            t168g.cd_hansya,
            t168g.cd_kaisya,
            t168g.no_cyumon
    ) ft168g 
        ON ft168g.cd_kaisya = tg.cd_kaisya 
        AND ft168g.cd_hansya = tg.cd_hansya 
        AND ft168g.no_cyumon = tg.no_cyumon
    WHERE
        -- 払出区分が　「00」　「40」　以外である 
        tg.kb_haraidas NOT IN ('00', '40') 
        -- 受注計上日が空ではない
        AND tg.dd_jucyuke IS NOT NULL 
        AND (
            (-- 登録計上日が空である
            ft168g.dd_torokei IS NULL
            -- 売上計上日が前月1日より大きい
                AND from_timestamp(tg.dd_uriagekj, 'yyyyMM') >= from_timestamp(add_months(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'yyyyMM')
            ) 
            OR ( -- 登録計上日が空ではない
            ft168g.dd_torokei IS NOT NULL 
             -- 登録計上日が前月1日より大きい
                AND from_timestamp(ft168g.dd_torokei, 'yyyyMM') >= from_timestamp(add_months(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'yyyyMM')
            )
        )
    GROUP BY 
        tg.cd_hansya,
        tg.cd_kaisya,
        tg.cd_tenpo,
        dd_date,
        tbbf001m.cd_ncsyamei,
        NVL(tbbf001m.kn_syame, '')
    UNION ALL
    SELECT
    	--販社コード
        tg.cd_hansya,
        --会社コード
        tg.cd_kaisya,
        --店舗コード
        tg.cd_tenpo,
        --車名コード
        tbbf001m.cd_ncsyamei,
        --車名
        UPPER(NVL(tbbf001m.kn_syame, '')) AS kn_syame,
        --日付
        tg.dd_uritrkkj AS dd_date,
        --新車販売実績
        0 AS su_sinsya_hanbai,
        --新車販売取消
        COUNT(*) AS su_sinsya_torikesi
    FROM ai21rep_ve_dx.tbba001g tg  -- 新車受注基本情報ＤＢ
    LEFT JOIN ai21rep_ve_dx.tbbf008m tbbf008m   -- 車両スペック２ＤＢ
        ON tg.cd_kaisya = tbbf008m.cd_kaisya 
        AND tg.cd_hansya = tbbf008m.cd_hansya 
        AND tg.mj_sinkysed = tbbf008m.mj_sinkysed 
        AND tg.mj_gaihansy = tbbf008m.cd_spec 
        AND tg.mj_hantenkt = tbbf008m.mj_hantenkt
        -- スペック区分が 「G」 である
        AND tbbf008m.kb_spec = 'G'
    LEFT JOIN ai21rep_ve_dx.tbbf001m tbbf001m  -- 車名ＤＢ
        ON tbbf001m.cd_kaisya = tbbf008m.cd_kaisya 
        AND tbbf001m.cd_hansya = tbbf008m.cd_hansya 
        AND tbbf001m.cd_ncsyamei = tbbf008m.mj_syamei
    WHERE 
        -- 払出区分が　「00」　「40」　以外である 
        tg.kb_haraidas NOT IN ('00', '40') 
         -- 受注計上日が空ではない
        AND tg.dd_jucyuke IS NOT NULL 
        -- 売上取消計上日が前月1日より大きい
        AND from_timestamp(tg.dd_uritrkkj, 'yyyyMM') >= from_timestamp(add_months(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'yyyyMM')
    GROUP BY 
        tg.cd_hansya,
        tg.cd_kaisya,
        tg.cd_tenpo,
        tbbf001m.cd_ncsyamei,
        NVL(tbbf001m.kn_syame, ''),
        tg.dd_uritrkkj
) combined
GROUP BY 
    cd_hansya,
    cd_kaisya,
    cd_tenpo,
    to_date(dd_date),
    cd_ncsyamei,
    kn_syame
LIMIT 0;

-- [019/099] level=1 target=gold.VBI001003
-- Gold dependencies: gold.vbi001001, gold.vbi001002
-- Source file: 001_新車車両日報/新車車両日報_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI001003 AS
SELECT
	--販社コード
	cd_hansya AS 販社コード,
	--会社コード
	cd_kaisya AS 会社コード,
	--店舗コード
	cd_tenpo AS 店舗コード,
	--車名
	kn_syame AS 車名,
	--店舗名称
	kj_tenpomei AS 店舗名称,
	--店舗短縮名称
	kj_tentanms AS 店舗短縮名称,
	--ゾーンコード
	cd_zon AS ゾーンコード,
	--ゾーン名称
	kj_zonmei AS ゾーン名称,
	--新車受注実績
	su_sinsya_jucyu AS 新車受注実績,
	--新車受注取消
	su_sinsya_jucyu_torikesi AS 新車受注取消,
	--新車受注合計
	su_sinsya_jucyu_goukei AS 新車受注合計,
	--新車受注残
	su_sinsya_jucyucan AS 新車受注残,
	--新車販売実績
	su_sinsya_hanbai AS 新車販売実績,
	--新車販売取消
	su_sinsya_hanbai_torikesi AS 新車販売取消,
	--新車販売合計
	su_sinsya_hanbai_goukei AS 新車販売合計,
	--受注日付
	dd_jucyu AS 受注日付,
	--新車販売日付
	dd_sinsya_hanbai AS 新車販売日付,
	--店舗ソート順
	DENSE_RANK() OVER (
    	PARTITION BY cd_hansya,cd_kaisya
		ORDER BY cd_zon,mj_sortjyun
    ) AS 店舗ソート順,
	--車名ソート順
    DENSE_RANK() OVER (
    	PARTITION BY cd_hansya,cd_kaisya
		ORDER BY sort_sin,syamei_sin,kn_syame
    ) AS 車名ソート順
FROM
	(
SELECT 
    t201m.cd_hansya,
    t201m.cd_kaisya,
    t201m.cd_tenpo,
    syame.kn_syame,
    t201m.kj_tenpomei,
    t201m.kj_tentanms,
    IF(
    	t033m.kj_zonmei IS NULL OR regexp_replace(t033m.kj_zonmei, '[ 　]+', '') = '',
    	'999999',
    	IF(
        	t033m.cd_zon IS NULL OR regexp_replace(t033m.cd_zon, '[ 　]+', '') = '',
        	'999998',
        	t033m.cd_zon
    	)
	) AS cd_zon,
    t033m.kj_zonmei,
    syame.su_sinsya_jucyu AS su_sinsya_jucyu,
    syame.su_sinsya_jucyu_torikesi AS su_sinsya_jucyu_torikesi,
    syame.su_sinsya_jucyu_goukei AS su_sinsya_jucyu_goukei,
    syame.su_sinsya_jucyucan AS su_sinsya_jucyucan,
    syame.su_sinsya_hanbai AS su_sinsya_hanbai,
    syame.su_sinsya_hanbai_torikesi AS su_sinsya_hanbai_torikesi,
    syame.su_sinsya_hanbai_goukei AS su_sinsya_hanbai_goukei,
    syame.dd_jucyu,
    syame.dd_sinsya_hanbai,
    RANK() OVER (
        PARTITION BY t201m.cd_hansya, t201m.cd_kaisya 
        ORDER BY tbi999003m.mj_sortjyun, t201m.cd_tenpo
    ) AS mj_sortjyun,
    --新車ソート順
		MIN(sort_car_sin.mj_sortjyun) OVER ( PARTITION BY t201m.cd_hansya, t201m.cd_kaisya, sort_car_sin.kn_syamei ) AS sort_sin,
    --新車車名ソート順
		MIN(sort_car_sin.cd_ncsyamei) OVER ( PARTITION BY t201m.cd_hansya, t201m.cd_kaisya, sort_car_sin.kn_syamei ) AS syamei_sin
FROM ai21rep_ve_dx.tbv0201m t201m --共通店舗ＤＢ
LEFT JOIN dx_ve.tbi999003m tbi999003m --店舗表示設定
    ON t201m.cd_hansya = tbi999003m.cd_hansya
    AND t201m.cd_kaisya = tbi999003m.cd_kaisya
    AND t201m.cd_tenpo = tbi999003m.cd_tenpo
    AND tbi999003m.mj_cyohyoid = '001'
LEFT JOIN ai21rep_ve_dx.tbv0047m t047m --M車両店舗ＤＢ
    ON t047m.cd_hansya = t201m.cd_hansya
    AND t047m.cd_kaisya = t201m.cd_kaisya
    AND t047m.cd_tenpo = t201m.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbv0033m t033m --MゾーンコードＤＢ
    ON t033m.cd_hansya = t201m.cd_hansya
    AND t033m.cd_kaisya = t201m.cd_kaisya
    AND t033m.cd_zon = t047m.cd_nczon
    AND t033m.kb_syohin = '1'
LEFT JOIN (
    SELECT 
        all_view.cd_hansya,
        all_view.cd_kaisya,
        all_view.cd_tenpo,
        all_view.kn_syame,
        SUM(su_sinsya_jucyu) AS su_sinsya_jucyu,
        SUM(su_sinsya_jucyu_torikesi) AS su_sinsya_jucyu_torikesi,
        SUM(su_sinsya_jucyu_goukei) AS su_sinsya_jucyu_goukei,
        SUM(su_sinsya_jucyucan) AS su_sinsya_jucyucan,
        SUM(su_sinsya_hanbai) AS su_sinsya_hanbai,
        SUM(su_sinsya_hanbai_torikesi) AS su_sinsya_hanbai_torikesi,
        SUM(su_sinsya_hanbai_goukei) AS su_sinsya_hanbai_goukei,
        dd_jucyu,
        dd_sinsya_hanbai
    FROM (
        -- 新車受注
        SELECT 
            v1.cd_hansya,
            v1.cd_kaisya,
            v1.cd_tenpo,
            v1.cd_ncsyamei,
            v1.kn_syame,
            v1.su_sinsya_jucyu,
            v1.su_sinsya_jucyu_torikesi,
            v1.su_sinsya_jucyu_goukei,
            v1.su_sinsya_jucyucan,
            NULL AS su_jusya_jucyu,
            NULL AS su_jusya_jucyu_torikesi,
            NULL AS su_jusya_jucyu_goukei,
            NULL AS su_jusya_jucyucan,
            NULL AS su_sinsya_hanbai,
            NULL AS su_sinsya_hanbai_torikesi,
            NULL AS su_sinsya_hanbai_goukei,
            NULL AS su_jusya_hanbai,
            NULL AS su_jusya_hanbai_torikesi,
            NULL AS su_jusya_hanbai_goukei,
            NULL AS su_jusya_hanbai_current,
            NULL AS su_jusya_hanbai_mikomi,
            v1.dd_date AS dd_jucyu,
            NULL AS dd_sinsya_hanbai,
            NULL AS dd_jusya_hanbai,
            NULL AS dd_jusya_mikomi
        FROM gold.vbi001001 v1        
        UNION ALL        
        -- 新車販売
        SELECT 
            v2.cd_hansya,
            v2.cd_kaisya,
            v2.cd_tenpo,
            v2.cd_ncsyamei,
            v2.kn_syame,
            NULL AS su_sinsya_jucyu,
            NULL AS su_sinsya_jucyu_torikesi,
            NULL AS su_sinsya_jucyu_goukei,
            NULL AS su_sinsya_jucyucan,
            NULL AS su_jusya_jucyu,
            NULL AS su_jusya_jucyu_torikesi,
            NULL AS su_jusya_jucyu_goukei,
            NULL AS su_jusya_jucyucan,
            v2.su_sinsya_hanbai,
            v2.su_sinsya_hanbai_torikesi,
            v2.su_sinsya_hanbai_goukei,
            NULL AS su_jusya_hanbai,
            NULL AS su_jusya_hanbai_torikesi,
            NULL AS su_jusya_hanbai_goukei,
            NULL AS su_jusya_hanbai_current,
            NULL AS su_jusya_hanbai_mikomi,
            NULL AS dd_jucyu,
            v2.dd_date AS dd_sinsya_hanbai,
            NULL AS dd_jusya_hanbai,
            NULL AS dd_jusya_mikomi
        FROM gold.vbi001002 v2
    ) all_view
    LEFT JOIN dx_ve.tbi999008m tbi999008m --新車車種表示設定
        ON tbi999008m.cd_hansya = all_view.cd_hansya
        AND tbi999008m.cd_kaisya = all_view.cd_kaisya
        AND tbi999008m.cd_ncsyamei = all_view.cd_ncsyamei
        AND tbi999008m.kb_tenji = 1
    WHERE
    	--販社コードが空ではない
    	tbi999008m.cd_hansya IS NOT NULL
    GROUP BY 
        cd_hansya,
        cd_kaisya,
        cd_tenpo,
        kn_syame,
        dd_jucyu,
        dd_sinsya_hanbai
) syame 
    ON t201m.cd_hansya = syame.cd_hansya
    AND t201m.cd_kaisya = syame.cd_kaisya
    AND t201m.cd_tenpo = syame.cd_tenpo
LEFT JOIN (SELECT	
				 tbi999008m.cd_hansya,
				 tbi999008m.cd_kaisya,
				 TRIM(tbi999008m.kn_syamei) AS kn_syamei,
				 MIN(tbi999008m.mj_sortjyun) AS mj_sortjyun,
				 MIN(tbi999008m.cd_ncsyamei) AS cd_ncsyamei
 		FROM dx_ve.tbi999008m --新車車種表示設定
		WHERE
			--表示区分が 「1」 である
			tbi999008m.kb_tenji = 1
		GROUP BY 
			tbi999008m.cd_hansya,
			tbi999008m.cd_kaisya,
			TRIM(tbi999008m.kn_syamei)
		) sort_car_sin
	ON syame.cd_hansya = sort_car_sin.cd_hansya
    AND syame.cd_kaisya = sort_car_sin.cd_kaisya
	AND TRIM(syame.kn_syame) = TRIM(sort_car_sin.kn_syamei)
WHERE
	--表示区分が 「1」 である
	tbi999003m.kb_tenji = 1
) sinsya_nippou
LIMIT 0;

-- [020/099] level=0 target=gold.vbi002001_en
-- Gold dependencies: none
-- Source file: 002_新車売掛金/VBI002001_新車売掛金店舗別_en_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi002001_en AS
--販社コードがTMTの店舗
SELECT
    main_table.su_store_number, --店舗数
    main_table.cd_hansya_kaisya_tenpo, --販社会社店舗コード
	main_table.cd_hansya_kaisya_zon_tenpo, --販社会社ゾーン店舗コード
	main_table.cd_hansya, --販社コード
	main_table.cd_kaisya, --会社コード
	main_table.cd_tenpo, --店舗コード
	main_table.kj_tenpomei, --店舗名称
	main_table.kj_tentanms, --店舗短縮名称
    IF(main_table.zone_name_abbreviation IS NULL OR regexp_replace(main_table.zone_name_abbreviation, '[ 　]+', '') = '','999999',IF(main_table.cd_zon IS NULL OR regexp_replace(main_table.cd_zon, '[ 　]+', '') = '','999998',main_table.cd_zon)) AS cd_zon, --ゾーンコード
    main_table.cd_nczon, --ンゾン
    main_table.kj_zonmei, --ゾーン名称
	main_table.zone_name_abbreviation, --ゾーン名略
	main_table.sort_order --ソート順
FROM(
    SELECT
        1 AS su_store_number, --店舗数
    	CONCAT(tbv201m.cd_hansya, tbv201m.cd_kaisya, tbv201m.cd_tenpo) AS cd_hansya_kaisya_tenpo, --販社会社店舗コード
    	IF(tntenpo.cd_zon IS NOT NULL,CONCAT(tbv201m.cd_hansya, tbv201m.cd_kaisya,tntenpo.cd_zon, tbv201m.cd_tenpo),CONCAT(tbv201m.cd_hansya, tbv201m.cd_kaisya,tbv003m.cd_zon, tbv201m.cd_tenpo)) AS cd_hansya_kaisya_zon_tenpo, --販社会社ゾーン店舗コード
    	tbv201m.cd_hansya, --販社コード
    	tbv201m.cd_kaisya, --会社コード
    	tbv201m.cd_tenpo, --店舗コード
    	tbv201m.kj_tenpomei, --店舗名称
    	tbv201m.kj_tentanms, --店舗短縮名称
        NVL(tntenpo.cd_zon,tbv003m.cd_zon) AS cd_zon, --ゾーンコード
        NVL(tntenpo.cd_zon,tbv0047m.cd_nczon) AS cd_nczon, --ンゾン
        NVL(tbv003m1.kj_zonmei,tbv003m.kj_zonmei) AS kj_zonmei, --ゾーン名称
    	CASE
    	    WHEN tbv003m1.kj_zonmei IS NOT NULL AND (LEFT(CAST (tbv003m1.kj_zonmei AS STRING), 3) = 'ト' OR LEFT (CAST (tbv003m1.kj_zonmei AS STRING), 3) = 'レ') AND RIGHT (CAST (tbv003m1.kj_zonmei AS STRING), 6) = 'エ統'
            THEN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SUBSTR(CAST (tbv003m1.kj_zonmei AS STRING), 1, 9), 'レ', 'L-'), 'ト', 'T-'), '０', '0'), '１', '1'), '２', '2'), '３', '3'), '４', '4'), '５', '5'), '６', '6'), '７', '7'), '８', '8'), '９', '9')
            WHEN tbv003m1.kj_zonmei IS NOT NULL
            THEN TRIM(REPLACE(CAST(tbv003m1.kj_zonmei AS STRING), '　', ' '))
            WHEN (LEFT(CAST (tbv003m.kj_zonmei AS STRING), 3) = 'ト' OR LEFT (CAST (tbv003m.kj_zonmei AS STRING), 3) = 'レ') AND RIGHT (CAST (tbv003m.kj_zonmei AS STRING), 6) = 'エ統'
            THEN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SUBSTR(CAST (tbv003m.kj_zonmei AS STRING), 1, 9), 'レ', 'L-'), 'ト', 'T-'), '０', '0'), '１', '1'), '２', '2'), '３', '3'), '４', '4'), '５', '5'), '６', '6'), '７', '7'), '８', '8'), '９', '9')
            ELSE TRIM(REPLACE(CAST(tbv003m.kj_zonmei AS STRING), '　', ' '))
    	END AS zone_name_abbreviation, --ゾーン名略
    	RANK() OVER (PARTITION BY tbv201m.cd_hansya,tbv201m.cd_kaisya ORDER BY NVL(tntenpo.cd_zon,tbv003m.cd_zon), tbi999003m.mj_sortjyun, tbv201m.cd_tenpo) AS sort_order --ソート順
    FROM
    	ai21rep_ve_dx.tbv0201m tbv201m --共通店舗DB
    LEFT JOIN dx_ve.tbi999003m tbi999003m --店舗展示設定
    	ON tbv201m.cd_hansya = tbi999003m.cd_hansya
    	AND tbv201m.cd_kaisya = tbi999003m.cd_kaisya
    	AND tbv201m.cd_tenpo = tbi999003m.cd_tenpo
    	AND tbi999003m.mj_cyohyoid = "002" --帳票ＩＤが002
    LEFT JOIN ai21rep_ve_dx.tbv0047m tbv0047m --M車両店舗DB
    	ON tbv0047m.cd_hansya = '03601' --販社コードがTMT
    	AND tbv0047m.cd_kaisya = '01' --会社コードが01
    	AND tbv0047m.cd_tenpo = tbv201m.cd_tenpo
    LEFT JOIN ai21rep_ve_dx.tbv0033m tbv003m --MゾーンコードDB
    	ON tbv003m.cd_hansya = '03601' --販社コードがTMT
    	AND tbv003m.cd_kaisya = '01' --会社コードが01
    	AND tbv003m.cd_zon = tbv0047m.cd_nczon
    	AND tbv003m.kb_syohin = '1' --新車商品区分が１
    LEFT JOIN dx_ve.tbi002003m tntenpo --手入力店舗所属
    	ON tntenpo.cd_hansya = '03601' --販社コードがTMT
    	AND tntenpo.cd_kaisya = '01' --会社コードが01
    	AND tntenpo.cd_tenpo = tbv201m.cd_tenpo
    LEFT JOIN ai21rep_ve_dx.tbv0033m tbv003m1 --MゾーンコードDB
    	ON tbv003m1.cd_hansya = '03601' --販社コードがTMT
    	AND tbv003m1.cd_kaisya = '01' --会社コードが01
    	AND tntenpo.cd_zon = tbv003m1.cd_zon
    WHERE
    	tbi999003m.kb_tenji = 1 --店舗展示設定
    	AND tbv201m.kj_tenpomei NOT LIKE '%廃）%' --店舗.店舗名称が"廃）"を含まない
    	AND tbv201m.cd_hansya = '03601' --販社コードがTMT
    	AND tbv201m.cd_kaisya = '01' --会社コードが01
    	AND (tbv003m.cd_zon IN ('01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','30','31','32','33','60','90') --トヨタ０１～トヨタ１５、Ｌ１統括部～Ｌ４統括部を削除
        OR SUBSTRING(tbv003m.cd_zon, 1, 3) = 'TK_') --TK_01、TK_02は手入力店舗の所属.xlsxの特約店、タクシー部
    	AND tbv201m.cd_tenpo NOT IN ( 'T01','T02','T03','T04','T05','T06','T07','T08','T09','T10','T11','T12','T13','T14','T15','L01','L02','L03','L04') --店舗コード制限
    UNION ALL
    --販社コードがTMT以外の店舗
    SELECT
    	1 AS su_store_number, --店舗数
    	CONCAT(tbv201m.cd_hansya, tbv201m.cd_kaisya, tbv201m.cd_tenpo) AS cd_hansya_kaisya_tenpo, --販社会社店舗コード
        IF(tntenpo.cd_zon IS NOT NULL,CONCAT(tbv201m.cd_hansya, tbv201m.cd_kaisya,tntenpo.cd_zon, tbv201m.cd_tenpo),CONCAT(tbv201m.cd_hansya, tbv201m.cd_kaisya,tbv003m.cd_zon, tbv201m.cd_tenpo)) AS cd_hansya_kaisya_zon_tenpo, --販社会社ゾーン店舗コード
    	tbv201m.cd_hansya, --販社コード
    	tbv201m.cd_kaisya, --会社コード
    	tbv201m.cd_tenpo, --店舗コード
    	tbv201m.kj_tenpomei, --店舗名称
    	tbv201m.kj_tentanms, --店舗短縮名称
        NVL(tntenpo.cd_zon,tbv003m.cd_zon) AS cd_zon, --ゾーンコード
        NVL(tntenpo.cd_zon,tbv0047m.cd_nczon) AS cd_nczon, --ンゾン
        NVL(tbv003m1.kj_zonmei,tbv003m.kj_zonmei) AS kj_zonmei, --ゾーン名称
    	NVL(tbv003m1.kj_zonmei,tbv003m.kj_zonmei) AS zone_name_abbreviation, --ゾーン名略
    	RANK() OVER (PARTITION BY tbv201m.cd_hansya,tbv201m.cd_kaisya ORDER BY NVL(tntenpo.cd_zon,tbv003m.cd_zon), tbi999003m.mj_sortjyun, tbv201m.cd_tenpo) AS sort_order --ソート順
    FROM
    	ai21rep_ve_dx.tbv0201m tbv201m --共通店舗DB
    LEFT JOIN dx_ve.tbi999003m tbi999003m --店舗展示設定
    	ON tbv201m.cd_hansya = tbi999003m.cd_hansya
    	AND tbv201m.cd_kaisya = tbi999003m.cd_kaisya
    	AND tbv201m.cd_tenpo = tbi999003m.cd_tenpo
    	AND tbi999003m.mj_cyohyoid = "002" --帳票ＩＤが002
    LEFT JOIN ai21rep_ve_dx.tbv0047m tbv0047m --M車両店舗DB
    	ON tbv0047m.cd_hansya = tbv201m.cd_hansya
    	AND tbv0047m.cd_tenpo = tbv201m.cd_kaisya
    	AND tbv0047m.cd_tenpo = tbv201m.cd_tenpo
    LEFT JOIN ai21rep_ve_dx.tbv0033m tbv003m --MゾーンコードDB
    	ON tbv003m.cd_hansya = tbv0047m.cd_hansya
    	AND tbv003m.cd_kaisya = tbv0047m.cd_tenpo
    	AND tbv003m.cd_zon = tbv0047m.cd_nczon
    	AND tbv003m.kb_syohin = '1' --新車商品区分が１
    LEFT JOIN dx_ve.tbi002003m tntenpo --手入力店舗所属
    	ON tntenpo.cd_hansya = tbv201m.cd_hansya
    	AND tntenpo.cd_kaisya = tbv201m.cd_kaisya
    	AND tntenpo.cd_tenpo = tbv201m.cd_tenpo
    LEFT JOIN ai21rep_ve_dx.tbv0033m tbv003m1 --MゾーンコードDB
    	ON tntenpo.cd_hansya = tbv003m1.cd_hansya
    	AND tntenpo.cd_kaisya = tbv003m1.cd_kaisya
    	AND tntenpo.cd_tenpo = tbv003m1.cd_zon
    WHERE
        tbi999003m.kb_tenji = 1 --店舗展示設定
        AND tbv201m.cd_hansya <> '03601' --販社コードがTMT以外
    	AND tbv201m.kj_tenpomei NOT LIKE '%廃）%' --店舗.店舗名称が"廃）"を含まない
) main_table
LIMIT 0;

-- [021/099] level=1 target=gold.VBI002001
-- Gold dependencies: gold.vbi002001_en
-- Source file: 002_新車売掛金/VBI002001_新車売掛金店舗別_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI002001 AS
SELECT
    su_store_number AS 店舗数, --店舗数
    cd_hansya_kaisya_tenpo AS 販社会社店舗コード, --販社会社店舗コード
	cd_hansya_kaisya_zon_tenpo AS 販社会社ゾーン店舗コード, --販社会社ゾーン店舗コード
	cd_hansya AS 販社コード, --販社コード
	cd_kaisya AS 会社コード, --会社コード
	cd_tenpo AS 店舗コード, --店舗コード
	kj_tenpomei AS 店舗名称, --店舗名称
	kj_tentanms AS 店舗短縮名称, --店舗短縮名称
    cd_zon AS ゾーンコード, --ゾーンコード
    cd_nczon AS ンゾン, --ンゾン
    kj_zonmei AS ゾーン名称, --ゾーン名称
	zone_name_abbreviation AS ゾーン名略, --ゾーン名略
	sort_order AS ソート順 --ソート順
FROM
	gold.vbi002001_en vbi002001 --新車売掛金店舗別_en
LIMIT 0;

-- [022/099] level=1 target=gold.VBI002003
-- Gold dependencies: gold.vbi002001_en
-- Source file: 002_新車売掛金/VBI002003_新車売掛金回転日数_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI002003 AS
WITH months AS (
    SELECT 1 AS month
    UNION ALL
    SELECT 2 AS month
    UNION ALL
    SELECT 3 AS month
    UNION ALL
    SELECT 4 AS month
    UNION ALL
    SELECT 5 AS month
    UNION ALL
    SELECT 6 AS month
    UNION ALL
    SELECT 7 AS month
    UNION ALL
    SELECT 8 AS month
    UNION ALL
    SELECT 9 AS month
    UNION ALL
    SELECT 10 AS month
    UNION ALL
    SELECT 11 AS month
    UNION ALL
    SELECT 12 AS month
)
SELECT
    months.month AS 月, --月
    tbg7005m.cd_hansya AS 販社コード, --販社コード
    tbg7005m.cd_kaisya AS 会社コード, --会社コード
    tbg7005m.cd_hansya || tbg7005m.cd_kaisya || tbg7005m.cd_tenpo AS 販社会社店舗コード, --販社会社店舗コード
    SUM(
        CASE
            WHEN tbg7005m.nu_yyyy = YEAR(MONTHS_SUB(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP() ,'JST') ,4)) -1 AND tbg7005m.cd_kanjyou = '10401  '
            THEN
                CASE
                    WHEN months.month = 4 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 - tbg7005m.ki_toykas01
                    WHEN months.month = 5 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02
                    WHEN months.month = 6 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03
                    WHEN months.month = 7 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04
                    WHEN months.month = 8 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05
                    WHEN months.month = 9 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06
                    WHEN months.month = 10 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07
                    WHEN months.month = 11 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 + tbg7005m.ki_toykar08 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07 - tbg7005m.ki_toykas08
                    WHEN months.month = 12 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 + tbg7005m.ki_toykar08 + tbg7005m.ki_toykar09 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07 - tbg7005m.ki_toykas08 - tbg7005m.ki_toykas09
                    WHEN months.month = 1 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 + tbg7005m.ki_toykar08 + tbg7005m.ki_toykar09 + tbg7005m.ki_toykar10 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07 - tbg7005m.ki_toykas08 - tbg7005m.ki_toykas09 - tbg7005m.ki_toykas10
                    WHEN months.month = 2 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 + tbg7005m.ki_toykar08 + tbg7005m.ki_toykar09 + tbg7005m.ki_toykar10 + tbg7005m.ki_toykar11 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07 - tbg7005m.ki_toykas08 - tbg7005m.ki_toykas09 - tbg7005m.ki_toykas10 - tbg7005m.ki_toykas11
                    WHEN months.month = 3 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 + tbg7005m.ki_toykar08 + tbg7005m.ki_toykar09 + tbg7005m.ki_toykar10 + tbg7005m.ki_toykar11 + tbg7005m.ki_toykar12 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07 - tbg7005m.ki_toykas08 - tbg7005m.ki_toykas09 - tbg7005m.ki_toykas10 - tbg7005m.ki_toykas11 - tbg7005m.ki_toykas12
                END
        END)/1000000 AS 前年売掛金残高, --前年売掛金残高
    SUM(
        CASE
            WHEN tbg7005m.nu_yyyy = YEAR(MONTHS_SUB(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP() ,'JST') ,4)) -1 AND tbg7005m.cd_kanjyou BETWEEN '5010101' AND '5019999'
            THEN
                CASE
                    WHEN months.month = 4 THEN tbg7005m.ki_toykas01 - tbg7005m.ki_toykar01
                    WHEN months.month = 5 THEN tbg7005m.ki_toykas02 - tbg7005m.ki_toykar02
                    WHEN months.month = 6 THEN tbg7005m.ki_toykas03 - tbg7005m.ki_toykar03
                    WHEN months.month = 7 THEN tbg7005m.ki_toykas04 - tbg7005m.ki_toykar04
                    WHEN months.month = 8 THEN tbg7005m.ki_toykas05 - tbg7005m.ki_toykar05
                    WHEN months.month = 9 THEN tbg7005m.ki_toykas06 - tbg7005m.ki_toykar06
                    WHEN months.month = 10 THEN tbg7005m.ki_toykas07 - tbg7005m.ki_toykar07
                    WHEN months.month = 11 THEN tbg7005m.ki_toykas08 - tbg7005m.ki_toykar08
                    WHEN months.month = 12 THEN tbg7005m.ki_toykas09 - tbg7005m.ki_toykar09
                    WHEN months.month = 1 THEN  tbg7005m.ki_toykas10 - tbg7005m.ki_toykar10
                    WHEN months.month = 2 THEN  tbg7005m.ki_toykas11 - tbg7005m.ki_toykar11
                    WHEN months.month = 3 THEN  tbg7005m.ki_toykas12 - tbg7005m.ki_toykar12
                END
        END)/1000000 AS 前年売上額, --前年売上額
    SUM(
        CASE
            WHEN tbg7005m.nu_yyyy = YEAR(MONTHS_SUB(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP() ,'JST') ,4)) AND tbg7005m.cd_kanjyou = '10401  ' AND ((MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')) > 4 AND months.month > 3 AND months.month < MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'))) OR (MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')) <= 4 AND (months.month > 3 OR months.month < MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'))))) 
            THEN
                CASE
                    WHEN months.month = 4 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 - tbg7005m.ki_toykas01
                    WHEN months.month = 5 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02
                    WHEN months.month = 6 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03
                    WHEN months.month = 7 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04
                    WHEN months.month = 8 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05
                    WHEN months.month = 9 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06
                    WHEN months.month = 10 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07
                    WHEN months.month = 11 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 + tbg7005m.ki_toykar08 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07 - tbg7005m.ki_toykas08
                    WHEN months.month = 12 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 + tbg7005m.ki_toykar08 + tbg7005m.ki_toykar09 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07 - tbg7005m.ki_toykas08 - tbg7005m.ki_toykas09
                    WHEN months.month = 1 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 + tbg7005m.ki_toykar08 + tbg7005m.ki_toykar09 + tbg7005m.ki_toykar10 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07 - tbg7005m.ki_toykas08 - tbg7005m.ki_toykas09 - tbg7005m.ki_toykas10
                    WHEN months.month = 2 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 + tbg7005m.ki_toykar08 + tbg7005m.ki_toykar09 + tbg7005m.ki_toykar10 + tbg7005m.ki_toykar11 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07 - tbg7005m.ki_toykas08 - tbg7005m.ki_toykas09 - tbg7005m.ki_toykas10 - tbg7005m.ki_toykas11
                    WHEN months.month = 3 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 + tbg7005m.ki_toykar08 + tbg7005m.ki_toykar09 + tbg7005m.ki_toykar10 + tbg7005m.ki_toykar11 + tbg7005m.ki_toykar12 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07 - tbg7005m.ki_toykas08 - tbg7005m.ki_toykas09 - tbg7005m.ki_toykas10 - tbg7005m.ki_toykas11 - tbg7005m.ki_toykas12
                END
        END)/1000000 AS 売掛金残高, --売掛金残高
    SUM(
        CASE
            WHEN tbg7005m.nu_yyyy = YEAR(MONTHS_SUB(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP() ,'JST') ,4)) AND tbg7005m.cd_kanjyou BETWEEN '5010101' AND '5019999' AND ((MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')) > 4 AND months.month > 3 AND months.month < MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'))) OR (MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')) <= 4 AND (months.month > 3 OR months.month < MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'))))) 
            THEN
                CASE
                    WHEN months.month = 4 THEN tbg7005m.ki_toykas01 - tbg7005m.ki_toykar01
                    WHEN months.month = 5 THEN tbg7005m.ki_toykas02 - tbg7005m.ki_toykar02
                    WHEN months.month = 6 THEN tbg7005m.ki_toykas03 - tbg7005m.ki_toykar03
                    WHEN months.month = 7 THEN tbg7005m.ki_toykas04 - tbg7005m.ki_toykar04
                    WHEN months.month = 8 THEN tbg7005m.ki_toykas05 - tbg7005m.ki_toykar05
                    WHEN months.month = 9 THEN tbg7005m.ki_toykas06 - tbg7005m.ki_toykar06
                    WHEN months.month = 10 THEN tbg7005m.ki_toykas07 - tbg7005m.ki_toykar07
                    WHEN months.month = 11 THEN tbg7005m.ki_toykas08 - tbg7005m.ki_toykar08
                    WHEN months.month = 12 THEN tbg7005m.ki_toykas09 - tbg7005m.ki_toykar09
                    WHEN months.month = 1 THEN  tbg7005m.ki_toykas10 - tbg7005m.ki_toykar10
                    WHEN months.month = 2 THEN  tbg7005m.ki_toykas11 - tbg7005m.ki_toykar11
                    WHEN months.month = 3 THEN  tbg7005m.ki_toykas12 - tbg7005m.ki_toykar12
                END
        END)/1000000 AS 売上額 --売上額
FROM
    months months,ai21rep_ve_dx.tbg7005m tbg7005m --総勘定ⅮＢ
INNER JOIN gold.vbi002001_en v2001 --新車売掛金店舗別_en
    ON v2001.cd_hansya = tbg7005m.cd_hansya
    AND v2001.cd_kaisya = tbg7005m.cd_kaisya
    AND v2001.cd_tenpo = tbg7005m.cd_tenpo
WHERE
    (tbg7005m.cd_hansya <> '03601' --販社コード=03601、会社コード=01、または店舗コード=zzzの対象を除外する
    OR tbg7005m.cd_kaisya <> '01'
    OR tbg7005m.cd_tenpo <> 'ZZZ')
GROUP BY
    months.month,
    tbg7005m.cd_hansya,
    tbg7005m.cd_kaisya,
    tbg7005m.cd_tenpo
LIMIT 0;

-- [023/099] level=1 target=gold.VBI002004_en
-- Gold dependencies: gold.vbi002001_en
-- Source file: 002_新車売掛金/VBI002004_新車売掛金回収状況_en_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI002004_en AS
SELECT
	tbba001g.cd_hansya, --販社コード
	tbba001g.cd_kaisya, --会社コード
	tbba001g.cd_tenpo, --店舗コード
	tbba001g.cd_hansya || tbba001g.cd_kaisya || tbba001g.cd_tenpo AS cd_hansya_kaisya_tenpo, --販社会社店舗コード
	IF(MONTH(tbba001g.dd_jucyu) = MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')),1,0) AS su_order, --受注台数
    IF(MONTH(tbba001g.dd_touroku) = MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')),1,0) AS su_registered_vehicle, --登録台数
    IF(MONTH(tbba001g.dd_touroku) = MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')) AND tbba052g.su_sitadori = 0,1,0) AS su_no_trade_in_vehicle_registered_this_month, --当月登録内下取車なし
	COALESCE(tbba001g_1.su_avg_lead_time, 0) AS su_average_lead_time_for_collections_completed_this_month, --当月回収完了分平均リードタイム
    IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_urikzumi IS NULL,1,0) AS su_currently_registered_but_uncollected_case, --現在登録済未回収件数
    IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_urikzumi IS NULL,tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk,0) AS su_currently_registered_uncollected_amount, --現在登録済未回収金額
    IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_urikzumi IS NULL AND TRUNC(tbba001g.dd_touroku, 'month') = TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'month'),1,0) AS su_registered_but_uncollected_items_from_the_previous_month, --前月登録済未回収件数
    IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_urikzumi IS NULL AND TRUNC(tbba001g.dd_touroku, 'month') = TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'month'),tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk,0) AS su_uncollected_amount_registered_in_the_previous_month, --前月登録済未回収金額
    IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_urikzumi IS NULL AND (TRUNC(tbba001g.dd_touroku, 'year') < TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'year') OR (TRUNC(tbba001g.dd_touroku, 'year') = TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'year') AND TRUNC(tbba001g.dd_touroku, 'month') < TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'month'))),1,0) AS su_registered_but_uncollected_items_from_the_previous_month_or_earlier, --前月以前登録済未回収件数
    IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_urikzumi IS NULL AND (TRUNC(tbba001g.dd_touroku, 'year') < TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'year') OR (TRUNC(tbba001g.dd_touroku, 'year') = TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'year') AND TRUNC(tbba001g.dd_touroku, 'month') < TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'month'))),tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk,0) AS su_uncollected_amount_registered_in_the_previous_month_or_earlier, --前月以前登録済未回収金額
    IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_urikzumi IS NULL,1,NULL) AS su_pieces, --件数
    IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_urikzumi IS NULL,(tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk) / 1000,NULL)   AS su_amount, --金額
    v2001.sort_order --ソート順
FROM
	ai21rep_ve_dx.tbba001g tbba001g --新車受注基本DB
INNER JOIN gold.vbi002001_en v2001 --新車売掛金店舗別_en
    ON v2001.cd_hansya = tbba001g.cd_hansya
    AND v2001.cd_kaisya = tbba001g.cd_kaisya
    AND v2001.cd_tenpo = tbba001g.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbba052g tbba052g --新車受注販売条件情報DB
    ON tbba001g.cd_hansya = tbba052g.cd_hansya
	AND tbba001g.cd_kaisya = tbba052g.cd_kaisya
	AND tbba001g.no_cyumon = tbba052g.no_cyumon
	AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba052g.no_cyumoned)
LEFT JOIN (
	SELECT
        tbba001g.cd_hansya, --販社コード
		tbba001g.cd_kaisya, --会社コード
		tbba001g.cd_tenpo, --店舗コード
        AVG(DATEDIFF(
            CAST(tbba001g.dd_urikzumi AS DATE),
            CAST(tbba001g.dd_fr AS DATE)
          )
        )
    AS su_avg_lead_time --当月回収完了分平均リードタイム取得
	FROM
		ai21rep_ve_dx.tbba001g tbba001g --新車受注基本DB
	LEFT JOIN ai21rep_ve_dx.tbba052g tbba052g --新車受注販売条件情報DB
         ON tbba001g.cd_hansya = tbba052g.cd_hansya
		AND tbba001g.cd_kaisya = tbba052g.cd_kaisya
		AND tbba001g.no_cyumon = tbba052g.no_cyumon
		AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba052g.no_cyumoned)
	WHERE
		tbba001g.dd_touroku IS NOT NULL --登録日がNULLではない
		AND (tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk) = 0 --未回収額が0
        AND TRUNC(tbba001g.dd_urikzumi, 'month') = TRUNC(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 'month') --販売日が今月である
	GROUP BY
        tbba001g.cd_hansya,
		tbba001g.cd_kaisya,
		tbba001g.cd_tenpo) tbba001g_1
	ON tbba001g.cd_hansya = tbba001g_1.cd_hansya
    AND tbba001g.cd_kaisya = tbba001g_1.cd_kaisya
	AND tbba001g.cd_tenpo = tbba001g_1.cd_tenpo
WHERE tbba001g.dd_torikesi IS NULL --取消日がNULLである
    AND (dd_torotrkk IS NULL --登録取消計上日がNULLである
		OR (dd_torotrkk IS NOT NULL --登録取消計上日がNULLではない
			AND (tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk) != 0 --値があると残高がある
			)
		)
    AND LEFT(CAST (tbba001g.kb_haraidas AS STRING), 1) = '1' --払出区分の第一位が1
    AND ISNOTTRUE(
		(tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk) = 0 --値があると残高がある
        AND(
    	    (
    	        tbba001g.dd_touroku IS NOT NULL --登録日がNULLではない
    	        AND tbba001g.dd_nosya < DATE '2023-03-01' --納車日が2023-03-01以前
    	        AND (tbba001g.dd_urikzumi IS NULL OR tbba001g.dd_urikzumi < DATE '2024-03-01') --売掛金完済日がNULLであるまたは売掛金完済日が2024-03-01以前
    	    )
    	    OR (tbba001g.dd_nosya IS NULL AND tbba001g.dd_touroku < DATE '2023-03-01') --納車日がNULLであるそして登録日が2023-03-01以前
    	    OR tbba001g.dd_urikzumi < DATE '2024-03-01' --納車日が2024-03-01以前
    	    OR (tbba001g.dd_touroku IS NULL AND tbba001g.dd_jucyu < DATE '2020-12-01') --登録日がNULLであるまたは受注日が2020-12-01以前
            )
		) --ゴミデータ除外
LIMIT 0;

-- [024/099] level=2 target=gold.vbi002002
-- Gold dependencies: gold.vbi002001_en, gold.VBI002004_en
-- Source file: 002_新車売掛金/VBI002002_エリア統括部と店舗別_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi002002 AS
SELECT
    v2001.zone_name_abbreviation AS エリア統括部と店舗, --エリア統括部と店舗
    'ゾーン名称' AS 区分名称, --区分名称
    '1' AS 区分コード, --区分コード
    v2001.cd_hansya AS 販社コード, --販社コード
    v2001.cd_kaisya AS 会社コード, --会社コード
    v2001.cd_zon AS ゾーンコード, --ゾーンコード
    NULL AS 店舗コード, --店舗コード
    NULL AS 販社会社店舗コード, --販社会社店舗コード
    NULL AS 販社会社ゾーン店舗コード, --販社会社ゾーン店舗コード
    SUM(v2004.su_pieces) AS 件数, --件数
    SUM(v2004.su_amount) AS 金額, --金額
    CAST(v2001.cd_zon AS INT) AS ソート順 --ソート順
FROM
    gold.vbi002001_en v2001 --新車売掛金店舗別_en
LEFT JOIN gold.VBI002004_en v2004 --新車売掛金回収状況_en
	ON v2001.cd_hansya = v2004.cd_hansya
	AND v2001.cd_kaisya = v2004.cd_kaisya
	AND v2001.cd_tenpo = v2004.cd_tenpo
GROUP BY
    エリア統括部と店舗,
    区分名称,
    区分コード,
    販社コード,
    会社コード,
    ゾーンコード
UNION ALL
SELECT
    v2001.kj_tentanms AS エリア統括部と店舗, --エリア統括部と店舗
    '店舗略称' AS 区分名称, --区分名称
    '2' AS 区分コード, --区分コード
    v2001.cd_hansya AS 販社コード, --販社コード
    v2001.cd_kaisya AS 会社コード, --会社コード
    v2001.cd_zon AS ゾーンコード, --ゾーンコード
    v2001.cd_tenpo AS 店舗コード, --店舗コード
    v2001.cd_hansya_kaisya_tenpo AS 販社会社店舗コード, --販社会社店舗コード
    v2001.cd_hansya_kaisya_zon_tenpo AS 販社会社ゾーン店舗コード, --販社会社ゾーン店舗コード
    SUM(su_pieces) AS 件数, --件数
    SUM(su_amount) AS 金額, --金額
    v2001.sort_order AS ソート順 --ソート順
FROM
    gold.vbi002001_en v2001 --新車売掛金店舗別_en
LEFT JOIN gold.VBI002004_en v2004 --新車売掛金回収状況_en
	ON v2001.cd_hansya = v2004.cd_hansya
	AND v2001.cd_kaisya = v2004.cd_kaisya
	AND v2001.cd_tenpo = v2004.cd_tenpo
GROUP BY
    エリア統括部と店舗,
    区分名称,
    区分コード,
    販社コード,
    会社コード,
    ゾーンコード,
    店舗コード,
    販社会社店舗コード,
    販社会社ゾーン店舗コード,
    ソート順
LIMIT 0;

-- [025/099] level=2 target=gold.vbi002004
-- Gold dependencies: gold.VBI002004_en
-- Source file: 002_新車売掛金/VBI002004_新車売掛金回収状況_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi002004 AS
SELECT
	cd_hansya AS 販社コード, --販社コード
	cd_kaisya AS 会社コード, --会社コード
	cd_tenpo AS 店舗コード, --店舗コード
	cd_hansya_kaisya_tenpo AS 販社会社店舗コード, --販社会社店舗コード
    su_order AS 受注台数, --受注台数
    su_registered_vehicle AS 登録台数, --登録台数
    su_no_trade_in_vehicle_registered_this_month AS 当月登録内下取車なし, --当月登録内下取車なし
	su_average_lead_time_for_collections_completed_this_month AS 当月回収完了分平均リードタイム, --当月回収完了分平均リードタイム
    su_currently_registered_but_uncollected_case AS 現在登録済未回収件数, --現在登録済未回収件数
    su_currently_registered_uncollected_amount AS 現在登録済未回収金額, --現在登録済未回収金額
    su_registered_but_uncollected_items_from_the_previous_month AS 前月登録済未回収件数, --前月登録済未回収件数
    su_uncollected_amount_registered_in_the_previous_month AS 前月登録済未回収金額, --前月登録済未回収金額
    su_registered_but_uncollected_items_from_the_previous_month_or_earlier AS 前月以前登録済未回収件数, --前月以前登録済未回収件数
    su_uncollected_amount_registered_in_the_previous_month_or_earlier AS 前月以前登録済未回収金額, --前月以前登録済未回収金額
    su_pieces AS 件数, --件数
    su_amount AS 金額, --金額
    sort_order AS ソート順 --ソート順
FROM
	gold.VBI002004_en vbi002004 --新車売掛金回収状況_en
LIMIT 0;

-- [026/099] level=1 target=gold.VBI002005
-- Gold dependencies: gold.vbi002001_en
-- Source file: 002_新車売掛金/VBI002005_新車売掛金残高_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI002005 AS
SELECT
	tbba001g.cd_hansya AS 販社コード, --販社コード
	tbba001g.cd_kaisya AS 会社コード, --会社コード
    tbba001g.cd_hansya || tbba001g.cd_kaisya || tbba001g.cd_tenpo AS 販社会社店舗コード,
    IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'),-1)) AND (tbba001g.dd_urikzumi >= TRUNC(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(),'JST'),'MM') OR tbba001g.dd_urikzumi IS NULL),1,0) AS 登録済件数,--登録済件数
    IF(COALESCE(tbba052g.su_sitadori, 0) = 0 AND tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND (tbba001g.dd_urikzumi >= TRUNC(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 'MM') OR tbba001g.dd_urikzumi IS NULL),1,0) AS 下取車なし総件数, --下取車なし総件数
    IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbba001g.dd_urikzumi IS NULL AND (tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk) != 0,1,0) AS 未回収総件数, --未回収総件数
    IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbba001g.dd_urikzumi IS NULL AND (tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk) != 0,tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk,0) AS 未回収総金額, --未回収総金額
    IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbba001g.dd_urikzumi IS NULL AND (tbba052g.ki_genkhasg - tbba052g.ki_genknykg) != 0,1,0) AS 未回収現金総件数, --未回収現金総件数
    IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbba001g.dd_urikzumi IS NULL AND (tbba052g.ki_genkhasg - tbba052g.ki_genknykg) != 0,tbba052g.ki_genkhasg - tbba052g.ki_genknykg,0) AS 未回収現金総金額, --未回収現金総金額
    IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbba001g.dd_urikzumi IS NULL AND (tbba052g.ki_fuharhsk - tbba052g.ki_fuharnyk) != 0,1,0) AS 未回収割賦総総件数, --未回収割賦総総件数
    IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbba001g.dd_urikzumi IS NULL AND (tbba052g.ki_fuharhsk - tbba052g.ki_fuharnyk) != 0,tbba052g.ki_fuharhsk - tbba052g.ki_fuharnyk,0) AS 未回収割賦総総金額, --未回収割賦総総金額
    IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbba001g.dd_urikzumi IS NULL AND (tbba052g.ki_sitahasg - tbba052g.ki_sitanykg) != 0,1,0) AS 未回収下取総件数, --未回収下取総件数
    IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbba001g.dd_urikzumi IS NULL AND (tbba052g.ki_sitahasg - tbba052g.ki_sitanykg) != 0,tbba052g.ki_sitahasg - tbba052g.ki_sitanykg,0) AS 未回収下取総金額, --未回収下取総金額
    IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND (tbba001g.dd_urikzumi >= TRUNC(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 'MM') OR tbba001g.dd_urikzumi IS NULL) AND tbba001g.dd_nosya IS NULL,1,0) AS 登録済未納車件数 --登録済未納車件数
FROM 
	ai21rep_ve_dx.tbba001g tbba001g --新車受注基本DB
INNER JOIN gold.vbi002001_en v2001 --新車売掛金店舗別_en
    ON v2001.cd_hansya = tbba001g.cd_hansya
    AND v2001.cd_kaisya = tbba001g.cd_kaisya
    AND v2001.cd_tenpo = tbba001g.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbba052g tbba052g --新車受注販売条件情報DB
	ON tbba001g.cd_hansya = tbba052g.cd_hansya
	AND tbba001g.cd_kaisya = tbba052g.cd_kaisya
	AND tbba001g.no_cyumon = tbba052g.no_cyumon
	AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba052g.no_cyumoned)
WHERE
tbba001g.dd_torikesi IS NULL --取消日がNULLである
AND (dd_torotrkk IS NULL
      OR (dd_torotrkk IS NOT NULL
        AND (tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk) != 0
        )
    )--登録取消計上日がNULLではない　or　残高がある
AND LEFT(CAST (tbba001g.kb_haraidas AS STRING), 1) = '1' --払出区分の第一位が1
AND ISNOTTRUE(
		(tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk) = 0 --値があると残高がある
        AND(
    	    (
    	        tbba001g.dd_touroku IS NOT NULL --登録日がNULLではないではありません
    	        and tbba001g.dd_nosya < DATE '2023-03-01' --納車日が2023-03-01以前
    	        and (tbba001g.dd_urikzumi IS NULL OR tbba001g.dd_urikzumi < DATE '2024-03-01') --売掛金完済日がNULLであるまたは売掛金完済日が2024-03-01以前
    	    )
    	    OR (tbba001g.dd_nosya IS NULL AND tbba001g.dd_touroku < DATE '2023-03-01') --納車日がNULLであるそして登録日が2023-03-01以前
    	    OR tbba001g.dd_urikzumi < DATE '2024-03-01' --納車日が2024-03-01以前
    	    OR (tbba001g.dd_touroku IS NULL AND tbba001g.dd_jucyu < DATE '2020-12-01') --登録日がNULLであるまたは受注日が2020-12-01以前
            )
		)--ゴミデータ除外
LIMIT 0;

-- [027/099] level=0 target=gold.VBI002006
-- Gold dependencies: none
-- Source file: 002_新車売掛金/VBI002006_新車売掛金明細_アラート判断_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI002006 AS
WITH kb_genkin_table AS(
    SELECT
        tbi999013m.cd_hansya, --販社コード
        tbi999013m.cd_kaisya, --会社コード
        GROUP_CONCAT(tbi999013m.kb_nyuukin, ',') AS kb_nyuukin_list --入金区分list
    FROM dx_ve.tbi999013m tbi999013m --販売店入金区分設定
    WHERE tbi999013m.kb_genkin = '1'
    GROUP BY tbi999013m.cd_hansya
            ,tbi999013m.cd_kaisya
),
kb_crejcard_table AS(
    SELECT
        tbi999013m.cd_hansya, --販社コード
        tbi999013m.cd_kaisya, --会社コード
        GROUP_CONCAT(tbi999013m.kb_nyuukin, ',') AS kb_nyuukin_list --入金区分list
    FROM dx_ve.tbi999013m tbi999013m --販売店入金区分設定
    WHERE tbi999013m.kb_crejcard = '1'
    GROUP BY tbi999013m.cd_hansya
            ,tbi999013m.cd_kaisya
),
base_data AS (
  SELECT
    CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE) AS jp_today, --日本時間
    DATE_TRUNC('MONTH', FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')) AS current_month_start, --月初
    LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AS last_month_end, --先月末
    tbba001g.cd_hansya || tbba001g.cd_kaisya || tbba001g.no_cyumon || TRIM(tbba001g.no_cyumoned) AS cd_pk, --pk_販社会社注文no枝番
    tbba001g.cd_hansya || tbba001g.cd_kaisya || tbba001g.cd_tenpo AS cd_hankaisya_tenpo, --pk_販社会社店舗コード
    tbba001g.cd_hansya, --販社コード
    tbba001g.cd_kaisya, --会社コード
    tbba001g.cd_tenpo, --店舗コード
    tbba001g.no_cyumon, --注文ＮＯ
    tbba001g.no_cyumoned, --注文ＮＯ枝番
    tbba001g.dd_touroku, --登録日
    tbba001g.dd_nosya, --納車日
    tbba001g.dd_fr, --振当日
    tbba001g.dd_urikzumi, --売掛金完済日
    tbba001g.dd_jucyu, --受注日
    tbba001g.dd_torikesi, --取消日
    tbba001g.dd_torotrkk, --登録取消計上日
    tbba052g.dd_minasksy, --見直し回収予定日
    tbba052g.dd_kaisyuyo, --回収予定日
    tbba052g.ki_haseirui, --発生累計
    tbba052g.ki_genknykg, --現金入金額
    tbba052g.ki_sitanykg, --下取車入金額
    tbba052g.ki_fuharnyk, --賦払金入金額
    tbba052g.ki_genkhasg, --現金発生額
    tbba052g.ki_fuharhsk, --賦払金発生額
    tbba052g.mj_keiykeit, --契約形態
    COALESCE(tbi002001m.su_leadtime, 20) AS su_leadtime, --リードタイム日
    COALESCE(tbi002001m.su_minosya, 30) AS su_minosya, --未納車経過日
    COALESCE(tbi002001m.su_touroku, 90) AS su_touroku, --登録経過日
    COALESCE(tbi002001m.su_fr, 90) AS su_fr, --振当経過日
    COALESCE(tbi002001m.su_jucyu, 365) AS su_jucyu --受注経過日
  FROM
    ai21rep_ve_dx.tbba001g tbba001g --新車受注基本DB
  LEFT JOIN ai21rep_ve_dx.tbba052g tbba052g --新車受注販売条件情報DB
    ON tbba001g.cd_hansya = tbba052g.cd_hansya
    AND tbba001g.cd_kaisya = tbba052g.cd_kaisya
    AND tbba001g.no_cyumon = tbba052g.no_cyumon
    AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba052g.no_cyumoned)
  LEFT JOIN dx_ve.tbi002001m tbi002001m --店舗アラート項目設定
    ON tbba001g.cd_hansya = tbi002001m.cd_hansya
    AND tbba001g.cd_kaisya = tbi002001m.cd_kaisya
  WHERE
    --ゴミデータ除外
    ISNOTTRUE(
        (NVL(tbba052g.ki_haseirui,0) - NVL(tbba052g.ki_genknykg,0) - NVL(tbba052g.ki_sitanykg,0) - NVL(tbba052g.ki_fuharnyk,0)) = 0 --残高金額に値がない
        AND((tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_nosya < DATE '2023-03-01' --登録日がNULLではないではありませんそして納車日が2023-03-01以前
            AND (tbba001g.dd_urikzumi IS NULL OR tbba001g.dd_urikzumi < DATE '2024-03-01')) --売掛金完済日がNULLであるまたは売掛金完済日が2024-03-01以前
            OR (tbba001g.dd_nosya IS NULL AND tbba001g.dd_touroku < DATE '2023-03-01') --納車日がNULLであるそして登録日が2023-03-01以前
            OR tbba001g.dd_urikzumi < DATE '2024-03-01' --納車日が2024-03-01以前
            OR (tbba001g.dd_touroku IS NULL AND tbba001g.dd_jucyu < DATE '2020-12-01') --登録日がNULLであるまたは受注日が2020-12-01以前
            )
        )
    AND (tbba001g.dd_torotrkk IS NULL OR (tbba001g.dd_torotrkk IS NOT NULL AND (NVL(tbba052g.ki_haseirui,0) - NVL(tbba052g.ki_genknykg,0) - NVL(tbba052g.ki_sitanykg,0) - NVL(tbba052g.ki_fuharnyk,0)) <> 0)) --登録取消計上日がNULLではないであるであるまたは値があると残高がある
    AND (LEFT(tbba001g.kb_haraidas, 1) = '1' OR ( --払出区分が1である
        LEFT(tbba001g.kb_haraidas, 1) = '3' --払出区分が3である
        AND NOT((NVL(tbba052g.ki_haseirui,0) - NVL(tbba052g.ki_genknykg,0) - NVL(tbba052g.ki_sitanykg,0) - NVL(tbba052g.ki_fuharnyk,0)) = 0 --値があると残高がある
        AND (NVL(tbba052g.ki_genkhasg,0) - NVL(tbba052g.ki_genknykg,0)) = 0 --現金発生額から現金入金額を引いた値が0である
        AND (NVL(tbba052g.ki_fuharhsk,0) - NVL(tbba052g.ki_fuharnyk,0)) = 0 --賦払金発生額から下取車入金額を引いた値が0である
        AND (NVL(tbba052g.ki_sitahasg,0) - NVL(tbba052g.ki_sitanykg,0)) = 0))) --下取車発生額から下取車入金額を引いた値が0である
)
SELECT
  cd_pk AS pk_販社会社注文no枝番, --pk_販社会社注文no枝番
  cd_hankaisya_tenpo AS pk_販社会社店舗コード, --pk_販社会社店舗コード
  cd_hansya AS 販社コード, --販社コード
  cd_kaisya AS 会社コード, --会社コード
  IF(CONCAT_WS('',flg_1, flg_2, flg_3, flg_4, flg_5, flg_6, flg_a, flg_b, flg_c, flg_d, flg_e, flg_f) = '','99',CONCAT_WS('',flg_1, flg_2, flg_3, flg_4, flg_5, flg_6, flg_a, flg_b, flg_c, flg_d, flg_e, flg_f)) AS アラート判断 --アラート判断
  ,no_cyumon AS 注文ＮＯ --注文ＮＯ
  ,cd_tenpo AS 店舗コード --店舗コード
  ,dd_nosya AS 納車日 --納車日
  ,dd_touroku AS 登録日 --登録日
  ,dd_fr AS 振当日 --振当日
  ,dd_jucyu AS 受注日 --受注日
  ,flg_1 --flg_1
  ,flg_2 --flg_2
  ,flg_3 --flg_3
  ,flg_4 --flg_4
  ,flg_5 --flg_5
  ,flg_6 --flg_6
  ,flg_a --flg_a
  ,flg_b --flg_b
  ,flg_c --flg_c
  ,flg_d --flg_d
  ,flg_e --flg_e
  ,flg_f --flg_f
  ,dd_minasksy AS 見直し回収予定日 --見直し回収予定日
  ,dd_kaisyuyo AS 回収予定日 --回収予定日
  ,su_leadtime AS リードタイム日 --リードタイム日
  ,su_minosya AS 未納車経過日 --未納車経過日
  ,su_touroku AS 登録経過日 --登録経過日
  ,su_fr AS 振当経過日 --振当経過日
  ,su_jucyu AS 受注経過日 --受注経過日
  FROM(
  SELECT
    cd_pk, --pk_販社会社注文no枝番
    cd_hankaisya_tenpo, --pk_販社会社店舗コード
    cd_hansya, --販社コード
    cd_kaisya, --会社コード
    no_cyumon, --注文ＮＯ
    cd_tenpo, --店舗コード
    dd_nosya, --納車日
    dd_touroku, --登録日
    dd_fr, --振当日
    dd_jucyu, --受注日
    dd_minasksy, --見直し回収予定日
    dd_kaisyuyo, --回収予定日
    su_leadtime, --リードタイム日
    su_minosya, --未納車経過日
    su_touroku, --登録経過日
    su_fr, --振当経過日
    su_jucyu, --受注経過日
    IF(COALESCE(dd_minasksy,dd_kaisyuyo) IS NOT NULL AND COALESCE(dd_minasksy,dd_kaisyuyo) < jp_today AND (NVL(ki_haseirui,0) - NVL(ki_genknykg,0) - NVL(ki_sitanykg,0) - NVL(ki_fuharnyk,0)) <> 0,'1','') AS flg_1, --flg_1
    IF(dd_touroku IS NOT NULL AND (NVL(ki_haseirui,0) - NVL(ki_genknykg,0) - NVL(ki_sitanykg,0) - NVL(ki_fuharnyk,0)) < 0,'2','') AS flg_2, --flg_2
    IF(dd_touroku IS NOT NULL AND dd_nosya IS NULL,'3','') AS flg_3, --flg_3
    IF(dd_nosya IS NOT NULL AND ((NVL(ki_genkhasg,0) - NVL(ki_genknykg,0) ) <> 0 OR (NVL(ki_fuharhsk,0) - NVL(ki_fuharnyk,0)) <> 0) AND mj_keiykeit <> '4','4','') AS flg_4, --flg_4
    --IF(NVL(tbg8014m_2.cash_receipt, 0) + NVL(tbg8014m_2.positive_count,0) - NVL(tbg8014m_2.negative_count, 0) >= 3,'5','') AS flg_5, --flg_5
    IF(NVL(tbg8014m_2.ki_nyukinur2 - tbg8014m_2.ki_nyukinur3, 0) + NVL(tbg8014m_2.positive_count - tbg8014m_2.negative_count, 0) >= 3,'5','') AS flg_5, --flg_5,
    IF(DATEDIFF(dd_nosya, dd_fr) != 0 AND DATEDIFF(dd_nosya, dd_fr) >= su_leadtime,'6','') AS flg_6, --flg_6
    IF((dd_touroku < current_month_start AND dd_touroku IS NOT NULL) AND (dd_urikzumi > last_month_end OR dd_urikzumi IS NULL),'a','') AS flg_a, --flg_a
    IF((dd_touroku < current_month_start AND dd_touroku IS NOT NULL) AND (dd_urikzumi > last_month_end OR dd_urikzumi IS NULL) AND DATEDIFF(last_month_end, dd_touroku) >= su_minosya AND dd_nosya IS NULL,'b','') AS flg_b, --flg_b
    IF((dd_touroku < current_month_start AND dd_touroku IS NOT NULL) AND (dd_urikzumi > last_month_end OR dd_urikzumi IS NULL) AND DATEDIFF(last_month_end, dd_touroku) >= su_touroku,'c','') AS flg_c, --flg_c
    IF((dd_touroku < current_month_start AND dd_touroku IS NOT NULL) AND (dd_urikzumi > last_month_end OR dd_urikzumi IS NULL) AND DATEDIFF(last_month_end, dd_fr) >= su_fr,'d','') AS flg_d, --flg_d
    IF((dd_touroku < current_month_start AND dd_touroku IS NOT NULL) AND (dd_urikzumi > last_month_end OR dd_urikzumi IS NULL) AND DATEDIFF(last_month_end, dd_jucyu) >= su_jucyu,'e','') AS flg_e, --flg_e
    IF(dd_torikesi IS NOT NULL AND dd_torotrkk IS NULL AND (nvl(ki_haseirui,0) - nvl(ki_genknykg,0) - nvl(ki_sitanykg,0) - nvl(ki_fuharnyk,0)) <> 0,'f','') AS flg_f --flg_f
  FROM base_data
  LEFT JOIN (
      SELECT
        tbg8014m.cd_hansya AS cd_hansya_1, --販社コード
        tbg8014m.cd_kaisya AS cd_kaisya_1, --会社コード
        TRIM(tbg8014m.no_cyumon) AS no_cyumon_1, --注文ＮＯ
        SUM(IF(tbg8014m.kb_nyukkanr = '01',1,0)) AS cash_receipt, --現金入金回数
        SUM(IF(FIND_IN_SET(SUBSTR(tbg8014m.kb_nyuukin, 1, 2), (kb_genkin_table.kb_nyuukin_list)) > 0 AND tbg8014m.kb_urinyuki = '2' AND tbg8014m.ki_nyukinur >= 1,1,0)) AS positive_count, --カード入金金額
        SUM(IF(FIND_IN_SET(SUBSTR(tbg8014m.kb_nyuukin, 1, 2), (kb_genkin_table.kb_nyuukin_list)) > 0 AND tbg8014m.kb_urinyuki = '2' AND tbg8014m.ki_nyukinur <= -1,1,0)) AS negative_count, --負数
        SUM(IF(FIND_IN_SET(LEFT(tbg8014m.kb_nyuukin, 2), (kb_crejcard_table.kb_nyuukin_list)) > 0 AND tbg8014m.kb_urinyuki = '2' AND tbg8014m.ki_nyukinur >= 1,1,0)) AS ki_nyukinur2, --カード入金の回数（カード入金金額が1円以上の回数）
        SUM(IF(FIND_IN_SET(LEFT(tbg8014m.kb_nyuukin, 2), (kb_crejcard_table.kb_nyuukin_list)) > 0 AND tbg8014m.kb_urinyuki = '2' AND tbg8014m.ki_nyukinur <= -1,1,0)) AS ki_nyukinur3 --カード入金の回数（カード入金金額がｰ1円以下の回数）
      FROM
        ai21rep_ve_dx.tbg8014m tbg8014m --売掛金履歴ＤＢ
      RIGHT JOIN ai21rep_ve_dx.tbba052g tbba052g --新車受注販売条件情報DB
        ON tbg8014m.cd_hansya = tbba052g.cd_hansya
        AND tbg8014m.cd_kaisya = tbba052g.cd_kaisya
        AND TRIM(tbg8014m.no_cyumon) = (TRIM(tbba052g.no_cyumon) || TRIM(tbba052g.no_cyumoned))
      LEFT JOIN kb_genkin_table
        ON kb_genkin_table.cd_hansya = tbg8014m.cd_hansya
       AND kb_genkin_table.cd_kaisya = tbg8014m.cd_kaisya
      LEFT JOIN kb_crejcard_table
        ON kb_crejcard_table.cd_hansya = tbg8014m.cd_hansya
       AND kb_crejcard_table.cd_kaisya = tbg8014m.cd_kaisya
      GROUP BY
        tbg8014m.cd_hansya,
        tbg8014m.cd_kaisya,
        TRIM(tbg8014m.no_cyumon)
  )tbg8014m_2
    ON base_data.cd_hansya = tbg8014m_2.cd_hansya_1
   AND base_data.cd_kaisya = tbg8014m_2.cd_kaisya_1
   AND (TRIM(base_data.no_cyumon) ||  TRIM(base_data.no_cyumoned)) = tbg8014m_2.no_cyumon_1
  ) maintable
LIMIT 0;

-- [028/099] level=0 target=gold.vbi002007
-- Gold dependencies: none
-- Source file: 002_新車売掛金/VBI002007_新車売掛金履歴_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi002007 AS
WITH table_8014m AS (SELECT
    ROW_NUMBER() OVER(ORDER BY 1) AS logic_pk,
    tbg8014m.*
FROM ai21rep_ve_dx.tbg8014m  --TBG8014M_売掛金履歴ＤＢ
)

SELECT
    t014m.logic_pk AS 主キー, --主キー
    t014m.cd_hansya AS 販社コード, --販社コード
    t014m.cd_kaisya AS 会社コード, --会社コード
    t014m.no_cyumon AS 注文ＮＯ, --注文ＮＯ
    CONCAT(t014m.cd_hansya, t014m.cd_kaisya, TRIM(t014m.no_cyumon)) AS 販社会社注文no, --販社会社注文no
    CAST(t014m.dd_keijyou AS STRING) AS 日付_順番用, --日付_順番用
    TO_TIMESTAMP(CAST(t014m.dd_keijyou AS STRING), 'yyyyMMdd') AS 日付, --日付
    COALESCE(t053m.kb_syohmei, t204m.kj_nasemei, t208m.kj_nyuukinm) AS 項目名, --項目名
    IF (t014m.kb_urinyuki = '1', t014m.ki_nyukinur, NULL) AS 発生額, --発生額
    IF (t014m.kb_urinyuki = '2', t014m.KI_NYUKINUR, NULL) AS 入金額, --入金額
    IF (t014m.kb_urinyuki = '1',
        CASE SUBSTR(t014m.kb_nyuukin, 3, 1)
            WHEN '1' THEN '取消'
            WHEN '2' THEN '売上'
            WHEN '3' THEN '条変'
        END,
    IF (t014m.kb_urinyuki = '2',
        CASE t014m.kb_nyukkanr
            WHEN '01' THEN '現金'
            WHEN '02' THEN '割賦'
            WHEN '03' THEN '下取'
            WHEN '04' THEN '約手'
            WHEN '05' THEN '残債'
        END,
        NULL
        )
        ) AS 空白欄, --空白欄
    t014m.no_denpyo AS 伝票番号, --伝票番号
    t014m.kb_gyoumu AS 業務区分, --業務区分
    t014m.kb_nyuukin AS 入金区分, --入金区分
    1 AS 件数 --件数
FROM(
    SELECT
        t014m.logic_pk, --主キー
        LEFT(t014m.kb_nyuukin, 2) AS kb_nyuukin, --入金区分
        MAX(t053m.dt_saisinup) AS dt_saisinup --最新更新日時
    FROM
        table_8014m t014m --売掛金履歴ＤＢ
    LEFT JOIN ai21rep_ve_dx.tbbf053m t053m --車両諸費用タイトルＤＢ
    ON t014m.cd_hansya = t053m.cd_hansya
    AND t014m.cd_kaisya = t053m.cd_kaisya
    AND CAST(FROM_TIMESTAMP(t053m.dt_saisinup, 'yyyyMMdd') AS INT) <= t014m.dd_keijyou
    GROUP BY
        t014m.logic_pk,
        t014m.kb_nyuukin
  ) bt
LEFT JOIN table_8014m t014m --売掛金履歴ＤＢ
    ON t014m.logic_pk = bt.logic_pk
LEFT JOIN ai21rep_ve_dx.tbbf053m t053m --車両諸費用タイトルＤＢ
    ON t014m.kb_urinyuki = '1' --売上入金区分が1である
    AND t053m.dt_saisinup = bt.dt_saisinup
    AND CONCAT(t053m.kb_syohmei, t053m.kb_syohmsy) = CASE LEFT(t014m.kb_nyuukin, 2) --入金区分制限
        WHEN '14' THEN '210'
        WHEN '15' THEN '220'
        WHEN '16' THEN '231'
        WHEN '17' THEN '232'
        WHEN '18' THEN '233'
        WHEN '20' THEN '520'
        WHEN '21' THEN '510'
        WHEN '22' THEN '610'
        WHEN '23' THEN '620'
        WHEN '24' THEN '631'
        WHEN '25' THEN '632'
        WHEN '26' THEN '633'
    END
LEFT JOIN ai21rep_ve_dx.tbgm024m t204m --売上発生管理ＤＢ
    ON t014m.kb_urinyuki = '1' --売上入金区分が1である
    AND FIND_IN_SET(LEFT(t014m.kb_nyuukin, 2), '14,15,16,17,18,20,21,22,23,24,25,26') = 0 --入金区分制限
    AND t204m.cd_hansya = t014m.cd_hansya
    AND t204m.cd_kaisya = t014m.cd_kaisya
    AND t204m.kb_hassei = LEFT(t014m.kb_nyuukin, 2)
LEFT JOIN ai21rep_ve_dx.tbv0208m t208m --入金区分ＤＢ
    ON t014m.kb_urinyuki = '2' --売上入金区分が2である
    AND t208m.cd_hansya = t014m.cd_hansya
    AND t208m.cd_kaisya = t014m.cd_kaisya
    AND t208m.kb_nyuukin = LEFT(t014m.kb_nyuukin, 2)
LIMIT 0;

-- [029/099] level=1 target=gold.VBI002008
-- Gold dependencies: gold.vbi002001_en
-- Source file: 002_新車売掛金/VBI002008_新車売掛金回転日数_売上金額_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI002008 AS
SELECT
    tbg7005m_3.cd_hansya AS 販社コード, --販社コード
    tbg7005m_3.cd_kaisya AS 会社コード, --会社コード
    tbg7005m_3.cd_tenpo AS 店舗コード, --店舗コード
    tbg7005m_3.cd_hansya || tbg7005m_3.cd_kaisya || tbg7005m_3.cd_tenpo AS 販社会社店舗コード, --販社会社店舗コード
    SUM(tbg7005m_3.ki_toykar01) AS 当年借方金額０１, --当年借方金額０１
    SUM(tbg7005m_3.ki_toykar02) AS 当年借方金額０２, --当年借方金額０２
    SUM(tbg7005m_3.ki_toykar03) AS 当年借方金額０３, --当年借方金額０３
    SUM(tbg7005m_3.ki_toykar04) AS 当年借方金額０４, --当年借方金額０４
    SUM(tbg7005m_3.ki_toykar05) AS 当年借方金額０５, --当年借方金額０５
    SUM(tbg7005m_3.ki_toykar06) AS 当年借方金額０６, --当年借方金額０６
    SUM(tbg7005m_3.ki_toykar07) AS 当年借方金額０７, --当年借方金額０７
    SUM(tbg7005m_3.ki_toykar08) AS 当年借方金額０８, --当年借方金額０８
    SUM(tbg7005m_3.ki_toykar09) AS 当年借方金額０９, --当年借方金額０９
    SUM(tbg7005m_3.ki_toykar10) AS 当年借方金額１０, --当年借方金額１０
    SUM(tbg7005m_3.ki_toykar11) AS 当年借方金額１１, --当年借方金額１１
    SUM(tbg7005m_3.ki_toykar12) AS 当年借方金額１２, --当年借方金額１２
    SUM(tbg7005m_3.ki_toykas01) AS 当年貸方金額０１, --当年貸方金額０１
    SUM(tbg7005m_3.ki_toykas02) AS 当年貸方金額０２, --当年貸方金額０２
    SUM(tbg7005m_3.ki_toykas03) AS 当年貸方金額０３, --当年貸方金額０３
    SUM(tbg7005m_3.ki_toykas04) AS 当年貸方金額０４, --当年貸方金額０４
    SUM(tbg7005m_3.ki_toykas05) AS 当年貸方金額０５, --当年貸方金額０５
    SUM(tbg7005m_3.ki_toykas06) AS 当年貸方金額０６, --当年貸方金額０６
    SUM(tbg7005m_3.ki_toykas07) AS 当年貸方金額０７, --当年貸方金額０７
    SUM(tbg7005m_3.ki_toykas08) AS 当年貸方金額０８, --当年貸方金額０８
    SUM(tbg7005m_3.ki_toykas09) AS 当年貸方金額０９, --当年貸方金額０９
    SUM(tbg7005m_3.ki_toykas10) AS 当年貸方金額１０, --当年貸方金額１０
    SUM(tbg7005m_3.ki_toykas11) AS 当年貸方金額１１, --当年貸方金額１１
    SUM(tbg7005m_3.ki_toykas12) AS 当年貸方金額１２  --当年貸方金額１２
FROM
    ai21rep_ve_dx.tbg7005m tbg7005m_3 --総勘定ＤＢ
INNER JOIN gold.vbi002001_en v2001 --新車売掛金店舗別_en
    ON v2001.cd_hansya = tbg7005m_3.cd_hansya
    AND v2001.cd_kaisya = tbg7005m_3.cd_kaisya
    AND v2001.cd_tenpo = tbg7005m_3.cd_tenpo
WHERE (tbg7005m_3.cd_hansya <> '03601' OR tbg7005m_3.cd_kaisya <> '01' OR tbg7005m_3.cd_tenpo <> 'ZZZ') --店舗コード制限
    AND tbg7005m_3.nu_yyyy = YEAR(MONTHS_SUB(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 4)) --日付選択で4ヶ月前に対応する年を選択する
    AND tbg7005m_3.cd_kanjyou BETWEEN '5010101' AND '5019999' --勘定科目コード制限
GROUP BY
    tbg7005m_3.cd_hansya,
    tbg7005m_3.cd_kaisya,
    tbg7005m_3.cd_tenpo
LIMIT 0;

-- [030/099] level=1 target=gold.vbi002011
-- Gold dependencies: gold.vbi002001_en
-- Source file: 002_新車売掛金/VBI002011_新車売掛金明細_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi002011 AS
WITH kb_genkin_table AS(
    SELECT
        tbi999013m.cd_hansya, --販社コード
        tbi999013m.cd_kaisya, --会社コード
        GROUP_CONCAT(tbi999013m.kb_nyuukin, ',') AS kb_nyuukin_list --入金区分list
    FROM dx_ve.tbi999013m tbi999013m --販売店入金区分設定
    WHERE tbi999013m.kb_genkin = '1'
    GROUP BY tbi999013m.cd_hansya
            ,tbi999013m.cd_kaisya
),
kb_crejcard_table AS(
    SELECT
        tbi999013m.cd_hansya, --販社コード
        tbi999013m.cd_kaisya, --会社コード
        GROUP_CONCAT(tbi999013m.kb_nyuukin, ',') AS kb_nyuukin_list --入金区分list
    FROM dx_ve.tbi999013m tbi999013m --販売店入金区分設定
    WHERE tbi999013m.kb_crejcard = '1'
    GROUP BY tbi999013m.cd_hansya
            ,tbi999013m.cd_kaisya
),
nt8014m AS(
    SELECT
        t014m.cd_hansya, --販社コード
        t014m.cd_kaisya, --会社コード
        t014m.no_cyumon, --注文ＮＯ
        COUNT(IF(t014m.kb_nyukkanr = '01',t014m.dd_keijyou,NULL)) AS cnt, --合計
        MAX(IF(t014m.kb_nyukkanr = '01',t014m.dd_keijyou,NULL)) AS dd_keijyou1, --計上日1
        MAX(IF(t014m.kb_nyukkanr = '02',t014m.dd_keijyou,NULL)) AS dd_keijyou2, --計上日2
        MAX(IF(t014m.kb_nyukkanr = '03',t014m.dd_keijyou,NULL)) AS dd_keijyou3 --計上日3
    FROM ai21rep_ve_dx.tbg8014m t014m --売掛金履歴ＤＢ
    GROUP BY t014m.cd_hansya, t014m.cd_kaisya, t014m.no_cyumon
),
kt8014m AS(
    SELECT
        t001g.cd_hansya, --販社コード
        t001g.cd_kaisya, --会社コード
        t001g.no_cyumon, --注文ＮＯ
        TRIM(t001g.no_cyumoned) AS no_cyumoned, --注文ＮＯ枝番
        SUM(IF(t014m.dd_keijyou < CAST(FROM_TIMESTAMP(t001g.dd_touroku, 'yyyyMMdd') AS INT),t014m.ki_nyukinur,0)) AS ki_nyukinur1, --入金額兼売上額1
        SUM(IF(FIND_IN_SET(LEFT(t014m.kb_nyuukin, 2),kb_crejcard_table.kb_nyuukin_list) > 0 AND t014m.ki_nyukinur >= 1,1,0)) AS ki_nyukinur2, --カード入金の回数（カード入金金額が1円以上の回数）
        SUM(IF(FIND_IN_SET(LEFT(t014m.kb_nyuukin, 2),kb_crejcard_table.kb_nyuukin_list) > 0 AND t014m.ki_nyukinur <= -1,1,0)) AS ki_nyukinur3, --カード入金の回数（カード入金金額がｰ1円以下の回数）
        SUM(IF(FIND_IN_SET(LEFT(t014m.kb_nyuukin, 2),kb_genkin_table.kb_nyuukin_list) > 0 AND t014m.ki_nyukinur >= 1,1,0)) AS ki_nyukinur4, --現金入金の回数（現金入金金額が1円以上の回数）
        SUM(IF(FIND_IN_SET(LEFT(t014m.kb_nyuukin, 2),kb_genkin_table.kb_nyuukin_list) > 0 AND t014m.ki_nyukinur <= -1,1,0)) AS ki_nyukinur5 --現金入金の回数（現金入金金額がｰ1円以下の回数）
    FROM ai21rep_ve_dx.tbba001g t001g --新車受注基本情報ＤＢ
    INNER JOIN ai21rep_ve_dx.tbg8014m t014m ON t014m.cd_hansya = t001g.cd_hansya  --売掛金履歴ＤＢ
    AND t014m.cd_kaisya = t001g.cd_kaisya
    AND TRIM(t014m.no_cyumon) = TRIM(CONCAT(t001g.no_cyumon, t001g.no_cyumoned))
    AND t014m.kb_urinyuki = '2' --売上入金区分が2である
    LEFT JOIN kb_genkin_table
    ON kb_genkin_table.cd_hansya = t001g.cd_hansya
    AND kb_genkin_table.cd_kaisya = t001g.cd_kaisya
    LEFT JOIN kb_crejcard_table
    ON kb_crejcard_table.cd_hansya = t001g.cd_hansya
    AND kb_crejcard_table.cd_kaisya = t001g.cd_kaisya
    GROUP BY t001g.cd_hansya, t001g.cd_kaisya, t001g.no_cyumon, TRIM(t001g.no_cyumoned)
)
SELECT
    t001g.cd_hansya AS 販社コード, --販社コード
    t001g.cd_kaisya AS 会社コード, --会社コード
    t001g.cd_tenpo AS 店舗コード, --店舗コード
    t001g.no_cyumon AS 注文ＮＯ, --注文ＮＯ
    TRIM(t001g.no_cyumoned) AS 注文枝番, --注文枝番
    CONCAT(t001g.cd_hansya, t001g.cd_kaisya, t001g.no_cyumon, TRIM(t001g.no_cyumoned)) AS pk_販社会社注文no枝番, --pk_販社会社注文no枝番
    CONCAT(t001g.cd_hansya, t001g.cd_kaisya, t001g.cd_tenpo) AS 販社会社店舗コード, --販社会社店舗コード
	v2001.kj_tentanms AS 店舗略称, --店舗略称
    v2001.zone_name_abbreviation AS エリア統括部, --エリア統括部
    v2001.cd_zon AS ゾーンコード, --ゾーンコード
    v2001.sort_order AS ソート順, --ソート順
    IF(t001g.dd_touroku IS NOT NULL,'登録済','未登録') AS 登録, --登録
    IF(t001g.dd_nosya IS NOT NULL,'納車済','未納車') AS 納車, --納車
    IF((NVL(t052g.ki_haseirui,0) - NVL(t052g.ki_genknykg,0) - NVL(t052g.ki_sitanykg,0) - NVL(t052g.ki_fuharnyk,0)) = 0,'残高なし','残高あり') AS 売掛残高, --売掛残高
    t014m.kj_syainmei AS 社員名, --社員名
    DATEDIFF(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), t001g.dd_touroku) AS 売上経過日数, --売上経過日数
    CONCAT(REGEXP_REPLACE(t001g.kj_kainmei1, '　+$', ''), REGEXP_REPLACE(t001g.kj_kainmei2, '　+$', '')) AS 買主名, --買主名
    CONCAT(REGEXP_REPLACE(t001g.kj_meigime1, '　+$', ''), REGEXP_REPLACE(t001g.kj_meigime2, '　+$', '')) AS 名義人, --名義人
    CASE t052g.mj_keiykeit
        WHEN '1' THEN '現金'
        WHEN '2' THEN '後払い'
        WHEN '3' THEN '自社割賦'
        WHEN '4' THEN '信用購入斡旋'
        WHEN '5' THEN '債権譲渡'
        WHEN '' THEN 'その他'
    END AS 契約形態, --契約形態
    TRIM(CONCAT(t001g.no_cyumon, t001g.no_cyumoned)) AS 注文no_枝番, --注文no_枝番
    SPLIT_PART(t001g.mj_hantenkt, '-', 1) AS 型式, --型式
    t001g.dd_jucyu AS 受注日, --受注日
    t001g.dd_fr AS 振当日, --振当日
    t052g.dd_maeuknyu AS 申込金受領日, --申込金受領日
    t001g.dd_touroku AS 登録日, --登録日
    t001g.dd_haisou AS 配送日, --配送日
    t001g.dd_nosya AS 納車日, --納車日
    NVL(t052g.dd_minasksy, t052g.dd_kaisyuyo) AS 回収予定日, --回収予定日
    TO_TIMESTAMP(CAST(nt8014m1.dd_keijyou1 AS STRING), 'yyyyMMdd') AS 最終入金日現金, --最終入金日現金
    TO_TIMESTAMP(CAST(nt8014m1.dd_keijyou2 AS STRING), 'yyyyMMdd') AS 最終入金日割賦, --最終入金日割賦
    TO_TIMESTAMP(CAST(nt8014m1.dd_keijyou3 AS STRING), 'yyyyMMdd') AS 下取完了日, --下取完了日
    t001g.dd_urikzumi AS 完了, --完了
    t052g.ki_genknykg AS 現金入金額, --現金入金額
    t052g.ki_sitanykg AS 下取車入金額, --下取車入金額
    t052g.ki_fuharnyk AS 賦払金入金額, --賦払金入金額
    (NVL(t052g.ki_haseirui,0) - NVL(t052g.ki_genknykg,0) - NVL(t052g.ki_sitanykg,0) - NVL(t052g.ki_fuharnyk,0)) AS 売掛金残高合計, --売掛金残高合計
    t052g.ki_genkhasg AS 現金発生額, --現金発生額
    (NVL(t052g.ki_genkhasg,0) - NVL(t052g.ki_genknykg,0)) AS 現金残高, --現金残高
    t052g.ki_fuharhsk AS 賦払金発生額, --賦払金発生額
    (NVL(t052g.ki_fuharhsk,0) - NVL(t052g.ki_fuharnyk,0)) AS 割賦残高, --割賦残高
    t052g.ki_sitahasg AS 下取車発生額, --下取車発生額
    (NVL(t052g.ki_sitahasg,0) - NVL(t052g.ki_sitanykg,0)) AS 下取車残高, --下取車残高
    IF (
        t001g.dd_touroku IS NULL OR nt8014m1.dd_keijyou1 IS NULL OR TO_TIMESTAMP(CAST(nt8014m1.dd_keijyou1 AS STRING), 'yyyyMMdd') < t001g.dd_touroku,  -- 最終入金日
        t052g.ki_nyuruike,
        NVL(kt8014m.ki_nyukinur1, 0)
    ) AS 申込金, --申込金
    NVL(kt8014m.ki_nyukinur4 - kt8014m.ki_nyukinur5, 0) AS 現金入金回数, --現金入金回数
    --NVL(nt8014m1.cnt, 0) AS 現金入金回数, --現金入金回数
    NVL(kt8014m.ki_nyukinur2 - kt8014m.ki_nyukinur3, 0) AS カード入金回数, --カード入金回数
    DATEDIFF(t001g.dd_nosya, t001g.dd_fr) AS '振当-納車', --振当-納車
    DATEDIFF(t001g.dd_nosya, t001g.dd_touroku) AS '登録-納車', --登録-納車
    DATEDIFF(t001g.dd_urikzumi, t001g.dd_touroku) AS '登録-完了', --登録-完了
    CASE LEFT(t001g.kb_haraidas, 1)
        WHEN '1' THEN '一般売上'
        WHEN '3' THEN 'リース'
    END AS 払出区分, --払出区分
    if(
        t051g1.kb_seibetu = '1' AND t051g2.kb_seibetu = '1'
        OR t051g1.kb_seibetu = '2' AND t051g2.kb_seibetu = '1'
        OR t051g1.kb_seibetu = '1' AND t051g2.kb_seibetu = '2'
        OR t051g1.kb_seibetu = '2' AND t051g2.kb_seibetu = '2',
        '個人',
        '法人'
    ) AS 法人個人区分, --法人個人区分
    t052g.ki_haseirui AS 発生累計, --発生累計
    t001g.dt_saisinup AS 更新日時 --更新日時
FROM ai21rep_ve_dx.tbba001g t001g --新車受注基本情報ＤＢ
INNER JOIN gold.vbi002001_en v2001 --新車売掛金店舗別_en
    ON v2001.cd_hansya = t001g.cd_hansya
    AND v2001.cd_kaisya = t001g.cd_kaisya
    AND v2001.cd_tenpo = t001g.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbba052g t052g --新車受注販売条件情報ＤＢ
    ON t052g.cd_hansya = t001g.cd_hansya
    AND t052g.cd_kaisya = t001g.cd_kaisya
    AND t052g.no_cyumon = t001g.no_cyumon
    AND TRIM(t052g.no_cyumoned) = TRIM(t001g.no_cyumoned)
LEFT JOIN ai21rep_ve_dx.tbv0014m t014m --Ｍ社員ＤＢ
    ON t014m.cd_hansya = t001g.cd_hansya
    AND t014m.cd_kaisya = t001g.cd_kaisya
    AND t014m.cd_syain = t001g.cd_hanstaff
LEFT JOIN nt8014m nt8014m1
    ON nt8014m1.cd_hansya = t001g.cd_hansya
    AND nt8014m1.cd_kaisya = t001g.cd_kaisya
    AND TRIM(nt8014m1.no_cyumon) = TRIM(concat(t001g.no_cyumon, t001g.no_cyumoned))
LEFT JOIN kt8014m
    ON kt8014m.cd_hansya = t001g.cd_hansya
    AND kt8014m.cd_kaisya = t001g.cd_kaisya
    AND TRIM(kt8014m.no_cyumon) = t001g.no_cyumon
    AND TRIM(kt8014m.no_cyumoned) = TRIM(t001g.no_cyumoned)
LEFT JOIN ai21rep_ve_dx.tbba051g t051g1 --新車受注顧客情報ＤＢ
    ON t051g1.cd_hansya = t001g.cd_hansya
    AND t051g1.cd_kaisya = t001g.cd_kaisya
    AND t051g1.no_cyumon = t001g.no_cyumon
    AND TRIM(t051g1.no_cyumoned) = TRIM(t001g.no_cyumoned)
    AND t051g1.kb_kokyaku = '1' --顧客区分が1である
LEFT JOIN ai21rep_ve_dx.tbba051g t051g2 --新車受注顧客情報ＤＢ
    ON t051g2.cd_hansya = t001g.cd_hansya
    AND t051g2.cd_kaisya = t001g.cd_kaisya
    AND t051g2.no_cyumon = t001g.no_cyumon
    AND TRIM(t051g2.no_cyumoned) = TRIM(t001g.no_cyumoned)
    AND t051g2.kb_kokyaku = '2' --顧客区分が2である
WHERE isnottrue(
    (t052g.ki_haseirui - t052g.ki_genknykg - t052g.ki_sitanykg - t052g.ki_fuharnyk) = 0 --値があると残高がある
    AND((t001g.dd_touroku IS NOT NULL AND t001g.dd_nosya < DATE '2023-03-01' --登録日がNULLではないではありませんそして納車日が2023-03-01以前
        AND (t001g.dd_urikzumi IS NULL OR t001g.dd_urikzumi < DATE '2024-03-01')) --売掛金完済日がNULLであるまたは売掛金完済日が2024-03-01以前
        OR (t001g.dd_nosya IS NULL AND t001g.dd_touroku < DATE '2023-03-01') --納車日がNULLであるそして登録日が2023-03-01以前
        OR t001g.dd_urikzumi < DATE '2024-03-01' --納車日が2024-03-01以前
        OR (t001g.dd_touroku IS NULL AND t001g.dd_jucyu < DATE '2020-12-01') --登録日がNULLであるまたは受注日が2020-12-01以前
        )
    )
AND (t001g.dd_torotrkk IS NULL
    OR (t052g.ki_haseirui - t052g.ki_genknykg - t052g.ki_sitanykg - t052g.ki_fuharnyk) <> 0) --値があると残高がある
AND (LEFT(t001g.kb_haraidas, 1) = '1' --払出区分が1である
    OR (LEFT(t001g.kb_haraidas, 1) = '3' --払出区分が3である
        AND NOT((t052g.ki_haseirui - t052g.ki_genknykg - t052g.ki_sitanykg - t052g.ki_fuharnyk) = 0 --値があると残高がある
            AND (t052g.ki_genkhasg - t052g.ki_genknykg) = 0 --現金発生額から現金入金額を引いた値が0である
            AND (t052g.ki_fuharhsk - t052g.ki_fuharnyk) = 0 --賦払金発生額から下取車入金額を引いた値が0である
            AND (t052g.ki_sitahasg - t052g.ki_sitanykg) = 0 --下取車発生額から下取車入金額を引いた値が0である
            )
        )
    )
LIMIT 0;

-- [031/099] level=1 target=gold.vbi0020012
-- Gold dependencies: gold.vbi002001_en
-- Source file: 002_新車売掛金/VBI002012_新車売掛金回転日数_売掛金_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi0020012 AS
SELECT
    tbg7005m_3.cd_hansya AS 販社コード, --販社コード
    tbg7005m_3.cd_kaisya AS 会社コード, --会社コード
    tbg7005m_3.cd_tenpo AS 店舗コード, --店舗コード
    tbg7005m_3.cd_hansya || tbg7005m_3.cd_kaisya || tbg7005m_3.cd_tenpo AS 販社会社店舗コード, --販社会社店舗コード
    SUM(tbg7005m_3.ki_toyjkksy) AS 当年上期期首残高, --当年上期期首残高
    SUM(tbg7005m_3.ki_toykar01) AS 当年借方金額０１, --当年借方金額０１
    SUM(tbg7005m_3.ki_toykar02) AS 当年借方金額０２, --当年借方金額０２
    SUM(tbg7005m_3.ki_toykar03) AS 当年借方金額０３, --当年借方金額０３
    SUM(tbg7005m_3.ki_toykar04) AS 当年借方金額０４, --当年借方金額０４
    SUM(tbg7005m_3.ki_toykar05) AS 当年借方金額０５, --当年借方金額０５
    SUM(tbg7005m_3.ki_toykar06) AS 当年借方金額０６, --当年借方金額０６
    SUM(tbg7005m_3.ki_toykar07) AS 当年借方金額０７, --当年借方金額０７
    SUM(tbg7005m_3.ki_toykar08) AS 当年借方金額０８, --当年借方金額０８
    SUM(tbg7005m_3.ki_toykar09) AS 当年借方金額０９, --当年借方金額０９
    SUM(tbg7005m_3.ki_toykar10) AS 当年借方金額１０, --当年借方金額１０
    SUM(tbg7005m_3.ki_toykar11) AS 当年借方金額１１, --当年借方金額１１
    SUM(tbg7005m_3.ki_toykar12) AS 当年借方金額１２, --当年借方金額１２
    SUM(tbg7005m_3.ki_toykas01) AS 当年貸方金額０１, --当年貸方金額０１
    SUM(tbg7005m_3.ki_toykas02) AS 当年貸方金額０２, --当年貸方金額０２
    SUM(tbg7005m_3.ki_toykas03) AS 当年貸方金額０３, --当年貸方金額０３
    SUM(tbg7005m_3.ki_toykas04) AS 当年貸方金額０４, --当年貸方金額０４
    SUM(tbg7005m_3.ki_toykas05) AS 当年貸方金額０５, --当年貸方金額０５
    SUM(tbg7005m_3.ki_toykas06) AS 当年貸方金額０６, --当年貸方金額０６
    SUM(tbg7005m_3.ki_toykas07) AS 当年貸方金額０７, --当年貸方金額０７
    SUM(tbg7005m_3.ki_toykas08) AS 当年貸方金額０８, --当年貸方金額０８
    SUM(tbg7005m_3.ki_toykas09) AS 当年貸方金額０９, --当年貸方金額０９
    SUM(tbg7005m_3.ki_toykas10) AS 当年貸方金額１０, --当年貸方金額１０
    SUM(tbg7005m_3.ki_toykas11) AS 当年貸方金額１１, --当年貸方金額１１
    SUM(tbg7005m_3.ki_toykas12) AS 当年貸方金額１２  --当年貸方金額１２
FROM 
    ai21rep_ve_dx.tbg7005m tbg7005m_3 --総勘定ＤＢ
INNER JOIN gold.vbi002001_en v2001 --新車売掛金店舗別_en
    ON v2001.cd_hansya = tbg7005m_3.cd_hansya
    AND v2001.cd_kaisya = tbg7005m_3.cd_kaisya
    AND v2001.cd_tenpo = tbg7005m_3.cd_tenpo
WHERE 
    (tbg7005m_3.cd_hansya <> '03601' OR tbg7005m_3.cd_kaisya <> '01' OR tbg7005m_3.cd_tenpo <> 'ZZZ') --店舗コード制限
    AND tbg7005m_3.nu_yyyy = YEAR(MONTHS_SUB(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 4)) --日付選択で4ヶ月前に対応する年を選択する
    AND tbg7005m_3.cd_kanjyou = '10401  ' --勘定科目コード制限
GROUP BY
    tbg7005m_3.cd_hansya,
    tbg7005m_3.cd_kaisya,
    tbg7005m_3.cd_tenpo
LIMIT 0;

-- [032/099] level=1 target=gold.vbi0020013
-- Gold dependencies: gold.vbi002001_en
-- Source file: 002_新車売掛金/VBI002013_新車売掛金回転日数_回転日数1_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi0020013 AS
SELECT
    tbg7005m_3.cd_hansya AS 販社コード, --販社コード
    tbg7005m_3.cd_kaisya AS 会社コード, --会社コード
    tbg7005m_3.cd_tenpo AS 店舗コード, --店舗コード
    tbg7005m_3.cd_hansya || tbg7005m_3.cd_kaisya || tbg7005m_3.cd_tenpo AS 販社会社店舗コード, --販社会社店舗コード
    SUM(tbg7005m_3.ki_toykar01) AS 当年借方金額０１, --当年借方金額０１
    SUM(tbg7005m_3.ki_toykar02) AS 当年借方金額０２, --当年借方金額０２
    SUM(tbg7005m_3.ki_toykar03) AS 当年借方金額０３, --当年借方金額０３
    SUM(tbg7005m_3.ki_toykar04) AS 当年借方金額０４, --当年借方金額０４
    SUM(tbg7005m_3.ki_toykar05) AS 当年借方金額０５, --当年借方金額０５
    SUM(tbg7005m_3.ki_toykar06) AS 当年借方金額０６, --当年借方金額０６
    SUM(tbg7005m_3.ki_toykar07) AS 当年借方金額０７, --当年借方金額０７
    SUM(tbg7005m_3.ki_toykar08) AS 当年借方金額０８, --当年借方金額０８
    SUM(tbg7005m_3.ki_toykar09) AS 当年借方金額０９, --当年借方金額０９
    SUM(tbg7005m_3.ki_toykar10) AS 当年借方金額１０, --当年借方金額１０
    SUM(tbg7005m_3.ki_toykar11) AS 当年借方金額１１, --当年借方金額１１
    SUM(tbg7005m_3.ki_toykar12) AS 当年借方金額１２, --当年借方金額１２
    SUM(tbg7005m_3.ki_toykas01) AS 当年貸方金額０１, --当年貸方金額０１
    SUM(tbg7005m_3.ki_toykas02) AS 当年貸方金額０２, --当年貸方金額０２
    SUM(tbg7005m_3.ki_toykas03) AS 当年貸方金額０３, --当年貸方金額０３
    SUM(tbg7005m_3.ki_toykas04) AS 当年貸方金額０４, --当年貸方金額０４
    SUM(tbg7005m_3.ki_toykas05) AS 当年貸方金額０５, --当年貸方金額０５
    SUM(tbg7005m_3.ki_toykas06) AS 当年貸方金額０６, --当年貸方金額０６
    SUM(tbg7005m_3.ki_toykas07) AS 当年貸方金額０７, --当年貸方金額０７
    SUM(tbg7005m_3.ki_toykas08) AS 当年貸方金額０８, --当年貸方金額０８
    SUM(tbg7005m_3.ki_toykas09) AS 当年貸方金額０９, --当年貸方金額０９
    SUM(tbg7005m_3.ki_toykas10) AS 当年貸方金額１０, --当年貸方金額１０
    SUM(tbg7005m_3.ki_toykas11) AS 当年貸方金額１１, --当年貸方金額１１
    SUM(tbg7005m_3.ki_toykas12) AS 当年貸方金額１２  --当年貸方金額１２
FROM 
    ai21rep_ve_dx.tbg7005m tbg7005m_3 --総勘定ＤＢ
INNER JOIN gold.vbi002001_en v2001 --新車売掛金店舗別_en
    ON v2001.cd_hansya = tbg7005m_3.cd_hansya
    AND v2001.cd_kaisya = tbg7005m_3.cd_kaisya
    AND v2001.cd_tenpo = tbg7005m_3.cd_tenpo
WHERE 
    (tbg7005m_3.cd_hansya <> '03601' OR tbg7005m_3.cd_kaisya <> '01' OR tbg7005m_3.cd_tenpo <> 'ZZZ') --店舗コード制限
    AND tbg7005m_3.nu_yyyy = YEAR(MONTHS_SUB(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 4))-1 --日付選択で4ヶ月前に対応する年を選択する
    AND tbg7005m_3.cd_kanjyou >= '5010101' AND tbg7005m_3.cd_kanjyou <= '5019999' --勘定科目コード制限
GROUP BY
    tbg7005m_3.cd_hansya,
    tbg7005m_3.cd_kaisya,
    tbg7005m_3.cd_tenpo
LIMIT 0;

-- [033/099] level=1 target=gold.vbi0020014
-- Gold dependencies: gold.vbi002001_en
-- Source file: 002_新車売掛金/VBI002014_新車売掛金回転日数_回転日数2_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi0020014 AS
SELECT
    tbg7005m_3.cd_hansya AS 販社コード, --販社コード
    tbg7005m_3.cd_kaisya AS 会社コード, --会社コード
    tbg7005m_3.cd_tenpo AS 店舗コード, --店舗コード
    tbg7005m_3.cd_hansya || tbg7005m_3.cd_kaisya || tbg7005m_3.cd_tenpo AS 販社会社店舗コード, --販社会社店舗コード
    SUM(tbg7005m_3.ki_toyjkksy) AS 当年上期期首残高, --当年上期期首残高
    SUM(tbg7005m_3.ki_toykar01) AS 当年借方金額０１, --当年借方金額０１
    SUM(tbg7005m_3.ki_toykar02) AS 当年借方金額０２, --当年借方金額０２
    SUM(tbg7005m_3.ki_toykar03) AS 当年借方金額０３, --当年借方金額０３
    SUM(tbg7005m_3.ki_toykar04) AS 当年借方金額０４, --当年借方金額０４
    SUM(tbg7005m_3.ki_toykar05) AS 当年借方金額０５, --当年借方金額０５
    SUM(tbg7005m_3.ki_toykar06) AS 当年借方金額０６, --当年借方金額０６
    SUM(tbg7005m_3.ki_toykar07) AS 当年借方金額０７, --当年借方金額０７
    SUM(tbg7005m_3.ki_toykar08) AS 当年借方金額０８, --当年借方金額０８
    SUM(tbg7005m_3.ki_toykar09) AS 当年借方金額０９, --当年借方金額０９
    SUM(tbg7005m_3.ki_toykar10) AS 当年借方金額１０, --当年借方金額１０
    SUM(tbg7005m_3.ki_toykar11) AS 当年借方金額１１, --当年借方金額１１
    SUM(tbg7005m_3.ki_toykar12) AS 当年借方金額１２, --当年借方金額１２
    SUM(tbg7005m_3.ki_toykas01) AS 当年貸方金額０１, --当年貸方金額０１
    SUM(tbg7005m_3.ki_toykas02) AS 当年貸方金額０２, --当年貸方金額０２
    SUM(tbg7005m_3.ki_toykas03) AS 当年貸方金額０３, --当年貸方金額０３
    SUM(tbg7005m_3.ki_toykas04) AS 当年貸方金額０４, --当年貸方金額０４
    SUM(tbg7005m_3.ki_toykas05) AS 当年貸方金額０５, --当年貸方金額０５
    SUM(tbg7005m_3.ki_toykas06) AS 当年貸方金額０６, --当年貸方金額０６
    SUM(tbg7005m_3.ki_toykas07) AS 当年貸方金額０７, --当年貸方金額０７
    SUM(tbg7005m_3.ki_toykas08) AS 当年貸方金額０８, --当年貸方金額０８
    SUM(tbg7005m_3.ki_toykas09) AS 当年貸方金額０９, --当年貸方金額０９
    SUM(tbg7005m_3.ki_toykas10) AS 当年貸方金額１０, --当年貸方金額１０
    SUM(tbg7005m_3.ki_toykas11) AS 当年貸方金額１１, --当年貸方金額１１
    SUM(tbg7005m_3.ki_toykas12) AS 当年貸方金額１２  --当年貸方金額１２
FROM ai21rep_ve_dx.tbg7005m tbg7005m_3 --総勘定ＤＢ
INNER JOIN gold.vbi002001_en v2001 --新車売掛金店舗別_en
    ON v2001.cd_hansya = tbg7005m_3.cd_hansya
    AND v2001.cd_kaisya = tbg7005m_3.cd_kaisya
    AND v2001.cd_tenpo = tbg7005m_3.cd_tenpo
WHERE (tbg7005m_3.cd_hansya <> '03601' OR tbg7005m_3.cd_kaisya <> '01' OR tbg7005m_3.cd_tenpo <> 'ZZZ') --店舗コード制限
    AND tbg7005m_3.nu_yyyy = YEAR(MONTHS_SUB(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 4))-1 --日付選択で4ヶ月前に対応する年を選択する
    AND tbg7005m_3.cd_kanjyou = '10401  ' --勘定科目コード制限
GROUP BY
    tbg7005m_3.cd_hansya,
    tbg7005m_3.cd_kaisya,
    tbg7005m_3.cd_tenpo
LIMIT 0;

-- [034/099] level=0 target=gold.VBI002015
-- Gold dependencies: none
-- Source file: 002_新車売掛金/VBI002015_アラートの文言テーブル_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI002015 AS
WITH alert_text AS (
    SELECT '0' AS Value, '' AS aler_text --aler_text
    UNION ALL
    SELECT '1', '回収遅延'
    UNION ALL
    SELECT '2', '入金超過'
    UNION ALL
    SELECT '3', '未納車'
    UNION ALL
    SELECT '4', '納車済残高あり'
    UNION ALL
    SELECT '5', '複数回入金'
    UNION ALL
    SELECT '6', 'リードタイム'
    UNION ALL
    SELECT 'a', ''
    UNION ALL
    SELECT 'b', ''
    UNION ALL
    SELECT 'c', ''
    UNION ALL
    SELECT 'd', ''
    UNION ALL
    SELECT 'e', ''
    UNION ALL
    SELECT 'f', ''
    )

SELECT
     tbi002001m.cd_hansya AS 販社コード --販社コード
    ,tbi002001m.cd_kaisya AS 会社コード --会社コード
    ,Value
    ,IF(Value = '6',CONCAT('リードタイム', CAST(COALESCE(tbi002001m.su_leadtime, 20) AS STRING), '日以上チェック'),aler_text) AS アラート文言 --アラート文言
FROM
    alert_text
CROSS JOIN
    dx_ve.tbi002001m tbi002001m -- --_新車アラート項目設定
LIMIT 0;

-- [035/099] level=0 target=gold.VBI002016
-- Gold dependencies: none
-- Source file: 002_新車売掛金/VBI002016_アラートの文言テーブル(条件検索)_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI002016 AS
WITH alert_text AS (
    SELECT '0' AS Value, '' AS aler_text --aler_text
    UNION ALL
    SELECT '1', ''
    UNION ALL
    SELECT '2', ''
    UNION ALL
    SELECT '3', ''
    UNION ALL
    SELECT '4', ''
    UNION ALL
    SELECT '5', ''
    UNION ALL
    SELECT '6', ''
    UNION ALL
    SELECT 'a', '売掛回収チェック'
    UNION ALL
    SELECT 'b', '未納車30日経過'
    UNION ALL
    SELECT 'c', '登録90日経過'
    UNION ALL
    SELECT 'd', '振当90日経過'
    UNION ALL
    SELECT 'e', '受注1年経過'
    UNION ALL
    SELECT 'f', 'キャンセル未返金'
    )

SELECT
     tbi002001m.cd_hansya AS 販社コード --販社コード
    ,tbi002001m.cd_kaisya AS 会社コード --会社コード
    ,Value
    ,CASE
        WHEN Value = 'b' THEN CONCAT('未納車', CAST(COALESCE(tbi002001m.su_minosya, 30) AS STRING), '日経過')
        WHEN Value = 'c' THEN CONCAT('登録', CAST(COALESCE(tbi002001m.su_touroku, 20) AS STRING), '日経過')
        WHEN Value = 'd' THEN CONCAT('振当', CAST(COALESCE(tbi002001m.su_fr, 20) AS STRING), '日経過')
        WHEN Value = 'f' THEN CONCAT('受注', CAST(COALESCE(tbi002001m.su_jucyu, 20) AS STRING), '日経過')
        ELSE aler_text
    END AS アラート文言 --アラート文言
FROM
    alert_text
CROSS JOIN
    dx_ve.tbi002001m tbi002001m --_新車アラート項目設定
LIMIT 0;

-- [036/099] level=0 target=gold.vbi003001_en
-- Gold dependencies: none
-- Source file: 003_ストール充足率見える化（ストール軸管理向け）/smb_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi003001_en AS
select
	--日付
	bt.dd_date,
	--日付_月
	trunc(bt.dd_date, 'MM') as dd_month,
	--日付_yyyy/MM/dd
	from_timestamp(bt.dd_date, 'yyyy/MM/dd') as `dd_yyyy/MM/dd`,
	--日付_yyyyMMdd
	from_timestamp(bt.dd_date, 'yyyyMMdd') as `dd_yyyyMMdd`,
	--週末判定
	case dayofweek(bt.dd_date)
		when 1 then '2'
		when 7 then '2'
		else '1'
	end as kb_week
from (
	select
		days_add(cast(from_utc_timestamp(utc_timestamp(), 'JST') as date), i) as dd_date
	from(
		VALUES((0 AS i),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13))
	) dd
) bt
LIMIT 0;

-- [037/099] level=1 target=gold.vbi003001
-- Gold dependencies: gold.vbi003001_en
-- Source file: 003_ストール充足率見える化（ストール軸管理向け）/smb_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi003001 AS
select
	--日付
	dd_date as `日付`,
	--日付_月
	dd_month as `日付_月`,
	--日付_yyyy/MM/dd
	`dd_yyyy/MM/dd` as `日付_yyyy/MM/dd`,
	--日付_yyyyMMdd
	`dd_yyyyMMdd` as `日付_yyyyMMdd`,
	--週末判定
	kb_week as `週末判定`
from gold.vbi003001_en
LIMIT 0;

-- [038/099] level=0 target=gold.vbi003002
-- Gold dependencies: none
-- Source file: 003_ストール充足率見える化（ストール軸管理向け）/smb_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi003002 AS
select
	--ソート順
	dense_rank() over(partition by t3002m.cd_hansya, t3002m.cd_kaisya order by  IF(
                t033m.kj_zonmei IS NULL OR regexp_replace(t033m.kj_zonmei, '[ 　]+', '') = '',
                '999999',
                IF(
                    t033m.cd_zon IS NULL OR regexp_replace(t033m.cd_zon, '[ 　]+', '') = '',
                    '999998',
                    t033m.cd_zon
                )
            ), t9003m.mj_sortjyun, t3002m.cd_tenpo) as mj_sortjyun,
	--販社コード
	t3002m.cd_hansya,
	--会社コード
	t3002m.cd_kaisya,
	--店舗コード
	t3002m.cd_tenpo,
	--店舗名
	regexp_replace(t201m.kj_tenpomei, '　+$', '') as kj_tenpomei,
	--エリアコード
	IF(
    	t033m.kj_zonmei IS NULL OR regexp_replace(t033m.kj_zonmei, '[ 　]+', '') = '',
    	'999999',
    	IF(
        	t033m.cd_zon IS NULL OR regexp_replace(t033m.cd_zon, '[ 　]+', '') = '',
        	'999998',
        	t033m.cd_zon
    	)
	) AS cd_zon,
	--エリア名
	regexp_replace(t033m.kj_zonmei, '　+$', '') as kj_zonmei,
	--ストール番号
	t3002m.no_stall,
	--ストール名称
	t3002m.mj_stallmei,
	--集計対象判別
	t3002m.kb_shuukeitaishou,
	--販社会社店舗ストール番号
	concat(t3002m.cd_hansya, t3002m.cd_kaisya, t3002m.cd_tenpo, cast(t3002m.no_stall as string)) as cd_hansyakaisyatenpostall,
	--ストール選択
	concat(cast(t3002m.no_stall as string), '　', t3002m.mj_stallmei) as kb_stallsentaku,
	-- 出勤時間
	t3001m.tm_kaiten,
	--出勤時間_秒
	unix_timestamp(concat('1970-01-01 ', t3001m.tm_kaiten)) as tm_shukkinsecond,
	-- 退勤時間
	t3001m.tm_heiten,
	--退勤時間_秒
	unix_timestamp(concat('1970-01-01 ', t3001m.tm_heiten)) as tm_taikinsecond,
	--残業時間
	from_timestamp(hours_add(concat('1970-01-01 ', t3001m.tm_heiten), 2), 'HH:mm:ss') as tm_zangyo,
	--定外規定
	1440 / 12 as kb_teigaikitei,
	--定内規定
	(unix_timestamp(concat('1970-01-01 ', t3001m.tm_heiten)) - unix_timestamp(concat('1970-01-01 ', t3001m.tm_kaiten))) / 60 - 60 as kb_teinaikitei,
	--販社会社店舗コード
	concat(t3002m.cd_hansya, t3002m.cd_kaisya, t3002m.cd_tenpo) as cd_hansyakaisyatenpo
-- ストール集計対象一覧
from dx_ve.tbi003002m t3002m
-- 店舗表示設定
inner join dx_ve.tbi999003m t9003m on t9003m.cd_hansya = t3002m.cd_hansya
and t9003m.cd_kaisya = t3002m.cd_kaisya
and t9003m.cd_tenpo = t3002m.cd_tenpo
and t9003m.mj_cyohyoid = '003'
and t9003m.kb_tenji = 1
-- SMB異常管理ボード集計対象店舗一覧
inner join dx_ve.tbi003001m t3001m on t3001m.cd_hansya = t3002m.cd_hansya
and t3001m.cd_kaisya = t3002m.cd_kaisya
and t3001m.cd_tenpo = t3002m.cd_tenpo
-- 共通店舗ＤＢ
left join ai21rep_ve_dx.tbv0201m t201m on t201m.cd_hansya = t3002m.cd_hansya
and t201m.cd_kaisya = t3002m.cd_kaisya
and t201m.cd_tenpo = t3002m.cd_tenpo
-- サービス店舗ＤＢ
left join ai21rep_ve_dx.tbv0202m t202m on t202m.cd_hansya = t201m.cd_hansya
and t202m.cd_kaisya = t201m.cd_kaisya
and t202m.cd_tenpo = t201m.cd_tenpo
-- ＭゾーンコードＤＢ
left join ai21rep_ve_dx.tbv0033m t033m on t033m.cd_hansya = t202m.cd_hansya
and t033m.cd_kaisya = t202m.cd_kaisya
and t033m.cd_zon = t202m.cd_zon
and t033m.kb_syohin  = '3'
where t3002m.kb_shuukeitaishou = '1'
-- ISERROR(SEARCH("コント", [ストール名称], 1))
and instr(t3002m.mj_stallmei, 'コント') = 0
-- ISERROR(SEARCH("外注", [ストール名称], 1))
and instr(t3002m.mj_stallmei, '外注') = 0
LIMIT 0;

-- [039/099] level=1 target=gold.vbi003003
-- Gold dependencies: gold.vbi003001_en, gold.vbi003002
-- Source file: 003_ストール充足率見える化（ストール軸管理向け）/smb_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi003003 AS
with t275m as (
	select
		--販社コード
		t275m.cd_hansya,
		--会社コード
		t275m.cd_kaisya,
		--店舗コード
		t275m.cd_tenpo,
		--稼動日付
		v3001.dd_date as dd_kado,
		--稼動区分
		case day(v3001.dd_date)
			when 1 then t275m.kb_kado1
			when 2 then t275m.kb_kado2
			when 3 then t275m.kb_kado3
			when 4 then t275m.kb_kado4
			when 5 then t275m.kb_kado5
			when 6 then t275m.kb_kado6
			when 7 then t275m.kb_kado7
			when 8 then t275m.kb_kado8
			when 9 then t275m.kb_kado9
			when 10 then t275m.kb_kado10
			when 11 then t275m.kb_kado11
			when 12 then t275m.kb_kado12
			when 13 then t275m.kb_kado13
			when 14 then t275m.kb_kado14
			when 15 then t275m.kb_kado15
			when 16 then t275m.kb_kado16
			when 17 then t275m.kb_kado17
			when 18 then t275m.kb_kado18
			when 19 then t275m.kb_kado19
			when 20 then t275m.kb_kado20
			when 21 then t275m.kb_kado21
			when 22 then t275m.kb_kado22
			when 23 then t275m.kb_kado23
			when 24 then t275m.kb_kado24
			when 25 then t275m.kb_kado25
			when 26 then t275m.kb_kado26
			when 27 then t275m.kb_kado27
			when 28 then t275m.kb_kado28
			when 29 then t275m.kb_kado29
			when 30 then t275m.kb_kado30
			when 31 then t275m.kb_kado31
		end as kb_kado
	-- 店舗稼動日程ＤＢ
	from ai21rep_ve_dx.tbfy275m t275m
	-- 日付_14日
	inner join gold.vbi003001_en v3001 on v3001.dd_month = t275m.dd_kadoyymm
)
select
	--ソート順
	v3002.mj_sortjyun,
	--販社コード
	v3002.cd_hansya,
	--会社コード
	v3002.cd_kaisya,
	--店舗コード
	v3002.cd_tenpo,
	--店舗名
	v3002.kj_tenpomei,
	--販社会社店舗ストール番号
	v3002.cd_hansyakaisyatenpostall,
	--ストール番号
	v3002.no_stall,
	--ストール名称
	v3002.mj_stallmei,
	--ストール選択
	v3002.kb_stallsentaku,
	--エリアコード
	v3002.cd_zon,
	--エリア名
	v3002.kj_zonmei,
	--定外規定
	v3002.kb_teigaikitei,
	--定内規定
	if(
		-- 店舗休みの場合、休みとみなす
		t275m.kb_kado not in('1', '9')
		-- 店舗休みではない場合、ストールの[非稼動区分]が1でない場合、稼働とみなす
		or t002m.kb_hikado = '1',
		0,
		v3002.kb_teinaikitei
	) as kb_teinaikitei,
	-- 休憩区分
	if(
		-- 店舗休みの場合、休みとみなす
		t275m.kb_kado not in('1', '9')
		-- 店舗休みではない場合、ストールの[非稼動区分]が1でない場合、稼働とみなす
		or t002m.kb_hikado = '1',
		1,
		0
	) as kb_kyukei,
	--日付
	v3001.dd_date,
	--販社会社店舗ストール番号日付
	concat(v3002.cd_hansyakaisyatenpostall, v3001.`dd_yyyy/MM/dd`) as cd_hansyakaisyatenpostalldate,
	--週末判定
	v3001.kb_week
-- ストールマスタ_充足率対象ＤＢ
from gold.vbi003002 v3002
cross join gold.vbi003001_en v3001
-- 店舗稼動日程ＤＢ
left join t275m on t275m.cd_hansya = v3002.cd_hansya
and t275m.cd_kaisya = v3002.cd_kaisya
and t275m.cd_tenpo = v3002.cd_tenpo
and t275m.dd_kado = v3001.dd_date
and t275m.kb_kado <> 'Z'
-- ストール稼動予定マスタＤＢ
left join ai21rep_ve_dx.tbsa002m t002m on t002m.cd_hansya = v3002.cd_hansya
and t002m.cd_kaisya = v3002.cd_kaisya
and t002m.cd_tenpo = v3002.cd_tenpo
and t002m.no_stall = v3002.no_stall
and t002m.dd_hikado = v3001.`dd_yyyyMMdd`
LIMIT 0;

-- [040/099] level=1 target=gold.vbi003004
-- Gold dependencies: gold.vbi003002
-- Source file: 003_ストール充足率見える化（ストール軸管理向け）/smb_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi003004 AS
select
	--販社コード
	t005g.cd_hansya,
	--会社コード
	t005g.cd_kaisya,
	--店舗コード
	t005g.cd_tenpo,
	--予約ＩＤ
	t005g.no_yoyakuid,
	--予約明細ＩＤ
	t005g.cd_yoykmsai,
	--明細枝番最大番号
	t005g.no_msaiedmx,
	--ストール番号
	t005g.no_stall,
	--ストール番号_文字列
	cast(t005g.no_stall as string) as mj_stallno,
	--ご用命
	t005g.mj_gyme,
	--工程区分
	t005g.kb_koutei,
	--使用開始日時
	t005g.dt_siyost,
	--入庫予定日
	trunc(t005g.dt_siyost, 'J') as dd_nyuukoyt,
	--入庫予定時間_秒
	unix_timestamp(concat('1970-01-01 ', from_timestamp(t005g.dt_siyost, 'HH:mm:ss'))) as tm_nyuukoytsecond,
	--使用終了日時
	t005g.dt_siyoed,
	--出庫予定日
	trunc(t005g.dt_siyoed, 'J') as dd_shukkoyt,
	--出庫予定時間_秒
	unix_timestamp(concat('1970-01-01 ', from_timestamp(t005g.dt_siyoed, 'HH:mm:ss'))) as tm_shukkoytsecond,
	--使用所要時間
	t005g.tm_siyotime,
	--入庫区分
	t005g.kb_nyuuko,
	--実績ステータス
	t005g.cd_jisekist,
	--休憩跨ぎ区分
	t005g.cd_restcros,
	--作業人数
	t005g.su_sgyninz,
	--入庫実績日時
	t005g.dt_nyukjisk,
	--精算実績日時
	t005g.dt_sesnjisk,
	--ＳＭＢ削除フラグ
	t005g.mj_sakujyo
-- ストール予約明細ＤＢ
from ai21rep_ve_dx.tbsa005g t005g
-- ストールマスタ_充足率対象ＤＢ
left semi join gold.vbi003002 v3002 on v3002.cd_hansya = t005g.cd_hansya
and v3002.cd_kaisya = t005g.cd_kaisya
and v3002.cd_tenpo = t005g.cd_tenpo
and v3002.no_stall = t005g.no_stall
-- [ＳＭＢ削除フラグ] = "0"
where t005g.mj_sakujyo = '0'
-- [実績ステータス] <> "00" and [実績ステータス] <> "01" and [実績ステータス] <> "02"
and isnottrue(t005g.cd_jisekist in('00', '01', '02'))
and t005g.dt_siyost >= cast(from_utc_timestamp(utc_timestamp(), 'JST') as date)
and t005g.dt_siyost < days_add(cast(from_utc_timestamp(utc_timestamp(), 'JST') as date), 14)
union all
select
	tb05s.cd_hansya,
	tb05s.cd_kaisya,
	tb05s.cd_tenpo,
	tb05s.no_yoyakuid,
	tb05s.cd_yoykmsai,
	tb05s.no_msaiedmx,
	tb05s.no_stall,
	cast(tb05s.no_stall as string) as mj_stallno,
	tb05s.mj_gyme,
	tb05s.kb_koutei,
	tb05s.dt_siyost,
	trunc(tb05s.dt_siyost, 'J') as dd_nyuukoyt,
	-- 入庫予定時間
	unix_timestamp(concat('1970-01-01 ', from_timestamp(tb05s.dt_siyost, 'HH:mm:ss'))) as tm_nyuukoytsecond,
	tb05s.dt_siyoed,
	trunc(tb05s.dt_siyoed, 'J') as dd_shukkoyt,
	-- 出庫予定時間
	unix_timestamp(concat('1970-01-01 ', from_timestamp(tb05s.dt_siyoed, 'HH:mm:ss'))) as tm_shukkoytsecond,
	tb05s.tm_siyotime,
	tb05s.kb_nyuuko,
	tb05s.cd_jisekist,
	tb05s.cd_restcros,
	tb05s.su_sgyninz,
	tb05s.dt_nyukjisk,
	tb05s.dt_sesnjisk,
	tb05s.mj_sakujyo
	-- ストール予約明細退避ＤＢ
from ai21rep_ve_dx.tbsab05s tb05s
-- ストールマスタ_充足率対象ＤＢ
left semi join gold.vbi003002 v3002 on v3002.cd_hansya = tb05s.cd_hansya
and v3002.cd_kaisya = tb05s.cd_kaisya
and v3002.cd_tenpo = tb05s.cd_tenpo
and v3002.no_stall = tb05s.no_stall
-- ストール予約明細ＤＢ
left anti join ai21rep_ve_dx.tbsa005g t005g on t005g.cd_hansya = tb05s.cd_hansya
and t005g.cd_kaisya = tb05s.cd_kaisya
and t005g.cd_tenpo = tb05s.cd_tenpo
and t005g.no_yoyakuid = tb05s.no_yoyakuid
and t005g.no_stall = tb05s.no_stall
and t005g.mj_sakujyo = '0'
and isnottrue(t005g.cd_jisekist in('00', '01', '02'))
-- ストール予約明細退避ＤＢ，重複判別
left anti join ai21rep_ve_dx.tbsab05s tb05s2 on tb05s2.cd_hansya = tb05s.cd_hansya
and tb05s2.cd_kaisya = tb05s.cd_kaisya
and tb05s2.cd_tenpo = tb05s.cd_tenpo
and tb05s2.no_yoyakuid = tb05s.no_yoyakuid
and tb05s2.cd_yoykmsai = tb05s.cd_yoykmsai
and tb05s2.no_stall = tb05s.no_stall
and tb05s2.mj_sakujyo = '0'
and isnottrue(tb05s2.cd_jisekist in('00', '01', '02'))
and tb05s2.no_msaiedmx <> tb05s.no_msaiedmx
-- [ＳＭＢ削除フラグ] = "0"
where tb05s.mj_sakujyo = '0'
-- [実績ステータス] <> "00" and [実績ステータス] <> "01" and [実績ステータス] <> "02"
and isnottrue(tb05s.cd_jisekist in('00', '01', '02'))
and tb05s.dt_siyost >= cast(from_utc_timestamp(utc_timestamp(), 'JST') as date)
and tb05s.dt_siyost < days_add(cast(from_utc_timestamp(utc_timestamp(), 'JST') as date), 14)
LIMIT 0;

-- [041/099] level=0 target=gold.vbi003005
-- Gold dependencies: none
-- Source file: 003_ストール充足率見える化（ストール軸管理向け）/smb_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi003005 AS
select
	--販社コード
	t021m.cd_hansya,
	--会社コード
	t021m.cd_kaisya,
	--店舗コード
	t021m.cd_tenpo,
	--ストール番号
	t021m.no_stall,
	--ストール休憩番号
	t021m.no_stlkyuke,
	--休憩有効フラグ
	t021m.mj_kyukeyko,
	--休憩開始時間
	t021m.tm_kyukest,
	--休憩開始時間_秒
	unix_timestamp(concat('1970-01-01 ', t021m.tm_kyukest)) as tm_kyukestsecond,
	--休憩終了時間
	t021m.tm_kyukeen,
	--休憩終了時間_秒
	unix_timestamp(concat('1970-01-01 ', t021m.tm_kyukeen)) as tm_kyukeensecond
-- ストール休憩マスタＤＢ
from ai21rep_ve_dx.tbsa021m t021m
-- 店舗表示設定
left semi join dx_ve.tbi999003m t9003m on t9003m.cd_hansya = t021m.cd_hansya
and t9003m.cd_kaisya = t021m.cd_kaisya
and t9003m.cd_tenpo = t021m.cd_tenpo
and t9003m.mj_cyohyoid = '003'
and t9003m.kb_tenji = 1
-- SMB異常管理ボード集計対象店舗一覧
left semi join dx_ve.tbi003001m t3001m on t3001m.cd_hansya = t021m.cd_hansya
and t3001m.cd_kaisya = t021m.cd_kaisya
and t3001m.cd_tenpo = t021m.cd_tenpo
and t3001m.tm_kaiten < t021m.tm_kyukest
and t3001m.tm_heiten > t021m.tm_kyukeen
-- [ＳＭＢ削除フラグ] = "0"
where t021m.mj_sakujyo = '0'
-- [休憩有効フラグ] = 1
and t021m.mj_kyukeyko = '1'
LIMIT 0;

-- [042/099] level=2 target=gold.vbi003006_en
-- Gold dependencies: gold.vbi003002, gold.vbi003003, gold.vbi003004, gold.vbi003005
-- Source file: 003_ストール充足率見える化（ストール軸管理向け）/smb_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi003006_en AS
with crs as(
	select
		--販社コード
		v3004.cd_hansya,
		--会社コード
		v3004.cd_kaisya,
		--店舗コード
		v3004.cd_tenpo,
		--予約ＩＤ
		v3004.no_yoyakuid,
		--予約明細ＩＤ
		v3004.cd_yoykmsai,
		--跨ぎ休憩時間_秒
		sum(nvl(v3005.tm_kyukeensecond - v3005.tm_kyukestsecond, 0)) as tm_mtgkyukesecond
	-- tbsa005g_ストール予約明細ＤＢ_退避含_14日
	from gold.vbi003004 v3004
	-- ストール休憩マスタＤＢ
	left join gold.vbi003005 v3005 on v3005.cd_hansya = v3004.cd_hansya
	and v3005.cd_kaisya = v3004.cd_kaisya
	and v3005.cd_tenpo = v3004.cd_tenpo
	and v3005.no_stall = v3004.no_stall
	and v3005.tm_kyukest > from_timestamp(v3004.dt_siyost, 'HH:mm:ss')
	and v3005.tm_kyukeen < from_timestamp(v3004.dt_siyoed, 'HH:mm:ss')
	group by v3004.cd_hansya, v3004.cd_kaisya, v3004.cd_tenpo, v3004.no_yoyakuid, v3004.cd_yoykmsai
)
select
	--販社コード
	bt.cd_hansya,
	--会社コード
	bt.cd_kaisya,
	--店舗コード
	bt.cd_tenpo,
	--予約ＩＤ
	bt.no_yoyakuid,
	--予約明細ＩＤ
	bt.cd_yoykmsai,
	--ストール番号
	bt.no_stall,
	--ご用命
	bt.mj_gyme,
	--工程区分
	bt.kb_koutei,
	--入庫予定日時
	bt.dt_siyost as dt_nyuukoyt,
	--出庫予定日時
	bt.dt_siyoed as dt_shukkoyt,
	--使用所要時間
	bt.tm_siyotime,
	--入庫区分
	bt.kb_nyuuko,
	--実績ステータス
	bt.cd_jisekist,
	--実績ステータス名
	t231m.mj_kubunnai as mj_jisekist,
	--休憩跨ぎ区分
	bt.cd_restcros,
	--ＳＭＢ削除フラグ
	bt.mj_sakujyo,
	--販社会社店舗ストール番号日付
	concat(bt.cd_hansyakaisyatenpostall, from_timestamp(bt.dt_siyost, 'yyyy/MM/dd')) as cd_hansyakaisyatenpostalldate,
	--入庫予定日
	bt.dd_nyuukoyt,
	--予約
	if (
		bt.kb_shukkonyuko = 1,
		if (
			-- 入庫予定時間 < 退勤時間
			bt.tm_nyuukoytsecond < bt.tm_taikinsecond,
			bt.tm_siyotime,
			null
		),
		-- 入庫と出庫日一致
		if (
			-- 入庫予定時間<=出勤時間 && 出庫予定時間<=出勤時間
			bt.tm_nyuukoytsecond <= bt.tm_shukkinsecond and bt.tm_shukkoytsecond <= bt.tm_shukkinsecond,
			null,
			if (
				-- 入庫予定時間<=出勤時間 && 出庫予定時間 > 出勤時間 && 出庫予定時間<=退勤時間
				bt.tm_nyuukoytsecond <= bt.tm_shukkinsecond and bt.tm_shukkoytsecond > bt.tm_shukkinsecond and bt.tm_shukkoytsecond <= bt.tm_taikinsecond,
				-- 出庫予定時間 - 出勤時間
				(bt.tm_shukkoytsecond - bt.tm_shukkinsecond) / 60,
				if (
					-- 入庫予定時間<=出勤時間 && 出庫予定時間 > 退勤時間
					bt.tm_nyuukoytsecond <= bt.tm_shukkinsecond and bt.tm_shukkoytsecond > bt.tm_taikinsecond,
					(bt.tm_taikinsecond - bt.tm_shukkinsecond) / 60,
					if (
						-- 入庫予定時間 > 出勤時間  && 入庫予定時間<=退勤時間 && 出庫予定時間 > 出勤時間 && 出庫予定時間<=退勤時間
						bt.tm_nyuukoytsecond > bt.tm_shukkinsecond and bt.tm_nyuukoytsecond <= bt.tm_taikinsecond and bt.tm_shukkoytsecond > bt.tm_shukkinsecond and bt.tm_shukkoytsecond <= bt.tm_taikinsecond,
						-- 出庫予定時間 - 入庫予定時間
						(bt.tm_shukkoytsecond - bt.tm_nyuukoytsecond) / 60,
						if (
							-- 入庫予定時間 > 出勤時間 && 入庫予定時間<=退勤時間 && 出庫予定時間>退勤時間
							bt.tm_nyuukoytsecond > bt.tm_shukkinsecond and bt.tm_nyuukoytsecond <= bt.tm_taikinsecond and bt.tm_shukkoytsecond > bt.tm_taikinsecond,
							(bt.tm_taikinsecond - bt.tm_nyuukoytsecond) / 60,
							if (
								-- 入庫予定時間 > 退勤時間
								bt.tm_nyuukoytsecond > bt.tm_taikinsecond,
								0,
								null
							)
						)
					)
				)
			)
		)
	) - if (
		bt.cd_restcros = '0' or bt.cd_restcros = '2',
		0,
		if (
			bt.kb_shukkonyuko = 1,
			0,
			if (
				-- [入庫と出庫ストール休憩番号不一致FLG] = 0
				bt.kb_stall_syasumi_dif = 0,
				-- 出庫予定時間 - 入庫予定時間
				(bt.tm_shukkoytsecond - bt.tm_nyuukoytsecond) / 60,
				-- [入庫休憩時間] + [出庫休憩時間] + [跨ぎ休憩時間]
				(bt.tm_nyukoyukesecond + bt.tm_shukkoyukesecond + bt.tm_mtgkyukesecond) / 60
			)
		)
	) as mj_yoyaku,
	--出勤時間
	bt.tm_shukkin,
	--退勤時間
	bt.tm_taikin,
	--残業時間
	bt.tm_zangyo
from(
	select
		--販社コード
		v3004.cd_hansya,
		--会社コード
		v3004.cd_kaisya,
		--店舗コード
		v3004.cd_tenpo,
		--予約ＩＤ
		v3004.no_yoyakuid,
		--予約明細ＩＤ
		v3004.cd_yoykmsai,
		--ストール番号
		v3004.no_stall,
		--ご用命
		v3004.mj_gyme,
		--工程区分
		v3004.kb_koutei,
		--使用開始日時
		v3004.dt_siyost,
		--使用終了日時
		v3004.dt_siyoed,
		--使用所要時間
		v3004.tm_siyotime,
		--入庫区分
		v3004.kb_nyuuko,
		--実績ステータス
		v3004.cd_jisekist,
		--休憩跨ぎ区分
		v3004.cd_restcros,
		--ＳＭＢ削除フラグ
		v3004.mj_sakujyo,
		--販社会社店舗ストール番号
		concat(v3004.cd_hansya, v3004.cd_kaisya, v3004.cd_tenpo, v3004.mj_stallno) as cd_hansyakaisyatenpostall,
		--入庫予定日
		v3004.dd_nyuukoyt,
		--入庫と出庫日不一致
		if (v3004.dd_nyuukoyt <> v3004.dd_shukkoyt, 1, 0) as kb_shukkonyuko,
		--入庫と出庫ストール休憩番号不一致FLG
		if (v3005i.no_stlkyuke is null and v3005o.no_stlkyuke is null, 2, if (nvl(v3005i.no_stlkyuke, -1) <> nvl(v3005o.no_stlkyuke, -1), 1, 0)) as kb_stall_syasumi_dif,
		--入庫予定時間_秒
		v3004.tm_nyuukoytsecond,
		--出庫予定時間_秒
		v3004.tm_shukkoytsecond,
		--出勤時間
		v3002.tm_kaiten as tm_shukkin,
		--出勤時間_秒
		v3002.tm_shukkinsecond,
		--退勤時間
		v3002.tm_heiten as tm_taikin,
		--退勤時間_秒
		v3002.tm_taikinsecond,
		--残業時間
		v3002.tm_zangyo,
		--入庫休憩時間_秒
		nvl(v3005i.tm_kyukeensecond - v3004.tm_nyuukoytsecond, 0) as tm_nyukoyukesecond,
		--出庫休憩時間_秒
		nvl(v3004.tm_shukkoytsecond - v3005o.tm_kyukestsecond, 0) as tm_shukkoyukesecond,
		--跨ぎ休憩時間_秒
		nvl(crs.tm_mtgkyukesecond, 0) as tm_mtgkyukesecond
	-- tbsa005g_ストール予約明細ＤＢ_退避含_14日
	from gold.vbi003004 v3004
	-- ストールマスタ_充足率対象ＤＢ_14日
	left semi join gold.vbi003003 v3003 on v3003.cd_hansya = v3004.cd_hansya
	and v3003.cd_kaisya = v3004.cd_kaisya
	and v3003.cd_tenpo = v3004.cd_tenpo
	and v3003.no_stall = v3004.no_stall
	and v3003.dd_date = v3004.dd_nyuukoyt
	and v3003. kb_kyukei = 0
	-- ストールマスタ_充足率対象ＤＢ
	left join gold.vbi003002 v3002 on v3002.cd_hansya = v3004.cd_hansya
	and v3002.cd_kaisya = v3004.cd_kaisya
	and v3002.cd_tenpo = v3004.cd_tenpo
	and v3002.no_stall = v3004.no_stall
	-- ストール休憩マスタＤＢ，入庫
	left join gold.vbi003005 v3005i on v3005i.cd_hansya = v3004.cd_hansya
	and v3005i.cd_kaisya = v3004.cd_kaisya
	and v3005i.cd_tenpo = v3004.cd_tenpo
	and v3005i.no_stall = v3004.no_stall
	and v3005i.tm_kyukestsecond <= v3004.tm_nyuukoytsecond
	and v3005i.tm_kyukeensecond >= v3004.tm_nyuukoytsecond
	-- ストール休憩マスタＤＢ，出庫
	left join gold.vbi003005 v3005o on v3005o.cd_hansya = v3004.cd_hansya
	and v3005o.cd_kaisya = v3004.cd_kaisya
	and v3005o.cd_tenpo = v3004.cd_tenpo
	and v3005o.no_stall = v3004.no_stall
	and v3005o.tm_kyukestsecond <= v3004.tm_shukkoytsecond
	and v3005o.tm_kyukeensecond >= v3004.tm_shukkoytsecond
	-- ストール休憩マスタＤＢ， 跨ぎ
	left join crs on crs.cd_hansya = v3004.cd_hansya
	and crs.cd_kaisya = v3004.cd_kaisya
	and crs.cd_tenpo = v3004.cd_tenpo
	and	crs.no_yoyakuid = v3004.no_yoyakuid
	and	crs.cd_yoykmsai = v3004.cd_yoykmsai
) bt
--コード区分ＤＢ
left join ai21rep_ve_dx.tbv0231m t231m on t231m.cd_hansya = bt.cd_hansya
and t231m.cd_kaisya = bt.cd_kaisya
and t231m.mj_blockid = '09'
and t231m.mj_kubunid = '0016'
and t231m.cd_kubun = bt.cd_jisekist
LIMIT 0;

-- [043/099] level=3 target=gold.vbi003006
-- Gold dependencies: gold.vbi003006_en
-- Source file: 003_ストール充足率見える化（ストール軸管理向け）/smb_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi003006 AS
select
	--販社コード
	cd_hansya as `販社コード`,
	--会社コード
	cd_kaisya as `会社コード`,
	--店舗コード
	cd_tenpo as `店舗コード`,
	--予約ＩＤ
	no_yoyakuid as `予約ＩＤ`,
	--予約明細ＩＤ
	cd_yoykmsai as `予約明細ＩＤ`,
	--ストール番号
	no_stall as `ストール番号`,
	--ご用
	mj_gyme as `ご用命`,
	--工程区分
	kb_koutei as `工程区分`,
	--入庫予定日時
	dt_nyuukoyt as `入庫予定日時`,
	--出庫予定日時
	dt_shukkoyt as `出庫予定日時`,
	--使用所要時間
	tm_siyotime as `使用所要時間`,
	--入庫区分
	kb_nyuuko as `入庫区分`,
	--実績ステータス
	cd_jisekist as `実績ステータス`,
	--実績ステータス名
	mj_jisekist as `実績ステータス名`,
	--休憩跨ぎ区分
	cd_restcros as `休憩跨ぎ区分`,
	--ＳＭＢ削除フラグ
	mj_sakujyo as `ＳＭＢ削除フラグ`,
	--販社会社店舗ストール番号日付
	cd_hansyakaisyatenpostalldate as `販社会社店舗ストール番号日付`,
	--入庫予定日
	dd_nyuukoyt as `入庫予定日`,
	--予約
	mj_yoyaku as `予約`,
	--出勤時間
	tm_shukkin as `出勤時間`,
	--退勤時間
	tm_taikin as `退勤時間`,
	--残業時間
	tm_zangyo as `残業時間`
from
	gold.vbi003006_en
LIMIT 0;

-- [044/099] level=3 target=gold.vbi003007
-- Gold dependencies: gold.vbi003003, gold.vbi003006_en
-- Source file: 003_ストール充足率見える化（ストール軸管理向け）/smb_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi003007 AS
select
	--ソート順
	v3003.mj_sortjyun as `ソート順`,
	--販社コード
	v3003.cd_hansya as `販社コード`,
	--会社コード
	v3003.cd_kaisya as `会社コード`,
	--店舗コード
	v3003.cd_tenpo as `店舗コード`,
	--販社会社店舗コード
	concat(v3003.cd_hansya, v3003.cd_kaisya, v3003.cd_tenpo) as `販社会社店舗コード`,
	--エリアード
	v3003.cd_zon as `エリアコード`,
	--エリア名
	v3003.kj_zonmei as `エリア名`,
	--店舗名
	v3003.kj_tenpomei as `店舗名`,
	--ストール番号
	v3003.no_stall as `ストール番号`,
	--ストール名称
	v3003.mj_stallmei as `ストール名称`,
	--販社会社店舗ストール番号日付
	v3003.cd_hansyakaisyatenpostalldate as `販社会社店舗ストール番号日付`,
	--ストール選択
	v3003.kb_stallsentaku as `ストール選択`,
	--日付
	v3003.dd_date as `日付`,
	--定内規定
	v3003.kb_teinaikitei as `定内規定`,
	--予約
	nvl(v3006.mj_yoyaku, 0) as `予約`
-- ストールマスタ_充足率対象ＤＢ_14日
from gold.vbi003003 v3003
-- ストール予約明細_分析対象ＤＢ_14日_group
left join (
	select
		v3006.cd_hansya,
		v3006.cd_kaisya,
		v3006.cd_tenpo,
		v3006.no_stall,
		v3006.dd_nyuukoyt,
		sum(v3006.mj_yoyaku) as mj_yoyaku
	-- ストール予約明細_分析対象ＤＢ_14日
	from gold.vbi003006_en v3006
	group by v3006.cd_hansya, v3006.cd_kaisya, v3006.cd_tenpo, v3006.no_stall, v3006.dd_nyuukoyt
) v3006 on v3006.cd_hansya = v3003.cd_hansya
and v3006.cd_kaisya = v3003.cd_kaisya
and v3006.cd_tenpo = v3003.cd_tenpo
and v3006.no_stall = v3003.no_stall
and v3006.dd_nyuukoyt = v3003.dd_date
LIMIT 0;

-- [045/099] level=1 target=gold.vbi003008
-- Gold dependencies: gold.vbi003002
-- Source file: 003_ストール充足率見える化（ストール軸管理向け）/smb_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi003008 AS
select
	--ソート順
	v3002.mj_sortjyun as`ソート順`,
	--販社コード
	v3002.cd_hansya as `販社コード`,
	--会社コード
	v3002.cd_kaisya as `会社コード`,
	--店舗コード
	v3002.cd_tenpo as `店舗コード`,
	--販社会社店舗コード
	concat(v3002.cd_hansya, v3002.cd_kaisya, v3002.cd_tenpo) as `販社会社店舗コード`,
	--エリアコード
	v3002.cd_zon as `エリアコード`,
	--エリア名
	v3002.kj_zonmei as `エリア名`,
	--店舗名
	v3002.kj_tenpomei as `店舗名`
-- ストールマスタ_充足率対象ＤＢ
from gold.vbi003002 v3002
group by v3002.cd_hansya, v3002.cd_kaisya, v3002.cd_tenpo, v3002.kj_zonmei,v3002.cd_zon, v3002.kj_tenpomei, v3002.mj_sortjyun
LIMIT 0;

-- [046/099] level=0 target=gold.VBI006001
-- Gold dependencies: none
-- Source file: 006_新車注文書明細_先月登録分/vbi006001_新車注文書明細_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI006001 AS
select 
tbi006001m.cd_hanbaitn , --販売店コード
TBBA001G.CD_HANSYA , --販社コード
TBBA001G.CD_KAISYA, --会社コード
FROM_TIMESTAMP(TBBA001G.DD_JUCYUKE, 'yyyy/MM/dd') AS DD_JUCYUKE  , --受注計上日
T_KOKYAKU_1.KB_SEIBETU   , -- 買主性別区分
CONCAT(T_KOKYAKU_1.KN_SEI,T_KOKYAKU_1.KN_MEI) AS KAI_KANA,--買主名（カナ）
TBBA001G.KJ_KAINMEI1 , --買主名（漢字）
CONCAT(T_KOKYAKU_2.KN_SEI,T_KOKYAKU_2.KN_MEI) AS MEIGI_KANA, --名義人名（カナ）
TBBA001G.KJ_MEIGIME1 , --名義人名（漢字）
CONCAT(TBBA008G.NO_CYUMON,TBBA008G.NO_CYUMONED) AS NO_CYUMON, --注文no
FROM_TIMESTAMP(TBBA001G.DD_JUCYU, 'yyyy/MM/dd') AS DD_JUCYU, --受注日
TBBA008G.NO_FRAME , --フレームno
TBBF001M.KN_SYAME  , -- カナ車名
TBBF001M.KJ_KURUMAME  , -- 漢字車名
TBBA001G.MJ_HANTENKT   , --型式
TBBA056G.KJ_DAIHYOSY  , --法人代表者名（漢字）
CONCAT(T_KOKYAKU_5.KN_SEI,T_KOKYAKU_5.KN_MEI) AS SIYOUSYA_KANA, -- 使用者氏名（カナ）
CONCAT(TBBA056G.KJ_SYYUSME1,TBBA056G.KJ_SYYUSME2) AS SYOUYUSYA_KANJI, -- 所有者氏名（漢字）
T_KOKYAKU_5.NO_POST   , --使用本拠地：郵便番号
T_KOKYAKU_5.CD_JYUSYO  , --使用本拠地：住所コード
T_KOKYAKU_5.KN_JUSYO1 , --使用本拠地：住所カナ１
T_KOKYAKU_5.KN_JUSYO2 , --使用本拠地：住所カナ２
T_KOKYAKU_5.KN_JUSYO3 , --使用本拠地：住所カナ３
T_KOKYAKU_5.KJ_JUSYOKJ1 , --使用本拠地：住所漢字１
T_KOKYAKU_5.KJ_JUSYOKJ2 , --使用本拠地：住所漢字２
T_KOKYAKU_5.KJ_JUSYOKJ3 , --使用本拠地：住所漢字３
FROM_TIMESTAMP(TBBA031G.DD_TOROYOTE, 'yyyy/MM/dd') DD_TOROYOTE  , --登録予定日
CONCAT(TBBA031G.CD_NORIKUSI,TBBA031G.KB_NOSYASYU,TBBA031G.MJ_NOGYOTAI,TBBA031G.NO_NOSEIRI) AS TOROKU_NO ,--登録no
FROM_TIMESTAMP(TBBA001G.DD_TOUROKU, 'yyyy/MM/dd') AS DD_TOUROKU, --登録日
TBBA001G.KB_JCSINPO   , --受注進捗区分
IF(TBAZ017M_2.DD_SYODOTOR IS NOT NULL , FROM_TIMESTAMP(TBAZ017M_2.DD_SYODOTOR, 'yyyy/MM/dd'), FROM_TIMESTAMP(TBAZ017M_1.DD_SYODOTOR, 'yyyy/MM/dd') ) AS DD_SYODOTOR , --初度登録年月日
IF(TBAZ017M_2.DD_SYODOTOR IS NULL AND TBAZ017M_1.DD_SYODOTOR IS NOT NULL, '1' , '0' ) AS DD_SYODOTOR_COLOR, --初度登録年月日色
TBBA001G.DT_SAISINUP -- 最新更新日時
--新車受注基本情報ＤＢ 
from ai21rep_ve_dx.TBBA001G TBBA001G
--新車受注顧客情報ＤＢ（買主名）
LEFT JOIN ai21rep_ve_dx.TBBA051G T_KOKYAKU_1
ON TBBA001G.CD_KAISYA = T_KOKYAKU_1.CD_KAISYA
AND TBBA001G.CD_HANSYA = T_KOKYAKU_1.CD_HANSYA
AND TBBA001G.NO_CYUMON = T_KOKYAKU_1.NO_CYUMON 
AND TBBA001G.NO_CYUMONED = T_KOKYAKU_1.NO_CYUMONED
AND T_KOKYAKU_1.KB_KOKYAKU = '1'
--新車受注顧客情報ＤＢ（名義人）
LEFT JOIN ai21rep_ve_dx.TBBA051G T_KOKYAKU_2
ON TBBA001G.CD_KAISYA = T_KOKYAKU_2.CD_KAISYA
AND TBBA001G.CD_HANSYA = T_KOKYAKU_2.CD_HANSYA
AND TBBA001G.NO_CYUMON = T_KOKYAKU_2.NO_CYUMON 
AND TBBA001G.NO_CYUMONED = T_KOKYAKU_2.NO_CYUMONED
AND T_KOKYAKU_2.KB_KOKYAKU = '2'
----新車受注顧客情報ＤＢ（使用者）
LEFT JOIN ai21rep_ve_dx.TBBA051G T_KOKYAKU_5
ON TBBA001G.CD_KAISYA = T_KOKYAKU_5.CD_KAISYA
AND TBBA001G.CD_HANSYA = T_KOKYAKU_5.CD_HANSYA
AND TBBA001G.NO_CYUMON = T_KOKYAKU_5.NO_CYUMON 
AND TBBA001G.NO_CYUMONED = T_KOKYAKU_5.NO_CYUMONED
AND T_KOKYAKU_5.KB_KOKYAKU = '5'
----新車お客様詳細情報ＤＢ
LEFT JOIN ai21rep_ve_dx.TBBA056G TBBA056G
ON TBBA001G.CD_KAISYA = TBBA056G.CD_KAISYA
AND TBBA001G.CD_HANSYA = TBBA056G.CD_HANSYA
AND TBBA001G.NO_CYUMON = TBBA056G.NO_CYUMON 
AND TBBA001G.NO_CYUMONED = TBBA056G.NO_CYUMONED
----新車車両情報ＤＢ
INNER JOIN ai21rep_ve_dx.TBBA008G TBBA008G
ON TBBA001G.CD_KAISYA = TBBA008G.CD_KAISYA
AND TBBA001G.CD_HANSYA = TBBA008G.CD_HANSYA
AND TBBA001G.MJ_SIMUKSAK = TBBA008G.MJ_SIMUKSAK
AND TBBA001G.NO_ORDER = TBBA008G.NO_ORDER
AND TBBA001G.MJ_KATAHIMA = TBBA008G.MJ_KATAHIMA
AND TBBA001G.NO_FRAME = TBBA008G.NO_FRAME
AND TBBA001G.DD_SIIRE = TBBA008G.DD_SIIRE
AND TBBA008G.NO_CYUMON IS NOT NULL
----登録ＤＢ
INNER JOIN ai21rep_ve_dx.TBBA031G TBBA031G
ON TBBA001G.CD_KAISYA = TBBA031G.CD_KAISYA
AND TBBA001G.CD_HANSYA = TBBA031G.CD_HANSYA
AND TBBA001G.NO_CYUMON = TBBA031G.NO_CYUMON 
AND TBBA001G.NO_CYUMONED = TBBA031G.NO_CYUMONED
AND TBBA031G.KB_SYOHIN = '1'
----販売店情報
INNER JOIN dx_ve.tbi006001m tbi006001m
ON TBBA001G.cd_hansya = tbi006001m.cd_hansya
AND TBBA001G.cd_kaisya = tbi006001m.cd_kaisya
AND tbi006001m.cd_hanbaitn IS NOT NULL
----車両スペック２ＤＢ
LEFT JOIN ai21rep_ve_dx.TBBF008M TBBF008M
ON TBBA001G.CD_KAISYA = TBBF008M.CD_KAISYA
AND TBBA001G.CD_HANSYA = TBBF008M.CD_HANSYA
AND TBBA001G.MJ_SINKYSED = TBBF008M.MJ_SINKYSED
AND TBBA001G.MJ_GAIHANSY  = TBBF008M.CD_SPEC 
AND TBBA001G.MJ_HANTENKT  = TBBF008M.MJ_HANTENKT 
AND TBBF008M.KB_SPEC = 'G'
----車名ＤＢ
LEFT JOIN ai21rep_ve_dx.TBBF001M TBBF001M
ON TBBF001M.CD_KAISYA = TBBF008M.CD_KAISYA
AND TBBF001M.CD_HANSYA = TBBF008M.CD_HANSYA
AND TBBF001M.CD_NCSYAMEI = TBBF008M.MJ_SYAMEI 
----車両基本ＤＢ
LEFT JOIN ai21rep_ve_dx.TBAZ017M TBAZ017M_1
ON TBBA001G.CD_KAISYA = TBAZ017M_1.CD_KAISYA
AND TBBA001G.CD_HANSYA = TBAZ017M_1.CD_HANSYA
AND T_KOKYAKU_1.CD_KOKYAKU = TBAZ017M_1.CD_OKYAKU 
AND TBBA031G.CD_NORIKUSI = TBAZ017M_1.CD_NORIKUSI
AND TBBA031G.KB_NOSYASYU = TBAZ017M_1.KB_NOSYASYU
AND TBBA031G.MJ_NOGYOTAI = TBAZ017M_1.CD_NOGYOTAI  
AND TBBA031G.NO_NOSEIRI = TBAZ017M_1.NO_NOSEIRI
----車両基本ＤＢ
LEFT JOIN ai21rep_ve_dx.TBAZ017M TBAZ017M_2
ON TBBA001G.CD_KAISYA = TBAZ017M_2.CD_KAISYA
AND TBBA001G.CD_HANSYA = TBAZ017M_2.CD_HANSYA
AND T_KOKYAKU_2.CD_KOKYAKU = TBAZ017M_2.CD_OKYAKU 
AND TBBA031G.CD_NORIKUSI = TBAZ017M_2.CD_NORIKUSI
AND TBBA031G.KB_NOSYASYU = TBAZ017M_2.KB_NOSYASYU
AND TBBA031G.MJ_NOGYOTAI = TBAZ017M_2.CD_NOGYOTAI
AND TBBA031G.NO_NOSEIRI = TBAZ017M_2.NO_NOSEIRI
WHERE 
--新車受注基本情報ＤＢ.取消日 がNULL AND 登録日 が前月
TBBA001G.DD_TORIKESI IS NULL 
AND TBBA001G.DD_TOUROKU IS NOT NULL 
AND FROM_TIMESTAMP(TBBA001G.DD_TOUROKU, 'yyyy/MM')  = FROM_TIMESTAMP(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'yyyy/MM')
LIMIT 0;

-- [047/099] level=0 target=gold.VBI010001
-- Gold dependencies: none
-- Source file: 010_経営主要項目実績/VBI010001-VBI010006_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI010001 AS
SELECT  
	t201m.cd_hansya AS 販社コード, --販社コード
	t201m.cd_kaisya AS 会社コード, --会社コード
	t201m.cd_tenpo AS 店舗コード, --店舗コード
	t201m.kj_tenpomei AS 店舗名称, --店舗名称
	t201m.kj_tentanms AS 店舗短縮名称, --店舗短縮名称
	RANK() OVER (PARTITION BY t201m.cd_hansya,t201m.cd_kaisya ORDER BY IF(NVL(t033m.kj_zonmei,t033m_2.kj_zonmei) = '', 0,1), NVL(t033m.kj_zonmei,t033m_2.kj_zonmei) ,  t201m.cd_tenpo) as ソート順,   --ソート順
	CONCAT(t201m.cd_hansya, t201m.cd_kaisya, t201m.cd_tenpo) AS 販社会社店舗,  --販社会社店舗
	'' AS ゾーン名称, --ゾーン名称
	t033m.kb_syohin AS 商品区分, --商品区分
	CASE
		WHEN tbv0200m.KJ_KAISYA LIKE '%トヨペット%' THEN 'P'
		WHEN tbv0200m.KJ_KAISYA LIKE '%ネッツトヨタ%' THEN 'N'
		ELSE NULL
	END AS pn区分,  --pn区分
	CASE
		WHEN NVL(TRIM(t201m.cd_lexhan), '') = '' THEN 'ﾄﾖﾀ'
		ELSE 'ﾚｸｻｽ'
	END AS tl区分,  --tl区分
	CASE
		WHEN t201m.kb_ncbumumu = '1' AND t201m.kb_ucbumumu = '1' THEN '11'
		WHEN t201m.kb_ncbumumu = '1' AND NVL(t201m.kb_ucbumumu, '')<> '1' THEN '10'
		WHEN NVL(t201m.kb_ncbumumu, '')<> '1' AND t201m.kb_ucbumumu = '1' THEN '01'
		ELSE '00'
	END 新U区分, --新U区分
	CASE
		WHEN (t047m.kb_nchonsya = '2' or t047m.kb_uchonsya = '2') AND (t047m.kb_nchonsya = '1' OR t047m.kb_uchonsya = '1') THEN '11'
		WHEN (t047m.kb_nchonsya = '2' or t047m.kb_uchonsya = '2') AND (NVL(t047m.kb_nchonsya, '')<> '1' AND NVL(t047m.kb_uchonsya, '')<> '1') THEN '10'
		WHEN (t047m.kb_nchonsya = '1' or t047m.kb_uchonsya = '1') AND (NVL(t047m.kb_nchonsya, '')<> '2' AND NVL(t047m.kb_uchonsya, '')<> '2') THEN '01'
		ELSE '00'
	END 本部店舗区分 --本部店舗区分
FROM
	ai21rep_ve_dx.tbv0201m t201m --共通店舗ＤＢ 	
LEFT JOIN ai21rep_ve_dx.tbv0047m t047m --Ｍ車両店舗ＤＢ	
	ON t047m.cd_hansya = t201m.cd_hansya
	AND t047m.cd_kaisya = t201m.cd_kaisya
	AND t047m.cd_tenpo = t201m.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbv0033m t033m --ＭゾーンコードＤＢ	
	ON t033m.cd_hansya = t201m.cd_hansya
	AND t033m.cd_kaisya = t201m.cd_kaisya
	AND t033m.cd_zon = t047m.cd_nczon
	AND t033m.kb_syohin = '1'
LEFT JOIN ai21rep_ve_dx.tbv0033m t033m_2 --ＭゾーンコードＤＢ	
	ON t033m_2.cd_hansya = t201m.cd_hansya
	AND t033m_2.cd_kaisya = t201m.cd_kaisya
	AND t033m_2.cd_zon = t047m.cd_uczon
	AND t033m_2.kb_syohin = '2'
LEFT JOIN ai21rep_ve_dx.tbv0200m tbv0200m --会社コードＤＢ	
    ON t201m.cd_hansya = tbv0200m.cd_hansya
	AND t201m.cd_kaisya = tbv0200m.cd_kaisya
LIMIT 0;

-- [048/099] level=0 target=gold.VBI010002
-- Gold dependencies: none
-- Source file: 010_経営主要項目実績/VBI010001-VBI010006_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI010002 AS
SELECT  
	t201m.cd_hansya AS 販社コード, --販社コード
	t201m.cd_kaisya AS 会社コード, --会社コード
	t201m.cd_tenpo AS 店舗コード, --店舗コード
	CONCAT(t201m.cd_hansya, t201m.cd_kaisya, t201m.cd_tenpo) AS 販社会社店舗, --販社会社店舗
	NVL(newcar.新車軽OEM数, 0) AS 新車軽OEM数, --新車軽OEM数
	NVL(newcar.新車登録車数, 0) AS 新車登録車数, --新車登録車数
	NVL(newcar.新車軽OEM収益, 0) AS 新車軽OEM収益, --新車軽OEM収益
	NVL(newcar.新車登録収益, 0) AS 新車登録収益, --新車登録収益
	NVL(newcar.新車軽OEM売上, 0) AS 新車軽OEM売上, --新車軽OEM売上
	NVL(newcar.新車登録売上, 0) AS 新車登録売上, --新車登録売上
	NVL(ucar.TAD販売実績, 0) AS TAD販売実績, --TAD販売実績
	NVL(ucar.TAD売上実績, 0) AS TAD売上実績, --TAD売上実績
	NVL(ucar.TAD収益実績, 0) AS TAD収益実績, --TAD収益実績
	NVL(tbv0014m_newcar.staffCount, 0) AS 新車スタッフ数, --新車スタッフ数
	NVL(ucar.UCar小売, 0) AS UCar小売, --UCar小売
	NVL(ucar.UCar卸, 0) AS UCar卸, --UCar卸
	NVL(ucar.UCar卸収益, 0) AS UCar卸収益, --UCar卸収益
	NVL(ucar.UCar小売売上, 0) AS UCar小売売上, --UCar小売売上
	NVL(ucar.UCar卸売上, 0) AS UCar卸売上, --UCar卸売上
	NVL(ucar.UCar小売収益, 0) AS UCar小売収益, --UCar小売収益
	NVL(tbv0014m_ucar.staffCount, 0) AS Ucarスタッフ数  --Ucarスタッフ数
FROM
	ai21rep_ve_dx.tbv0201m t201m --共通店舗ＤＢ
LEFT JOIN
(	--新車販売
	SELECT
		cd_hansya, --販社コード
		cd_kaisya, --会社コード
		cd_tenpo,  --店舗コード
		SUM(新車数) AS 新車数, --新車数
		SUM(CASE WHEN 軽区分 = '1' THEN 新車数 ELSE 0 END) AS 新車軽OEM数,  --新車軽OEM数
		SUM(CASE WHEN NVL(軽区分,'') != '1' THEN 新車数 ELSE 0 END) AS 新車登録車数,  --新車登録車数
		SUM(CASE WHEN 軽区分 = '1' THEN rieki ELSE 0 END) AS 新車軽OEM収益,  --新車軽OEM収益
		SUM(CASE WHEN NVL(軽区分,'') != '1' THEN rieki ELSE 0 END) AS 新車登録収益, --新車登録収益
		SUM(CASE WHEN 軽区分 = '1' THEN uriage ELSE 0 END) AS 新車軽OEM売上, --新車軽OEM売上
		SUM(CASE WHEN NVL(軽区分,'') != '1' THEN uriage ELSE 0 END) AS 新車登録売上  --新車登録売上
	FROM
		(
		SELECT
			tbba001g.cd_hansya, --販社コード
			tbba001g.cd_kaisya, --会社コード
			tbba001g.cd_tenpo,  --店舗コード
			SUM(calflg) AS 新車数, --新車数
			tbbf001m.kn_kei AS 軽区分, --軽区分
			SUM(calflg * (NVL(TBBA052G.ki_syryhnzk, 0)+ NVL(tbba052g.SU_MAKOBY1, 0) + NVL(tbba052g.SU_MAKOBY2, 0) + NVL(tbba052g.SU_MAKOBY3, 0) + 
			NVL(tbba052g.SU_MAKOBY4, 0) + NVL(tbba052g.SU_MAKOBY5, 0) + NVL(tbba052g.SU_MAKOBY6, 0) + 
			NVL(tbba052g.SU_MAKOBY7, 0) + NVL(tbba052g.SU_MAKOBY8, 0) + NVL(tbba052g.SU_MAKOBY9, 0) + 
			NVL(tbba052g.SU_MAKOBY10, 0) + NVL(tbba052g.SU_MAKOBY11, 0) + NVL(tbba052g.SU_MAKOBY12, 0) + 
			NVL(tbba052g.SU_MAKOBY13, 0) + NVL(tbba052g.SU_MAKOBY14, 0) + NVL(tbba052g.SU_MAKOBY15, 0) + 
			NVL(tbba052g.SU_MAKOBY16, 0) - NVL(tbba052g.ki_syryhnez, 0))) AS uriage, --売上
			SUM( calflg * (
				NVL(tbba052g.ki_syryohon, 0) - NVL(tbba052g.ki_syryoneb, 0) - NVL(tbba052g.KI_KATAKANR, 0) +
				NVL(tbba052g.KI_FUZKTUKN, 0) - NVL(tbba052g.KI_FUZKHNNB, 0) - NVL(tbba052g.KI_FUZKTUKG, 0) +
				NVL(tbba052g.KI_HANSPTKN, 0) - NVL(tbba052g.KI_HANBTSNE, 0) - NVL(tbba052g.KI_HANSPTKG, 0) +
				NVL(tbba052g.KI_SIKIBUY, 0) + 
				NVL(tbba052g.SU_MAKOBY1, 0) + NVL(tbba052g.SU_MAKOBY2, 0) + NVL(tbba052g.SU_MAKOBY3, 0) + 
				NVL(tbba052g.SU_MAKOBY4, 0) + NVL(tbba052g.SU_MAKOBY5, 0) + NVL(tbba052g.SU_MAKOBY6, 0) + 
				NVL(tbba052g.SU_MAKOBY7, 0) + NVL(tbba052g.SU_MAKOBY8, 0) + NVL(tbba052g.SU_MAKOBY9, 0) + 
				NVL(tbba052g.SU_MAKOBY10, 0) + NVL(tbba052g.SU_MAKOBY11, 0) + NVL(tbba052g.SU_MAKOBY12, 0) + 
				NVL(tbba052g.SU_MAKOBY13, 0) + NVL(tbba052g.SU_MAKOBY14, 0) + NVL(tbba052g.SU_MAKOBY15, 0) + NVL(tbba052g.SU_MAKOBY16, 0) -
				NVL(tbba052g.KI_MAKOPNEB, 0) - 
				(
				    NVL(tbba052g.KI_SIKIKANG, 0) + NVL(tbba052g.KI_MAKEOK1, 0) + NVL(tbba052g.KI_MAKEOK2, 0) + 
				    NVL(tbba052g.KI_MAKEOK3, 0) + NVL(tbba052g.KI_MAKEOK4, 0) + NVL(tbba052g.KI_MAKEOK5, 0) + 
				    NVL(tbba052g.KI_MAKEOK6, 0) + NVL(tbba052g.KI_MAKEOK7, 0) + NVL(tbba052g.KI_MAKEOK8, 0) + 
				    NVL(tbba052g.KI_MAKEOK9, 0) + NVL(tbba052g.KI_MAKEOK10, 0) + NVL(tbba052g.KI_MAKEOK11, 0) + 
				    NVL(tbba052g.KI_MAKEOK12, 0) + NVL(tbba052g.KI_MAKEOK13, 0) + NVL(tbba052g.KI_MAKEOK14, 0) + 
				    NVL(tbba052g.KI_MAKEOK15, 0) + NVL(tbba052g.KI_MAKEOK16, 0)
				) +
				-- 諸費用利益
				NVL(tbba052g.KI_KAZETESK, 0) + NVL(tbba052g.KI_KENSATES, 0) + NVL(tbba052g.KI_SYKOSYTE, 0) + 
				NVL(tbba052g.KI_SITATOTS, 0) + NVL(tbba052g.KI_NINHOTHI, 0) + NVL(tbba052g.KI_DORSVKAN, 0) + 
				NVL(tbba052g.KI_NINHOKNR, 0) + NVL(tbba054g.KI_NINAZUK, 0) -
				(NVL(tbba052g.KI_KENSGENK, 0) + NVL(tbba052g.KI_SYKOHIGE, 0) + NVL(tbba052g.KI_NOSYHKGE, 0) + NVL(TBBA053G.KI_NINSYHKG, 0) +
				NVL(tbba052g.KI_KENSTESK, 0) + NVL(tbba052g.KI_SYKOTEKA, 0) + NVL(tbba052g.KI_NINHTHIG, 0) + 
				NVL(tbba052g.KI_DORSVKAK, 0) + NVL(tbba054g.KI_NINAZUKG, 0) + NVL(tbba052g.KI_NINHOKGE, 0) + 
				NVL(tbba052g.KI_SITATSKA, 0) + NVL(tbba052g.KI_SITAKANG, 0) + NVL(tbba052g.KI_SITSATKA, 0) ) - NVL(tbba052g.KI_SYSNHOKN, 0) +
				-- 割賦手数料利益
					NVL(tbba055g.ki_kaptesu, 0) - ( 
						CASE WHEN (NVL(tbba055g.ki_kaptesu, 0) + NVL(tbba052g.ki_kaptesuN, 0)) >= 0 
				        THEN TRUNC(NVL(tbba055g.ki_kaptesu, 0) * NVL(tbi010001m.NU_KAPTESG, 0) / 100)
				        ELSE NVL(tbba055g.ki_kaptesu, 0) - TRUNC(NVL(tbba055g.ki_kaptesu, 0) * NVL(tbi010001m.NU_KAPTESG, 0) / 100)
				   		END
				)
		    	)) AS rieki --利益
		FROM
			(
			SELECT
				tbba001g.cd_hansya, --販社コード
				tbba001g.cd_kaisya, --会社コード
				tbba001g.cd_tenpo, --店舗コード
				tbba001g.no_cyumon, --注文ＮＯ
				tbba001g.no_cyumoned, --注文ＮＯ枝番
				tbba001g.mj_sinkysed, --新旧世代
				tbba001g.mj_gaihansy, --外鈑色
				tbba001g.mj_hantenkt, --販売店型式
				(CASE
					WHEN ft168g.dd_torokei IS NULL THEN tbba001g.dd_uriagekj
					ELSE ft168g.dd_torokei
				END) AS 日付,
				1 AS calflg --計算フラグ
			FROM
				ai21rep_ve_dx.tbba001g tbba001g --新車受注基本情報ＤＢ 
			LEFT JOIN(
			    SELECT
			        t168g.cd_hansya,
			        t168g.cd_kaisya,
			        t168g.no_cyumon,
			        min(t168g.dd_torokei) AS dd_torokei
			    FROM ai21rep_ve_dx.tbbg168g t168g  --履歴登録ＤＢ
			    WHERE -- 業務ＮＯ=「07」、処理ＮＯ=「01」　
			    	t168g.no_gyomu = '07'
			    AND t168g.no_syori = '01'
			    GROUP BY t168g.cd_hansya, t168g.cd_kaisya, t168g.no_cyumon
			) ft168g ON
				ft168g.cd_kaisya = tbba001g.cd_kaisya
				AND ft168g.cd_hansya = tbba001g.cd_hansya
				AND ft168g.no_cyumon = tbba001g.no_cyumon
			WHERE -- 払出区分 =「00」or「40」、受注計上日に値があり、かつ履歴登録ＤＢの登録計上日がNULLと新車受注基本情報ＤＢの売上計上日が当月、或いは履歴登録ＤＢの登録計上日が当月
				tbba001g.kb_haraidas NOT IN ('00', '40')
				AND tbba001g.dd_jucyuke IS NOT NULL
				AND ( (ft168g.dd_torokei IS NULL AND tbba001g.dd_uriagekj >= TRUNC(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM'))
					OR  (ft168g.dd_torokei IS NOT NULL
					AND ft168g.dd_torokei >= TRUNC(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM'))
				)
			UNION ALL
				SELECT
					tbba001g.cd_hansya, --販社コード
					tbba001g.cd_kaisya , --会社コード
					tbba001g.cd_tenpo, --店舗コード
					tbba001g.no_cyumon, --注文ＮＯ
					tbba001g.no_cyumoned, --注文ＮＯ枝番
					tbba001g.mj_sinkysed, --新旧世代
					tbba001g.mj_gaihansy, --外鈑色
					tbba001g.mj_hantenkt, --販売店型式
					tbba001g.dd_uritrkkj AS 日付, --売上取消計上日
					-1 AS calflg --計算フラグ
				FROM
					ai21rep_ve_dx.tbba001g tbba001g  --履歴登録ＤＢ					
				WHERE -- 払出区分 =「00」or「40」、受注計上日に値があり、かつ売上取消計上日が当月
					tbba001g.kb_haraidas NOT IN ('00', '40')
					AND tbba001g.dd_jucyuke IS NOT NULL
					AND tbba001g.dd_uritrkkj >= TRUNC(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM')
		) tbba001g
		LEFT JOIN ai21rep_ve_dx.tbbf008m TBBF008M  --車両スペック２ＤＢ
	    	ON tbba001g.cd_kaisya = tbbf008m.cd_kaisya
				AND tbba001g.cd_hansya = tbbf008m.cd_hansya
				AND tbba001g.mj_sinkysed = tbbf008m.mj_sinkysed
				AND tbba001g.mj_gaihansy = tbbf008m.cd_spec
				AND tbba001g.mj_hantenkt = tbbf008m.mj_hantenkt
				AND tbbf008m.kb_spec = 'G'
			LEFT JOIN ai21rep_ve_dx.tbbf001m tbbf001m --車名ＤＢ 
    		ON
				tbbf001m.cd_kaisya = tbbf008m.cd_kaisya
				AND tbbf001m.cd_hansya = tbbf008m.cd_hansya
				AND tbbf001m.cd_ncsyamei = tbbf008m.mj_syamei
			LEFT JOIN ai21rep_ve_dx.tbba052g tbba052g--新車受注販売条件情報ＤＢ 
				ON tbba001g.cd_hansya = tbba052g.cd_hansya
				AND tbba001g.cd_kaisya = tbba052g.cd_kaisya
				AND tbba001g.no_cyumon = tbba052g.no_cyumon
				AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba052g.no_cyumoned)
				LEFT JOIN (
					SELECT
						tbba054g.cd_hansya, --販社コード
						tbba054g.cd_kaisya, --会社コード
						tbba054g.no_cyumon, --注文ＮＯ
						tbba054g.no_cyumoned, --注文ＮＯ枝番
						SUM(KI_NINAZUK) AS KI_NINAZUK, --任意預かり金
						SUM(KI_NINAZUKG) AS KI_NINAZUKG --任意預かり金管理原価
					FROM
						ai21rep_ve_dx.tbba054g tbba054g  --新車受注任意預かり金情報ＤＢ
					WHERE -- 任意預かり金連番　＝'A', 'B', 'C', 'D', 'E'
						tbba054g.NO_NINAZUKN IN ('A', 'B', 'C', 'D', 'E')
					GROUP BY
						tbba054g.cd_hansya ,
						tbba054g.cd_kaisya,
						tbba054g.no_cyumon,
						tbba054g.no_cyumoned
				) tbba054g
				ON tbba001g.cd_hansya = tbba054g.cd_hansya
					AND tbba001g.cd_kaisya = tbba054g.cd_kaisya
					AND tbba001g.no_cyumon = tbba054g.no_cyumon
					AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba054g.no_cyumoned)
				LEFT JOIN (
					SELECT
						TBBA053G.cd_hansya, --販社コード
						TBBA053G.cd_kaisya,  --会社コード
						TBBA053G.no_cyumon,  --注文ＮＯ
						TBBA053G.no_cyumoned, --注文ＮＯ枝番
						sum(KI_NINSYHKG) AS KI_NINSYHKG --任意諸費用管理原価
					FROM
						ai21rep_ve_dx.tbba053g TBBA053G --新車受注任意預かり金情報ＤＢ
					WHERE -- 任意諸費用連番 　＝'1', '2', '3', '4', '5'
						TBBA053G.NO_NINSYHIY IN ('1', '2', '3', '4', '5')
					GROUP BY
						TBBA053G.cd_hansya,
						TBBA053G.cd_kaisya,
						TBBA053G.no_cyumon,
						TBBA053G.no_cyumoned
				) TBBA053G
				ON
					tbba001g.cd_hansya = TBBA053G.cd_hansya
					AND tbba001g.cd_kaisya = TBBA053G.cd_kaisya
					AND tbba001g.no_cyumon = TBBA053G.no_cyumon
					AND TRIM(tbba001g.no_cyumoned) = TRIM(TBBA053G.no_cyumoned)
				LEFT JOIN (
					SELECT
						tbba055g.cd_hansya, --販社コード
						tbba055g.cd_kaisya, --会社コード
						tbba055g.no_cyumon, --注文ＮＯ
						tbba055g.no_cyumoned, --注文ＮＯ枝番
						sum(ki_kaptesu) AS ki_kaptesu --割賦手数料
					FROM
						ai21rep_ve_dx.tbba055g TBBA055G --新車受注割賦情報ＤＢ
					WHERE -- 割賦連番 ＝'1', '2'
						tbba055g.NO_KAPRENB IN ('1', '2')
					GROUP BY
						tbba055g.cd_hansya,
						tbba055g.cd_kaisya,
						tbba055g.no_cyumon,
						tbba055g.no_cyumoned
				) TBBA055G
				ON  tbba001g.cd_hansya = tbba055g.cd_hansya
					AND tbba001g.cd_kaisya = tbba055g.cd_kaisya
					AND tbba001g.no_cyumon = tbba055g.no_cyumon
					AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba055g.no_cyumoned)
			LEFT JOIN dx_ve.tbi010001m tbi010001m--経営主要項目目標
				ON tbba001g.cd_hansya = tbi010001m.cd_hansya
				AND tbba001g.cd_kaisya = tbi010001m.cd_kaisya
				AND	tbba001g.cd_tenpo = tbi010001m.cd_tenpo
				GROUP BY
					tbba001g.cd_hansya,
					tbba001g.cd_kaisya,
					tbba001g.cd_tenpo,
					tbbf001m.kn_kei
			) combined
			GROUP BY
				cd_hansya,
				cd_kaisya,
				cd_tenpo
			) newcar
			ON t201m.cd_hansya = newcar.cd_hansya
			AND t201m.cd_kaisya = newcar.cd_kaisya
			AND t201m.cd_tenpo = newcar.cd_tenpo
LEFT JOIN (
	SELECT
		tbv0014m.cd_hansya, --販社コード
		tbv0014m.cd_kaisya, --会社コード
		tbv0014m.cd_syozoten, --所属店舗
		COUNT(1) AS staffCount --スタッフ数
	FROM
		ai21rep_ve_dx.tbv0014m tbv0014m --Ｍ社員ＤＢ
	WHERE -- スタッフ新車 ＝'1'
		tbv0014m.kb_staffsin = '1'
	GROUP BY
		tbv0014m.cd_hansya,
		tbv0014m.cd_kaisya,
		tbv0014m.cd_syozoten
) tbv0014m_newcar
  ON
	newcar.cd_hansya = tbv0014m_newcar.cd_hansya
	AND newcar.cd_kaisya = tbv0014m_newcar.cd_kaisya
	AND newcar.cd_tenpo = tbv0014m_newcar.cd_syozoten	
LEFT JOIN 
(	--中古車販売
	SELECT
		cd_hansya, --販社コード
		cd_kaisya,  --会社コード
		cd_jytyuten, --受注店舗コード
		SUM(CASE WHEN 売上区分 = '11' THEN Ucar販売数 ELSE 0 END) AS UCar小売, --UCar小売
		SUM(CASE WHEN 売上区分 = '20' THEN Ucar販売数 ELSE 0 END) AS UCar卸, --UCar卸
		SUM(CASE WHEN 売上区分 = '11' THEN ucar売上 ELSE 0 END) AS UCar小売売上, --UCar小売売上
		SUM(CASE WHEN 売上区分 = '20' THEN ucar売上 ELSE 0 END) AS UCar卸売上, --UCar卸売上
		SUM(CASE WHEN 売上区分 = '11' THEN 収益 ELSE 0 END) AS UCar小売収益, --UCar小売収益
		SUM(CASE WHEN 売上区分 = '20' THEN 収益 ELSE 0 END) AS UCar卸収益, --UCar卸収益	
		SUM(CASE WHEN 売上区分 = '14' THEN Ucar販売数 ELSE 0 END) AS TAD販売実績, --TAD販売実績
		SUM(CASE WHEN 売上区分 = '14' THEN ucar売上 ELSE 0 END) AS TAD売上実績, --TAD売上実績
		SUM(CASE WHEN 売上区分 = '14' THEN 収益 ELSE 0 END) AS TAD収益実績 --TAD収益実績
	FROM
		(
		SELECT
			tbbc017g.cd_hansya, -- 販社コード
			tbbc017g.cd_kaisya, --会社コード
			tbbc017g.cd_jytyuten, --受注店舗コード
			tbbc017g.日付, --日付
			tbbc017g.kb_uriage AS 売上区分, --売上区分
			SUM(calflg) AS Ucar販売数, --Ucar販売数
			SUM(CASE WHEN NVL(tbbc020g.kb_mntpkkei, '') != '' THEN tbbc017g.calflg ELSE 0 END)  AS UCar入会数, --UCar入会数
			SUM(calflg * (NVL(tbbc020g.ki_syryhnzk, 0) - NVL(tbbc020g.ki_syryhnez, 0))) AS ucar売上 , --ucar売上
			SUM (calflg * (NVL(tbbc020g.ki_syryohon, 0) - NVL(tbbc020g.ki_syryoneb, 0) - (NVL(tbbc020g.ki_syryogen, 0) + NVL(TBBC001G.nu_kanrikgn, 0)) +
			(NVL(tbbc020g.ki_fuzkbuyk, 0) - NVL(tbbc020g.KI_FUZKHNNB, 0) + NVL(tbbc020g.ki_spsiybyk, 0) - NVL(tbbc020g.KI_SPSIYNEB, 0)) - NVL(tbbc020g.ki_sokamitu, 0) 
			+ NVL(tbbc020g.ki_nahnjibs, 0) - (NVL(tbbc020g.ki_mntpryok, 0) + NVL(tbbc020g.ki_seunetes, 0) + (NVL(tbbc020g.ki_glinkhiy, 0) - 
			NVL(tbbc020g.ki_glinktes, 0))) + NVL(tbbc020g.nu_syrykage, 0) + NVL(tbbc020g.nu_syukage, 0) - NVL(tbbc020g.ki_hanbaihi, 0) - NVL(tbbc020g.ki_zaneksit, 0)
			- NVL(tbbc020g.ki_tasonkin, 0)+ NVL(tbbc020g.nu_sntkagen, 0) -
			(CASE
				WHEN tbbc017g.su_joknhens = 0 THEN TBPF070M.ki_honbkanr
				WHEN tbbc017g.su_joknhens>0 THEN tbbc020g.ki_zanehobk
			END) )) AS 収益 --収益
		FROM
			(
			SELECT
				tbbc017g.cd_hansya, --販社コード
				tbbc017g.cd_kaisya, --会社コード
				tbbc017g.cd_jytyuten, --受注店舗コード
				tbbc017g.no_cyumon, --注文ＮＯ
				tbbc017g.no_cyumoned, --注文ＮＯ枝番
				tbbc017g.no_syaryou, --車両ＮＯ
				tbbc017g.kb_uriage, --売上区分
				tbbc017g.su_joknhens, --条件変更回数
				(CASE
					WHEN ft8006.dd_uriage IS NULL THEN tbbc017g.dd_uriagekj
					ELSE to_timestamp(CAST(ft8006.dd_uriage AS string), 'yyyyMMdd HH:mm:ss')
				END) AS 日付,
				1 AS calflg  --計算フラグ
			FROM
				ai21rep_ve_dx.tbbc017g tbbc017g --中古車受注基本情報ＤＢ
			LEFT JOIN 
	   		(
				SELECT
					t8006.cd_hansya, --販社コード
					t8006.cd_kaisya, --会社コード
					t8006.no_cyumon,  --注文ＮＯ
					MIN(t8006.dd_uriage) AS dd_uriage --売上日
				FROM
					ai21rep_ve_dx.tbg8006m t8006 --中古車小売売上トランＤＢ 
				GROUP BY
					t8006.cd_hansya,
					t8006.cd_kaisya,
					t8006.no_cyumon
	    		)ft8006 ON
				tbbc017g.cd_kaisya = ft8006.cd_kaisya
				AND tbbc017g.cd_kaisya = ft8006.cd_kaisya
				AND tbbc017g.no_cyumon = ft8006.no_cyumon
				AND tbbc017g.dd_uritorik IS NULL
			WHERE  -- 受注計上日に値があり、取消日がNULL、かつ中古車小売売上トランＤＢ の売上日がNULLと中古車受注基本情報ＤＢの売上計上日が当月、
				--或いは中古車小売売上トランＤＢの売上日が当月
				tbbc017g.dd_uriagekj IS NOT NULL
				AND tbbc017g.dd_torikesi IS NULL
				AND ( (ft8006.dd_uriage IS NULL
					AND tbbc017g.dd_uriagekj >= TRUNC(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM'))
					OR 
	            		(ft8006.dd_uriage IS NOT NULL
					AND from_timestamp(to_timestamp(CAST(ft8006.dd_uriage AS STRING), 'yyyyMM'), 'yyyyMM') >= TRUNC(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM')
	        ))
		UNION ALL
			SELECT
				tbbc017g.cd_hansya, --販社コード
				tbbc017g.cd_kaisya,  --会社コード
				tbbc017g.cd_jytyuten,  --受注店舗コード
				tbbc017g.no_cyumon,  --注文ＮＯ
				tbbc017g.no_cyumoned, --注文ＮＯ枝番
				tbbc017g.no_syaryou, --車両ＮＯ
				tbbc017g.kb_uriage, --売上区分
				tbbc017g.su_joknhens, --条件変更回数
				tbbc017g.dd_uritorik, --売上取消日
				-1 AS calflg  ----計算フラグ
			FROM
				ai21rep_ve_dx.tbbc017g tbbc017g --中古車受注基本情報ＤＢ 
			WHERE -- 中古車受注基本情報ＤＢの受注計上日に値があり、取消日が当月
				tbbc017g.dd_jucyuke IS NOT NULL
				AND tbbc017g.dd_uritorik >= TRUNC(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM')
		) tbbc017g
		LEFT JOIN ai21rep_ve_dx.tbbc001g TBBC001G --中古車在庫基本情報ＤＢ
		ON TBBC001G.cd_kaisya = tbbc017g.cd_kaisya
		AND TBBC001G.cd_hansya = tbbc017g.cd_hansya
		AND TBBC001G.no_syaryou = tbbc017g.no_syaryou
		LEFT JOIN ai21rep_ve_dx.tbbc020g tbbc020g --中古車受注販売条件情報ＤＢ
		ON tbbc017g.cd_hansya = tbbc020g.cd_hansya
			AND tbbc017g.cd_kaisya = tbbc020g.cd_kaisya
			AND tbbc017g.no_cyumon = tbbc020g.no_cyumon
			AND TRIM(tbbc017g.no_cyumoned) = TRIM(tbbc020g.no_cyumoned)
		LEFT JOIN ai21rep_ve_dx.tbpf070m TBPF070M --中古車コントロールＤＢ 
		ON tbbc017g.cd_hansya = TBPF070M.cd_hansya
		AND tbbc017g.cd_kaisya = TBPF070M.cd_kaisya
		-- 売上区分 ＝'11', '14', '20'
		WHERE tbbc017g.kb_uriage IN ('11', '14', '20')
		GROUP BY
			tbbc017g.cd_hansya,
			tbbc017g.cd_kaisya,
			tbbc017g.cd_jytyuten,
			日付,
			tbbc017g.kb_uriage
) combined
	GROUP BY
		cd_hansya,
		cd_kaisya,
		cd_jytyuten
) ucar ON
	t201m.cd_hansya = ucar.cd_hansya
	AND t201m.cd_kaisya = ucar.cd_kaisya
	AND t201m.cd_tenpo = ucar.cd_jytyuten
LEFT JOIN (
	SELECT
		tbv0014m.cd_hansya , --販社コード
		tbv0014m.cd_kaisya , --会社コード
		tbv0014m.cd_syozoten , --所属店舗
		COUNT(1) AS staffCount --スタッフ数
	FROM
		ai21rep_ve_dx.tbv0014m tbv0014m --Ｍ社員ＤＢ
	WHERE --スタッフ中古車 = '1'
		tbv0014m.kb_stafftyu = '1'
	GROUP BY
		tbv0014m.cd_hansya ,
		tbv0014m.cd_kaisya ,
		tbv0014m.cd_syozoten
) tbv0014m_ucar
  ON
	ucar.cd_hansya = tbv0014m_ucar.cd_hansya
	AND ucar.cd_kaisya = tbv0014m_ucar.cd_kaisya
	AND ucar.cd_jytyuten = tbv0014m_ucar.cd_syozoten
LIMIT 0;

-- [049/099] level=0 target=gold.VBI010003
-- Gold dependencies: none
-- Source file: 010_経営主要項目実績/VBI010001-VBI010006_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI010003 AS
SELECT  
	t201m.cd_hansya AS 販社コード, --販社コード
	t201m.cd_kaisya AS 会社コード,  --会社コード
	t201m.cd_tenpo AS 店舗コード,  --店舗コード
	CONCAT(t201m.cd_hansya, t201m.cd_kaisya, t201m.cd_tenpo) AS 販社会社店舗, --販社会社店舗
	NVL(newcar.新車下取数, 0) AS 新車下取数, --新車下取数
	NVL(newcar.入会数, 0) AS 新車入会数, --新車入会数
	NVL(newcar.直販数, 0) AS 新車直販数, --新車直販数
	NVL(newcar.直販下取数, 0) AS 直販下取数, --直販下取数
	NVL(newcar.新車軽OEM数, 0) AS 新車軽OEM数, --新車軽OEM数
	NVL(newcar.新車登録車数, 0) AS 新車登録車数  --新車登録車数
FROM
	ai21rep_ve_dx.tbv0201m t201m --共通店舗ＤＢ
LEFT JOIN
(	--新車販売
	SELECT
		cd_hansya, --販社コード
		cd_kaisya, --会社コード
		cd_tenpo, --店舗コード
		CONCAT(cd_hansya, cd_kaisya, cd_tenpo) AS 販社会社店舗コード, --販社会社店舗コード
		SUM(新車数) AS 新車数, --新車数
		SUM(新車下取数) AS 新車下取数, --新車下取数
		SUM(入会数) AS 入会数, --入会数
		SUM(直販数) AS 直販数, --直販数
		SUM(直販下取数) AS 直販下取数, --直販下取数
		SUM(CASE WHEN 軽区分 = '1' THEN 新車数 ELSE 0 END) AS 新車軽OEM数, -- --新車軽OEM数
		SUM(CASE WHEN NVL(軽区分,'') != '1' THEN 新車数 ELSE 0 END) AS 新車登録車数 --新車登録車数
	FROM
		(
		SELECT
			tbba001g.cd_hansya, --販社コード
			tbba001g.cd_kaisya, --会社コード
			tbba001g.cd_tenpo, --店舗コード
			SUM(calflg) AS 新車数, --新車数
			SUM( CASE WHEN tbba003g_1.新車下取数 > 0 THEN calflg ELSE 0 END) AS 新車下取数, --新車下取数
			TBBF001M.kn_kei AS 軽区分, --軽区分
			SUM( CASE WHEN NVL(REPLACE(REPLACE(tbba052g.kb_mntpkkei, '　', ''), ' ', ''),'') <>'' THEN calflg ELSE 0 END) AS 入会数, --入会数
			SUM( CASE WHEN TBBA056G.kb_gyocyok = '1' THEN calflg ELSE 0 END) AS 直販数, --直販数
			SUM( CASE WHEN TBBA056G.kb_gyocyok = '1' AND tbba003g_1.新車下取数 > 0 THEN calflg ELSE 0 END)  AS 直販下取数 --直販下取数		
		FROM
			(
			SELECT
				tbba001g.cd_hansya, --販社コード
				tbba001g.cd_kaisya, --会社コード
				tbba001g.cd_tenpo, --店舗コード
				tbba001g.no_cyumon, --注文ＮＯ
				tbba001g.no_cyumoned, --注文ＮＯ枝番
				tbba001g.mj_sinkysed,  --新旧世代
				tbba001g.mj_gaihansy, --外鈑色
				tbba001g.mj_hantenkt, --販売店型式
				(CASE
					WHEN ft168g.dd_torokei IS NULL THEN tbba001g.dd_uriagekj
					ELSE ft168g.dd_torokei
				END) AS 日付, --日付
				1 AS calflg --計算フラグ
			FROM
				ai21rep_ve_dx.tbba001g tbba001g --新車受注基本情報ＤＢ 
			LEFT JOIN(
			    SELECT
			        t168g.cd_hansya, --販社コード
			        t168g.cd_kaisya, --会社コード
			        t168g.no_cyumon, --注文ＮＯ
			        min(t168g.dd_torokei) AS dd_torokei --登録計上日
			    FROM ai21rep_ve_dx.tbbg168g t168g --履歴登録ＤＢ
			    WHERE -- 業務ＮＯ=「07」、処理ＮＯ=「01」　
			    	t168g.no_gyomu = '07'
			      AND t168g.no_syori = '01'
			    GROUP BY t168g.cd_hansya, t168g.cd_kaisya, t168g.no_cyumon
			) ft168g ON
				ft168g.cd_kaisya = tbba001g.cd_kaisya
				AND ft168g.cd_hansya = tbba001g.cd_hansya
				AND ft168g.no_cyumon = tbba001g.no_cyumon
			WHERE -- 払出区分 =「00」or「40」、受注計上日に値があり、かつ履歴登録ＤＢの登録計上日がNULLと新車受注基本情報ＤＢの売上計上日が当月、或いは履歴登録ＤＢの登録計上日が当月
				tbba001g.kb_haraidas NOT IN ('00', '40')
					AND tbba001g.dd_jucyuke IS NOT NULL
					AND ( (ft168g.dd_torokei IS NULL AND tbba001g.dd_uriagekj >= trunc(add_months(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM'))
						OR  (ft168g.dd_torokei IS NOT NULL
						AND ft168g.dd_torokei >= trunc(add_months(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM'))
  					)
			UNION ALL
				SELECT
					tbba001g.cd_hansya, --販社コード
					tbba001g.cd_kaisya, --会社コード					tbba001g.cd_tenpo,
					tbba001g.cd_tenpo, --店舗コード
					tbba001g.no_cyumon, --注文ＮＯ
					tbba001g.no_cyumoned, --注文ＮＯ枝番
					tbba001g.mj_sinkysed, --新旧世代
					tbba001g.mj_gaihansy, --外鈑色
					tbba001g.mj_hantenkt, --販売店型式
					tbba001g.dd_uritrkkj AS 日付, --売上取消計上日
					-1 AS calflg  --計算フラグ
				FROM
					ai21rep_ve_dx.tbba001g tbba001g --履歴登録ＤＢ
				WHERE --払出区分 =「00」or「40」、受注計上日が空白ではなく、売上取消計上日が今月
					tbba001g.kb_haraidas NOT IN ('00', '40')
					AND tbba001g.dd_jucyuke IS NOT NULL
					AND tbba001g.dd_uritrkkj >= trunc(add_months(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM')
		) tbba001g
		LEFT JOIN ai21rep_ve_dx.tbbf008m TBBF008M  --車両スペック２ＤＢ
	    	ON tbba001g.cd_kaisya = TBBF008M.cd_kaisya
				AND tbba001g.cd_hansya = TBBF008M.cd_hansya
				AND tbba001g.mj_sinkysed = TBBF008M.mj_sinkysed
				AND tbba001g.mj_gaihansy = TBBF008M.cd_spec
				AND tbba001g.mj_hantenkt = TBBF008M.mj_hantenkt
				AND TBBF008M.kb_spec = 'G'
			LEFT JOIN ai21rep_ve_dx.tbbf001m TBBF001M  --車名ＤＢ
    		ON
				TBBF001M.cd_kaisya = TBBF008M.cd_kaisya
				AND TBBF001M.cd_hansya = TBBF008M.cd_hansya
				AND TBBF001M.cd_ncsyamei = TBBF008M.mj_syamei
			LEFT JOIN (
				SELECT
					tbba003g.cd_hansya , --販社コード
					tbba003g.cd_kaisya , --会社コード
					tbba003g.no_cyumon , --注文ＮＯ
					tbba003g.no_cyumoned , --注文ＮＯ枝番
					COUNT(1) AS 新車下取数
				FROM
					ai21rep_ve_dx.tbba003g tbba003g --受注下取DB
				WHERE -- 新中区分= '1'
					tbba003g.kb_sincyu = '1'
				GROUP BY
					tbba003g.cd_hansya,
					tbba003g.cd_kaisya,
					tbba003g.no_cyumon,
					tbba003g.no_cyumoned
			) tbba003g_1
				ON tbba001g.cd_hansya = tbba003g_1.cd_hansya
				AND tbba001g.cd_kaisya = tbba003g_1.cd_kaisya
				AND tbba001g.no_cyumon = tbba003g_1.no_cyumon
				AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba003g_1.no_cyumoned)
			LEFT JOIN ai21rep_ve_dx.tbba052g tbba052g --新車受注販売条件情報ＤＢ 
				ON tbba001g.cd_hansya = tbba052g.cd_hansya
				AND tbba001g.cd_kaisya = tbba052g.cd_kaisya
				AND tbba001g.no_cyumon = tbba052g.no_cyumon
				AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba052g.no_cyumoned)
			LEFT JOIN ai21rep_ve_dx.tbba056g tbba056g --新車お客様詳細情報ＤＢ
				ON tbba001g.cd_hansya = tbba056g.cd_hansya
					AND tbba001g.cd_kaisya = tbba056g.cd_kaisya
					AND tbba001g.no_cyumon = tbba056g.no_cyumon
					AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba056g.no_cyumoned)
				GROUP BY
					tbba001g.cd_hansya,
					tbba001g.cd_kaisya,
					tbba001g.cd_tenpo,
					TBBF001M.kn_kei
			) combined
				GROUP BY
					cd_hansya,
					cd_kaisya,
					cd_tenpo,
					販社会社店舗コード
) newcar
		ON t201m.cd_hansya = newcar.cd_hansya
		AND t201m.cd_kaisya = newcar.cd_kaisya
		AND t201m.cd_tenpo = newcar.cd_tenpo
LIMIT 0;

-- [050/099] level=0 target=gold.VBI010004
-- Gold dependencies: none
-- Source file: 010_経営主要項目実績/VBI010001-VBI010006_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI010004 AS
SELECT  
	t201m.cd_hansya AS 販社コード, --販社コード
	t201m.cd_kaisya AS 会社コード, --会社コード
	t201m.cd_tenpo AS 店舗コード, --店舗コード
	CONCAT(t201m.cd_hansya, t201m.cd_kaisya, t201m.cd_tenpo) AS 販社会社店舗, --販社会社店舗
	NVL(ucar.TAD販売実績, 0) AS TAD販売実績, --TAD販売実績
	NVL(ucar.TAD下取数, 0) AS TAD下取数, --TAD下取数
	NVL(ucar.TAD入会数, 0) AS TAD入会数, --TAD入会数
	NVL(ucar.Ucar下取数, 0) AS Ucar下取数, --Ucar下取数
	NVL(ucar.UCar買取数, 0) AS UCar買取数, --UCar買取数
	NVL(ucar.UCar入会数, 0) AS UCar入会数, --UCar入会数
	NVL(ucar.UCar小売, 0) AS UCar小売, --UCar小売
	NVL(ucar.UCar卸, 0) AS UCar卸 --UCar卸
FROM
	ai21rep_ve_dx.tbv0201m t201m --共通店舗ＤＢ
LEFT JOIN 
(--中古車販売
	SELECT
		cd_hansya, --販社コード
		cd_kaisya,  --会社コード
		cd_jytyuten, --受注店舗コード
		SUM(CASE WHEN 売上区分 = '11' THEN Ucar下取数 ELSE 0 END) AS Ucar下取数, --Ucar下取数
		SUM(CASE WHEN 売上区分 = '11' THEN UCar入会数 ELSE 0 END) AS UCar入会数, --UCar入会数
		SUM(UCar買取数) AS UCar買取数, --UCar買取数	
		SUM(CASE WHEN 売上区分 = '11' THEN Ucar販売数 ELSE 0 END) AS UCar小売, --UCar小売
		SUM(CASE WHEN 売上区分 = '20' THEN Ucar販売数 ELSE 0 END) AS UCar卸, --UCar卸
		SUM(CASE WHEN 売上区分 = '14' THEN Ucar販売数 ELSE 0 END) AS TAD販売実績, --TAD販売実績
		SUM(CASE WHEN 売上区分 = '14' THEN Ucar下取数 ELSE 0 END) AS TAD下取数, --TAD下取数
		SUM(CASE WHEN 売上区分 = '14' THEN UCar入会数 ELSE 0 END) AS TAD入会数 --TAD入会数
	FROM
		(
		SELECT
			tbbc017g.cd_hansya, --販社コード
			tbbc017g.cd_kaisya, --会社コード
			tbbc017g.cd_jytyuten, --受注店舗コード
			tbbc017g.kb_uriage AS 売上区分, --売上区分
			SUM(calflg) AS Ucar販売数, --Ucar販売数
     		(SUM(CASE WHEN tbba003g_1.Ucar下取数 > 0  THEN calflg ELSE 0 END) ) AS Ucar下取数, --Ucar下取数
			SUM(CASE WHEN TBBC001G.kb_siire LIKE '3%' THEN calflg ELSE 0 END) AS UCar買取数 , --UCar買取数
			SUM(CASE WHEN NVL(REPLACE(REPLACE(tbbc020g.kb_mntpkkei, '　', ''), ' ', ''),'') <> '' THEN calflg ELSE 0 END)  AS UCar入会数  --UCar入会数
		FROM
			(
			SELECT
				tbbc017g.cd_hansya, --販社コード
				tbbc017g.cd_kaisya, --会社コード
				tbbc017g.cd_jytyuten, --受注店舗コード
				tbbc017g.no_cyumon, --注文ＮＯ
				tbbc017g.no_cyumoned, --注文ＮＯ枝番
				tbbc017g.no_syaryou, --車両ＮＯ
				tbbc017g.kb_uriage, --売上区分
				1 AS calflg --計算フラグ
			FROM
				ai21rep_ve_dx.tbbc017g tbbc017g --中古車受注基本情報ＤＢ
			LEFT JOIN 
	   		(
				SELECT
					t8006.cd_hansya, --販社コード
					t8006.cd_kaisya, --会社コード
					t8006.no_cyumon,  --注文ＮＯ
					MIN(t8006.dd_uriage) AS dd_uriage --売上日
				FROM
					ai21rep_ve_dx.tbg8006m t8006 --中古車小売売上トランＤＢ 
				GROUP BY
					t8006.cd_hansya,
					t8006.cd_kaisya,
					t8006.no_cyumon
	    		)ft8006 ON
				tbbc017g.cd_kaisya = ft8006.cd_kaisya
				AND tbbc017g.cd_kaisya = ft8006.cd_kaisya
				AND tbbc017g.no_cyumon = ft8006.no_cyumon
				AND tbbc017g.dd_uritorik IS NULL
			WHERE -- 受注計上日に値があり、取消日がNULL、かつ中古車小売売上トランＤＢ の売上日がNULLと中古車受注基本情報ＤＢの売上計上日が当月、
				--或いは中古車小売売上トランＤＢの売上日が当月
				tbbc017g.dd_uriagekj IS NOT NULL
				AND tbbc017g.dd_torikesi IS NULL
				AND ( (ft8006.dd_uriage IS NULL
					AND tbbc017g.dd_uriagekj >= TRUNC(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM'))
					OR 
	            		(ft8006.dd_uriage IS NOT NULL
					AND from_timestamp(to_timestamp(CAST(ft8006.dd_uriage AS STRING), 'yyyyMM'), 'yyyyMM') >= TRUNC(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM')
	        ))
		UNION ALL
			SELECT
				tbbc017g.cd_hansya, --販社コード
				tbbc017g.cd_kaisya, --会社コード
				tbbc017g.cd_jytyuten, --受注店舗コード
				tbbc017g.no_cyumon, --注文ＮＯ
				tbbc017g.no_cyumoned, --注文ＮＯ枝番
				tbbc017g.no_syaryou,  --車両ＮＯ
				tbbc017g.kb_uriage, --売上区分
				-1 AS calflg --計算フラグ
			FROM
				ai21rep_ve_dx.tbbc017g tbbc017g --中古車受注基本情報ＤＢ
			WHERE -- 中古車受注基本情報ＤＢの受注計上日に値があり、取消日が当月
				tbbc017g.dd_jucyuke IS NOT NULL
				AND tbbc017g.dd_uritorik >= TRUNC(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM')
		) tbbc017g
		LEFT JOIN ai21rep_ve_dx.tbbc001g TBBC001G --中古車在庫基本情報ＤＢ
		ON TBBC001G.cd_kaisya = tbbc017g.cd_kaisya
		AND TBBC001G.cd_hansya = tbbc017g.cd_hansya
		AND TBBC001G.no_syaryou = tbbc017g.no_syaryou
		LEFT JOIN (
			SELECT
				tbba003g.cd_hansya, --販社コード
				tbba003g.cd_kaisya, --会社コード
				tbba003g.no_cyumon, --注文ＮＯ
				tbba003g.no_cyumoned, --注文ＮＯ枝番
				COUNT(1) AS Ucar下取数 --Ucar下取数
			FROM
				ai21rep_ve_dx.tbba003g tbba003g --受注下取DB
			WHERE --新中区分='2'
				tbba003g.kb_sincyu = '2'
			GROUP BY
				tbba003g.cd_hansya,
				tbba003g.cd_kaisya,
				tbba003g.no_cyumon,
				tbba003g.no_cyumoned
		   ) tbba003g_1
		   ON tbbc017g.cd_hansya = tbba003g_1.cd_hansya
			AND tbbc017g.cd_kaisya = tbba003g_1.cd_kaisya
			AND tbbc017g.no_cyumon = tbba003g_1.no_cyumon
			AND TRIM(tbbc017g.no_cyumoned) = TRIM(tbba003g_1.no_cyumoned)
		LEFT JOIN ai21rep_ve_dx.tbbc020g tbbc020g --中古車受注販売条件情報ＤＢ
			ON tbbc017g.cd_hansya = tbbc020g.cd_hansya
			AND tbbc017g.cd_kaisya = tbbc020g.cd_kaisya
			AND tbbc017g.no_cyumon = tbbc020g.no_cyumon
			AND TRIM(tbbc017g.no_cyumoned) = TRIM(tbbc020g.no_cyumoned)
		--売上区分 = '11', '14', '20'
		WHERE tbbc017g.kb_uriage IN ('11', '14', '20')
			GROUP BY
				tbbc017g.cd_hansya,
				tbbc017g.cd_kaisya,
				tbbc017g.cd_jytyuten,
				tbbc017g.kb_uriage
) combined
	GROUP BY
		cd_hansya,
		cd_kaisya,
		cd_jytyuten
) ucar ON
	t201m.cd_hansya = ucar.cd_hansya
	AND t201m.cd_kaisya = ucar.cd_kaisya
	AND t201m.cd_tenpo = ucar.cd_jytyuten
LIMIT 0;

-- [051/099] level=0 target=gold.VBI010005
-- Gold dependencies: none
-- Source file: 010_経営主要項目実績/VBI010001-VBI010006_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI010005 AS
SELECT  
	t201m.cd_hansya AS 販社コード, --販社コード
	t201m.cd_kaisya AS 会社コード, --会社コード
	t201m.cd_tenpo AS 店舗コード, --店舗コード
	CONCAT(t201m.cd_hansya, t201m.cd_kaisya, t201m.cd_tenpo) AS 販社会社店舗, --販社会社店舗
	NVL(newcar_daitei.新車代替, 0) AS 新車代替, --新車代替
	NVL(newcar_daitei.新車実績, 0) AS 新車実績 --新車実績
FROM
	ai21rep_ve_dx.tbv0201m t201m --共通店舗ＤＢ
LEFT JOIN
( --新車代替
	SELECT
		tbba001g.cd_hansya, --販社コード
		tbba001g.cd_kaisya, --会社コード
		tbba001g.cd_tenpo, --店舗コード
		SUM( IF(tbba056g.mj_jucyuke4 IN ('02','03'),calflg ,0)) AS 新車代替, --新車代替
		SUM(calflg) AS 新車実績 --新車実績
	FROM
		(
		SELECT
			tbba001g.cd_hansya, --販社コード
			tbba001g.cd_kaisya, --会社コード
			tbba001g.cd_tenpo, --店舗コード
			tbba001g.no_cyumon, --注文ＮＯ
			tbba001g.no_cyumoned, --注文ＮＯ枝番
			tbba001g.mj_sinkysed, --新旧世代
			tbba001g.mj_gaihansy, --外鈑色
			tbba001g.mj_hantenkt, --販売店型式
			(CASE
				WHEN ft168g.dd_torokei IS NULL THEN tbba001g.dd_uriagekj
				ELSE ft168g.dd_torokei
			END) AS 日付,
			1 AS calflg
		FROM
			ai21rep_ve_dx.tbba001g tbba001g --新車受注基本情報ＤＢ 
		LEFT JOIN(
		    SELECT
		        t168g.cd_hansya, --販社コード
		        t168g.cd_kaisya, --会社コード
		        t168g.no_cyumon, --注文ＮＯ
		        min(t168g.dd_torokei) AS dd_torokei --登録計上日
		    FROM ai21rep_ve_dx.tbbg168g t168g --履歴登録ＤＢ
		    WHERE -- 業務ＮＯ=「07」、処理ＮＯ=「01」　
		    	t168g.no_gyomu = '07'
		      AND t168g.no_syori = '01'
		    GROUP BY t168g.cd_hansya, t168g.cd_kaisya, t168g.no_cyumon
		) ft168g ON
			ft168g.cd_kaisya = tbba001g.cd_kaisya
			AND ft168g.cd_hansya = tbba001g.cd_hansya
			AND ft168g.no_cyumon = tbba001g.no_cyumon
		WHERE -- 払出区分 =「00」or「40」、受注計上日に値があり、かつ履歴登録ＤＢの登録計上日がNULLと新車受注基本情報ＤＢの売上計上日に値があり、或いは履歴登録ＤＢの登録計上日に値がある
			tbba001g.kb_haraidas NOT IN ('00', '40')
				AND tbba001g.dd_jucyuke IS NOT NULL
				AND ( (ft168g.dd_torokei IS NULL
					AND tbba001g.dd_uriagekj IS NOT NULL)
					OR  (ft168g.dd_torokei IS NOT NULL)
		)
		UNION ALL
			SELECT
				tbba001g.cd_hansya, --販社コード
				tbba001g.cd_kaisya , --会社コード
				tbba001g.cd_tenpo, --店舗コード
				tbba001g.no_cyumon, --注文ＮＯ
				tbba001g.no_cyumoned, --注文ＮＯ枝番
				tbba001g.mj_sinkysed, --新旧世代
				tbba001g.mj_gaihansy, --外鈑色
				tbba001g.mj_hantenkt, --販売店型式
				tbba001g.dd_uritrkkj AS dd_uritrkkj, --売上取消計上日
				-1 AS calflg
			FROM
				ai21rep_ve_dx.tbba001g tbba001g --新車受注基本情報ＤＢ
			WHERE --払出区分 =「00」or「40」、受注計上日、売上取消計上日が空白ではない
				tbba001g.kb_haraidas NOT IN ('00', '40')
					AND tbba001g.dd_jucyuke IS NOT NULL
					AND tbba001g.dd_uritrkkj IS NOT NULL
		) tbba001g
		LEFT JOIN ai21rep_ve_dx.tbba056g tbba056g  --新車お客様詳細情報ＤＢ 
			ON tbba001g.cd_hansya = TBBA056G.cd_hansya
			AND tbba001g.cd_kaisya = TBBA056G.cd_kaisya
			AND tbba001g.no_cyumon = TBBA056G.no_cyumon
			AND TRIM(tbba001g.no_cyumoned) = TRIM(TBBA056G.no_cyumoned)
	GROUP BY
		tbba001g.cd_hansya,
		tbba001g.cd_kaisya,
		tbba001g.cd_tenpo
	) newcar_daitei --新車代替	
	ON t201m.cd_hansya = newcar_daitei.cd_hansya
	AND t201m.cd_kaisya = newcar_daitei.cd_kaisya
	AND t201m.cd_tenpo = newcar_daitei.cd_tenpo
LIMIT 0;

-- [052/099] level=0 target=gold.VBI010006
-- Gold dependencies: none
-- Source file: 010_経営主要項目実績/VBI010001-VBI010006_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI010006 AS
SELECT  
	t201m.cd_hansya AS 販社コード,
	t201m.cd_kaisya AS 会社コード,
	t201m.cd_tenpo AS 店舗コード,
	CONCAT(t201m.cd_hansya, t201m.cd_kaisya, t201m.cd_tenpo) AS 販社会社店舗,
	NVL(ucar_daitei.Ucar実績, 0) AS Ucar実績,
	NVL(ucar_daitei.Ucar代替, 0) AS Ucar代替,
	NVL(ucar_daitei.TAD実績, 0) AS TAD実績,
	NVL(ucar_daitei.TAD代替, 0) AS TAD代替
FROM
	ai21rep_ve_dx.tbv0201m t201m --共通店舗ＤＢ
LEFT JOIN
	(-- Ucar代替	
	SELECT
		tbbc017g.cd_hansya,
		tbbc017g.cd_kaisya,
		tbbc017g.cd_jytyuten,
		SUM(IF(tbbc017g.kb_uriage = '11', calflg,0)) AS Ucar実績,
		SUM(IF(tbbc017g.kb_uriage ='11' AND tbbc034g.mj_jucyuke4 IN ('02','03'), calflg,0)) AS Ucar代替,
		SUM(IF(tbbc017g.kb_uriage='14', calflg,0)) AS TAD実績,
		SUM(IF(tbbc017g.kb_uriage='14' AND tbbc034g.mj_jucyuke4 IN ('02','03'), calflg,0)) AS TAD代替
	FROM
		(
		SELECT
			tbbc017g.cd_hansya, --販社コード
				tbbc017g.cd_kaisya, --会社コード
				tbbc017g.cd_jytyuten, --受注店舗コード
				tbbc017g.no_cyumon, --注文ＮＯ
				tbbc017g.no_cyumoned,  --注文ＮＯ枝番
				tbbc017g.no_syaryou, --車両ＮＯ
				tbbc017g.kb_uriage, --売上区分
				1 AS calflg --計算フラグ
		FROM ai21rep_ve_dx.tbbc017g tbbc017g  --中古車受注基本情報ＤＢ
		LEFT JOIN 
		(
			SELECT
				t8006.cd_hansya, --販社コード
				t8006.cd_kaisya, --会社コード
				t8006.no_cyumon, --注文ＮＯ
				MIN(t8006.dd_uriage) AS dd_uriage --売上日
			FROM
				ai21rep_ve_dx.tbg8006m t8006  --中古車小売売上トランＤＢ
			GROUP BY
				t8006.cd_hansya,
				t8006.cd_kaisya,
				t8006.no_cyumon
		 )ft8006 ON
				tbbc017g.cd_kaisya = ft8006.cd_kaisya
			AND tbbc017g.cd_kaisya = ft8006.cd_kaisya
			AND tbbc017g.no_cyumon = ft8006.no_cyumon
			AND tbbc017g.dd_uritorik IS NULL
		WHERE -- 受注計上日に値があり、取消日がNULL、かつ中古車小売売上トランＤＢ の売上日がNULLと中古車受注基本情報ＤＢの売上計上日に値があり、、
				--或いは中古車小売売上トランＤＢの売上日に値がある
			tbbc017g.dd_uriagekj IS NOT NULL
			AND tbbc017g.dd_torikesi IS NULL
			AND (
		            (ft8006.dd_uriage IS NULL AND tbbc017g.dd_uriagekj IS NOT NULL)
			OR 
		            (ft8006.dd_uriage IS NOT NULL
		        ))
	UNION ALL
		SELECT
			tbbc017g.cd_hansya, --販社コード
			tbbc017g.cd_kaisya, --会社コード
			tbbc017g.cd_jytyuten, --受注店舗コード
			tbbc017g.no_cyumon, --注文ＮＯ
			tbbc017g.no_cyumoned,  --注文ＮＯ枝番
			tbbc017g.no_syaryou, --車両ＮＯ
			tbbc017g.kb_uriage, --売上区分
			-1 AS calflg  --計算フラグ
		FROM
			ai21rep_ve_dx.tbbc017g tbbc017g  --中古車受注基本情報ＤＢ
		WHERE -- 中古車受注基本情報ＤＢの受注計上日、取消日に値がある
		tbbc017g.dd_jucyuke IS NOT NULL
		AND tbbc017g.dd_uritorik IS NOT NULL
	) tbbc017g
	LEFT JOIN ai21rep_ve_dx.tbbc034g tbbc034g --中古車受注お客様詳細情報ＤＢ
		ON tbbc017g.cd_hansya = tbbc034g.cd_hansya
		AND tbbc017g.cd_kaisya = tbbc034g.cd_kaisya
		AND tbbc017g.no_cyumon = tbbc034g.no_cyumon
		AND TRIM(tbbc017g.no_cyumoned) = TRIM(tbbc034g.no_cyumoned)
	GROUP BY
			tbbc017g.cd_hansya,
			tbbc017g.cd_kaisya,
			tbbc017g.cd_jytyuten
) ucar_daitei 
	ON t201m.cd_hansya = ucar_daitei.cd_hansya
	AND t201m.cd_kaisya = ucar_daitei.cd_kaisya
	AND t201m.cd_tenpo = ucar_daitei.cd_jytyuten
LIMIT 0;

-- [053/099] level=0 target=gold.vbi011001
-- Gold dependencies: none
-- Source file: 011_メンテナンスパック契約客ステータス一覧/メンテナンスパック契約客ステータス一覧_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi011001 AS
SELECT 
    --販社コード
    t0021m.cd_hansya,  
    --会社コード
    t0021m.cd_kaisya, 
    --契約区分
    t0021m.kb_keiyaku, 
    --枝番
    t0021m.no_edaban,   
    --想定税率 
    t0021m.nu_sotezert, 
    --連番
    t0021m.no_renban, 
    --利用整備名称
    t0021m.kj_riyoseim,
    --加入商品名
    t0020m.kj_kanyusyu,
    --税込金額 = 合計金額 + 消費税
    t0021m.ki_goukei + t0021m.ki_syohizei AS `totalcount`
FROM 
    --Ｍパック料金ＤＢ
    ai21rep_ve_dx.tbv0021m t0021m   
LEFT JOIN
    --Ｍパック商品ＤＢ
    ai21rep_ve_dx.tbv0020m t0020m   
ON 
    t0021m.cd_hansya = t0020m.cd_hansya
    AND t0021m.cd_kaisya = t0020m.cd_kaisya
    AND t0021m.kb_keiyaku = t0020m.kb_keiyaku
    AND t0021m.no_edaban = t0020m.no_edaban
    AND t0021m.nu_sotezert = t0020m.nu_sotezert
LIMIT 0;

-- [054/099] level=0 target=gold.vbi011002
-- Gold dependencies: none
-- Source file: 011_メンテナンスパック契約客ステータス一覧/メンテナンスパック契約客ステータス一覧_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi011002 AS
SELECT 
	--販社コード
	t0201m.cd_hansya,  
	--会社コード
	t0201m.cd_kaisya, 
	--店舗コード
	t0201m.cd_tenpo,  
	--店舗名称
	t0201m.kj_tenpomei,
	--ゾーンコード
	 IF(
    	t0033m.kj_zonmei IS NULL OR regexp_replace(t0033m.kj_zonmei, '[ 　]+', '') = '',
    	'999999',
    	IF(
        	t0033m.cd_zon IS NULL OR regexp_replace(t0033m.cd_zon, '[ 　]+', '') = '',
        	'999998',
        	t0033m.cd_zon
    	)
	) AS cd_zon, 
	--ゾーン名称 
	t0033m.kj_zonmei,
	--ソート順
	t9003m.mj_sortjyun
FROM
	--共通店舗DB
    ai21rep_ve_dx.tbv0201m t0201m
    --M車両店舗DB
LEFT JOIN ai21rep_ve_dx.tbv0047m t0047m
    ON t0047m.cd_hansya = t0201m.cd_hansya
    AND t0047m.cd_kaisya = t0201m.cd_kaisya
    AND t0047m.cd_tenpo = t0201m.cd_tenpo
    --MゾーンコードDB
LEFT JOIN ai21rep_ve_dx.tbv0033m t0033m
    ON t0033m.cd_hansya = t0047m.cd_hansya
    AND t0033m.cd_kaisya = t0047m.cd_kaisya
    AND t0033m.cd_zon = t0047m.CD_NCZON
	--商品区分 = '3'（サービス）
	AND t0033m.kb_syohin = '3'
	--店舗展示設定
INNER JOIN dx_ve.tbi999003m t9003m
	ON t9003m.cd_hansya = t0201m.cd_hansya
    AND t9003m.cd_kaisya = t0201m.cd_kaisya
    AND t9003m.cd_tenpo = t0201m.cd_tenpo
    AND t9003m.mj_cyohyoid = '011'
    AND t9003m.kb_tenji = 1
LIMIT 0;

-- [055/099] level=0 target=gold.vbi011004
-- Gold dependencies: none
-- Source file: 011_メンテナンスパック契約客ステータス一覧/メンテナンスパック契約客ステータス一覧_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi011004 AS
SELECT 
	--販社コード
	t005g.cd_hansya,
	--会社コード
	t005g.cd_kaisya,
	--お客様コード
	ta001g.cd_okyaku,
	--登録ＮＯ陸支コード
	ta001g.cd_norikusi,
	--登録ＮＯ車種区分
	ta001g.kb_nosyasyu,
	--登録ＮＯ業態コード
	ta001g.cd_nogyotai,
	--登録ＮＯ整理番号
	ta001g.no_noseiri,
	--入庫予定日時
	ta001g.dt_nyuukoyt,
	--入庫区分
	t005g.kb_nyuuko
--ストール予約明細DB
FROM ai21rep_ve_dx.tbsa005g t005g
--ストール予約ＤＢ
LEFT JOIN ai21rep_ve_dx.tbsa001g ta001g 
ON t005g.cd_hansya = ta001g.cd_hansya 
AND t005g.cd_kaisya = ta001g.cd_kaisya
AND t005g.cd_tenpo = ta001g.cd_tenpo
--予約ＩＤ
AND t005g.no_yoyakuid = ta001g.no_yoyakuid
--= Table.SelectRows(フィルターされた行, each ([予約ＩＤ] <> null and [予約ＩＤ] <> "") and ([登録ＮＯ陸支コード] <> ""))
AND ta001g.no_yoyakuid IS NOT NULL
--登録ＮＯ陸支コード != '' 
AND ta001g.cd_norikusi != '' 
--= Table.SelectRows(chgColName, each ([ＳＭＢ削除フラグ] = "0"))
AND ta001g.mj_sakujyo = '0'
WHERE 
--= Table.SelectRows(条件付き制限された初期行数, each ([ＳＭＢ削除フラグ] = "0") and ([入庫区分] <> "" and [入庫区分] <> "0" and [入庫区分] <> "8" and [入庫区分] <> "9"))
t005g.mj_sakujyo = '0'
AND t005g.kb_nyuuko != ''
AND t005g.kb_nyuuko != '0'
AND t005g.kb_nyuuko != '8'
AND t005g.kb_nyuuko != '9'
LIMIT 0;

-- [056/099] level=1 target=gold.vbi011005
-- Gold dependencies: gold.vbi011002
-- Source file: 011_メンテナンスパック契約客ステータス一覧/メンテナンスパック契約客ステータス一覧_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi011005 AS
SELECT 
	--販社コード
	tz006m.cd_hansya,
	--会社コード
	tz006m.cd_kaisya,
	--お客様コード
	tz006m.cd_okyaku,
	--スタッフ店舗コード
	tz006m.cd_stafften,
	--スタッフコード
	tz006m.cd_staff,
	--エリアコード
	vbi011002.cd_zon,
	--エリア名
	vbi011002.kj_zonmei,
	--店舗名
	vbi011002.kj_tenpomei,
	--ソート順
	vbi011002.mj_sortjyun,
	--社員名
	t0014m.kj_syainmei
--顧客担当ＤＢ
FROM ai21rep_ve_dx.tbaz006m tz006m
INNER JOIN gold.vbi011002 vbi011002
	ON tz006m.cd_hansya = vbi011002.cd_hansya
	AND tz006m.cd_kaisya = vbi011002.cd_kaisya
	AND tz006m.cd_stafften = vbi011002.cd_tenpo
--M社員DB
LEFT JOIN ai21rep_ve_dx.tbv0014m t0014m
	ON tz006m.cd_hansya = t0014m.cd_hansya
	AND tz006m.cd_kaisya = t0014m.cd_kaisya
	AND tz006m.cd_staff = t0014m.cd_syain
--Table.SelectRows(#"名前が変更された列 ", each ([会社コード] = "01") and ([#"担当分類区分 "] = "1"))
WHERE tz006m.kb_tantobun = '1'
LIMIT 0;

-- [057/099] level=2 target=gold.vbi011006
-- Gold dependencies: gold.vbi011001, gold.vbi011004, gold.vbi011005
-- Source file: 011_メンテナンスパック契約客ステータス一覧/メンテナンスパック契約客ステータス一覧_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi011006 AS
SELECT 
		--販社コード
    	tz030m.cd_hansya AS '販社コード',
		--会社コード
		tz030m.cd_kaisya AS '会社コード',
		--お客様コード
		tz030m.cd_okyaku AS 'お客様コード',
		--スタッフエリアコード
		vbi011005.cd_zon AS 'スタッフエリアコード',
		--スタッフエリア名
		vbi011005.kj_zonmei AS 'スタッフエリア名',
		--スタッフ店舗名
		vbi011005.kj_tenpomei AS 'スタッフ店舗名',
		--テーブル店舗名
		vbi011005.kj_tenpomei AS 'テーブル店舗名',
		--スタッフ名
		vbi011005.kj_syainmei AS 'スタッフ名',
		--店舗スタッフ
		CONCAT(vbi011005.cd_stafften, vbi011005.cd_staff) AS '店舗スタッフ',
		--実施区分
		tz031m.kb_jissi AS '実施区分',
		--メンテパック名称
		vbi011001.kj_kanyusyu AS 'メンテパック名称',
		--項目利用整備名称
		vbi011001.kj_riyoseim AS '項目利用整備名称',
		--契約区分
		vbi011001.kb_keiyaku AS '契約区分',
		--税込金額
		vbi011001.totalcount AS '税込金額',
		--新規連番
		DENSE_RANK() OVER (
			PARTITION BY 
			CONCAT(tz030m.cd_okyaku, tz030m.cd_norikusi, tz030m.kb_nosyasyu, tz030m.cd_nogyotai, tz030m.no_noseiri, vbi011001.kb_keiyaku, vbi011001.kj_kanyusyu)
			ORDER BY tz031m.dd_jisiyote ASC, vbi011001.no_renban ASC
		) AS '新規連番',
		--実施予定年月日
		tz031m.dd_jisiyote AS '実施予定年月日',
		--実施予定年月スライサー
		IF(tz031m.dd_jisiyote IS NULL, NULL
	    , IF(tz031m.dd_jisiyote >= DATE_ADD(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), INTERVAL -3 MONTH)
	    	, CONCAT(FROM_TIMESTAMP(tz031m.dd_jisiyote, 'yy年MM月'), '分')
	    	, CONCAT(FROM_TIMESTAMP(DATE_ADD(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), INTERVAL -3 MONTH), 'yy年MM月'), '以前分')
	    	)
	    ) AS '実施予定年月スライサー',
		--契約終了予定年月スライサー
	    IF(tz030m.dd_mntkanry IS NULL, NULL
	    ,IF(
	    	FROM_TIMESTAMP(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'yyyyMM') > FROM_TIMESTAMP(tz030m.dd_mntkanry, 'yyyyMM')
	    	, CONCAT(FROM_TIMESTAMP(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'yy年MM月'), '以前分')
	    	, CONCAT(FROM_TIMESTAMP(tz030m.dd_mntkanry, 'yy年MM月'), '分')
	    	)
	    ) AS '契約終了予定年月スライサー',
		--登録ＮＯ
		CONCAT(
			tz030m.cd_hansya,
			tz030m.cd_kaisya,
			tz030m.cd_okyaku,
			tz030m.cd_norikusi,
			tz030m.kb_nosyasyu,
			tz030m.cd_nogyotai,
			tz030m.no_noseiri
			) AS '登録ＮＯ',
		--入庫区分漢字
	    CASE
		    	WHEN INSTR(vbi011001.kj_riyoseim, '無') > 0 THEN '無点'
			  	WHEN INSTR(vbi011001.kj_riyoseim, '１２') > 0 THEN '１２点'
			  	WHEN INSTR(vbi011001.kj_riyoseim, '６') > 0 THEN '６点'
			  	WHEN INSTR(vbi011001.kj_riyoseim, '車検') > 0 THEN '車検'
		    ELSE NULL 
	    END AS '入庫区分漢字',
		--SMB予約入庫日時
		(IF(vbi011004.dt_nyuukoyt >= DATE_ADD(tz031m.dd_jisiyote, INTERVAL -2 MONTH) 
				AND vbi011004.dt_nyuukoyt <= DATE_ADD(tz031m.dd_jisiyote, INTERVAL 1 MONTH)
				,vbi011004.dt_nyuukoyt
				,NULL)) AS 'SMB予約入庫日時'
	--メンテパック契約DB
    FROM ai21rep_ve_dx.tbaz030m tz030m
    LEFT JOIN gold.vbi011001
		ON tz030m.cd_hansya = vbi011001.cd_hansya
		AND tz030m.cd_kaisya = vbi011001.cd_kaisya
		AND tz030m.kb_mntkeiya = TRIM(vbi011001.kb_keiyaku)
		AND tz030m.no_edaban = vbi011001.no_edaban
		AND CAST(tz030m.nu_sotezert AS INT) = vbi011001.nu_sotezert
	--メンテパック明細ＤＢ
    LEFT JOIN ai21rep_ve_dx.tbaz031m tz031m
		ON tz030m.cd_hansya = tz031m.cd_hansya
		AND tz030m.cd_kaisya = tz031m.cd_kaisya
		AND tz030m.cd_okyaku = tz031m.cd_okyaku
		AND tz030m.cd_norikusi = tz031m.cd_norikusi
		AND tz030m.kb_nosyasyu = tz031m.kb_nosyasyu
		AND tz030m.cd_nogyotai = tz031m.cd_nogyotai
		AND tz030m.no_noseiri = tz031m.no_noseiri
		AND vbi011001.no_renban = LPAD(CAST(tz031m.no_table AS STRING), 2, '0')
	-- サービス入庫区分DB
	LEFT JOIN ai21rep_ve_dx.tbfy232m ty232m
		ON tz030m.cd_hansya = ty232m.cd_hansya
		AND tz030m.cd_kaisya = ty232m.cd_kaisya
		--= Table.SelectRows(#"名前が変更された列 ", each ([詳細入庫区分] = " "))
		AND ty232m.kb_syosnyuk = " "
		AND CASE
		    	WHEN INSTR(vbi011001.kj_riyoseim, '無') > 0 THEN '無点'
			  	WHEN INSTR(vbi011001.kj_riyoseim, '１２') > 0 THEN '１２点'
			  	WHEN INSTR(vbi011001.kj_riyoseim, '６') > 0 THEN '６点'
			  	WHEN INSTR(vbi011001.kj_riyoseim, '車検') > 0 THEN '車検'
			    ELSE NULL 
		    END = REPLACE(REPLACE(ty232m.kj_nyuukom, '　', ''), ' ', '')
	LEFT JOIN(
		SELECT 
			--販社コード
			cd_hansya,
			--会社コード
			cd_kaisya,
			--お客様コード
			cd_okyaku,
			--登録ＮＯ陸支コード
			cd_norikusi,
			--登録ＮＯ車種区分
			kb_nosyasyu,
			--登録ＮＯ業態コード
			cd_nogyotai,
			--登録ＮＯ整理番号
			no_noseiri,
			--入庫区分
			kb_nyuuko,
            --入庫予定日時
			max(dt_nyuukoyt) as 'dt_nyuukoyt'
		FROM gold.vbi011004
		GROUP BY
			cd_hansya,
			cd_kaisya,
			cd_okyaku,
			cd_norikusi,
			kb_nosyasyu,
			cd_nogyotai,
			no_noseiri,
			kb_nyuuko
	)vbi011004
		ON tz030m.cd_hansya = vbi011004.cd_hansya
		AND tz030m.cd_kaisya = vbi011004.cd_kaisya
		AND tz030m.cd_okyaku = vbi011004.cd_okyaku
		AND tz030m.cd_norikusi = vbi011004.cd_norikusi
		AND tz030m.kb_nosyasyu = vbi011004.kb_nosyasyu
		AND tz030m.cd_nogyotai = vbi011004.cd_nogyotai
		AND tz030m.no_noseiri = vbi011004.no_noseiri
		AND vbi011004.kb_nyuuko = ty232m.kb_nyuuko
INNER JOIN gold.vbi011005
	ON tz030m.cd_hansya = vbi011005.cd_hansya
	AND tz030m.cd_kaisya = vbi011005.cd_kaisya
	AND tz030m.cd_okyaku = vbi011005.cd_okyaku
LIMIT 0;

-- [058/099] level=2 target=gold.vbi011008
-- Gold dependencies: gold.vbi011005
-- Source file: 011_メンテナンスパック契約客ステータス一覧/メンテナンスパック契約客ステータス一覧_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi011008 AS
SELECT 
	--販社コード
	tz030m.cd_hansya AS '販社コード',
	--会社コード
	tz030m.cd_kaisya AS '会社コード',
	--お客様コード
	tz030m.cd_okyaku AS 'お客様コード',
	--ソート順
	dense_rank() over(partition by tz030m.cd_hansya, tz030m.cd_kaisya order by vbi011005.cd_zon,vbi011005.mj_sortjyun, vbi011005.cd_stafften) as 'ソート順',
	--テーブルソート順
	dense_rank() over(partition by tz030m.cd_hansya, tz030m.cd_kaisya order by vbi011005.cd_zon,vbi011005.mj_sortjyun, vbi011005.cd_stafften,vbi011005.cd_staff) as 'テーブルソート順',
	--車名
	tec05g.mj_syamei AS '車名',
	--登録番号 = RELATED('TBV0013M_Ｍ陸支コードDB'[陸支名称])&[登録NO陸支除]
	CONCAT(t0013m.kj_rikusim, tz030m.kb_nosyasyu, tz030m.cd_nogyotai, tz030m.no_noseiri) AS '登録番号',
	--登録ＮＯ
	CONCAT(
			tz030m.cd_hansya,
			tz030m.cd_kaisya,
			tz030m.cd_okyaku,
			tz030m.cd_norikusi,
			tz030m.kb_nosyasyu,
			tz030m.cd_nogyotai,
			tz030m.no_noseiri
			) AS '登録ＮＯ'
--メンテパック契約ＤＢ
FROM ai21rep_ve_dx.tbaz030m tz030m
INNER JOIN gold.vbi011005 vbi011005
	ON tz030m.cd_hansya = vbi011005.cd_hansya
	AND tz030m.cd_kaisya = vbi011005.cd_kaisya
	AND tz030m.cd_okyaku = vbi011005.cd_okyaku
--車両管理ＤＢ
LEFT JOIN ai21rep_ve_dx.tbtec05g tec05g
	ON tz030m.cd_hansya = tec05g.cd_hansya
	AND tz030m.cd_kaisya = tec05g.cd_kaisya
	AND tz030m.cd_okyaku = tec05g.cd_okyaku
	AND tz030m.cd_norikusi = tec05g.cd_norikusi
	AND tz030m.kb_nosyasyu = tec05g.kb_nosyasyu
	AND tz030m.cd_nogyotai = tec05g.cd_nogyotai
	AND tz030m.no_noseiri = tec05g.no_noseiri
--Ｍ陸支コードＤＢ
LEFT JOIN ai21rep_ve_dx.tbv0013m t0013m  
	ON tz030m.cd_hansya = t0013m.cd_hansya
	AND tz030m.cd_kaisya = t0013m.cd_kaisya
	AND REPLACE(REPLACE(tz030m.cd_norikusi, ' ', ''), '　', '') = t0013m.cd_rikusi
LIMIT 0;

-- [059/099] level=0 target=gold.vbi012001_en
-- Gold dependencies: none
-- Source file: 012_SMB空き枠カレンダー（ストール軸管理向け）/smbcalendar_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi012001_en AS
select
	--日付
	bt.dd_date,
	--日付_月
	trunc(bt.dd_date, 'MM') as dd_month,
	--日付_yyyy/MM/dd
	from_timestamp(bt.dd_date, 'yyyy/MM/dd') as `dd_yyyy/MM/dd`,
	--日付_yyyyMMdd
	from_timestamp(bt.dd_date, 'yyyyMMdd') as `dd_yyyyMMdd`,
	--日付_曜日
	concat(from_timestamp(bt.dd_date, 'MM/dd'), CHR(10), '(',
		case dayofweek(bt.dd_date)
			when 1 then '日'
			when 2 then '月'
			when 3 then '火'
			when 4 then '水'
			when 5 then '木'
			when 6 then '金'
			when 7 then '土'
		end,
	')') as dd_week,
	--先週/来週
	bt.kb_senshuraishu
from (
	select
		days_add(cast(from_utc_timestamp(utc_timestamp(), 'JST') as date), i) as dd_date,
		if (i < 7, "先週", "来週") as kb_senshuraishu
	from(
		VALUES((0 AS i),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13))
	) dd
) bt
LIMIT 0;

-- [060/099] level=1 target=gold.vbi012001
-- Gold dependencies: gold.vbi012001_en
-- Source file: 012_SMB空き枠カレンダー（ストール軸管理向け）/smbcalendar_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi012001 AS
select
	--日付
	dd_date as `日付`,
	--日付_月
	dd_month as `日付_月`,
	--日付_yyyy/MM/dd
	`dd_yyyy/MM/dd` as `日付_yyyy/MM/dd`,
	--日付_yyyyMMdd
	`dd_yyyyMMdd` as `日付_yyyyMMdd`,
	--日付_曜日
	dd_week as `日付_曜日`,
	--先週/来週
	kb_senshuraishu as `先週/来週`
from gold.vbi012001_en
LIMIT 0;

-- [061/099] level=0 target=gold.vbi012002
-- Gold dependencies: none
-- Source file: 012_SMB空き枠カレンダー（ストール軸管理向け）/smbcalendar_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi012002 AS
select
	--販社コード
	t3002m.cd_hansya,
	--会社コード
	t3002m.cd_kaisya,
	--店舗コード
	t3002m.cd_tenpo,
	--ストール番号
	t3002m.no_stall,
	--ストール名称
	t3002m.mj_stallmei,
	--ストール選択
	concat(cast(t3002m.no_stall as string), '　', t3002m.mj_stallmei) as kb_stallsentaku,
	--販社会社店舗コード
	concat(t3002m.cd_hansya, t3002m.cd_kaisya, t3002m.cd_tenpo) as `cd_hansyakaisyatenpo`,
	--ソート順
	t9003m.mj_sortjyun
-- ストール集計対象一覧
from dx_ve.tbi003002m t3002m
-- SMB異常管理ボード集計対象店舗一覧
left semi join dx_ve.tbi003001m t3001m on t3001m.cd_hansya = t3002m.cd_hansya
and t3001m.cd_kaisya = t3002m.cd_kaisya
and t3001m.cd_tenpo = t3002m.cd_tenpo
-- 店舗表示設定
inner join dx_ve.tbi999003m t9003m on t9003m.cd_hansya = t3002m.cd_hansya
and t9003m.cd_kaisya = t3002m.cd_kaisya
and t9003m.cd_tenpo = t3002m.cd_tenpo
and t9003m.mj_cyohyoid = '012'
and t9003m.kb_tenji = 1
where t3002m.kb_shuukeitaishou = '1'
-- ISERROR(SEARCH("コント", [ストール名称], 1))
and instr(t3002m.mj_stallmei, 'コント') = 0
-- ISERROR(SEARCH("外注", [ストール名称], 1))
and instr(t3002m.mj_stallmei, '外注') = 0
LIMIT 0;

-- [062/099] level=1 target=gold.vbi012003
-- Gold dependencies: gold.vbi012001_en, gold.vbi012002
-- Source file: 012_SMB空き枠カレンダー（ストール軸管理向け）/smbcalendar_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi012003 AS
with t275m as (
	select
		--販社コード
		t275m.cd_hansya,
		--会社コード
		t275m.cd_kaisya,
		--店舗コード
		t275m.cd_tenpo,
		--稼動日付
		v12001.dd_date as dd_kado,
		--稼動区分
		case day(v12001.dd_date)
			when 1 then t275m.kb_kado1
			when 2 then t275m.kb_kado2
			when 3 then t275m.kb_kado3
			when 4 then t275m.kb_kado4
			when 5 then t275m.kb_kado5
			when 6 then t275m.kb_kado6
			when 7 then t275m.kb_kado7
			when 8 then t275m.kb_kado8
			when 9 then t275m.kb_kado9
			when 10 then t275m.kb_kado10
			when 11 then t275m.kb_kado11
			when 12 then t275m.kb_kado12
			when 13 then t275m.kb_kado13
			when 14 then t275m.kb_kado14
			when 15 then t275m.kb_kado15
			when 16 then t275m.kb_kado16
			when 17 then t275m.kb_kado17
			when 18 then t275m.kb_kado18
			when 19 then t275m.kb_kado19
			when 20 then t275m.kb_kado20
			when 21 then t275m.kb_kado21
			when 22 then t275m.kb_kado22
			when 23 then t275m.kb_kado23
			when 24 then t275m.kb_kado24
			when 25 then t275m.kb_kado25
			when 26 then t275m.kb_kado26
			when 27 then t275m.kb_kado27
			when 28 then t275m.kb_kado28
			when 29 then t275m.kb_kado29
			when 30 then t275m.kb_kado30
			when 31 then t275m.kb_kado31
		end as kb_kado
	-- 店舗稼動日程ＤＢ
	from ai21rep_ve_stg_kudu.tbfy275m t275m
	--ストールマスタ_充足率対象ＤＢ
	inner join gold.vbi012001_en v12001 on v12001.dd_month = t275m.dd_kadoyymm
)
select
	--販社コード
	v12002.cd_hansya,
	--会社コード
	v12002.cd_kaisya,
	--店舗コード
	v12002.cd_tenpo,
	--ストール番号
	v12002.no_stall,
	--ストール名称
	v12002.mj_stallmei,
	--ストール選択
	v12002.kb_stallsentaku,
	--休憩区分
	if(
		-- 店舗休みの場合、休みとみなす
		t275m.kb_kado not in('1', '9')
		-- 店舗休みではない場合、ストールの[非稼動区分]が1でない場合、稼働とみなす
		or t002m.kb_hikado = '1',
		1,
		0
	) as kb_kyukei,
	--日付
	v12001.dd_date
-- ストールマスタ_充足率対象ＤＢ
from gold.vbi012002 v12002
cross join gold.vbi012001_en v12001
-- 店舗稼動日程ＤＢ
left join t275m on t275m.cd_hansya = v12002.cd_hansya
and t275m.cd_kaisya = v12002.cd_kaisya
and t275m.cd_tenpo = v12002.cd_tenpo
and t275m.dd_kado = v12001.dd_date
and t275m.kb_kado <> 'Z'
-- ストール稼動予定マスタＤＢ
left join ai21rep_ve_stg_kudu.tbsa002m t002m on t002m.cd_hansya = v12002.cd_hansya
and t002m.cd_kaisya = v12002.cd_kaisya
and t002m.cd_tenpo = v12002.cd_tenpo
and t002m.no_stall = v12002.no_stall
and t002m.dd_hikado = v12001.`dd_yyyyMMdd`
LIMIT 0;

-- [063/099] level=1 target=gold.vbi012004
-- Gold dependencies: gold.vbi012002
-- Source file: 012_SMB空き枠カレンダー（ストール軸管理向け）/smbcalendar_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi012004 AS
select
	--販社コード
	t005g.cd_hansya,
	--会社コード
	t005g.cd_kaisya,
	--店舗コード
	t005g.cd_tenpo,
	--ストール番号
	t005g.no_stall,
	--使用開始日時
	t005g.dt_siyost,
	--使用終了日時
	t005g.dt_siyoed
-- ストール予約明細ＤＢ
from ai21rep_ve_stg_kudu.tbsa005g t005g
-- ストールマスタ_充足率対象ＤＢ
left semi join gold.vbi012002 v3002 on v3002.cd_hansya = t005g.cd_hansya
and v3002.cd_kaisya = t005g.cd_kaisya
and v3002.cd_tenpo = t005g.cd_tenpo
and v3002.no_stall = t005g.no_stall
-- [ＳＭＢ削除フラグ] = "0"
where t005g.mj_sakujyo = '0'
--使用開始日時が現在の日付から14日以内の範囲
and ((t005g.dt_siyost >= cast(from_utc_timestamp(utc_timestamp(), 'JST') as date) and t005g.dt_siyost < days_add(cast(from_utc_timestamp(utc_timestamp(), 'JST') as date), 14))
--使用終了日時が現在の日付から14日以内の範囲
or (t005g.dt_siyoed >= cast(from_utc_timestamp(utc_timestamp(), 'JST') as date) and t005g.dt_siyoed < days_add(cast(from_utc_timestamp(utc_timestamp(), 'JST') as date), 14)))
union all
select
	tb05s.cd_hansya,
	tb05s.cd_kaisya,
	tb05s.cd_tenpo,
	tb05s.no_stall,
	tb05s.dt_siyost,
	tb05s.dt_siyoed
-- ストール予約明細退避ＤＢ
from ai21rep_ve_stg_kudu.tbsab05s tb05s
-- ストールマスタ_充足率対象ＤＢ
left semi join gold.vbi012002 v3002 on v3002.cd_hansya = tb05s.cd_hansya
and v3002.cd_kaisya = tb05s.cd_kaisya
and v3002.cd_tenpo = tb05s.cd_tenpo
and v3002.no_stall = tb05s.no_stall
-- ストール予約明細ＤＢ
left anti join ai21rep_ve_stg_kudu.tbsa005g t005g on t005g.cd_hansya = tb05s.cd_hansya
and t005g.cd_kaisya = tb05s.cd_kaisya
and t005g.cd_tenpo = tb05s.cd_tenpo
and t005g.no_yoyakuid = tb05s.no_yoyakuid
and t005g.no_stall = tb05s.no_stall
and t005g.mj_sakujyo = '0'
-- ストール予約明細退避ＤＢ，重複判別
left anti join ai21rep_ve_stg_kudu.tbsab05s tb05s2 on tb05s2.cd_hansya = tb05s.cd_hansya
and tb05s2.cd_kaisya = tb05s.cd_kaisya
and tb05s2.cd_tenpo = tb05s.cd_tenpo
and tb05s2.no_yoyakuid = tb05s.no_yoyakuid
and tb05s2.cd_yoykmsai = tb05s.cd_yoykmsai
and tb05s2.no_stall = tb05s.no_stall
and tb05s2.mj_sakujyo = '0'
and tb05s2.no_msaiedmx <> tb05s.no_msaiedmx
-- [ＳＭＢ削除フラグ] = "0"
where tb05s.mj_sakujyo = '0'
--使用開始日時が現在の日付から14日以内の範囲
and ((tb05s.dt_siyost >= cast(from_utc_timestamp(utc_timestamp(), 'JST') as date) and tb05s.dt_siyost < days_add(cast(from_utc_timestamp(utc_timestamp(), 'JST') as date), 14))
--使用終了日時が現在の日付から14日以内の範囲
or (tb05s.dt_siyoed >= cast(from_utc_timestamp(utc_timestamp(), 'JST') as date) and tb05s.dt_siyoed < days_add(cast(from_utc_timestamp(utc_timestamp(), 'JST') as date), 14)))
LIMIT 0;

-- [064/099] level=2 target=gold.vbi012005
-- Gold dependencies: gold.vbi012003, gold.vbi012004
-- Source file: 012_SMB空き枠カレンダー（ストール軸管理向け）/smbcalendar_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi012005 AS
select
	--販社コード
	v12003.cd_hansya as `販社コード`,
	--会社コード
	v12003.cd_kaisya as `会社コード`,
	--店舗コード
	v12003.cd_tenpo as `店舗コード`,
	--販社会社店舗コード
	concat(v12003.cd_hansya, v12003.cd_kaisya, v12003.cd_tenpo) as `販社会社店舗コード`,
	--ストール番号
	v12003.no_stall as `ストール番号`,
	--ストール名称
	v12003.mj_stallmei as `ストール名称`,
	--ストール選択
	v12003.kb_stallsentaku as `ストール選択`,
	--日付
	v12003.dd_date as `日付`,
	--時刻
	bt.tm_jikoku as `時刻`,
	--予約不可フラグ
	if (
		v12003.kb_kyukei = 1,
		1,
		case bt.tm_jikoku
			when '08:00' then if (minutes_add(v12003.dd_date, 510) > v12004.dt_siyost and minutes_add(v12003.dd_date, 480) < v12004.dt_siyoed, 1, 0)
			when '08:30' then if (minutes_add(v12003.dd_date, 540) > v12004.dt_siyost and minutes_add(v12003.dd_date, 510) < v12004.dt_siyoed, 1, 0)
			when '09:00' then if (minutes_add(v12003.dd_date, 570) > v12004.dt_siyost and minutes_add(v12003.dd_date, 540) < v12004.dt_siyoed, 1, 0)
			when '09:30' then if (minutes_add(v12003.dd_date, 600) > v12004.dt_siyost and minutes_add(v12003.dd_date, 570) < v12004.dt_siyoed, 1, 0)
			when '10:00' then if (minutes_add(v12003.dd_date, 630) > v12004.dt_siyost and minutes_add(v12003.dd_date, 600) < v12004.dt_siyoed, 1, 0)
			when '10:30' then if (minutes_add(v12003.dd_date, 660) > v12004.dt_siyost and minutes_add(v12003.dd_date, 630) < v12004.dt_siyoed, 1, 0)
			when '11:00' then if (minutes_add(v12003.dd_date, 690) > v12004.dt_siyost and minutes_add(v12003.dd_date, 660) < v12004.dt_siyoed, 1, 0)
			when '11:30' then if (minutes_add(v12003.dd_date, 720) > v12004.dt_siyost and minutes_add(v12003.dd_date, 690) < v12004.dt_siyoed, 1, 0)
			when '12:00' then if (minutes_add(v12003.dd_date, 750) > v12004.dt_siyost and minutes_add(v12003.dd_date, 720) < v12004.dt_siyoed, 1, 0)
			when '12:30' then if (minutes_add(v12003.dd_date, 780) > v12004.dt_siyost and minutes_add(v12003.dd_date, 750) < v12004.dt_siyoed, 1, 0)
			when '13:00' then if (minutes_add(v12003.dd_date, 810) > v12004.dt_siyost and minutes_add(v12003.dd_date, 780) < v12004.dt_siyoed, 1, 0)
			when '13:30' then if (minutes_add(v12003.dd_date, 840) > v12004.dt_siyost and minutes_add(v12003.dd_date, 810) < v12004.dt_siyoed, 1, 0)
			when '14:00' then if (minutes_add(v12003.dd_date, 870) > v12004.dt_siyost and minutes_add(v12003.dd_date, 840) < v12004.dt_siyoed, 1, 0)
			when '14:30' then if (minutes_add(v12003.dd_date, 900) > v12004.dt_siyost and minutes_add(v12003.dd_date, 870) < v12004.dt_siyoed, 1, 0)
			when '15:00' then if (minutes_add(v12003.dd_date, 930) > v12004.dt_siyost and minutes_add(v12003.dd_date, 900) < v12004.dt_siyoed, 1, 0)
			when '15:30' then if (minutes_add(v12003.dd_date, 960) > v12004.dt_siyost and minutes_add(v12003.dd_date, 930) < v12004.dt_siyoed, 1, 0)
			when '16:00' then if (minutes_add(v12003.dd_date, 990) > v12004.dt_siyost and minutes_add(v12003.dd_date, 960) < v12004.dt_siyoed, 1, 0)
			when '16:30' then if (minutes_add(v12003.dd_date, 1020) > v12004.dt_siyost and minutes_add(v12003.dd_date, 990) < v12004.dt_siyoed, 1, 0)
			when '17:00' then if (minutes_add(v12003.dd_date, 1050) > v12004.dt_siyost and minutes_add(v12003.dd_date, 1020) < v12004.dt_siyoed, 1, 0)
			when '17:30' then if (minutes_add(v12003.dd_date, 1080) > v12004.dt_siyost and minutes_add(v12003.dd_date, 1050) < v12004.dt_siyoed, 1, 0)
			when '18:00' then if (minutes_add(v12003.dd_date, 1110) > v12004.dt_siyost and minutes_add(v12003.dd_date, 1080) < v12004.dt_siyoed, 1, 0)
			when '18:30' then if (minutes_add(v12003.dd_date, 1140) > v12004.dt_siyost and minutes_add(v12003.dd_date, 1110) < v12004.dt_siyoed, 1, 0)
			when '19:00' then if (minutes_add(v12003.dd_date, 1170) > v12004.dt_siyost and minutes_add(v12003.dd_date, 1140) < v12004.dt_siyoed, 1, 0)
			when '19:30' then if (minutes_add(v12003.dd_date, 1200) > v12004.dt_siyost and minutes_add(v12003.dd_date, 1170) < v12004.dt_siyoed, 1, 0)
		end
	) as `予約不可フラグ`
--ストールマスタ_充足率対象ＤＢ_14日
from gold.vbi012003 v12003
-- SMB異常管理ボード集計対象店舗一覧
inner join dx_ve.tbi003001m t3001m on t3001m.cd_hansya = v12003.cd_hansya
and t3001m.cd_kaisya = v12003.cd_kaisya
and t3001m.cd_tenpo = v12003.cd_tenpo
--tbsa005g_ストール予約明細ＤＢ_退避含_14日
left join gold.vbi012004 v12004 on v12004.cd_hansya = v12003.cd_hansya
and v12004.cd_kaisya = v12003.cd_kaisya
and v12004.cd_tenpo = v12003.cd_tenpo
and v12004.no_stall = v12003.no_stall
and ((v12004.dt_siyost >= v12003.dd_date and v12004.dt_siyost < days_add(v12003.dd_date, 1))
	or (v12004.dt_siyoed >= v12003.dd_date and v12004.dt_siyoed < days_add(v12003.dd_date, 1))
)
and v12003.kb_kyukei = 0
cross join (
	VALUES(('08:00' as tm_jikoku), ('08:30'), ('09:00'), ('09:30'), ('10:00'), ('10:30'), ('11:00'), ('11:30'), ('12:00'), ('12:30'), ('13:00'), ('13:30'), ('14:00'), ('14:30'), ('15:00'), ('15:30'), ('16:00'), ('16:30'), ('17:00'), ('17:30'), ('18:00'), ('18:30'), ('19:00'), ('19:30'))
) bt
--開店時間の前五桁 <= 時刻
where left(t3001m.tm_kaiten, 5) <= bt.tm_jikoku
--閉店時間の前五桁 >= 時刻
and left(t3001m.tm_heiten, 5) > bt.tm_jikoku
LIMIT 0;

-- [065/099] level=1 target=gold.vbi012006
-- Gold dependencies: gold.vbi012002
-- Source file: 012_SMB空き枠カレンダー（ストール軸管理向け）/smbcalendar_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi012006 AS
select
	--ソート順
	row_number() over(partition by v12002.cd_hansya, v12002.cd_kaisya order by v12002.mj_sortjyun, v12002.cd_tenpo) as `ソート順`,
	--販社コード
	v12002.cd_hansya as `販社コード`,
	--会社コード
	v12002.cd_kaisya as `会社コード`,
	--店舗コード
	v12002.cd_tenpo as `店舗コード`,
	--店舗名
	regexp_replace(t201m.kj_tenpomei, '　+$', '') as `店舗名`,
	--販社会社店舗コード
	concat(v12002.cd_hansya, v12002.cd_kaisya, v12002.cd_tenpo) as `販社会社店舗コード`
--ストールマスタ_充足率対象ＤＢ
from gold.vbi012002 v12002
-- 共通店舗ＤＢ
left join ai21rep_ve_stg_kudu.tbv0201m t201m on t201m.cd_hansya = v12002.cd_hansya
and t201m.cd_kaisya = v12002.cd_kaisya
and t201m.cd_tenpo = v12002.cd_tenpo
group by v12002.cd_hansya, v12002.cd_kaisya, v12002.cd_tenpo, t201m.kj_tenpomei, v12002.mj_sortjyun
LIMIT 0;

-- [066/099] level=0 target=gold.VBI016001
-- Gold dependencies: none
-- Source file: 016_新車受注分析/vbi016001-vbi016011_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI016001 AS
SELECT
	販社コード, --販社コード
	会社コード, --会社コード
	新車車名, --新車車名
	受注計上日, --受注計上日
	CASE
		WHEN FROM_TIMESTAMP(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'yyyyMM') = FROM_TIMESTAMP(受注計上日, 'yyyyMM')
		THEN '前月'
		WHEN FROM_TIMESTAMP(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'yyyyMM') = FROM_TIMESTAMP(受注計上日, 'yyyyMM')
		THEN '当月'
		ELSE
		' '
	END AS 月別, --月別
	CONCAT(新車車名, FROM_TIMESTAMP(受注計上日, 'yyyyMMdd')) AS 車名受注日,  --車名受注日
	DENSE_RANK() OVER (PARTITION BY 販社コード, 会社コード ORDER BY ソート順, 新車車名コード ) AS ソート順, --ソート順
	台数 --台数
FROM
	(
	SELECT
		tbba001g.cd_hansya AS 販社コード,  --販社コード
		tbba001g.cd_kaisya AS 会社コード,  --会社コード
		CAST(tbba001g.dd_jucyuke AS DATE) AS 受注計上日,  --受注計上日
		tbbf001m.kj_kurumame AS 新車車名, --新車車名
		MIN(sort_car.mj_sortjyun) AS ソート順, --ソート順
		MIN(sort_car.cd_ncsyamei) AS 新車車名コード, --新車車名コード
		COUNT(1) AS 台数  --台数
	FROM
		ai21rep_ve_dx.tbba001g tbba001g --新車受注基本情報ＤＢ
	LEFT SEMI JOIN dx_ve.tbi999003m tbi999003m --店舗展示設定
	ON
		tbba001g.cd_hansya = tbi999003m.cd_hansya
		AND tbba001g.cd_kaisya = tbi999003m.cd_kaisya
		AND tbba001g.cd_tenpo = tbi999003m.cd_tenpo
		AND tbi999003m.mj_cyohyoid = '016'
		AND tbi999003m.kb_tenji = 1
	LEFT JOIN ai21rep_ve_dx.tbbf008m tbbf008m --車両スペック２ＤＢ
    ON
		tbba001g.cd_hansya = tbbf008m.cd_hansya
		AND tbba001g.cd_kaisya = tbbf008m.cd_kaisya
		AND tbba001g.mj_sinkysed = tbbf008m.mj_sinkysed
		AND tbba001g.mj_gaihansy = tbbf008m.cd_spec
		AND tbba001g.mj_hantenkt = tbbf008m.mj_hantenkt
		AND tbbf008m.kb_spec = 'G'
	LEFT JOIN ai21rep_ve_dx.tbbf001m tbbf001m --車名ＤＢ 
    ON
		tbbf001m.cd_kaisya = tbbf008m.cd_kaisya
		AND tbbf001m.cd_hansya = tbbf008m.cd_hansya
		AND tbbf001m.cd_ncsyamei = tbbf008m.mj_syamei
	INNER JOIN dx_ve.tbi999008m tbi999008m --車種展示設定
	ON
		tbbf001m.cd_hansya = tbi999008m.cd_hansya
		AND tbbf001m.cd_kaisya = tbi999008m.cd_kaisya
		AND tbbf001m.cd_ncsyamei = tbi999008m.cd_ncsyamei
		AND tbi999008m.kb_tenji = 1
	LEFT JOIN (
		SELECT	
				 tbi999008m.cd_hansya, --販社コード
				 tbi999008m.cd_kaisya, --会社コード
				 TRIM(tbi999008m.kj_kurumame) AS kj_kurumame, --漢字車名
				 MIN(tbi999008m.mj_sortjyun) AS mj_sortjyun, --ソート順
				 MIN(tbi999008m.cd_ncsyamei) AS cd_ncsyamei --新車車名コード
		FROM
			dx_ve.tbi999008m tbi999008m --車種展示設定
		WHERE
			tbi999008m.kb_tenji = 1
		GROUP BY 
			tbi999008m.cd_hansya,
			tbi999008m.cd_kaisya,
			TRIM(tbi999008m.kj_kurumame)
		) sort_car
	ON
		tbbf001m.cd_hansya = sort_car.cd_hansya
		AND tbbf001m.cd_kaisya = sort_car.cd_kaisya
		AND TRIM(tbbf001m.kj_kurumame) = TRIM(sort_car.kj_kurumame)
		--売上取消計上日と取消日=NULL、受注計上日!=NULL
	WHERE
		tbba001g.dd_uritrkkj IS NULL
		AND tbba001g.dd_torikesi IS NULL
		AND tbba001g.dd_jucyuke IS NOT NULL
	GROUP BY
		tbba001g.cd_hansya,
		tbba001g.cd_kaisya,
		CAST(tbba001g.dd_jucyuke AS DATE),
		新車車名
) t
UNION ALL
SELECT
	'固定' AS 販社コード, --販社コード
	'' AS 会社コード, --会社コード
	'合計' AS 新車車名, --新車車名
	NULL AS 受注計上日, --受注計上日
	NULL AS 月別, --月別
	NULL AS 車名受注日, --車名受注日
	-1 AS ソート順, --ソート順
	0 AS 台数 --台数
LIMIT 0;

-- [067/099] level=0 target=gold.VBI016002
-- Gold dependencies: none
-- Source file: 016_新車受注分析/vbi016001-vbi016011_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI016002 AS
SELECT
	tbbf008m.cd_hansya AS 販社コード, --販社コード
	tbbf008m.cd_kaisya AS 会社コード, --会社コード
	tbbf007m.kn_hinmei AS 品名カナ, --品名カナ
	CONCAT(tbbf001m.kj_kurumame, FROM_TIMESTAMP(tbba001g.dd_jucyuke, 'yyyyMMdd')) AS 車名受注日, --車名受注日
	tbbf001m.kj_kurumame AS 新車車名,	 --車名受注日
	tbv0229m.mj_guredo AS グレード, --グレード
	SUM(IF(tbba001g.cd_hansya IS NOT NULL AND tbi999003m.cd_hansya IS NOT NULL
   			AND tbba001g.dd_uritrkkj IS NULL AND tbba001g.dd_torikesi IS NULL AND tbba001g.dd_jucyuke IS NOT NULL, 1, 0)) AS 台数 --台数
FROM
	ai21rep_ve_dx.tbbf008m tbbf008m	--車両スペック２ＤＢ
INNER JOIN ai21rep_ve_dx.tbbf001m tbbf001m	--車名ＤＢ 
    ON
	tbbf001m.cd_kaisya = tbbf008m.cd_kaisya
	AND tbbf001m.cd_hansya = tbbf008m.cd_hansya
	AND tbbf001m.cd_ncsyamei = tbbf008m.mj_syamei
	AND tbbf008m.kb_spec = 'G'
LEFT JOIN ai21rep_ve_dx.tbbf007m tbbf007m	--車両スペックＤＢ
    ON
	tbbf007m.cd_hansya = tbbf008m.cd_hansya
	AND tbbf007m.cd_kaisya = tbbf008m.cd_kaisya
	AND tbbf007m.mj_syamei = tbbf008m.mj_syamei
	AND tbbf007m.kb_spec = tbbf008m.kb_spec
	AND tbbf007m.cd_spec = tbbf008m.cd_spec
	AND tbbf007m.no_hinmei = tbbf008m.no_hinmei
LEFT JOIN ai21rep_ve_dx.tbba001g tbba001g	--新車受注基本情報ＤＢ
    ON
	tbba001g.cd_kaisya = tbbf008m.cd_kaisya
	AND tbba001g.cd_hansya = tbbf008m.cd_hansya
	AND tbba001g.mj_sinkysed = tbbf008m.mj_sinkysed
	AND tbba001g.mj_gaihansy = tbbf008m.cd_spec
	AND tbba001g.mj_hantenkt = tbbf008m.mj_hantenkt
LEFT JOIN ai21rep_ve_dx.tbv0229m tbv0229m	--指定類別ＤＢ
    ON
	tbv0229m.cd_hansya = tbba001g.cd_hansya
	AND tbv0229m.cd_kaisya = tbba001g.cd_kaisya
	AND tbv0229m.no_siteruib = tbba001g.no_siteruib
LEFT JOIN dx_ve.tbi999003m tbi999003m	--店舗展示設定
	ON
	tbba001g.cd_hansya = tbi999003m.cd_hansya
	AND tbba001g.cd_kaisya = tbi999003m.cd_kaisya
	AND tbba001g.cd_tenpo = tbi999003m.cd_tenpo
	AND tbi999003m.mj_cyohyoid = '016'
	AND tbi999003m.kb_tenji = 1
LEFT SEMI JOIN dx_ve.tbi999008m tbi999008m	--車種展示設定
	ON
	tbbf001m.cd_hansya = tbi999008m.cd_hansya
	AND tbbf001m.cd_kaisya = tbi999008m.cd_kaisya
	AND tbbf001m.cd_ncsyamei = tbi999008m.cd_ncsyamei
	AND tbi999008m.kb_tenji = 1
GROUP BY	
	販社コード,
	会社コード,
	品名カナ,
	車名受注日,
	新車車名,
	グレード
LIMIT 0;

-- [068/099] level=0 target=gold.VBI016003
-- Gold dependencies: none
-- Source file: 016_新車受注分析/vbi016001-vbi016011_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI016003 AS
SELECT
	main.cd_hansya AS 販社コード, --販社コード
	main.cd_kaisya AS 会社コード, --会社コード
	main.kj_tentanms AS 店舗短縮名称, --店舗短縮名称
	main.kj_kurumame AS 新車車名 , --新車車名
	main.cd_tenpo AS 店舗コード, --店舗コード
	CONCAT(kj_kurumame, from_timestamp(dd_jucyuke, 'yyyyMMdd')) AS 車名受注日, --車名受注日
	RANK() OVER (PARTITION BY cd_hansya, cd_kaisya ORDER BY mj_sortjyun , cd_tenpo) AS ソート順, --ソート順
	daisu AS 台数
FROM
	(
	SELECT
		main1.cd_hansya, --販社コード
		main1.cd_kaisya, --会社コード
		main1.cd_tenpo, --店舗コード
		main1.kj_tentanms, --店舗短縮名称
		main1.dd_jucyuke, --受注計上日
		main1.kj_kurumame, --新車車名
		sort_sub.mj_sortjyun, --ソート順
		SUM(daisu) AS daisu --台数
	FROM
		(
		SELECT
			t201m.cd_hansya, --販社コード
			t201m.cd_kaisya, --会社コード
			t201m.cd_tenpo, --店舗コード
			t201m.kj_tenpomei, --店舗名称
			t201m.kj_tentanms, --店舗短縮名称
			CAST(tbba001g.dd_jucyuke AS DATE) AS dd_jucyuke, --受注計上日
			TBBF001M.kj_kurumame AS kj_kurumame, --新車車名
			COUNT(tbba001g.cd_hansya) AS daisu --台数
		FROM
			 ai21rep_ve_dx.tbv0201m t201m  --共通店舗ＤＢ
		LEFT SEMI JOIN dx_ve.tbi999003m tbi999003m  --店舗展示設定
			ON
			t201m.cd_hansya = tbi999003m.cd_hansya
			AND t201m.cd_kaisya = tbi999003m.cd_kaisya
			AND t201m.cd_tenpo = tbi999003m.cd_tenpo
			AND tbi999003m.mj_cyohyoid = '016'
			AND tbi999003m.kb_tenji = 1
		LEFT JOIN ai21rep_ve_dx.tbba001g tbba001g			--新車受注基本情報ＤＢ
		ON
			t201m.cd_hansya = tbba001g.cd_hansya
			AND t201m.cd_kaisya = tbba001g.cd_kaisya
			AND t201m.cd_tenpo = tbba001g.cd_tenpo
		LEFT JOIN ai21rep_ve_dx.tbbf008m TBBF008M			--車両スペック２ＤＢ
		    ON
			tbba001g.cd_kaisya = TBBF008M.cd_kaisya
			AND tbba001g.cd_hansya = TBBF008M.cd_hansya
			AND tbba001g.mj_sinkysed = TBBF008M.mj_sinkysed
			AND tbba001g.mj_gaihansy = TBBF008M.cd_spec
			AND tbba001g.mj_hantenkt = TBBF008M.mj_hantenkt
			AND TBBF008M.kb_spec = 'G'
		LEFT JOIN ai21rep_ve_dx.tbbf001m TBBF001M			--車名ＤＢ 
	    	ON
			TBBF001M.cd_kaisya = TBBF008M.cd_kaisya
			AND TBBF001M.cd_hansya = TBBF008M.cd_hansya
			AND TBBF001M.cd_ncsyamei = TBBF008M.mj_syamei
		LEFT SEMI JOIN dx_ve.tbi999008m tbi999008m			--車種展示設定
			ON
			TBBF001M.cd_hansya = tbi999008m.cd_hansya
			AND TBBF001M.cd_kaisya = tbi999008m.cd_kaisya
			AND TBBF001M.cd_ncsyamei = tbi999008m.cd_ncsyamei
			AND tbi999008m.kb_tenji = 1
		WHERE
			--売上取消計上日と取消日=NULL
			tbba001g.dd_uritrkkj IS NULL
			AND tbba001g.dd_torikesi IS NULL
			AND tbba001g.dd_jucyuke IS NOT NULL
		GROUP BY
			t201m.cd_hansya,
			t201m.cd_kaisya,
			t201m.cd_tenpo,
			kj_tenpomei,
			kj_tentanms,
			CAST(tbba001g.dd_jucyuke AS DATE),
			kj_kurumame
		HAVING NOT (NVL(t201m.kj_tenpomei, '') LIKE '%廃）%'
				AND COUNT(tbba001g.cd_hansya)= 0)
	) main1
	LEFT JOIN (
		SELECT
			kj_tentanms, --店舗短縮名称
			t201m_2.cd_hansya, --販社コード
			t201m_2.cd_kaisya, --会社コード
			MIN(tbi999003m.mj_sortjyun) AS mj_sortjyun --ソート順
		FROM
			ai21rep_ve_dx.tbv0201m t201m_2
		INNER JOIN dx_ve.tbi999003m tbi999003m --店舗展示設定
			ON
			t201m_2.cd_hansya = tbi999003m.cd_hansya
			AND t201m_2.cd_kaisya = tbi999003m.cd_kaisya
			AND t201m_2.cd_tenpo = tbi999003m.cd_tenpo
			AND tbi999003m.mj_cyohyoid = '016'
			AND tbi999003m.kb_tenji = 1
		GROUP BY 
			t201m_2.cd_hansya,
			t201m_2.cd_kaisya,
			kj_tentanms		
	) sort_sub
	ON
		main1.cd_hansya = sort_sub.cd_hansya
		AND main1.cd_kaisya = sort_sub.cd_kaisya
		AND main1.kj_tentanms = sort_sub.kj_tentanms
	GROUP BY
		main1.cd_hansya,
		main1.cd_kaisya,
		main1.cd_tenpo,
		main1.kj_tentanms,
		main1.dd_jucyuke,
		sort_sub.mj_sortjyun,
		main1.kj_kurumame
 ) main
LIMIT 0;

-- [069/099] level=0 target=gold.VBI016004
-- Gold dependencies: none
-- Source file: 016_新車受注分析/vbi016001-vbi016011_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI016004 AS
SELECT
	販社コード, --販社コード
	会社コード, --会社コード
	新車車名, --新車車名
	法人個人区分, --法人個人区分
	法人個人区分ソート順, --法人個人区分ソート順
	年齢別, --年齢別
	商談動機, --商談動機
	業直区分, --業直区分
	支払区分, --支払区分
	CONCAT(新車車名,from_timestamp(受注計上日, 'yyyyMMdd')) AS 車名受注日, --車名受注日
	COUNT(1) AS 台数, --台数
	SUM(受注台数) AS 受注台数 --受注台数
FROM
(
SELECT
	tbba001g.cd_hansya AS 販社コード, --販社コード
	tbba001g.cd_kaisya AS 会社コード, --会社コード
	CASE WHEN tbba051g.kb_seibetu ='1' THEN '男' WHEN tbba051g.kb_seibetu ='2' THEN '女' WHEN tbba051g.kb_seibetu = '3' THEN '法人' ELSE NULL END AS 法人個人区分, --法人個人区分
	CASE WHEN tbba051g.kb_seibetu ='1' THEN 1 WHEN tbba051g.kb_seibetu ='2' THEN 2 WHEN tbba051g.kb_seibetu = '3' THEN 3 ELSE 4 END AS 法人個人区分ソート順, --法人個人区分ソート順
	CASE WHEN tbba051g.nu_nenrei >=60 THEN '60歳以上' 
		WHEN tbba051g.nu_nenrei >=50 THEN '50歳代' 
		WHEN tbba051g.nu_nenrei >=40 THEN '40歳代' 
		WHEN tbba051g.nu_nenrei >=30 THEN '30歳代' 
		ELSE '29歳以下' 
	END AS 年齢別, --年齢別
	tbbf001m.kj_kurumame AS 新車車名, --新車車名
	tbba001g.dd_jucyuke AS 受注計上日, --受注計上日
	NVL(tbbg068m.答名,'') AS 商談動機, --商談動機
	IF(tbba056g.kb_gyocyok = '1','直','業') AS 業直区分, --業直区分
	REPLACE(TRIM(tbv0231m.mj_kubunnai),'　','') AS  支払区分, --支払区分
	tbba001g.su_juchudai AS 受注台数 --受注台数
FROM
	ai21rep_ve_dx.tbba001g tbba001g --新車受注基本情報ＤＢ 
LEFT SEMI JOIN dx_ve.tbi999003m tbi999003m ON --店舗展示設定
	tbba001g.cd_hansya = tbi999003m.cd_hansya
	AND tbba001g.cd_kaisya = tbi999003m.cd_kaisya
	AND tbba001g.cd_tenpo = tbi999003m.cd_tenpo
	AND tbi999003m.mj_cyohyoid = '016'
	AND tbi999003m.kb_tenji = 1
LEFT JOIN ai21rep_ve_dx.tbbf008m TBBF008M  --車両スペック２ＤＢ
    ON tbba001g.cd_kaisya = TBBF008M.cd_kaisya
    AND tbba001g.cd_hansya = TBBF008M.cd_hansya
    AND tbba001g.mj_sinkysed = TBBF008M.mj_sinkysed
    AND tbba001g.mj_gaihansy  = TBBF008M.cd_spec 
    AND tbba001g.mj_hantenkt  = TBBF008M.mj_hantenkt
    AND TBBF008M.kb_spec = 'G'
LEFT  JOIN ai21rep_ve_dx.tbbf001m tbbf001m  --車名ＤＢ 
    ON tbbf001m.cd_kaisya = TBBF008M.cd_kaisya
    AND tbbf001m.cd_hansya = TBBF008M.cd_hansya
    AND tbbf001m.cd_ncsyamei = TBBF008M.mj_syamei
LEFT SEMI JOIN dx_ve.tbi999008m tbi999008m  --車種展示設定
	ON tbbf001m.cd_hansya = tbi999008m.cd_hansya
	AND tbbf001m.cd_kaisya = tbi999008m.cd_kaisya
	AND tbbf001m.cd_ncsyamei = tbi999008m.cd_ncsyamei
	AND tbi999008m.kb_tenji = 1
LEFT JOIN ai21rep_ve_dx.tbba056g tbba056g  --新車お客様詳細情報DB 
    ON tbba056g.cd_hansya = tbba001g.cd_hansya
    AND tbba056g.cd_kaisya = tbba001g.cd_kaisya
    AND tbba056g.no_cyumon = tbba001g.no_cyumon
    AND TRIM(tbba056g.no_cyumoned) = TRIM(tbba001g.no_cyumoned)
 LEFT JOIN ai21rep_ve_dx.tbba051g tbba051g --新車受注顧客情報ＤＢ
     ON tbba051g.cd_hansya = tbba001g.cd_hansya
    AND tbba051g.cd_kaisya = tbba001g.cd_kaisya
    AND tbba051g.no_cyumon = tbba001g.no_cyumon
    AND TRIM(tbba051g.no_cyumoned) = TRIM(tbba001g.no_cyumoned)
    AND tbba051g.kb_kokyaku = '2'
 LEFT JOIN ai21rep_ve_dx.tbba052g tbba052g --新車受注販売条件情報ＤＢ
     ON tbba052g.cd_hansya = tbba001g.cd_hansya
    AND tbba052g.cd_kaisya = tbba001g.cd_kaisya
    AND tbba052g.no_cyumon = tbba001g.no_cyumon
    AND TRIM(tbba052g.no_cyumoned) = TRIM(tbba001g.no_cyumoned)
 LEFT JOIN ai21rep_ve_dx.tbv0231m tbv0231m --コード区分ＤＢ （車両支払区分）
     ON tbv0231m.cd_hansya = tbba001g.cd_hansya
    AND tbv0231m.cd_kaisya = tbba001g.cd_kaisya
    AND tbv0231m.mj_blockid  = '02'
    AND tbv0231m.mj_kubunid = '0018'
    AND TRIM(tbv0231m.cd_kubun) = tbba052g.kb_siharai
 LEFT JOIN(
 	--受注形態マスタＤＢ 商談動機　
	--販社コード, 会社コード , 問題コード , 検索キー, 答名１ ～ 答名２０	
	SELECT cd_hansya, cd_kaisya, '01' AS searchKey, cd_kotaem1 AS 答名  FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, '02' AS searchKey, cd_kotaem2 AS 答名 FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, '03' AS searchKey, cd_kotaem3 AS 答名 FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, '04' AS searchKey, cd_kotaem4 AS 答名 FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, '05' AS searchKey, cd_kotaem5 AS 答名 FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, '06' AS searchKey, cd_kotaem6 AS 答名 FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, '07' AS searchKey, cd_kotaem7 AS 答名 FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, '08' AS searchKey, cd_kotaem8 AS 答名 FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, '09' AS searchKey, cd_kotaem9 AS 答名 FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, '10' AS searchKey, cd_kotaem10 AS 答名 FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, '11' AS searchKey, cd_kotaem11 AS 答名 FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, '12' AS searchKey, cd_kotaem12 AS 答名 FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, '13' AS searchKey, cd_kotaem13 AS 答名 FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, '14' AS searchKey, cd_kotaem14 AS 答名 FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, '15' AS searchKey, cd_kotaem15 AS 答名 FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, '16' AS searchKey, cd_kotaem16 AS 答名 FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, '17' AS searchKey, cd_kotaem17 AS 答名 FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, '18' AS searchKey, cd_kotaem18 AS 答名 FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, '19' AS searchKey, cd_kotaem19 AS 答名 FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, '20' AS searchKey, cd_kotaem20 AS 答名 FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
 ) tbbg068m 
 	ON tbba056g.mj_jucyuke1=tbbg068m.searchKey
 	AND tbba001g.cd_hansya = tbbg068m.cd_hansya
    AND tbba001g.cd_kaisya = tbbg068m.cd_kaisya
--売上取消計上日と取消日=NULL 受注計上日!=NULL
WHERE tbba001g.dd_uritrkkj IS NULL
	AND tbba001g.dd_torikesi IS NULL
	AND tbba001g.dd_jucyuke IS NOT NULL
	 ) t 
 GROUP BY 
 	販社コード,
	会社コード,
 	新車車名,
 	車名受注日,
	法人個人区分,
	法人個人区分ソート順,
	年齢別,
	商談動機,
	業直区分,
	支払区分
LIMIT 0;

-- [070/099] level=0 target=gold.VBI016005
-- Gold dependencies: none
-- Source file: 016_新車受注分析/vbi016001-vbi016011_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI016005 AS
SELECT
	販社コード, --販社コード
	会社コード, --会社コード
	新車車名, --新車車名
	購入形態, --購入形態
	下取車の年式, --下取車の年式
	下取車の車名, --下取車の車名
	カテゴリー, --カテゴリー
	CONCAT(NVL(カテゴリー, '') , 下取車の車名) AS カテゴリー車名, --カテゴリー車名
	自社他社, --自社他社
	CONCAT(新車車名,from_timestamp(受注計上日, 'yyyyMMdd')) AS 車名受注日, --車名受注日
	SUM(下取台数) AS 下取台数, --下取台数
	COUNT(1) AS 台数 --台数
FROM 
(
SELECT
	tbba001g.cd_hansya AS 販社コード, --販社コード
	tbba001g.cd_kaisya AS 会社コード, --会社コード
	CASE WHEN tbbf001m.kb_syasikib='6' THEN 	--レクサス
		CASE 
		    WHEN tbba056g.mj_jucyuk11  IN ('03', '04') THEN '自社代替'
		    WHEN tbba056g.mj_jucyuk11  = '01' AND NVL(tbba003g_group.sitasu,0) = 0 THEN '新規下取無'
		    WHEN tbba056g.mj_jucyuk11  = '01' AND tbba003g_group.sitasu > 0 THEN '新規下取有'
		    WHEN tbba056g.mj_jucyuk11  IN ('05', '06') THEN '併有他社替'
		    WHEN tbba056g.mj_jucyuk11  = '02' THEN '自社増車'
		    ELSE 'その他'
		END 
	ELSE	
		CASE 
		    WHEN tbba056g.mj_jucyuke4  IN ('03', '04') THEN '自社代替'
		    WHEN tbba056g.mj_jucyuke4  = '01' AND NVL(tbba003g_group.sitasu,0) = 0 THEN '新規下取無'
		    WHEN tbba056g.mj_jucyuke4  = '01' AND tbba003g_group.sitasu > 0 THEN '新規下取有'
		    WHEN tbba056g.mj_jucyuke4  IN ('05', '06') THEN '併有他社替'
		    WHEN tbba056g.mj_jucyuke4  = '02' THEN '自社増車'
		    ELSE 'その他'
		END 
	END AS 購入形態, --購入形態
	IF(tbv0232m.cd_hansya IS NOT NULL, tbba003g_group.sitasu,0) AS 下取台数, --下取台数
	tbbf001m.kj_kurumame AS 新車車名,	--新車車名
	tbba001g.dd_jucyuke AS 受注計上日, --受注計上日
    IF(tbv0232m.cd_maker = '01' AND LEFT(tbv0232m.cd_syamei,1) <> 'L' , 'トヨタ' , '他メーカー' ) AS 自社他社, --自社他社
  	tbv0232m.kj_syamei AS 下取車の車名, --下取車の車名
  	tbv0231m.mj_kubunnai AS カテゴリー,  --カテゴリー
  	(CASE 
    WHEN CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) < (YEAR(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE)) - 8) THEN
      CASE 
        WHEN (YEAR(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE)) - 9) >= 2019 THEN 
          CONCAT('R', LPAD(CAST((YEAR(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE)) - 2018 - 9) AS STRING), 2, '0'), '～')
        ELSE 
          CONCAT('H', LPAD(CAST((YEAR(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE)) - 1988 - 9) AS STRING), 2, '0'), '～')
      END
    WHEN CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) >= 2019 THEN
      CONCAT('R', LPAD(CAST(CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) - 2018 AS STRING), 2, '0'))
    WHEN CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) >= 1989 THEN
      CONCAT('H', LPAD(CAST(CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) - 1988 AS STRING), 2, '0'))
    ELSE
      NULL
  	END) AS 下取車の年式 --下取車の年式
FROM
	ai21rep_ve_dx.tbba001g tbba001g --新車受注基本情報ＤＢ 
LEFT SEMI JOIN dx_ve.tbi999003m tbi999003m ON --店舗展示設定
	tbba001g.cd_hansya = tbi999003m.cd_hansya
	AND tbba001g.cd_kaisya = tbi999003m.cd_kaisya
	AND tbba001g.cd_tenpo = tbi999003m.cd_tenpo
	AND tbi999003m.mj_cyohyoid = '016'
	AND tbi999003m.kb_tenji = 1
LEFT JOIN ai21rep_ve_dx.tbbf008m tbbf008m  --車両スペック２ＤＢ
    ON tbba001g.cd_kaisya = tbbf008m.cd_kaisya
    AND tbba001g.cd_hansya = tbbf008m.cd_hansya
    AND tbba001g.mj_sinkysed = tbbf008m.mj_sinkysed
    AND tbba001g.mj_gaihansy  = tbbf008m.cd_spec 
    AND tbba001g.mj_hantenkt  = tbbf008m.mj_hantenkt
    AND tbbf008m.kb_spec = 'G'
LEFT  JOIN ai21rep_ve_dx.tbbf001m tbbf001m  --車名ＤＢ 
    ON tbbf001m.cd_kaisya = tbbf008m.cd_kaisya
    AND tbbf001m.cd_hansya = tbbf008m.cd_hansya
    AND tbbf001m.cd_ncsyamei = tbbf008m.mj_syamei
LEFT SEMI JOIN dx_ve.tbi999008m tbi999008m  --車種展示設定
	ON tbbf001m.cd_hansya = tbi999008m.cd_hansya
	AND tbbf001m.cd_kaisya = tbi999008m.cd_kaisya
	AND tbbf001m.cd_ncsyamei = tbi999008m.cd_ncsyamei
	AND tbi999008m.kb_tenji = 1
LEFT JOIN ai21rep_ve_dx.tbba056g tbba056g  --新車お客様詳細情報DB 
    ON tbba056g.cd_hansya = tbba001g.cd_hansya
    AND tbba056g.cd_kaisya = tbba001g.cd_kaisya
    AND tbba056g.no_cyumon = tbba001g.no_cyumon
    AND TRIM(tbba056g.no_cyumoned) = TRIM(tbba001g.no_cyumoned)
 LEFT JOIN ai21rep_ve_dx.tbba051g tbba051g --新車受注顧客情報ＤＢ
     ON tbba051g.cd_hansya = tbba001g.cd_hansya
    AND tbba051g.cd_kaisya = tbba001g.cd_kaisya
    AND tbba051g.no_cyumon = tbba001g.no_cyumon
    AND TRIM(tbba051g.no_cyumoned) = TRIM(tbba001g.no_cyumoned)
    AND tbba051g.kb_kokyaku = '2'
 LEFT JOIN (
	  SELECT
	     tbba003g.cd_hansya --販社コード
	    ,tbba003g.cd_kaisya --会社コード
	    ,tbba003g.no_cyumon --注文ＮＯ
	    ,tbba003g.no_cyumoned --注文ＮＯ枝番
	    ,COUNT(1) AS sitasu --下取台数
	    ,MAX(su_syndotor) AS su_syndotor --初年度登録年月
	    ,MAX(tbba003g.cd_sitadosy) AS cd_sitadosy	 --下取車名コード
	  FROM ai21rep_ve_dx.tbba003g tbba003g --受注下取DB
	  WHERE tbba003g.kb_sincyu  = '1'
	  GROUP BY
	     tbba003g.cd_hansya
	    ,tbba003g.cd_kaisya
	    ,tbba003g.no_cyumon
	    ,tbba003g.no_cyumoned
	) tbba003g_group
	ON tbba001g.cd_hansya = tbba003g_group.cd_hansya
	AND tbba001g.cd_kaisya = tbba003g_group.cd_kaisya
	AND tbba001g.no_cyumon = tbba003g_group.no_cyumon
	AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba003g_group.no_cyumoned)
LEFT JOIN ai21rep_ve_dx.tbv0232m tbv0232m --ａｉ２１車名コードＤＢ
    ON tbv0232m.cd_hansya = tbba003g_group.cd_hansya
    AND tbv0232m.cd_kaisya = tbba003g_group.cd_kaisya
    AND tbv0232m.cd_syamei = tbba003g_group.cd_sitadosy 
 LEFT JOIN ai21rep_ve_dx.tbv0231m tbv0231m --コード区分ＤＢ （カテゴリーコード）
     ON tbv0231m.cd_hansya = tbv0232m.cd_hansya
    AND tbv0231m.cd_kaisya = tbv0232m.cd_kaisya
    AND tbv0231m.mj_blockid = '00'
    AND tbv0231m.mj_kubunid = '0031'
    AND tbv0231m.cd_kubun = tbv0232m.cd_category
--売上取消計上日と取消日=NULL
WHERE tbba001g.dd_uritrkkj IS NULL
	AND tbba001g.dd_torikesi IS NULL
	AND tbba001g.dd_jucyuke IS NOT NULL
 ) t 
 GROUP BY 
 	販社コード,
	会社コード,
 	新車車名,
 	車名受注日,
 	カテゴリー,
	購入形態,
	下取車の年式,
	下取車の車名,
	自社他社
LIMIT 0;

-- [071/099] level=0 target=gold.VBI016006
-- Gold dependencies: none
-- Source file: 016_新車受注分析/vbi016001-vbi016011_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI016006 AS
SELECT
	販社コード, --販社コード
	会社コード, --会社コード
	IF(自社他社 = 'トヨタ', '1', '3') AS 番号, --番号
	自社他社 AS 自社他社, --自社他社
	下取車の車名 AS 車名, --車名
	カテゴリー, --カテゴリー
	CONCAT(NVL(カテゴリー,'') , 下取車の車名) AS カテゴリー車名, --カテゴリー車名
	IF(カテゴリー IS NULL, 1, 2) AS カテゴリーソート順 --カテゴリーソート順
FROM
	(
	SELECT
		販社コード, --販社コード
		会社コード, --販社コード
		下取車の車名, --下取車の車名
		カテゴリー, --カテゴリー
		自社他社 --自社他社
	FROM 
	(
		SELECT
			tbba001g.cd_hansya AS 販社コード, --販社コード
			tbba001g.cd_kaisya AS 会社コード, --会社コード
		    IF(tbv0232m.cd_maker = '01' AND LEFT(tbv0232m.cd_syamei,1) <> 'L' , 'トヨタ' , '他メーカー' ) AS 自社他社, --自社他社
		  	tbv0232m.kj_syamei AS 下取車の車名, --下取車の車名
		  	tbv0231m.mj_kubunnai AS カテゴリー --カテゴリー
		FROM
			ai21rep_ve_dx.tbba001g tbba001g --新車受注基本情報ＤＢ 
		LEFT SEMI JOIN dx_ve.tbi999003m tbi999003m ON --店舗展示設定
			tbba001g.cd_hansya = tbi999003m.cd_hansya
			AND tbba001g.cd_kaisya = tbi999003m.cd_kaisya
			AND tbba001g.cd_tenpo = tbi999003m.cd_tenpo
			AND tbi999003m.mj_cyohyoid = '016'
			AND tbi999003m.kb_tenji = 1
		 LEFT JOIN (
			  SELECT
			     tbba003g.cd_hansya --販社コード
			    ,tbba003g.cd_kaisya --会社コード
			    ,tbba003g.no_cyumon --注文ＮＯ
			    ,tbba003g.no_cyumoned --注文ＮＯ枝番
			    ,MAX(tbba003g.cd_sitadosy) AS cd_sitadosy --下取車名コード	
			  FROM ai21rep_ve_dx.tbba003g tbba003g --受注下取DB
			  --新中区分= '1'
			  WHERE tbba003g.kb_sincyu  = '1'
			  GROUP BY
			     tbba003g.cd_hansya
			    ,tbba003g.cd_kaisya
			    ,tbba003g.no_cyumon
			    ,tbba003g.no_cyumoned
			) tbba003g_group
			ON tbba001g.cd_hansya = tbba003g_group.cd_hansya
			AND tbba001g.cd_kaisya = tbba003g_group.cd_kaisya
			AND tbba001g.no_cyumon = tbba003g_group.no_cyumon
			AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba003g_group.no_cyumoned)
		LEFT JOIN ai21rep_ve_dx.tbv0232m tbv0232m --ａｉ２１車名コードＤＢ
		    ON tbv0232m.cd_hansya = tbba003g_group.cd_hansya
		    AND tbv0232m.cd_kaisya = tbba003g_group.cd_kaisya
		    AND tbv0232m.cd_syamei = tbba003g_group.cd_sitadosy 
		 LEFT JOIN ai21rep_ve_dx.tbv0231m tbv0231m --コード区分ＤＢ （カテゴリーコード）
		     ON tbv0231m.cd_hansya = tbv0232m.cd_hansya
		    AND tbv0231m.cd_kaisya = tbv0232m.cd_kaisya
		    AND tbv0231m.mj_blockid = '00'
		    AND tbv0231m.mj_kubunid = '0031'
		    AND tbv0231m.cd_kubun = tbv0232m.cd_category
		--売上取消計上日と取消日=NULL 受注計上日!=NULL
		WHERE tbba001g.dd_uritrkkj IS NULL
			AND tbba001g.dd_torikesi IS NULL
			AND tbba001g.dd_jucyuke IS NOT NULL
	 ) t 
	 GROUP BY 
	 	販社コード,
		会社コード,
		下取車の車名,
		カテゴリー,
		自社他社
	) t
GROUP BY
	販社コード,
	会社コード,
	自社他社,
	下取車の車名,
	カテゴリー,
	カテゴリーソート順
UNION ALL
SELECT
	'固定' AS 販社コード, --販社コード
	'' AS 会社コード, --会社コード
	'4' AS 番号, --番号
	' ' AS 自社他社, --自社他社
	"他社計" AS 車名, --車名
	' ' AS カテゴリー, --カテゴリー
	' ' AS カテゴリー車名, --カテゴリー車名
	1 AS カテゴリーソート順 --カテゴリーソート順
UNION ALL
SELECT
	'固定' AS 販社コード, --販社コード
	'' AS 会社コード, --会社コード
	'5' AS 番号, --番号
	'合　計' AS 自社他社, --自社他社
	' ' AS 車名, --車名
	' ' AS カテゴリー, --カテゴリー
	' ' AS カテゴリー車名, --カテゴリー車名
	1 AS カテゴリーソート順 --カテゴリーソート順
UNION ALL
SELECT
	'固定' AS 販社コード, --販社コード
	'' AS 会社コード, --会社コード
	'6' AS 番号, --番号
	'構成比' AS 自社他社, --自社他社
	' ' AS 車名, --車名
	' ' AS カテゴリー, --カテゴリー
	' ' AS カテゴリー車名, --カテゴリー車名
	1 AS カテゴリーソート順 --カテゴリーソート順
UNION ALL
SELECT
	'固定' AS 販社コード, --販社コード
	'' AS 会社コード, --会社コード
	'2' AS 番号, --番号
	'' AS 自社他社, --自社他社
	"自社計" AS 車名, --車名
	' ' AS カテゴリー, --カテゴリー
	' ' AS カテゴリー車名, --カテゴリー車名
	1 AS カテゴリーソート順 --カテゴリーソート順
LIMIT 0;

-- [072/099] level=0 target=gold.VBI016007
-- Gold dependencies: none
-- Source file: 016_新車受注分析/vbi016001-vbi016011_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI016007 AS
WITH tbbg068m AS (
    --受注形態マスタＤＢ　
	--販社コード, 会社コード , 問題コード , 検索キー, 答名１ ～ 答名２０　　											WHERE条件：問題コード は商談動機、購入形態（レクサス、トヨタ）かつ新中区分= '1'
	SELECT cd_hansya, cd_kaisya, cd_mondai, '01' AS searchKey, cd_kotaem1 AS cd_kotaem  FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '02' AS searchKey, cd_kotaem2 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '03' AS searchKey, cd_kotaem3 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '04' AS searchKey, cd_kotaem4 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '05' AS searchKey, cd_kotaem5 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '06' AS searchKey, cd_kotaem6 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '07' AS searchKey, cd_kotaem7 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '08' AS searchKey, cd_kotaem8 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '09' AS searchKey, cd_kotaem9 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '10' AS searchKey, cd_kotaem10 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '11' AS searchKey, cd_kotaem11 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '12' AS searchKey, cd_kotaem12 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '13' AS searchKey, cd_kotaem13 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '14' AS searchKey, cd_kotaem14 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '15' AS searchKey, cd_kotaem15 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '16' AS searchKey, cd_kotaem16 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '17' AS searchKey, cd_kotaem17 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '18' AS searchKey, cd_kotaem18 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '19' AS searchKey, cd_kotaem19 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '20' AS searchKey, cd_kotaem20 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
)
SELECT
	販社コード, -- 販社コード
	会社コード, -- 会社コード
	ゾーン名称, -- ゾーン名称
	ゾーンコード, -- ゾーンコード
	店舗短縮名称, -- 店舗短縮名称
	新車車名, -- 新車車名
	受注計上日, -- 受注計上日
	購入形態, -- 購入形態
	法人個人区分, -- 法人個人区分
	年齢別, -- 年齢別
	商談動機, -- 商談動機
	支払区分, -- 支払区分
	RANK() OVER (PARTITION BY 販社コード,会社コード ORDER BY IF(NVL(ゾーン名称,'') = '', 0,1), ゾーン名称 , ソート順 , 店舗コード) AS ソート順, -- ソート順
	RANK() OVER (PARTITION BY 販社コード, 会社コード ORDER BY 車名ソート順,新車車名コード) AS 車名ソート順, -- 車名ソート順
	台数 -- 台数
FROM
(
SELECT
	t201m.cd_hansya AS 販社コード, -- 販社コード
	t201m.cd_kaisya AS 会社コード, -- 会社コード
	IF(
		(tbv0033m.cd_zon IS NULL OR regexp_replace(tbv0033m.cd_zon, '[ 　]+', '') = ''),
			IF((tbv0033m.kj_zonmei IS NULL OR regexp_replace(tbv0033m.kj_zonmei, '[ 　]+', '') = ''),
			'999999',
			'999998'
			),
			IF(((tbv0033m.kj_zonmei IS NULL OR regexp_replace(tbv0033m.kj_zonmei, '[ 　]+', '') = '')),
			'999999',
			tbv0033m.cd_zon)
		) AS ゾーンコード, -- ゾーンコード
	tbv0033m.kj_zonmei AS ゾーン名称, -- ゾーン名称
	t201m.cd_tenpo AS 店舗コード, -- 店舗コード
	sort_sub.mj_sortjyun AS ソート順, -- ソート順
	MIN(sort_car.mj_sortjyun) AS 車名ソート順, -- 車名ソート順
	MIN(sort_car.cd_ncsyamei) AS 新車車名コード, -- 新車車名コード
	t201m.kj_tentanms AS 店舗短縮名称, -- 店舗短縮名称
	CASE WHEN tbba051g.kb_seibetu ='1' THEN '男' WHEN tbba051g.kb_seibetu ='2' THEN '女' WHEN tbba051g.kb_seibetu = '3' THEN '法人' ELSE NULL END AS 法人個人区分, -- 法人個人区分
	CASE WHEN tbba051g.nu_nenrei >=60 THEN '60歳以上' 
		WHEN tbba051g.nu_nenrei >=50 THEN '50歳代' 
		WHEN tbba051g.nu_nenrei >=40 THEN '40歳代' 
		WHEN tbba051g.nu_nenrei >=30 THEN '30歳代' 
		ELSE '29歳以下' 
	END AS 年齢別, -- 年齢別
	IF(tbbf001m.kb_syasikib='6' , IF(TRIM(tbbg068m_2.cd_kotaem)='',NULL, tbbg068m_2.cd_kotaem) , IF(TRIM(tbbg068m_3.cd_kotaem)='',NULL, tbbg068m_3.cd_kotaem)) AS 購入形態, -- 購入形態
	tbbf001m.kj_kurumame AS 新車車名, -- 新車車名
	CAST(tbba001g.dd_jucyuke AS DATE) AS 受注計上日, -- 受注計上日
	IF(TRIM(tbbg068m_1.cd_kotaem)='',NULL, tbbg068m_1.cd_kotaem) AS 商談動機, -- 商談動機
	REPLACE(TRIM(tbv0231m.mj_kubunnai),'　','') AS  支払区分, -- 支払区分
	COUNT(tbba001g.cd_hansya) AS 台数 -- 台数
FROM
	ai21rep_ve_dx.tbv0201m t201m  --共通店舗ＤＢ 
LEFT JOIN ai21rep_ve_dx.tbba001g tbba001g --新車受注基本情報ＤＢ 
	ON t201m.cd_hansya = tbba001g.cd_hansya
	AND t201m.cd_kaisya = tbba001g.cd_kaisya
	AND t201m.cd_tenpo = tbba001g.cd_tenpo
	AND tbba001g.dd_uritrkkj IS NULL
	AND tbba001g.dd_torikesi IS NULL
	AND tbba001g.dd_jucyuke IS NOT NULL
INNER JOIN dx_ve.tbi999003m tbi999003m  --店舗展示設定
	ON t201m.cd_hansya = tbi999003m.cd_hansya
	AND t201m.cd_kaisya = tbi999003m.cd_kaisya
	AND t201m.cd_tenpo = tbi999003m.cd_tenpo
	AND tbi999003m.mj_cyohyoid = '016'
	AND tbi999003m.kb_tenji = 1
LEFT JOIN ai21rep_ve_dx.tbv0047m  tbv0047m
    ON tbv0047m.cd_hansya = t201m.cd_hansya
	AND tbv0047m.cd_kaisya = t201m.cd_kaisya
	AND tbv0047m.cd_tenpo = t201m.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbv0033m tbv0033m  --ＭゾーンコードＤＢ 
    ON tbv0033m.cd_hansya = t201m.cd_hansya
	AND tbv0033m.cd_kaisya = t201m.cd_kaisya
	AND tbv0033m.cd_zon = tbv0047m.cd_nczon
	AND tbv0033m.kb_syohin  = '1'
LEFT JOIN ai21rep_ve_dx.tbbf008m tbbf008m  --車両スペック２ＤＢ
    ON tbba001g.cd_kaisya = tbbf008m.cd_kaisya
    AND tbba001g.cd_hansya = tbbf008m.cd_hansya
    AND tbba001g.mj_sinkysed = tbbf008m.mj_sinkysed
    AND tbba001g.mj_gaihansy  = tbbf008m.cd_spec 
    AND tbba001g.mj_hantenkt  = tbbf008m.mj_hantenkt
    AND tbbf008m.kb_spec = 'G'
LEFT  JOIN ai21rep_ve_dx.tbbf001m tbbf001m  --車名ＤＢ 
    ON tbbf001m.cd_kaisya = tbbf008m.cd_kaisya
    AND tbbf001m.cd_hansya = tbbf008m.cd_hansya
    AND tbbf001m.cd_ncsyamei = tbbf008m.mj_syamei
LEFT SEMI JOIN dx_ve.tbi999008m tbi999008m  --車種展示設定
	ON tbbf001m.cd_hansya = tbi999008m.cd_hansya
	AND tbbf001m.cd_kaisya = tbi999008m.cd_kaisya
	AND tbbf001m.cd_ncsyamei = tbi999008m.cd_ncsyamei
	AND tbi999008m.kb_tenji = 1
LEFT JOIN ai21rep_ve_dx.tbba056g tbba056g  --新車お客様詳細情報DB 
    ON tbba056g.cd_hansya = tbba001g.cd_hansya
    AND tbba056g.cd_kaisya = tbba001g.cd_kaisya
    AND tbba056g.no_cyumon = tbba001g.no_cyumon
    AND TRIM(tbba056g.no_cyumoned) = TRIM(tbba001g.no_cyumoned)
 LEFT JOIN ai21rep_ve_dx.tbba051g tbba051g --新車受注顧客情報ＤＢ
     ON tbba051g.cd_hansya = tbba001g.cd_hansya
    AND tbba051g.cd_kaisya = tbba001g.cd_kaisya
    AND tbba051g.no_cyumon = tbba001g.no_cyumon
    AND TRIM(tbba051g.no_cyumoned) = TRIM(tbba001g.no_cyumoned)
    AND tbba051g.kb_kokyaku = '2'
 LEFT JOIN tbbg068m tbbg068m_1 --受注形態マスタＤＢ
 	ON tbbg068m_1.cd_hansya = tbba056g.cd_hansya
 	AND tbbg068m_1.cd_kaisya = tbba056g.cd_kaisya
 	AND tbba056g.mj_jucyuke1=tbbg068m_1.searchKey  
 	AND tbbg068m_1.cd_mondai  = '101'
 LEFT JOIN tbbg068m tbbg068m_2 --受注形態マスタＤＢ
 	ON tbbg068m_2.cd_hansya = tbba056g.cd_hansya
 	AND tbbg068m_2.cd_kaisya = tbba056g.cd_kaisya
 	AND tbba056g.mj_jucyuk11=tbbg068m_2.searchKey  
 	AND tbbg068m_2.cd_mondai  = '111'
 LEFT JOIN tbbg068m tbbg068m_3 --受注形態マスタＤＢ
 	ON tbbg068m_3.cd_hansya = tbba056g.cd_hansya
 	AND tbbg068m_3.cd_kaisya = tbba056g.cd_kaisya
 	AND tbba056g.mj_jucyuke4=tbbg068m_3.searchKey
 	AND tbbg068m_3.cd_mondai  = '104'
 LEFT JOIN ai21rep_ve_dx.tbba052g tbba052g --新車受注販売条件情報ＤＢ
     ON tbba052g.cd_hansya = tbba001g.cd_hansya
    AND tbba052g.cd_kaisya = tbba001g.cd_kaisya
    AND tbba052g.no_cyumon = tbba001g.no_cyumon
    AND TRIM(tbba052g.no_cyumoned) = TRIM(tbba001g.no_cyumoned)
 LEFT JOIN ai21rep_ve_dx.tbv0231m tbv0231m --コード区分ＤＢ （車両支払区分）
     ON tbv0231m.cd_hansya = tbba001g.cd_hansya
    AND tbv0231m.cd_kaisya = tbba001g.cd_kaisya
    AND tbv0231m.mj_blockid = '02'
    AND tbv0231m.mj_kubunid = '0018'
    AND TRIM(tbv0231m.cd_kubun) = tbba052g.kb_siharai
 LEFT JOIN  (SELECT	kj_tentanms, -- 店舗短縮名称
					 t201m_2.cd_hansya,  --販社コード
					 t201m_2.cd_kaisya,	 --会社コード
 					MIN(tbi999003m.mj_sortjyun) AS mj_sortjyun  --ソート順
 		FROM ai21rep_ve_dx.tbv0201m t201m_2
	 	INNER JOIN dx_ve.tbi999003m tbi999003m  --店舗展示設定
			ON t201m_2.cd_hansya = tbi999003m.cd_hansya
			AND t201m_2.cd_kaisya = tbi999003m.cd_kaisya
			AND t201m_2.cd_tenpo = tbi999003m.cd_tenpo
			AND tbi999003m.mj_cyohyoid = '016'
			AND tbi999003m.kb_tenji = 1
		GROUP BY 
			t201m_2.cd_hansya,
			t201m_2.cd_kaisya,
			kj_tentanms		
		) sort_sub
	ON t201m.cd_hansya = sort_sub.cd_hansya
    AND t201m.cd_kaisya = sort_sub.cd_kaisya
	AND t201m.kj_tentanms = sort_sub.kj_tentanms
 LEFT JOIN (SELECT	
				 tbi999008m.cd_hansya, --販社コード
				 tbi999008m.cd_kaisya, --会社コード
				 TRIM(tbi999008m.kj_kurumame) AS kj_kurumame, --漢字車名
				 MIN(tbi999008m.mj_sortjyun) AS mj_sortjyun, --ソート順
				 MIN(tbi999008m.cd_ncsyamei) AS cd_ncsyamei --新車車名コード
 		FROM dx_ve.tbi999008m tbi999008m  --車種展示設定
		WHERE tbi999008m.kb_tenji = 1 --展示区分 = 1
		GROUP BY 
			tbi999008m.cd_hansya,
			tbi999008m.cd_kaisya,
			TRIM(tbi999008m.kj_kurumame)
		) sort_car
	ON tbbf001m.cd_hansya = sort_car.cd_hansya
    AND tbbf001m.cd_kaisya = sort_car.cd_kaisya
	AND TRIM(tbbf001m.kj_kurumame) = TRIM(sort_car.kj_kurumame)
WHERE NOT (t201m.kj_tenpomei LIKE '%廃）%' AND tbba001g.cd_hansya IS NULL)
GROUP BY 
 	販社コード,
	会社コード,
	ゾーンコード,
	ゾーン名称,
	店舗コード,
	ソート順,
	店舗短縮名称,
	年齢別,
 	新車車名,
 	受注計上日,
 	購入形態,
	法人個人区分,	
	商談動機,
	支払区分
 ) t
LIMIT 0;

-- [073/099] level=0 target=gold.VBI016008
-- Gold dependencies: none
-- Source file: 016_新車受注分析/vbi016001-vbi016011_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI016008 AS
SELECT
	販社コード, -- 販社コード
	会社コード, -- 会社コード
	店舗コード, -- 店舗コード
	下取有無, -- 下取有無
	下取車の車名, -- 下取車の車名
	新車車名, -- 新車車名
	受注計上日, -- 受注計上日
	店舗短縮名称, -- 店舗短縮名称
	ゾーンコード, -- ゾーンコード
	ゾーン名称, -- ゾーン名称
	下取車の自社他社, -- 下取車の自社他社
	下取車の年式, -- 下取車の年式
	RANK() OVER (PARTITION BY 販社コード,会社コード ORDER BY IF(NVL(ゾーン名称,'') = '', 0,1), ゾーン名称,ソート順 , 店舗コード) AS ソート順, -- ソート順
	RANK() OVER (PARTITION BY 販社コード, 会社コード ORDER BY 車名ソート順, 新車車名コード) AS 車名ソート順, -- 車名ソート順
	台数, -- 台数
	下取台数 -- 下取台数
FROM 
(
SELECT
	tbv0201m.cd_hansya AS 販社コード, -- 販社コード
	tbv0201m.cd_kaisya AS 会社コード, -- 会社コード
	tbv0201m.cd_tenpo AS 店舗コード, -- 店舗コード
	sort_sub.mj_sortjyun AS ソート順, -- ソート順
	MIN(sort_car.mj_sortjyun) AS 車名ソート順, -- 車名ソート順
	MIN(sort_car.cd_ncsyamei) AS 新車車名コード, -- 新車車名コード
	IF(tbba003g_group.sitasu > 0, '有', '無') AS 下取有無, -- 下取有無
	tbv0232m.kj_syamei AS 下取車の車名, -- 下取車の車名
	tbbf001m.kj_kurumame AS 新車車名, -- 新車車名
	CAST(tbba001g.dd_jucyuke AS DATE) AS 受注計上日, -- 受注計上日
	tbv0201m.kj_tentanms AS 店舗短縮名称, -- 店舗短縮名称
	IF(
		(tbv0033m.cd_zon IS NULL OR regexp_replace(tbv0033m.cd_zon, '[ 　]+', '') = ''),
			IF((tbv0033m.kj_zonmei IS NULL OR regexp_replace(tbv0033m.kj_zonmei, '[ 　]+', '') = ''),
			'999999',
			'999998'
			),
			IF(((tbv0033m.kj_zonmei IS NULL OR regexp_replace(tbv0033m.kj_zonmei, '[ 　]+', '') = '')),
			'999999',
			tbv0033m.cd_zon)
		) AS ゾーンコード, -- ゾーンコード
	TBV0033M.kj_zonmei AS ゾーン名称, -- ゾーン名称
	IF(tbv0232m.cd_hansya IS NULL, NULL, IF(tbv0232m.cd_maker = '01' AND LEFT(tbv0232m.cd_syamei,1) <> 'L' , 'トヨタ' , '他メーカー' )) AS 下取車の自社他社,   -- 下取車の自社他社
	CASE 
    WHEN CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) < (YEAR(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE)) - 8) THEN
      CASE 
        WHEN (YEAR(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE)) - 9) >= 2019 THEN 
          CONCAT('R', LPAD(CAST((YEAR(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE)) - 2018 - 9) AS STRING), 2, '0'), '～')
        ELSE 
          CONCAT('H', LPAD(CAST((YEAR(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE)) - 1988 - 9) AS STRING), 2, '0'), '～')
      END
    WHEN CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) >= 2019 THEN
      CONCAT('R', LPAD(CAST(CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) - 2018 AS STRING), 2, '0'))
    WHEN CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) >= 1989 THEN
      CONCAT('H', LPAD(CAST(CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) - 1988 AS STRING), 2, '0'))
    ELSE
      NULL
  	END AS 下取車の年式,  -- 下取車の年式
  	COUNT(tbba001g.cd_hansya) AS 台数, -- 台数
  	SUM(IF(tbv0232m.cd_hansya IS NOT NULL, tbba003g_group.sitasu,0)) AS 下取台数 -- 下取台数
FROM ai21rep_ve_dx.tbv0201m tbv0201m --共通店舗DB
INNER JOIN dx_ve.tbi999003m tbi999003m  --店舗展示設定
	ON tbv0201m.cd_hansya = tbi999003m.cd_hansya
	AND tbv0201m.cd_kaisya = tbi999003m.cd_kaisya
	AND tbv0201m.cd_tenpo = tbi999003m.cd_tenpo
	AND tbi999003m.mj_cyohyoid = '016'
	AND tbi999003m.kb_tenji = 1
LEFT JOIN ai21rep_ve_dx.tbv0047m TBV0047M --M車両店舗DB
    ON TBV0047M.cd_hansya = tbv0201m.cd_hansya
    AND TBV0047M.cd_kaisya = tbv0201m.cd_kaisya
    AND TBV0047M.cd_tenpo = tbv0201m.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbv0033m TBV0033M --MゾーンコードDB
    ON TBV0033M.cd_hansya = TBV0047M.cd_hansya
    AND TBV0033M.cd_kaisya = TBV0047M.cd_kaisya
    AND TBV0033M.cd_zon = TBV0047M.cd_nczon
    AND tbv0033m.kb_syohin  = '1'
LEFT JOIN ai21rep_ve_dx.tbba001g tbba001g --新車受注基本情報ＤＢ 
	ON tbv0201m.cd_hansya = tbba001g.cd_hansya
	AND tbv0201m.cd_kaisya = tbba001g.cd_kaisya
	AND tbv0201m.cd_tenpo = tbba001g.cd_tenpo
	AND tbba001g.dd_uritrkkj IS NULL
	AND tbba001g.dd_torikesi IS NULL
	AND tbba001g.dd_jucyuke IS NOT NULL
LEFT JOIN ai21rep_ve_dx.tbbf008m tbbf008m  --車両スペック２ＤＢ
    ON tbba001g.cd_kaisya = tbbf008m.cd_kaisya
    AND tbba001g.cd_hansya = tbbf008m.cd_hansya
    AND tbba001g.mj_sinkysed = tbbf008m.mj_sinkysed
    AND tbba001g.mj_gaihansy  = tbbf008m.cd_spec 
    AND tbba001g.mj_hantenkt  = tbbf008m.mj_hantenkt
    AND tbbf008m.kb_spec = 'G'
LEFT  JOIN ai21rep_ve_dx.tbbf001m tbbf001m  --車名ＤＢ 
    ON tbbf001m.cd_kaisya = tbbf008m.cd_kaisya
    AND tbbf001m.cd_hansya = tbbf008m.cd_hansya
    AND tbbf001m.cd_ncsyamei = tbbf008m.mj_syamei
LEFT SEMI JOIN dx_ve.tbi999008m tbi999008m  --車種展示設定
	ON tbbf001m.cd_hansya = tbi999008m.cd_hansya
	AND tbbf001m.cd_kaisya = tbi999008m.cd_kaisya
	AND tbbf001m.cd_ncsyamei = tbi999008m.cd_ncsyamei
	AND tbi999008m.kb_tenji = 1
LEFT JOIN (
	  SELECT
	     tbba003g.cd_hansya -- 販社コード
	    ,tbba003g.cd_kaisya -- 会社コード
	    ,tbba003g.no_cyumon --注文ＮＯ
	    ,tbba003g.no_cyumoned  --注文ＮＯ枝番
	    ,MAX(su_syndotor) AS su_syndotor  --初年度登録年月
	    ,MAX(tbba003g.cd_sitadosy) AS cd_sitadosy  --下取車名コード
	    ,COUNT(1) AS sitasu	 --下取台数
	  FROM ai21rep_ve_dx.tbba003g tbba003g --受注下取DB
	  WHERE tbba003g.kb_sincyu = '1'  --新中区分 = '1'
	  GROUP BY
	     tbba003g.cd_hansya
	    ,tbba003g.cd_kaisya
	    ,tbba003g.no_cyumon
	    ,tbba003g.no_cyumoned
	) tbba003g_group
	ON tbba001g.cd_hansya = tbba003g_group.cd_hansya
	AND tbba001g.cd_kaisya = tbba003g_group.cd_kaisya
	AND tbba001g.no_cyumon = tbba003g_group.no_cyumon
	AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba003g_group.no_cyumoned)
LEFT JOIN ai21rep_ve_dx.tbv0232m tbv0232m --ａｉ２１車名コードＤＢ
    ON tbv0232m.cd_hansya = tbba003g_group.cd_hansya
    AND tbv0232m.cd_kaisya = tbba003g_group.cd_kaisya
    AND tbv0232m.cd_syamei = tbba003g_group.cd_sitadosy
LEFT JOIN   (SELECT	 kj_tentanms, -- 店舗短縮名称
					 t201m_2.cd_hansya, --販社コード
					 t201m_2.cd_kaisya, --会社コード
 					MIN(t201m_2.cd_tenpo) AS cd_tenpo, --店舗コード
 					MIN(tbi999003m.mj_sortjyun) AS mj_sortjyun --ソート順
 		FROM ai21rep_ve_dx.tbv0201m t201m_2
	 	INNER JOIN dx_ve.tbi999003m tbi999003m  --店舗展示設定
			ON t201m_2.cd_hansya = tbi999003m.cd_hansya
			AND t201m_2.cd_kaisya = tbi999003m.cd_kaisya
			AND t201m_2.cd_tenpo = tbi999003m.cd_tenpo
			AND tbi999003m.mj_cyohyoid = '016'
			AND tbi999003m.kb_tenji = 1
		GROUP BY 
			t201m_2.cd_hansya,
			t201m_2.cd_kaisya,
			kj_tentanms
		) sort_sub
	ON tbv0201m.cd_hansya = sort_sub.cd_hansya
    AND tbv0201m.cd_kaisya = sort_sub.cd_kaisya
	AND tbv0201m.kj_tentanms = sort_sub.kj_tentanms
	LEFT JOIN (SELECT	
				 tbi999008m.cd_hansya, --販社コード
				 tbi999008m.cd_kaisya, --会社コード
				 TRIM(tbi999008m.kj_kurumame) AS kj_kurumame, --漢字車名
				 MIN(tbi999008m.mj_sortjyun) AS mj_sortjyun, --ソート順
				 MIN(tbi999008m.cd_ncsyamei) AS cd_ncsyamei --新車車名コード
 		FROM dx_ve.tbi999008m tbi999008m  --車種展示設定
		WHERE tbi999008m.kb_tenji = 1
		GROUP BY 
			tbi999008m.cd_hansya,
			tbi999008m.cd_kaisya,
			TRIM(tbi999008m.kj_kurumame)
		) sort_car
	ON tbbf001m.cd_hansya = sort_car.cd_hansya
    AND tbbf001m.cd_kaisya = sort_car.cd_kaisya
	AND TRIM(tbbf001m.kj_kurumame) = TRIM(sort_car.kj_kurumame)
WHERE NOT (tbv0201m.kj_tenpomei LIKE '%廃）%' AND tbba001g.cd_hansya IS NULL)  -- 店舗名称が"廃）"を含まないかつ新車受注基本情報ＤＢにデータがある
GROUP BY 
 	販社コード,
	会社コード,
	店舗コード,
	ゾーンコード,
	ソート順,
	下取有無,
	下取車の車名,
	新車車名,
	受注計上日,
	店舗短縮名称,
	ゾーン名称,
 	下取車の自社他社,
 	下取車の年式
 ) t
LIMIT 0;

-- [074/099] level=0 target=gold.VBI016009
-- Gold dependencies: none
-- Source file: 016_新車受注分析/vbi016001-vbi016011_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI016009 AS
SELECT
	販社コード, -- 販社コード
	会社コード, -- 会社コード
	店舗コード, -- 店舗コード
	店舗短縮名称, -- 店舗短縮名称
	ゾーンコード, -- ゾーンコード
	ゾーン名称, -- ゾーン名称
	グレード, -- グレード
	品名カナ, -- 品名カナ
	新車車名, -- 新車車名
	受注計上日, -- 受注計上日
	RANK() OVER (PARTITION BY 販社コード,会社コード ORDER BY IF(NVL(ゾーン名称,'') = '', 0,1), ゾーン名称 ,ソート順 , 店舗コード) AS ソート順, -- ソート順
	RANK() OVER (PARTITION BY 販社コード, 会社コード ORDER BY 車名ソート順, 新車車名コード) AS 車名ソート順, -- 車名ソート順
	台数 -- 台数
FROM(
	SELECT
		t201m.cd_hansya AS 販社コード, -- 販社コード
		t201m.cd_kaisya AS 会社コード, -- 会社コード
		t201m.cd_tenpo AS 店舗コード, -- 店舗コード
		sort_sub.mj_sortjyun AS ソート順, -- ソート順
		MIN(sort_car.mj_sortjyun) AS 車名ソート順, -- 車名ソート順
		MIN(sort_car.cd_ncsyamei) AS 新車車名コード, -- 新車車名コード
		t201m.kj_tentanms AS 店舗短縮名称, -- 店舗短縮名称
		IF(
		(tbv0033m.cd_zon IS NULL OR regexp_replace(tbv0033m.cd_zon, '[ 　]+', '') = ''),
			IF((tbv0033m.kj_zonmei IS NULL OR regexp_replace(tbv0033m.kj_zonmei, '[ 　]+', '') = ''),
			'999999',
			'999998'
			),
			IF(((tbv0033m.kj_zonmei IS NULL OR regexp_replace(tbv0033m.kj_zonmei, '[ 　]+', '') = '')),
			'999999',
			tbv0033m.cd_zon)
		) AS ゾーンコード, -- ゾーンコード
		tbv0033m.kj_zonmei AS ゾーン名称, -- ゾーン名称
		tbv0229m.mj_guredo AS グレード, -- グレード
		tbbf007m.kn_hinmei AS 品名カナ, -- 品名カナ
		tbbf001m.kj_kurumame AS 新車車名, -- 新車車名
		CAST(tbba001g.dd_jucyuke AS DATE) AS 受注計上日, -- 受注計上日
		COUNT(tbba001g.cd_hansya) AS 台数 -- 台数
	FROM  ai21rep_ve_dx.tbv0201m t201m  --共通店舗ＤＢ 
	INNER JOIN dx_ve.tbi999003m tbi999003m  --店舗展示設定
		ON t201m.cd_hansya = tbi999003m.cd_hansya
		AND t201m.cd_kaisya = tbi999003m.cd_kaisya
		AND t201m.cd_tenpo = tbi999003m.cd_tenpo
		AND tbi999003m.mj_cyohyoid = '016'
		AND tbi999003m.kb_tenji = 1
	LEFT JOIN ai21rep_ve_dx.tbba001g tbba001g  --新車受注基本情報ＤＢ
	    ON tbba001g.cd_kaisya = t201m.cd_kaisya
	    AND tbba001g.cd_hansya = t201m.cd_hansya
	    AND tbba001g.cd_tenpo = t201m.cd_tenpo
	    AND tbba001g.dd_uritrkkj IS NULL
		AND tbba001g.dd_torikesi IS NULL
		AND tbba001g.dd_jucyuke IS NOT NULL
	LEFT JOIN ai21rep_ve_dx.tbbf008m TBBF008M  --車両スペック２ＤＢ
		ON tbba001g.cd_hansya = TBBF008M.cd_hansya
		AND tbba001g.cd_kaisya = TBBF008M.cd_kaisya
		AND tbba001g.mj_sinkysed = TBBF008M.mj_sinkysed
	    AND tbba001g.mj_gaihansy  = TBBF008M.cd_spec 
	    AND tbba001g.mj_hantenkt  = TBBF008M.mj_hantenkt
	    AND TBBF008M.kb_spec = 'G'
	LEFT JOIN ai21rep_ve_dx.tbbf001m tbbf001m  --車名ＤＢ 
	    ON tbbf001m.cd_kaisya = TBBF008M.cd_kaisya
	    AND tbbf001m.cd_hansya = TBBF008M.cd_hansya
	    AND tbbf001m.cd_ncsyamei = TBBF008M.mj_syamei
	LEFT SEMI JOIN dx_ve.tbi999008m tbi999008m  --車種展示設定
		ON tbbf001m.cd_hansya = tbi999008m.cd_hansya
		AND tbbf001m.cd_kaisya = tbi999008m.cd_kaisya
		AND tbbf001m.cd_ncsyamei = tbi999008m.cd_ncsyamei
		AND tbi999008m.kb_tenji = 1
	LEFT JOIN ai21rep_ve_dx.tbbf007m tbbf007m  --車両スペックＤＢ
	    ON tbbf007m.cd_hansya = TBBF008M.cd_hansya
	    AND tbbf007m.cd_kaisya = TBBF008M.cd_kaisya
	    AND tbbf007m.mj_syamei = TBBF008M.mj_syamei
	    AND tbbf007m.kb_spec = TBBF008M.kb_spec
	    AND tbbf007m.cd_spec = TBBF008M.cd_spec
	    AND tbbf007m.no_hinmei = TBBF008M.no_hinmei
	LEFT JOIN ai21rep_ve_dx.tbv0047m  tbv0047m
	    ON tbv0047m.cd_hansya = t201m.cd_hansya
		AND tbv0047m.cd_kaisya = t201m.cd_kaisya
		AND tbv0047m.cd_tenpo = t201m.cd_tenpo
	LEFT JOIN ai21rep_ve_dx.tbv0033m tbv0033m  --ＭゾーンコードＤＢ 
	    ON tbv0033m.cd_hansya = t201m.cd_hansya
		AND tbv0033m.cd_kaisya = t201m.cd_kaisya
		AND tbv0033m.cd_zon = tbv0047m.cd_nczon
		AND tbv0033m.kb_syohin  = '1'
	LEFT JOIN ai21rep_ve_dx.tbv0229m tbv0229m  --指定類別ＤＢ
	    ON tbv0229m.cd_hansya = tbba001g.cd_hansya
		AND tbv0229m.cd_kaisya = tbba001g.cd_kaisya
		AND tbv0229m.no_siteruib = tbba001g.no_siteruib	
	LEFT JOIN   (SELECT	 kj_tentanms, -- 店舗短縮名称
					 t201m_2.cd_hansya, --販社コード
					 t201m_2.cd_kaisya, --会社コード
 					MIN(t201m_2.cd_tenpo) AS cd_tenpo, --店舗コード
 					MIN(tbi999003m.mj_sortjyun) AS mj_sortjyun --ソート順
 		FROM ai21rep_ve_dx.tbv0201m t201m_2
	 	INNER JOIN dx_ve.tbi999003m tbi999003m  --店舗展示設定
			ON t201m_2.cd_hansya = tbi999003m.cd_hansya
			AND t201m_2.cd_kaisya = tbi999003m.cd_kaisya
			AND t201m_2.cd_tenpo = tbi999003m.cd_tenpo
			AND tbi999003m.mj_cyohyoid = '016'
			AND tbi999003m.kb_tenji = 1
		GROUP BY 
			t201m_2.cd_hansya,
			t201m_2.cd_kaisya,
			kj_tentanms
		) sort_sub
	ON t201m.cd_hansya = sort_sub.cd_hansya
    AND t201m.cd_kaisya = sort_sub.cd_kaisya
	AND t201m.kj_tentanms = sort_sub.kj_tentanms
	LEFT JOIN (SELECT	
				 tbi999008m.cd_hansya, --販社コード
				 tbi999008m.cd_kaisya, --会社コード
				 TRIM(tbi999008m.kj_kurumame) AS kj_kurumame, --漢字車名
				 MIN(tbi999008m.mj_sortjyun) AS mj_sortjyun, --ソート順
				 MIN(tbi999008m.cd_ncsyamei) AS cd_ncsyamei --新車車名コード
 		FROM dx_ve.tbi999008m tbi999008m  --車種展示設定
		WHERE tbi999008m.kb_tenji = 1 --新中区分 = '1'
		GROUP BY 
			tbi999008m.cd_hansya,
			tbi999008m.cd_kaisya,
			TRIM(tbi999008m.kj_kurumame)
		) sort_car
	ON tbbf001m.cd_hansya = sort_car.cd_hansya
    AND tbbf001m.cd_kaisya = sort_car.cd_kaisya
	AND TRIM(tbbf001m.kj_kurumame) = TRIM(sort_car.kj_kurumame)
	WHERE NOT (t201m.kj_tenpomei LIKE '%廃）%' AND tbba001g.cd_hansya IS NULL) -- 店舗名称が"廃）"を含まないかつ新車受注基本情報ＤＢにデータがある
	GROUP BY	
		販社コード,
		会社コード,
		店舗コード,
		ソート順,
		品名カナ,
		新車車名,
		受注計上日,
		店舗短縮名称,
		ゾーンコード,
		ゾーン名称,
		グレード
) t
LIMIT 0;

-- [075/099] level=0 target=gold.VBI016010
-- Gold dependencies: none
-- Source file: 016_新車受注分析/vbi016001-vbi016011_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI016010 AS
SELECT
	t201m.cd_hansya AS 販社コード, -- 販社コード
	t201m.cd_kaisya AS 会社コード, -- 会社コード
	t201m.cd_tenpo AS 店舗コード, -- 店舗コード
	tbv0033m.cd_zon AS ゾーンコード, -- ゾーンコード
	t201m.kj_tentanms AS エリア店舗, -- エリア店舗
	'店舗略称' AS 区分名称 -- 区分名称
FROM  ai21rep_ve_dx.tbv0201m t201m  --共通店舗ＤＢ 
LEFT SEMI JOIN dx_ve.tbi999003m tbi999003m  --店舗展示設定
	ON t201m.cd_hansya = tbi999003m.cd_hansya
	AND t201m.cd_kaisya = tbi999003m.cd_kaisya
	AND t201m.cd_tenpo = tbi999003m.cd_tenpo
	AND tbi999003m.mj_cyohyoid = '016'
	AND tbi999003m.kb_tenji = 1
LEFT JOIN ai21rep_ve_dx.tbv0047m  tbv0047m
    ON tbv0047m.cd_hansya = t201m.cd_hansya
	AND tbv0047m.cd_kaisya = t201m.cd_kaisya
	AND tbv0047m.cd_tenpo = t201m.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbv0033m tbv0033m  --ＭゾーンコードＤＢ 
    ON tbv0033m.cd_hansya = t201m.cd_hansya
	AND tbv0033m.cd_kaisya = t201m.cd_kaisya
	AND tbv0033m.cd_zon = tbv0047m.cd_nczon
	AND tbv0033m.kb_syohin  = '1'
UNION ALL
SELECT
	t201m.cd_hansya AS 販社コード, -- 販社コード
	t201m.cd_kaisya AS 会社コード, -- 会社コード
	t201m.cd_tenpo AS 店舗コード, -- 店舗コード
	tbv0033m.cd_zon AS ゾーンコード, -- ゾーンコード
	tbv0033m.kj_zonmei AS エリア統括部と店舗, -- エリア統括部と店舗
	'ゾーン名称' AS 区分名称 -- 区分名称
FROM  ai21rep_ve_dx.tbv0201m t201m  --共通店舗ＤＢ 
LEFT SEMI JOIN dx_ve.tbi999003m tbi999003m  --店舗展示設定
	ON t201m.cd_hansya = tbi999003m.cd_hansya
	AND t201m.cd_kaisya = tbi999003m.cd_kaisya
	AND t201m.cd_tenpo = tbi999003m.cd_tenpo
	AND tbi999003m.mj_cyohyoid = '016'
	AND tbi999003m.kb_tenji = 1
LEFT JOIN ai21rep_ve_dx.tbv0047m  tbv0047m --M車両店舗DB
    ON tbv0047m.cd_hansya = t201m.cd_hansya
	AND tbv0047m.cd_kaisya = t201m.cd_kaisya
	AND tbv0047m.cd_tenpo = t201m.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbv0033m tbv0033m  --ＭゾーンコードＤＢ 
    ON tbv0033m.cd_hansya = t201m.cd_hansya
	AND tbv0033m.cd_kaisya = t201m.cd_kaisya
	AND tbv0033m.cd_zon = tbv0047m.cd_nczon
	AND tbv0033m.kb_syohin  = '1'
LIMIT 0;

-- [076/099] level=0 target=gold.VBI016011
-- Gold dependencies: none
-- Source file: 016_新車受注分析/vbi016001-vbi016011_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI016011 AS
WITH tbbg068m AS (
    --受注形態マスタＤＢ　
	--販社コード, 会社コード , 問題コード , 検索キー, 答名１ ～ 答名２０　　											WHERE条件：問題コード は商談動機、購入形態（レクサス、トヨタ）かつ新中区分= '1'
	SELECT cd_hansya, cd_kaisya, cd_mondai, '01' AS searchKey, cd_kotaem1 AS cd_kotaem  FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '02' AS searchKey, cd_kotaem2 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '03' AS searchKey, cd_kotaem3 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '04' AS searchKey, cd_kotaem4 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '05' AS searchKey, cd_kotaem5 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '06' AS searchKey, cd_kotaem6 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '07' AS searchKey, cd_kotaem7 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '08' AS searchKey, cd_kotaem8 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '09' AS searchKey, cd_kotaem9 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '10' AS searchKey, cd_kotaem10 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '11' AS searchKey, cd_kotaem11 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '12' AS searchKey, cd_kotaem12 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '13' AS searchKey, cd_kotaem13 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '14' AS searchKey, cd_kotaem14 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '15' AS searchKey, cd_kotaem15 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '16' AS searchKey, cd_kotaem16 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '17' AS searchKey, cd_kotaem17 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '18' AS searchKey, cd_kotaem18 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '19' AS searchKey, cd_kotaem19 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
	UNION ALL
	SELECT cd_hansya, cd_kaisya, cd_mondai, '20' AS searchKey, cd_kotaem20 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
)
	SELECT
		t201m.cd_hansya AS 販社コード, -- 販社コード
		t201m.cd_kaisya AS 会社コード, -- 会社コード
		t201m.cd_tenpo AS 店舗コード, -- 店舗コード
		RANK() OVER (PARTITION BY t201m.cd_hansya,t201m.cd_kaisya ORDER BY IF(NVL(tbv0033m.kj_zonmei,'') = '', 0,1), tbv0033m.kj_zonmei , sort_sub.mj_sortjyun, t201m.cd_tenpo) AS ソート順, -- ソート順
		RANK() OVER (PARTITION BY t201m.cd_hansya, t201m.cd_kaisya ORDER BY sort_car.mj_sortjyun, sort_car.cd_ncsyamei) AS 車名ソート順, -- 車名ソート順
		t201m.kj_tentanms AS 店舗短縮名称, -- 店舗短縮名称
		IF(
		(tbv0033m.cd_zon IS NULL OR regexp_replace(tbv0033m.cd_zon, '[ 　]+', '') = ''),
			IF((tbv0033m.kj_zonmei IS NULL OR regexp_replace(tbv0033m.kj_zonmei, '[ 　]+', '') = ''),
			'999999',
			'999998'
			),
			IF(((tbv0033m.kj_zonmei IS NULL OR regexp_replace(tbv0033m.kj_zonmei, '[ 　]+', '') = '')),
			'999999',
			tbv0033m.cd_zon)
		) AS ゾーンコード, -- ゾーンコード
		tbv0033m.kj_zonmei AS ゾーン名称, -- ゾーン名称
		tbba001g.no_cyumon AS 注文ＮＯ, -- 注文ＮＯ
		tbbf001m.kj_kurumame AS 新車車名, -- 新車車名
		CAST(tbba001g.dd_jucyuke AS DATE) AS 受注計上日, -- 受注計上日
		tbv0229m.mj_guredo AS グレード, -- グレード
		tbbf007m.kn_hinmei AS 品名カナ, -- 品名カナ
		CASE WHEN tbba051g.kb_seibetu ='1' THEN '男' WHEN tbba051g.kb_seibetu ='2' THEN '女' WHEN tbba051g.kb_seibetu = '3' THEN '法人' ELSE NULL END AS 法人個人区分, -- 法人個人区分
		CASE WHEN tbba051g.nu_nenrei >=60 THEN '60歳以上' 
			WHEN tbba051g.nu_nenrei >=50 THEN '50歳代' 
			WHEN tbba051g.nu_nenrei >=40 THEN '40歳代' 
			WHEN tbba051g.nu_nenrei >=30 THEN '30歳代' 
			ELSE '29歳以下' 
		END AS 年齢別, -- 年齢別
		tbbg068m_1.cd_kotaem AS 商談動機, -- 商談動機
		IF(tbbf001m.kb_syasikib='6' , tbbg068m_2.cd_kotaem	, tbbg068m_3.cd_kotaem) AS 購入形態, -- 購入形態
		IF(NVL(tbba003g_group.sitasu,0) = 0 , '無', '有') AS 下取有無, -- 下取有無
		IF(tbv0232m.cd_maker = '01' AND LEFT(tbv0232m.cd_syamei,1) <> 'L' , 'トヨタ' ,IF(tbv0232m.cd_syamei IS NOT NULL,'他メーカー', NULL )  ) AS メーカー区分, -- メーカー区分
		tbv0232m.kj_syamei AS 下取車名, -- 下取車名
		tbv0232m.mj_sysyubur AS 車種分類, -- 車種分類
		(CASE 
		    WHEN CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) < (YEAR(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE)) - 8) THEN
		      CASE 
		        WHEN (YEAR(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE)) - 9) >= 2019 THEN 
		          CONCAT('R', LPAD(CAST((YEAR(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE)) - 2018 - 9) AS STRING), 2, '0'), '～')
		        ELSE 
		          CONCAT('H', LPAD(CAST((YEAR(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE)) - 1988 - 9) AS STRING), 2, '0'), '～')
		      END
		    WHEN CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) >= 2019 THEN
		      CONCAT('R', LPAD(CAST(CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) - 2018 AS STRING), 2, '0'))
		    WHEN CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) >= 1989 THEN
		      CONCAT('H', LPAD(CAST(CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) - 1988 AS STRING), 2, '0'))
		    ELSE
		      NULL
		END) AS 下取車年式, -- 下取車年式
		(CASE 
			WHEN tbv0232m.cd_maker = "01" AND LEFT(tbv0232m.cd_syamei,1) <> 'L' THEN
		        CASE
		        WHEN regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,4})', 0) = 'クラウン' THEN 'クラウン'
		            WHEN regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,4})', 0) = 'プリウス' THEN 'プリウス'
		            WHEN regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,4})', 0) = 'カローラ' THEN 'カローラ'
		            WHEN regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,4})', 0) = 'シエンタ' THEN 'シエンタ'
		            WHEN regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,4})', 0) = 'アイシス' OR regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,3})', 0) = 'ガイア' THEN 'アイシス・ガイア'
		            WHEN regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,5})', 0) = 'エスティマ' THEN 'エスティマ'  
		            WHEN regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,4})', 0) = 'ハリアー' THEN 'ハリアー'
		            ELSE 'その他　トヨタ車'  
		        END
		 	WHEN tbv0232m.cd_hansya IS NOT NULL THEN
		    	CASE
		            WHEN regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,3})', 0) = 'ホンダ' THEN 'ホンダ系'  
		            WHEN LEFT(tbv0232m.cd_syamei, 1) = 'L' THEN 'レクサス' 
		            WHEN regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,3})', 0) = 'スバル' THEN 'スバル系'
		            WHEN regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,4})', 0) = 'ニッサン' THEN 'ニッサン系'
		            WHEN INSTR(tbv0232m.kj_syamei, '輸入車') > 0 THEN '輸入車'
		            ELSE 'その他メーカー' 
		        END
		    ELSE NULL
		END) AS 下取車メーカー -- 下取車メーカー
	FROM ai21rep_ve_dx.tbv0201m t201m  --共通店舗ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbv0047m  tbv0047m
	    ON tbv0047m.cd_hansya = t201m.cd_hansya
		AND tbv0047m.cd_kaisya = t201m.cd_kaisya
		AND tbv0047m.cd_tenpo = t201m.cd_tenpo
	LEFT JOIN ai21rep_ve_dx.tbv0033m tbv0033m  --ＭゾーンコードＤＢ 
	    ON tbv0033m.cd_hansya = t201m.cd_hansya
		AND tbv0033m.cd_kaisya = t201m.cd_kaisya
		AND tbv0033m.cd_zon = tbv0047m.cd_nczon
		AND tbv0033m.kb_syohin  = '1'
	INNER JOIN dx_ve.tbi999003m tbi999003m ON --店舗展示設定
		t201m.cd_hansya = tbi999003m.cd_hansya
		AND t201m.cd_kaisya = tbi999003m.cd_kaisya
		AND t201m.cd_tenpo = tbi999003m.cd_tenpo
		AND tbi999003m.mj_cyohyoid = '016'
		AND tbi999003m.kb_tenji = 1
	INNER JOIN ai21rep_ve_dx.tbba001g tbba001g --新車受注基本情報ＤＢ 
		ON t201m.cd_hansya = tbba001g.cd_hansya
		AND t201m.cd_kaisya = tbba001g.cd_kaisya
		AND t201m.cd_tenpo = tbba001g.cd_tenpo
		AND tbba001g.dd_uritrkkj IS NULL
		AND tbba001g.dd_torikesi IS NULL
		AND tbba001g.dd_jucyuke IS NOT NULL
	LEFT JOIN ai21rep_ve_dx.tbbf008m TBBF008M  --車両スペック２ＤＢ
	    ON tbba001g.cd_kaisya = TBBF008M.cd_kaisya
	    AND tbba001g.cd_hansya = TBBF008M.cd_hansya
	    AND tbba001g.mj_sinkysed = TBBF008M.mj_sinkysed
	    AND tbba001g.mj_gaihansy  = TBBF008M.cd_spec 
	    AND tbba001g.mj_hantenkt  = TBBF008M.mj_hantenkt
	    AND TBBF008M.kb_spec = 'G'
	LEFT  JOIN ai21rep_ve_dx.tbbf001m tbbf001m  --車名ＤＢ 
	    ON tbbf001m.cd_kaisya = TBBF008M.cd_kaisya
	    AND tbbf001m.cd_hansya = TBBF008M.cd_hansya
	    AND tbbf001m.cd_ncsyamei = TBBF008M.mj_syamei
	INNER JOIN  dx_ve.tbi999008m tbi999008m --車種展示設定
		ON tbbf001m.cd_hansya = tbi999008m.cd_hansya
		AND tbbf001m.cd_kaisya = tbi999008m.cd_kaisya
		AND tbbf001m.cd_ncsyamei = tbi999008m.cd_ncsyamei
		AND tbi999008m.kb_tenji = 1
	LEFT JOIN ai21rep_ve_dx.tbbf007m tbbf007m  --車両スペックＤＢ
	    ON tbbf007m.cd_hansya = TBBF008M.cd_hansya
	    AND tbbf007m.cd_kaisya = TBBF008M.cd_kaisya
	    AND tbbf007m.mj_syamei = TBBF008M.mj_syamei
	    AND tbbf007m.kb_spec = TBBF008M.kb_spec
	    AND tbbf007m.cd_spec = TBBF008M.cd_spec
	    AND tbbf007m.no_hinmei = TBBF008M.no_hinmei 
	LEFT JOIN ai21rep_ve_dx.tbba056g tbba056g  --新車お客様詳細情報DB 
	    ON tbba056g.cd_hansya = tbba001g.cd_hansya
	    AND tbba056g.cd_kaisya = tbba001g.cd_kaisya
	    AND tbba056g.no_cyumon = tbba001g.no_cyumon
	    AND TRIM(tbba056g.no_cyumoned) = TRIM(tbba001g.no_cyumoned)
	 LEFT JOIN ai21rep_ve_dx.tbba051g tbba051g --新車受注顧客情報ＤＢ
	     ON tbba051g.cd_hansya = tbba001g.cd_hansya
	    AND tbba051g.cd_kaisya = tbba001g.cd_kaisya
	    AND tbba051g.no_cyumon = tbba001g.no_cyumon
	    AND TRIM(tbba051g.no_cyumoned) = TRIM(tbba001g.no_cyumoned)
	    AND tbba051g.kb_kokyaku = '2'
	LEFT JOIN (
		  SELECT
		     tbba003g.cd_hansya -- 販社コード
		    ,tbba003g.cd_kaisya -- 会社コード
		    ,tbba003g.no_cyumon --注文ＮＯ
		    ,tbba003g.no_cyumoned  --注文ＮＯ枝番
		    ,MAX(su_syndotor) AS su_syndotor  --初年度登録年月
		    ,MAX(tbba003g.cd_sitadosy) AS cd_sitadosy  --下取車名コード
		    ,COUNT(1) AS sitasu	 --下取台数
		  FROM ai21rep_ve_dx.tbba003g tbba003g --受注下取DB
		  WHERE tbba003g.kb_sincyu = '1'  --新中区分 = '1'
		  GROUP BY
		     tbba003g.cd_hansya
		    ,tbba003g.cd_kaisya
		    ,tbba003g.no_cyumon
		    ,tbba003g.no_cyumoned
		) tbba003g_group
		ON tbba001g.cd_hansya = tbba003g_group.cd_hansya
		AND tbba001g.cd_kaisya = tbba003g_group.cd_kaisya
		AND tbba001g.no_cyumon = tbba003g_group.no_cyumon
		AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba003g_group.no_cyumoned)
	LEFT JOIN ai21rep_ve_dx.tbv0232m tbv0232m --ａｉ２１車名コードＤＢ
	    ON tbv0232m.cd_hansya = tbba003g_group.cd_hansya
	    AND tbv0232m.cd_kaisya = tbba003g_group.cd_kaisya
	    AND tbv0232m.cd_syamei = tbba003g_group.cd_sitadosy 
	LEFT JOIN ai21rep_ve_dx.tbv0229m tbv0229m  --指定類別ＤＢ
	    ON tbv0229m.cd_hansya = tbba001g.cd_hansya
		AND tbv0229m.cd_kaisya = tbba001g.cd_kaisya
		AND tbv0229m.no_siteruib = tbba001g.no_siteruib	
	 LEFT JOIN tbbg068m tbbg068m_1 --受注形態マスタＤＢ
	 	ON tbbg068m_1.cd_hansya = tbba056g.cd_hansya
	 	AND tbbg068m_1.cd_kaisya = tbba056g.cd_kaisya
	 	AND tbba056g.mj_jucyuke1=tbbg068m_1.searchKey  
	 	AND tbbg068m_1.cd_mondai  = '101'
	 LEFT JOIN tbbg068m tbbg068m_2 --受注形態マスタＤＢ
	  ON tbbg068m_2.cd_hansya = tbba056g.cd_hansya
	 	AND tbbg068m_2.cd_kaisya = tbba056g.cd_kaisya
	 	AND tbba056g.mj_jucyuk11=tbbg068m_2.searchKey  
	 	AND tbbg068m_2.cd_mondai  = '111'
	 LEFT JOIN tbbg068m tbbg068m_3 --受注形態マスタＤＢ
	   ON tbbg068m_3.cd_hansya = tbba056g.cd_hansya
	 	AND tbbg068m_3.cd_kaisya = tbba056g.cd_kaisya
	 	AND tbba056g.mj_jucyuke4=tbbg068m_3.searchKey
	 	AND tbbg068m_3.cd_mondai  = '104'
 LEFT JOIN  (SELECT	kj_tentanms, -- 店舗短縮名称
					 t201m_2.cd_hansya,  --販社コード
					 t201m_2.cd_kaisya,	 --会社コード
 					MIN(tbi999003m.mj_sortjyun) AS mj_sortjyun  --ソート順
 		FROM ai21rep_ve_dx.tbv0201m t201m_2
	 	INNER JOIN dx_ve.tbi999003m tbi999003m  --店舗展示設定
			ON t201m_2.cd_hansya = tbi999003m.cd_hansya
			AND t201m_2.cd_kaisya = tbi999003m.cd_kaisya
			AND t201m_2.cd_tenpo = tbi999003m.cd_tenpo
			AND tbi999003m.mj_cyohyoid = '016'
			AND tbi999003m.kb_tenji = 1
		GROUP BY 
			t201m_2.cd_hansya,
			t201m_2.cd_kaisya,
			kj_tentanms		
		) sort_sub
	ON t201m.cd_hansya = sort_sub.cd_hansya
    AND t201m.cd_kaisya = sort_sub.cd_kaisya
	AND sort_sub.kj_tentanms=t201m.kj_tentanms
 LEFT JOIN (SELECT	
				 tbi999008m.cd_hansya, --販社コード
				 tbi999008m.cd_kaisya, --会社コード
				 TRIM(tbi999008m.kj_kurumame) AS kj_kurumame, --漢字車名
				 MIN(tbi999008m.mj_sortjyun) AS mj_sortjyun, --ソート順
				 MIN(tbi999008m.cd_ncsyamei) AS cd_ncsyamei --新車車名コード
 		FROM dx_ve.tbi999008m tbi999008m  --車種展示設定
		WHERE tbi999008m.kb_tenji = 1 --展示区分 = 1
		GROUP BY 
			tbi999008m.cd_hansya,
			tbi999008m.cd_kaisya,
			TRIM(tbi999008m.kj_kurumame)
		) sort_car
	ON tbbf001m.cd_hansya = sort_car.cd_hansya
    AND tbbf001m.cd_kaisya = sort_car.cd_kaisya
	AND TRIM(tbbf001m.kj_kurumame) = TRIM(sort_car.kj_kurumame)
	WHERE NOT (t201m.kj_tenpomei LIKE '%廃）%' AND tbba001g.cd_hansya IS NULL)
LIMIT 0;

-- [077/099] level=0 target=gold.vbi017001
-- Gold dependencies: none
-- Source file: 017_新車実績一覧(スタッフ別・店舗別)/新車実績一覧（スタッフ別・店舗別）_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi017001 AS
SELECT
	--販社コード
	cd_hansya,
	--会社コード
	cd_kaisya,
	--店舗コード
	cd_tenpo,
	--店舗名称
	kj_tenpomei,
	--販売スタッフコード
	cd_hanstaff,
	--社員名
	kj_syainmei,
	--月
	month,
	--受注
	SUM(su_jucyu) AS 'su_jucyu',
	--受注キャンセル反映
	SUM(su_jucyu) - SUM(su_jucyucancel) AS 'su_jucyucancelhane',
	--受注除軽
	SUM(su_jucyujyokei) AS 'su_jucyujyokei',
	--受注除軽キャンセル反映
	SUM(su_jucyujyokei) - SUM(su_jucyucanceljyokei) AS 'su_jucyucanceljyokeihane',
	--割賦
	SUM(su_kap) AS 'su_kap',
	--メンテナンスパック
	SUM(su_maintenancepack) AS 'su_maintenancepack',
	--下取り
	SUM(su_sitadori) AS 'su_sitadori'
FROM
(
	SELECT 
		--販社コード
		t001g.cd_hansya,
		--会社コード
		t001g.cd_kaisya,
		--店舗コード
		t001g.cd_tenpo,
		--店舗名称
		regexp_replace(t0201m.kj_tenpomei, '　+$', '') AS 'kj_tenpomei',
		--販売スタッフコード
		t001g.cd_hanstaff,
		--社員名
		regexp_replace(t014m.kj_syainmei, '　+$', '') AS 'kj_syainmei',
		--月
		IF(t001g.dd_jucyuke >= trunc(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'MM'),'当月','前月') AS 'month',
		--受注
		1 AS 'su_jucyu',
		--受注取消
		0 AS 'su_jucyucancel',
		--受注除軽
		IF(t001m.kn_kei <> '1',1,0) AS 'su_jucyujyokei',
		--受注取消除軽
		0 AS 'su_jucyucanceljyokei',
		--割賦
		--新車受注販売条件情報ＤＢ.支払区分 = 2
		IF(t052g.kb_siharai = '2',1 ,0) AS 'su_kap',
		--メンテナンスパック
		--新車受注販売条件情報ＤＢ.メンテナンスパック契約区分 <> 空
		IF(t052g.kb_mntpkkei IS NOT NULL
			AND REPLACE(REPLACE(t052g.kb_mntpkkei, '　', ''), ' ', '') != '',1 ,0) AS 'su_maintenancepack',
		--下取り
		--新車受注販売条件情報ＤＢ.下取台数 > 0
		IF(t052g.su_sitadori > 0, 1, 0) AS 'su_sitadori'
	-- 新車受注基本情報ＤＢ
	FROM ai21rep_ve_dx.tbba001g t001g
	--新車受注販売条件情報ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbba052g t052g
		ON t052g.cd_kaisya = t001g.cd_kaisya
	    AND t052g.cd_hansya = t001g.cd_hansya
	    AND t052g.no_cyumon = t001g.no_cyumon
	    AND TRIM(t052g.no_cyumoned) = TRIM(t001g.no_cyumoned)
	--M社員ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbv0014m t014m
		ON t014m.cd_kaisya = t001g.cd_kaisya
	    AND t014m.cd_hansya = t001g.cd_hansya
	    AND t014m.cd_syain = t001g.cd_hanstaff
	-- 車両スペック２ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbbf008m t008m
		ON t001g.cd_kaisya = t008m.cd_kaisya
		AND t001g.cd_hansya = t008m.cd_hansya
		AND t001g.mj_sinkysed = t008m.mj_sinkysed
		AND t001g.mj_gaihansy = t008m.cd_spec 
		AND t001g.mj_hantenkt  = t008m.mj_hantenkt 
		AND t008m.kb_spec = 'G'
	--車名ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbbf001m t001m
		ON t001m.cd_kaisya = t008m.cd_kaisya
		AND t001m.cd_hansya = t008m.cd_hansya
		AND t001m.cd_ncsyamei = t008m.mj_syamei 
	--共通店舗ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbv0201m t0201m
		ON t0201m.cd_kaisya = t001g.cd_kaisya
	    AND t0201m.cd_hansya = t001g.cd_hansya
	    AND t0201m.cd_tenpo = t001g.cd_tenpo
    -- 店舗表示設定
	LEFT SEMI JOIN dx_ve.tbi999003m
		ON tbi999003m.cd_kaisya = t001g.cd_kaisya
	    AND tbi999003m.cd_hansya = t001g.cd_hansya
	    AND tbi999003m.cd_tenpo = t001g.cd_tenpo
	    AND tbi999003m.mj_cyohyoid = '017'
	    AND tbi999003m.kb_tenji = 1
	WHERE 
	    -- [払出区分] <> "00" AND [払出区分] <> "40"
	    t001g.kb_haraidas NOT IN ('00', '40')
	    AND 
		-- 受注計上日 >= 先月
		t001g.dd_jucyuke >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
	UNION ALL
	SELECT
		--販社コード
		t001g.cd_hansya,
		--会社コード
		t001g.cd_kaisya,
		--店舗コード
		t001g.cd_tenpo,
		--店舗名称
		regexp_replace(t0201m.kj_tenpomei, '　+$', '') AS 'kj_tenpomei',
		--販売スタッフコード
		t001g.cd_hanstaff,
		--社員名
		regexp_replace(t014m.kj_syainmei, '　+$', '') AS 'kj_syainmei',
		--月
		IF(t001g.dd_torikesi >= trunc(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'MM'),'当月','前月') AS 'month',
		--受注
		0 AS 'su_jucyu',
		--受注取消
		1 AS 'su_jucyucancel',
		--受注除軽
		0 AS 'su_jucyujyokei',
		--受注取消除軽
		IF(t001m.kn_kei <> '1',1,0) AS 'su_jucyucanceljyokei',
		--割賦
		0 AS 'su_kap',
		--メンテナンスパック
		0 AS 'su_maintenancepack',
		--下取り
		0 AS 'su_sitadori'
	FROM
	--新車受注基本情報ＤＢ
	ai21rep_ve_dx.tbba001g t001g
	-- M社員ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbv0014m t014m
		ON t014m.cd_kaisya = t001g.cd_kaisya
	    AND t014m.cd_hansya = t001g.cd_hansya
	    AND t014m.cd_syain = t001g.cd_hanstaff
	-- 車両スペック２ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbbf008m t008m
		ON t001g.cd_kaisya = t008m.cd_kaisya
		AND t001g.cd_hansya = t008m.cd_hansya
		AND t001g.mj_sinkysed = t008m.mj_sinkysed
		AND t001g.mj_gaihansy = t008m.cd_spec 
		AND t001g.mj_hantenkt  = t008m.mj_hantenkt 
		AND t008m.kb_spec = 'G'
	--車名ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbbf001m t001m
		ON t001m.cd_kaisya = t008m.cd_kaisya
		AND t001m.cd_hansya = t008m.cd_hansya
		AND t001m.cd_ncsyamei = t008m.mj_syamei
	-- 共通店舗ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbv0201m t0201m
		ON t0201m.cd_kaisya = t001g.cd_kaisya
	    AND t0201m.cd_hansya = t001g.cd_hansya
	    AND t0201m.cd_tenpo = t001g.cd_tenpo
    -- 店舗表示設定
	LEFT SEMI JOIN dx_ve.tbi999003m
		ON tbi999003m.cd_kaisya = t001g.cd_kaisya
	    AND tbi999003m.cd_hansya = t001g.cd_hansya
	    AND tbi999003m.cd_tenpo = t001g.cd_tenpo
	    AND tbi999003m.mj_cyohyoid = '017'
	    AND tbi999003m.kb_tenji = 1
	WHERE 
	 	-- [払出区分] <> "00" AND [払出区分] <> "40"
	    t001g.kb_haraidas NOT IN ('00', '40')
	    -- 取消日 >= 先月
	    AND t001g.dd_torikesi >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
)combined
GROUP BY
	cd_hansya,
	cd_kaisya,
	cd_tenpo,
	kj_tenpomei,
	cd_hanstaff,
	kj_syainmei,
	month
LIMIT 0;

-- [078/099] level=0 target=gold.vbi017002
-- Gold dependencies: none
-- Source file: 017_新車実績一覧(スタッフ別・店舗別)/新車実績一覧（スタッフ別・店舗別）_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi017002 AS
SELECT 
	--販社コード
	cd_hansya,
	--会社コード
	cd_kaisya,
	--店舗コード
	cd_tenpo,
	--店舗名称
	kj_tenpomei,
	--販売スタッフコード
	cd_hanstaff,
	--社員名
	kj_syainmei,
	--月
	month,
	--販売
	SUM(su_hanbai) AS 'su_hanbai',
	--販売キャンセル反映
	SUM(su_hanbai) - SUM(su_hanbaicancel) AS 'su_hanbaicancelhane',
	--販売除軽
	SUM(su_hanbaijyokei) AS 'su_hanbaijyokei',
	--販売除軽キャンセル反映
	SUM(su_hanbaijyokei) - SUM(su_hanbaicanceljyokei) AS 'su_hanbaicanceljyokeihene'
FROM
(
	SELECT
		--販社コード
		t001g.cd_hansya,
		--会社コード
		t001g.cd_kaisya,
		--店舗コード
		t001g.cd_tenpo,
		--店舗名称
		regexp_replace(t0201m.kj_tenpomei, '　+$', '') AS 'kj_tenpomei',
		--販売スタッフコード
		t001g.cd_hanstaff,
		--社員名
		regexp_replace(t014m.kj_syainmei, '　+$', '') AS 'kj_syainmei',
		--月
		IF(IF(ft168g.dd_torokei IS NULL, t001g.dd_uriagekj, ft168g.dd_torokei) >= trunc(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'MM'),'当月','前月') AS 'month',
		--販売
		1 AS 'su_hanbai',
		--販売取消
		0 AS 'su_hanbaicancel',
		--販売除軽
		IF(t001m.kn_kei <> '1',1,0) AS 'su_hanbaijyokei',
		--販売取消除軽
		0 AS 'su_hanbaicanceljyokei'
	FROM
	--新車受注基本情報ＤＢ
	ai21rep_ve_dx.tbba001g t001g
	-- 履歴登録ＤＢ
	LEFT JOIN 
		(
	        SELECT
				--販社コード
	            t168g.cd_hansya,
				--会社コード
	            t168g.cd_kaisya,
				--注文ＮＯ
	            t168g.no_cyumon,
				--注文ｎｏ枝番
				t168g.no_cyumoned,
				--登録計上日
	            min(t168g.dd_torokei) as dd_torokei
	        FROM ai21rep_ve_dx.tbbg168g t168g  
	        WHERE 
	            t168g.no_gyomu = '07'
	        AND t168g.no_syori = '01'
	        GROUP BY t168g.cd_hansya,t168g.cd_kaisya, t168g.no_cyumon, t168g.no_cyumoned
	    ) ft168g 
	    ON ft168g.cd_kaisya = t001g.cd_kaisya
	    AND ft168g.cd_hansya = t001g.cd_hansya
	    AND ft168g.no_cyumon = t001g.no_cyumon
	    AND TRIM(ft168g.no_cyumoned) = TRIM(t001g.no_cyumoned)
	-- 車両スペック２ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbbf008m t008m
		ON t001g.cd_kaisya = t008m.cd_kaisya
		AND t001g.cd_hansya = t008m.cd_hansya
		AND t001g.mj_sinkysed = t008m.mj_sinkysed
		AND t001g.mj_gaihansy = t008m.cd_spec 
		AND t001g.mj_hantenkt  = t008m.mj_hantenkt 
		AND t008m.kb_spec = 'G'
	--車名ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbbf001m t001m
		ON t001m.cd_kaisya = t008m.cd_kaisya
		AND t001m.cd_hansya = t008m.cd_hansya
		AND t001m.cd_ncsyamei = t008m.mj_syamei 
	-- M社員ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbv0014m t014m
		ON t014m.cd_kaisya = t001g.cd_kaisya
	    AND t014m.cd_hansya = t001g.cd_hansya
	    AND t014m.cd_syain = t001g.cd_hanstaff
	-- 共通店舗ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbv0201m t0201m
		ON t0201m.cd_kaisya = t001g.cd_kaisya
	    AND t0201m.cd_hansya = t001g.cd_hansya
	    AND t0201m.cd_tenpo = t001g.cd_tenpo
    -- 店舗表示設定
	LEFT SEMI JOIN dx_ve.tbi999003m
		ON tbi999003m.cd_kaisya = t001g.cd_kaisya
	    AND tbi999003m.cd_hansya = t001g.cd_hansya
	    AND tbi999003m.cd_tenpo = t001g.cd_tenpo
	    AND tbi999003m.mj_cyohyoid = '017'
	    AND tbi999003m.kb_tenji = 1
	WHERE 
	 	-- [払出区分] <> "00" AND [払出区分] <> "40"
	    t001g.kb_haraidas NOT IN ('00', '40')
	    --受注計上日≠NULL
	    AND t001g.dd_jucyuke IS NOT NULL
	    AND (
			(ft168g.dd_torokei >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM'))
			OR
			(ft168g.dd_torokei IS NULL AND t001g.dd_uriagekj >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM'))	
	    )
	UNION ALL
	SELECT
		--販社コード
		t001g.cd_hansya,
		--会社コード
		t001g.cd_kaisya,
		--店舗コード
		t001g.cd_tenpo,
		--店舗名称
		regexp_replace(t0201m.kj_tenpomei, '　+$', '') AS 'kj_tenpomei',
		--販売スタッフコード
		t001g.cd_hanstaff,
		--社員名
		regexp_replace(t014m.kj_syainmei, '　+$', '') AS 'kj_syainmei',
		--月
		IF(t001g.dd_uritrkkj >= trunc(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'MM'),'当月','前月') AS 'month',
		--販売
		0 AS 'su_hanbai',
	    --販売取消
		1 AS 'su_hanbaicancel',
	    --販売除軽
		0 AS 'su_hanbaijyokei',
		--販売取消除軽
		IF(t001m.kn_kei <> '1',1,0) AS 'su_hanbaicanceljyokei'
	FROM
	--新車受注基本情報ＤＢ
	ai21rep_ve_dx.tbba001g t001g
	-- M社員ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbv0014m t014m
		ON t014m.cd_kaisya = t001g.cd_kaisya
	    AND t014m.cd_hansya = t001g.cd_hansya
	    AND t014m.cd_syain = t001g.cd_hanstaff
	-- 車両スペック２ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbbf008m t008m
		ON t001g.cd_kaisya = t008m.cd_kaisya
		AND t001g.cd_hansya = t008m.cd_hansya
		AND t001g.mj_sinkysed = t008m.mj_sinkysed
		AND t001g.mj_gaihansy = t008m.cd_spec 
		AND t001g.mj_hantenkt  = t008m.mj_hantenkt 
		AND t008m.kb_spec = 'G'
	--車名ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbbf001m t001m
		ON t001m.cd_kaisya = t008m.cd_kaisya
		AND t001m.cd_hansya = t008m.cd_hansya
		AND t001m.cd_ncsyamei = t008m.mj_syamei 
	-- 共通店舗ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbv0201m t0201m
		ON t0201m.cd_kaisya = t001g.cd_kaisya
	    AND t0201m.cd_hansya = t001g.cd_hansya
	    AND t0201m.cd_tenpo = t001g.cd_tenpo
    -- 店舗表示設定
	LEFT SEMI JOIN dx_ve.tbi999003m
		ON tbi999003m.cd_kaisya = t001g.cd_kaisya
	    AND tbi999003m.cd_hansya = t001g.cd_hansya
	    AND tbi999003m.cd_tenpo = t001g.cd_tenpo
	    AND tbi999003m.mj_cyohyoid = '017'
	    AND tbi999003m.kb_tenji = 1
	WHERE 
	 	-- [払出区分] <> "00" AND [払出区分] <> "40"
	    t001g.kb_haraidas NOT IN ('00', '40')
	    --受注計上日≠NULL
	    AND t001g.dd_jucyuke IS NOT NULL
	    AND t001g.dd_uritrkkj >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
)combined
GROUP BY
	--販社コード
	cd_hansya,
	--会社コード
	cd_kaisya,
	--店舗コード
	cd_tenpo,
	--店舗名称
	kj_tenpomei,
	--販売スタッフコード
	cd_hanstaff,
	--社員名
	kj_syainmei,
	--月
	month
LIMIT 0;

-- [079/099] level=1 target=gold.vbi017003
-- Gold dependencies: gold.vbi017001, gold.vbi017002
-- Source file: 017_新車実績一覧(スタッフ別・店舗別)/新車実績一覧（スタッフ別・店舗別）_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi017003 AS
SELECT 
	--販社コード
	t.cd_hansya AS '販社コード',
	--会社コード
	t.cd_kaisya AS '会社コード',
	--店舗コード
	t.cd_tenpo AS '店舗コード',
	--店舗名称
	t.kj_tenpomei AS '店舗名称',
	--販売スタッフコード
	t.cd_hanstaff AS '販売スタッフコード',
	--社員名
	t.kj_syainmei AS '社員名',
	--月
	t.month AS '月',
	--受注
	t.su_jucyu AS '受注',
	--受注キャンセル反映
	t.su_jucyucancelhane AS '受注キャンセル反映',
	--受注除軽
	t.su_jucyujyokei AS '受注除軽',
	--受注除軽キャンセル反映
	t.su_jucyucanceljyokeihane AS '受注除軽キャンセル反映',
	--販売
	t.su_hanbai AS '販売',
	--販売キャンセル反映
	t.su_hanbaicancelhane AS '販売キャンセル反映',
	--販売除軽
	t.su_hanbaijyokei AS '販売除軽',
	--販売除軽キャンセル反映
	t.su_hanbaicanceljyokeihene AS '販売除軽キャンセル反映',
	--割賦
	t.su_kap AS '割賦',
	--メンテナンスパック
	t.su_maintenancepack AS 'メンテナンスパック',
	--下取り
	t.su_sitadori AS '下取り',
	--ソート順
	rank() over (partition by t.cd_hansya,t.cd_kaisya order by tbi999003m.mj_sortjyun , t.cd_tenpo) as 'ソート順'
FROM 
(
	SELECT 
		--販社コード
		cd_hansya,
		--会社コード
		cd_kaisya,
		--店舗コード
		cd_tenpo,
		--店舗名称
		kj_tenpomei,
		--販売スタッフコード
		cd_hanstaff,
		--社員名
		kj_syainmei,
		--月
		month,
		--受注
		SUM(su_jucyu) AS 'su_jucyu',
		--受注キャンセル反映
		SUM(su_jucyucancelhane) AS 'su_jucyucancelhane',
		--受注除軽
		SUM(su_jucyujyokei) AS 'su_jucyujyokei',
		--受注除軽キャンセル反映
		SUM(su_jucyucanceljyokeihane) AS 'su_jucyucanceljyokeihane',
		--販売
		SUM(su_hanbai) AS 'su_hanbai',
		--販売キャンセル反映
		SUM(su_hanbaicancelhane) AS 'su_hanbaicancelhane',
		--販売除軽
		SUM(su_hanbaijyokei) AS 'su_hanbaijyokei',
		--販売除軽キャンセル反映
		SUM(su_hanbaicanceljyokeihene) AS 'su_hanbaicanceljyokeihene',
		--割賦
		SUM(su_kap) AS 'su_kap',
		--メンテナンスパック
		SUM(su_maintenancepack) AS 'su_maintenancepack',
		--下取り
		SUM(su_sitadori) AS 'su_sitadori'
	FROM
	(
		SELECT
			--販社コード
			cd_hansya,
			--会社コード
			cd_kaisya,
			--店舗コード
			cd_tenpo,
			--店舗名称
			kj_tenpomei,
			--販売スタッフコード
			cd_hanstaff,
			--社員名
			kj_syainmei,
			--月
			month,
			--受注
			su_jucyu,
			--受注キャンセル反映
			su_jucyucancelhane,
			--受注除軽
			su_jucyujyokei,
			--受注除軽キャンセル反映
			su_jucyucanceljyokeihane,
			--販売
			0 AS 'su_hanbai',
			--販売キャンセル反映
			0 AS 'su_hanbaicancelhane',
			--販売除軽
			0 AS 'su_hanbaijyokei',
			--販売除軽キャンセル反映
			0 AS 'su_hanbaicanceljyokeihene',
			--割賦
			su_kap,
			--メンテナンスパック
			su_maintenancepack,
			--下取り
			su_sitadori
		FROM gold.vbi017001
		UNION ALL
		SELECT 
			--販社コード
			cd_hansya,
			--会社コード
			cd_kaisya,
			--店舗コード
			cd_tenpo,
			--店舗名称
			kj_tenpomei,
			--販売スタッフコード
			cd_hanstaff,
			--社員名
			kj_syainmei,
			--月
			month,
			--受注
			0 AS 'su_jucyu',
			--受注キャンセル反映
			0 AS 'su_jucyucancelhane',
			--受注除軽
			0 AS 'su_jucyujyokei',
			--受注除軽キャンセル反映
			0 AS 'su_jucyucanceljyokeihane',
			--販売
			su_hanbai,
			--販売キャンセル反映
			su_hanbaicancelhane,
			--販売除軽
			su_hanbaijyokei,
			--販売除軽キャンセル反映
			su_hanbaicanceljyokeihene,
			--割賦
			0 AS 'su_kap',
			--メンテナンスパック
			0 AS 'su_maintenancepack',
			--下取り
			0 AS 'su_sitadori'
		FROM gold.vbi017002
	)combined
	GROUP BY
		--販社コード
		cd_hansya,
		--会社コード
		cd_kaisya,
		--店舗コード
		cd_tenpo,
		--店舗名称
		kj_tenpomei,
		--販売スタッフコード
		cd_hanstaff,
		--社員名
		kj_syainmei,
		--月
		month
)t
-- 店舗表示設定
INNER JOIN dx_ve.tbi999003m
	ON tbi999003m.cd_kaisya = t.cd_kaisya
	AND tbi999003m.cd_hansya = t.cd_hansya
	AND tbi999003m.cd_tenpo = t.cd_tenpo
	AND tbi999003m.mj_cyohyoid = '017'
	AND tbi999003m.kb_tenji = 1
LIMIT 0;

-- [080/099] level=0 target=gold.enoreport_full_fixed
-- Gold dependencies: none
-- Source file: 018_NEO/enoreport_full_fixed_gold.sql

CREATE TABLE IF NOT EXISTS gold.enoreport_full_fixed AS
WITH base AS (
SELECT
     tbba001g.cd_hansya    AS 販社コード
    ,tbba001g.cd_kaisya    AS 会社コード
    ,tbba001g.no_cyumon    AS 注文ＮＯ
    ,tbba001g.no_cyumoned  AS 注文ＮＯ枝番
    ,tbba001g.dd_haisoyot  AS 配送予定日
    ,tbba001g.dd_nosya     AS 納車日
    ,COALESCE(REGEXP_REPLACE(tbba001g.kj_kainmei1, '^[ 　]+|[ 　]+$', ''),'') || COALESCE(REGEXP_REPLACE(tbba001g.kj_kainmei2, '^[ 　]+|[ 　]+$', ''),'') AS 買主名漢字
    ,COALESCE(REGEXP_REPLACE(tbba001g.KJ_MEIGIME1, '^[ 　]+|[ 　]+$', ''),'') || COALESCE(REGEXP_REPLACE(tbba001g.KJ_MEIGIME2, '^[ 　]+|[ 　]+$', ''),'') AS 名義人名漢字
    ,tbba001g.mj_hantenkt  AS 販売店型式
    ,tbba001g.mj_gaihansy  AS 外鈑色
    ,tbba001g.dd_jucyuke   AS 受注計上日
    --,tbba001g.dd_fr        AS 振当日
    ,tbba008g.kb_zaikojyo AS 'tbba008g.在庫状態区分'
    ,CAST(TO_TIMESTAMP(CAST(tbba008g.dd_karinoki AS STRING), 'yyyyMMdd') AS DATE)  AS 'tbba008g.仮納期'
    ,CAST(TO_TIMESTAMP(CAST(tbba008g.dd_kansei AS STRING), 'yyyyMMdd') AS DATE) AS 'tbba008g.完成予定日'
    ,CAST(TO_TIMESTAMP(CAST(tbba008g.dd_haisyyo AS STRING), 'yyyyMMdd') AS DATE) AS 'tbba008g.配車予定日'
    ,tbba008g.dd_orderjur AS 'tbba008g.オーダー受理日'
    ,tbba035g.su_nokikasn  AS 'tbba035g.仮納期加算日数'
    ,tbba035g.su_kanseiks  AS 'tbba035g.完成予定日加算日数'
    ,tbba035g.su_kakunoki  AS 'tbba035g.確定納期加算日数'
    ,tbz0002c.dd_job  AS 'tbz0002c.ジョブ日付'
    ,TRUNC(ADD_MONTHS(tbz0002c.dd_job, -1), 'MM') AS `前月1日`
    ,'' AS 振当日
    ,CASE WHEN tbba001g.dd_zjfryote IS NOT NULL THEN '予' ELSE NULL END AS 振当予定
    ,tbv0200m.kj_kaisyatn  AS 販売店名
    ,tbv0014m.kj_syainmei  AS 社員名
    ,tbbf001m.kj_kurumame  AS 車名
    ,tbba001g.no_syadaiba      AS 車台番号
    ,tbba001g.dd_touroku       AS 登録日
    ,tbba001g.no_palkanri      AS   'tbba001g.ＰＡＬ管理ＮＯ'
    ,tbba001g.no_kanri         AS   'tbba001g.管理ＮＯ'
    ,tbba001g.no_yoyaku        AS   'tbba001g.予約ＮＯ'
    ,tbba001g.su_juchudai      AS   'tbba001g.受注台数'
    ,tbba001g.cd_zon           AS   'tbba001g.ゾーンコード'
    ,tbba001g.cd_tenpo         AS   'tbba001g.店舗コード'
    ,tbba001g.cd_ka            AS   'tbba001g.課コード'
    ,tbba001g.cd_kakari        AS   'tbba001g.係コード'
    ,tbba001g.kb_yoyaku        AS   'tbba001g.予約区分'
    ,tbba001g.cd_hanstaff      AS   'tbba001g.販売スタッフコード'
    ,tbba001g.mj_hantenkt      AS   'tbba001g.販売店型式'
    ,tbba001g.mj_sinkysed      AS   'tbba001g.新旧世代'
    ,tbba001g.no_syadaiba      AS   'tbba001g.車台番号'
    ,tbba001g.no_siteruib      AS   'tbba001g.指定類別番号'
    ,tbba001g.mj_gaihansy      AS   'tbba001g.外鈑色'
    ,tbba001g.mj_iropadng      AS   'tbba001g.色パディング'
    ,tbba001g.cd_utihari       AS   'tbba001g.内張コード'
    ,tbba001g.cd_taiya         AS   'tbba001g.タイヤコード'
    ,tbba001g.mj_taiyacom      AS   'tbba001g.タイヤコメント'
    ,tbba001g.mj_makeop1       AS   'tbba001g.メーカーＯＰＴ１'
    ,tbba001g.mj_makeop2       AS   'tbba001g.メーカーＯＰＴ２'
    ,tbba001g.mj_makeop3       AS   'tbba001g.メーカーＯＰＴ３'
    ,tbba001g.mj_makeop4       AS   'tbba001g.メーカーＯＰＴ４'
    ,tbba001g.mj_makeop5       AS   'tbba001g.メーカーＯＰＴ５'
    ,tbba001g.mj_makeop6       AS   'tbba001g.メーカーＯＰＴ６'
    ,tbba001g.mj_makeop7       AS   'tbba001g.メーカーＯＰＴ７'
    ,tbba001g.mj_makeop8       AS   'tbba001g.メーカーＯＰＴ８'
    ,tbba001g.mj_makeop9       AS   'tbba001g.メーカーＯＰＴ９'
    ,tbba001g.mj_makeop10      AS   'tbba001g.メーカーＯＰＴ１０'
    ,tbba001g.mj_makeop11      AS   'tbba001g.メーカーＯＰＴ１１'
    ,tbba001g.mj_makeop12      AS   'tbba001g.メーカーＯＰＴ１２'
    ,tbba001g.mj_makeop13      AS   'tbba001g.メーカーＯＰＴ１３'
    ,tbba001g.mj_makeop14      AS   'tbba001g.メーカーＯＰＴ１４'
    ,tbba001g.mj_makeop15      AS   'tbba001g.メーカーＯＰＴ１５'
    ,tbba001g.mj_makeop16      AS   'tbba001g.メーカーＯＰＴ１６'
    ,tbba001g.kb_haraidas      AS   'tbba001g.払出区分'
    ,tbba001g.kb_yoto          AS   'tbba001g.用途区分'
    ,tbba001g.kb_toroku        AS   'tbba001g.登録区分'
    ,tbba001g.kb_genmen        AS   'tbba001g.減免区分'
    ,tbba001g.kb_jcsinpo       AS   'tbba001g.受注進捗区分'
    ,tbba001g.kb_torokkah      AS   'tbba001g.登録可否区分'
    ,tbba001g.kb_jibaeigy      AS   'tbba001g.自賠営業用区分'
    ,tbba001g.no_tysenkib      AS   'tbba001g.抽選希望ＮＯ'
    ,tbba001g.no_ipankibo      AS   'tbba001g.一般希望ＮＯ'
    ,tbba001g.mj_jikosiki      AS   'tbba001g.字光式'
    ,tbba001g.mj_nosybas       AS   'tbba001g.納車場所'
    ,tbba001g.mj_syateira      AS   'tbba001g.車両手配依頼'
    ,tbba001g.dd_syrythir      AS   'tbba001g.車両手配依頼日'
    ,tbba001g.cd_kainusig      AS   'tbba001g.買主業者コード'
    ,tbba001g.kb_gyosynys      AS   'tbba001g.業者名寄せ区分'
    ,tbba001g.kj_kainmei1      AS   'tbba001g.買主名漢字１'
    ,tbba001g.kj_kainmei2      AS   'tbba001g.買主名漢字２'
    ,tbba001g.kj_meigime1      AS   'tbba001g.名義人名漢字１'
    ,tbba001g.kj_meigime2      AS   'tbba001g.名義人名漢字２'
    ,tbba001g.mj_kainmgka      AS   'tbba001g.買主名義人関係'
    ,tbba001g.mj_siyohonk      AS   'tbba001g.使用本拠地'
    ,tbba001g.mj_siyohnkk      AS   'tbba001g.使用本拠地小字'
    ,tbba001g.kj_siyohonk      AS   'tbba001g.使用本拠地名'
    ,tbba001g.kb_syokenry      AS   'tbba001g.所有権留保区分'
    ,tbba001g.kb_tasnowko      AS   'tbba001g.多降雪控除区分'
    ,tbba001g.kb_ritojiba      AS   'tbba001g.離島自賠責区分'
    ,tbba001g.mj_cymonm1       AS   'tbba001g.注文メモ１'
    ,tbba001g.mj_cymonm2       AS   'tbba001g.注文メモ２'
    ,tbba001g.mj_cymonnin      AS   'tbba001g.注文任意メモ'
    ,tbba001g.cd_teritbsy      AS   'tbba001g.テリトリ部署コード'
    ,tbba001g.kb_tyonou        AS   'tbba001g.直納区分'
    ,tbba001g.mj_tntbusen      AS   'tbba001g.担当物流センター'
    ,tbba001g.kj_tuikomem      AS   'tbba001g.追工メモ'
    ,tbba001g.mj_freeto        AS   'tbba001g.フリート'
    ,tbba001g.mj_reigai        AS   'tbba001g.例外'
    ,tbba001g.mj_jucyhkok      AS   'tbba001g.受注報告一覧出力済ＦＬＧ'
    ,tbba001g.kb_yudamhab      AS   'tbba001g.有玉販売区分'
    ,tbba001g.dd_frjknkab      AS   'tbba001g.振当条件完備日'
    ,tbba001g.dd_paltymsk      AS   'tbba001g.ＰＡＬ注文書作成日'
    ,tbba001g.dd_jucyuhas      AS   'tbba001g.受注発生日'
    ,tbba001g.dd_jucyuke       AS   'tbba001g.受注計上日'
    ,tbba001g.dd_jucyu         AS   'tbba001g.受注日'
    ,tbba001g.dd_jokenhen      AS   'tbba001g.条件変更日'
    ,tbba001g.mj_simuksak      AS   'tbba001g.仕向先'
    ,tbba001g.no_order         AS   'tbba001g.オーダーＮＯ'
    ,tbba001g.mj_katahima      AS   'tbba001g.型式ハイフン前'
    ,tbba001g.no_frame         AS   'tbba001g.フレームＮＯ'
    ,tbba001g.dd_siire         AS   'tbba001g.仕入日'
    ,tbba001g.dd_frkanou       AS   'tbba001g.振当可能日'
    ,tbba001g.dd_frkej         AS   'tbba001g.振当計上日'
    ,tbba001g.dd_krhuri        AS   'tbba001g.仮振当日'
    ,tbba001g.dd_fr            AS   'tbba001g.振当日'
    ,tbba001g.dd_frtoriks      AS   'tbba001g.振当取消日'
    ,tbba001g.mj_frtorikr      AS   'tbba001g.振当取消理由'
    ,tbba001g.dd_kibonoki      AS   'tbba001g.希望納期'
    ,tbba001g.dd_torokibo      AS   'tbba001g.登録希望日'
    ,tbba001g.dd_touroku       AS   'tbba001g.登録日'
    ,tbba001g.dd_honbsyok      AS   'tbba001g.本部書類全完日'
    ,tbba001g.dd_tenpsyok      AS   'tbba001g.店舗書類全完日'
    ,tbba001g.cd_toroirai      AS   'tbba001g.登録代行依頼元販売店コード'
    ,tbba001g.dd_torodaik      AS   'tbba001g.登録代行受付日'
    ,tbba001g.dd_torotrkk      AS   'tbba001g.登録取消計上日'
    ,tbba001g.dd_uritrkkj      AS   'tbba001g.売上取消計上日'
    ,tbba001g.dd_modurikj      AS   'tbba001g.戻し売上計上日'
    ,tbba001g.dd_uriagekj      AS   'tbba001g.売上計上日'
    ,tbba001g.dd_uritorik      AS   'tbba001g.売上取消日'
    ,tbba001g.dd_moduriag      AS   'tbba001g.戻し売上日'
    ,tbba001g.dd_uriage        AS   'tbba001g.売上日'
    ,tbba001g.dd_urikzumi      AS   'tbba001g.売掛金完済日'
    ,tbba001g.dd_nosya         AS   'tbba001g.納車日'
    ,tbba001g.nu_nosysokm      AS   'tbba001g.納車時走行キロ'
    ,tbba001g.dd_haiskibo      AS   'tbba001g.配送希望日'
    ,tbba001g.dd_haisou        AS   'tbba001g.配送日'
    ,tbba001g.tm_haisotai      AS   'tbba001g.配送時間帯'
    ,tbba001g.cd_haisskdr      AS   'tbba001g.配送先ディーラーコード'
    ,tbba001g.dd_joknhkhk      AS   'tbba001g.条件変更不可日付'
    ,tbba001g.dd_haisoyot      AS   'tbba001g.配送予定日'
    ,tbba001g.mj_haisosak      AS   'tbba001g.配送先'
    ,tbba001g.kj_naisomem      AS   'tbba001g.配送メモ'
    ,tbba001g.nu_sagyjyn       AS   'tbba001g.作業順位'
    ,tbba001g.dd_sagtyyo       AS   'tbba001g.作業着手予定日'
    ,tbba001g.kb_daihynai      AS   'tbba001g.代表作業難易度区分'
    ,tbba001g.tm_totutmke      AS   'tbba001g.取付時間計'
    ,tbba001g.kb_tokuso        AS   'tbba001g.特装区分'
    ,tbba001g.kb_tokusouk      AS   'tbba001g.特装受付区分'
    ,tbba001g.dd_tokusosg      AS   'tbba001g.特装作業日数'
    ,tbba001g.dd_toksokry      AS   'tbba001g.特装完了予定日'
    ,tbba001g.dd_sagtyak       AS   'tbba001g.作業着手日'
    ,tbba001g.dd_sagyokan      AS   'tbba001g.作業完了日'
    ,tbba001g.mj_iraibumo      AS   'tbba001g.依頼部門'
    ,tbba001g.dd_totyakuy      AS   'tbba001g.到着予定日'
    ,tbba001g.dd_totykykg      AS   'tbba001g.到着予定日加算後'
    ,tbba001g.dd_haisosru      AS   'tbba001g.配送車両受取日'
    ,tbba001g.dd_syakihka      AS   'tbba001g.車両基本確定日'
    ,tbba001g.no_syakihjo      AS   'tbba001g.車両基本条件変更枝番'
    ,tbba001g.mj_syssiym       AS   'tbba001g.最終仕様無ＦＬＧ'
    ,tbba001g.mj_nysjkk        AS   'tbba001g.名寄せ実行ＦＬＧ買主'
    ,tbba001g.mj_nysjkksy      AS   'tbba001g.名寄せ実行ＦＬＧ買主車両'
    ,tbba001g.mj_nysjkm        AS   'tbba001g.名寄せ実行ＦＬＧ名義人'
    ,tbba001g.dd_fuzkspsi      AS   'tbba001g.付属品特別仕様確定日'
    ,tbba001g.dd_hanbkaku      AS   'tbba001g.販売条件確定日'
    ,tbba001g.dd_sitajkak      AS   'tbba001g.下取車情報確定日'
    ,tbba001g.dd_sykajoka      AS   'tbba001g.紹介者情報確定日'
    ,tbba001g.dd_kyakkaku      AS   'tbba001g.お客様詳細確定日'
    ,tbba001g.dd_sonknkak      AS   'tbba001g.損金残益確定日'
    ,tbba001g.dd_cynyukan      AS   'tbba001g.注文書入力完全完了日'
    ,tbba001g.dd_seikysak      AS   'tbba001g.請求書作成日'
    ,tbba001g.dd_jibsysak      AS   'tbba001g.自賠責証明書作成日'
    ,tbba001g.no_nohinsek      AS   'tbba001g.納品請求書ＮＯ'
    ,tbba001g.no_gosnseky      AS   'tbba001g.合算請求書ＮＯ'
    ,tbba001g.su_hokenkim      AS   'tbba001g.保険期間月数'
    ,tbba001g.dd_hokenkij      AS   'tbba001g.保険期間至'
    ,tbba001g.dd_hokenkii      AS   'tbba001g.保険期間自'
    ,tbba001g.mj_oyaari        AS   'tbba001g.親有ＦＬＧ'
    ,tbba001g.mj_joknhkhy      AS   'tbba001g.条件変更表示フラグ'
    ,tbba001g.dd_torikesi      AS   'tbba001g.取消日'
    ,tbba001g.cd_toririyu      AS   'tbba001g.取消理由コード'
    ,tbba001g.cd_toristaf      AS   'tbba001g.取消スタッフコード'
    ,tbba001g.mj_copynofl      AS   'tbba001g.コピーＮＯＦＬＧ'
    ,tbba001g.kb_hisenkan      AS   'tbba001g.品番選択完了区分'
    ,tbba001g.mj_dfsckanr      AS   'tbba001g.ＤＦＳＣ寒冷地'
    ,tbba001g.kb_tuiksjin      AS   'tbba001g.追工指示票印刷区分'
    ,tbba001g.no_kytyumon      AS   'tbba001g.旧注文ＮＯ'
    ,tbba001g.no_kytymoed      AS   'tbba001g.旧注文ＮＯ枝番'
    ,tbba001g.cd_kyhabstf      AS   'tbba001g.旧販売スタッフコード'
    ,tbba001g.no_sintymon      AS   'tbba001g.新注文ＮＯ'
    ,tbba001g.no_sintymed      AS   'tbba001g.新注文ＮＯ枝番'
    ,tbba001g.cd_sihabstf      AS   'tbba001g.新販売スタッフコード'
    ,tbba001g.no_skycymon      AS   'tbba001g.送信旧注文ＮＯ'
    ,tbba001g.no_skycymed      AS   'tbba001g.送信旧注文ＮＯ枝番'
    ,tbba001g.kb_8no           AS   'tbba001g.８ＮＯ区分'
    ,tbba001g.mj_listoutf      AS   'tbba001g.リスト出力フラグ'
    ,tbba001g.mj_sosinerf      AS   'tbba001g.送信エラーフラグ'
    ,tbba001g.mj_kaktshrp      AS   'tbba001g.確定お支払いプラン'
    ,tbba001g.kb_busiji        AS   'tbba001g.物流指示区分'
    ,tbba001g.kb_buhtejot      AS   'tbba001g.部品手配状態区分'
    ,tbba001g.kb_zekomiin      AS   'tbba001g.税込入力区分'
    ,tbba001g.kb_yotaku        AS   'tbba001g.預託区分'
    ,tbba001g.dd_yotakuyt      AS   'tbba001g.預託予定日'
    ,tbba001g.nu_syrdstjr      AS   'tbba001g.シュレッダーダスト重量増減'
    ,tbba001g.mj_arcnscum      AS   'tbba001g.エアコン装着有無'
    ,tbba001g.kb_tokusyu       AS   'tbba001g.特殊区分'
    ,tbba001g.kb_houtaksh      AS   'tbba001g.法対象架装物区分変更値'
    ,tbba001g.kb_sekydtss      AS   'tbba001g.請求データ送信区分'
    ,tbba001g.kb_yohndtss      AS   'tbba001g.用品品番データ送信区分'
    ,tbba001g.kb_osssin        AS   'tbba001g.ＯＳＳ申請区分'
    ,tbba001g.kb_siyozkis      AS   'tbba001g.使用済記載区分'
    ,tbba001g.kb_stjizeso      AS   'tbba001g.下取自動車税相当額表示区分'
    ,tbba001g.dd_hosysyhk      AS   'tbba001g.保証書発行日'
    ,tbba001g.kb_kamitjis      AS   'tbba001g.保険かんたん見積実施区分'
    ,tbba001g.kb_symitjis      AS   'tbba001g.保険詳細見積実施区分'
    ,tbba001g.mj_junknorn      AS   'tbba001g.旬間オーダー連番'
    ,tbba001g.kb_iko           AS   'tbba001g.移行区分'
    ,tbba001g.mj_gbkprint      AS   'tbba001g.ＧＢＯＯＫ申込書印刷済フラグ'
    ,tbba001g.kb_telmnavi      AS   'tbba001g.テレマナビ区分'
    ,tbba001g.mj_telmnavs      AS   'tbba001g.テレマナビ種別'
    ,tbba001g.cd_telmnavi      AS   'tbba001g.テレマナビコード'
    ,tbba001g.cd_telnavsy      AS   'tbba001g.テレマ車名コード'
    ,tbba001g.kb_espotai       AS   'tbba001g.ＥＳＰＯ対象区分'
    ,tbba001g.kb_ptlmnavi      AS   'tbba001g.ＰＡＬテレマナビ区分'
    ,tbba001g.mj_ptlmnavs      AS   'tbba001g.ＰＡＬテレマナビ種別'
    ,tbba001g.cd_ptlmnavi      AS   'tbba001g.ＰＡＬテレマナビコード'
    ,tbba001g.cd_ptlnavsy      AS   'tbba001g.ＰＡＬテレマ車名コード'
    ,tbba001g.kb_pespotai      AS   'tbba001g.ＰＡＬＥＳＰＯ対象区分'
    ,tbba001g.mj_znfratjt      AS   'tbba001g.前回振当状態'
    ,tbba001g.dd_znfratmd      AS   'tbba001g.前回振当月日'
    ,tbba001g.kb_znfurate      AS   'tbba001g.前回振当区分'
    ,tbba001g.dd_znhaisou      AS   'tbba001g.前回配送日'
    ,tbba001g.kj_znhaisoj      AS   'tbba001g.前回配送状況'
    ,tbba001g.dt_znsyokai      AS   'tbba001g.前回照会日時'
    ,tbba001g.kb_zjsyori       AS   'tbba001g.前日処理ＦＬＧ'
    ,tbba001g.kb_zjzaikoj      AS   'tbba001g.前日在庫状態区分'
    ,tbba001g.dd_zjfryote      AS   'tbba001g.前日振当予定日'
    ,tbba001g.dd_zjkrhuri      AS   'tbba001g.前日仮振当日'
    ,tbba001g.dd_zjfr          AS   'tbba001g.前日振当日'
    ,tbba001g.dd_zjhaisou      AS   'tbba001g.前日配送表示日'
    ,tbba001g.mj_zjhaist       AS   'tbba001g.前日配送ステータス'
    ,tbba001g.kb_zzsyori       AS   'tbba001g.前々日処理ＦＬＧ'
    ,tbba001g.kb_zzzaikoj      AS   'tbba001g.前々日在庫状態区分'
    ,tbba001g.dd_zzfryote      AS   'tbba001g.前々日振当予定日'
    ,tbba001g.dd_zzkrhuri      AS   'tbba001g.前々日仮振当日'
    ,tbba001g.dd_zzfr          AS   'tbba001g.前々日振当日'
    ,tbba001g.dd_zzhaisou      AS   'tbba001g.前々日配送表示日'
    ,tbba001g.mj_zzhaist       AS   'tbba001g.前々日配送ステータス'
    ,tbba001g.kb_sysnhosy      AS   'tbba001g.小損害保証区分'
    ,tbba001g.dd_sysnhshk      AS   'tbba001g.小損害保証書発行日'
    ,tbba001g.kb_rtnsyry       AS   'tbba001g.Ｒ店車両区分'
    ,tbba001g.no_rtnhaty       AS   'tbba001g.Ｒ店車両発注ＮＯ'
    ,tbba001g.no_rtnhaed       AS   'tbba001g.Ｒ店車両発注ＮＯ枝番'
    ,tbba001g.mj_syatkid       AS   'tbba001g.車両特定ＩＤ'
    ,tbba001g.dd_rtntry        AS   'tbba001g.Ｒ店登録予定日'
    /*
    ,CAST(
        CONCAT(
            SUBSTR(CAST(tbba001g.dd_rtntry AS STRING), 1, 4), '-',
            SUBSTR(CAST(tbba001g.dd_rtntry AS STRING), 5, 2), '-',
            SUBSTR(CAST(tbba001g.dd_rtntry AS STRING), 7, 2)
        ) AS TIMESTAMP
     ) AS 'Ｒ店登録予定日'
     */
    ,tbba031g.dd_toroyote    AS   'Ｒ店登録予定日'
    ,tbba001g.dd_rtnnsy      AS   'tbba001g.Ｒ店納車予定日'
    ,tbba001g.dd_rtntsh      AS   'tbba001g.Ｒ店登録書類必着日'
    ,tbba001g.dd_rtnfri      AS   'tbba001g.Ｒ店振当結果送付日'
    ,tbba001g.kb_icjrnkum    AS   'tbba001g.ＩＣＲＯＰＪ連携有無'
    ,tbba001g.kb_kinto       AS   'tbba001g.ＫＩＮＴＯ区分'
    ,tbba001g.dt_saisinup    AS   'tbba001g.最新更新日時'
    ,tbba001g.mj_sasintan    AS   'tbba001g.最新更新端末ＩＤ'
    ,tbv0014m.cd_syain       AS   'tbv0014m.社員コード'
    ,tbv0014m.kj_syainmei      AS   'tbv0014m.社員名'
    ,tbv0014m.kb_syainzok      AS   'tbv0014m.社員属性'
    ,tbv0014m.cd_syozoten      AS   'tbv0014m.所属店舗'
    ,tbv0014m.cd_syozoka      AS   'tbv0014m.所属課'
    ,tbv0014m.cd_syozokak      AS   'tbv0014m.所属係'
    ,tbv0014m.cd_syozobum      AS   'tbv0014m.所属部門'
    ,tbv0014m.mj_syanenji      AS   'tbv0014m.車両年次'
    ,tbv0014m.mj_syarank      AS   'tbv0014m.車両ランク'
    ,tbv0014m.kb_staffsin      AS   'tbv0014m.スタッフ新車'
    ,tbv0014m.kb_stafftyu      AS   'tbv0014m.スタッフ中古車'
    ,tbv0014m.kb_okyakuta      AS   'tbv0014m.お客様担当'
    ,tbv0014m.kb_staffduo      AS   'tbv0014m.スタッフＤＵＯ'
    ,tbv0014m.mj_staffsv      AS   'tbv0014m.スタッフサービス'
    ,tbv0014m.dd_taisyoku      AS   'tbv0014m.退職日'
    ,tbv0014m.kb_gyomkeng      AS   'tbv0014m.業務権限区分'
    ,tbv0014m.kb_tyokan      AS   'tbv0014m.直間区分'
    ,tbv0014m.kb_frestaff      AS   'tbv0014m.フリースタッフ区分'
    ,tbv0014m.dd_ido      AS   'tbv0014m.移動日'
    ,tbv0014m.mj_kysyztnp      AS   'tbv0014m.旧所属店舗'
    ,tbv0014m.mj_kysyzka      AS   'tbv0014m.旧所属課'
    ,tbv0014m.mj_kysyzkak      AS   'tbv0014m.旧所属係'
    ,tbv0014m.mj_kysyzbum      AS   'tbv0014m.旧所属部門'
    ,tbv0014m.kb_tasyskos      AS   'tbv0014m.他システム更新区分'
    ,tbv0014m.dd_todoke      AS   'tbv0014m.届出日'
    ,tbv0014m.dd_haisi      AS   'tbv0014m.廃止日'
    ,tbv0014m.kb_kyugyokn      AS   'tbv0014m.旧業務権限区分'
    ,tbv0014m.kb_usekbn      AS   'tbv0014m.ＡＴＳＣ利用区分'
    ,tbv0014m.mj_syainmei      AS   'tbv0014m.ＡＴＳＣ社員英名'
    ,tbv0014m.kb_honkbn      AS   'tbv0014m.ＡＴＳＣ本部店舗区分'
    ,tbv0014m.mj_login1      AS   'tbv0014m.ログインＩＤ１'
    ,tbv0014m.mj_login2      AS   'tbv0014m.ログインＩＤ２'
    ,tbv0014m.mj_login3      AS   'tbv0014m.ログインＩＤ３'
    ,tbv0014m.mj_login4      AS   'tbv0014m.ログインＩＤ４'
    ,tbv0014m.mj_login5      AS   'tbv0014m.ログインＩＤ５'
    ,tbv0014m.mj_login6      AS   'tbv0014m.ログインＩＤ６'
    ,tbv0014m.mj_login7      AS   'tbv0014m.ログインＩＤ７'
    ,tbv0014m.mj_login8      AS   'tbv0014m.ログインＩＤ８'
    ,tbv0014m.mj_login9      AS   'tbv0014m.ログインＩＤ９'
    ,tbv0014m.mj_login10      AS   'tbv0014m.ログインＩＤ１０'
    ,tbv0014m.mj_keisyo      AS   'tbv0014m.継承有無'
    ,tbv0014m.cd_kirkaisy      AS   'tbv0014m.切替可能会社'
    ,tbv0014m.cd_kirtenpo      AS   'tbv0014m.切替可能店舗'

    ,tbbf008m.mj_hantenkt     AS   'tbbf008m.販売店型式'
    ,tbbf008m.mj_sinkysed     AS   'tbbf008m.新旧世代'
    ,tbbf008m.kb_spec     AS   'tbbf008m.スペック区分'
    ,tbbf008m.cd_spec     AS   'tbbf008m.スペックコード'
    ,tbbf008m.no_hinmei     AS   'tbbf008m.品名連番'
    ,tbbf008m.mj_syamei     AS   'tbbf008m.車名'
    ,tbbf008m.ki_baika     AS   'tbbf008m.売価'
    ,tbbf008m.nu_kazejyry     AS   'tbbf008m.課税重量'
    ,tbbf008m.ki_jikasyzg     AS   'tbbf008m.自家用取得税額'
    ,tbbf008m.ki_eigysyga     AS   'tbbf008m.営業用取得税額'
    ,tbbf008m.ki_kanrigen     AS   'tbbf008m.管理原価'
    ,tbbf008m.nu_kanrgen     AS   'tbbf008m.管理原価率'
    ,tbbf008m.ki_yotegen     AS   'tbbf008m.予定原価'
    ,tbbf008m.nu_yotegnr     AS   'tbbf008m.予定原価率'
    ,tbbf008m.no_hyojsobh     AS   'tbbf008m.標準装備品ＮＯ'
    ,tbbf008m.mj_setkaumu     AS   'tbbf008m.セット価格有無'
    ,tbbf008m.mj_padhing     AS   'tbbf008m.パディング'
    ,tbbf008m.mj_hyojnais     AS   'tbbf008m.標準内装'
    ,tbbf008m.kb_siyohuka     AS   'tbbf008m.使用不可区分'
    ,tbbf008m.kb_kkkmhane     AS   'tbbf008m.価格未反映区分'
    ,tbbf008m.kb_modrst     AS   'tbbf008m.モデリスタ区分'
    ,tbbf008m.kb_palrenra     AS   'tbbf008m.ＰＡＬ連絡区分'
    ,tbbf008m.dd_jcutikri     AS   'tbbf008m.受注打切日'
    ,tbbf001m.cd_ncsyamei     AS   'tbbf001m.新車車名コード'
    ,tbbf001m.kn_syame     AS   'tbbf001m.カナ車名'
    ,tbbf001m.kj_kurumame     AS   'tbbf001m.漢字車名'
    ,tbbf001m.nu_symenarb     AS   'tbbf001m.車名並び順'
    ,tbbf001m.kb_oem     AS   'tbbf001m.ＯＥＭ区分'
    ,tbbf001m.kb_recycmks     AS   'tbbf001m.リサイクルメーカー識別区分'
    ,tbbf001m.kb_syasyu     AS   'tbbf001m.車種区分'
    ,tbbf001m.kb_jikajidz     AS   'tbbf001m.自家用自動車税区分'
    ,tbbf001m.kb_eigyjdsy     AS   'tbbf001m.営業用自動車税区分'
    ,tbbf001m.kb_jyuuzei     AS   'tbbf001m.重量税区分'
    ,tbbf001m.ki_yusohi     AS   'tbbf001m.輸送費'
    ,tbbf001m.kb_syohize     AS   'tbbf001m.消費税区分'
    ,tbbf001m.mj_haigasu     AS   'tbbf001m.排ガス記号'
    ,tbbf001m.kb_yoykkah     AS   'tbbf001m.予約可否区分'
    ,tbbf001m.su_yoykkano     AS   'tbbf001m.予約可能台数'
    ,tbbf001m.su_yoyayuko     AS   'tbbf001m.予約有効日数'
    ,tbbf001m.su_nokikasn     AS   'tbbf001m.仮納期加算日数'
    ,tbbf001m.su_kanseiks     AS   'tbbf001m.完成予定日加算日数'
    ,tbbf001m.su_kakunoki     AS   'tbbf001m.確定納期加算日数'
    ,tbbf001m.su_totyakuy     AS   'tbbf001m.到着予定日加算日数'
    ,tbbf001m.ki_nebkeiko     AS   'tbbf001m.値引き警告額'
    ,tbbf001m.nu_nebkeiko     AS   'tbbf001m.値引き警告率'
    ,tbbf001m.ki_nebjogen     AS   'tbbf001m.値引き上限額'
    ,tbbf001m.nu_nebjogen     AS   'tbbf001m.値引き上限率'
    ,tbbf001m.cd_21syamei     AS   'tbbf001m.ａｉ２１車名コード'
    ,tbbf001m.cd_yohinsya     AS   'tbbf001m.用品車名コード'
    ,tbbf001m.mj_farkanrg     AS   'tbbf001m.ファーム管理グループ'
    ,tbbf001m.kb_sobetu     AS   'tbbf001m.層別区分'
    ,tbbf001m.mj_zenjd     AS   'tbbf001m.全自動振当有無'
    ,tbbf001m.mj_zenjdkar     AS   'tbbf001m.全自動仮振当有無'
    ,tbbf001m.kb_orderkah     AS   'tbbf001m.オーダー可否区分'
    ,tbbf001m.ki_toksyne1     AS   'tbbf001m.特殊値引き警告額１'
    ,tbbf001m.nu_toksyne1     AS   'tbbf001m.特殊値引き警告率１'
    ,tbbf001m.ki_toksynj1     AS   'tbbf001m.特殊値引き上限額１'
    ,tbbf001m.nu_toksynj1     AS   'tbbf001m.特殊値引き上限率１'
    ,tbbf001m.ki_toksyne2     AS   'tbbf001m.特殊値引き警告額２'
    ,tbbf001m.nu_toksyne2     AS   'tbbf001m.特殊値引き警告率２'
    ,tbbf001m.ki_toksynj2     AS   'tbbf001m.特殊値引き上限額２'
    ,tbbf001m.nu_toksynj2     AS   'tbbf001m.特殊値引き上限率２'
    ,tbbf001m.ki_toksyne3     AS   'tbbf001m.特殊値引き警告額３'
    ,tbbf001m.nu_toksyne3     AS   'tbbf001m.特殊値引き警告率３'
    ,tbbf001m.ki_toksynj3     AS   'tbbf001m.特殊値引き上限額３'
    ,tbbf001m.nu_toksynj3     AS   'tbbf001m.特殊値引き上限率３'
    ,tbbf001m.nu_toksyby     AS   'tbbf001m.特殊売価率'
    ,tbbf001m.cd_busent     AS   'tbbf001m.物流センタコード'
    ,tbbf001m.cd_syuyaksy     AS   'tbbf001m.集約車名コード'
    ,tbbf001m.nu_risoptkz     AS   'tbbf001m.リースＯＰＴ加算係数'
    ,tbbf001m.kb_palrenra     AS   'tbbf001m.ＰＡＬ連絡区分'
    ,tbbf001m.mj_siki     AS   'tbbf001m.始期'
    ,tbbf001m.mj_syuuki     AS   'tbbf001m.終期'
    ,tbbf001m.kb_syasikib     AS   'tbbf001m.車名識別区分'
    ,tbbf001m.kb_seisansy     AS   'tbbf001m.生産車区分'
    ,tbbf001m.ki_honbkanr     AS   'tbbf001m.本部管理費'
    ,tbbf001m.kb_syatehai     AS   'tbbf001m.車両手配区分'
    ,tbbf001m.dd_syatehai     AS   'tbbf001m.車両手配日数'
    ,tbbf001m.dd_kankenkik     AS   'tbbf001m.完検切期間'
    ,tbbf001m.ki_afutas     AS   'tbbf001m.アフターサービス料'
    ,tbbf001m.cd_sinttuik     AS   'tbbf001m.新点追工コード'
    ,tbbf001m.nu_kanrgen     AS   'tbbf001m.管理原価率'
    ,tbbf001m.kb_kanrhas     AS   'tbbf001m.管理端数処理区分'
    ,tbbf001m.kb_nebset     AS   'tbbf001m.値引設定区分'
    ,tbbf001m.nu_yotegnr     AS   'tbbf001m.予定原価率'
    ,tbbf001m.kb_yotehssy     AS   'tbbf001m.予定端数処理区分'
    ,tbbf001m.kb_toksyhss     AS   'tbbf001m.特殊端数処理区分'
    ,tbbf001m.kb_zekmkths     AS   'tbbf001m.税込型式端数区分'
    ,tbbf001m.kb_zekmspch     AS   'tbbf001m.税込スペック端数区分'
    ,tbbf001m.kb_szekmkth     AS   'tbbf001m.新税込型式端数区分'
    ,tbbf001m.nu_zkmkkemz     AS   'tbbf001m.税込価格計算元税率'
    ,tbbf001m.cd_kairisya     AS   'tbbf001m.経理車名コード'
    ,tbbf001m.dd_jcutikri     AS   'tbbf001m.受注打切日'
    ,tbbf001m.ki_hyojrie     AS   'tbbf001m.標準利益'
    ,tbbf001m.su_hyojrisi     AS   'tbbf001m.標準利益使用台数'
    ,tbbf001m.cd_kykeirsy     AS   'tbbf001m.旧経理車名コード'
    ,tbbf001m.dd_kirikae     AS   'tbbf001m.切替日'
    ,tbbf001m.kb_siyofskh     AS   'tbbf001m.仕様振当照会可否区分'
    ,tbbf001m.kb_dfscjdst     AS   'tbbf001m.ＤＦＳＣ自動設定区分'
    ,tbbf001m.mj_sinkyhug     AS   'tbbf001m.新旧符号'
    ,tbbf001m.kb_toksyns1     AS   'tbbf001m.特殊値引設定区分１'
    ,tbbf001m.kb_toksyns2     AS   'tbbf001m.特殊値引設定区分２'
    ,tbbf001m.kb_toksyns3     AS   'tbbf001m.特殊値引設定区分３'
    ,tbbf001m.kn_kei     AS   'tbbf001m.軽区分'
    ,tbbf001m.kb_hyojnkai     AS   'tbbf001m.標準解除区分'
    ,tbbf001m.kb_tachasya     AS   'tbbf001m.他チャネル車両区分'
    ,tbbf001m.kb_pc10hisu     AS   'tbbf001m.ＰＣ１０非推奨区分'

    ,tltl2001.lskykno      AS リース契約Ｎｏ
    ,tltl2001.kata         AS 型式
    ,tltl2001.toshokcd     AS 塗色
    ,tltl2031.hchymd       AS 発注年月日
    ,tltl2031.noshakiboymd AS 納車希望年月日
    ,tltl2031.trkkiboymd AS 登録希望日

    ,tltl2001.RTENID AS 'tltl2001.Ｒ店ＩＤ'
    ,tltl2001.LSKYKNO AS 'tltl2001.リース契約Ｎｏ'
    ,tltl2001.SHDNNO AS 'tltl2001.商談Ｎｏ'
    ,tltl2001.SHDNNOSC AS 'tltl2001.商談Ｎｏ枝番'
    ,tltl2001.ANKENGRPNO AS 'tltl2001.案件グループＮｏ'
    ,tltl2001.ANKENGRPSC AS 'tltl2001.案件グループ枝番'
    ,tltl2001.ZNLSKYKNO AS 'tltl2001.前リース契約Ｎｏ'
    ,tltl2001.NXTLSKYKNO AS 'tltl2001.次リース契約Ｎｏ'
    ,tltl2001.KYKSKCD AS 'tltl2001.契約先コード'
    ,tltl2001.SKYSKCD AS 'tltl2001.請求先コード'
    ,tltl2001.USESKCD AS 'tltl2001.使用先コード'
    ,tltl2001.TKSKCD AS 'tltl2001.点検先コード'
    ,tltl2001.SCNKYKSKCD AS 'tltl2001.２次契約先コード'
    ,tltl2001.SCNKYKSKNM1 AS 'tltl2001.２次契約先名称１'
    ,tltl2001.SCNKYKSKNM2 AS 'tltl2001.２次契約先名称２'
    ,tltl2001.TNTSHOPCD AS 'tltl2001.担当ショップコード'
    ,tltl2001.TNTSHOPNM1 AS 'tltl2001.担当ショップ名１'
    ,tltl2001.TNTSHOPNM2 AS 'tltl2001.担当ショップ名２'
    ,tltl2001.EXPRANNAISFSCD AS 'tltl2001.満了案内送付先コード'
    ,tltl2001.LSKTAI AS 'tltl2001.リース形態'
    ,tltl2001.LSKIKN AS 'tltl2001.リース期間'
    ,tltl2001.LSSYMD AS 'tltl2001.リース開始年月日'
    ,tltl2001.LSEYMD AS 'tltl2001.リース終了年月日'
    ,tltl2001.LSKISU AS 'tltl2001.リース回数'
    ,tltl2001.LSURISUMIKISU AS 'tltl2001.リース売上済回数'
    ,tltl2001.LSHOSK AS 'tltl2001.リース方式'
    ,tltl2001.FLEETMNTKBN AS 'tltl2001.フリートメンテナンス区分'
    ,tltl2001.NUKBN AS 'tltl2001.新中区分'
    ,tltl2001.KYKKTAICD AS 'tltl2001.契約形態コード'
    ,tltl2001.RELSKBN AS 'tltl2001.再リース区分'
    ,tltl2001.TKEILSHOSK AS 'tltl2001.提携リース方式'
    ,tltl2001.TKEISKCD AS 'tltl2001.提携先コード'
    ,tltl2001.LSSSNBNR AS 'tltl2001.リース資産分類'
    ,tltl2001.CARNMCD AS 'tltl2001.車名コード'
    ,tltl2001.REFCARNMCD AS 'tltl2001.参照車名コード'
    ,tltl2001.SHDNCARNM AS 'tltl2001.商談車名'
    ,tltl2001.GRDNM AS 'tltl2001.グレード名'
    ,tltl2001.BDYNM AS 'tltl2001.ボディ名'
    ,tltl2001.ENGINNM AS 'tltl2001.エンジン名'
    ,tltl2001.MISSIONNM AS 'tltl2001.ミッション名'
    ,tltl2001.MKRCARNMCD AS 'tltl2001.メーカー車名コード'
    ,tltl2001.SHGNGEN AS 'tltl2001.諸元世代'
    ,tltl2001.MKRKATA AS 'tltl2001.メーカー型式'
    ,tltl2001.SNGYSHRKBN AS 'tltl2001.産業車両区分'
    ,tltl2001.TRKNOPLTNO AS 'tltl2001.登録ＮｏプレートＮｏ'
    ,tltl2001.TRKNORKSCD AS 'tltl2001.登録Ｎｏ陸支コード'
    ,tltl2001.TRKNOSHSHKBN AS 'tltl2001.登録Ｎｏ車種区分'
    ,tltl2001.TRKNONK AS 'tltl2001.登録Ｎｏカナ'
    ,tltl2001.SHADINO AS 'tltl2001.車台番号'
    ,tltl2001.KATA AS 'tltl2001.型式'
    ,tltl2001.TOSHOKCD AS 'tltl2001.塗色コード'
    ,tltl2001.NAISOSHOKCD AS 'tltl2001.内装色コード'
    ,tltl2001.NENRYOKBN AS 'tltl2001.燃料区分'
    ,tltl2001.SNGYSHRKYKSHFLG AS 'tltl2001.産業車両契約書フラグ'
    ,tltl2001.NOZEISHSHKBN AS 'tltl2001.納税車種区分'
    ,tltl2001.SHKNYOHIFLG AS 'tltl2001.車検要否フラグ'
    ,tltl2001.HTNYOHIFLG AS 'tltl2001.法点要否フラグ'
    ,tltl2001.SHKNCYCLSHKAI AS 'tltl2001.車検サイクル初回'
    ,tltl2001.SHKNCYCLSCNIKO AS 'tltl2001.車検サイクル２回目以降'
    ,tltl2001.NOSHABASHOCD AS 'tltl2001.納車場所コード'
    ,tltl2001.MSOKOKYORI AS 'tltl2001.月走行距離'
    ,tltl2001.OVRSOKORYO AS 'tltl2001.超過走行料'
    ,tltl2001.SHRHONTAINCARJIKK AS 'tltl2001.車両本体新車時価格'
    ,tltl2001.SHRHONTAIZNKYKKK AS 'tltl2001.車両本体前契約価格'
    ,tltl2001.SHRHONTAIGKAKK AS 'tltl2001.車両本体原価価格'
    ,tltl2001.SHRHONTAISIRKK AS 'tltl2001.車両本体仕入価格'
    ,tltl2001.TRKNOSHAHYOUMFLG AS 'tltl2001.登録納車費用有無フラグ'
    ,tltl2001.TRKNOSHAHYO AS 'tltl2001.登録納車費用'
    ,tltl2001.SHTKTXUMFLG AS 'tltl2001.取得税有無フラグ'
    ,tltl2001.SHTKTX AS 'tltl2001.取得税'
    ,tltl2001.JURYOTXUMKBN AS 'tltl2001.重量税有無区分'
    ,tltl2001.JURYOTX1NENMEKNGK AS 'tltl2001.重量税１年目金額'
    ,tltl2001.JURYOTX2NENMEKNGK AS 'tltl2001.重量税２年目金額'
    ,tltl2001.JURYOTX3NENMEKNGK AS 'tltl2001.重量税３年目金額'
    ,tltl2001.JURYOTX4NENMEKNGK AS 'tltl2001.重量税４年目金額'
    ,tltl2001.JURYOTX5NENMEKNGK AS 'tltl2001.重量税５年目金額'
    ,tltl2001.JURYOTX6NENMEKNGK AS 'tltl2001.重量税６年目金額'
    ,tltl2001.JURYOTX7NENMEKNGK AS 'tltl2001.重量税７年目金額'
    ,tltl2001.JURYOTX8NENMEKNGK AS 'tltl2001.重量税８年目金額'
    ,tltl2001.JURYOTXGOKKNGK AS 'tltl2001.重量税合計金額'
    ,tltl2001.JURYOTXKISU AS 'tltl2001.重量税回数'
    ,tltl2001.JBSKUMKBN AS 'tltl2001.自賠責有無区分'
    ,tltl2001.JBSKKISU AS 'tltl2001.自賠責回数'
    ,tltl2001.JBSK1NENMEKNGK AS 'tltl2001.自賠責１年目金額'
    ,tltl2001.JBSK2NENMEKNGK AS 'tltl2001.自賠責２年目金額'
    ,tltl2001.JBSK3NENMEKNGK AS 'tltl2001.自賠責３年目金額'
    ,tltl2001.JBSK4NENMEKNGK AS 'tltl2001.自賠責４年目金額'
    ,tltl2001.JBSK5NENMEKNGK AS 'tltl2001.自賠責５年目金額'
    ,tltl2001.JBSK6NENMEKNGK AS 'tltl2001.自賠責６年目金額'
    ,tltl2001.JBSK7NENMEKNGK AS 'tltl2001.自賠責７年目金額'
    ,tltl2001.JBSK8NENMEKNGK AS 'tltl2001.自賠責８年目金額'
    ,tltl2001.JBSKGOKKNGK AS 'tltl2001.自賠責合計金額'
    ,tltl2001.JBSKKANYUKBN AS 'tltl2001.自賠責加入区分'
    ,tltl2001.JBSKSNPSTEIFLG AS 'tltl2001.自賠責損保指定フラグ'
    ,tltl2001.JBSKSNPKSHCD AS 'tltl2001.自賠責損保会社コード'
    ,tltl2001.JBSKDIRTNSTEIFLG AS 'tltl2001.自賠責代理店指定フラグ'
    ,tltl2001.JBSKDIRTNNM AS 'tltl2001.自賠責代理店名'
    ,tltl2001.CARTXUMKBN AS 'tltl2001.自動車税有無区分'
    ,tltl2001.CARTXKISU AS 'tltl2001.自動車税回数'
    ,tltl2001.CARTXCHIKBTKBN AS 'tltl2001.自動車税地区別区分'
    ,tltl2001.CARTXSHNENDKNGK AS 'tltl2001.自動車税初年度金額'
    ,tltl2001.CARTX2NENDKNGK AS 'tltl2001.自動車税２年度金額'
    ,tltl2001.CARTX3NENDKNGK AS 'tltl2001.自動車税３年度金額'
    ,tltl2001.CARTX4NENDKNGK AS 'tltl2001.自動車税４年度金額'
    ,tltl2001.CARTX5NENDKNGK AS 'tltl2001.自動車税５年度金額'
    ,tltl2001.CARTX6NENDKNGK AS 'tltl2001.自動車税６年度金額'
    ,tltl2001.CARTX7NENDKNGK AS 'tltl2001.自動車税７年度金額'
    ,tltl2001.CARTX8NENDKNGK AS 'tltl2001.自動車税８年度金額'
    ,tltl2001.CARTXGOKKNGK AS 'tltl2001.自動車税合計金額'
    ,tltl2001.SHKIRYOUMFLG AS 'tltl2001.紹介料有無フラグ'
    ,tltl2001.SHKIRYO AS 'tltl2001.紹介料'
    ,tltl2001.HOJOKNUMFLG AS 'tltl2001.補助金有無フラグ'
    ,tltl2001.HOJOKN AS 'tltl2001.補助金'
    ,tltl2001.HOJOKNHNKYAKKBN AS 'tltl2001.補助金返却区分'
    ,tltl2001.STAFINCEJKNUMFLG AS 'tltl2001.その他ファイナンス条件有無フラグ'
    ,tltl2001.STAFINCEHYO AS 'tltl2001.その他ファイナンス費用'
    ,tltl2001.NHKNUMFLG AS 'tltl2001.任意保険有無フラグ'
    ,tltl2001.NHKNKISU AS 'tltl2001.任意保険回数'
    ,tltl2001.NHKNMSKDITOSHFTNUMFLG AS 'tltl2001.任意保険免責代当社負担有無フラグ'
    ,tltl2001.NHKNMSKDITOSHFTNKYKKISU AS 'tltl2001.任意保険免責代当社負担契約回数'
    ,tltl2001.NHKNMSKDITOSHFTNKYKGKA AS 'tltl2001.任意保険免責代当社負担契約原価'
    ,tltl2001.JIKOHSOUMFLG AS 'tltl2001.事故補償有無フラグ'
    ,tltl2001.JAFUMFLG AS 'tltl2001.ＪＡＦ有無フラグ'
    ,tltl2001.JAFHYO AS 'tltl2001.ＪＡＦ費用'
    ,tltl2001.SPOTDIALUMFLG AS 'tltl2001.サポートダイヤル有無フラグ'
    ,tltl2001.KYUYUCARDUMFLG AS 'tltl2001.給油カード有無フラグ'
    ,tltl2001.KYUYUCARDSBT AS 'tltl2001.給油カード種別'
    ,tltl2001.G_BOOKUMFLG AS 'tltl2001.Ｇ－ＢＯＯＫ有無フラグ'
    ,tltl2001.G_BOOKHYO AS 'tltl2001.Ｇ－ＢＯＯＫ費用'
    ,tltl2001.MNTKBN AS 'tltl2001.メンテナンス区分'
    ,tltl2001.SVREKBN AS 'tltl2001.シビア区分'
    ,tltl2001.SFMKYKUMFLG AS 'tltl2001.ＳＦＭ契約有無フラグ'
    ,tltl2001.SFMSHSHTYP AS 'tltl2001.ＳＦＭ車種タイプ'
    ,tltl2001.SFMNOUHIKIUMFLG AS 'tltl2001.ＳＦＭ納引有無フラグ'
    ,tltl2001.SFMHOMONTKUMFLG AS 'tltl2001.ＳＦＭ訪問点検有無フラグ'
    ,tltl2001.SFMHOMONTKCYCL AS 'tltl2001.ＳＦＭ訪問点検サイクル'
    ,tltl2001.SFMSHSHCLS AS 'tltl2001.ＳＦＭ車種クラス'
    ,tltl2001.SFMSOKOKYORICLS AS 'tltl2001.ＳＦＭ走行距離クラス'
    ,tltl2001.SHKNUMFLG AS 'tltl2001.車検有無フラグ'
    ,tltl2001.SHKNKISU AS 'tltl2001.車検回数'
    ,tltl2001.SHKNTEIKA AS 'tltl2001.車検定価'
    ,tltl2001.SHKNGKA AS 'tltl2001.車検原価'
    ,tltl2001.SHKNHNKUMFLG AS 'tltl2001.車検変更有無フラグ'
    ,tltl2001.SHKNFUTAITEIKA AS 'tltl2001.車検付帯定価'
    ,tltl2001.SHKNFUTAIGKA AS 'tltl2001.車検付帯原価'
    ,tltl2001.SHKNFUTAIHNKUMFLG AS 'tltl2001.車検付帯変更有無フラグ'
    ,tltl2001.HTENUMFLG AS 'tltl2001.法点有無フラグ'
    ,tltl2001.HTNCYCL AS 'tltl2001.法点サイクル'
    ,tltl2001.HTENKISU AS 'tltl2001.法点回数'
    ,tltl2001.HTENTEIKA AS 'tltl2001.法点定価'
    ,tltl2001.HTENGKA AS 'tltl2001.法点原価'
    ,tltl2001.HTENHNKUMFLG AS 'tltl2001.法点変更有無フラグ'
    ,tltl2001.HTENFUTAITEIKA AS 'tltl2001.法点付帯定価'
    ,tltl2001.HTENFUTAIGKA AS 'tltl2001.法点付帯原価'
    ,tltl2001.HTENFUTAIHNKUMFLG AS 'tltl2001.法点付帯変更有無フラグ'
    ,tltl2001.PRO10UMFLG AS 'tltl2001.プロケア１０有無フラグ'
    ,tltl2001.PRO10KISU AS 'tltl2001.プロケア１０回数'
    ,tltl2001.PRO10TEIKA AS 'tltl2001.プロケア１０定価'
    ,tltl2001.PRO10GKA AS 'tltl2001.プロケア１０原価'
    ,tltl2001.PRO10HNKUMFLG AS 'tltl2001.プロケア１０変更有無フラグ'
    ,tltl2001.PRO10FUTAITEIKA AS 'tltl2001.プロケア１０付帯定価'
    ,tltl2001.PRO10FUTAIGKA AS 'tltl2001.プロケア１０付帯原価'
    ,tltl2001.PRO10FUTAIHNKUMFLG AS 'tltl2001.プロケア１０付帯変更有無フラグ'
    ,tltl2001.IPNSEIBIUMFLG AS 'tltl2001.一般整備有無フラグ'
    ,tltl2001.IPNSEIBITEIKA AS 'tltl2001.一般整備定価'
    ,tltl2001.IPNSEIBIGKA AS 'tltl2001.一般整備原価'
    ,tltl2001.IPNSEIBIHNKUMFLG AS 'tltl2001.一般整備変更有無フラグ'
    ,tltl2001.JIKOREPAIRUMFLG AS 'tltl2001.事故修理有無フラグ'
    ,tltl2001.OILUMFLG AS 'tltl2001.オイル有無フラグ'
    ,tltl2001.OILKISU AS 'tltl2001.オイル回数'
    ,tltl2001.OILTEIKA AS 'tltl2001.オイル定価'
    ,tltl2001.OILGKA AS 'tltl2001.オイル原価'
    ,tltl2001.OILHNKUMFLG AS 'tltl2001.オイル変更有無フラグ'
    ,tltl2001.BTTRYUMFLG AS 'tltl2001.バッテリー有無フラグ'
    ,tltl2001.BTTRYKOSU AS 'tltl2001.バッテリー個数'
    ,tltl2001.BTTRYNM1 AS 'tltl2001.バッテリー名称１'
    ,tltl2001.BTTRYNM2 AS 'tltl2001.バッテリー名称２'
    ,tltl2001.BTTRYTEIKA AS 'tltl2001.バッテリー定価'
    ,tltl2001.BTTRYGKA AS 'tltl2001.バッテリー原価'
    ,tltl2001.BTTRYHNKUMFLG AS 'tltl2001.バッテリー変更有無フラグ'
    ,tltl2001.BTTRYMUSEIGENKBN AS 'tltl2001.バッテリー無制限区分'
    ,tltl2001.JNKISVCUMFLG AS 'tltl2001.巡回サービス有無フラグ'
    ,tltl2001.JNKISVCKISU AS 'tltl2001.巡回サービス回数'
    ,tltl2001.JNKISVCCYCL AS 'tltl2001.巡回サービスサイクル'
    ,tltl2001.JNKISVCTEIKA AS 'tltl2001.巡回サービス定価'
    ,tltl2001.JNKISVCGKA AS 'tltl2001.巡回サービス原価'
    ,tltl2001.JNKISVCHNKUMFLG AS 'tltl2001.巡回サービス変更有無フラグ'
    ,tltl2001.JNKISVCTRKFLG AS 'tltl2001.巡回サービス登録フラグ'
    ,tltl2001.TIREUMFLG AS 'tltl2001.タイヤ有無フラグ'
    ,tltl2001.TIRECD01 AS 'tltl2001.タイヤコード０１'
    ,tltl2001.TIRECD02 AS 'tltl2001.タイヤコード０２'
    ,tltl2001.TIRECD03 AS 'tltl2001.タイヤコード０３'
    ,tltl2001.TIRECD04 AS 'tltl2001.タイヤコード０４'
    ,tltl2001.TIRECD05 AS 'tltl2001.タイヤコード０５'
    ,tltl2001.TIRECD06 AS 'tltl2001.タイヤコード０６'
    ,tltl2001.TIRESZ01 AS 'tltl2001.タイヤサイズ０１'
    ,tltl2001.TIRESZ02 AS 'tltl2001.タイヤサイズ０２'
    ,tltl2001.TIRESZ03 AS 'tltl2001.タイヤサイズ０３'
    ,tltl2001.TIRESZ04 AS 'tltl2001.タイヤサイズ０４'
    ,tltl2001.TIRESZ05 AS 'tltl2001.タイヤサイズ０５'
    ,tltl2001.TIRESZ06 AS 'tltl2001.タイヤサイズ０６'
    ,tltl2001.TIREHONSU01 AS 'tltl2001.タイヤ本数０１'
    ,tltl2001.TIREHONSU02 AS 'tltl2001.タイヤ本数０２'
    ,tltl2001.TIREHONSU03 AS 'tltl2001.タイヤ本数０３'
    ,tltl2001.TIREHONSU04 AS 'tltl2001.タイヤ本数０４'
    ,tltl2001.TIREHONSU05 AS 'tltl2001.タイヤ本数０５'
    ,tltl2001.TIREHONSU06 AS 'tltl2001.タイヤ本数０６'
    ,tltl2001.TIRETEIKA01 AS 'tltl2001.タイヤ定価０１'
    ,tltl2001.TIRETEIKA02 AS 'tltl2001.タイヤ定価０２'
    ,tltl2001.TIRETEIKA03 AS 'tltl2001.タイヤ定価０３'
    ,tltl2001.TIRETEIKA04 AS 'tltl2001.タイヤ定価０４'
    ,tltl2001.TIRETEIKA05 AS 'tltl2001.タイヤ定価０５'
    ,tltl2001.TIRETEIKA06 AS 'tltl2001.タイヤ定価０６'
    ,tltl2001.TIREGKA01 AS 'tltl2001.タイヤ原価０１'
    ,tltl2001.TIREGKA02 AS 'tltl2001.タイヤ原価０２'
    ,tltl2001.TIREGKA03 AS 'tltl2001.タイヤ原価０３'
    ,tltl2001.TIREGKA04 AS 'tltl2001.タイヤ原価０４'
    ,tltl2001.TIREGKA05 AS 'tltl2001.タイヤ原価０５'
    ,tltl2001.TIREGKA06 AS 'tltl2001.タイヤ原価０６'
    ,tltl2001.TIREHNKUMFLG01 AS 'tltl2001.タイヤ変更有無フラグ０１'
    ,tltl2001.TIREHNKUMFLG02 AS 'tltl2001.タイヤ変更有無フラグ０２'
    ,tltl2001.TIREHNKUMFLG03 AS 'tltl2001.タイヤ変更有無フラグ０３'
    ,tltl2001.TIREHNKUMFLG04 AS 'tltl2001.タイヤ変更有無フラグ０４'
    ,tltl2001.TIREHNKUMFLG05 AS 'tltl2001.タイヤ変更有無フラグ０５'
    ,tltl2001.TIREHNKUMFLG06 AS 'tltl2001.タイヤ変更有無フラグ０６'
    ,tltl2001.TIREMUSEIGENFLG01 AS 'tltl2001.タイヤ無制限フラグ０１'
    ,tltl2001.TIREMUSEIGENFLG02 AS 'tltl2001.タイヤ無制限フラグ０２'
    ,tltl2001.TIREMUSEIGENFLG03 AS 'tltl2001.タイヤ無制限フラグ０３'
    ,tltl2001.TIREMUSEIGENFLG04 AS 'tltl2001.タイヤ無制限フラグ０４'
    ,tltl2001.TIREMUSEIGENFLG05 AS 'tltl2001.タイヤ無制限フラグ０５'
    ,tltl2001.TIREMUSEIGENFLG06 AS 'tltl2001.タイヤ無制限フラグ０６'
    ,tltl2001.TIREHOKANUMFLG AS 'tltl2001.タイヤ保管有無フラグ'
    ,tltl2001.TIREHOKANGKA AS 'tltl2001.タイヤ保管原価'
    ,tltl2001.TIREHOKANTEIKA AS 'tltl2001.タイヤ保管定価'
    ,tltl2001.TIREHOKANHNKUMFLG AS 'tltl2001.タイヤ保管変更有無フラグ'
    ,tltl2001.DISHAUMFLG AS 'tltl2001.代車有無フラグ'
    ,tltl2001.DISHASHKNJIDSU AS 'tltl2001.代車車検時日数'
    ,tltl2001.DISHASHKNJITEIKA AS 'tltl2001.代車車検時定価'
    ,tltl2001.DISHASHKNJIGKA AS 'tltl2001.代車車検時原価'
    ,tltl2001.DISHASHKNJIHNKUMFLG AS 'tltl2001.代車車検時変更有無フラグ'
    ,tltl2001.DISHASHKNJIMUSEIGENFLG AS 'tltl2001.代車車検時無制限フラグ'
    ,tltl2001.DISHAHTENJIDSU AS 'tltl2001.代車法点時日数'
    ,tltl2001.DISHAHTENJITEIKA AS 'tltl2001.代車法点時定価'
    ,tltl2001.DISHAHTENJIGKA AS 'tltl2001.代車法点時原価'
    ,tltl2001.DISHAHTENJIHNKUMFLG AS 'tltl2001.代車法点時変更有無フラグ'
    ,tltl2001.DISHAHTENJIMUSEIGENFLG AS 'tltl2001.代車法点時無制限フラグ'
    ,tltl2001.DISHAJIKOJIDSU AS 'tltl2001.代車事故時日数'
    ,tltl2001.DISHAJIKOJITEIKA AS 'tltl2001.代車事故時定価'
    ,tltl2001.DISHAJIKOJIGKA AS 'tltl2001.代車事故時原価'
    ,tltl2001.DISHAJIKOJIHNKUMFLG AS 'tltl2001.代車事故時変更有無フラグ'
    ,tltl2001.DISHAJIKOJIMUSEIGENFLG AS 'tltl2001.代車事故時無制限フラグ'
    ,tltl2001.DISHAIPNDSU AS 'tltl2001.代車一般日数'
    ,tltl2001.DISHAIPNTEIKA AS 'tltl2001.代車一般定価'
    ,tltl2001.DISHAIPNGKA AS 'tltl2001.代車一般原価'
    ,tltl2001.DISHAIPNHNKUMFLG AS 'tltl2001.代車一般変更有無フラグ'
    ,tltl2001.DISHAIPNMUSEIGENFLG AS 'tltl2001.代車一般無制限フラグ'
    ,tltl2001.DISHATKYJKN AS 'tltl2001.代車提供条件'
    ,tltl2001.FGOKTEIKA AS 'tltl2001.Ｆ合計定価'
    ,tltl2001.FGOKGKA AS 'tltl2001.Ｆ合計原価'
    ,tltl2001.MGOKTEIKA AS 'tltl2001.Ｍ合計定価'
    ,tltl2001.MGOKGKA AS 'tltl2001.Ｍ合計原価'
    ,tltl2001.FMGOKTEIKA AS 'tltl2001.ＦＭ合計定価'
    ,tltl2001.FMGOKGKA AS 'tltl2001.ＦＭ合計原価'
    ,tltl2001.ZNKSESNKBN AS 'tltl2001.残価精算区分'
    ,tltl2001.ZNKKSKBN AS 'tltl2001.残価係数区分'
    ,tltl2001.ZNKTEIKA AS 'tltl2001.残価定価'
    ,tltl2001.ZNKGKA AS 'tltl2001.残価原価'
    ,tltl2001.ZNKHGK AS 'tltl2001.残価表示額'
    ,tltl2001.ZNKRT AS 'tltl2001.残価率'
    ,tltl2001.ARARRRT AS 'tltl2001.細利率'
    ,tltl2001.ARARIGK AS 'tltl2001.粗利額'
    ,tltl2001.LSRYOSOGKTEIKA AS 'tltl2001.リース料総額定価'
    ,tltl2001.LSRYOSOGKGKA AS 'tltl2001.リース料総額原価'
    ,tltl2001.CHSGOARARRRT AS 'tltl2001.調整後粗利率'
    ,tltl2001.CHSGOARARIGK AS 'tltl2001.調整後粗利額'
    ,tltl2001.CHSGK AS 'tltl2001.調整額'
    ,tltl2001.CHSGOLSRYOSOGK AS 'tltl2001.調整後リース料総額'
    ,tltl2001.KITSNGIKNKHNRYO AS 'tltl2001.規定損害金基本料'
    ,tltl2001.KITSNGIKNTGNMGK AS 'tltl2001.規定損害金逓減月額'
    ,tltl2001.KITSNGIKNTGNMGKRK AS 'tltl2001.規定損害金逓減月額累計'
    ,tltl2001.KITSNGIKNKKAMSU AS 'tltl2001.規定損害金経過月数'
    ,tltl2001.KAZEIKBN AS 'tltl2001.課税区分'
    ,tltl2001.KAZEITAISGAIKBN AS 'tltl2001.課税対象外区分'
    ,tltl2001.MITUKLSKISU AS 'tltl2001.毎月リース回数'
    ,tltl2001.MITUKLSGK AS 'tltl2001.毎月リース額'
    ,tltl2001.MITUKSHHTXGK AS 'tltl2001.毎月消費税額'
    ,tltl2001.BNSM1 AS 'tltl2001.ボーナス月１'
    ,tltl2001.BNSM2 AS 'tltl2001.ボーナス月２'
    ,tltl2001.BNSMLSGK AS 'tltl2001.ボーナス月リース額'
    ,tltl2001.BNSMSHHTXGK AS 'tltl2001.ボーナス月消費税額'
    ,tltl2001.NAKANUKEMS AS 'tltl2001.中抜け月開始'
    ,tltl2001.NAKANUKEME AS 'tltl2001.中抜け月終了'
    ,tltl2001.NAKANUKEMLSGK AS 'tltl2001.中抜け月リース額'
    ,tltl2001.NAKANUKEMSHHTXGK AS 'tltl2001.中抜け月消費税額'
    ,tltl2001.DWSHKAI AS 'tltl2001.日割初回'
    ,tltl2001.DWSHKAILSGK AS 'tltl2001.日割初回リース額'
    ,tltl2001.DWSHKAISHHTXGK AS 'tltl2001.日割初回消費税額'
    ,tltl2001.DWLASTKAI AS 'tltl2001.日割最終回'
    ,tltl2001.DWLASTKAILSGK AS 'tltl2001.日割最終回リース額'
    ,tltl2001.DWLASTKAISHHTXGK AS 'tltl2001.日割最終回消費税額'
    ,tltl2001.MBKN AS 'tltl2001.前払金'
    ,tltl2001.MBKNPAYYMD AS 'tltl2001.前払金支払年月日'
    ,tltl2001.MBKNSHKAISKYKBN AS 'tltl2001.前払金初回請求区分'
    ,tltl2001.MBKN1KISU AS 'tltl2001.前払金１回数'
    ,tltl2001.MBKN1 AS 'tltl2001.前払金１'
    ,tltl2001.MBKN2KISUJI AS 'tltl2001.前払金２回数自'
    ,tltl2001.MBKN2KISUITR AS 'tltl2001.前払金２回数至'
    ,tltl2001.MBKN2KAIAT AS 'tltl2001.前払金２回当'
    ,tltl2001.MBKN3KISUJI AS 'tltl2001.前払金３回数自'
    ,tltl2001.MBKN3KISUITR AS 'tltl2001.前払金３回数至'
    ,tltl2001.MBKN3KAIAT AS 'tltl2001.前払金３回当'
    ,tltl2001.HOSHOKNGK AS 'tltl2001.保証金額'
    ,tltl2001.HOSHOKNPAYYMD AS 'tltl2001.保証金支払年月日'
    ,tltl2001.HOSHOKNSHKAISKYKBN AS 'tltl2001.保証金初回請求区分'
    ,tltl2001.LSPAYKISUJI1 AS 'tltl2001.リース支払回数自１'
    ,tltl2001.LSPAYKISUITR1 AS 'tltl2001.リース支払回数至１'
    ,tltl2001.LSPAYYMD1 AS 'tltl2001.リース支払年月日１'
    ,tltl2001.SHKAISKYKBN1KAIME AS 'tltl2001.初回請求区分１回目'
    ,tltl2001.LSPAYKISUJI2 AS 'tltl2001.リース支払回数自２'
    ,tltl2001.LSPAYKISUITR2 AS 'tltl2001.リース支払回数至２'
    ,tltl2001.LSPAYYMD2 AS 'tltl2001.リース支払年月日２'
    ,tltl2001.SHKAISKYKBNSCN AS 'tltl2001.初回請求区分２回目'
    ,tltl2001.LSPAYKISUJI3 AS 'tltl2001.リース支払回数自３'
    ,tltl2001.LSPAYKISUITR3 AS 'tltl2001.リース支払回数至３'
    ,tltl2001.LSPAYKISUJI4 AS 'tltl2001.リース支払回数自４'
    ,tltl2001.LSPAYKISUITR4 AS 'tltl2001.リース支払回数至４'
    ,tltl2001.TCDTNO AS 'tltl2001.トヨタクレジットＮｏ'
    ,tltl2001.HNBITENKNRNO AS 'tltl2001.販売店管理番号'
    ,tltl2001.SHKNHOSHOSHNINNO AS 'tltl2001.集金保証承認番号'
    ,tltl2001.JAFNO AS 'tltl2001.ＪＡＦＮｏ'
    ,tltl2001.JCHKTRY AS 'tltl2001.受注獲得理由'
    ,tltl2001.JCHKTRY5KT AS 'tltl2001.受注獲得理由（５桁）'
    ,tltl2001.DTRKRY AS 'tltl2001.脱落理由'
    ,tltl2001.KIYKSHRIKBN AS 'tltl2001.解約処理区分'
    ,tltl2001.KIYKRYKBN AS 'tltl2001.解約理由区分'
    ,tltl2001.KIYKRYOSKYKBN AS 'tltl2001.解約料請求区分'
    ,tltl2001.KIYKRYOPAYYMD AS 'tltl2001.解約料支払年月日'
    ,tltl2001.KMDSKISU AS 'tltl2001.組戻回数'
    ,tltl2001.KMDSSYMD AS 'tltl2001.組戻開始年月日'
    ,tltl2001.KMDSEYMD AS 'tltl2001.組戻終了年月日'
    ,tltl2001.KMDSGOKGK AS 'tltl2001.組戻合計額'
    ,tltl2001.KMDSSCS AS 'tltl2001.組戻枝番始'
    ,tltl2001.KMDSSCE AS 'tltl2001.組戻枝番終'
    ,tltl2001.JCHYMD AS 'tltl2001.受注年月日'
    ,tltl2001.KYKYMD AS 'tltl2001.契約年月日'
    ,tltl2001.CTKYKYMD AS 'tltl2001.中途解約年月日'
    ,tltl2001.CNCLYMD AS 'tltl2001.キャンセル年月日'
    ,tltl2001.MSHYMD AS 'tltl2001.抹消年月日'
    ,tltl2001.NOSHAYMD AS 'tltl2001.納車年月日'
    ,tltl2001.LSSYTIYMD AS 'tltl2001.リース開始予定年月日'
    ,tltl2001.MGKHNKSGK AS 'tltl2001.月額変更差額'
    ,tltl2001.TRKKJOYMD AS 'tltl2001.登録計上年月日'
    ,tltl2001.TRKSHRIYMD AS 'tltl2001.登録処理年月日'
    ,tltl2001.JCHKJOYMD AS 'tltl2001.受注計上年月日'
    ,tltl2001.CNCLKJOYMD AS 'tltl2001.キャンセル計上年月日'
    ,tltl2001.CTKYKKJOYMD AS 'tltl2001.中途解約計上年月日'
    ,tltl2001.IKTPAYMSU AS 'tltl2001.一括払月数'
    ,tltl2001.SETKNRJSSITSUP AS 'tltl2001.設定金利実質％'
    ,tltl2001.SETKNRGKA AS 'tltl2001.設定金利原価'
    ,tltl2001.CHOKIKNRJSSITSUP AS 'tltl2001.長期金利実質％'
    ,tltl2001.CHOKIKNRGKA AS 'tltl2001.長期金利原価'
    ,tltl2001.ATMKIN AS 'tltl2001.頭金'
    ,tltl2001.SETATMKINKNRP AS 'tltl2001.設定頭金金利％'
    ,tltl2001.CHOKIATMKINKNRP AS 'tltl2001.長期頭金金利％'
    ,tltl2001.TTLARARRRT AS 'tltl2001.トータル粗利率'
    ,tltl2001.SHRFEE AS 'tltl2001.車両手数料'
    ,tltl2001.HKNFEE AS 'tltl2001.保険手数料'
    ,tltl2001.HKNFEEBTNRT AS 'tltl2001.保険手数料分担率'
    ,tltl2001.STAICM AS 'tltl2001.その他収入'
    ,tltl2001.SITADORICARKAITRIKK AS 'tltl2001.下取車買取価格'
    ,tltl2001.SITADORICARBAIKYAKYTIKK AS 'tltl2001.下取車売却予定価格'
    ,tltl2001.SKYSHBIKO1 AS 'tltl2001.請求書備考１'
    ,tltl2001.SKYSHBIKO2 AS 'tltl2001.請求書備考２'
    ,tltl2001.SHKNINFTRIKMSUMIFLG AS 'tltl2001.車検情報取込済フラグ'
    ,tltl2001.MBKNSKYSHNO AS 'tltl2001.前払金請求書Ｎｏ'
    ,tltl2001.MBKNSKYSHOUTFLG AS 'tltl2001.前払金請求書出力フラグ'
    ,tltl2001.MBKNSKYSHSHHTXRT AS 'tltl2001.前払金請求書消費税率'
    ,tltl2001.MNTCARDOUTJOKYO AS 'tltl2001.メンテナンスカード出力状況'
    ,tltl2001.MNTCARDOUTFLG AS 'tltl2001.メンテナンスカード出力フラグ'
    ,tltl2001.SFMNTCARDFKHYOOUTJOKYO AS 'tltl2001.ＳＦメンテナンスカード副表出力状況'
    ,tltl2001.SFMNTCARDFKHYOOUTFLG AS 'tltl2001.ＳＦメンテナンスカード副表出力フラグ'
    ,tltl2001.SHKNFLTRIKMFLG AS 'tltl2001.車検ファイル取込フラグ'
    ,tltl2001.TKYAK1 AS 'tltl2001.特約１'
    ,tltl2001.TKYAK2 AS 'tltl2001.特約２'
    ,tltl2001.TKYAK3 AS 'tltl2001.特約３'
    ,tltl2001.TKYAK4 AS 'tltl2001.特約４'
    ,tltl2001.TKYAK5 AS 'tltl2001.特約５'
    ,tltl2001.TKYAK6 AS 'tltl2001.特約６'
    ,tltl2001.MEMO1 AS 'tltl2001.メモ１'
    ,tltl2001.MEMO2 AS 'tltl2001.メモ２'
    ,tltl2001.MEMO3 AS 'tltl2001.メモ３'
    ,tltl2001.MEMO4 AS 'tltl2001.メモ４'
    ,tltl2001.MEMO5 AS 'tltl2001.メモ５'
    ,tltl2001.MEMOA AS 'tltl2001.メモＡ'
    ,tltl2001.MEMOB AS 'tltl2001.メモＢ'
    ,tltl2001.MEMOC AS 'tltl2001.メモＣ'
    ,tltl2001.MEMOD AS 'tltl2001.メモＤ'
    ,tltl2001.MEMOE AS 'tltl2001.メモＥ'
    ,tltl2001.MEMOF AS 'tltl2001.メモＦ'
    ,tltl2001.HKNMOSHIKOMRENKEISUMIFLG AS 'tltl2001.保険申込連携済フラグ'
    ,tltl2001.MBKNSKYD AS 'tltl2001.前払金請求日'
    ,tltl2001.ZNKHOSHOKBN AS 'tltl2001.残価保証区分'
    ,tltl2001.SHYUKITNKBN AS 'tltl2001.所有権移転区分'
    ,tltl2001.LSTRIHKKBN AS 'tltl2001.リース取引区分'
    ,tltl2001.LSTRIHKKBNKST AS 'tltl2001.リース取引区分（貸手）'
    ,tltl2001.MITUKLSRYOHNKFLG AS 'tltl2001.毎月リース料変更フラグ'
    ,tltl2001.LSTRIHKKBNZIMB AS 'tltl2001.リース取引区分（税務Ｂ）'
    ,tltl2001.SHYUKITNKBNZIMB AS 'tltl2001.所有権移転区分（税務Ｂ）'
    ,tltl2001.MNTCARDSKSED AS 'tltl2001.メンテナンスカード作成日'
    ,tltl2001.MNTCARDZNKSKSED AS 'tltl2001.メンテナンスカード前回作成日'
    ,tltl2001.MNTCARDFKHYOSKSED AS 'tltl2001.メンテナンスカード副表作成日'
    ,tltl2001.MNTCARDFKHYOZNKSKSED AS 'tltl2001.メンテナンスカード副表前回作成日'
    ,tltl2001.SHSHCLS AS 'tltl2001.車種クラス'
    ,tltl2001.DNKYKKBN AS 'tltl2001.ＤＮ契約区分'
    ,tltl2001.DNSESNNOSC AS 'tltl2001.ＤＮ精算Ｎｏ枝番'
    ,tltl2001.SCHTKKBN AS 'tltl2001.スケジュール点検区分'
    ,tltl2001.MPBKBN AS 'tltl2001.ＭＰＢ区分'
    ,tltl2001.SHHTXKKASOTIKBN AS 'tltl2001.消費税経過措置区分'
    ,tltl2001.SYSUPDCLIENTID AS 'tltl2001.システム更新クライアントＩＤ'
    ,tltl2001.SYSUPDPRGID AS 'tltl2001.システム更新プログラムＩＤ'
    ,tltl2001.SYSUPDYMDHMS AS 'tltl2001.システム更新年月日時分秒'
    ,tltl2001.TCKYKUMFLG AS 'tltl2001.ＴＣ契約有無フラグ'
    ,tltl2001.TCKYKKBN AS 'tltl2001.ＴＣ契約区分'
    ,tltl2001.TCKYKHYO AS 'tltl2001.ＴＣ契約費用'
    ,tltl2001.MNTTKTSFLG AS 'tltl2001.メンテ統括フラグ'
    ,tltl2001.DNCENFLG AS 'tltl2001.ＤＮセンターフラグ'

    ,jslimorderstatus.sim_kndate_dt AS `納期情報_納期シミュレーション結果(日付型)`
    --,jslimorderstatus.toroyote      AS 登録予定日
    ,tbba001g.no_order              AS オーダーNo
    ,tbba051g_sel.kn_kinmumei       AS 名義人勤務先名

    -- 塗色差異：不同就〇
    ,CASE
        WHEN COALESCE(REPLACE(TRIM(tltl2001.toshokcd), '　', ''), '') <>
             COALESCE(REPLACE(TRIM(tbba001g.mj_gaihansy), '　', ''), '')
        THEN '〇' ELSE NULL
     END AS 塗色差異

    -- 型式差異：不同就〇
    ,CASE
        WHEN COALESCE(REPLACE(TRIM(tbba001g.mj_hantenkt), '　', ''), '') <>
             COALESCE(REPLACE(TRIM(tltl2001.kata),       '　', ''), '')
        THEN '〇' ELSE NULL
     END AS 型式差異

    -- 型式色差異：任一组有差异就〇
    ,CASE
        WHEN COALESCE(REPLACE(TRIM(tltl2001.toshokcd), '　', ''), '') <>
             COALESCE(REPLACE(TRIM(tbba001g.mj_gaihansy), '　', ''), '')
          OR COALESCE(REPLACE(TRIM(tbba001g.mj_hantenkt), '　', ''), '') <>
             COALESCE(REPLACE(TRIM(tltl2001.kata),       '　', ''), '')
        THEN '〇' ELSE NULL
     END AS 型式色差異

    -- メーカーOPT４５桁：有任一项则〇
    ,CASE
        WHEN COALESCE(TRIM(tbba001g.mj_makeop1),  '') <> '' OR
             COALESCE(TRIM(tbba001g.mj_makeop2),  '') <> '' OR
             COALESCE(TRIM(tbba001g.mj_makeop3),  '') <> '' OR
             COALESCE(TRIM(tbba001g.mj_makeop4),  '') <> '' OR
             COALESCE(TRIM(tbba001g.mj_makeop5),  '') <> '' OR
             COALESCE(TRIM(tbba001g.mj_makeop6),  '') <> '' OR
             COALESCE(TRIM(tbba001g.mj_makeop7),  '') <> '' OR
             COALESCE(TRIM(tbba001g.mj_makeop8),  '') <> '' OR
             COALESCE(TRIM(tbba001g.mj_makeop9),  '') <> '' OR
             COALESCE(TRIM(tbba001g.mj_makeop10), '') <> '' OR
             COALESCE(TRIM(tbba001g.mj_makeop11), '') <> '' OR
             COALESCE(TRIM(tbba001g.mj_makeop12), '') <> '' OR
             COALESCE(TRIM(tbba001g.mj_makeop13), '') <> '' OR
             COALESCE(TRIM(tbba001g.mj_makeop14), '') <> '' OR
             COALESCE(TRIM(tbba001g.mj_makeop15), '') <> '' OR
             COALESCE(TRIM(tbba001g.mj_makeop16), '') <> ''
        THEN '〇' ELSE NULL
     END AS メーカーOPT４５桁
    ,houjinhankatsu.dt_nifi_kosin AS 'houjinhankatsu.nifi更新日'
    ,'D11' || tbv0200m.cd_hanbaitn || tbba001g.no_cyumon AS 車両特定番号
    ,CAST(tltl2001.lskykno AS STRING) || trim(houjinhankatsu.no_cyumon_fk) AS 契約ＮＯのSort
    -- 内装差異：不同就〇
    ,CASE
        WHEN COALESCE(REPLACE(TRIM(tltl2001.NAISOSHOKCD), '　', ''), '') <>
             COALESCE(REPLACE(TRIM(tbba001g.cd_utihari), '　', ''), '')
        THEN '〇' ELSE NULL
     END AS 内装差異

FROM neo1rep_ve.tltl2001 tltl2001 --契約情報

    -- ★ 1) tltl2001 ⇔ houjinhankatsu（最新行）【INNER JOIN】
    INNER JOIN (
        SELECT
             h.no_cyumon
            ,h.no_cyumon_fk
            ,h.dt_nifi_kosin
            ,COALESCE(h.mj_risukaisyasyaryokeiyakuno, h.mj_risukaisyasyaryokeiyakunoyobi) AS mj_risukaisyasyaryokeiyakuno
        FROM dx_ve.houjinhankatsu h --中間ファイルデータ
    ) houjinhankatsu
      --リース会社車両契約NO/リース会社車両契約NO(予備) = リース契約Ｎｏ
      ON CAST(houjinhankatsu.mj_risukaisyasyaryokeiyakuno AS INT) = tltl2001.lskykno

    -- ★ 2) houjinhankatsu ⇔ tbba001g（受注番号(枝番付)）【INNER JOIN】
    --INNER JOIN tbba001g tbba001g
      INNER JOIN ai21rep_ve_dx.tbba001g tbba001g --新車受注基本情報ＤＢ
      --ON TRIM(tbba001g.no_cyumon || tbba001g.no_cyumoned) = TRIM(houjinhankatsu.no_cyumon)
      --'T_'+[注文ＮＯ]+[注文ＮＯ枝番]+'_'+[受注発生日] = [注文No(外部キー)]
      ON CAST('T_' || tbba001g.no_cyumon || tbba001g.no_cyumoned || '_' || COALESCE(from_unixtime(unix_timestamp(tbba001g.dd_jucyuhas), 'yyyyMMdd'), '') AS String)  = houjinhankatsu.no_cyumon_fk
    LEFT JOIN ai21rep_ve_dx.tbba031g tbba031g --登録ＤＢ
      ON tbba031g.cd_hansya = tbba001g.cd_hansya
     AND tbba031g.cd_kaisya = tbba001g.cd_kaisya
     AND tbba031g.no_cyumon = tbba001g.no_cyumon
     AND tbba031g.no_cyumoned = tbba001g.no_cyumoned
    LEFT JOIN ai21rep_ve_dx.tbba008g tbba008g --新車車両情報ＤＢ
      --販社コード、会社コード、注文ＮＯ、注文ＮＯ枝番、仕向先、オーダーＮＯ、型式ハイフン前、フレームＮＯ、仕入日
      ON tbba008g.cd_hansya = tbba001g.cd_hansya
     AND tbba008g.cd_kaisya = tbba001g.cd_kaisya
     AND tbba008g.no_cyumon = tbba001g.no_cyumon
     AND tbba008g.no_cyumoned = tbba001g.no_cyumoned
     AND tbba008g.mj_simuksak = tbba001g.mj_simuksak
     AND tbba008g.no_order = tbba001g.no_order
     AND tbba008g.mj_katahima = tbba001g.mj_katahima
     AND tbba008g.no_frame = tbba001g.no_frame
     AND tbba008g.dd_siire  = tbba001g.dd_siire
    LEFT JOIN ai21rep_ve_dx.tbba035g tbba035g --最終仕様ＤＢ
      --販社コード、会社コード、販売店型式、新旧世代、外鈑色、メーカーＯＰＴ１～メーカーＯＰＴ１６
      ON tbba035g.cd_hansya = tbba008g.cd_hansya
     AND tbba035g.cd_kaisya = tbba008g.cd_kaisya
     AND tbba035g.mj_hantenkt = tbba008g.mj_hantenkt
     AND tbba035g.mj_sinkysed = tbba008g.mj_sinkysed
     AND tbba035g.mj_gaihansy = tbba008g.mj_gaihansy
     AND tbba035g.mj_makeop1 = tbba008g.mj_makeop1
     AND tbba035g.mj_makeop2 = tbba008g.mj_makeop2
     AND tbba035g.mj_makeop3 = tbba008g.mj_makeop3
     AND tbba035g.mj_makeop4 = tbba008g.mj_makeop4
     AND tbba035g.mj_makeop5 = tbba008g.mj_makeop5
     AND tbba035g.mj_makeop6 = tbba008g.mj_makeop6
     AND tbba035g.mj_makeop7 = tbba008g.mj_makeop7
     AND tbba035g.mj_makeop8 = tbba008g.mj_makeop8
     AND tbba035g.mj_makeop9 = tbba008g.mj_makeop9
     AND tbba035g.mj_makeop10 = tbba008g.mj_makeop10
     AND tbba035g.mj_makeop11 = tbba008g.mj_makeop11
     AND tbba035g.mj_makeop12 = tbba008g.mj_makeop12
     AND tbba035g.mj_makeop13 = tbba008g.mj_makeop13
     AND tbba035g.mj_makeop14 = tbba008g.mj_makeop14
     AND tbba035g.mj_makeop15 = tbba008g.mj_makeop15
     AND tbba035g.mj_makeop16 = tbba008g.mj_makeop16
    LEFT JOIN ai21rep_ve_dx.tbz0002c tbz0002c --システム情報ＤＢ
      ON tbz0002c.cd_hansya = tbba001g.cd_hansya
     AND tbz0002c.cd_kaisya = tbba001g.cd_kaisya
    LEFT JOIN neo1rep_ve.tltl2031 tltl2031 --車両発注情報
      --Ｒ店ＩＤ、リース契約Ｎｏ
      ON tltl2001.rtenid = tltl2031.rtenid
     AND tltl2001.lskykno = tltl2031.lskykno
    -- マスタ系：保持 LEFT JOIN
    LEFT JOIN ai21rep_ve_dx.tbv0200m tbv0200m --会社コードＤＢ
      ON tbba001g.cd_hansya = tbv0200m.cd_hansya
     AND tbba001g.cd_kaisya = tbv0200m.cd_kaisya

    LEFT JOIN ai21rep_ve_dx.tbv0014m tbv0014m --Ｍ社員ＤＢ
      ON tbba001g.cd_hansya   = tbv0014m.cd_hansya
     AND tbba001g.cd_kaisya   = tbv0014m.cd_kaisya
     AND tbba001g.cd_hanstaff = tbv0014m.cd_syain

    LEFT JOIN ai21rep_ve_dx.tbbf008m tbbf008m --車両スペック２ＤＢ
      --販社コード、会社コード、販売店型式、新旧世代、スペック区分
      ON tbba001g.cd_hansya   = tbbf008m.cd_hansya
     AND tbba001g.cd_kaisya   = tbbf008m.cd_kaisya
     AND tbba001g.mj_gaihansy = tbbf008m.cd_spec
     AND tbba001g.mj_sinkysed = tbbf008m.mj_sinkysed
     AND tbba001g.mj_hantenkt = tbbf008m.mj_hantenkt
     AND tbbf008m.kb_spec = 'G' --Ｇ：外鈑色

    LEFT JOIN ai21rep_ve_dx.tbbf001m tbbf001m --車名ＤＢ
      ON tbbf008m.cd_hansya = tbbf001m.cd_hansya
     AND tbbf008m.cd_kaisya = tbbf001m.cd_kaisya
     --車名 = 新車車名コード
     AND tbbf008m.mj_syamei = tbbf001m.cd_ncsyamei

    LEFT JOIN datalib_ve.V_JSLIM_STS jslimorderstatus
      ON TRIM(tbba001g.no_cyumon || tbba001g.no_cyumoned)
       = TRIM(jslimorderstatus.no_cyumon || jslimorderstatus.no_cyumoned)
     AND tbba001g.cd_hansya = jslimorderstatus.dlrcd
    LEFT JOIN (
        SELECT
             g.cd_hansya
            ,g.cd_kaisya
            ,g.no_cyumon
            ,g.no_cyumoned
            ,g.kn_kinmumei
            ,ROW_NUMBER() OVER (
                PARTITION BY g.cd_hansya, g.cd_kaisya, g.no_cyumon, g.no_cyumoned
                ORDER BY g.no_cyumon
            ) AS rn
        FROM ai21rep_ve_dx.tbba051g g --新車受注顧客情報ＤＢ
        WHERE g.kb_kokyaku = '2' --顧客区分 = 2:名義人
    ) tbba051g_sel
      ON tbba001g.cd_hansya   = tbba051g_sel.cd_hansya
     AND tbba001g.cd_kaisya   = tbba051g_sel.cd_kaisya
     AND tbba001g.no_cyumon   = tbba051g_sel.no_cyumon
     AND tbba001g.no_cyumoned = tbba051g_sel.no_cyumoned
     AND tbba051g_sel.rn = 1
--WHERE
    -- Ｒ店ＩＤ
    --tltl2001.RTENID = '122';
)

SELECT
    b.*
FROM (
    SELECT
        base.*,
        ROW_NUMBER() OVER (
            PARTITION BY base.契約ＮＯのSort
            ORDER BY base.`tbba001g.受注発生日` DESC, base.注文ＮＯ, base.注文ＮＯ枝番
        ) AS rn
    FROM base
) b
WHERE b.rn = 1
LIMIT 0;

-- [081/099] level=0 target=gold.enoreport_full_fixed_work_date
-- Gold dependencies: none
-- Source file: 018_NEO/enoreport_full_fixed_work_date_gold.sql

CREATE TABLE IF NOT EXISTS gold.enoreport_full_fixed_work_date AS
SELECT
    t.cd_hansya,
    t.cd_kaisya,
    TO_TIMESTAMP(
        concat(
            CAST(t.nu_yyyy AS STRING), '-',
            lpad(CAST(t.nu_tuki AS STRING),2,'0'), '-',
            lpad(CAST(d.day AS STRING),2,'0')
        ) , 'yyyy-MM-dd'
    ) AS mj_youbi
FROM ai21rep_ve_dx.tbbf018m t --カレンダＤＢ

CROSS JOIN (
    SELECT 1 AS day UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
    UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
    UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16
    UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20
    UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23 UNION ALL SELECT 24
    UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28
    UNION ALL SELECT 29 UNION ALL SELECT 30 UNION ALL SELECT 31
) d

WHERE
    t.nu_karend = 10
    AND
    CASE d.day
        WHEN 1 THEN t.mj_kyjium1
        WHEN 2 THEN t.mj_kyjium2
        WHEN 3 THEN t.mj_kyjium3
        WHEN 4 THEN t.mj_kyjium4
        WHEN 5 THEN t.mj_kyjium5
        WHEN 6 THEN t.mj_kyjium6
        WHEN 7 THEN t.mj_kyjium7
        WHEN 8 THEN t.mj_kyjium8
        WHEN 9 THEN t.mj_kyjium9
        WHEN 10 THEN t.mj_kyjium10
        WHEN 11 THEN t.mj_kyjium11
        WHEN 12 THEN t.mj_kyjium12
        WHEN 13 THEN t.mj_kyjium13
        WHEN 14 THEN t.mj_kyjium14
        WHEN 15 THEN t.mj_kyjium15
        WHEN 16 THEN t.mj_kyjium16
        WHEN 17 THEN t.mj_kyjium17
        WHEN 18 THEN t.mj_kyjium18
        WHEN 19 THEN t.mj_kyjium19
        WHEN 20 THEN t.mj_kyjium20
        WHEN 21 THEN t.mj_kyjium21
        WHEN 22 THEN t.mj_kyjium22
        WHEN 23 THEN t.mj_kyjium23
        WHEN 24 THEN t.mj_kyjium24
        WHEN 25 THEN t.mj_kyjium25
        WHEN 26 THEN t.mj_kyjium26
        WHEN 27 THEN t.mj_kyjium27
        WHEN 28 THEN t.mj_kyjium28
        WHEN 29 THEN t.mj_kyjium29
        WHEN 30 THEN t.mj_kyjium30
        WHEN 31 THEN t.mj_kyjium31
    END IN ('0','1')
LIMIT 0;

-- [082/099] level=0 target=gold.vbi019001
-- Gold dependencies: none
-- Source file: 019_中古車実績一覧(スタッフ別・店舗別)/中古車実績一覧（スタッフ別・店舗別）_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi019001 AS
SELECT 
	--販社コード
	cd_hansya,
	--会社コード
	cd_kaisya,
	--店舗コード
	cd_tenpo,
	--店舗名称
	kj_tenpomei,
	--販売スタッフコード
	cd_hanstaff,
	--社員名
	kj_syainmei,
	--月
	month,
	--受注
	SUM(su_jucyu) AS 'su_jucyu',
	--受注キャンセル反映
	SUM(su_jucyu) - SUM(su_jucyucancel) AS 'su_jucyucancelhane',
	--受注除軽
	SUM(su_jucyujyokei) AS 'su_jucyujyokei',
	--受注除軽キャンセル反映
	SUM(su_jucyujyokei) - SUM(su_jucyucanceljyokei) AS 'su_jucyucanceljyokeihane',
	--割賦
	SUM(su_kap) AS 'su_kap',
	--メンテナンスパック
	SUM(su_maintenancepack) AS 'su_maintenancepack'
FROM 
(
	SELECT
		--販社コード
		t.cd_hansya,
		--会社コード
		t.cd_kaisya,
		--受注店舗コード
		t.cd_jytyuten AS 'cd_tenpo',
		--店舗名称
		regexp_replace(t0201m.kj_tenpomei, '　+$', '') AS 'kj_tenpomei',
		--販売スタッフコード
		t.cd_hanstaff,
		--社員名
		regexp_replace(t014m.kj_syainmei, '　+$', '') AS 'kj_syainmei',
		--月
		IF(t.dd_jucyuke >= trunc(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'MM'),'当月','前月') AS 'month',
		--受注
		1 AS 'su_jucyu',
		--受注取消
		0 AS 'su_jucyucancel',
		--受注除軽
		IF(t001g.kn_kei <> '1',1,0) AS 'su_jucyujyokei',
		--受注取消除軽
		0 AS 'su_jucyucanceljyokei',
		--割賦
		-- 中古車受注販売条件情報ＤＢ.支払区分 = 2(割賦)
		IF(t020g.kb_siharai = '2',1 ,0) AS 'su_kap',
		--メンテナンスパック
		-- 中古車受注販売条件情報ＤＢ.メンテナンスパック契約区分 <> 空
		IF(
			t020g.kb_mntpkkei IS NOT NULL
			AND REPLACE(REPLACE(t020g.kb_mntpkkei, '　', ''), ' ', '') != '',
			1 ,0
		) AS 'su_maintenancepack'
	FROM 
	--抹消済中古車受注基本情報ＤＢ AND 中古車受注基本情報ＤＢ
	(
		SELECT cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,cd_jytyuten,cd_hanstaff,dd_jucyuke,no_syaryou FROM ai21rep_ve_dx.tbbc040g tbbc040g
		WHERE tbbc040g.dd_jucyuke >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
		UNION ALL
		SELECT cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,cd_jytyuten,cd_hanstaff,dd_jucyuke,no_syaryou FROM ai21rep_ve_dx.tbbc017g tbbc017g
		WHERE tbbc017g.dd_jucyuke >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
	) t
	-- 中古車受注販売条件情報ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbbc020g t020g
		ON t.cd_kaisya = t020g.cd_kaisya
		AND t.cd_hansya = t020g.cd_hansya
		AND t.no_cyumon = t020g.no_cyumon
		AND TRIM(t.no_cyumoned) = TRIM(t020g.no_cyumoned)
	-- M社員ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbv0014m t014m
		ON t014m.cd_kaisya = t.cd_kaisya
		AND t014m.cd_hansya = t.cd_hansya
		AND t014m.cd_syain = t.cd_hanstaff
	-- 中古車在庫基本情報ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbbc001g t001g 
    	ON t001g.cd_kaisya = t.cd_kaisya
	 	AND t001g.cd_hansya = t.cd_hansya
	 	AND t001g.no_syaryou = t.no_syaryou
	-- 共通店舗ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbv0201m t0201m
		ON t0201m.cd_kaisya = t.cd_kaisya
		AND t0201m.cd_hansya = t.cd_hansya
		AND t0201m.cd_tenpo = t.cd_jytyuten
	-- 店舗表示設定
	LEFT SEMI JOIN dx_ve.tbi999003m
		ON tbi999003m.cd_kaisya = t.cd_kaisya
	    AND tbi999003m.cd_hansya = t.cd_hansya
	    AND tbi999003m.cd_tenpo = t.cd_jytyuten
	    AND tbi999003m.mj_cyohyoid = '019'
	    AND tbi999003m.kb_tenji = 1
	UNION ALL
	SELECT
		--販社コード
		t.cd_hansya,
		--会社コード
		t.cd_kaisya,
		--受注店舗コード
		t.cd_jytyuten AS 'cd_tenpo',
		--店舗名称
		regexp_replace(t0201m.kj_tenpomei, '　+$', '') AS 'kj_tenpomei',
		--販売スタッフコード
		t.cd_hanstaff,
		--社員名
		regexp_replace(t014m.kj_syainmei, '　+$', '') AS 'kj_syainmei',
		--月
		IF(t.dd_torikesi >= trunc(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'MM'),'当月','前月') AS 'month',
		--受注
		0 AS 'su_jucyu',
		--受注取消
		1 AS 'su_jucyucancel',
		--受注除軽
		0 AS 'su_jucyujyokei',
		--受注取消除軽
		IF(t001g.kn_kei <> '1',1,0) AS 'su_jucyucanceljyokei',
		0 AS 'su_kap',
		0 AS 'su_maintenancepack'
	FROM 
	--抹消済中古車受注基本情報ＤＢ AND 中古車受注基本情報ＤＢ
	(
		SELECT cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,cd_jytyuten,cd_hanstaff,dd_jucyuke,dd_torikesi,no_syaryou 
		FROM ai21rep_ve_dx.tbbc040g
		WHERE tbbc040g.dd_torikesi >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM') AND tbbc040g.dd_jucyuke IS NOT NULL
		UNION ALL
		SELECT cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,cd_jytyuten,cd_hanstaff,dd_jucyuke,dd_torikesi,no_syaryou 
		FROM ai21rep_ve_dx.tbbc017g
		WHERE tbbc017g.dd_torikesi >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM') AND tbbc017g.dd_jucyuke IS NOT NULL
	) t
	-- M社員ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbv0014m t014m
		ON t014m.cd_kaisya = t.cd_kaisya
		AND t014m.cd_hansya = t.cd_hansya
		AND t014m.cd_syain = t.cd_hanstaff
	-- 中古車在庫基本情報ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbbc001g t001g 
    	ON t001g.cd_kaisya = t.cd_kaisya
	 	AND t001g.cd_hansya = t.cd_hansya
	 	AND t001g.no_syaryou = t.no_syaryou
	-- 共通店舗ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbv0201m t0201m
		ON t0201m.cd_kaisya = t.cd_kaisya
		AND t0201m.cd_hansya = t.cd_hansya
		AND t0201m.cd_tenpo = t.cd_jytyuten
	-- 店舗表示設定
	LEFT SEMI JOIN dx_ve.tbi999003m
		ON tbi999003m.cd_kaisya = t.cd_kaisya
	    AND tbi999003m.cd_hansya = t.cd_hansya
	    AND tbi999003m.cd_tenpo = t.cd_jytyuten
	    AND tbi999003m.mj_cyohyoid = '019'
	    AND tbi999003m.kb_tenji = 1
) t
GROUP BY
	cd_hansya,
	cd_kaisya,
	cd_tenpo,
	kj_tenpomei,
	cd_hanstaff,
	kj_syainmei,
	month
LIMIT 0;

-- [083/099] level=0 target=gold.vbi019002
-- Gold dependencies: none
-- Source file: 019_中古車実績一覧(スタッフ別・店舗別)/中古車実績一覧（スタッフ別・店舗別）_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi019002 AS
SELECT 
	--販社コード
	cd_hansya,
	--会社コード
	cd_kaisya,
	--店舗コード
	cd_tenpo,
	--店舗名称
	kj_tenpomei,
	--販売スタッフコード
	cd_hanstaff,
	--社員名
	kj_syainmei,
	--月
	month,
	--販売
	SUM(su_hanbai) AS 'su_hanbai',
	--販売キャンセル反映
	SUM(su_hanbai) - SUM(su_hanbaicancel) AS 'su_hanbaicancelhane',
	--販売除軽
	SUM(su_hanbaijyokei) AS 'su_hanbaijyokei',
	--販売除軽キャンセル反映
	SUM(su_hanbaijyokei) - SUM(su_hanbaicanceljyokei) AS 'su_hanbaicanceljyokeihene'
FROM 
(
	SELECT
		--販社コード
		t.cd_hansya,
		--会社コード
		t.cd_kaisya,
		--受注店舗コード
		t.cd_jytyuten AS 'cd_tenpo',
		--店舗名称
		regexp_replace(t0201m.kj_tenpomei, '　+$', '') AS 'kj_tenpomei',
		--販売スタッフコード
		t.cd_hanstaff,
		--社員名
		regexp_replace(t014m.kj_syainmei, '　+$', '') AS 'kj_syainmei',
		--月
		IF(
			IF(t.dd_uriage IS NULL, CAST(t.dd_uriagekj AS DATE), CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(t.dd_uriage AS STRING), 'yyyyMMdd')) AS DATE))
			>= trunc(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'MM')
			,'当月','前月'
		) AS 'month',
		--販売
		IF(
			(t.dd_uriage IS NOT NULL AND CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(t.dd_uriage AS STRING), 'yyyyMMdd')) AS DATE) >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM'))
			OR
			(t.dd_uriage IS NULL AND t.dd_uriagekj >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM'))
			,1 ,0
		) AS 'su_hanbai',
		--販売取消
		0 AS 'su_hanbaicancel',
		--販売除軽
		IF(
			t001g.kn_kei <> '1'
			AND
			(
				t.dd_uriage IS NOT NULL AND CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(t.dd_uriage AS STRING), 'yyyyMMdd')) AS DATE) >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
				OR
				t.dd_uriage IS NULL AND t.dd_uriagekj >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
			)
			,1 ,0
		) AS 'su_hanbaijyokei',
		--販売取消除軽
		0 AS 'su_hanbaicanceljyokei'
	FROM 
	--抹消済中古車受注基本情報ＤＢ AND 中古車受注基本情報ＤＢ
	(
		SELECT t040g.cd_hansya,t040g.cd_kaisya,t040g.no_cyumon,t040g.no_cyumoned,t040g.cd_jytyuten,t040g.cd_hanstaff,t040g.dd_torikesi,t040g.dd_uriagekj,t040g.no_syaryou,ft8006.dd_uriage
		FROM ai21rep_ve_dx.TBBC040G t040g
		LEFT JOIN 
		(
			SELECT
				t8006.cd_hansya,
				t8006.cd_kaisya,
				t8006.no_cyumon,
				MIN(t8006.dd_uriage) as dd_uriage
			FROM
				--中古車小売売上トランＤＢ
				ai21rep_ve_dx.tbg8006m t8006  
			GROUP BY
				t8006.cd_hansya,
				t8006.cd_kaisya,
				t8006.no_cyumon
		)ft8006 
		ON t040g.cd_kaisya = ft8006.cd_kaisya
		AND t040g.cd_kaisya = ft8006.cd_kaisya
		AND t040g.no_cyumon = ft8006.no_cyumon
		WHERE t040g.kb_uriage = '1A'
			AND t040g.dd_uriagekj IS NOT NULL
			AND t040g.dd_torikesi IS NULL
			AND (
				t040g.dd_uriagekj >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
				OR
				CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(ft8006.dd_uriage AS STRING), 'yyyyMMdd')) AS DATE) >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
			)
		UNION ALL
		SELECT t017g.cd_hansya,t017g.cd_kaisya,t017g.no_cyumon,t017g.no_cyumoned,t017g.cd_jytyuten,t017g.cd_hanstaff,t017g.dd_torikesi,t017g.dd_uriagekj,t017g.no_syaryou,ft8006.dd_uriage
		FROM ai21rep_ve_dx.tbbc017g t017g
		LEFT JOIN 
		(
			SELECT
				t8006.cd_hansya,
				t8006.cd_kaisya,
				t8006.no_cyumon,
				MIN(t8006.dd_uriage) as dd_uriage
			FROM
				--中古車小売売上トランＤＢ
				ai21rep_ve_dx.tbg8006m t8006  
			GROUP BY
				t8006.cd_hansya,
				t8006.cd_kaisya,
				t8006.no_cyumon
		)ft8006 
		ON t017g.cd_kaisya = ft8006.cd_kaisya
		AND t017g.cd_kaisya = ft8006.cd_kaisya
		AND t017g.no_cyumon = ft8006.no_cyumon
		WHERE t017g.kb_uriage = '1A'
			AND t017g.dd_uriagekj IS NOT NULL
			AND t017g.dd_torikesi IS NULL
			AND (
				t017g.dd_uriagekj >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
				OR
				CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(ft8006.dd_uriage AS STRING), 'yyyyMMdd')) AS DATE) >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
			)
	)t
	-- M社員ＤＢ
	LEFT JOIN ai21rep_ve_dx.TBV0014M t014m
		ON t014m.cd_kaisya = t.cd_kaisya
		AND t014m.cd_hansya = t.cd_hansya
		AND t014m.cd_syain = t.cd_hanstaff
	--  中古車在庫基本情報ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbbc001g t001g  
		ON t001g.cd_kaisya = t.cd_kaisya
		AND t001g.cd_hansya = t.cd_hansya
		AND t001g.no_syaryou = t.no_syaryou
	-- 共通店舗ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbv0201m t0201m
		ON t0201m.cd_kaisya = t.cd_kaisya
		AND t0201m.cd_hansya = t.cd_hansya
		AND t0201m.cd_tenpo = t.cd_jytyuten
    -- 店舗表示設定
	LEFT SEMI JOIN dx_ve.tbi999003m
			ON tbi999003m.cd_kaisya = t.cd_kaisya
			AND tbi999003m.cd_hansya = t.cd_hansya
			AND tbi999003m.cd_tenpo = t.cd_jytyuten
			AND tbi999003m.mj_cyohyoid = '019'
			AND tbi999003m.kb_tenji = 1
	UNION ALL
	SELECT
		--販社コード
		t.cd_hansya,
		--会社コード
		t.cd_kaisya,
		--受注店舗コード
		t.cd_jytyuten AS 'cd_tenpo',
		--店舗名称
		regexp_replace(t0201m.kj_tenpomei, '　+$', '') AS 'kj_tenpomei',
		--販売スタッフコード
		t.cd_hanstaff,
		--社員名
		regexp_replace(t014m.kj_syainmei, '　+$', '') AS 'kj_syainmei',
		--月
		IF(t.dd_uritorik >= trunc(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'MM'),'当月','前月') AS 'month',
		--販売
		0 AS 'su_hanbai',
		--販売取消
	    1 AS 'su_hanbaicancel',
	    --販売除軽
		0 AS 'su_hanbaijyokei',
		--販売取消除軽
		IF(t001g.kn_kei <> '1',1,0) AS 'su_hanbaicanceljyokei'
	FROM 
	--抹消済中古車受注基本情報ＤＢ AND 中古車受注基本情報ＤＢ
	(
		SELECT t040g.cd_hansya,t040g.cd_kaisya,t040g.no_cyumon,t040g.no_cyumoned,t040g.cd_jytyuten,t040g.cd_hanstaff,t040g.dd_jucyuke,t040g.dd_uritorik,t040g.no_syaryou,t040g.kb_uriage
		FROM ai21rep_ve_dx.TBBC040G t040g
		WHERE t040g.kb_uriage = '1A' AND t040g.dd_jucyuke IS NOT NULL
		AND t040g.dd_uritorik >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
		UNION ALL
		SELECT t017g.cd_hansya,t017g.cd_kaisya,t017g.no_cyumon,t017g.no_cyumoned,t017g.cd_jytyuten,t017g.cd_hanstaff,t017g.dd_jucyuke,t017g.dd_uritorik,t017g.no_syaryou,t017g.kb_uriage
		FROM ai21rep_ve_dx.tbbc017g t017g	
		WHERE t017g.kb_uriage = '1A' AND t017g.dd_jucyuke IS NOT NULL
		AND t017g.dd_uritorik >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
	) t
	-- M社員ＤＢ
	LEFT JOIN ai21rep_ve_dx.TBV0014M t014m
		ON t014m.cd_kaisya = t.cd_kaisya
		AND t014m.cd_hansya = t.cd_hansya
		AND t014m.cd_syain = t.cd_hanstaff
	--  中古車在庫基本情報ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbbc001g t001g
		ON t001g.cd_kaisya = t.cd_kaisya
		AND t001g.cd_hansya = t.cd_hansya
		AND t001g.no_syaryou = t.no_syaryou
	-- 共通店舗ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbv0201m t0201m
		ON t0201m.cd_kaisya = t.cd_kaisya
		AND t0201m.cd_hansya = t.cd_hansya
		AND t0201m.cd_tenpo = t.cd_jytyuten
    -- 店舗表示設定
	LEFT SEMI JOIN dx_ve.tbi999003m
			ON tbi999003m.cd_kaisya = t.cd_kaisya
			AND tbi999003m.cd_hansya = t.cd_hansya
			AND tbi999003m.cd_tenpo = t.cd_jytyuten
			AND tbi999003m.mj_cyohyoid = '019'
			AND tbi999003m.kb_tenji = 1
) t
GROUP BY
	--販社コード
	cd_hansya,
	--会社コード
	cd_kaisya,
	--店舗コード
	cd_tenpo,
	--店舗名称
	kj_tenpomei,
	--販売スタッフコード
	cd_hanstaff,
	--社員名
	kj_syainmei,
	--月
	month
LIMIT 0;

-- [084/099] level=1 target=gold.vbi019003
-- Gold dependencies: gold.vbi019001, gold.vbi019002
-- Source file: 019_中古車実績一覧(スタッフ別・店舗別)/中古車実績一覧（スタッフ別・店舗別）_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi019003 AS
SELECT 
	--販社コード
	t.cd_hansya AS '販社コード',
	--会社コード
	t.cd_kaisya AS '会社コード',
	--店舗コード
	t.cd_tenpo AS '店舗コード',
	--店舗名称
	t.kj_tenpomei AS '店舗名称',
	--販売スタッフコード
	t.cd_hanstaff AS '販売スタッフコード',
	--社員名
	t.kj_syainmei AS '社員名',
	--月
	t.month AS '月',
	--受注
	t.su_jucyu AS '受注',
	--受注キャンセル反映
	t.su_jucyucancelhane AS '受注キャンセル反映',
	--受注除軽
	t.su_jucyujyokei AS '受注除軽',
	--受注除軽キャンセル反映
	t.su_jucyucanceljyokeihane AS '受注除軽キャンセル反映',
	--販売
	t.su_hanbai AS '販売',
	--販売キャンセル反映
	t.su_hanbaicancelhane AS '販売キャンセル反映',
	--販売除軽
	t.su_hanbaijyokei AS '販売除軽',
	--販売除軽キャンセル反映
	t.su_hanbaicanceljyokeihene AS '販売除軽キャンセル反映',
	--割賦
	t.su_kap AS '割賦',
	--メンテナンスパック
	t.su_maintenancepack AS 'メンテナンスパック',
	--ソート順
	rank() over (partition by t.cd_hansya,t.cd_kaisya order by tbi999003m.mj_sortjyun , t.cd_tenpo) as 'ソート順'
FROM 
(
	SELECT 
		--販社コード
		cd_hansya,
		--会社コード
		cd_kaisya,
		--店舗コード
		cd_tenpo,
		--店舗名称
		kj_tenpomei,
		--販売スタッフコード
		cd_hanstaff,
		--社員名
		kj_syainmei,
		--月
		month,
		--受注
		SUM(su_jucyu) AS 'su_jucyu',
		--受注キャンセル反映
		SUM(su_jucyucancelhane) AS 'su_jucyucancelhane',
		--受注除軽
		SUM(su_jucyujyokei) AS 'su_jucyujyokei',
		--受注除軽キャンセル反映
		SUM(su_jucyucanceljyokeihane) AS 'su_jucyucanceljyokeihane',
		--販売
		SUM(su_hanbai) AS 'su_hanbai',
		--販売キャンセル反映
		SUM(su_hanbaicancelhane) AS 'su_hanbaicancelhane',
		--販売除軽
		SUM(su_hanbaijyokei) AS 'su_hanbaijyokei',
		--販売除軽キャンセル反映
		SUM(su_hanbaicanceljyokeihene) AS 'su_hanbaicanceljyokeihene',
		--割賦
		SUM(su_kap) AS 'su_kap',
		--メンテナンスパック
		SUM(su_maintenancepack) AS 'su_maintenancepack'
	FROM
	(
		SELECT 
			--販社コード
			cd_hansya,
			--会社コード
			cd_kaisya,
			--店舗コード
			cd_tenpo,
			--店舗名称
			kj_tenpomei,
			--販売スタッフコード
			cd_hanstaff,
			--社員名
			kj_syainmei,
			--月
			month,
			--受注
			su_jucyu,
			--受注キャンセル反映
			su_jucyucancelhane,
			--受注除軽
			su_jucyujyokei,
			--受注除軽キャンセル反映
			su_jucyucanceljyokeihane,
			--販売
			0 AS 'su_hanbai',
			--販売キャンセル反映
			0 AS 'su_hanbaicancelhane',
			--販売除軽
			0 AS 'su_hanbaijyokei',
			--販売除軽キャンセル反映
			0 AS 'su_hanbaicanceljyokeihene',
			--割賦
			su_kap,
			--メンテナンスパック
			su_maintenancepack
		FROM gold.vbi019001
		UNION ALL
		SELECT 
			--販社コード
			cd_hansya,
			--会社コード
			cd_kaisya,
			--店舗コード
			cd_tenpo,
			--店舗名称
			kj_tenpomei,
			--販売スタッフコード
			cd_hanstaff,
			--社員名
			kj_syainmei,
			--月
			month,
			--受注
			0 AS 'su_jucyu',
			--受注キャンセル反映
			0 AS 'su_jucyucancelhane',
			--受注除軽
			0 AS 'su_jucyujyokei',
			--受注除軽キャンセル反映
			0 AS 'su_jucyucanceljyokeihane',
			--販売
			su_hanbai,
			--販売キャンセル反映
			su_hanbaicancelhane,
			--販売除軽
			su_hanbaijyokei,
			--販売除軽キャンセル反映
			su_hanbaicanceljyokeihene,
			--割賦
			0 AS 'su_kap',
			--メンテナンスパック
			0 AS 'su_maintenancepack'
		FROM gold.vbi019002
	)combined
	GROUP BY
		--販社コード
		cd_hansya,
		--会社コード
		cd_kaisya,
		--店舗コード
		cd_tenpo,
		--店舗名称
		kj_tenpomei,
		--販売スタッフコード
		cd_hanstaff,
		--社員名
		kj_syainmei,
		--月
		month
)t
-- 店舗表示設定
INNER JOIN dx_ve.tbi999003m
	ON tbi999003m.cd_kaisya = t.cd_kaisya
	AND tbi999003m.cd_hansya = t.cd_hansya
	AND tbi999003m.cd_tenpo = t.cd_tenpo
	AND tbi999003m.mj_cyohyoid = '019'
	AND tbi999003m.kb_tenji = 1
LIMIT 0;

-- [085/099] level=0 target=gold.vbi021001
-- Gold dependencies: none
-- Source file: 021_Bz4x買換え報奨金照会/報奨金_view_ve_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi021001 AS
select t.cd_hansya , 
		t200m.kj_kaisyatn, 
		t200m.cd_hanbaitn,
		t.cd_kaisya, 
		t.CD_OKYAKU, 
		t.KB_SINCYU, 
		t.NO_SYADAI, 
		t.MJ_KATASIKI,
		t.MJ_SYAMEI,
		t006m.CD_STAFFTEN, 
		t201m.kj_tenpomei,
		t000m.KJ_OKYAKUM1
-- 車両管理ＤＢ
from ai21rep_ve_dx.TBTEC05G t
-- 顧客担当ＤＢ
left join ai21rep_ve_dx.TBAZ006M t006m
on t006m.cd_hansya = t.cd_hansya
and t006m.cd_kaisya = t.cd_kaisya
and t006m.CD_OKYAKU = t.CD_OKYAKU
-- 会社コードＤＢ
left join ai21rep_ve_dx.tbv0200m t200m
on t200m.cd_hansya = t.cd_hansya
and t200m.cd_kaisya = t.cd_kaisya
-- 共通店舗ＤＢ 
left join ai21rep_ve_dx.tbv0201m t201m
on t201m.cd_hansya = t.cd_hansya
and t201m.cd_kaisya = t.cd_kaisya
and t201m.cd_tenpo = t006m.CD_STAFFTEN
-- 顧客基本ＤＢ
left join ai21rep_ve_dx.TBAZ000M t000m					
on t000m.cd_hansya = t.cd_hansya					
and t000m.cd_kaisya = t.cd_kaisya					
and t000m.CD_OKYAKU = t.CD_OKYAKU	
where (lOWER(t.MJ_KATASIKI) like '%xeam10%' or lOWER(t.MJ_KATASIKI) like '%yeam15%')
and t006m.KB_TANTOBUN = '1'
and t.KB_SYAMASSY  <> '1'
LIMIT 0;

-- [086/099] level=0 target=gold.vbi021002
-- Gold dependencies: none
-- Source file: 021_Bz4x買換え報奨金照会/報奨金_view_ve_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi021002 AS
WITH
-- 受注下取ＤＢ+抹消済受注下取ＤＢ+保存用受注下取ＤＢ
a003g AS (
  SELECT *
  FROM (
    SELECT
      cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,NO_SYADAIBA,DD_SITATORI,KB_SINCYU,
      RANK() OVER (PARTITION BY cd_hansya, cd_kaisya, no_cyumon, no_cyumoned, NO_SYADAIBA ORDER BY sortn ASC) AS rnk
    FROM (
      SELECT
        cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,NO_SYADAIBA,DD_SITATORI,KB_SINCYU,1 AS sortn
      -- 受注下取ＤＢ（優先度=1）
      FROM ai21rep_ve_dx.TBBA003G TBBA003G
      UNION ALL
      SELECT
        cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,NO_SYADAIBA,DD_SITATORI,KB_SINCYU,2 AS sortn
      -- 抹消済受注下取ＤＢ（優先度=2）
      FROM ai21rep_ve_dx.TBBA095G TBBA095G
      UNION ALL
      SELECT
        cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,NO_SYADAIBA,DD_SITATORI,KB_SINCYU,3 AS sortn
      -- 保存用受注下取ＤＢ（優先度=3）
      FROM ai21rep_ve_dx.TBBA117G TBBA117G
    ) jucyushitatr1
  ) jucyushitatr2
  WHERE rnk = 1
),
-- 新車受注基本情報ＤＢ+抹消済+保存用
a001g AS (
  SELECT *
  FROM (
    SELECT
      NO_SYADAIBA,KJ_MEIGIME1,DD_JUCYU,DD_TOUROKU,MJ_HANTENKT,DD_TORIKESI,cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,MJ_SINKYSED,MJ_GAIHANSY,
      RANK() OVER (PARTITION BY cd_hansya, cd_kaisya, no_cyumon, no_cyumoned ORDER BY sortn ASC) AS rnk
    FROM (
      SELECT
        NO_SYADAIBA,KJ_MEIGIME1,DD_JUCYU,DD_TOUROKU,MJ_HANTENKT,DD_TORIKESI,cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,MJ_SINKYSED,MJ_GAIHANSY,1 AS sortn
      -- 新車受注基本情報ＤＢ（優先度=1）
      FROM ai21rep_ve_dx.TBBA001G TBBA001G where (DD_TOUROKU >= '2025-8-27' and DD_TOUROKU < '2028-4-1' or DD_TOUROKU is null)
      UNION ALL
      SELECT
        NO_SYADAIBA,KJ_MEIGIME1,DD_JUCYU,DD_TOUROKU,MJ_HANTENKT,DD_TORIKESI,cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,MJ_SINKYSED,MJ_GAIHANSY,2 AS sortn
      -- 抹消済新車受注基本情報ＤＢ（優先度=2）
      FROM ai21rep_ve_dx.TBBA085G TBBA085G where (DD_TOUROKU >= '2025-8-27' and DD_TOUROKU < '2028-4-1' or DD_TOUROKU is null)
      UNION ALL
      SELECT
        NO_SYADAIBA,KJ_MEIGIME1,DD_JUCYU,DD_TOUROKU,MJ_HANTENKT,DD_TORIKESI,cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,MJ_SINKYSED,MJ_GAIHANSY,3 AS sortn
      -- 保存用新車受注基本情報ＤＢ（優先度=3）
      FROM ai21rep_ve_dx.TBBA108G TBBA108G where (DD_TOUROKU >= '2025-8-27' and DD_TOUROKU < '2028-4-1' or DD_TOUROKU is null)
    ) shinsha1
  ) shinsha2
  WHERE rnk = 1
),
-- 中古車在庫基本情報ＤＢ+抹消済+保存用
c001g AS (
  SELECT *
  FROM (
    SELECT
      DD_KEIRIKEI,NO_SYADAIBA,MJ_KATASIKI,KJ_SITAMEIG,MJ_FURUSYAM,KB_SIIRE,DD_SIREJYTY,DD_SIRETORO,CD_SYOYUSYA,KJ_SAISSYYU,cd_hansya,cd_kaisya,DD_TORIKESI,cd_sitadote,NO_SIRETYUM,no_syaryou,
      RANK() OVER (PARTITION BY cd_hansya, cd_kaisya, NO_SYADAIBA ORDER BY sortn ASC) AS rnk
    FROM (
      SELECT
        DD_KEIRIKEI,NO_SYADAIBA,MJ_KATASIKI,KJ_SITAMEIG,MJ_FURUSYAM,KB_SIIRE,DD_SIREJYTY,DD_SIRETORO,CD_SYOYUSYA,KJ_SAISSYYU,cd_hansya,cd_kaisya,DD_TORIKESI,cd_sitadote,NO_SIRETYUM,no_syaryou,1 AS sortn
      -- 中古車在庫基本情報ＤＢ（優先度=1）
      FROM ai21rep_ve_dx.TBBC001G TBBC001G
      WHERE (LOWER(MJ_KATASIKI) LIKE '%xeam10%' OR LOWER(MJ_KATASIKI) LIKE '%yeam15%')
		AND KB_SIIRE LIKE '1%'
      UNION ALL
      SELECT
        DD_KEIRIKEI,NO_SYADAIBA,MJ_KATASIKI,KJ_SITAMEIG,MJ_FURUSYAM,KB_SIIRE,DD_SIREJYTY,DD_SIRETORO,CD_SYOYUSYA,KJ_SAISSYYU,cd_hansya,cd_kaisya,DD_TORIKESI,cd_sitadote,NO_SIRETYUM,no_syaryou,2 AS sortn
      -- 抹消済中古車在庫基本情報ＤＢ（優先度=2）
      FROM ai21rep_ve_dx.TBBC050G TBBC050G
      WHERE  (LOWER(MJ_KATASIKI) LIKE '%xeam10%' OR LOWER(MJ_KATASIKI) LIKE '%yeam15%')
		AND KB_SIIRE LIKE '1%'
      UNION ALL
      SELECT
        DD_KEIRIKEI,NO_SYADAIBA,MJ_KATASIKI,KJ_SITAMEIG,MJ_FURUSYAM,KB_SIIRE,DD_SIREJYTY,DD_SIRETORO,CD_SYOYUSYA,KJ_SAISSYYU,cd_hansya,cd_kaisya,DD_TORIKESI,cd_sitadote,NO_SIRETYUM,no_syaryou,3 AS sortn
      -- 保存用中古車在庫基本情報ＤＢ（優先度=3）
      FROM ai21rep_ve_dx.TBBC065G TBBC065G
      WHERE (LOWER(MJ_KATASIKI) LIKE '%xeam10%' OR LOWER(MJ_KATASIKI) LIKE '%yeam15%')
		AND KB_SIIRE LIKE '1%'
    ) cyukokh1
  ) cyukokh2
  WHERE rnk = 1
),
-- 中古車在庫登録情報ＤＢ+抹消済+保存用
c006g AS (
  SELECT *
  FROM (
    SELECT
      DD_1JTOROKU,cd_hansya,cd_kaisya,NO_SYARYOU,
      RANK() OVER (PARTITION BY cd_hansya, cd_kaisya, NO_SYARYOU ORDER BY sortn ASC) AS rnk
    FROM (
      SELECT
        DD_1JTOROKU,cd_hansya,cd_kaisya,NO_SYARYOU,1 AS sortn
      -- 中古車在庫登録情報ＤＢ（優先度=1）
      FROM ai21rep_ve_dx.TBBC006G TBBC006G
      UNION ALL
      SELECT
        DD_1JTOROKU,cd_hansya,cd_kaisya,NO_SYARYOU,2 AS sortn
      -- 抹消済中古車在庫登録情報ＤＢ（優先度=2）
      FROM ai21rep_ve_dx.TBBC052G TBBC052G
      UNION ALL
      SELECT
        max(DD_1JTOROKU) as DD_1JTOROKU,cd_hansya,cd_kaisya,NO_SYARYOU,3 AS sortn
      -- 保存用中古車在庫登録情報ＤＢ（優先度=3）
      FROM ai21rep_ve_dx.TBBC064G TBBC064G
      group by cd_hansya,cd_kaisya,NO_SYARYOU
    ) cyukotr1
  ) cyukotr2
  WHERE rnk = 1
)
-- ① 予定
SELECT
  t.cd_hansya,
  t200m.kj_kaisyatn,
  t200m.cd_hanbaitn,
  t.cd_kaisya,
  t201m.kj_tenpomei,
  t.NO_SYADAIBA,
  -- 予定
  t.NO_SYADAIBA AS NO_SYADAIBA_yotei,
  t.MJ_KATASIKI,
  t.KJ_SITAMEIG,
  t.MJ_FURUSYAM,
  t.KB_SIREHANB,
  -- 中古車在庫基本情報
  c001g.DD_KEIRIKEI AS DD_KEIRIKEI_zako,
  c001g.NO_SYADAIBA AS NO_SYADAIBA_zako,
  c001g.MJ_KATASIKI AS MJ_KATASIKI_zako,
  c001g.KJ_SITAMEIG AS KJ_SITAMEIG_zako,
  c001g.MJ_FURUSYAM AS MJ_FURUSYAM_zako,
  c001g.KB_SIIRE AS KB_SIIRE_zako,
  c001g.DD_SIREJYTY AS DD_SIREJYTY_zako,
  c001g.DD_SIRETORO AS DD_SIRETORO_zako,
  c001g.CD_SYOYUSYA AS CD_SYOYUSYA_zako,
  c001g.KJ_SAISSYYU AS KJ_SAISSYYU_zako,
  -- 新車受注基本情報
  a001g.NO_SYADAIBA AS NO_SYADAIBA_shinsya,
  a001g.KJ_MEIGIME1 AS kj_meigime1_shinsya,
  a001g.DD_JUCYU AS dd_jucyu_shinsya,
  a001g.DD_TOUROKU AS dd_touroku_shinsya,
  a001g.MJ_HANTENKT AS mj_katasiki_shinsya,
  a001g.NO_CYUMON AS no_cyumon_shinsya,
  f001m.KJ_KURUMAME AS kj_kurumame_shinsya,
  -- 中古車在庫登録情報ＤＢ
  c006g.DD_1JTOROKU
-- 仕入予定基本情報ＤＢ
FROM ai21rep_ve_dx.TBBC003G t
LEFT JOIN ai21rep_ve_dx.tbv0200m t200m
ON t200m.cd_hansya = t.cd_hansya
AND t200m.cd_kaisya = t.cd_kaisya
LEFT JOIN ai21rep_ve_dx.tbv0201m t201m
ON t201m.cd_hansya = t.cd_hansya
AND t201m.cd_kaisya = t.cd_kaisya
AND t201m.cd_tenpo  = t.CD_SITADOTE
-- 受注下取ＤＢ+抹消済+保存用
INNER JOIN a003g
ON a003g.cd_hansya = t.cd_hansya
AND a003g.cd_kaisya = t.cd_kaisya
AND CONCAT(COALESCE(a003g.NO_CYUMON,''), COALESCE(a003g.NO_CYUMONED,'')) = t.NO_SIRETYUM
AND TRIM(a003g.NO_SYADAIBA) = TRIM(t.NO_SYADAIBA)
AND a003g.DD_SITATORI IS NULL
AND a003g.KB_SINCYU = '1'
-- 新車受注基本情報ＤＢ+抹消済+保存用
INNER JOIN a001g
ON a001g.cd_hansya = t.cd_hansya
AND a001g.cd_kaisya = t.cd_kaisya
AND CONCAT(COALESCE(a001g.NO_CYUMON,''), COALESCE(a001g.NO_CYUMONED,'')) = t.NO_SIRETYUM
AND a001g.DD_TORIKESI IS NULL
-- 車両スペック２ＤＢ
INNER JOIN ai21rep_ve_dx.TBBF008M f008m
ON f008m.cd_hansya   = a001g.cd_hansya
AND f008m.cd_kaisya   = a001g.cd_kaisya
AND f008m.MJ_SINKYSED = a001g.MJ_SINKYSED
AND f008m.CD_SPEC     = a001g.MJ_GAIHANSY
AND f008m.MJ_HANTENKT = a001g.MJ_HANTENKT
AND f008m.kb_spec     = 'G'
-- 車名ＤＢ
INNER JOIN ai21rep_ve_dx.tbbf001m f001m
ON f001m.cd_hansya    = f008m.cd_hansya
AND f001m.cd_kaisya    = f008m.cd_kaisya
AND f001m.cd_ncsyamei  = f008m.mj_syamei
-- 中古車在庫基本情報ＤＢ+抹消済+保存用
left JOIN c001g
ON c001g.cd_hansya = t.cd_hansya
AND c001g.cd_kaisya = t.cd_kaisya
AND TRIM(c001g.NO_SYADAIBA) = TRIM(t.NO_SYADAIBA)
AND c001g.DD_TORIKESI IS NULL
LEFT JOIN c006g
ON c006g.cd_hansya = t.cd_hansya
AND c006g.cd_kaisya = t.cd_kaisya
AND c006g.NO_SYARYOU = t.NO_SYARYOU
WHERE (LOWER(t.MJ_KATASIKI) LIKE '%xeam10%' OR LOWER(t.MJ_KATASIKI) LIKE '%yeam15%')
AND t.KB_SIREHANB = '1'
AND (((f001m.KJ_KURUMAME LIKE '%bZ4X%' OR f001m.KJ_KURUMAME LIKE '%ｂＺ４Ｘ%')
    AND (a001g.MJ_HANTENKT LIKE '%XEAM11%' OR a001g.MJ_HANTENKT LIKE '%XEAM15%'))
    OR f001m.KJ_KURUMAME LIKE '%bZ4Xツーリング%'
    OR f001m.KJ_KURUMAME LIKE '%ｂＺ４Ｘツーリング%'
    OR f001m.KJ_KURUMAME LIKE '%プリウス%'
    OR f001m.KJ_KURUMAME LIKE '%RAV4%'
    OR f001m.KJ_KURUMAME LIKE '%ＲＡＶ４%'
    OR f001m.KJ_KURUMAME LIKE '%ハリアー%'
    OR f001m.KJ_KURUMAME LIKE '%アルファード%'
    OR f001m.KJ_KURUMAME LIKE '%ヴェルファイア%'
    OR f001m.KJ_KURUMAME LIKE '%クラウンスポーツ%'
    OR f001m.KJ_KURUMAME LIKE '%クラウンエステート%'
  )
UNION
-- ② 在庫
SELECT
  t.cd_hansya,
  t200m.kj_kaisyatn,
  t200m.cd_hanbaitn,
  t.cd_kaisya,
  t201m.kj_tenpomei,
  t.NO_SYADAIBA,
  -- 予定
  t.NO_SYADAIBA AS NO_SYADAIBA_yotei,
  t.MJ_KATASIKI AS MJ_KATASIKI,
  t.KJ_SITAMEIG AS KJ_SITAMEIG,
  t.MJ_FURUSYAM AS MJ_FURUSYAM,
  t.KB_SIIRE AS KB_SIREHANB,
  -- 中古車在庫基本情報
  t.DD_KEIRIKEI AS DD_KEIRIKEI_zako,
  t.NO_SYADAIBA AS NO_SYADAIBA_zako,
  t.MJ_KATASIKI AS MJ_KATASIKI_zako,
  t.KJ_SITAMEIG AS KJ_SITAMEIG_zako,
  t.MJ_FURUSYAM AS MJ_FURUSYAM_zako,
  t.KB_SIIRE AS KB_SIIRE_zako,
  t.DD_SIREJYTY AS DD_SIREJYTY_zako,
  t.DD_SIRETORO AS DD_SIRETORO_zako,
  t.CD_SYOYUSYA AS CD_SYOYUSYA_zako,
  t.KJ_SAISSYYU AS KJ_SAISSYYU_zako,
  -- 新車受注基本情報
  a001g.NO_SYADAIBA AS NO_SYADAIBA_shinsya,
  a001g.KJ_MEIGIME1 AS kj_meigime1_shinsya,
  a001g.DD_JUCYU AS dd_jucyu_shinsya,
  a001g.DD_TOUROKU AS dd_touroku_shinsya,
  a001g.MJ_HANTENKT AS mj_katasiki_shinsya,
  a001g.NO_CYUMON AS no_cyumon_shinsya,
  f001m.KJ_KURUMAME AS kj_kurumame_shinsya,
  -- 中古車在庫登録情報ＤＢ
  c006g.DD_1JTOROKU
-- 中古車在庫登録情報ＤＢ+抹消済+保存用
FROM c001g t
LEFT JOIN ai21rep_ve_dx.tbv0200m t200m
ON t200m.cd_hansya = t.cd_hansya
AND t200m.cd_kaisya = t.cd_kaisya
LEFT JOIN ai21rep_ve_dx.tbv0201m t201m
ON t201m.cd_hansya = t.cd_hansya
AND t201m.cd_kaisya = t.cd_kaisya
AND t201m.cd_tenpo  = t.CD_SITADOTE
-- 新車受注基本情報ＤＢ+抹消済+保存用
LEFT JOIN a001g
ON a001g.cd_hansya = t.cd_hansya
AND a001g.cd_kaisya = t.cd_kaisya
AND CONCAT(COALESCE(a001g.NO_CYUMON,''), COALESCE(a001g.NO_CYUMONED,'')) = t.NO_SIRETYUM
AND a001g.DD_TORIKESI IS NULL
-- 車両スペック２ＤＢ
INNER JOIN ai21rep_ve_dx.TBBF008M f008m
ON f008m.cd_hansya   = a001g.cd_hansya
AND f008m.cd_kaisya   = a001g.cd_kaisya
AND f008m.MJ_SINKYSED = a001g.MJ_SINKYSED
AND f008m.CD_SPEC     = a001g.MJ_GAIHANSY
AND f008m.MJ_HANTENKT = a001g.MJ_HANTENKT
AND f008m.kb_spec     = 'G'
-- 車名ＤＢ
INNER JOIN ai21rep_ve_dx.tbbf001m f001m
ON f001m.cd_hansya    = f008m.cd_hansya
AND f001m.cd_kaisya    = f008m.cd_kaisya
AND f001m.cd_ncsyamei  = f008m.mj_syamei
LEFT JOIN c006g
ON c006g.cd_hansya = t.cd_hansya
AND c006g.cd_kaisya = t.cd_kaisya
AND c006g.NO_SYARYOU = t.NO_SYARYOU
WHERE (LOWER(t.MJ_KATASIKI) LIKE '%xeam10%' OR LOWER(t.MJ_KATASIKI) LIKE '%yeam15%')
AND t.KB_SIIRE LIKE '1%'
AND (((f001m.KJ_KURUMAME LIKE '%bZ4X%' OR f001m.KJ_KURUMAME LIKE '%ｂＺ４Ｘ%')
    AND (a001g.MJ_HANTENKT LIKE '%XEAM11%' OR a001g.MJ_HANTENKT LIKE '%XEAM15%'))
    OR f001m.KJ_KURUMAME LIKE '%bZ4Xツーリング%'
    OR f001m.KJ_KURUMAME LIKE '%ｂＺ４Ｘツーリング%'
    OR f001m.KJ_KURUMAME LIKE '%プリウス%'
    OR f001m.KJ_KURUMAME LIKE '%RAV4%'
    OR f001m.KJ_KURUMAME LIKE '%ＲＡＶ４%'
    OR f001m.KJ_KURUMAME LIKE '%ハリアー%'
    OR f001m.KJ_KURUMAME LIKE '%アルファード%'
    OR f001m.KJ_KURUMAME LIKE '%ヴェルファイア%'
    OR f001m.KJ_KURUMAME LIKE '%クラウンスポーツ%'
    OR f001m.KJ_KURUMAME LIKE '%クラウンエステート%'
  )
LIMIT 0;

-- [087/099] level=0 target=gold.vbi021004
-- Gold dependencies: none
-- Source file: 021_Bz4x買換え報奨金照会/報奨金_view_ve_iceberg_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi021004 AS
WITH
-- 受注下取ＤＢ+抹消済受注下取ＤＢ+保存用受注下取ＤＢ
a003g AS (
  SELECT *
  FROM (
    SELECT
      cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,NO_SYADAIBA,DD_SITATORI,KB_SINCYU,
      RANK() OVER (PARTITION BY cd_hansya, cd_kaisya, no_cyumon, no_cyumoned, NO_SYADAIBA ORDER BY sortn ASC) AS rnk
    FROM (
      SELECT
        cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,NO_SYADAIBA,DD_SITATORI,KB_SINCYU,1 AS sortn
      -- 受注下取ＤＢ（優先度=1）
      FROM ai21rep_ve_dx.TBBA003G TBBA003G where cd_hansya is null
      UNION ALL
      SELECT
        cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,NO_SYADAIBA,DD_SITATORI,KB_SINCYU,2 AS sortn
      -- 抹消済受注下取ＤＢ（優先度=2）
      FROM ai21rep_ve_dx.TBBA095G TBBA095G where cd_hansya is null
      UNION ALL
      SELECT
        cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,NO_SYADAIBA,DD_SITATORI,KB_SINCYU,3 AS sortn
      -- 保存用受注下取ＤＢ（優先度=3）
      FROM ai21rep_ve_dx.TBBA117G TBBA117G where cd_hansya is null
    ) jucyushitatr1
  ) jucyushitatr2
  WHERE rnk = 1
),
-- 新車受注顧客情報ＤＢ+抹消済+保存用
a051g AS (
  SELECT *
  FROM (
    SELECT
      cd_hansya,cd_kaisya,CD_KOKYAKU,KB_KOKYAKU,NO_CYUMON,NO_CYUMONED,
      RANK() OVER (PARTITION BY cd_hansya, cd_kaisya, no_cyumon, no_cyumoned,KB_KOKYAKU ORDER BY sortn ASC) AS rnk
    FROM (
      SELECT
        cd_hansya,cd_kaisya,CD_KOKYAKU,KB_KOKYAKU,NO_CYUMON,NO_CYUMONED,1 AS sortn
      -- 新車受注顧客情報ＤＢ（優先度=1）
      FROM ai21rep_ve_dx.TBBA051G TBBA051G
      UNION ALL
      SELECT
        cd_hansya,cd_kaisya,CD_KOKYAKU,KB_KOKYAKU,NO_CYUMON,NO_CYUMONED,2 AS sortn
      -- 抹消済新車顧客情報ＤＢ（優先度=2）
      FROM ai21rep_ve_dx.TBBA087G TBBA087G
      UNION ALL
      SELECT
        cd_hansya,cd_kaisya,CD_KOKYAKU,KB_KOKYAKU,NO_CYUMON,NO_CYUMONED,3 AS sortn
      -- 保存用受注下取ＤＢ（優先度=3）
      FROM ai21rep_ve_dx.TBBA130G TBBA130G
    ) jucyushitatr1
  ) jucyushitatr2
  WHERE rnk = 1
),
-- 新車受注基本情報ＤＢ+抹消済+保存用
a001g AS (
  SELECT *
  FROM (
    SELECT
      NO_SYADAIBA,KJ_MEIGIME1,DD_JUCYU,DD_TOUROKU,MJ_HANTENKT,DD_TORIKESI,cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,MJ_SINKYSED,MJ_GAIHANSY,
      RANK() OVER (PARTITION BY cd_hansya, cd_kaisya, no_cyumon, no_cyumoned ORDER BY sortn ASC) AS rnk
    FROM (
      SELECT
        NO_SYADAIBA,KJ_MEIGIME1,DD_JUCYU,DD_TOUROKU,MJ_HANTENKT,DD_TORIKESI,cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,MJ_SINKYSED,MJ_GAIHANSY,1 AS sortn
      -- 新車受注基本情報ＤＢ（優先度=1）
      FROM ai21rep_ve_dx.TBBA001G TBBA001G where (DD_TOUROKU >= '2025-8-27' and DD_TOUROKU < '2028-4-1' or DD_TOUROKU is null)
      UNION ALL
      SELECT
        NO_SYADAIBA,KJ_MEIGIME1,DD_JUCYU,DD_TOUROKU,MJ_HANTENKT,DD_TORIKESI,cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,MJ_SINKYSED,MJ_GAIHANSY,2 AS sortn
      -- 抹消済新車受注基本情報ＤＢ（優先度=2）
      FROM ai21rep_ve_dx.TBBA085G TBBA085G where (DD_TOUROKU >= '2025-8-27' and DD_TOUROKU < '2028-4-1' or DD_TOUROKU is null)
      UNION ALL
      SELECT
        NO_SYADAIBA,KJ_MEIGIME1,DD_JUCYU,DD_TOUROKU,MJ_HANTENKT,DD_TORIKESI,cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,MJ_SINKYSED,MJ_GAIHANSY,3 AS sortn
      -- 保存用新車受注基本情報ＤＢ（優先度=3）
      FROM ai21rep_ve_dx.TBBA108G TBBA108G where (DD_TOUROKU >= '2025-8-27' and DD_TOUROKU < '2028-4-1' or DD_TOUROKU is null)
    ) shinsha1
  ) shinsha2
  WHERE rnk = 1
),
-- 中古車在庫基本情報ＤＢ+抹消済+保存用
c001g AS (
  SELECT *
  FROM (
    SELECT
      MJ_SIRENORI,KB_SIRETOSY,CD_SIRETOGY,NO_SIRETOSE,DD_SIIRE,DT_SAISINUP,DD_KEIRIKEI,NO_SYADAIBA,MJ_KATASIKI,KJ_SITAMEIG,MJ_FURUSYAM,KB_SIIRE,DD_SIREJYTY,DD_SIRETORO,CD_SYOYUSYA,KJ_SAISSYYU,cd_hansya,cd_kaisya,DD_TORIKESI,cd_sitadote,NO_SIRETYUM,no_syaryou,
      RANK() OVER (PARTITION BY cd_hansya, cd_kaisya, NO_SYADAIBA ORDER BY sortn ASC) AS rnk
    FROM (
      SELECT
        MJ_SIRENORI,KB_SIRETOSY,CD_SIRETOGY,NO_SIRETOSE,DD_SIIRE,DT_SAISINUP,DD_KEIRIKEI,NO_SYADAIBA,MJ_KATASIKI,KJ_SITAMEIG,MJ_FURUSYAM,KB_SIIRE,DD_SIREJYTY,DD_SIRETORO,CD_SYOYUSYA,KJ_SAISSYYU,cd_hansya,cd_kaisya,DD_TORIKESI,cd_sitadote,NO_SIRETYUM,no_syaryou,1 AS sortn
      -- 中古車在庫基本情報ＤＢ（優先度=1）
      FROM ai21rep_ve_dx.TBBC001G TBBC001G
      where (lOWER(MJ_KATASIKI) like '%xeam10%' or lOWER(MJ_KATASIKI) like '%yeam15%')
		AND DD_TORIKESI IS NULL
		and KB_SIIRE like '3%'
      UNION ALL
      SELECT
        MJ_SIRENORI,KB_SIRETOSY,CD_SIRETOGY,NO_SIRETOSE,DD_SIIRE,DT_SAISINUP,DD_KEIRIKEI,NO_SYADAIBA,MJ_KATASIKI,KJ_SITAMEIG,MJ_FURUSYAM,KB_SIIRE,DD_SIREJYTY,DD_SIRETORO,CD_SYOYUSYA,KJ_SAISSYYU,cd_hansya,cd_kaisya,DD_TORIKESI,cd_sitadote,NO_SIRETYUM,no_syaryou,2 AS sortn
      -- 抹消済中古車在庫基本情報ＤＢ（優先度=2）
      FROM ai21rep_ve_dx.TBBC050G TBBC050G
      where (lOWER(MJ_KATASIKI) like '%xeam10%' or lOWER(MJ_KATASIKI) like '%yeam15%')
		AND DD_TORIKESI IS NULL
		and KB_SIIRE like '3%'
      UNION ALL
      SELECT
        MJ_SIRENORI,KB_SIRETOSY,CD_SIRETOGY,NO_SIRETOSE,DD_SIIRE,DT_SAISINUP,DD_KEIRIKEI,NO_SYADAIBA,MJ_KATASIKI,KJ_SITAMEIG,MJ_FURUSYAM,KB_SIIRE,DD_SIREJYTY,DD_SIRETORO,CD_SYOYUSYA,KJ_SAISSYYU,cd_hansya,cd_kaisya,DD_TORIKESI,cd_sitadote,NO_SIRETYUM,no_syaryou,3 AS sortn
      -- 保存用中古車在庫基本情報ＤＢ（優先度=3）
      FROM ai21rep_ve_dx.TBBC065G TBBC065G
      where (lOWER(MJ_KATASIKI) like '%xeam10%' or lOWER(MJ_KATASIKI) like '%yeam15%')
		AND DD_TORIKESI IS NULL
		and KB_SIIRE like '3%'
    ) cyukokh1
  ) cyukokh2
  WHERE rnk = 1
),
-- 中古車在庫登録情報ＤＢ+抹消済+保存用
c006g AS (
  SELECT *
  FROM (
    SELECT
      DD_1JTOROKU,cd_hansya,cd_kaisya,NO_SYARYOU,
      RANK() OVER (PARTITION BY cd_hansya, cd_kaisya, NO_SYARYOU ORDER BY sortn ASC) AS rnk
    FROM (
      SELECT
        DD_1JTOROKU,cd_hansya,cd_kaisya,NO_SYARYOU,1 AS sortn
      -- 中古車在庫登録情報ＤＢ（優先度=1）
      FROM ai21rep_ve_dx.TBBC006G TBBC006G
      UNION ALL
      SELECT
        DD_1JTOROKU,cd_hansya,cd_kaisya,NO_SYARYOU,2 AS sortn
      -- 抹消済中古車在庫登録情報ＤＢ（優先度=2）
      FROM ai21rep_ve_dx.TBBC052G TBBC052G
      UNION ALL
      SELECT
        max(DD_1JTOROKU) as DD_1JTOROKU,cd_hansya,cd_kaisya,NO_SYARYOU,3 AS sortn
      -- 保存用中古車在庫登録情報ＤＢ（優先度=3）
      FROM ai21rep_ve_dx.TBBC064G TBBC064G
      group by cd_hansya,cd_kaisya,NO_SYARYOU
    ) cyukotr1
  ) cyukotr2
  WHERE rnk = 1
)
select 
t.cd_hansya,
t200m.kj_kaisyatn ,
t200m.cd_hanbaitn,
t.cd_kaisya , 
t201m.kj_tenpomei,
t.NO_SYADAIBA,
t.MJ_KATASIKI,
t.KJ_SITAMEIG,
t.MJ_FURUSYAM,
t.KB_SIIRE,
t.DD_KEIRIKEI,
t.DD_SIRETORO,
t.DD_SIREJYTY,
t.CD_SYOYUSYA,
t.KJ_SAISSYYU,
NULLIF(
  LEAST(
    -- 仕入日
    COALESCE(t.DD_SIIRE, DATE '9999-12-31'),
    -- 経理計上日
    COALESCE(t.DD_KEIRIKEI, DATE '9999-12-31'),
    -- 仕入受注日
    COALESCE(t.DD_SIREJYTY, DATE '9999-12-31'),
    -- 仕入登録日
    COALESCE(t.DD_SIRETORO, DATE '9999-12-31'),
    -- 最新更新日時
    COALESCE(t.DT_SAISINUP, DATE '9999-12-31')
  ),
  DATE '9999-12-31'
) AS min_non_null_date_zaiko,
-- 新車受注基本情報ＤＢ
a001g.NO_SYADAIBA as NO_SYADAIBA_shinsya,
a001g.KJ_MEIGIME1 as kj_meigime1_shinsya,
a001g.DD_JUCYU as dd_jucyu_shinsya,
a001g.DD_TOUROKU as dd_touroku_shinsya,
a001g.MJ_HANTENKT as mj_katasiki_shinsya,
a001g.NO_CYUMON as no_cyumon_shinsya,
f001m.KJ_KURUMAME as kj_kurumame_shinsya,
-- 仕入予定基本情報ＤＢ
c003g.KB_SIREHANB,
-- 中古車在庫登録情報ＤＢ
c006g.DD_1JTOROKU
-- 中古車在庫基本情報ＤＢ+抹消済+保存用
from c001g t
-- 車両管理ＤＢ 
inner join ai21rep_ve_dx.TBTEC05G c05g
on c05g.cd_hansya = t.cd_hansya
and c05g.cd_kaisya = t.cd_kaisya
and RTRIM(c05g.NO_SYADAI) = rtrim(t.NO_SYADAIBA)
and c05g.CD_NORIKUSI = t.MJ_SIRENORI
and c05g.KB_NOSYASYU = t.KB_SIRETOSY
and c05g.CD_NOGYOTAI = t.CD_SIRETOGY
and c05g.NO_NOSEIRI = t.NO_SIRETOSE
left join ai21rep_ve_dx.tbv0200m t200m
on t200m.cd_hansya = t.cd_hansya
and t200m.cd_kaisya = t.cd_kaisya
left join ai21rep_ve_dx.tbv0201m t201m
on t201m.cd_hansya = t.cd_hansya
and t201m.cd_kaisya = t.cd_kaisya
and t201m.cd_tenpo = t.CD_SITADOTE
-- 新車受注顧客情報ＤＢ+抹消済+保存用
inner join a051g
on a051g.cd_hansya = t.cd_hansya
and a051g.cd_kaisya = t.cd_kaisya
and a051g.CD_KOKYAKU = c05g.CD_OKYAKU
and a051g.KB_KOKYAKU = '2'
-- 新車受注基本情報ＤＢ+抹消済+保存用
inner join a001g
on a001g.cd_hansya = t.cd_hansya
and a001g.cd_kaisya = t.cd_kaisya
-- and RTRIM(a001g.KJ_MEIGIME1) =RTRIM(t.KJ_SITAMEIG)
and a001g.NO_CYUMON = a051g.NO_CYUMON
and a001g.NO_CYUMONED = a051g.NO_CYUMONED
and a001g.DD_TORIKESI IS NULL
-- 車両スペック２ＤＢ
inner join ai21rep_ve_dx.TBBF008M f008m
on f008m.cd_hansya = a001g.cd_hansya
and f008m.cd_kaisya = a001g.cd_kaisya
and f008m.MJ_SINKYSED = a001g.MJ_SINKYSED
and f008m.CD_SPEC = a001g.MJ_GAIHANSY
and f008m.MJ_HANTENKT = a001g.MJ_HANTENKT
AND f008m.kb_spec = 'G'
-- 車名ＤＢ
inner join ai21rep_ve_dx.Tbbf001m f001m
on f001m.cd_hansya = f008m.cd_hansya
and f001m.cd_kaisya = f008m.cd_kaisya
and f001m.cd_ncsyamei = f008m.mj_syamei
-- 仕入予定基本情報ＤＢ
left join ai21rep_ve_dx.TBBC003G c003g
on c003g.cd_hansya = a001g.cd_hansya
and c003g.cd_kaisya = a001g.cd_kaisya
and c003g.NO_SIRETYUM = CONCAT(a001g.NO_CYUMON, a001g.NO_CYUMONED)
-- 受注下取ＤＢ+抹消済+保存用
left join a003g
on a003g.cd_hansya = t.cd_hansya
and a003g.cd_kaisya = t.cd_kaisya
and a003g.NO_CYUMON = a001g.NO_CYUMON
and a003g.NO_CYUMONED = a001g.NO_CYUMONED
AND RTRIM(a003g.NO_SYADAIBA) = RTRIM(a001g.NO_SYADAIBA)
AND a003g.DD_SITATORI IS NULL
AND a003g.KB_SINCYU ='1'
-- 中古車在庫登録情報ＤＢ+抹消済+保存用
LEFT JOIN c006g
ON c006g.cd_hansya = t.cd_hansya
AND c006g.cd_kaisya = t.cd_kaisya
and c006g.NO_SYARYOU = t.NO_SYARYOU
where (lOWER(t.MJ_KATASIKI) like '%xeam10%' or lOWER(t.MJ_KATASIKI) like '%yeam15%')
AND t.DD_TORIKESI IS NULL
and t.KB_SIIRE like '3%'
and a003g.cd_hansya is null
and (c003g.KB_SIREHANB not in ('1', '2', '4') or c003g.KB_SIREHANB is null)
and ( ((f001m.KJ_KURUMAME like '%bZ4X%' or  f001m.KJ_KURUMAME LIKE '%ｂＺ４Ｘ%') and (a001g.MJ_HANTENKT like '%XEAM11%' or a001g.MJ_HANTENKT like '%XEAM15%'))
 or f001m.KJ_KURUMAME like '%bZ4Xツーリング%'
 OR f001m.KJ_KURUMAME LIKE '%ｂＺ４Ｘツーリング%'
 or f001m.KJ_KURUMAME like '%プリウス%'
 or f001m.KJ_KURUMAME like '%RAV4%'
 OR f001m.KJ_KURUMAME LIKE '%ＲＡＶ４%'
 or f001m.KJ_KURUMAME like '%ハリアー%'
 or f001m.KJ_KURUMAME like '%アルファード%'
 or f001m.KJ_KURUMAME like '%ヴェルファイア%'
 or f001m.KJ_KURUMAME like '%クラウンスポーツ%'
 or f001m.KJ_KURUMAME like '%クラウンエステート%'
)
LIMIT 0;

-- [088/099] level=0 target=gold.vbi022001
-- Gold dependencies: none
-- Source file: 022_中古車車両日報/中古車車両日報_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi022001 AS
SELECT
	--販社コード
	cd_hansya,
	--会社コード
	cd_kaisya,
	--受注店舗コード
	cd_jytyuten AS cd_tenpo,
	--日付
    CAST(to_date(dd_date) AS DATE) AS dd_date,
	--車名コード
	cd_ncsyamei,
	--車名
	kn_syame,
	--中古車受注実績
	NULLIFZERO(SUM(su_jusya_jucyu)) AS su_jusya_jucyu,
	--中古車受注取消
	NULLIFZERO(SUM(su_jusya_jucyu_torikesi)) AS su_jusya_jucyu_torikesi,
	--中古車受注合計
	NULLIFZERO(SUM(su_jusya_jucyu) - SUM(su_jusya_jucyu_torikesi)) AS su_jusya_jucyu_goukei,
	--中古車受注残
	NULLIFZERO(SUM(su_jusya_jucyucan)) AS su_jusya_jucyucan
FROM
	(
	SELECT
		--販社コード
		tg.cd_hansya,
		--会社コード
		tg.cd_kaisya,
		--受注店舗コード
		tg.cd_jytyuten,
		--車名コード
		CONCAT(NVL(tbbc001g.mj_21syamek, ''), 
               NVL(tbbc001g.mj_21syasyu, ''), 
               NVL(tbbc001g.mj_21syamak, ''), 
               NVL(tbbc001g.no_21syaren, ''), 
               NVL(tbbc001g.mj_21syanin, '')) AS cd_ncsyamei,
		--車名
		UPPER(NVL(tbv0232m.mj_syamei, '')) AS kn_syame,
		--日付
		tg.dd_jucyuke AS dd_date,
		--中古車受注実績
        CASE
			WHEN tg.dd_jucyuke IS NOT NULL THEN 1
			ELSE NULL
		END AS su_jusya_jucyu,
		--中古車受注取消
		0 AS su_jusya_jucyu_torikesi,
		--中古車受注残
		CASE
			WHEN tg.dd_jucyuke IS NOT NULL
			AND tg.dd_touroku IS NULL THEN 1
			ELSE NULL
		END AS su_jusya_jucyucan
	FROM
		ai21rep_ve_dx.tbbc017g tg	-- 中古車受注基本情報ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbbc001g tbbc001g	-- 中古車在庫基本情報ＤＢ
        ON
		tbbc001g.cd_kaisya = tg.cd_kaisya
		AND tbbc001g.cd_hansya = tg.cd_hansya
		AND tbbc001g.no_syaryou = tg.no_syaryou
	LEFT JOIN ai21rep_ve_dx.tbv0232m tbv0232m	-- ａｉ２１車名コードＤＢ
        ON
		tbv0232m.cd_hansya = tbbc001g.cd_hansya
		AND tbv0232m.cd_kaisya = tbbc001g.cd_kaisya
		-- 車名コード = ａｉ２１車名コードメーカー & ａｉ２１車名コード車種  &  ａｉ２１車名コード市場  &  ａｉ２１車名コード連番  &  ａｉ２１車名コード任意
		AND tbv0232m.cd_syamei = CONCAT(NVL(tbbc001g.mj_21syamek, ''), 
                                        NVL(tbbc001g.mj_21syasyu, ''), 
                                        NVL(tbbc001g.mj_21syamak, ''), 
                                        NVL(tbbc001g.no_21syaren, ''), 
                                        NVL(tbbc001g.mj_21syanin, ''))
	WHERE
		--受注計上日が空ではない
		tg.dd_jucyuke IS NOT NULL
		--受注計上日が前月1日より大きい
		AND from_timestamp(tg.dd_jucyuke, 'yyyyMM') >= from_timestamp(
            add_months(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 
            'yyyyMM'
        )
UNION ALL
	SELECT
		--販社コード
		tg.cd_hansya,
		--会社コード
		tg.cd_kaisya,
		--受注店舗コード
		tg.cd_jytyuten,
		--車名コード
		CONCAT(NVL(tbbc001g.mj_21syamek, ''), 
               NVL(tbbc001g.mj_21syasyu, ''), 
               NVL(tbbc001g.mj_21syamak, ''), 
               NVL(tbbc001g.no_21syaren, ''), 
               NVL(tbbc001g.mj_21syanin, '')) AS cd_ncsyamei,
        --車名
		UPPER(NVL(tbv0232m.mj_syamei, '')) AS kn_syame,
		--日付
		tg.dd_torikesi AS dd_date,
		--中古車受注実績
		0 AS su_jusya_jucyu,
		--中古車受注取消
		CASE
			WHEN tg.dd_torikesi IS NOT NULL THEN 1
			ELSE NULL
		END AS su_jusya_jucyu_torikesi,
		--中古車受注残
		0 AS su_jusya_jucyucan
	FROM
		ai21rep_ve_dx.tbbc017g tg	--中古車受注基本情報ＤＢ
	LEFT JOIN ai21rep_ve_dx.tbbc001g tbbc001g	--中古車在庫基本情報ＤＢ
        ON
		tbbc001g.cd_kaisya = tg.cd_kaisya
		AND tbbc001g.cd_hansya = tg.cd_hansya
		AND tbbc001g.no_syaryou = tg.no_syaryou
	LEFT JOIN ai21rep_ve_dx.tbv0232m tbv0232m	--ａｉ２１車名コードＤＢ
        ON
		tbv0232m.cd_hansya = tbbc001g.cd_hansya
		AND tbv0232m.cd_kaisya = tbbc001g.cd_kaisya
		--車名コード = ａｉ２１車名コードメーカー & ａｉ２１車名コード車種  &  ａｉ２１車名コード市場  &  ａｉ２１車名コード連番  &  ａｉ２１車名コード任意
		AND tbv0232m.cd_syamei = CONCAT(NVL(tbbc001g.mj_21syamek, ''), 
                                        NVL(tbbc001g.mj_21syasyu, ''), 
                                        NVL(tbbc001g.mj_21syamak, ''), 
                                        NVL(tbbc001g.no_21syaren, ''), 
                                        NVL(tbbc001g.mj_21syanin, ''))
	WHERE
		--受注計上日が空ではない
		tg.dd_jucyuke IS NOT NULL
		--取消日が前月1日より大きい
		AND from_timestamp(tg.dd_torikesi, 'yyyyMM') >= from_timestamp(
            add_months(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 
            'yyyyMM'
        )
) combined
GROUP BY
	cd_hansya,
	cd_kaisya,
	cd_jytyuten,
	to_date(dd_date),
	cd_ncsyamei,
	kn_syame
LIMIT 0;

-- [089/099] level=0 target=gold.vbi022002
-- Gold dependencies: none
-- Source file: 022_中古車車両日報/中古車車両日報_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi022002 AS
SELECT
	--販社コード
    cd_hansya,
    --会社コード
    cd_kaisya,
    --受注店舗コード
    cd_jytyuten AS cd_tenpo,
    --車名コード
    cd_ncsyamei,
    --車名
    kn_syame,
    --日付
    CAST(TO_DATE(dd_date) AS DATE) AS dd_date,
    --中古車販売実績
    NULLIFZERO(SUM(su_jusya_hanbai)) AS su_jusya_hanbai,
    --中古車販売取消
    NULLIFZERO(SUM(su_jusya_hanbai_torikesi)) AS su_jusya_hanbai_torikesi,
    --中古車販売合計
    NULLIFZERO(SUM(su_jusya_hanbai) - SUM(su_jusya_hanbai_torikesi)) AS su_jusya_hanbai_goukei,
    --当月中古車販売
    NULLIFZERO(
        SUM(
            CASE
                WHEN FROM_TIMESTAMP(dd_date, 'yyyyMM') =
                     FROM_TIMESTAMP(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 'yyyyMM')
                THEN su_jusya_hanbai - su_jusya_hanbai_torikesi
                ELSE 0
            END
        )
    ) AS su_jusya_hanbai_current
FROM
(
    SELECT
    	--販社コード
        tg.cd_hansya,
        --会社コード
        tg.cd_kaisya,
        --受注店舗コード
        tg.cd_jytyuten,
        --車名コード
        CONCAT(
            NVL(tbbc001g.mj_21syamek, ''),
            NVL(tbbc001g.mj_21syasyu, ''),
            NVL(tbbc001g.mj_21syamak, ''),
            NVL(tbbc001g.no_21syaren, ''),
            NVL(tbbc001g.mj_21syanin, '')
        ) AS cd_ncsyamei,
        --車名
        UPPER(NVL(tbv0232m.mj_syamei, '')) AS kn_syame,
        --日付
        CASE
            WHEN ft8006.dd_uriage IS NULL THEN tg.dd_uriagekj
            ELSE TO_TIMESTAMP(CAST(ft8006.dd_uriage AS STRING), 'yyyyMMdd')
        END AS dd_date,
        --中古車販売実績
        COUNT(*) AS su_jusya_hanbai,
        --中古車販売取消
        0 AS su_jusya_hanbai_torikesi
    FROM ai21rep_ve_dx.tbbc017g tg  --中古車受注基本情報ＤＢ
    LEFT JOIN ai21rep_ve_dx.tbbc001g tbbc001g  --中古車在庫基本情報ＤＢ
        ON tbbc001g.cd_kaisya = tg.cd_kaisya
        AND tbbc001g.cd_hansya = tg.cd_hansya
        AND tbbc001g.no_syaryou = tg.no_syaryou
    LEFT JOIN
    (
        SELECT
        	--販社コード
            t8006.cd_hansya,
            --会社コード
            t8006.cd_kaisya,
            --注文NO
            t8006.no_cyumon,
            --売上日
            MIN(t8006.dd_uriage) AS dd_uriage
        FROM ai21rep_ve_dx.tbg8006m t8006  --中古車小売売上トランＤＢ
        GROUP BY
            t8006.cd_hansya,
            t8006.cd_kaisya,
            t8006.no_cyumon,
            t8006.dd_uriage
    ) ft8006
        ON tg.cd_kaisya = ft8006.cd_kaisya
        AND tg.cd_kaisya = ft8006.cd_kaisya
        AND tg.no_cyumon = ft8006.no_cyumon
        --売上取消日が空である
        AND tg.dd_uritorik IS NULL
    LEFT JOIN ai21rep_ve_dx.tbv0232m tbv0232m
        ON tbv0232m.cd_hansya = tbbc001g.cd_hansya
        AND tbv0232m.cd_kaisya = tbbc001g.cd_kaisya
        AND tbv0232m.cd_syamei = CONCAT(
            NVL(tbbc001g.mj_21syamek, ''),
            NVL(tbbc001g.mj_21syasyu, ''),
            NVL(tbbc001g.mj_21syamak, ''),
            NVL(tbbc001g.no_21syaren, ''),
            NVL(tbbc001g.mj_21syanin, '')
        )
    WHERE 
        --売上計上日が空ではない
        tg.dd_uriagekj IS NOT NULL
        --取消日が空である
        AND tg.dd_torikesi IS NULL
        AND (
            (--売上日が空である
            ft8006.dd_uriage IS NULL
            	--売上計上日が前月1日より大きい
                AND FROM_TIMESTAMP(tg.dd_uriagekj, 'yyyyMM') >=
                    FROM_TIMESTAMP(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'yyyyMM'))
            OR
            (--売上日が空ではない
            ft8006.dd_uriage IS NOT NULL
            	--売上日が前月1日より大きい
                AND FROM_TIMESTAMP(TO_TIMESTAMP(CAST(ft8006.dd_uriage AS STRING), 'yyyyMMdd'), 'yyyyMM') >=
                    FROM_TIMESTAMP(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'yyyyMM'))
        )
    GROUP BY
        tg.cd_hansya,
        tg.cd_kaisya,
        tg.cd_jytyuten,
        CONCAT(
            NVL(tbbc001g.mj_21syamek, ''),
            NVL(tbbc001g.mj_21syasyu, ''),
            NVL(tbbc001g.mj_21syamak, ''),
            NVL(tbbc001g.no_21syaren, ''),
            NVL(tbbc001g.mj_21syanin, '')
        ),
        kn_syame,
        dd_date,
        tbbc001g.no_syaryou
    UNION ALL
    SELECT
    	--販社コード
        tg.cd_hansya,
        --会社コード
        tg.cd_kaisya,
        --受注店舗コード
        tg.cd_jytyuten,
        --車名コード
        CONCAT(
            NVL(tbbc001g.mj_21syamek, ''),
            NVL(tbbc001g.mj_21syasyu, ''),
            NVL(tbbc001g.mj_21syamak, ''),
            NVL(tbbc001g.no_21syaren, ''),
            NVL(tbbc001g.mj_21syanin, '')
        ) AS cd_ncsyamei,
        --車名
        UPPER(NVL(tbv0232m.mj_syamei, '')) AS kn_syame,
        --日付
        tg.dd_uritorik AS dd_date,
        --中古車販売実績
        0 AS su_jusya_hanbai,
        --中古車販売取消
        COUNT(*) AS su_jusya_hanbai_torikesi
    FROM ai21rep_ve_dx.tbbc017g tg  -- 中古車受注基本情報ＤＢ
    LEFT JOIN ai21rep_ve_dx.tbbc001g tbbc001g  -- 中古車在庫基本情報ＤＢ
        ON tbbc001g.cd_kaisya = tg.cd_kaisya
        AND tbbc001g.cd_hansya = tg.cd_hansya
        AND tbbc001g.no_syaryou = tg.no_syaryou
    LEFT JOIN ai21rep_ve_dx.tbv0232m tbv0232m  -- ａｉ２１車名コードＤＢ
        ON tbv0232m.cd_hansya = tbbc001g.cd_hansya
        AND tbv0232m.cd_kaisya = tbbc001g.cd_kaisya
        -- 車名コード = ａｉ２１車名コードメーカー & ａｉ２１車名コード車種  &  ａｉ２１車名コード市場  &  ａｉ２１車名コード連番  &  ａｉ２１車名コード任意
        AND tbv0232m.cd_syamei = CONCAT(
            NVL(tbbc001g.mj_21syamek, ''),
            NVL(tbbc001g.mj_21syasyu, ''),
            NVL(tbbc001g.mj_21syamak, ''),
            NVL(tbbc001g.no_21syaren, ''),
            NVL(tbbc001g.mj_21syanin, '')
        )
    WHERE 
        -- 受注計上日が空ではない
        tg.dd_jucyuke IS NOT NULL
        -- 売上取消日が前月1日より大きい
        AND FROM_TIMESTAMP(tg.dd_uritorik, 'yyyyMM') >=
            FROM_TIMESTAMP(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'yyyyMM')
    GROUP BY
        tg.cd_hansya,
        tg.cd_kaisya,
        tg.cd_jytyuten,
        CONCAT(
            NVL(tbbc001g.mj_21syamek, ''),
            NVL(tbbc001g.mj_21syasyu, ''),
            NVL(tbbc001g.mj_21syamak, ''),
            NVL(tbbc001g.no_21syaren, ''),
            NVL(tbbc001g.mj_21syanin, '')
        ),
        kn_syame,
        tg.dd_uritorik,
        tbbc001g.no_syaryou
) combined
GROUP BY
    cd_hansya,
    cd_kaisya,
    cd_jytyuten,
    cd_ncsyamei,
    kn_syame,
    TO_DATE(dd_date)
LIMIT 0;

-- [090/099] level=0 target=gold.vbi022003
-- Gold dependencies: none
-- Source file: 022_中古車車両日報/中古車車両日報_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi022003 AS
SELECT
	--販社コード
    tg.cd_hansya,
    --会社コード
    tg.cd_kaisya,
    --受注店舗コード
    tg.cd_jytyuten AS cd_tenpo,
    --車名
    UPPER(NVL(tbv0232m.mj_syamei, '')) AS kn_syame,
    --車名コード
    CONCAT(
        NVL(tbbc001g.mj_21syamek, ''),
        NVL(tbbc001g.mj_21syasyu, ''),
        NVL(tbbc001g.mj_21syamak, ''),
        NVL(tbbc001g.no_21syaren, ''),
        NVL(tbbc001g.mj_21syanin, '')
    ) AS cd_ncsyamei,
    --売上予定日
    CAST(TO_DATE(tg.dd_uriagyot) AS DATE) AS dd_uriagyot,
    --中古車販売見込み
    COUNT(*) AS su_jusya_hanbai_mikomi
FROM ai21rep_ve_dx.tbbc017g tg--中古車受注基本情報ＤＢ
    LEFT JOIN ai21rep_ve_dx.tbbc001g tbbc001g  --中古車在庫基本情報ＤＢ
        ON tbbc001g.cd_kaisya = tg.cd_kaisya
        AND tbbc001g.cd_hansya = tg.cd_hansya
        AND tbbc001g.no_syaryou = tg.no_syaryou
    LEFT JOIN ai21rep_ve_dx.tbv0232m tbv0232m  --ａｉ２１車名コードＤＢ
        ON tbv0232m.cd_hansya = tbbc001g.cd_hansya
        AND tbv0232m.cd_kaisya = tbbc001g.cd_kaisya
        --車名コード = ａｉ２１車名コードメーカー & ａｉ２１車名コード車種  &  ａｉ２１車名コード市場  &  ａｉ２１車名コード連番  &  ａｉ２１車名コード任意
        AND tbv0232m.cd_syamei = CONCAT(
            NVL(tbbc001g.mj_21syamek, ''),
            NVL(tbbc001g.mj_21syasyu, ''),
            NVL(tbbc001g.mj_21syamak, ''),
            NVL(tbbc001g.no_21syaren, ''),
            NVL(tbbc001g.mj_21syanin, '')
        )
WHERE 
    --売上計上日が空である
    tg.dd_uriagekj IS NULL
    --取消日が空である
    AND tg.dd_torikesi IS NULL
    --戻し売上日が空である
    AND tg.dd_moduriag IS NULL
    --売上予定日が当月である
    AND FROM_TIMESTAMP(tg.dd_uriagyot, 'yyyyMM') =
        FROM_TIMESTAMP(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'yyyyMM')
GROUP BY
    tg.cd_hansya,
    tg.cd_kaisya,
    tg.cd_jytyuten,
    UPPER(NVL(tbv0232m.mj_syamei, '')),
    CONCAT(
        NVL(tbbc001g.mj_21syamek, ''),
        NVL(tbbc001g.mj_21syasyu, ''),
        NVL(tbbc001g.mj_21syamak, ''),
        NVL(tbbc001g.no_21syaren, ''),
        NVL(tbbc001g.mj_21syanin, '')
    ),
    dd_uriagyot,
    tbbc001g.no_syaryou
LIMIT 0;

-- [091/099] level=1 target=gold.VBI022004
-- Gold dependencies: gold.vbi022001, gold.vbi022002, gold.vbi022003
-- Source file: 022_中古車車両日報/中古車車両日報_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI022004 AS
SELECT
	--販社コード
	cd_hansya AS 販社コード,
	--会社コード
	cd_kaisya AS 会社コード,
	--店舗コード
	cd_tenpo AS 店舗コード,
	--車名
	kn_syame AS 車名,
	--店舗名称
	kj_tenpomei AS 店舗名称,
	--店舗短縮名称
	kj_tentanms AS 店舗短縮名称,
	--ゾーンコード
	cd_zon AS ゾーンコード,
	--ゾーン名称
	kj_zonmei AS ゾーン名称,
	--中古車受注実績
	su_jusya_jucyu AS 中古車受注実績,
	--中古車受注取消
	su_jusya_jucyu_torikesi AS 中古車受注取消,
	--中古車受注合計
	su_jusya_jucyu_goukei AS 中古車受注合計,
	--中古車受注残
	su_jusya_jucyucan AS 中古車受注残,
	--中古車販売実績
	su_jusya_hanbai AS 中古車販売実績,
	--中古車販売取消
	su_jusya_hanbai_torikesi AS 中古車販売取消,
	--中古車販売合計
	su_jusya_hanbai_goukei AS 中古車販売合計,
	--当月中古車販売
	su_jusya_hanbai_current AS 当月中古車販売,
	--中古車販売見込み
	su_jusya_hanbai_mikomi AS 中古車販売見込み,
	--受注日付
	dd_jucyu AS 受注日付,
	--中古車販売日付
	dd_jusya_hanbai AS 中古車販売日付,
	--中古車見込み日付
	dd_jusya_mikomi AS 中古車見込み日付,
	--店舗ソート順
	DENSE_RANK() OVER (
    	PARTITION BY cd_hansya,cd_kaisya
		ORDER BY cd_zon,mj_sortjyun
    ) AS 店舗ソート順,
	--車名ソート順
    DENSE_RANK() OVER (
    	PARTITION BY cd_hansya,cd_kaisya
		ORDER BY sort_tyu,syamei_tyu,kn_syame
    ) AS 車名ソート順
FROM
	(
SELECT 
    t201m.cd_hansya,
    t201m.cd_kaisya,
    t201m.cd_tenpo,
    syame.kn_syame,
    t201m.kj_tenpomei,
    t201m.kj_tentanms,
    IF(
    	t033m.kj_zonmei IS NULL OR regexp_replace(t033m.kj_zonmei, '[ 　]+', '') = '',
    	'999999',
    	IF(
        	t033m.cd_zon IS NULL OR regexp_replace(t033m.cd_zon, '[ 　]+', '') = '',
        	'999998',
        	t033m.cd_zon
    	)
	) AS cd_zon,
    t033m.kj_zonmei,
    syame.su_jusya_jucyu AS su_jusya_jucyu,
    syame.su_jusya_jucyu_torikesi AS su_jusya_jucyu_torikesi,
    syame.su_jusya_jucyu_goukei AS su_jusya_jucyu_goukei,
    syame.su_jusya_jucyucan AS su_jusya_jucyucan,
    syame.su_jusya_hanbai AS su_jusya_hanbai,
    syame.su_jusya_hanbai_torikesi AS su_jusya_hanbai_torikesi,
    syame.su_jusya_hanbai_goukei AS su_jusya_hanbai_goukei,
    syame.su_jusya_hanbai_current AS su_jusya_hanbai_current,
    syame.su_jusya_hanbai_mikomi AS su_jusya_hanbai_mikomi,
    syame.dd_jucyu,
    syame.dd_jusya_hanbai,
    syame.dd_jusya_mikomi,
    RANK() OVER (
        PARTITION BY t201m.cd_hansya, t201m.cd_kaisya 
        ORDER BY tbi999003m.mj_sortjyun, t201m.cd_tenpo
    ) AS mj_sortjyun,
    --中古車ソート順
		MIN(sort_car_tyu.mj_sortjyun) OVER ( PARTITION BY t201m.cd_hansya, t201m.cd_kaisya, sort_car_tyu.kn_syame ) AS sort_tyu,
    --中古車車名ソート順
		MIN(sort_car_tyu.cd_ocsyamei) OVER ( PARTITION BY t201m.cd_hansya, t201m.cd_kaisya, sort_car_tyu.kn_syame ) AS syamei_tyu
FROM ai21rep_ve_dx.tbv0201m t201m --共通店舗ＤＢ
LEFT JOIN dx_ve.tbi999003m tbi999003m --店舗表示設定
    ON t201m.cd_hansya = tbi999003m.cd_hansya
    AND t201m.cd_kaisya = tbi999003m.cd_kaisya
    AND t201m.cd_tenpo = tbi999003m.cd_tenpo
    AND tbi999003m.mj_cyohyoid = '022'
LEFT JOIN ai21rep_ve_dx.tbv0047m t047m --M車両店舗ＤＢ
    ON t047m.cd_hansya = t201m.cd_hansya
    AND t047m.cd_kaisya = t201m.cd_kaisya
    AND t047m.cd_tenpo = t201m.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbv0033m t033m --MゾーンコードＤＢ
    ON t033m.cd_hansya = t201m.cd_hansya
    AND t033m.cd_kaisya = t201m.cd_kaisya
    AND t033m.cd_zon = t047m.cd_uczon
    AND t033m.kb_syohin = '2'
LEFT JOIN (
    SELECT 
        all_view.cd_hansya,
        all_view.cd_kaisya,
        all_view.cd_tenpo,
        all_view.kn_syame,
        SUM(su_jusya_jucyu) AS su_jusya_jucyu,
        SUM(su_jusya_jucyu_torikesi) AS su_jusya_jucyu_torikesi,
        SUM(su_jusya_jucyu_goukei) AS su_jusya_jucyu_goukei,
        SUM(su_jusya_jucyucan) AS su_jusya_jucyucan,
        SUM(su_jusya_hanbai) AS su_jusya_hanbai,
        SUM(su_jusya_hanbai_torikesi) AS su_jusya_hanbai_torikesi,
        SUM(su_jusya_hanbai_goukei) AS su_jusya_hanbai_goukei,
        SUM(su_jusya_hanbai_current) AS su_jusya_hanbai_current,
        SUM(su_jusya_hanbai_mikomi) AS su_jusya_hanbai_mikomi,
        dd_jucyu,
        dd_jusya_hanbai,
        dd_jusya_mikomi
    FROM (
        -- 中古車受注
        SELECT 
            v1.cd_hansya,
            v1.cd_kaisya,
            v1.cd_tenpo,
            v1.cd_ncsyamei,
            v1.kn_syame,
            v1.su_jusya_jucyu,
            v1.su_jusya_jucyu_torikesi,
            v1.su_jusya_jucyu_goukei,
            v1.su_jusya_jucyucan,
            NULL AS su_jusya_hanbai,
            NULL AS su_jusya_hanbai_torikesi,
            NULL AS su_jusya_hanbai_goukei,
            NULL AS su_jusya_hanbai_current,
            NULL AS su_jusya_hanbai_mikomi,
            v1.dd_date AS dd_jucyu,
            NULL AS dd_jusya_hanbai,
            NULL AS dd_jusya_mikomi
        FROM gold.vbi022001 v1
        UNION ALL
        -- 中古車販売
        SELECT 
            v2.cd_hansya,
            v2.cd_kaisya,
            v2.cd_tenpo,
            v2.cd_ncsyamei,
            v2.kn_syame,
            NULL AS su_jusya_jucyu,
            NULL AS su_jusya_jucyu_torikesi,
            NULL AS su_jusya_jucyu_goukei,
            NULL AS su_jusya_jucyucan,
            v2.su_jusya_hanbai,
            v2.su_jusya_hanbai_torikesi,
            v2.su_jusya_hanbai_goukei,
            v2.su_jusya_hanbai_current,
            NULL AS su_jusya_hanbai_mikomi,
            NULL AS dd_jucyu,
            v2.dd_date AS dd_jusya_hanbai,
            NULL AS dd_jusya_mikomi
        FROM gold.vbi022002 v2
        UNION ALL        
        -- 中古車販売見込み
        SELECT 
            v3.cd_hansya,
            v3.cd_kaisya,
            v3.cd_tenpo,
            v3.cd_ncsyamei,
            v3.kn_syame,
            NULL AS su_jusya_jucyu,
            NULL AS su_jusya_jucyu_torikesi,
            NULL AS su_jusya_jucyu_goukei,
            NULL AS su_jusya_jucyucan,
            NULL AS su_jusya_hanbai,
            NULL AS su_jusya_hanbai_torikesi,
            NULL AS su_jusya_hanbai_goukei,
            NULL AS su_jusya_hanbai_current,
            v3.su_jusya_hanbai_mikomi,
            NULL AS dd_jucyu,
            NULL AS dd_jusya_hanbai,
            v3.dd_uriagyot AS dd_jusya_mikomi
        FROM gold.vbi022003 v3
    ) all_view
    LEFT JOIN dx_ve.tbi999009m tbi999009m --中古車車種表示設定
        ON tbi999009m.cd_hansya = all_view.cd_hansya
        AND tbi999009m.cd_kaisya = all_view.cd_kaisya
        AND tbi999009m.cd_ocsyamei = all_view.cd_ncsyamei
        AND tbi999009m.kb_tenji = 1
    WHERE
    	--販社コードが空ではない
    	tbi999009m.cd_hansya IS NOT NULL
    GROUP BY 
        cd_hansya,
        cd_kaisya,
        cd_tenpo,
        kn_syame,
        dd_jucyu,
        dd_jusya_hanbai,
        dd_jusya_mikomi
) syame 
    ON t201m.cd_hansya = syame.cd_hansya
    AND t201m.cd_kaisya = syame.cd_kaisya
    AND t201m.cd_tenpo = syame.cd_tenpo
LEFT JOIN (SELECT	
				 tbi999009m.cd_hansya,
				 tbi999009m.cd_kaisya,
				 TRIM(tbi999009m.kn_syame) AS kn_syame,
				 MIN(tbi999009m.mj_sortjyun) AS mj_sortjyun,
				 MIN(tbi999009m.cd_ocsyamei) AS cd_ocsyamei
 		FROM dx_ve.tbi999009m --中古車車種表示設定
		WHERE
			--表示区分が 「1」 である
			tbi999009m.kb_tenji = 1
		GROUP BY 
			tbi999009m.cd_hansya,
			tbi999009m.cd_kaisya,
			TRIM(tbi999009m.kn_syame)
		) sort_car_tyu
	ON syame.cd_hansya = sort_car_tyu.cd_hansya
    AND syame.cd_kaisya = sort_car_tyu.cd_kaisya
	AND TRIM(syame.kn_syame) = TRIM(sort_car_tyu.kn_syame)
WHERE
	--表示区分が 「1」 である
	tbi999003m.kb_tenji = 1
) zhugokusya_nippou
LIMIT 0;

-- [092/099] level=0 target=gold.vbi999001
-- Gold dependencies: none
-- Source file: 101_マスタメンテナンス/vbi999001-VBI999010_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi999001 AS
SELECT
	t200m.cd_hanbaitn AS `販売店コード`, --販売店コード
	t200m.cd_hansya AS `販社コード`, --販社コード
	t200m.cd_kaisya AS `会社コード`, --会社コード
	CONCAT(t200m.cd_hanbaitn, '_', regexp_replace(t200m.kj_kaisya, '　| +$', '')) AS `会社名`,  --会社名
    GROUP_CONCAT(v9001m.mj_account, ';') AS `メール`, --メール
	GROUP_CONCAT(IF(
		v9001m.mj_account LIKE '%toyotecdap.onmicrosoft.com',
		v9001m.mj_account,
		CONCAT(REPLACE(v9001m.mj_account, '@', '_'), '#EXT#@toyotecdap.onmicrosoft.com')
	), ';') AS `メールSP`  --メールSP
FROM ai21rep_ve_dx.tbv0200m t200m --会社コードＤＢ 
INNER JOIN dx_ve.tbi999001m v9001m --ユーザ情報  
ON v9001m.cd_hanbaitn = t200m.cd_hanbaitn
AND v9001m.kb_masterkengen = '1'
GROUP BY t200m.cd_hansya, t200m.cd_kaisya, t200m.cd_hanbaitn, regexp_replace(t200m.kj_kaisya, '　| +$', '')
LIMIT 0;

-- [093/099] level=0 target=gold.vbi999002
-- Gold dependencies: none
-- Source file: 101_マスタメンテナンス/vbi999001-VBI999010_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi999002 AS
WITH bs AS(
	SELECT
		bt.cd_hansya, --販社コード
		bt.cd_kaisya, --会社コード
		bt.cd_tenpo, --店舗コード
		max(bt.`表示可否1`) AS `表示可否1`, --表示可否1
		max(bt.`表示可否2`) AS `表示可否2`, --表示可否2
		max(bt.`表示可否3`) AS `表示可否3`, --表示可否3
		max(bt.`表示可否4`) AS `表示可否4`, --表示可否4
		max(bt.`表示可否5`) AS `表示可否5`, --表示可否5
		max(bt.`表示可否6`) AS `表示可否6`, --表示可否6
		max(bt.`表示可否7`) AS `表示可否7`, --表示可否7
		max(bt.`表示可否8`) AS `表示可否8`, --表示可否8
		max(bt.`表示可否9`) AS `表示可否9`, --表示可否9
		max(bt.`表示可否10`) AS `表示可否10`, --表示可否10
		max(bt.`表示可否11`) AS `表示可否11`, --表示可否11
		max(bt.`表示順1`) AS `表示順1`, --表示順1
		max(bt.`表示順2`) AS `表示順2`, --表示順2
		max(bt.`表示順3`) AS `表示順3`, --表示順3
		max(bt.`表示順4`) AS `表示順4`, --表示順4
		max(bt.`表示順5`) AS `表示順5`, --表示順5
		max(bt.`表示順6`) AS `表示順6`, --表示順6
		max(bt.`表示順7`) AS `表示順7`, --表示順7
		max(bt.`表示順8`) AS `表示順8`, --表示順8
		max(bt.`表示順9`) AS `表示順9`, --表示順9
		max(bt.`表示順10`) AS `表示順10`, --表示順10
		max(bt.`表示順11`) AS `表示順11` --表示順11
	FROM(
		SELECT
			v9003m.cd_hansya, --販社コード
			v9003m.cd_kaisya, --会社コード
			v9003m.cd_tenpo, --店舗コード
			IF(v9003m.mj_cyohyoid = '000' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否1`, --表示可否1
			IF(v9003m.mj_cyohyoid = '001' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否2`, --表示可否2
			IF(v9003m.mj_cyohyoid = '022' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否3`, --表示可否3
			IF(v9003m.mj_cyohyoid = '002' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否4`, --表示可否4
			IF(v9003m.mj_cyohyoid = '013' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否5`, --表示可否5
			IF(v9003m.mj_cyohyoid = '011' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否6`, --表示可否6
			IF(v9003m.mj_cyohyoid = '003' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否7`, --表示可否7
			IF(v9003m.mj_cyohyoid = '012' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否8`, --表示可否8
			IF(v9003m.mj_cyohyoid = '016' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否9`, --表示可否9
			IF(v9003m.mj_cyohyoid = '017' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否10`, --表示可否10
			IF(v9003m.mj_cyohyoid = '019' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否11`, --表示可否11
			IF(v9003m.mj_cyohyoid = '000', v9003m.mj_sortjyun, NULL) AS `表示順1`, --表示順1
			IF(v9003m.mj_cyohyoid = '001', v9003m.mj_sortjyun, NULL) AS `表示順2`, --表示順2
			IF(v9003m.mj_cyohyoid = '022', v9003m.mj_sortjyun, NULL) AS `表示順3`, --表示順3
			IF(v9003m.mj_cyohyoid = '002', v9003m.mj_sortjyun, NULL) AS `表示順4`, --表示順4
			IF(v9003m.mj_cyohyoid = '013', v9003m.mj_sortjyun, NULL) AS `表示順5`, --表示順5
			IF(v9003m.mj_cyohyoid = '011', v9003m.mj_sortjyun, NULL) AS `表示順6`, --表示順6
			IF(v9003m.mj_cyohyoid = '003', v9003m.mj_sortjyun, NULL) AS `表示順7`, --表示順7
			IF(v9003m.mj_cyohyoid = '012', v9003m.mj_sortjyun, NULL) AS `表示順8`, --表示順8
			IF(v9003m.mj_cyohyoid = '016', v9003m.mj_sortjyun, NULL) AS `表示順9`, --表示順9
			IF(v9003m.mj_cyohyoid = '017', v9003m.mj_sortjyun, NULL) AS `表示順10`, --表示順10
			IF(v9003m.mj_cyohyoid = '019', v9003m.mj_sortjyun, NULL) AS `表示順11` --表示順11
		FROM dx_ve.tbi999003m v9003m --店舗表示設定
		--帳票ＩＤ = 指定したID
		WHERE v9003m.mj_cyohyoid in('000', '001', '002', '003', '011', '012', '013', '016', '017', '019', '022')
	) bt
	GROUP BY bt.cd_hansya, bt.cd_kaisya, bt.cd_tenpo
)
SELECT
	ROW_NUMBER() OVER(PARTITION BY t201m.cd_hansya, t201m.cd_kaisya order by t201m.kj_tenpomei, t201m.cd_tenpo) AS `No.`, --No
	t201m.cd_hansya AS `販社コード`, --販社コード
	t201m.cd_kaisya AS `会社コード`, --会社コード
	t201m.cd_tenpo AS `店舗コード`, --店舗コード
	regexp_replace(t201m.kj_tenpomei, '　+$', '') AS `店舗名`, --店舗名
	NVL(v3001m.tm_kaiten, '09:00:00') AS `開店時間`, --開店時間
	NVL(v3001m.tm_heiten, '17:00:00') AS `閉店時間`, --閉店時間
	v1001m.nu_sinsyajucyu AS `新車受注`, --新車受注
	v1001m.nu_sinsyahanbai AS `新車販売`, --新車販売
	v1001m.nu_jusyajucyu AS `中古車受注`, --中古車受注
	v1001m.nu_jusyahanbai AS `中古車販売`, --中古車販売
	NVL(bs.`表示可否1`, '○') AS `表示可否1`, --表示可否1
	NVL(bs.`表示可否2`, '○') AS `表示可否2`, --表示可否2
	NVL(bs.`表示可否3`, '○') AS `表示可否3`, --表示可否3
	NVL(bs.`表示可否4`, '○') AS `表示可否4`, --表示可否4
	NVL(bs.`表示可否5`, '○') AS `表示可否5`, --表示可否5
	NVL(bs.`表示可否6`, '○') AS `表示可否6`, --表示可否6
	NVL(bs.`表示可否7`, '○') AS `表示可否7`, --表示可否7
	NVL(bs.`表示可否8`, '○') AS `表示可否8`, --表示可否8
	NVL(bs.`表示可否9`, '○') AS `表示可否9`, --表示可否9
	NVL(bs.`表示可否10`, '○') AS `表示可否10`, --表示可否10
	NVL(bs.`表示可否11`, '○') AS `表示可否11`, --表示可否11
	bs.`表示順1`, --表示順1
	bs.`表示順2`, --表示順2
	bs.`表示順3`, --表示順3
	bs.`表示順4`, --表示順4
	bs.`表示順5`, --表示順5
	bs.`表示順6`, --表示順6
	bs.`表示順7`, --表示順7
	bs.`表示順8`, --表示順8
	bs.`表示順9`, --表示順9
	bs.`表示順10`, --表示順10
	bs.`表示順11` --表示順11
FROM ai21rep_ve_dx.tbv0201m t201m  --共通店舗ＤＢ
LEFT semi JOIN ai21rep_ve_dx.tbv0200m t200m --会社コードＤＢ  
ON t200m.cd_hansya = t201m.cd_hansya
AND t200m.cd_kaisya = t201m.cd_kaisya
LEFT JOIN dx_ve.tbi003001m v3001m --SMB異常管理ボード集計対象店舗一覧
ON v3001m.cd_hansya = t201m.cd_hansya
AND v3001m.cd_kaisya = t201m.cd_kaisya
AND v3001m.cd_tenpo = t201m.cd_tenpo
LEFT JOIN dx_ve.tbi001001m v1001m --目標  
ON v1001m.cd_hansya = t201m.cd_hansya
AND v1001m.cd_kaisya = t201m.cd_kaisya
AND v1001m.cd_tenpo = t201m.cd_tenpo
LEFT JOIN bs ON bs.cd_hansya = t201m.cd_hansya
AND bs.cd_kaisya = t201m.cd_kaisya
AND bs.cd_tenpo = t201m.cd_tenpo
LIMIT 0;

-- [094/099] level=0 target=gold.vbi999003
-- Gold dependencies: none
-- Source file: 101_マスタメンテナンス/vbi999001-VBI999010_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi999003 AS
SELECT
	1 AS `No.`, --No
	t200m.cd_hansya AS `販社コード`, --販社コード
	t200m.cd_kaisya AS `会社コード`, --会社コード
	'新車' AS `新車中古車区分`, --新車中古車区分
	CAST(NVL(v2001m.su_leadtime, 20) AS string) AS `リードタイム日`, --リードタイム日
	NVL(v2001m.su_minosya, 30) AS `未納車経過日`, --未納車経過日
	NVL(v2001m.su_touroku, 90) AS `登録経過日`, --登録経過日
	CAST(NVL(v2001m.su_fr, 90) AS string) AS `振当経過日`, --振当経過日
	NVL(v2001m.su_jucyu, 365) AS `受注経過日` --受注経過日
FROM ai21rep_ve_dx.tbv0200m t200m --会社コードＤＢ 
LEFT JOIN dx_ve.tbi002001m v2001m --新車アラート項目設定
ON v2001m.cd_hansya = t200m.cd_hansya
AND v2001m.cd_kaisya = t200m.cd_kaisya
UNION ALL
SELECT
	2 AS `No.`, --No
	t200m.cd_hansya AS `販社コード`, --販社コード
	t200m.cd_kaisya AS `会社コード`, --会社コード
	'中古車' AS `新車中古車区分`, --新車中古車区分
	'-' AS `リードタイム日`, --リードタイム日
	NVL(v13001m.su_minosya, 14) AS `未納車経過日`, --未納車経過日
	NVL(v13001m.su_touroku, 30) AS `登録経過日`, --登録経過日
	'-' AS `振当経過日`, --振当経過日
	NVL(v13001m.su_jucyu, 30) AS `受注経過日` --受注経過日
FROM ai21rep_ve_dx.tbv0200m t200m --会社コードＤＢ 
LEFT JOIN dx_ve.tbi013001m v13001m --中古車アラート項目設定
ON v13001m.cd_hansya = t200m.cd_hansya
AND v13001m.cd_kaisya = t200m.cd_kaisya
LIMIT 0;

-- [095/099] level=0 target=gold.vbi999004
-- Gold dependencies: none
-- Source file: 101_マスタメンテナンス/vbi999001-VBI999010_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi999004 AS
SELECT
	ROW_NUMBER() OVER(PARTITION BY t001m.cd_hansya, t001m.cd_kaisya order by t001m.cd_tenpo, t001m.no_stall) AS `No.`, --No
	t001m.cd_hansya AS `販社コード`, --販社コード
	t001m.cd_kaisya AS `会社コード`, --会社コード
	t001m.cd_tenpo AS `店舗コード`, --店舗コード
	regexp_replace(t201m.kj_tenpomei, '　+$', '') AS `店舗名`, --店舗名
	t001m.no_stall AS `ストール番号`, --ストール番号
	CONCAT(t001m.mj_stallmei, '##', CAST(ROW_NUMBER() OVER(PARTITION BY t001m.cd_hansya, t001m.cd_kaisya order by t001m.cd_tenpo, t001m.no_stall) AS string), '##') AS `ストール名称`, --ストール名称
	if (v3002m.kb_shuukeitaishou = '0', '×', '○') AS `集計対象判別` --集計対象判別
FROM ai21rep_ve_dx.tbsa001m t001m --ストールマスタＤＢ 
LEFT JOIN ai21rep_ve_dx.tbv0201m t201m -- 共通店舗ＤＢ 
ON t201m.cd_hansya = t001m.cd_hansya
AND t201m.cd_kaisya = t001m.cd_kaisya
AND t201m.cd_tenpo = t001m.cd_tenpo
LEFT JOIN dx_ve.tbi003002m v3002m --ストール集計対象一覧 
ON v3002m.cd_hansya = t001m.cd_hansya
AND v3002m.cd_kaisya = t001m.cd_kaisya
AND v3002m.cd_tenpo = t001m.cd_tenpo
AND v3002m.no_stall = t001m.no_stall
LIMIT 0;

-- [096/099] level=0 target=gold.vbi999008
-- Gold dependencies: none
-- Source file: 101_マスタメンテナンス/vbi999001-VBI999010_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi999008 AS
SELECT
	bt.cd_hansya AS `販社コード`, --販社コード
	bt.cd_kaisya AS `会社コード`, --会社コード
	GROUP_CONCAT(bt.mj_message, '<br /><br />') AS `メッセージ` --メッセージ
FROM (
	SELECT
		bt.cd_hansya, --販社コード
		bt.cd_kaisya, --会社コード
		CONCAT('※店舗情報が変更されましたため、マスタ情報の設定をお願い致します<br />下記が対象の店舗となります<br />※店舗コード_店舗名の順で記載しております<br />-------------<br />', GROUP_CONCAT(bt.mj_message, '<br /><br />'), '<br />-------------') AS mj_message  --メッセージ
	FROM (
		SELECT
			t201m.cd_hansya, --販社コード
			t201m.cd_kaisya, --会社コード
			CONCAT('■新規追加された店舗<br />', GROUP_CONCAT(CONCAT(t201m.cd_tenpo, '_', regexp_replace(t201m.kj_tenpomei, '　+$', '')), '、')) AS mj_message   --メッセージ
		FROM ai21rep_ve_dx.tbv0201m t201m --共通店舗ＤＢ 
		LEFT anti JOIN dx_ve.tbi003001m v3001m --SMB異常管理ボード集計対象店舗一覧
		ON v3001m.cd_hansya = t201m.cd_hansya
		AND v3001m.cd_kaisya = t201m.cd_kaisya
		AND v3001m.cd_tenpo = t201m.cd_tenpo
		GROUP BY t201m.cd_hansya, t201m.cd_kaisya
		UNION ALL
		SELECT
			t201m.cd_hansya, --販社コード
			t201m.cd_kaisya, --会社コード
			CONCAT('■変更があった店舗<br />', GROUP_CONCAT(CONCAT(v3001m.cd_tenpo, '_', regexp_replace(v3001m.kj_tenpomei, '　+$', ''), '　→', t201m.cd_tenpo, '_', regexp_replace(t201m.kj_tenpomei, '　+$', '')), '、')) AS mj_message --メッセージ
		FROM ai21rep_ve_dx.tbv0201m t201m --共通店舗ＤＢ 
		INNER JOIN dx_ve.tbi003001m v3001m --SMB異常管理ボード集計対象店舗一覧
		ON v3001m.cd_hansya = t201m.cd_hansya
		AND v3001m.cd_kaisya = t201m.cd_kaisya
		AND v3001m.cd_tenpo = t201m.cd_tenpo
		AND CONCAT(v3001m.cd_tenpo, '_', regexp_replace(v3001m.kj_tenpomei, '　+$', '')) <> CONCAT(t201m.cd_tenpo, '_', regexp_replace(t201m.kj_tenpomei, '　+$', ''))
		GROUP BY t201m.cd_hansya, t201m.cd_kaisya
		UNION ALL
		SELECT
			v3001m.cd_hansya, --販社コード
			v3001m.cd_kaisya, --会社コード
			CONCAT('■削除された店舗<br />', GROUP_CONCAT(CONCAT(v3001m.cd_tenpo, '_', regexp_replace(v3001m.kj_tenpomei, '　+$', '')), '、'))  --メッセージ
		FROM dx_ve.tbi003001m v3001m --SMB異常管理ボード集計対象店舗一覧
		LEFT anti JOIN ai21rep_ve_dx.tbv0201m t201m --共通店舗ＤＢ 
		ON t201m.cd_hansya = v3001m.cd_hansya
		AND t201m.cd_kaisya = v3001m.cd_kaisya
		AND t201m.cd_tenpo = v3001m.cd_tenpo
		GROUP BY v3001m.cd_hansya, v3001m.cd_kaisya
	) bt
	GROUP BY bt.cd_hansya, bt.cd_kaisya
	UNION ALL
	SELECT
		bt.cd_hansya, --販社コード
		bt.cd_kaisya, --会社コード
		CONCAT('※ストール情報が変更されましたため、マスタ情報の設定をお願い致します<br />下記が対象のストールとなります<br />※ストールコード_ストール名の順で記載しております<br />-------------<br />', GROUP_CONCAT(bt.mj_message, '<br /><br />'), '<br />-------------')  --メッセージ
	FROM (
		SELECT
			t001m.cd_hansya, --販社コード
			t001m.cd_kaisya, --会社コード
			CONCAT('■新規追加されたストール<br />', GROUP_CONCAT(CONCAT(CAST(t001m.no_stall AS string), '_', t001m.mj_stallmei), '、')) AS mj_message --メッセージ
		FROM ai21rep_ve_dx.tbsa001m t001m --ストールマスタＤＢ
		LEFT semi JOIN ai21rep_ve_dx.tbv0201m t201m  --共通店舗ＤＢ
		ON t201m.cd_hansya = t001m.cd_hansya
		AND t201m.cd_kaisya = t001m.cd_kaisya
		AND t201m.cd_tenpo = t001m.cd_tenpo
		LEFT anti JOIN dx_ve.tbi003002m v3002m --ストール集計対象一覧
		ON v3002m.cd_hansya = t001m.cd_hansya
		AND v3002m.cd_kaisya = t001m.cd_kaisya
		AND v3002m.cd_tenpo = t001m.cd_tenpo
		AND v3002m.no_stall = t001m.no_stall
		GROUP BY t001m.cd_hansya, t001m.cd_kaisya
		UNION ALL
		SELECT
			t001m.cd_hansya, --販社コード
			t001m.cd_kaisya, --会社コード
			CONCAT('■変更があったストール<br />', GROUP_CONCAT(CONCAT(CAST(v3002m.no_stall AS string), '_', v3002m.mj_stallmei, '　→', CAST(t001m.no_stall AS string), '_', t001m.mj_stallmei), '、')) --メッセージ
		FROM ai21rep_ve_dx.tbsa001m t001m --ストールマスタＤＢ
		LEFT semi JOIN ai21rep_ve_dx.tbv0201m t201m  --共通店舗ＤＢ
		ON t201m.cd_hansya = t001m.cd_hansya
		AND t201m.cd_kaisya = t001m.cd_kaisya
		AND t201m.cd_tenpo = t001m.cd_tenpo
		INNER JOIN dx_ve.tbi003002m v3002m --ストール集計対象一覧
		ON v3002m.cd_hansya = t001m.cd_hansya
		AND v3002m.cd_kaisya = t001m.cd_kaisya
		AND v3002m.cd_tenpo = t001m.cd_tenpo
		AND v3002m.no_stall = t001m.no_stall
		AND CONCAT(CAST(v3002m.no_stall AS string), '_', v3002m.mj_stallmei) <> CONCAT(CAST(t001m.no_stall AS string), '_', t001m.mj_stallmei)
		GROUP BY t001m.cd_hansya, t001m.cd_kaisya
		UNION ALL
		SELECT
			v3002m.cd_hansya, --販社コード
			v3002m.cd_kaisya, --会社コード
			CONCAT('■削除されたストール<br />', GROUP_CONCAT(CONCAT(CAST(v3002m.no_stall AS string), '_', v3002m.mj_stallmei), '、')) --メッセージ
		FROM dx_ve.tbi003002m v3002m --ストール集計対象一覧
		LEFT semi JOIN ai21rep_ve_dx.tbv0201m t201m  --共通店舗ＤＢ
		ON t201m.cd_hansya = v3002m.cd_hansya
		AND t201m.cd_kaisya = v3002m.cd_kaisya
		AND t201m.cd_tenpo = v3002m.cd_tenpo
		LEFT anti JOIN ai21rep_ve_dx.tbsa001m t001m --ストールマスタＤＢ 
		ON t001m.cd_hansya = v3002m.cd_hansya
		AND t001m.cd_kaisya = v3002m.cd_kaisya
		AND t001m.cd_tenpo = v3002m.cd_tenpo
		AND t001m.no_stall = v3002m.no_stall
		GROUP BY v3002m.cd_hansya, v3002m.cd_kaisya
	) bt
	GROUP BY bt.cd_hansya, bt.cd_kaisya
	UNION ALL
	SELECT
		bt.cd_hansya, --販社コード
		bt.cd_kaisya, --会社コード
		CONCAT('※新車車種情報が変更されましたため、マスタ情報の設定をお願い致します<br />下記が対象の車名となります<br />※車名コード_車名の順で記載しております<br />-------------<br />', GROUP_CONCAT(bt.mj_meaasge, '<br /><br />'), '<br />-------------') --メッセージ
	FROM (
		SELECT
			tf001m.cd_hansya, --販社コード
			tf001m.cd_kaisya, --会社コード
			CONCAT('■新規追加された車種<br />',GROUP_CONCAT(CONCAT(tf001m.cd_ncsyamei, '_', regexp_replace(tf001m.kn_syame, '[　| ]+$', ''), '_', regexp_replace(tf001m.kj_kurumame, '[　| ]+$', '')), '、')) AS mj_meaasge --メッセージ
		FROM ai21rep_ve_dx.tbbf001m tf001m --車名ＤＢ
		LEFT anti JOIN dx_ve.tbi999008m t9008m --新車車種表示設定
		ON t9008m.cd_hansya = tf001m.cd_hansya
		AND t9008m.cd_kaisya = tf001m.cd_kaisya
		AND t9008m.cd_ncsyamei = tf001m.cd_ncsyamei
		GROUP BY tf001m.cd_hansya, tf001m.cd_kaisya
		UNION ALL
		SELECT
			tf001m.cd_hansya, --販社コード
			tf001m.cd_kaisya, --会社コード
			CONCAT('■変更があった車種<br />',GROUP_CONCAT(CONCAT(t9008m.cd_ncsyamei, '_', regexp_replace(t9008m.kn_syamei, '[　| ]+$', ''), '_', regexp_replace(t9008m.kj_kurumame, '[　| ]+$', ''), '　→', tf001m.cd_ncsyamei, '_', regexp_replace(tf001m.kn_syame, '[　| ]+$', ''), '_', regexp_replace(tf001m.kj_kurumame, '[　| ]+$', '')), '<br />')) --メッセージ
		FROM ai21rep_ve_dx.tbbf001m tf001m --車名ＤＢ
		INNER JOIN dx_ve.tbi999008m t9008m --新車車種表示設定 
		ON t9008m.cd_hansya = tf001m.cd_hansya
		AND t9008m.cd_kaisya = tf001m.cd_kaisya
		AND t9008m.cd_ncsyamei = tf001m.cd_ncsyamei
		AND CONCAT(regexp_replace(t9008m.kn_syamei, '[　| ]+$', ''), '_', regexp_replace(t9008m.kj_kurumame, '[　| ]+$', '')) <> CONCAT(regexp_replace(tf001m.kn_syame, '[　| ]+$', ''), '_', regexp_replace(tf001m.kj_kurumame, '[　| ]+$', ''))
		GROUP BY tf001m.cd_hansya, tf001m.cd_kaisya
		UNION ALL
		SELECT
			t9008m.cd_hansya, --販社コード
			t9008m.cd_kaisya, --会社コード
			CONCAT('■削除された車種<br />',GROUP_CONCAT(CONCAT(t9008m.cd_ncsyamei, '_', regexp_replace(t9008m.kn_syamei, '[　| ]+$', ''), '_', regexp_replace(t9008m.kj_kurumame, '[　| ]+$', '')), '、'))  --メッセージ
		FROM dx_ve.tbi999008m t9008m --新車車種表示設定 
		LEFT anti JOIN ai21rep_ve_dx.tbbf001m tf001m --車名ＤＢ 
		ON tf001m.cd_hansya = t9008m.cd_hansya
		AND tf001m.cd_kaisya = t9008m.cd_kaisya
		AND tf001m.cd_ncsyamei = t9008m.cd_ncsyamei
		GROUP BY t9008m.cd_hansya, t9008m.cd_kaisya
	) bt
	GROUP BY bt.cd_hansya, bt.cd_kaisya
	UNION ALL
	SELECT
		bt.cd_hansya, --販社コード
		bt.cd_kaisya, --会社コード
		CONCAT('※中古車車種情報が変更されましたため、マスタ情報の設定をお願い致します<br />下記が対象の車名となります<br />※車名コード_車名の順で記載しております<br />-------------<br />', GROUP_CONCAT(bt.mj_meaasge, '<br /><br />'), '<br />-------------') --メッセージ
	FROM (
		SELECT
			t0232m.cd_hansya, --販社コード
			t0232m.cd_kaisya, --会社コード
			CONCAT('■新規追加された車種<br />',GROUP_CONCAT(CONCAT(t0232m.cd_syamei, '_', regexp_replace(t0232m.mj_syamei, '[　| ]+$', ''), '_', regexp_replace(t0232m.kj_syamei, '[　| ]+$', '')), '、')) AS mj_meaasge --メッセージ
		FROM ai21rep_ve_dx.tbv0232m t0232m --ａｉ２１車名コードＤＢ
		LEFT anti JOIN dx_ve.tbi999009m t9009m --中古車車種表示設定 
		ON t9009m.cd_hansya = t0232m.cd_hansya
		AND t9009m.cd_kaisya = t0232m.cd_kaisya
		AND t9009m.cd_ocsyamei = t0232m.cd_syamei
		WHERE t0232m.mj_syamei IS NOT NULL
		GROUP BY t0232m.cd_hansya, t0232m.cd_kaisya
		UNION ALL
		SELECT
			t0232m.cd_hansya, --販社コード
			t0232m.cd_kaisya, --会社コード
			CONCAT('■変更があった車種<br />',GROUP_CONCAT(CONCAT(t9009m.cd_ocsyamei, '_', regexp_replace(t9009m.kn_syame, '[　| ]+$', ''), '_', regexp_replace(t9009m.kj_kurumame, '[　| ]+$', ''), '　→', t0232m.cd_syamei, '_', regexp_replace(t0232m.mj_syamei, '[　| ]+$', ''), '_', regexp_replace(t0232m.kj_syamei, '[　| ]+$', '')), '、')) --メッセージ
		FROM ai21rep_ve_dx.tbv0232m t0232m --ａｉ２１車名コードＤＢ
		INNER JOIN dx_ve.tbi999009m t9009m --中古車車種表示設定 
		ON t9009m.cd_hansya = t0232m.cd_hansya
		AND t9009m.cd_kaisya = t0232m.cd_kaisya
		AND t9009m.cd_ocsyamei = t0232m.cd_syamei
		AND CONCAT(t9009m.cd_ocsyamei, '_', regexp_replace(t9009m.kn_syame, '[　| ]+$', ''), '_', regexp_replace(t9009m.kj_kurumame, '[　| ]+$', '')) <> CONCAT(t0232m.cd_syamei, '_', regexp_replace(t0232m.mj_syamei, '[　| ]+$', ''), '_', regexp_replace(t0232m.kj_syamei, '[　| ]+$', ''))
		WHERE t0232m.mj_syamei IS NOT NULL
		GROUP BY t0232m.cd_hansya, t0232m.cd_kaisya
		UNION ALL
		SELECT
			t9009m.cd_hansya, --販社コード
			t9009m.cd_kaisya, --会社コード
			CONCAT('■削除された車種<br />',GROUP_CONCAT(CONCAT(t9009m.cd_ocsyamei, '_', regexp_replace(t9009m.kn_syame, '[　| ]+$', ''), '_', regexp_replace(t9009m.kj_kurumame, '[　| ]+$', '')), '、')) --メッセージ
		FROM dx_ve.tbi999009m t9009m --中古車車種表示設定
		LEFT anti JOIN ai21rep_ve_dx.tbv0232m t0232m --ａｉ２１車名コードＤＢ 
		ON t0232m.cd_hansya = t9009m.cd_hansya
		AND t0232m.cd_kaisya = t9009m.cd_kaisya
		AND t0232m.cd_syamei = t9009m.cd_ocsyamei
		WHERE t9009m.kn_syame IS NOT NULL
		GROUP BY t9009m.cd_hansya, t9009m.cd_kaisya
	) bt
	GROUP BY bt.cd_hansya, bt.cd_kaisya
	UNION ALL
	SELECT
		bt.cd_hansya, --販社コード
		bt.cd_kaisya, --会社コード
		CONCAT('※入金区分情報が変更されましたため、マスタ情報の設定をお願い致します<br />下記が対象の入金区分となります<br />※入金区分コード_入金区分名の順で記載しております<br />-------------<br />', GROUP_CONCAT(bt.mj_message, '<br /><br />'), '<br />-------------') mj_message --メッセージ
	FROM
		(
		SELECT
			tbv0208m.cd_hansya, --販社コード
			tbv0208m.cd_kaisya, --会社コード
			CONCAT('■新規追加された入金区分<br />', GROUP_CONCAT(CONCAT(tbv0208m.kb_nyuukin, '_', regexp_replace(tbv0208m.kj_nyuukinm, '　+$', '')), '、')) mj_message --メッセージ
		FROM
			ai21rep_ve_dx.tbv0208m tbv0208m --入金区分ＤＢ 
			LEFT ANTI
		JOIN dx_ve.tbi999013m tbi999013m --入金区分設定  
		ON
			tbv0208m.cd_hansya = tbi999013m.cd_hansya
			AND tbv0208m.cd_kaisya = tbi999013m.cd_kaisya
			AND tbv0208m.kb_nyuukin = tbi999013m.kb_nyuukin
		GROUP BY
			tbv0208m.cd_hansya,
			tbv0208m.cd_kaisya
	UNION ALL
	SELECT
			tbv0208m.cd_hansya, --販社コード
			tbv0208m.cd_kaisya, --会社コード
			CONCAT('■変更があった入金区分<br />', GROUP_CONCAT(CONCAT(regexp_replace(tbi999013m.kj_nyuukinm, '　+$', ''), '　→', regexp_replace(tbv0208m.kj_nyuukinm, '　+$', '')), '、')) mj_message --メッセージ
		FROM
			ai21rep_ve_dx.tbv0208m tbv0208m --入金区分ＤＢ
		INNER JOIN dx_ve.tbi999013m tbi999013m --入金区分設定  
		ON
			tbv0208m.cd_hansya = tbi999013m.cd_hansya
			AND tbv0208m.cd_kaisya = tbi999013m.cd_kaisya
			AND tbv0208m.kb_nyuukin = tbi999013m.kb_nyuukin
			AND regexp_replace(tbv0208m.kj_nyuukinm, '　+$', '') != regexp_replace(tbi999013m.kj_nyuukinm, '　+$', '')
		GROUP BY
			tbv0208m.cd_hansya,
			tbv0208m.cd_kaisya
	UNION ALL
		SELECT
			tbi999013m.cd_hansya, --販社コード
			tbi999013m.cd_kaisya, --会社コード
			CONCAT('■削除された入金区分<br />', GROUP_CONCAT(regexp_replace(tbi999013m.kj_nyuukinm, '　+$', ''), '、')) --メッセージ
		FROM
			dx_ve.tbi999013m tbi999013m --入金区分設定  LEFT ANTI
		JOIN ai21rep_ve_dx.tbv0208m tbv0208m --入金区分ＤＢ 
		ON
			tbv0208m.cd_hansya = tbi999013m.cd_hansya
			AND tbv0208m.cd_kaisya = tbi999013m.cd_kaisya
			AND tbv0208m.kb_nyuukin = tbi999013m.kb_nyuukin
		GROUP BY
			tbi999013m.cd_hansya,
			tbi999013m.cd_kaisya) bt
	GROUP BY
		bt.cd_hansya,
		bt.cd_kaisya	
) bt
GROUP BY bt.cd_hansya, bt.cd_kaisya
LIMIT 0;

-- [097/099] level=0 target=gold.vbi999009
-- Gold dependencies: none
-- Source file: 101_マスタメンテナンス/vbi999001-VBI999010_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi999009 AS
SELECT
	ROW_NUMBER() OVER(PARTITION BY tf001m.cd_hansya, tf001m.cd_kaisya order by CAST(tf001m.nu_symenarb AS int), tf001m.cd_ncsyamei) AS `No.`, --No
	tf001m.cd_hansya AS `販社コード`, --販社コード
	tf001m.cd_kaisya AS `会社コード`, --会社コード
	tf001m.cd_ncsyamei AS `車名コード`, --車名コード
	CONCAT(tf001m.kn_syame, '##', CAST(ROW_NUMBER() OVER(PARTITION BY tf001m.cd_hansya, tf001m.cd_kaisya order by CAST(tf001m.nu_symenarb AS int), tf001m.cd_ncsyamei) AS string), '##') AS `カナ車名`, --カナ車名
	CONCAT(tf001m.kj_kurumame, '##', CAST(ROW_NUMBER() OVER(PARTITION BY tf001m.cd_hansya, tf001m.cd_kaisya order by CAST(tf001m.nu_symenarb AS int), tf001m.cd_ncsyamei) AS string), '##') AS `漢字車名`, --漢字車名
	IF(t9008m.kb_tenji = 0, '×', IF(tf001m.kb_oem in('0', '3', '6'), '○', '×')) AS `表示可否`, --表示可否
	CAST(tf001m.nu_symenarb AS int) AS `車名並び順` --車名並び順
FROM ai21rep_ve_dx.tbbf001m tf001m --車名ＤＢ
LEFT JOIN dx_ve.tbi999008m t9008m --新車車種表示設定
ON t9008m.cd_hansya = tf001m.cd_hansya
AND t9008m.cd_kaisya = tf001m.cd_kaisya
AND t9008m.cd_ncsyamei = tf001m.cd_ncsyamei
WHERE tf001m.kn_syame IS NOT NULL
GROUP BY tf001m.cd_hansya, tf001m.cd_kaisya, tf001m.kn_syame, tf001m.cd_ncsyamei, tf001m.kj_kurumame, t9008m.kb_tenji, tf001m.kb_oem, tf001m.nu_symenarb
LIMIT 0;

-- [098/099] level=0 target=gold.VBI999010
-- Gold dependencies: none
-- Source file: 101_マスタメンテナンス/vbi999001-VBI999010_gold.sql

CREATE TABLE IF NOT EXISTS gold.VBI999010 AS
SELECT  
	ROW_NUMBER() OVER (PARTITION BY tbv0208m.cd_hansya, tbv0208m.cd_kaisya ORDER BY tbv0208m.kb_nyuukin ASC) AS `No.`, --番号
	tbv0208m.cd_hansya AS 販社コード, --販社コード
	tbv0208m.cd_kaisya AS 会社コード, --会社コード
	tbv0208m.kb_nyuukin AS 入金区分, --入金区分
	tbv0208m.kj_nyuukinm AS 入金区分名, --入金区分名
	IF(tbi999013m.cd_hansya IS NULL , IF(tbv0208m.kj_nyuukinm RLIKE '現金', '○', '×') ,IF(tbi999013m.kb_genkin='1', '○', '×')) AS 現金, --現金
	IF(tbi999013m.cd_hansya IS NULL , IF(tbv0208m.kj_nyuukinm RLIKE 'クレジット', '○', '×'),IF(tbi999013m.kb_crejcard='1', '○', '×')) AS クレジットカード --クレジットカード
FROM
	ai21rep_ve_dx.tbv0208m tbv0208m --入金区分ＤＢ
LEFT JOIN dx_ve.tbi999013m tbi999013m --入金区分設定 
ON tbv0208m.cd_hansya = tbi999013m.cd_hansya
	AND tbv0208m.cd_kaisya = tbi999013m.cd_kaisya
	AND tbv0208m.kb_nyuukin = tbi999013m.kb_nyuukin
LIMIT 0;

-- [099/099] level=0 target=gold.vbi999006
-- Gold dependencies: none
-- Source file: 999_入口/vbi999006_gold.sql

CREATE TABLE IF NOT EXISTS gold.vbi999006 AS
SELECT
         tbi999002m.cd_hanbaitn AS 販売店コード --販売店コード
        ,tbi999002m.mj_cyohyoid AS 帳票ID --帳票ID
        ,tbi999002m.mj_url AS URL --URL
        ,CONCAT(COALESCE(tbv0200m.kj_kaisyatn, ''), '(', tbi999002m.cd_hanbaitn, ')') AS 販売店名 --販売店名
        ,tbi999006m.mj_url AS マスタメンテナンスURL --マスタメンテナンスURL
        ,tbi999002m.kb_sakujo AS 削除フラグ --削除フラグ
    FROM dx_ve.tbi999002m tbi999002m --帳票情報
    LEFT JOIN (
        SELECT
             tbv0200m.cd_hanbaitn --販売店コード
            ,tbv0200m.kj_kaisyatn --販売店名
            ,ROW_NUMBER() OVER (PARTITION BY tbv0200m.cd_hanbaitn ORDER BY tbv0200m.dd_saisinup DESC) AS rn --選別
      FROM ai21rep_ve_dx.tbv0200m tbv0200m --tbv0200m
    ) tbv0200m
    ON tbi999002m.cd_hanbaitn = tbv0200m.cd_hanbaitn
    AND tbv0200m.rn = 1 --選別 = 0
    LEFT JOIN dx_ve.tbi999006m tbi999006m --マスタメンテナンス情報
    ON tbi999002m.`cd_hanbaitn` = tbi999006m.cd_hanbaitn
    AND tbi999006m.kb_sakujo = 0 --いいえ削除フラグ
    --WHERE tbi999002m.削除フラグ = 0
LIMIT 0;



CREATE TABLE IF NOT EXISTS gold.vbi999005 AS
SELECT
    ROW_NUMBER() OVER(PARTITION BY t0232m.cd_hansya, t0232m.cd_kaisya ORDER BY CAST(t0232m.mj_sortjyun AS int), t0232m.cd_syamei) AS `No.`
    , t0232m.cd_hansya AS `販社コード`
    , t0232m.cd_kaisya AS `会社コード`
    , t0232m.cd_syamei AS `車名コード`
    , CONCAT(t0232m.kj_syamei, '##', CAST(ROW_NUMBER() OVER(PARTITION BY t0232m.cd_hansya, t0232m.cd_kaisya ORDER BY CAST(t0232m.mj_sortjyun AS int), t0232m.cd_syamei) AS string), '##') AS `車名（漢字）`
    , CONCAT(t0232m.mj_syamei, '##', CAST(ROW_NUMBER() OVER(PARTITION BY t0232m.cd_hansya, t0232m.cd_kaisya ORDER BY CAST(t0232m.mj_sortjyun AS int), t0232m.cd_syamei) AS string), '##') AS `車名（カナ）`
    , IF(t9009m.kb_tenji = 0, '×', '○') AS `表示可否`
    , CAST(t0232m.mj_sortjyun AS int) AS `ソート順`
FROM ai21rep_ve_dx.tbv0232m t0232m
LEFT JOIN dx_ve.tbi999009m t9009m
    ON t9009m.cd_hansya = t0232m.cd_hansya
    AND t9009m.cd_kaisya = t0232m.cd_kaisya
    AND t9009m.cd_ocsyamei = t0232m.cd_syamei
WHERE t0232m.mj_syamei IS NOT NULL
GROUP BY t0232m.cd_hansya, t0232m.cd_kaisya, t0232m.cd_syamei, t0232m.kj_syamei, t0232m.mj_syamei, t9009m.kb_tenji, t0232m.mj_sortjyun
LIMIT 0;

CREATE TABLE IF NOT EXISTS gold.vbi013001_en AS
SELECT
    main_table.su_store
    , main_table.cd_hansya_kaisya_tenpo
    , main_table.cd_hansya_kaisya_zon_tenpo
    , main_table.cd_hansya
    , main_table.cd_kaisya
    , main_table.cd_tenpo
    , main_table.kj_tenpomei
    , main_table.kj_tentanms
    , IF(main_table.zone_name IS NULL OR regexp_replace(main_table.zone_name, '[ 　]+', '') = '','999999',IF(main_table.cd_zon IS NULL OR regexp_replace(main_table.cd_zon, '[ 　]+', '') = '','999998',main_table.cd_zon)) AS cd_zon
    , main_table.cd_nczon
    , main_table.kj_zonmei
    , main_table.zone_name
    , main_table.mj_sortjyun
FROM(
    SELECT
        1 AS su_store
        , CONCAT(tbv201m.cd_hansya, tbv201m.cd_kaisya, tbv201m.cd_tenpo) AS cd_hansya_kaisya_tenpo
        , IF(tntenpo.cd_zon IS NOT NULL,CONCAT(tbv201m.cd_hansya, tbv201m.cd_kaisya, tntenpo.cd_zon, tbv201m.cd_tenpo),CONCAT(tbv201m.cd_hansya, tbv201m.cd_kaisya, tbv003m.cd_zon, tbv201m.cd_tenpo)) AS cd_hansya_kaisya_zon_tenpo
        , tbv201m.cd_hansya
        , tbv201m.cd_kaisya
        , tbv201m.cd_tenpo
        , tbv201m.kj_tenpomei
        , tbv201m.kj_tentanms
        , NVL(tntenpo.cd_zon, tbv003m.cd_zon) AS cd_zon
        , NVL(tntenpo.cd_zon, tbv0047m.cd_nczon) AS cd_nczon
        , NVL(tbv003m1.kj_zonmei, tbv003m.kj_zonmei) AS kj_zonmei
        , CASE
            WHEN tbv003m1.kj_zonmei IS NOT NULL AND(LEFT (CAST (tbv003m1.kj_zonmei AS STRING), 3) = 'ト' OR LEFT (CAST (tbv003m1.kj_zonmei AS STRING), 3) = 'レ') AND RIGHT (CAST (tbv003m1.kj_zonmei AS STRING), 6) = 'エ統'
            THEN
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SUBSTR(CAST (tbv003m1.kj_zonmei AS STRING), 1, 9), 'レ', 'L-'), 'ト', 'T-'), '０', '0'), '１', '1'), '２', '2'), '３', '3'), '４', '4'), '５', '5'), '６', '6'), '７', '7'), '８', '8'), '９', '9')
            WHEN tbv003m1.kj_zonmei IS NOT NULL
            THEN TRIM(REPLACE (CAST (tbv003m1.kj_zonmei AS STRING), '　', ' '))
            WHEN (LEFT (CAST (tbv003m.kj_zonmei AS STRING), 3) = 'ト' OR LEFT (CAST (tbv003m.kj_zonmei AS STRING), 3) = 'レ') AND RIGHT (CAST (tbv003m.kj_zonmei AS STRING), 6) = 'エ統'
            THEN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SUBSTR(CAST (tbv003m.kj_zonmei AS STRING), 1, 9), 'レ', 'L-'), 'ト', 'T-'), '０', '0'), '１', '1'), '２', '2'), '３', '3'), '４', '4'), '５', '5' ), '６', '6'), '７', '7'), '８', '8'), '９', '9')
            ELSE TRIM (REPLACE (CAST (tbv003m.kj_zonmei AS STRING), '　', ' '))
        END AS zone_name
        , RANK() OVER (PARTITION BY tbv201m.cd_hansya,tbv201m.cd_kaisya ORDER BY NVL(tntenpo.cd_zon, tbv003m.cd_zon), tbi999003m.mj_sortjyun , tbv201m.cd_tenpo) AS mj_sortjyun
    FROM ai21rep_ve_dx.tbv0201m tbv201m
    LEFT JOIN dx_ve.tbi999003m tbi999003m
        ON tbv201m.cd_hansya = tbi999003m.cd_hansya
        AND tbv201m.cd_kaisya = tbi999003m.cd_kaisya
        AND tbv201m.cd_tenpo = tbi999003m.cd_tenpo
        AND tbi999003m.mj_cyohyoid = "013"
    LEFT JOIN ai21rep_ve_dx.tbv0047m tbv0047m
        ON tbv0047m.cd_hansya = '03601'
        AND tbv0047m.cd_kaisya = '01'
        AND tbv0047m.cd_tenpo = tbv201m.cd_tenpo
    LEFT JOIN ai21rep_ve_dx.tbv0033m tbv003m
        ON tbv003m.cd_hansya = '03601'
        AND tbv003m.cd_kaisya = '01'
        AND tbv003m.cd_zon = tbv0047m.cd_nczon
        AND tbv003m.kb_syohin = '2'
    LEFT JOIN dx_ve.tbi002003m tntenpo
        ON tntenpo.cd_hansya = '03601'
        AND tntenpo.cd_kaisya = '01'
        AND tntenpo.cd_tenpo = tbv201m.cd_tenpo
    LEFT JOIN ai21rep_ve_dx.tbv0033m tbv003m1
        ON tbv003m1.cd_hansya = '03601'
        AND tbv003m1.cd_kaisya = '01'
        AND tntenpo.cd_zon = tbv003m1.cd_zon
    WHERE
        tbi999003m.kb_tenji = 1
        AND tbv201m.kj_tenpomei NOT LIKE '%廃）%'
        AND tbv201m.cd_hansya = '03601'
        AND tbv201m.cd_kaisya = '01'
        AND (tbv003m.cd_zon IN ('01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','30','31','32','33','60','90')
        OR SUBSTRING(tbv003m.cd_zon, 1, 3) = 'TK_')
        AND tbv201m.cd_tenpo NOT IN ('T01','T02','T03','T04','T05','T06','T07','T08','T09','T10','T11','T12','T13','T14','T15','L01','L02','L03','L04')
    UNION ALL
    SELECT
        1 AS su_store
        , CONCAT(tbv201m.cd_hansya, tbv201m.cd_kaisya, tbv201m.cd_tenpo) AS cd_hansya_kaisya_tenpo
        , IF(tntenpo.cd_zon IS NOT NULL,CONCAT(tbv201m.cd_hansya, tbv201m.cd_kaisya, tntenpo.cd_zon, tbv201m.cd_tenpo),CONCAT(tbv201m.cd_hansya, tbv201m.cd_kaisya, tbv003m.cd_zon, tbv201m.cd_tenpo)) AS cd_hansya_kaisya_zon_tenpo
        , tbv201m.cd_hansya
        , tbv201m.cd_kaisya
        , tbv201m.cd_tenpo
        , tbv201m.kj_tenpomei
        , tbv201m.kj_tentanms
        , NVL(tntenpo.cd_zon,tbv003m.cd_zon) AS cd_zon
        , NVL(tntenpo.cd_zon,tbv0047m.cd_nczon) AS cd_nczon
        , NVL(tbv003m1.kj_zonmei, tbv003m.kj_zonmei) AS kj_zonmei
        , NVL(tbv003m1.kj_zonmei, tbv003m.kj_zonmei) AS zone_name
        , RANK() OVER (PARTITION BY tbv201m.cd_hansya,tbv201m.cd_kaisya ORDER BY NVL(tntenpo.cd_zon, tbv003m.cd_zon), tbi999003m.mj_sortjyun , tbv201m.cd_tenpo) AS mj_sortjyun
    FROM ai21rep_ve_dx.tbv0201m tbv201m
    LEFT JOIN dx_ve.tbi999003m tbi999003m
        ON tbv201m.cd_hansya = tbi999003m.cd_hansya
        AND tbv201m.cd_kaisya = tbi999003m.cd_kaisya
        AND tbv201m.cd_tenpo = tbi999003m.cd_tenpo
        AND tbi999003m.mj_cyohyoid = "013"
    LEFT JOIN ai21rep_ve_dx.tbv0047m tbv0047m
        ON tbv0047m.cd_hansya = tbv201m.cd_hansya
        AND tbv0047m.cd_kaisya = tbv201m.cd_kaisya
        AND tbv0047m.cd_tenpo = tbv201m.cd_tenpo
    LEFT JOIN ai21rep_ve_dx.tbv0033m tbv003m
        ON tbv003m.cd_hansya = tbv0047m.cd_hansya
        AND tbv003m.cd_kaisya = tbv0047m.cd_kaisya
        AND tbv003m.cd_zon = tbv0047m.cd_nczon
        AND tbv003m.kb_syohin = '2'
    LEFT JOIN dx_ve.tbi002003m tntenpo
        ON tntenpo.cd_hansya = tbv201m.cd_hansya
        AND tntenpo.cd_kaisya = tbv201m.cd_kaisya
        AND tntenpo.cd_tenpo = tbv201m.cd_tenpo
    LEFT JOIN ai21rep_ve_dx.tbv0033m tbv003m1
        ON tntenpo.cd_hansya = tbv003m1.cd_hansya
        AND tntenpo.cd_kaisya = tbv003m1.cd_kaisya
        AND tntenpo.cd_zon = tbv003m1.cd_zon
    WHERE
        tbi999003m.kb_tenji = 1
        AND tbv201m.cd_hansya <> '03601'
        AND tbv201m.kj_tenpomei NOT LIKE '%廃）%'
) main_table
LIMIT 0;

CREATE TABLE IF NOT EXISTS gold.vbi013001 AS
SELECT
    su_store AS `店舗数`
    , cd_hansya_kaisya_tenpo AS `販社会社店舗コード`
    , cd_hansya_kaisya_zon_tenpo AS `販社会社ゾーン店舗コード`
    , cd_hansya AS `販社コード`
    , cd_kaisya AS `会社コード`
    , cd_tenpo AS `店舗コード`
    , kj_tenpomei AS `店舗名称`
    , kj_tentanms AS `店舗短縮名称`
    , cd_zon AS `ゾーンコード`
    , cd_nczon AS `ゾーンコード1`
    , kj_zonmei AS `ゾーン名`
    , zone_name AS `ゾーン名(略)`
    , mj_sortjyun AS `ソート順`
FROM dx_ve.vbi013001_en vbi013001
LIMIT 0;

CREATE TABLE IF NOT EXISTS gold.vbi013002 AS
SELECT
    v2001.zone_name AS `エリア統括部と店舗`
    , 'ゾーン名称' AS `区分名称`
    , '1' AS `区分コード`
    , v2001.cd_hansya AS `販社コード`
    , v2001.cd_kaisya AS `会社コード`
    , v2001.cd_zon AS `ゾーンコード`
    , NULL AS `店舗コード`
    , NULL AS `販社会社店舗コード`
    , NULL AS `販社会社ゾーン店舗コード`
    , SUM(v2004.su_pieces) AS `件数`
    , SUM(v2004.su_amount) AS `金額`
    , CAST(v2001.cd_zon AS INT) AS `ソート順`
FROM dx_ve.vbi013001_en v2001
LEFT JOIN dx_ve.vbi013004_en v2004
    ON v2001.cd_hansya = v2004.cd_hansya
    AND v2001.cd_kaisya = v2004.cd_kaisya
    AND v2001.cd_tenpo = v2004.cd_jytyuten
GROUP BY
    エリア統括部と店舗,
    区分名称,
    区分コード,
    販社コード,
    会社コード,
    ゾーンコード
UNION ALL
SELECT
    v2001.kj_tentanms AS `エリア統括部と店舗`
    , '店舗略称' AS `区分名称`
    , '2' AS `区分コード`
    , v2001.cd_hansya AS `販社コード`
    , v2001.cd_kaisya AS `会社コード`
    , v2001.cd_zon AS `ゾーンコード`
    , v2001.cd_tenpo AS `店舗コード`
    , v2001.cd_hansya_kaisya_tenpo AS `販社会社店舗コード`
    , v2001.cd_hansya_kaisya_zon_tenpo AS `販社会社ゾーン店舗コード`
    , SUM(su_pieces) AS `件数`
    , SUM(su_amount) AS `金額`
    , v2001.mj_sortjyun AS `ソート順`
FROM dx_ve.vbi013001_en v2001
LEFT JOIN dx_ve.vbi013004_en v2004
    ON v2001.cd_hansya = v2004.cd_hansya
    AND v2001.cd_kaisya = v2004.cd_kaisya
    AND v2001.cd_tenpo = v2004.cd_jytyuten
GROUP BY
    `エリア統括部と店舗`,
    `区分名称`,
    `区分コード`,
    `販社コード`,
    `会社コード`,
    `ゾーンコード`,
    `店舗コード`,
    `販社会社店舗コード`,
    `販社会社ゾーン店舗コード`,
    `ソート順`
LIMIT 0;

CREATE TABLE IF NOT EXISTS gold.vbi013003 AS
WITH months AS (
  SELECT 1 AS month
  UNION ALL
  SELECT 2 AS month
  UNION ALL
  SELECT 3 AS month
  UNION ALL
  SELECT 4 AS month
  UNION ALL
  SELECT 5 AS month
  UNION ALL
  SELECT 6 AS month
  UNION ALL
  SELECT 7 AS month
  UNION ALL
  SELECT 8 AS month
  UNION ALL
  SELECT 9 AS month
  UNION ALL
  SELECT 10 AS month
  UNION ALL
  SELECT 11 AS month
  UNION ALL
  SELECT 12 AS month
)
SELECT
  months.month AS `月`
  , tbg7005m.cd_hansya AS `販社コード`
  , tbg7005m.cd_kaisya AS `会社コード`
  , tbg7005m.cd_hansya || tbg7005m.cd_kaisya || tbg7005m.cd_tenpo AS `販社会社店舗コード`
  , SUM(CASE
        WHEN tbg7005m.nu_yyyy = YEAR(MONTHS_SUB(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP() ,'JST') ,4)) -1 AND tbg7005m.cd_kanjyou = '10402  '
          THEN
            CASE
              WHEN months.month = 4 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 - tbg7005m.ki_toykas01
              WHEN months.month = 5 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02
              WHEN months.month = 6 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03
              WHEN months.month = 7 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04
              WHEN months.month = 8 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05
              WHEN months.month = 9 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06
              WHEN months.month = 10 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07
              WHEN months.month = 11 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 + tbg7005m.ki_toykar08 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07 - tbg7005m.ki_toykas08
              WHEN months.month = 12 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 + tbg7005m.ki_toykar08 + tbg7005m.ki_toykar09 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07 - tbg7005m.ki_toykas08 - tbg7005m.ki_toykas09
              WHEN months.month = 1 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 + tbg7005m.ki_toykar08 + tbg7005m.ki_toykar09 + tbg7005m.ki_toykar10 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07 - tbg7005m.ki_toykas08 - tbg7005m.ki_toykas09 - tbg7005m.ki_toykas10
              WHEN months.month = 2 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 + tbg7005m.ki_toykar08 + tbg7005m.ki_toykar09 + tbg7005m.ki_toykar10 + tbg7005m.ki_toykar11 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07 - tbg7005m.ki_toykas08 - tbg7005m.ki_toykas09 - tbg7005m.ki_toykas10 - tbg7005m.ki_toykas11
              WHEN months.month = 3 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 + tbg7005m.ki_toykar08 + tbg7005m.ki_toykar09 + tbg7005m.ki_toykar10 + tbg7005m.ki_toykar11 + tbg7005m.ki_toykar12 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07 - tbg7005m.ki_toykas08 - tbg7005m.ki_toykas09 - tbg7005m.ki_toykas10 - tbg7005m.ki_toykas11 - tbg7005m.ki_toykas12
  END END)/1000000 AS 前年売掛金残高,
  SUM(CASE
        WHEN tbg7005m.nu_yyyy = YEAR(MONTHS_SUB(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP() ,'JST') ,4)) -1 AND tbg7005m.cd_kanjyou BETWEEN '50301  ' AND '50303  '
          THEN
            CASE
              WHEN months.month = 4 THEN tbg7005m.ki_toykas01 - tbg7005m.ki_toykar01
              WHEN months.month = 5 THEN tbg7005m.ki_toykas02 - tbg7005m.ki_toykar02
              WHEN months.month = 6 THEN tbg7005m.ki_toykas03 - tbg7005m.ki_toykar03
              WHEN months.month = 7 THEN tbg7005m.ki_toykas04 - tbg7005m.ki_toykar04
              WHEN months.month = 8 THEN tbg7005m.ki_toykas05 - tbg7005m.ki_toykar05
              WHEN months.month = 9 THEN tbg7005m.ki_toykas06 - tbg7005m.ki_toykar06
              WHEN months.month = 10 THEN tbg7005m.ki_toykas07 - tbg7005m.ki_toykar07
              WHEN months.month = 11 THEN tbg7005m.ki_toykas08 - tbg7005m.ki_toykar08
              WHEN months.month = 12 THEN tbg7005m.ki_toykas09 - tbg7005m.ki_toykar09
              WHEN months.month = 1 THEN  tbg7005m.ki_toykas10 - tbg7005m.ki_toykar10
              WHEN months.month = 2 THEN  tbg7005m.ki_toykas11 - tbg7005m.ki_toykar11
              WHEN months.month = 3 THEN  tbg7005m.ki_toykas12 - tbg7005m.ki_toykar12
  END END)/1000000 AS 前年売上額,
  SUM(CASE
        WHEN tbg7005m.nu_yyyy = YEAR(MONTHS_SUB(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP() ,'JST') ,4)) AND tbg7005m.cd_kanjyou = '10402  ' AND ((MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')) > 4 AND months.month > 3 AND months.month < MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'))) OR (MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')) <= 4 AND (months.month > 3 OR months.month < MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')))))
          THEN
            CASE
              WHEN months.month = 4 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 - tbg7005m.ki_toykas01
              WHEN months.month = 5 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02
              WHEN months.month = 6 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03
              WHEN months.month = 7 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04
              WHEN months.month = 8 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05
              WHEN months.month = 9 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06
              WHEN months.month = 10 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07
              WHEN months.month = 11 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 + tbg7005m.ki_toykar08 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07 - tbg7005m.ki_toykas08
              WHEN months.month = 12 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 + tbg7005m.ki_toykar08 + tbg7005m.ki_toykar09 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07 - tbg7005m.ki_toykas08 - tbg7005m.ki_toykas09
              WHEN months.month = 1 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 + tbg7005m.ki_toykar08 + tbg7005m.ki_toykar09 + tbg7005m.ki_toykar10 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07 - tbg7005m.ki_toykas08 - tbg7005m.ki_toykas09 - tbg7005m.ki_toykas10
              WHEN months.month = 2 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 + tbg7005m.ki_toykar08 + tbg7005m.ki_toykar09 + tbg7005m.ki_toykar10 + tbg7005m.ki_toykar11 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07 - tbg7005m.ki_toykas08 - tbg7005m.ki_toykas09 - tbg7005m.ki_toykas10 - tbg7005m.ki_toykas11
              WHEN months.month = 3 THEN tbg7005m.ki_toyjkksy + tbg7005m.ki_toykar01 + tbg7005m.ki_toykar02 + tbg7005m.ki_toykar03 + tbg7005m.ki_toykar04 + tbg7005m.ki_toykar05 + tbg7005m.ki_toykar06 + tbg7005m.ki_toykar07 + tbg7005m.ki_toykar08 + tbg7005m.ki_toykar09 + tbg7005m.ki_toykar10 + tbg7005m.ki_toykar11 + tbg7005m.ki_toykar12 - tbg7005m.ki_toykas01 - tbg7005m.ki_toykas02 - tbg7005m.ki_toykas03 - tbg7005m.ki_toykas04 - tbg7005m.ki_toykas05 - tbg7005m.ki_toykas06 - tbg7005m.ki_toykas07 - tbg7005m.ki_toykas08 - tbg7005m.ki_toykas09 - tbg7005m.ki_toykas10 - tbg7005m.ki_toykas11 - tbg7005m.ki_toykas12
  END END)/1000000 AS 売掛金残高,
  SUM(CASE
        WHEN tbg7005m.nu_yyyy = YEAR(MONTHS_SUB(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP() ,'JST') ,4)) AND tbg7005m.cd_kanjyou BETWEEN '50301  ' AND '50303  ' AND ((MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')) > 4 AND months.month > 3 AND months.month < MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'))) OR (MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')) <= 4 AND (months.month > 3 OR months.month < MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')))))
          THEN
            CASE
              WHEN months.month = 4 THEN tbg7005m.ki_toykas01 - tbg7005m.ki_toykar01
              WHEN months.month = 5 THEN tbg7005m.ki_toykas02 - tbg7005m.ki_toykar02
              WHEN months.month = 6 THEN tbg7005m.ki_toykas03 - tbg7005m.ki_toykar03
              WHEN months.month = 7 THEN tbg7005m.ki_toykas04 - tbg7005m.ki_toykar04
              WHEN months.month = 8 THEN tbg7005m.ki_toykas05 - tbg7005m.ki_toykar05
              WHEN months.month = 9 THEN tbg7005m.ki_toykas06 - tbg7005m.ki_toykar06
              WHEN months.month = 10 THEN tbg7005m.ki_toykas07 - tbg7005m.ki_toykar07
              WHEN months.month = 11 THEN tbg7005m.ki_toykas08 - tbg7005m.ki_toykar08
              WHEN months.month = 12 THEN tbg7005m.ki_toykas09 - tbg7005m.ki_toykar09
              WHEN months.month = 1 THEN  tbg7005m.ki_toykas10 - tbg7005m.ki_toykar10
              WHEN months.month = 2 THEN  tbg7005m.ki_toykas11 - tbg7005m.ki_toykar11
              WHEN months.month = 3 THEN  tbg7005m.ki_toykas12 - tbg7005m.ki_toykar12
  END END)/1000000 AS 売上額
FROM
  months months,ai21rep_ve_dx.tbg7005m tbg7005m
INNER JOIN dx_ve.vbi013001_en vbi013001
    ON vbi013001.cd_hansya = tbg7005m.cd_hansya
    AND vbi013001.cd_kaisya = tbg7005m.cd_kaisya
    AND vbi013001.cd_tenpo = tbg7005m.cd_tenpo
WHERE
  (tbg7005m.cd_hansya <> '03601' OR tbg7005m.cd_kaisya <> '01' OR tbg7005m.cd_tenpo <> 'ZZZ')
GROUP BY
  months.month,
  tbg7005m.cd_hansya,
  tbg7005m.cd_kaisya,
  tbg7005m.cd_tenpo
LIMIT 0;


CREATE TABLE IF NOT EXISTS gold.vbi013004_en AS
SELECT
    tbbc017g.cd_hansya
    , tbbc017g.cd_kaisya
    , IF(LEFT(tbbc017g.no_cyumon, 3) = 'TAD' AND LENGTH(tbbc017g_2.no_min_denpyo) > 0,LEFT(tbbc017g_2.no_min_denpyo, 3),tbbc017g.cd_jytyuten) AS cd_jytyuten
    , IF(LEFT(tbbc017g.no_cyumon, 3) = 'TAD' AND LENGTH(tbbc017g_2.no_min_denpyo) > 0,tbbc017g.cd_hansya || tbbc017g.cd_kaisya || LEFT(tbbc017g_2.no_min_denpyo, 3),tbbc017g.cd_hansya || tbbc017g.cd_kaisya || tbbc017g.cd_jytyuten) AS cd_hansya_kaisya_jytyuten
    , IF(MONTH(tbbc017g.dd_jucyu) = MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')),1,0) AS su_jucyu
    , IF(MONTH(tbbc017g.dd_touroku) = MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')),1,0) AS su_touroku
    , IF(MONTH(tbbc017g.dd_touroku) = MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')) AND tbbc020g.su_sitadori = 0,1,0) AS no_trade_in_vehicles_registered_this_month
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_urikzumi IS NULL,1,0) AS currently_registered_but_uncollected_cases
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_urikzumi IS NULL,tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk,0) AS currently_registered_uncollected_amount
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_urikzumi IS NULL AND TRUNC(tbbc017g.dd_touroku, 'month') = TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'month'),1,0) AS registered_but_uncollected_items_from_the_previous_month
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_urikzumi IS NULL AND TRUNC(tbbc017g.dd_touroku, 'month') = TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'month'),tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk,0) AS uncollected_amount_registered_in_the_previous_month
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_urikzumi IS NULL AND (TRUNC(tbbc017g.dd_touroku, 'year') < TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'year') OR (TRUNC(tbbc017g.dd_touroku, 'year') = TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'year') AND TRUNC(tbbc017g.dd_touroku, 'month') < TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'month'))),1,0) AS uncollected_cases_registered_two_months_prior
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_urikzumi IS NULL AND (TRUNC(tbbc017g.dd_touroku, 'year') < TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'year') OR (TRUNC(tbbc017g.dd_touroku, 'year') = TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'year') AND TRUNC(tbbc017g.dd_touroku, 'month') < TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'month'))),tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk,0) AS uncollected_amount_registered_two_months_prior
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_urikzumi IS NULL,1,NULL) AS su_pieces
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_urikzumi IS NULL,(tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) / 1000,NULL) AS su_amount
    , vbi013001.mj_sortjyun
FROM ai21rep_ve_dx.tbbc017g tbbc017g
LEFT JOIN ai21rep_ve_dx.tbbc020g tbbc020g
    ON tbbc017g.cd_hansya = tbbc020g.cd_hansya
    AND tbbc017g.cd_kaisya = tbbc020g.cd_kaisya
    AND tbbc017g.no_cyumon = tbbc020g.no_cyumon
    AND TRIM(tbbc017g.no_cyumoned) = TRIM(tbbc020g.no_cyumoned)
LEFT JOIN (
    SELECT
        tbbc017g.cd_hansya
        , tbbc017g.cd_kaisya
        , tbbc017g.cd_jytyuten
    FROM
        ai21rep_ve_dx.tbbc017g tbbc017g
    LEFT JOIN ai21rep_ve_dx.tbbc020g tbbc020g
        ON tbbc017g.cd_hansya = tbbc020g.cd_hansya
        AND tbbc017g.cd_kaisya = tbbc020g.cd_kaisya
        AND tbbc017g.no_cyumon = tbbc020g.no_cyumon
        AND TRIM(tbbc017g.no_cyumoned) = TRIM(tbbc020g.no_cyumoned)
    WHERE tbbc017g.dd_touroku IS NOT NULL
        AND (tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) = 0
        AND TRUNC(tbbc017g.dd_urikzumi, 'month') = TRUNC(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 'month')
    GROUP BY
        tbbc017g.cd_hansya,
        tbbc017g.cd_kaisya,
        tbbc017g.cd_jytyuten) tbbc017g_1
    ON tbbc017g.cd_hansya = tbbc017g_1.cd_hansya
    AND tbbc017g.cd_kaisya = tbbc017g_1.cd_kaisya
    AND tbbc017g.cd_jytyuten = tbbc017g_1.cd_jytyuten
    LEFT JOIN (
    SELECT
         tbbc017g.cd_hansya
        ,tbbc017g.cd_kaisya
        ,tbbc017g.no_cyumon
        ,tbbc017g.no_cyumoned
        ,MIN(tbg8014m.no_denpyo) AS no_min_denpyo
    FROM ai21rep_ve_dx.tbg8014m tbg8014m
    RIGHT JOIN ai21rep_ve_dx.tbbc017g tbbc017g
        ON tbg8014m.cd_hansya = tbbc017g.cd_hansya
        AND tbg8014m.cd_kaisya = tbbc017g.cd_kaisya
        AND TRIM(tbg8014m.no_cyumon) = (TRIM(tbbc017g.no_cyumon) || TRIM(tbbc017g.no_cyumoned))
        AND tbg8014m.kb_urinyuki = '2'
        AND tbg8014m.kb_nyukkanr = '01'
    GROUP BY
         tbbc017g.cd_hansya
        ,tbbc017g.cd_kaisya
        ,tbbc017g.no_cyumon
        ,tbbc017g.no_cyumoned
) tbbc017g_2
ON tbbc017g_2.cd_hansya = tbbc017g.cd_hansya
AND tbbc017g_2.cd_kaisya = tbbc017g.cd_kaisya
AND tbbc017g_2.no_cyumon = tbbc017g.no_cyumon
AND tbbc017g_2.no_cyumoned = tbbc017g.no_cyumoned
INNER JOIN dx_ve.vbi013001_en vbi013001
    ON vbi013001.cd_hansya = tbbc017g.cd_hansya
    AND vbi013001.cd_kaisya = tbbc017g.cd_kaisya
    AND vbi013001.cd_tenpo = IF(LEFT(tbbc017g.no_cyumon, 3) = 'TAD' AND LENGTH(tbbc017g_2.no_min_denpyo) > 0,LEFT(tbbc017g_2.no_min_denpyo, 3),tbbc017g.cd_jytyuten)
WHERE tbbc017g.dd_torikesi IS NULL
    AND (dd_torotrkk IS NULL OR (dd_torotrkk IS NOT NULL AND (tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) != 0))
    AND LEFT(CAST (tbbc017g.kb_uriage AS STRING), 1) = '1'
    AND ISNOTTRUE((tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) = 0
        AND((tbbc017g.dd_touroku IS NOT NULL
            AND tbbc017g.dd_nosya < DATE '2023-03-01'
            AND (tbbc017g.dd_urikzumi IS NULL OR tbbc017g.dd_urikzumi < DATE '2024-03-01'))
        OR (tbbc017g.dd_nosya IS NULL AND tbbc017g.dd_touroku < DATE '2023-03-01')
            OR tbbc017g.dd_urikzumi < DATE '2024-03-01'
            OR (tbbc017g.dd_touroku IS NULL AND tbbc017g.dd_jucyu < DATE '2020-12-01')))
LIMIT 0;

CREATE TABLE IF NOT EXISTS gold.vbi013005 AS
SELECT
    tbbc017g.cd_hansya AS `販社コード`
    , tbbc017g.cd_kaisya AS `会社コード`
    , IF(LEFT(tbbc017g.no_cyumon, 3) = 'TAD' AND LENGTH(tbbc017g_1.no_min_denpyo) > 0,tbbc017g.cd_hansya || tbbc017g.cd_kaisya || LEFT(tbbc017g_1.no_min_denpyo, 3),tbbc017g.cd_hansya || tbbc017g.cd_kaisya || tbbc017g.cd_jytyuten) AS `販社会社店舗コード`
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND (tbbc017g.dd_urikzumi >= TRUNC(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 'MM') OR tbbc017g.dd_urikzumi IS NULL),1,0) AS `登録済件数`
    , IF(COALESCE(tbbc020g.su_sitadori, 0) = 0 AND tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND (tbbc017g.dd_urikzumi >= TRUNC(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 'MM') OR tbbc017g.dd_urikzumi IS NULL),1,0) AS `下取車なし総件数`
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbbc017g.dd_urikzumi IS NULL AND (tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) != 0,1,0) AS `未回収総件数`
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbbc017g.dd_urikzumi IS NULL AND (tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) != 0,tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk,0) AS `未回収総金額`
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbbc017g.dd_urikzumi IS NULL AND (tbbc020g.ki_genkhasg - tbbc020g.ki_genknykg) != 0,1,0) AS `未回収現金総件数`
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbbc017g.dd_urikzumi IS NULL AND (tbbc020g.ki_genkhasg - tbbc020g.ki_genknykg) != 0,tbbc020g.ki_genkhasg - tbbc020g.ki_genknykg,0) AS `未回収現金総金額`
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbbc017g.dd_urikzumi IS NULL AND (tbbc020g.ki_sitahasg - tbbc020g.ki_sitanykg) != 0,1,0) AS `未回収下取総件数`
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbbc017g.dd_urikzumi IS NULL AND (tbbc020g.ki_sitahasg - tbbc020g.ki_sitanykg) != 0,tbbc020g.ki_sitahasg - tbbc020g.ki_sitanykg,0) AS `未回収下取総金額`
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND (tbbc017g.dd_urikzumi >= TRUNC(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 'MM') OR tbbc017g.dd_urikzumi IS NULL) AND tbbc017g.dd_nosya IS NULL,1,0) AS `登録済未納車件数`
FROM ai21rep_ve_dx.tbbc017g tbbc017g
LEFT JOIN (
    SELECT
         tbbc017g.cd_hansya
        ,tbbc017g.cd_kaisya
        ,tbbc017g.no_cyumon
        ,tbbc017g.no_cyumoned
        ,MIN(tbg8014m.no_denpyo) AS no_min_denpyo
    FROM ai21rep_ve_dx.tbg8014m tbg8014m
    RIGHT JOIN ai21rep_ve_dx.tbbc017g tbbc017g
        ON tbg8014m.cd_hansya = tbbc017g.cd_hansya
        AND tbg8014m.cd_kaisya = tbbc017g.cd_kaisya
        AND TRIM(tbg8014m.no_cyumon) = (TRIM(tbbc017g.no_cyumon) || TRIM(tbbc017g.no_cyumoned))
        AND tbg8014m.kb_urinyuki = '2'
        AND tbg8014m.kb_nyukkanr = '01'
    GROUP BY
         tbbc017g.cd_hansya
        ,tbbc017g.cd_kaisya
        ,tbbc017g.no_cyumon
        ,tbbc017g.no_cyumoned
) tbbc017g_1
ON tbbc017g_1.cd_hansya = tbbc017g.cd_hansya
AND tbbc017g_1.cd_kaisya = tbbc017g.cd_kaisya
AND tbbc017g_1.no_cyumon = tbbc017g.no_cyumon
AND tbbc017g_1.no_cyumoned = tbbc017g.no_cyumoned
INNER JOIN dx_ve.vbi013001_en vbi013001
    ON vbi013001.cd_hansya = tbbc017g.cd_hansya
    AND vbi013001.cd_kaisya = tbbc017g.cd_kaisya
    AND vbi013001.cd_tenpo = IF(LEFT(tbbc017g.no_cyumon, 3) = 'TAD' AND LENGTH(tbbc017g_1.no_min_denpyo) > 0,LEFT(tbbc017g_1.no_min_denpyo, 3),tbbc017g.cd_jytyuten)
LEFT JOIN ai21rep_ve_dx.tbbc020g tbbc020g
    ON tbbc017g.cd_hansya = tbbc020g.cd_hansya
    AND tbbc017g.cd_kaisya = tbbc020g.cd_kaisya
    AND tbbc017g.no_cyumon = tbbc020g.no_cyumon
    AND TRIM(tbbc017g.no_cyumoned) = TRIM(tbbc020g.no_cyumoned)
WHERE tbbc017g.dd_torikesi IS NULL
    AND (dd_torotrkk IS NULL OR (dd_torotrkk IS NOT NULL AND (tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) != 0))
    AND LEFT(CAST (tbbc017g.kb_uriage AS STRING), 1) = '1'
    AND ISNOTTRUE(
        (tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) = 0
        AND((tbbc017g.dd_touroku IS NOT NULL
            AND tbbc017g.dd_nosya < DATE '2023-03-01'
            AND (tbbc017g.dd_urikzumi IS NULL OR tbbc017g.dd_urikzumi < DATE '2024-03-01'))
        OR (tbbc017g.dd_nosya IS NULL AND tbbc017g.dd_touroku < DATE '2023-03-01')
            OR tbbc017g.dd_urikzumi < DATE '2024-03-01'
            OR (tbbc017g.dd_touroku IS NULL AND tbbc017g.dd_jucyu < DATE '2020-12-01')
        ))
LIMIT 0;

CREATE TABLE IF NOT EXISTS gold.vbi013006 AS
WITH kb_genkin_table AS(
    SELECT
        tbi999013m.cd_hansya
        , tbi999013m.cd_kaisya
        , GROUP_CONCAT(tbi999013m.kb_nyuukin, ',') AS kb_nyuukin_list
    FROM dx_ve.tbi999013m tbi999013m
    WHERE tbi999013m.kb_genkin = '1'
    GROUP BY tbi999013m.cd_hansya
            ,tbi999013m.cd_kaisya
),
kb_crejcard_table AS(
    SELECT
        tbi999013m.cd_hansya
        , tbi999013m.cd_kaisya
        , GROUP_CONCAT(tbi999013m.kb_nyuukin, ',') AS kb_nyuukin_list
    FROM dx_ve.tbi999013m tbi999013m
    WHERE tbi999013m.kb_crejcard = '1'
    GROUP BY tbi999013m.cd_hansya
            ,tbi999013m.cd_kaisya
),
nt8014m AS(
    SELECT
        t014m.cd_hansya
        , t014m.cd_kaisya
        , t014m.no_cyumon
        , MAX(IF(t014m.kb_nyukkanr = '01',t014m.dd_keijyou,NULL)) AS dd_keijyou1
        , MAX(IF(t014m.kb_nyukkanr = '02',t014m.dd_keijyou,NULL)) AS dd_keijyou2
    FROM ai21rep_ve_dx.tbg8014m t014m
    GROUP BY t014m.cd_hansya, t014m.cd_kaisya, t014m.no_cyumon
),
base_data AS (
  SELECT
    CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE) AS jp_today
    , DATE_TRUNC('MONTH', FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')) AS current_month_start
    , LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AS last_month_end
    , tbbc017g.cd_hansya || tbbc017g.cd_kaisya || tbbc017g.no_cyumon || trim(tbbc017g.no_cyumoned) AS cd_pk
    , IF(LEFT(tbbc017g.no_cyumon, 3) = 'TAD' AND LENGTH(tbbc017g_2.no_min_denpyo) > 0,tbbc017g.cd_hansya || tbbc017g.cd_kaisya || LEFT(tbbc017g_2.no_min_denpyo, 3),tbbc017g.cd_hansya || tbbc017g.cd_kaisya || tbbc017g.cd_jytyuten) AS cd_hankaisya_tenpo
    , tbbc017g.cd_hansya
    , tbbc017g.cd_kaisya
    , IF(LEFT(tbbc017g.no_cyumon, 3) = 'TAD' AND LENGTH(tbbc017g_2.no_min_denpyo) > 0,LEFT(tbbc017g_2.no_min_denpyo, 3),tbbc017g.cd_jytyuten) AS cd_jytyuten
    , tbbc017g.no_cyumon
    , tbbc017g.no_cyumoned
    , tbbc017g.dd_touroku
    , tbbc017g.dd_nosya
    , tbbc017g.dd_urikzumi
    , tbbc017g.dd_jucyu
    , tbbc017g.dd_torikesi
    , tbbc017g.dd_torotrkk
    , tbbc020g.dd_minasksy
    , tbbc020g.dd_kaisyuyo
    , tbbc020g.ki_haseirui
    , tbbc020g.ki_genknykg
    , tbbc020g.ki_sitanykg
    , tbbc020g.ki_fuharnyk
    , tbbc020g.ki_genkhasg
    , tbbc020g.ki_fuharhsk
    , CASE tbbc020g.mj_keiykeit
        WHEN '1' THEN '現金'
        WHEN '2' THEN '後払い'
        WHEN '3' THEN '自社割賦'
        WHEN '4' THEN '信用購入斡旋'
        WHEN '5' THEN '債権譲渡'
        WHEN '' THEN 'その他'
    END AS mj_keiykeit
    , TO_TIMESTAMP(CAST(nt8014m1.dd_keijyou1 AS STRING), 'yyyyMMdd') AS dd_keijyou1
    , TO_TIMESTAMP(CAST(nt8014m1.dd_keijyou2 AS STRING), 'yyyyMMdd') AS dd_keijyou2
    , COALESCE(tbi002001m.su_minosya, 14) AS su_minosya
    , COALESCE(tbi002001m.su_touroku, 30) AS su_touroku
    , COALESCE(tbi002001m.su_jucyu, 30) AS su_jucyu
  FROM
    ai21rep_ve_dx.tbbc017g tbbc017g
  LEFT JOIN ai21rep_ve_dx.tbbc020g tbbc020g
      ON tbbc017g.cd_hansya = tbbc020g.cd_hansya
      AND tbbc017g.cd_kaisya = tbbc020g.cd_kaisya
      AND tbbc017g.no_cyumon = tbbc020g.no_cyumon
      AND TRIM(tbbc017g.no_cyumoned) = TRIM(tbbc020g.no_cyumoned)
LEFT JOIN (
    SELECT
         tbbc017g.cd_hansya
        ,tbbc017g.cd_kaisya
        ,tbbc017g.no_cyumon
        ,tbbc017g.no_cyumoned
        ,MIN(tbg8014m.no_denpyo) AS no_min_denpyo
    FROM ai21rep_ve_dx.tbg8014m tbg8014m
    RIGHT JOIN ai21rep_ve_dx.tbbc017g tbbc017g
        ON tbg8014m.cd_hansya = tbbc017g.cd_hansya
        AND tbg8014m.cd_kaisya = tbbc017g.cd_kaisya
        AND TRIM(tbg8014m.no_cyumon) = (TRIM(tbbc017g.no_cyumon) || TRIM(tbbc017g.no_cyumoned))
        AND tbg8014m.kb_urinyuki = '2'
        AND tbg8014m.kb_nyukkanr = '01'
    GROUP BY
         tbbc017g.cd_hansya
        ,tbbc017g.cd_kaisya
        ,tbbc017g.no_cyumon
        ,tbbc017g.no_cyumoned
) tbbc017g_2
ON tbbc017g_2.cd_hansya = tbbc017g.cd_hansya
AND tbbc017g_2.cd_kaisya = tbbc017g.cd_kaisya
AND tbbc017g_2.no_cyumon = tbbc017g.no_cyumon
AND tbbc017g_2.no_cyumoned = tbbc017g.no_cyumoned
    LEFT JOIN dx_ve.tbi013001m tbi002001m
        ON tbbc017g.cd_hansya = tbi002001m.cd_hansya
        AND tbbc017g.cd_kaisya = tbi002001m.cd_kaisya
LEFT JOIN nt8014m nt8014m1
    ON nt8014m1.cd_hansya = tbbc017g.cd_hansya
    AND nt8014m1.cd_kaisya = tbbc017g.cd_kaisya
    AND nt8014m1.no_cyumon = TRIM(CONCAT(tbbc017g.no_cyumon, tbbc017g.no_cyumoned))
  WHERE ISNOTTRUE((NVL(tbbc020g.ki_haseirui ,0) - NVL(tbbc020g.ki_genknykg ,0) - NVL(tbbc020g.ki_sitanykg ,0) - NVL(tbbc020g.ki_fuharnyk ,0)) = 0
    AND((tbbc017g.dd_touroku IS NOT NULL
      AND tbbc017g.dd_nosya < DATE '2023-03-01'
      AND (tbbc017g.dd_urikzumi IS NULL OR tbbc017g.dd_urikzumi < DATE '2024-03-01'))
    OR (tbbc017g.dd_nosya IS NULL AND tbbc017g.dd_touroku < DATE '2023-03-01')
      OR tbbc017g.dd_urikzumi < DATE '2024-03-01'
      OR (tbbc017g.dd_touroku IS NULL AND tbbc017g.dd_jucyu < DATE '2020-12-01')))
    AND (tbbc017g.dd_torotrkk IS NULL OR (tbbc017g.dd_torotrkk IS NOT NULL AND (NVL(tbbc020g.ki_haseirui ,0) - NVL(tbbc020g.ki_genknykg ,0) - NVL(tbbc020g.ki_sitanykg ,0) - NVL(tbbc020g.ki_fuharnyk ,0)) <> 0))
    AND (
        LEFT(tbbc017g.kb_uriage, 1) = '1'
        OR (
        LEFT(tbbc017g.kb_uriage, 1) = '3'
        AND
        NOT((NVL(tbbc020g.ki_haseirui ,0) - NVL(tbbc020g.ki_genknykg ,0) - NVL(tbbc020g.ki_sitanykg ,0) - NVL(tbbc020g.ki_fuharnyk ,0)) = 0
        AND (NVL(tbbc020g.ki_genkhasg ,0) - NVL(tbbc020g.ki_genknykg ,0)) = 0
        AND (NVL(tbbc020g.ki_fuharhsk ,0) - NVL(tbbc020g.ki_fuharnyk ,0)) = 0
        AND (NVL(tbbc020g.ki_sitahasg ,0) - NVL(tbbc020g.ki_sitanykg ,0)) = 0)))
)
SELECT
  cd_pk AS `PK_販社会社注文NO枝番`
  , cd_hankaisya_tenpo AS `PK_販社会社店舗コード`
  , cd_hansya AS `販社コード`
  , cd_kaisya AS `会社コード`
  , IF(CONCAT_WS('',flg_1, flg_2, flg_3, flg_4, flg_5, flg_6, flg_a, flg_b, flg_c, flg_d, flg_e, flg_f) = '','99',CONCAT_WS('',flg_1, flg_2, flg_3, flg_4, flg_5, flg_6, flg_a, flg_b, flg_c, flg_d, flg_e, flg_f)) AS `アラート判断`
  ,no_cyumon AS `注文no`
  ,cd_jytyuten AS `店舗コード`
  ,dd_nosya AS `納車日`
  ,dd_touroku AS `登録日`
  ,dd_jucyu AS `受注日`
  ,flg_1
  ,flg_2
  ,flg_3
  ,flg_4
  ,flg_5
  ,flg_6
  ,flg_a
  ,flg_b
  ,flg_c
  ,flg_d
  ,flg_e
  ,flg_f
  ,flg
  ,dd_minasksy AS `見直し回収予定日`
  ,dd_kaisyuyo AS `回収予定日`
  ,su_minosya AS `未納車経過日`
  ,su_touroku AS `登録経過日`
  ,su_jucyu AS `受注経過日`
  FROM(
  SELECT
    cd_pk
    , cd_hankaisya_tenpo
    , cd_hansya
    , cd_kaisya
    , no_cyumon
    , cd_jytyuten
    , dd_nosya
    , dd_touroku
    , dd_jucyu
    , dd_minasksy
    , dd_kaisyuyo
    , su_minosya
    , su_touroku
    , su_jucyu
    , IF(COALESCE(dd_minasksy ,dd_kaisyuyo) IS NOT NULL AND COALESCE(dd_minasksy ,dd_kaisyuyo) < jp_today AND ((NVL(ki_genkhasg ,0) - NVL(ki_genknykg ,0) ) <> 0 OR (NVL(ki_fuharhsk ,0) - NVL(ki_fuharnyk ,0)) <> 0),'1','') AS flg_1
    , IF(dd_touroku IS NOT NULL AND (NVL(ki_haseirui ,0) - NVL(ki_genknykg ,0) - NVL(ki_sitanykg ,0) - NVL(ki_fuharnyk ,0)) < 0,'2','') AS flg_2
    , IF(dd_touroku IS NOT NULL AND dd_nosya IS NULL,'3','') AS flg_3
    , IF(dd_nosya IS NOT NULL AND ((NVL(ki_genkhasg ,0) - NVL(ki_genknykg ,0) ) <> 0 OR (NVL(ki_fuharhsk ,0) - NVL(ki_fuharnyk ,0)) <> 0) AND mj_keiykeit <> '後払い','4','') AS flg_4
    , IF(dd_nosya IS NOT NULL AND mj_keiykeit <> '後払い' AND (dd_keijyou1 > dd_nosya || dd_keijyou2 > dd_nosya),'5','') AS flg_5
    , IF(NVL(tbg8014m_2.ki_nyukinur2 - tbg8014m_2.ki_nyukinur3, 0) + NVL(tbg8014m_2.positive_count - tbg8014m_2.negative_count, 0) >= 3,'6','') AS flg_6
    , IF((dd_touroku < current_month_start AND dd_touroku IS NOT NULL) AND (dd_urikzumi > last_month_end OR dd_urikzumi IS NULL),'a','') AS flg_a
    , IF((dd_touroku < current_month_start AND dd_touroku IS NOT NULL) AND (dd_urikzumi > last_month_end OR dd_urikzumi IS NULL) AND DATEDIFF(last_month_end, dd_touroku) >= su_minosya AND (dd_nosya IS NULL OR TRUNC(dd_nosya, 'month') >= TRUNC(last_month_end, 'month')),'b','') AS flg_b
    , IF((dd_touroku < current_month_start AND dd_touroku IS NOT NULL) AND (dd_urikzumi > last_month_end OR dd_urikzumi IS NULL) AND DATEDIFF(last_month_end, dd_touroku) >= su_touroku,'c','') AS flg_c
    , IF(dd_jucyu IS NOT NULL AND dd_touroku IS NULL AND DATEDIFF(last_month_end, dd_jucyu) >= su_jucyu,'d','') AS flg_d
    , '' AS flg_e
    , '' AS flg_f
   , CASE
       WHEN dd_nosya IS NOT NULL AND mj_keiykeit <> '後払い' AND (dd_keijyou1 > dd_nosya || dd_keijyou2 > dd_nosya)
       THEN
           CASE
               WHEN dd_keijyou1 > dd_nosya AND dd_keijyou2 > dd_nosya
               THEN '1'
               WHEN dd_keijyou1 > dd_nosya
               THEN '2'
               ELSE '3'
           END
       ELSE ''
   END AS flg
  FROM base_data
  LEFT JOIN (
      SELECT
        tbg8014m.cd_hansya AS cd_hansya_1
        , tbg8014m.cd_kaisya AS cd_kaisya_1
        , TRIM(tbg8014m.no_cyumon) AS no_cyumon_1
        , SUM(IF(tbg8014m.kb_nyukkanr = '01',1,0)) AS cash_receipt
        , SUM(IF(FIND_IN_SET(LEFT(tbg8014m.kb_nyuukin, 2),kb_genkin_table.kb_nyuukin_list) > 0 AND tbg8014m.kb_urinyuki = '2' AND tbg8014m.ki_nyukinur >= 1,1,0)) AS positive_count
        , SUM(IF(FIND_IN_SET(LEFT(tbg8014m.kb_nyuukin, 2),kb_genkin_table.kb_nyuukin_list) > 0 AND tbg8014m.kb_urinyuki = '2' AND tbg8014m.ki_nyukinur <= -1,1,0)) AS negative_count
        , SUM(IF(FIND_IN_SET(LEFT(tbg8014m.kb_nyuukin, 2),kb_crejcard_table.kb_nyuukin_list) > 0 AND tbg8014m.kb_urinyuki = '2' AND tbg8014m.ki_nyukinur >= 1,1,0)) AS ki_nyukinur2
        , SUM(IF(FIND_IN_SET(LEFT(tbg8014m.kb_nyuukin, 2),kb_crejcard_table.kb_nyuukin_list) > 0 AND tbg8014m.kb_urinyuki = '2' AND tbg8014m.ki_nyukinur <= -1,1,0)) AS ki_nyukinur3
      FROM
        ai21rep_ve_dx.tbg8014m tbg8014m
      RIGHT JOIN ai21rep_ve_dx.tbbc020g tbbc020g
          ON tbg8014m.cd_hansya = tbbc020g.cd_hansya
          AND tbg8014m.cd_kaisya = tbbc020g.cd_kaisya
          AND TRIM(tbg8014m.no_cyumon) = (TRIM(tbbc020g.no_cyumon) || TRIM(tbbc020g.no_cyumoned))
       LEFT JOIN kb_genkin_table
           ON kb_genkin_table.cd_hansya = tbg8014m.cd_hansya
           AND kb_genkin_table.cd_kaisya = tbg8014m.cd_kaisya
       LEFT JOIN kb_crejcard_table
           ON kb_crejcard_table.cd_hansya = tbg8014m.cd_hansya
           AND kb_crejcard_table.cd_kaisya = tbg8014m.cd_kaisya
      GROUP BY
        tbg8014m.cd_hansya,
        tbg8014m.cd_kaisya,
        TRIM(tbg8014m.no_cyumon)
  )tbg8014m_2
    ON base_data.cd_hansya = tbg8014m_2.cd_hansya_1
   AND base_data.cd_kaisya = tbg8014m_2.cd_kaisya_1
   AND (TRIM(base_data.no_cyumon) ||  TRIM(base_data.no_cyumoned)) = tbg8014m_2.no_cyumon_1
  ) maintable
LIMIT 0;

CREATE TABLE IF NOT EXISTS gold.vbi013007 AS
WITH table_8014m AS (SELECT
    ROW_NUMBER() OVER(ORDER BY 1) AS logic_pk,
    tbg8014m.*
FROM ai21rep_ve_dx.tbg8014m
)
SELECT
  DISTINCT
  bt.logic_pk AS `主キー`
  , bt.cd_hansya AS `販社コード`
  , bt.cd_kaisya AS `会社コード`
  , t014m.no_cyumon AS `注文ＮＯ`
  , CONCAT(t014m.cd_hansya, t014m.cd_kaisya, TRIM(t014m.no_cyumon)) AS `販社会社注文NO`
  , CAST(t014m.dd_keijyou AS STRING) AS `日付_順番用`
  , TO_TIMESTAMP(CAST(t014m.dd_keijyou AS STRING), 'yyyyMMdd') AS `日付`
  , COALESCE(t053m.kb_syohmei, t204m.kj_nasemei, t208m.kj_nyuukinm) AS `項目名`
  , IF (t014m.kb_urinyuki = '1', t014m.ki_nyukinur, NULL) AS `発生額`
  , IF (t014m.kb_urinyuki = '2', t014m.ki_nyukinur, NULL) AS `入金額`
  , IF (t014m.kb_urinyuki = '1',
    CASE SUBSTR(t014m.kb_nyuukin, 3, 1)
      WHEN '1' THEN '取消'
      WHEN '2' THEN '売上'
      WHEN '3' THEN '条変'
    END,
    IF (t014m.kb_urinyuki = '2',
      CASE t014m.kb_nyukkanr
        WHEN '01' THEN '現金'
        WHEN '02' THEN '割賦'
        WHEN '03' THEN '下取'
        WHEN '04' THEN '約手'
        WHEN '05' THEN '残債'
      END,
      NULL
    )
  ) AS `空白欄`
  , t014m.no_denpyo AS `伝票番号`
  , t014m.kb_gyoumu AS `業務区分`
  , t014m.kb_nyuukin AS `入金区分`
  , 1 AS `件数`
FROM(
  SELECT
      t014m.cd_hansya
      , t014m.cd_kaisya
    , t014m.logic_pk
    , LEFT(t014m.kb_nyuukin, 2) AS kb_nyuukin
    , MAX(t053m.dt_saisinup) AS dt_saisinup
  FROM
    table_8014m t014m
  LEFT JOIN ai21rep_ve_dx.tbbf053m t053m
      ON t014m.cd_hansya = t053m.cd_hansya
      AND t014m.cd_kaisya = t053m.cd_kaisya
      AND CAST(from_timestamp(t053m.dt_saisinup, 'yyyyMMdd') AS INT) <= t014m.dd_keijyou
  GROUP BY
    t014m.cd_hansya,
      t014m.cd_kaisya,
      t014m.logic_pk,
      t014m.kb_nyuukin
    ) bt
INNER JOIN table_8014m t014m
    ON t014m.logic_pk = bt.logic_pk
    AND t014m.cd_hansya = bt.cd_hansya
    AND t014m.cd_kaisya = bt.cd_kaisya
LEFT JOIN ai21rep_ve_dx.tbbf053m t053m
    ON t014m.cd_hansya = t053m.cd_hansya
    AND t014m.cd_kaisya = t053m.cd_kaisya
    AND t014m.kb_urinyuki = '1'
    AND t053m.dt_saisinup = bt.dt_saisinup
    AND CONCAT(t053m.kb_syohmei, t053m.kb_syohmsy) = CASE LEFT(t014m.kb_nyuukin, 2)
    WHEN '14' THEN '210'
    WHEN '15' THEN '220'
    WHEN '16' THEN '231'
    WHEN '17' THEN '232'
    WHEN '18' THEN '233'
    WHEN '20' THEN '520'
    WHEN '21' THEN '510'
    WHEN '22' THEN '610'
    WHEN '23' THEN '620'
    WHEN '24' THEN '631'
    WHEN '25' THEN '632'
    WHEN '26' THEN '633'
  END
LEFT JOIN ai21rep_ve_dx.tbgm024m t204m
    ON t204m.cd_hansya = bt.cd_hansya
    AND t204m.cd_kaisya = bt.cd_kaisya
    AND t204m.kb_hassei = LEFT(t014m.kb_nyuukin, 2)
    AND t014m.kb_urinyuki = '1'
    AND FIND_IN_SET(LEFT(t014m.kb_nyuukin, 2), '14,15,16,17,18,20,21,22,23,24,25,26') = 0
LEFT JOIN ai21rep_ve_dx.tbv0208m t208m
    ON t208m.cd_hansya = bt.cd_hansya
    AND t208m.cd_kaisya = bt.cd_kaisya
    AND t208m.kb_nyuukin = LEFT(t014m.kb_nyuukin, 2)
    AND t014m.kb_urinyuki = '2'
LIMIT 0;

CREATE TABLE IF NOT EXISTS gold.vbi013011 AS
WITH kb_genkin_table AS(
    SELECT
        tbi999013m.cd_hansya
        , tbi999013m.cd_kaisya
        , GROUP_CONCAT(tbi999013m.kb_nyuukin, ',') AS kb_nyuukin_list
    FROM dx_ve.tbi999013m tbi999013m
    WHERE tbi999013m.kb_genkin = '1'
    GROUP BY tbi999013m.cd_hansya
            ,tbi999013m.cd_kaisya
),
kb_crejcard_table AS(
    SELECT
        tbi999013m.cd_hansya
        , tbi999013m.cd_kaisya
        , GROUP_CONCAT(tbi999013m.kb_nyuukin, ',') AS kb_nyuukin_list
    FROM dx_ve.tbi999013m tbi999013m
    WHERE tbi999013m.kb_crejcard = '1'
    GROUP BY tbi999013m.cd_hansya
            ,tbi999013m.cd_kaisya
),
nt8014m AS(
    SELECT
        t014m.cd_hansya
        , t014m.cd_kaisya
        , t014m.no_cyumon
        , MAX(IF(t014m.kb_nyukkanr = '01', t014m.dd_keijyou, NULL)) AS dd_keijyou1
        , MAX(IF(t014m.kb_nyukkanr = '02', t014m.dd_keijyou, NULL)) AS dd_keijyou2
        , MAX(IF(t014m.kb_nyukkanr = '03', t014m.dd_keijyou, NULL)) AS dd_keijyou3
    FROM ai21rep_ve_dx.tbg8014m t014m
    GROUP BY t014m.cd_hansya, t014m.cd_kaisya, t014m.no_cyumon
),
kt8014m AS(
    SELECT
        tbbc017g.cd_hansya
        , tbbc017g.cd_kaisya
        , tbbc017g.no_cyumon
        , TRIM(tbbc017g.no_cyumoned) AS no_cyumoned
        , SUM(IF(t014m.dd_keijyou < CAST(FROM_TIMESTAMP(tbbc017g.dd_touroku, 'yyyyMMdd') AS INT),t014m.ki_nyukinur,0)) AS ki_nyukinur1
        , SUM(IF(FIND_IN_SET(LEFT(t014m.kb_nyuukin, 2),kb_crejcard_table.kb_nyuukin_list) > 0 AND t014m.ki_nyukinur >= 1,1,0)) AS ki_nyukinur2
        , SUM(IF(FIND_IN_SET(LEFT(t014m.kb_nyuukin, 2),kb_crejcard_table.kb_nyuukin_list) > 0 AND t014m.ki_nyukinur <= -1,1,0)) AS ki_nyukinur3
        , SUM(IF(FIND_IN_SET(LEFT(t014m.kb_nyuukin, 2),kb_genkin_table.kb_nyuukin_list) > 0 AND t014m.ki_nyukinur >= 1,1,0)) AS ki_nyukinur4
        , SUM(IF(FIND_IN_SET(LEFT(t014m.kb_nyuukin, 2),kb_genkin_table.kb_nyuukin_list) > 0 AND t014m.ki_nyukinur <= -1,1,0)) AS ki_nyukinur5
    FROM ai21rep_ve_dx.tbbc017g tbbc017g
    INNER JOIN ai21rep_ve_dx.tbg8014m t014m
        ON t014m.cd_hansya = tbbc017g.cd_hansya
        AND t014m.cd_kaisya = tbbc017g.cd_kaisya
        AND TRIM(t014m.no_cyumon) = TRIM(CONCAT(tbbc017g.no_cyumon, tbbc017g.no_cyumoned))
        AND t014m.kb_urinyuki = '2'
     LEFT JOIN kb_genkin_table
         ON kb_genkin_table.cd_hansya = tbbc017g.cd_hansya
         AND kb_genkin_table.cd_kaisya = tbbc017g.cd_kaisya
     LEFT JOIN kb_crejcard_table
         ON kb_crejcard_table.cd_hansya = tbbc017g.cd_hansya
         AND kb_crejcard_table.cd_kaisya = tbbc017g.cd_kaisya
    GROUP BY tbbc017g.cd_hansya, tbbc017g.cd_kaisya, tbbc017g.no_cyumon, TRIM(tbbc017g.no_cyumoned)
)
SELECT
    tbbc017g.cd_hansya AS `販社コード`
    , tbbc017g.cd_kaisya AS `会社コード`
    , IF(LEFT(tbbc017g.no_cyumon, 3) = 'TAD' AND LENGTH(tbbc017g_2.no_min_denpyo) > 0,LEFT(tbbc017g_2.no_min_denpyo, 3),tbbc017g.cd_jytyuten) AS `店舗コード`
    , tbbc017g.no_cyumon AS `注文no`
    , TRIM(tbbc017g.no_cyumoned) AS `注文枝番`
    , CONCAT(tbbc017g.cd_hansya, tbbc017g.cd_kaisya, tbbc017g.no_cyumon, TRIM(tbbc017g.no_cyumoned)) AS `pk_販社会社注文no枝番`
    , IF(LEFT(tbbc017g.no_cyumon, 3) = 'TAD' AND LENGTH(tbbc017g_2.no_min_denpyo) > 0,tbbc017g.cd_hansya || tbbc017g.cd_kaisya || LEFT(tbbc017g_2.no_min_denpyo, 3),tbbc017g.cd_hansya || tbbc017g.cd_kaisya || tbbc017g.cd_jytyuten) AS `販社会社店舗コード`
    , v2001.kj_tentanms AS `店舗略称`
    , v2001.zone_name AS `エリア統括部`
    , v2001.cd_zon AS `ゾーンコード`
    , v2001.mj_sortjyun AS `ソート順`
    , IF(tbbc017g.dd_touroku IS NOT NULL,'登録済','未登録') AS `登録`
    , IF(tbbc017g.dd_nosya IS NOT NULL,'納車済','未納車') AS `納車`
    , IF(tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk = 0,'残高なし','残高あり') AS `売掛残高`
    , t014m.kj_syainmei AS `社員名`
    , DATEDIFF(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), tbbc017g.dd_touroku) AS `売上経過日数`
    , CONCAT(REGEXP_REPLACE(tbbc017g.kj_kainmei1, '　+$', ''), REGEXP_REPLACE(tbbc017g.kj_kainmei2, '　+$', '')) AS `買主名`
    , CONCAT(REGEXP_REPLACE(tbbc017g.kj_meigime1, '　+$', ''), REGEXP_REPLACE(tbbc017g.kj_meigime2, '　+$', '')) AS `名義人`
    , CASE tbbc020g.mj_keiykeit
        WHEN '1' THEN '現金'
        WHEN '2' THEN '後払い'
        WHEN '3' THEN '自社割賦'
        WHEN '4' THEN '信用購入斡旋'
        WHEN '5' THEN '債権譲渡'
        WHEN ''  THEN 'その他'
    END AS `契約形態`
    , TRIM(CONCAT(tbbc017g.no_cyumon, tbbc017g.no_cyumoned)) AS `注文NO_枝番`
    , IF(INSTR(tbbc001g.mj_katasiki, '-') > 0,SUBSTR(tbbc001g.mj_katasiki, 1, INSTR(tbbc001g.mj_katasiki, '-') - 1),tbbc001g.mj_katasiki) AS `型式`
    , tbbc017g.dd_jucyu AS `受注日`
    , tbbc020g.dd_maeuknyu AS `申込金受領日`
    , tbbc017g.dd_touroku AS `登録日`
    , tbbc017g.dd_nosya AS `納車日`
    , NVL(tbbc020g.dd_minasksy, tbbc020g.dd_kaisyuyo) AS `回収予定日`
    , TO_TIMESTAMP(CAST(nt8014m1.dd_keijyou1 AS STRING), 'yyyyMMdd') AS `最終入金日（現金）`
    , TO_TIMESTAMP(CAST(nt8014m1.dd_keijyou2 AS STRING), 'yyyyMMdd') AS `最終入金日（割賦）`
    , TO_TIMESTAMP(CAST(nt8014m1.dd_keijyou3 AS STRING), 'yyyyMMdd') AS `下取完了日`
    , tbbc017g.dd_urikzumi AS `完了`
    , (NVL(tbbc020g.ki_haseirui ,0) - NVL(tbbc020g.ki_genknykg ,0) - NVL(tbbc020g.ki_sitanykg,0) - NVL(tbbc020g.ki_fuharnyk,0)) as `売掛金残高合計`
    , (NVL(tbbc020g.ki_genkhasg ,0) - NVL(tbbc020g.ki_genknykg ,0)) AS `現金残高`
    , (NVL(tbbc020g.ki_fuharhsk ,0) - NVL(tbbc020g.ki_fuharnyk ,0)) AS `割賦残高`
    , (NVL(tbbc020g.ki_sitahasg ,0) - NVL(tbbc020g.ki_sitanykg ,0)) AS `下取車残高`
    , IF (
        tbbc017g.dd_touroku IS NULL OR nt8014m1.dd_keijyou1 IS NULL OR TO_TIMESTAMP(CAST(nt8014m1.dd_keijyou1 AS STRING), 'yyyyMMdd') < tbbc017g.dd_touroku,
        tbbc020g.ki_nyuruike,
        NVL(kt8014m.ki_nyukinur1, 0)
    ) AS `申込金`,
    NVL(kt8014m.ki_nyukinur4 - kt8014m.ki_nyukinur5, 0) AS `現金入金回数`
    , NVL(kt8014m.ki_nyukinur2 - kt8014m.ki_nyukinur3, 0) AS `カード入金回数`
    , tbbc017g.dd_nosya AS `振当-納車`
    , DATEDIFF(tbbc017g.dd_nosya, tbbc017g.dd_touroku) AS `登録-納車`
    , DATEDIFF(tbbc017g.dd_urikzumi, tbbc017g.dd_touroku) AS `登録-完了`
    , CASE LEFT(tbbc017g.kb_uriage, 1)
        WHEN '1' THEN '一般売上'
        WHEN '3' THEN 'リース'
    END AS `払出区分`
    , IF(
        t051g1.kb_seibetu = '1' AND t051g2.kb_seibetu = '1'
        OR t051g1.kb_seibetu = '2' AND t051g2.kb_seibetu = '1'
        OR t051g1.kb_seibetu = '1' AND t051g2.kb_seibetu = '2'
        OR t051g1.kb_seibetu = '2' AND t051g2.kb_seibetu = '2',
        '個人',
        '法人'
    ) AS `法人個人区分`,
    tbbc020g.ki_haseirui AS `発生累計`
    , tbbc017g.dt_saisinup AS `更新日時`
    , CASE
        WHEN tbbc017g.dd_nosya IS NOT NULL AND tbbc017g.dd_urikzumi IS NOT NULL THEN
            CASE
                WHEN DATEDIFF(tbbc017g.dd_nosya, tbbc017g.dd_urikzumi) <> 0
                    THEN
                        DATEDIFF(tbbc017g.dd_nosya, tbbc017g.dd_urikzumi)
                    ELSE 0
            END
        ELSE NULL
    END AS `納車～完了`
FROM ai21rep_ve_dx.tbbc017g tbbc017g
LEFT JOIN (
    SELECT
         tbbc017g.cd_hansya
        ,tbbc017g.cd_kaisya
        ,tbbc017g.no_cyumon
        ,tbbc017g.no_cyumoned
        ,MIN(tbg8014m.no_denpyo) AS no_min_denpyo
    FROM ai21rep_ve_dx.tbg8014m tbg8014m
    RIGHT JOIN ai21rep_ve_dx.tbbc017g tbbc017g
        ON tbg8014m.cd_hansya = tbbc017g.cd_hansya
        AND tbg8014m.cd_kaisya = tbbc017g.cd_kaisya
        AND TRIM(tbg8014m.no_cyumon) = (TRIM(tbbc017g.no_cyumon) || TRIM(tbbc017g.no_cyumoned))
        AND tbg8014m.kb_urinyuki = '2'
        AND tbg8014m.kb_nyukkanr = '01'
    GROUP BY
         tbbc017g.cd_hansya
        ,tbbc017g.cd_kaisya
        ,tbbc017g.no_cyumon
        ,tbbc017g.no_cyumoned
) tbbc017g_2
ON tbbc017g_2.cd_hansya = tbbc017g.cd_hansya
AND tbbc017g_2.cd_kaisya = tbbc017g.cd_kaisya
AND tbbc017g_2.no_cyumon = tbbc017g.no_cyumon
AND tbbc017g_2.no_cyumoned = tbbc017g.no_cyumoned
INNER JOIN dx_ve.vbi013001_en v2001
    ON v2001.cd_hansya = tbbc017g.cd_hansya
    AND v2001.cd_kaisya = tbbc017g.cd_kaisya
    AND v2001.cd_tenpo = IF(LEFT(tbbc017g.no_cyumon, 3) = 'TAD' AND LENGTH(tbbc017g_2.no_min_denpyo) > 0,LEFT(tbbc017g_2.no_min_denpyo, 3),tbbc017g.cd_jytyuten)
LEFT JOIN ai21rep_ve_dx.tbbc020g tbbc020g
    ON tbbc020g.cd_hansya = tbbc017g.cd_hansya
    AND tbbc020g.cd_kaisya = tbbc017g.cd_kaisya
    AND tbbc020g.no_cyumon = tbbc017g.no_cyumon
    AND TRIM(tbbc020g.no_cyumoned) = TRIM(tbbc017g.no_cyumoned)
LEFT JOIN ai21rep_ve_dx.tbv0014m t014m
    ON t014m.cd_hansya = tbbc017g.cd_hansya
    AND t014m.cd_kaisya = tbbc017g.cd_kaisya
    AND t014m.cd_syain = tbbc017g.cd_hanstaff
LEFT JOIN nt8014m nt8014m1
    ON nt8014m1.cd_hansya = tbbc017g.cd_hansya
    AND nt8014m1.cd_kaisya = tbbc017g.cd_kaisya
    AND TRIM(nt8014m1.no_cyumon) = TRIM(concat(tbbc017g.no_cyumon, tbbc017g.no_cyumoned))
LEFT JOIN kt8014m
    ON kt8014m.cd_hansya = tbbc017g.cd_hansya
    AND kt8014m.cd_kaisya = tbbc017g.cd_kaisya
    AND TRIM(kt8014m.no_cyumon) = tbbc017g.no_cyumon
    AND TRIM(kt8014m.no_cyumoned) = TRIM(tbbc017g.no_cyumoned)
LEFT JOIN ai21rep_ve_dx.tbbc018g t051g1
    ON t051g1.cd_hansya = tbbc017g.cd_hansya
    AND t051g1.cd_kaisya = tbbc017g.cd_kaisya
    AND t051g1.no_cyumon = tbbc017g.no_cyumon
    AND TRIM(t051g1.no_cyumoned) = TRIM(tbbc017g.no_cyumoned)
    AND t051g1.kb_kokyaku = '1'
LEFT JOIN ai21rep_ve_dx.tbbc018g t051g2
    ON t051g2.cd_hansya = tbbc017g.cd_hansya
    AND t051g2.cd_kaisya = tbbc017g.cd_kaisya
    AND t051g2.no_cyumon = tbbc017g.no_cyumon
    AND TRIM(t051g2.no_cyumoned) = TRIM(tbbc017g.no_cyumoned)
    AND t051g2.kb_kokyaku = '2'
LEFT JOIN ai21rep_ve_dx.tbbc001g tbbc001g
    ON tbbc017g.cd_hansya = tbbc001g.cd_hansya
    AND tbbc017g.cd_kaisya = tbbc001g.cd_kaisya
    AND tbbc017g.no_syaryou = tbbc001g.no_syaryou
WHERE ISNOTTRUE(
    (tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) = 0
    AND((tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_nosya < DATE '2023-03-01'
        AND (tbbc017g.dd_urikzumi IS NULL OR tbbc017g.dd_urikzumi < DATE '2024-03-01'))
        OR (tbbc017g.dd_nosya IS NULL AND tbbc017g.dd_touroku < DATE '2023-03-01')
        OR tbbc017g.dd_urikzumi < DATE '2024-03-01'
        OR (tbbc017g.dd_touroku IS NULL AND tbbc017g.dd_jucyu < DATE '2020-12-01')
        )
    )
AND (tbbc017g.dd_torotrkk IS NULL
    OR (tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) <> 0)
AND (
        LEFT(tbbc017g.kb_uriage, 1) = '1'
    OR (
        LEFT(tbbc017g.kb_uriage, 1) = '3'
        AND
            NOT((tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) = 0
            AND (tbbc020g.ki_genkhasg - tbbc020g.ki_genknykg) = 0
            AND (tbbc020g.ki_fuharhsk - tbbc020g.ki_fuharnyk) = 0
            AND (tbbc020g.ki_sitahasg - tbbc020g.ki_sitanykg) = 0
            )
        )
    )
LIMIT 0;

CREATE TABLE IF NOT EXISTS gold.vbi013012 AS
SELECT
  tbg7005m_3.cd_hansya AS `販社コード`
  , tbg7005m_3.cd_kaisya AS `会社コード`
  , tbg7005m_3.cd_tenpo AS `店舗コード`
  , tbg7005m_3.cd_hansya || tbg7005m_3.cd_kaisya || tbg7005m_3.cd_tenpo AS `販社会社店舗コード`
  , SUM(tbg7005m_3.ki_toyjkksy) AS `当年上期期首残高`
  , SUM(tbg7005m_3.ki_toykar01) AS `当年借方金額０１`
  , SUM(tbg7005m_3.ki_toykar02) AS `当年借方金額０２`
  , SUM(tbg7005m_3.ki_toykar03) AS `当年借方金額０３`
  , SUM(tbg7005m_3.ki_toykar04) AS `当年借方金額０４`
  , SUM(tbg7005m_3.ki_toykar05) AS `当年借方金額０５`
  , SUM(tbg7005m_3.ki_toykar06) AS `当年借方金額０６`
  , SUM(tbg7005m_3.ki_toykar07) AS `当年借方金額０７`
  , SUM(tbg7005m_3.ki_toykar08) AS `当年借方金額０８`
  , SUM(tbg7005m_3.ki_toykar09) AS `当年借方金額０９`
  , SUM(tbg7005m_3.ki_toykar10) AS `当年借方金額１０`
  , SUM(tbg7005m_3.ki_toykar11) AS `当年借方金額１１`
  , SUM(tbg7005m_3.ki_toykar12) AS `当年借方金額１２`
  , SUM(tbg7005m_3.ki_toykas01) AS `当年貸方金額０１`
  , SUM(tbg7005m_3.ki_toykas02) AS `当年貸方金額０２`
  , SUM(tbg7005m_3.ki_toykas03) AS `当年貸方金額０３`
  , SUM(tbg7005m_3.ki_toykas04) AS `当年貸方金額０４`
  , SUM(tbg7005m_3.ki_toykas05) AS `当年貸方金額０５`
  , SUM(tbg7005m_3.ki_toykas06) AS `当年貸方金額０６`
  , SUM(tbg7005m_3.ki_toykas07) AS `当年貸方金額０７`
  , SUM(tbg7005m_3.ki_toykas08) AS `当年貸方金額０８`
  , SUM(tbg7005m_3.ki_toykas09) AS `当年貸方金額０９`
  , SUM(tbg7005m_3.ki_toykas10) AS `当年貸方金額１０`
   , SUM(tbg7005m_3.ki_toykas11) AS `当年貸方金額１１`
   , SUM(tbg7005m_3.ki_toykas12) AS `当年貸方金額１２`
FROM
  ai21rep_ve_dx.tbg7005m tbg7005m_3
INNER JOIN dx_ve.vbi013001_en vbi013001
    ON vbi013001.cd_hansya = tbg7005m_3.cd_hansya
    AND vbi013001.cd_kaisya = tbg7005m_3.cd_kaisya
    AND vbi013001.cd_tenpo = tbg7005m_3.cd_tenpo
WHERE
  (tbg7005m_3.cd_hansya <> '03601' OR tbg7005m_3.cd_kaisya <> '01' OR tbg7005m_3.cd_tenpo <> 'ZZZ')
  AND tbg7005m_3.nu_yyyy = YEAR(MONTHS_SUB(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 4))
  AND tbg7005m_3.cd_kanjyou = '10402  '
GROUP BY
  tbg7005m_3.cd_hansya,
  tbg7005m_3.cd_kaisya,
  tbg7005m_3.cd_tenpo
LIMIT 0;

CREATE TABLE IF NOT EXISTS gold.vbi013013 AS
SELECT
  tbg7005m_3.cd_hansya AS `販社コード`
  , tbg7005m_3.cd_kaisya AS `会社コード`
  , tbg7005m_3.cd_tenpo AS `店舗コード`
  , tbg7005m_3.cd_hansya || tbg7005m_3.cd_kaisya || tbg7005m_3.cd_tenpo AS `販社会社店舗コード`
  , SUM(tbg7005m_3.ki_toykar01) AS `当年借方金額０１`
  , SUM(tbg7005m_3.ki_toykar02) AS `当年借方金額０２`
  , SUM(tbg7005m_3.ki_toykar03) AS `当年借方金額０３`
  , SUM(tbg7005m_3.ki_toykar04) AS `当年借方金額０４`
  , SUM(tbg7005m_3.ki_toykar05) AS `当年借方金額０５`
  , SUM(tbg7005m_3.ki_toykar06) AS `当年借方金額０６`
  , SUM(tbg7005m_3.ki_toykar07) AS `当年借方金額０７`
  , SUM(tbg7005m_3.ki_toykar08) AS `当年借方金額０８`
  , SUM(tbg7005m_3.ki_toykar09) AS `当年借方金額０９`
  , SUM(tbg7005m_3.ki_toykar10) AS `当年借方金額１０`
  , SUM(tbg7005m_3.ki_toykar11) AS `当年借方金額１１`
  , SUM(tbg7005m_3.ki_toykar12) AS `当年借方金額１２`
  , SUM(tbg7005m_3.ki_toykas01) AS `当年貸方金額０１`
  , SUM(tbg7005m_3.ki_toykas02) AS `当年貸方金額０２`
  , SUM(tbg7005m_3.ki_toykas03) AS `当年貸方金額０３`
  , SUM(tbg7005m_3.ki_toykas04) AS `当年貸方金額０４`
  , SUM(tbg7005m_3.ki_toykas05) AS `当年貸方金額０５`
  , SUM(tbg7005m_3.ki_toykas06) AS `当年貸方金額０６`
  , SUM(tbg7005m_3.ki_toykas07) AS `当年貸方金額０７`
  , SUM(tbg7005m_3.ki_toykas08) AS `当年貸方金額０８`
  , SUM(tbg7005m_3.ki_toykas09) AS `当年貸方金額０９`
  , SUM(tbg7005m_3.ki_toykas10) AS `当年貸方金額１０`
  , SUM(tbg7005m_3.ki_toykas11) AS `当年貸方金額１１`
  , SUM(tbg7005m_3.ki_toykas12) AS `当年貸方金額１２`
FROM
  ai21rep_ve_dx.tbg7005m tbg7005m_3
INNER JOIN dx_ve.vbi013001_en vbi013001
    ON vbi013001.cd_hansya = tbg7005m_3.cd_hansya
    AND vbi013001.cd_kaisya = tbg7005m_3.cd_kaisya
    AND vbi013001.cd_tenpo = tbg7005m_3.cd_tenpo
WHERE
  (tbg7005m_3.cd_hansya <> '03601' OR tbg7005m_3.cd_kaisya <> '01' OR tbg7005m_3.cd_tenpo <> 'ZZZ')
  AND tbg7005m_3.nu_yyyy = YEAR(MONTHS_SUB(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 4))-1
  AND tbg7005m_3.cd_kanjyou >= '50301  ' AND tbg7005m_3.cd_kanjyou <= '50303  '
GROUP BY
  tbg7005m_3.cd_hansya,
  tbg7005m_3.cd_kaisya,
  tbg7005m_3.cd_tenpo
LIMIT 0;

CREATE TABLE IF NOT EXISTS gold.vbi013014 AS
SELECT
  tbg7005m_3.cd_hansya AS `販社コード`
  , tbg7005m_3.cd_kaisya AS `会社コード`
  , tbg7005m_3.cd_tenpo AS `店舗コード`
  , tbg7005m_3.cd_hansya || tbg7005m_3.cd_kaisya || tbg7005m_3.cd_tenpo AS `販社会社店舗コード`
  , SUM(tbg7005m_3.ki_toyjkksy) AS `当年上期期首残高`
  , SUM(tbg7005m_3.ki_toykar01) AS `当年借方金額０１`
  , SUM(tbg7005m_3.ki_toykar02) AS `当年借方金額０２`
  , SUM(tbg7005m_3.ki_toykar03) AS `当年借方金額０３`
  , SUM(tbg7005m_3.ki_toykar04) AS `当年借方金額０４`
  , SUM(tbg7005m_3.ki_toykar05) AS `当年借方金額０５`
  , SUM(tbg7005m_3.ki_toykar06) AS `当年借方金額０６`
  , SUM(tbg7005m_3.ki_toykar07) AS `当年借方金額０７`
  , SUM(tbg7005m_3.ki_toykar08) AS `当年借方金額０８`
  , SUM(tbg7005m_3.ki_toykar09) AS `当年借方金額０９`
  , SUM(tbg7005m_3.ki_toykar10) AS `当年借方金額１０`
  , SUM(tbg7005m_3.ki_toykar11) AS `当年借方金額１１`
  , SUM(tbg7005m_3.ki_toykar12) AS `当年借方金額１２`
  , SUM(tbg7005m_3.ki_toykas01) AS `当年貸方金額０１`
  , SUM(tbg7005m_3.ki_toykas02) AS `当年貸方金額０２`
  , SUM(tbg7005m_3.ki_toykas03) AS `当年貸方金額０３`
  , SUM(tbg7005m_3.ki_toykas04) AS `当年貸方金額０４`
  , SUM(tbg7005m_3.ki_toykas05) AS `当年貸方金額０５`
  , SUM(tbg7005m_3.ki_toykas06) AS `当年貸方金額０６`
  , SUM(tbg7005m_3.ki_toykas07) AS `当年貸方金額０７`
  , SUM(tbg7005m_3.ki_toykas08) AS `当年貸方金額０８`
  , SUM(tbg7005m_3.ki_toykas09) AS `当年貸方金額０９`
  , SUM(tbg7005m_3.ki_toykas10) AS `当年貸方金額１０`
  , SUM(tbg7005m_3.ki_toykas11) AS `当年貸方金額１１`
  , SUM(tbg7005m_3.ki_toykas12) AS `当年貸方金額１２`
FROM ai21rep_ve_dx.tbg7005m tbg7005m_3
INNER JOIN dx_ve.vbi013001_en vbi013001
    ON vbi013001.cd_hansya = tbg7005m_3.cd_hansya
    AND vbi013001.cd_kaisya = tbg7005m_3.cd_kaisya
    AND vbi013001.cd_tenpo = tbg7005m_3.cd_tenpo
WHERE (tbg7005m_3.cd_hansya <> '03601' OR tbg7005m_3.cd_kaisya <> '01' OR tbg7005m_3.cd_tenpo <> 'ZZZ')
  AND tbg7005m_3.nu_yyyy = YEAR(MONTHS_SUB(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 4))-1
  AND tbg7005m_3.cd_kanjyou = '10402  '
GROUP BY
  tbg7005m_3.cd_hansya,
  tbg7005m_3.cd_kaisya,
  tbg7005m_3.cd_tenpo
LIMIT 0;

CREATE TABLE IF NOT EXISTS gold.vbi013015 AS
WITH alert_text AS (
    SELECT '0' AS value, '' AS alert_text
    UNION ALL
    SELECT '1', ''
    UNION ALL
    SELECT '2', ''
    UNION ALL
    SELECT '3', ''
    UNION ALL
    SELECT '4', ''
    UNION ALL
    SELECT '5', ''
    UNION ALL
    SELECT '6', ''
    UNION ALL
    SELECT 'a', '売掛回収チェック'
    UNION ALL
    SELECT 'b', '未納車14日経過'
    UNION ALL
    SELECT 'c', '登録30日経過'
    UNION ALL
    SELECT 'd', '受注30日経過'
    )
SELECT
     tbi013001m.cd_hansya AS `販社コード`
    ,tbi013001m.cd_kaisya AS `会社コード`
    ,value AS `値`
    ,CASE
        WHEN value = 'b' THEN CONCAT('未納車', CAST(COALESCE(tbi013001m.su_minosya, 14) AS STRING), '日経過')
        WHEN value = 'c' THEN CONCAT('登録', CAST(COALESCE(tbi013001m.su_touroku, 30) AS STRING), '日経過')
        WHEN value = 'd' THEN CONCAT('受注', CAST(COALESCE(tbi013001m.su_jucyu, 30) AS STRING), '日経過')
        ELSE alert_text
    END AS `アラート文言`
FROM
    alert_text
CROSS JOIN
    dx_ve.tbi013001m tbi013001m
LIMIT 0;

