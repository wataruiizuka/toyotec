CREATE TABLE gold.DM_USERINFO_AUTH (
    cd_user               VARCHAR(50)   NOT NULL,
    cd_hansya             VARCHAR(50),
    cd_kaisya             VARCHAR(50),
    cd_hanbaitn           VARCHAR(50),
    cd_tenpo              VARCHAR(50),
    cd_syain              VARCHAR(50),
    mj_name               VARCHAR(255),
    mj_role               VARCHAR(255),
    kb_access_honten      VARCHAR(10),
    kb_access_hansya      VARCHAR(10),
    kb_access_yoyaku      VARCHAR(10),
    kb_hansya_mente       VARCHAR(10),
    kb_user_mente         VARCHAR(10),
    kb_notice_mente       VARCHAR(10),
    kb_view_kpi           VARCHAR(10),
    kb_view_proc          VARCHAR(10),
    kb_view_ucar          VARCHAR(10),
    mart_created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (cd_user)
);

CREATE TABLE gold.DM_AREAMASTER (
    cd_chiiki       VARCHAR(50)   NOT NULL,
    mj_chiiki       VARCHAR(255),
    mart_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (cd_chiiki)
);

CREATE TABLE gold.DM_HANSYA_DISPLAY (
    cd_hansya         VARCHAR(50)   NOT NULL,
    cd_kaisya         VARCHAR(50),
    cd_hanbaitn       VARCHAR(50),
    kj_hansya         VARCHAR(255),
    cd_chiiki         VARCHAR(50),
    mj_upassuse       VARCHAR(255),
    kb_disp           BOOLEAN,
    mart_target_date  DATE,
    mart_created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (cd_hansya, cd_kaisya, cd_hanbaitn)
);

CREATE TABLE gold.DM_HANSYAINFO_POOL (
    cd_hanbaitn      VARCHAR(50)   NOT NULL,
    kb_dbcp          VARCHAR(50),
    mj_dlguid        VARCHAR(255),
    mart_created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (cd_hanbaitn)
);
