-- DM_USERINFO_AUTH
TRUNCATE TABLE gold.DM_USERINFO_AUTH;

INSERT INTO gold.DM_USERINFO_AUTH (
    cd_user,
    cd_hansya,
    cd_kaisya,
    cd_hanbaitn,
    cd_tenpo,
    cd_syain,
    mj_name,
    mj_role,
    kb_access_honten,
    kb_access_hansya,
    kb_access_yoyaku,
    kb_hansya_mente,
    kb_user_mente,
    kb_notice_mente,
    kb_view_kpi,
    kb_view_proc,
    kb_view_ucar,
    mart_created_at
)
SELECT
    t_user.cd_user,
    t_hsif.cd_hansya,
    t_hsif.cd_kaisya,
    t_user.cd_hanbaitn,
    t_user.cd_tenpo,
    t_user.cd_syain,
    t_user.mj_name,
    t_user.mj_role,
    t_user.kb_access_honten,
    t_user.kb_access_hansya,
    t_user.kb_access_yoyaku,
    t_user.kb_hansya_mente,
    t_user.kb_user_mente,
    t_user.kb_notice_mente,
    t_user.kb_view_kpi,
    t_user.kb_view_proc,
    t_user.kb_view_ucar,
    NOW()
FROM uslim_ve.USERINFO t_user
LEFT JOIN uslim_ve.HANSYAINFO t_hsif
    ON t_user.cd_hanbaitn = t_hsif.cd_hanbaitn
WHERE (t_user.mj_sakujo <> '1' OR t_user.mj_sakujo IS NULL);


-- DM_AREAMASTER
TRUNCATE TABLE uslim_ve.DM_AREAMASTER;

INSERT INTO uslim_ve.DM_AREAMASTER (
    cd_chiiki,
    mj_chiiki,
    mart_created_at
)
SELECT
    cd_chiiki,
    mj_chiiki,
    NOW()
FROM uslim_ve.AREAMASTER;


-- DM_HANSYA_DISPLAY
TRUNCATE TABLE uslim_ve.DM_HANSYA_DISPLAY;

INSERT INTO uslim_ve.DM_HANSYA_DISPLAY (
    cd_hansya,
    cd_kaisya,
    cd_hanbaitn,
    kj_hansya,
    cd_chiiki,
    mj_upassuse,
    kb_disp,
    mart_target_date,
    mart_created_at
)
SELECT
    t_hsif.cd_hansya,
    t_hsif.cd_kaisya,
    t_hsif.cd_hanbaitn,
    t_hsif.kj_hanbaitn AS kj_hansya,
    t_hsif.cd_chiiki,
    t_hsif.mj_upassuse,
    (
        (t_hsif.dd_uslimstart IS NULL OR t_hsif.dd_uslimstart <= CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE))
        AND
        (t_hsif.dd_uslimend IS NULL OR t_hsif.dd_uslimend >= CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE))
    ) AS kb_disp,
    CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE) AS mart_target_date,
    NOW()
FROM uslim_ve.HANSYAINFO t_hsif
WHERE EXISTS (
    SELECT 1
    FROM uslim_ve.AREAMASTER t_area
    WHERE t_hsif.cd_chiiki = t_area.cd_chiiki
);


-- DM_HANSYAINFO_POOL
TRUNCATE TABLE uslim_ve.DM_HANSYAINFO_POOL;

INSERT INTO uslim_ve.DM_HANSYAINFO_POOL (
    cd_hanbaitn,
    kb_dbcp,
    mj_dlguid,
    mart_created_at
)
SELECT
    cd_hanbaitn,
    kb_dbcp,
    mj_dlguid,
    NOW()
FROM uslim_ve.HANSYAINFO;
