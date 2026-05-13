DROP TABLE IF EXISTS gold.vbi999008;
CREATE TABLE gold.vbi999008 AS
SELECT
    bt.cd_hansya AS `販社コード`
    , bt.cd_kaisya AS `会社コード`
    , GROUP_CONCAT(bt.mj_message, '<br /><br />') AS `メッセージ`
FROM (
    SELECT
        bt.cd_hansya
        , bt.cd_kaisya
        , CONCAT('※店舗情報が変更されましたため、マスタ情報の設定をお願い致します<br />下記が対象の店舗となります<br />※店舗コード_店舗名の順で記載しております<br />-------------<br />', GROUP_CONCAT(bt.mj_message, '<br /><br />'), '<br />-------------') AS mj_message
    FROM (
        SELECT
            t201m.cd_hansya
            , t201m.cd_kaisya
            , CONCAT('■新規追加された店舗<br />', GROUP_CONCAT(CONCAT(t201m.cd_tenpo, '_', regexp_replace(t201m.kj_tenpomei, '　+$', '')), '、')) AS mj_message
        FROM ai21rep_ve_dx.tbv0201m t201m
        LEFT ANTI JOIN dx_ve.tbi003001m v3001m
            ON v3001m.cd_hansya = t201m.cd_hansya
            AND v3001m.cd_kaisya = t201m.cd_kaisya
            AND v3001m.cd_tenpo = t201m.cd_tenpo
        GROUP BY t201m.cd_hansya, t201m.cd_kaisya
        UNION ALL
        SELECT
            t201m.cd_hansya
            , t201m.cd_kaisya
            , CONCAT('■変更があった店舗<br />', GROUP_CONCAT(CONCAT(v3001m.cd_tenpo, '_', regexp_replace(v3001m.kj_tenpomei, '　+$', ''), '　→', t201m.cd_tenpo, '_', regexp_replace(t201m.kj_tenpomei, '　+$', '')), '、')) AS mj_message
        FROM ai21rep_ve_dx.tbv0201m t201m
        INNER JOIN dx_ve.tbi003001m v3001m
            ON v3001m.cd_hansya = t201m.cd_hansya
            AND v3001m.cd_kaisya = t201m.cd_kaisya
            AND v3001m.cd_tenpo = t201m.cd_tenpo
            AND CONCAT(v3001m.cd_tenpo, '_', regexp_replace(v3001m.kj_tenpomei, '　+$', '')) <> CONCAT(t201m.cd_tenpo, '_', regexp_replace(t201m.kj_tenpomei, '　+$', ''))
        GROUP BY t201m.cd_hansya, t201m.cd_kaisya
        UNION ALL
        SELECT
            v3001m.cd_hansya
            , v3001m.cd_kaisya
            , CONCAT('■削除された店舗<br />', GROUP_CONCAT(CONCAT(v3001m.cd_tenpo, '_', regexp_replace(v3001m.kj_tenpomei, '　+$', '')), '、'))
        FROM dx_ve.tbi003001m v3001m
        LEFT ANTI JOIN ai21rep_ve_dx.tbv0201m t201m
            ON t201m.cd_hansya = v3001m.cd_hansya
            AND t201m.cd_kaisya = v3001m.cd_kaisya
            AND t201m.cd_tenpo = v3001m.cd_tenpo
        GROUP BY v3001m.cd_hansya, v3001m.cd_kaisya
    ) bt
    GROUP BY bt.cd_hansya, bt.cd_kaisya
    UNION ALL
    SELECT
        bt.cd_hansya
        , bt.cd_kaisya
        , CONCAT('※ストール情報が変更されましたため、マスタ情報の設定をお願い致します<br />下記が対象のストールとなります<br />※ストールコード_ストール名の順で記載しております<br />-------------<br />', GROUP_CONCAT(bt.mj_message, '<br /><br />'), '<br />-------------')
    FROM (
        SELECT
            t001m.cd_hansya
            , t001m.cd_kaisya
            , CONCAT('■新規追加されたストール<br />', GROUP_CONCAT(CONCAT(CAST(t001m.no_stall AS string), '_', t001m.mj_stallmei), '、')) AS mj_message
        FROM ai21rep_ve_dx.tbsa001m t001m
        LEFT SEMI JOIN ai21rep_ve_dx.tbv0201m t201m
            ON t201m.cd_hansya = t001m.cd_hansya
            AND t201m.cd_kaisya = t001m.cd_kaisya
            AND t201m.cd_tenpo = t001m.cd_tenpo
        LEFT ANTI JOIN dx_ve.tbi003002m v3002m
            ON v3002m.cd_hansya = t001m.cd_hansya
            AND v3002m.cd_kaisya = t001m.cd_kaisya
            AND v3002m.cd_tenpo = t001m.cd_tenpo
            AND v3002m.no_stall = t001m.no_stall
        GROUP BY t001m.cd_hansya, t001m.cd_kaisya
        UNION ALL
        SELECT
            t001m.cd_hansya
            , t001m.cd_kaisya
            , CONCAT('■変更があったストール<br />', GROUP_CONCAT(CONCAT(CAST(v3002m.no_stall AS string), '_', v3002m.mj_stallmei, '　→', CAST(t001m.no_stall AS string), '_', t001m.mj_stallmei), '、'))
        FROM ai21rep_ve_dx.tbsa001m t001m
        LEFT SEMI JOIN ai21rep_ve_dx.tbv0201m t201m
            ON t201m.cd_hansya = t001m.cd_hansya
            AND t201m.cd_kaisya = t001m.cd_kaisya
            AND t201m.cd_tenpo = t001m.cd_tenpo
        INNER JOIN dx_ve.tbi003002m v3002m
            ON v3002m.cd_hansya = t001m.cd_hansya
            AND v3002m.cd_kaisya = t001m.cd_kaisya
            AND v3002m.cd_tenpo = t001m.cd_tenpo
            AND v3002m.no_stall = t001m.no_stall
            AND CONCAT(CAST(v3002m.no_stall AS string), '_', v3002m.mj_stallmei) <> CONCAT(CAST(t001m.no_stall AS string), '_', t001m.mj_stallmei)
        GROUP BY t001m.cd_hansya, t001m.cd_kaisya
        UNION ALL
        SELECT
            v3002m.cd_hansya
            , v3002m.cd_kaisya
            , CONCAT('■削除されたストール<br />', GROUP_CONCAT(CONCAT(CAST(v3002m.no_stall AS string), '_', v3002m.mj_stallmei), '、'))
        FROM dx_ve.tbi003002m v3002m
        LEFT SEMI JOIN ai21rep_ve_dx.tbv0201m t201m
            ON t201m.cd_hansya = v3002m.cd_hansya
            AND t201m.cd_kaisya = v3002m.cd_kaisya
            AND t201m.cd_tenpo = v3002m.cd_tenpo
        LEFT ANTI JOIN ai21rep_ve_dx.tbsa001m t001m
            ON t001m.cd_hansya = v3002m.cd_hansya
            AND t001m.cd_kaisya = v3002m.cd_kaisya
            AND t001m.cd_tenpo = v3002m.cd_tenpo
            AND t001m.no_stall = v3002m.no_stall
        GROUP BY v3002m.cd_hansya, v3002m.cd_kaisya
    ) bt
    GROUP BY bt.cd_hansya, bt.cd_kaisya
    UNION ALL
    SELECT
        bt.cd_hansya
        , bt.cd_kaisya
        , CONCAT('※新車車種情報が変更されましたため、マスタ情報の設定をお願い致します<br />下記が対象の車名となります<br />※車名コード_車名の順で記載しております<br />-------------<br />', GROUP_CONCAT(bt.mj_meaasge, '<br /><br />'), '<br />-------------')
    FROM (
        SELECT
            tf001m.cd_hansya
            , tf001m.cd_kaisya
            , CONCAT('■新規追加された車種<br />',GROUP_CONCAT(CONCAT(tf001m.cd_ncsyamei, '_', regexp_replace(tf001m.kn_syame, '[　| ]+$', ''), '_', regexp_replace(tf001m.kj_kurumame, '[　| ]+$', '')), '、')) AS mj_meaasge
        FROM ai21rep_ve_dx.tbbf001m tf001m
        LEFT ANTI JOIN dx_ve.tbi999008m t9008m
            ON t9008m.cd_hansya = tf001m.cd_hansya
            AND t9008m.cd_kaisya = tf001m.cd_kaisya
            AND t9008m.cd_ncsyamei = tf001m.cd_ncsyamei
        GROUP BY tf001m.cd_hansya, tf001m.cd_kaisya
        UNION ALL
        SELECT
            tf001m.cd_hansya
            , tf001m.cd_kaisya
            , CONCAT('■変更があった車種<br />',GROUP_CONCAT(CONCAT(t9008m.cd_ncsyamei, '_', regexp_replace(t9008m.kn_syamei, '[　| ]+$', ''), '_', regexp_replace(t9008m.kj_kurumame, '[　| ]+$', ''), '　→', tf001m.cd_ncsyamei, '_', regexp_replace(tf001m.kn_syame, '[　| ]+$', ''), '_', regexp_replace(tf001m.kj_kurumame, '[　| ]+$', '')), '<br />'))
        FROM ai21rep_ve_dx.tbbf001m tf001m
        INNER JOIN dx_ve.tbi999008m t9008m
            ON t9008m.cd_hansya = tf001m.cd_hansya
            AND t9008m.cd_kaisya = tf001m.cd_kaisya
            AND t9008m.cd_ncsyamei = tf001m.cd_ncsyamei
            AND CONCAT(regexp_replace(t9008m.kn_syamei, '[　| ]+$', ''), '_', regexp_replace(t9008m.kj_kurumame, '[　| ]+$', '')) <> CONCAT(regexp_replace(tf001m.kn_syame, '[　| ]+$', ''), '_', regexp_replace(tf001m.kj_kurumame, '[　| ]+$', ''))
        GROUP BY tf001m.cd_hansya, tf001m.cd_kaisya
        UNION ALL
        SELECT
            t9008m.cd_hansya
            , t9008m.cd_kaisya
            , CONCAT('■削除された車種<br />',GROUP_CONCAT(CONCAT(t9008m.cd_ncsyamei, '_', regexp_replace(t9008m.kn_syamei, '[　| ]+$', ''), '_', regexp_replace(t9008m.kj_kurumame, '[　| ]+$', '')), '、'))
        FROM dx_ve.tbi999008m t9008m
        LEFT ANTI JOIN ai21rep_ve_dx.tbbf001m tf001m
            ON tf001m.cd_hansya = t9008m.cd_hansya
            AND tf001m.cd_kaisya = t9008m.cd_kaisya
            AND tf001m.cd_ncsyamei = t9008m.cd_ncsyamei
        GROUP BY t9008m.cd_hansya, t9008m.cd_kaisya
    ) bt
    GROUP BY bt.cd_hansya, bt.cd_kaisya
    UNION ALL
    SELECT
        bt.cd_hansya
        , bt.cd_kaisya
        , CONCAT('※中古車車種情報が変更されましたため、マスタ情報の設定をお願い致します<br />下記が対象の車名となります<br />※車名コード_車名の順で記載しております<br />-------------<br />', GROUP_CONCAT(bt.mj_meaasge, '<br /><br />'), '<br />-------------')
    FROM (
        SELECT
            t0232m.cd_hansya
            , t0232m.cd_kaisya
            , CONCAT('■新規追加された車種<br />',GROUP_CONCAT(CONCAT(t0232m.cd_syamei, '_', regexp_replace(t0232m.mj_syamei, '[　| ]+$', ''), '_', regexp_replace(t0232m.kj_syamei, '[　| ]+$', '')), '、')) AS mj_meaasge
        FROM ai21rep_ve_dx.tbv0232m t0232m
        LEFT ANTI JOIN dx_ve.tbi999009m t9009m
            ON t9009m.cd_hansya = t0232m.cd_hansya
            AND t9009m.cd_kaisya = t0232m.cd_kaisya
            AND t9009m.cd_ocsyamei = t0232m.cd_syamei
        WHERE t0232m.mj_syamei IS NOT NULL
        GROUP BY t0232m.cd_hansya, t0232m.cd_kaisya
        UNION ALL
        SELECT
            t0232m.cd_hansya
            , t0232m.cd_kaisya
            , CONCAT('■変更があった車種<br />',GROUP_CONCAT(CONCAT(t9009m.cd_ocsyamei, '_', regexp_replace(t9009m.kn_syame, '[　| ]+$', ''), '_', regexp_replace(t9009m.kj_kurumame, '[　| ]+$', ''), '　→', t0232m.cd_syamei, '_', regexp_replace(t0232m.mj_syamei, '[　| ]+$', ''), '_', regexp_replace(t0232m.kj_syamei, '[　| ]+$', '')), '、'))
        FROM ai21rep_ve_dx.tbv0232m t0232m
        INNER JOIN dx_ve.tbi999009m t9009m
            ON t9009m.cd_hansya = t0232m.cd_hansya
            AND t9009m.cd_kaisya = t0232m.cd_kaisya
            AND t9009m.cd_ocsyamei = t0232m.cd_syamei
            AND CONCAT(t9009m.cd_ocsyamei, '_', regexp_replace(t9009m.kn_syame, '[　| ]+$', ''), '_', regexp_replace(t9009m.kj_kurumame, '[　| ]+$', '')) <> CONCAT(t0232m.cd_syamei, '_', regexp_replace(t0232m.mj_syamei, '[　| ]+$', ''), '_', regexp_replace(t0232m.kj_syamei, '[　| ]+$', ''))
        WHERE t0232m.mj_syamei IS NOT NULL
        GROUP BY t0232m.cd_hansya, t0232m.cd_kaisya
        UNION ALL
        SELECT
            t9009m.cd_hansya
            , t9009m.cd_kaisya
            , CONCAT('■削除された車種<br />',GROUP_CONCAT(CONCAT(t9009m.cd_ocsyamei, '_', regexp_replace(t9009m.kn_syame, '[　| ]+$', ''), '_', regexp_replace(t9009m.kj_kurumame, '[　| ]+$', '')), '、'))
        FROM dx_ve.tbi999009m t9009m
        LEFT ANTI JOIN ai21rep_ve_dx.tbv0232m t0232m
            ON t0232m.cd_hansya = t9009m.cd_hansya
            AND t0232m.cd_kaisya = t9009m.cd_kaisya
            AND t0232m.cd_syamei = t9009m.cd_ocsyamei
        WHERE t9009m.kn_syame IS NOT NULL
        GROUP BY t9009m.cd_hansya, t9009m.cd_kaisya
    ) bt
    GROUP BY bt.cd_hansya, bt.cd_kaisya
    UNION ALL
    SELECT
        bt.cd_hansya
        , bt.cd_kaisya
        , CONCAT('※入金区分情報が変更されましたため、マスタ情報の設定をお願い致します<br />下記が対象の入金区分となります<br />※入金区分コード_入金区分名の順で記載しております<br />-------------<br />', GROUP_CONCAT(bt.mj_message, '<br /><br />'), '<br />-------------') mj_message
    FROM
        (
        SELECT
            tbv0208m.cd_hansya
            , tbv0208m.cd_kaisya
            , CONCAT('■新規追加された入金区分<br />', GROUP_CONCAT(CONCAT(tbv0208m.kb_nyuukin, '_', regexp_replace(tbv0208m.kj_nyuukinm, '　+$', '')), '、')) mj_message
        FROM
            ai21rep_ve_dx.tbv0208m tbv0208m
            LEFT ANTI
        JOIN dx_ve.tbi999013m tbi999013m
        ON
            tbv0208m.cd_hansya = tbi999013m.cd_hansya
        AND tbv0208m.cd_kaisya = tbi999013m.cd_kaisya
        AND tbv0208m.kb_nyuukin = tbi999013m.kb_nyuukin
        GROUP BY
            tbv0208m.cd_hansya,
            tbv0208m.cd_kaisya
    UNION ALL
    SELECT
            tbv0208m.cd_hansya
            , tbv0208m.cd_kaisya
            , CONCAT('■変更があった入金区分<br />', GROUP_CONCAT(CONCAT(regexp_replace(tbi999013m.kj_nyuukinm, '　+$', ''), '　→', regexp_replace(tbv0208m.kj_nyuukinm, '　+$', '')), '、')) mj_message
        FROM
            ai21rep_ve_dx.tbv0208m tbv0208m
        INNER JOIN dx_ve.tbi999013m tbi999013m
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
            tbi999013m.cd_hansya
            , tbi999013m.cd_kaisya
            , CONCAT('■削除された入金区分<br />', GROUP_CONCAT(regexp_replace(tbi999013m.kj_nyuukinm, '　+$', ''), '、'))
        FROM
            dx_ve.tbi999013m tbi999013m
        JOIN ai21rep_ve_dx.tbv0208m tbv0208m
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
;
