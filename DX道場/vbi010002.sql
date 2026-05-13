DROP TABLE IF EXISTS gold.vbi010002;
CREATE TABLE gold.vbi010002 AS
SELECT
    t201m.cd_hansya AS 販社コード
    , t201m.cd_kaisya AS 会社コード
    , t201m.cd_tenpo AS 店舗コード
    , CONCAT(t201m.cd_hansya, t201m.cd_kaisya, t201m.cd_tenpo) AS 販社会社店舗
    , NVL(newcar.新車軽OEM数, 0) AS 新車軽OEM数
    , NVL(newcar.新車登録車数, 0) AS 新車登録車数
    , NVL(newcar.新車軽OEM収益, 0) AS 新車軽OEM収益
    , NVL(newcar.新車登録収益, 0) AS 新車登録収益
    , NVL(newcar.新車軽OEM売上, 0) AS 新車軽OEM売上
    , NVL(newcar.新車登録売上, 0) AS 新車登録売上
    , NVL(ucar.TAD販売実績, 0) AS TAD販売実績
    , NVL(ucar.TAD売上実績, 0) AS TAD売上実績
    , NVL(ucar.TAD収益実績, 0) AS TAD収益実績
    , NVL(tbv0014m_newcar.staffCount, 0) AS 新車スタッフ数
    , NVL(ucar.UCar小売, 0) AS UCar小売
    , NVL(ucar.UCar卸, 0) AS UCar卸
    , NVL(ucar.UCar卸収益, 0) AS UCar卸収益
    , NVL(ucar.UCar小売売上, 0) AS UCar小売売上
    , NVL(ucar.UCar卸売上, 0) AS UCar卸売上
    , NVL(ucar.UCar小売収益, 0) AS UCar小売収益
    , NVL(tbv0014m_ucar.staffCount, 0) AS Ucarスタッフ数
FROM
    ai21rep_ve_dx.tbv0201m t201m
LEFT JOIN
    ON (
    SELECT
        cd_hansya
        , cd_kaisya
        , cd_tenpo
        , SUM(新車数) AS 新車数
        , SUM(CASE WHEN 軽区分 = '1' THEN 新車数 ELSE 0 END) AS 新車軽OEM数
        , SUM(CASE WHEN NVL(軽区分,'') != '1' THEN 新車数 ELSE 0 END) AS 新車登録車数
        , SUM(CASE WHEN 軽区分 = '1' THEN rieki ELSE 0 END) AS 新車軽OEM収益
        , SUM(CASE WHEN NVL(軽区分,'') != '1' THEN rieki ELSE 0 END) AS 新車登録収益
        , SUM(CASE WHEN 軽区分 = '1' THEN uriage ELSE 0 END) AS 新車軽OEM売上
        , SUM(CASE WHEN NVL(軽区分,'') != '1' THEN uriage ELSE 0 END) AS 新車登録売上
    FROM
        (
        SELECT
            tbba001g.cd_hansya
            , tbba001g.cd_kaisya
            , tbba001g.cd_tenpo
            , SUM(calflg) AS 新車数
            , tbbf001m.kn_kei AS 軽区分
            , SUM(calflg * (NVL(TBBA052G.ki_syryhnzk, 0)+ NVL(tbba052g.SU_MAKOBY1, 0) + NVL(tbba052g.SU_MAKOBY2, 0) + NVL(tbba052g.SU_MAKOBY3, 0) +
            NVL(tbba052g.SU_MAKOBY4, 0) + NVL(tbba052g.SU_MAKOBY5, 0) + NVL(tbba052g.SU_MAKOBY6, 0) +
            NVL(tbba052g.SU_MAKOBY7, 0) + NVL(tbba052g.SU_MAKOBY8, 0) + NVL(tbba052g.SU_MAKOBY9, 0) +
            NVL(tbba052g.SU_MAKOBY10, 0) + NVL(tbba052g.SU_MAKOBY11, 0) + NVL(tbba052g.SU_MAKOBY12, 0) +
            NVL(tbba052g.SU_MAKOBY13, 0) + NVL(tbba052g.SU_MAKOBY14, 0) + NVL(tbba052g.SU_MAKOBY15, 0) +
            NVL(tbba052g.SU_MAKOBY16, 0) - NVL(tbba052g.ki_syryhnez, 0))) AS uriage,
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
                NVL(tbba052g.KI_KAZETESK, 0) + NVL(tbba052g.KI_KENSATES, 0) + NVL(tbba052g.KI_SYKOSYTE, 0) +
                NVL(tbba052g.KI_SITATOTS, 0) + NVL(tbba052g.KI_NINHOTHI, 0) + NVL(tbba052g.KI_DORSVKAN, 0) +
                NVL(tbba052g.KI_NINHOKNR, 0) + NVL(tbba054g.KI_NINAZUK, 0) -
                (NVL(tbba052g.KI_KENSGENK, 0) + NVL(tbba052g.KI_SYKOHIGE, 0) + NVL(tbba052g.KI_NOSYHKGE, 0) + NVL(TBBA053G.KI_NINSYHKG, 0) +
                NVL(tbba052g.KI_KENSTESK, 0) + NVL(tbba052g.KI_SYKOTEKA, 0) + NVL(tbba052g.KI_NINHTHIG, 0) +
                NVL(tbba052g.KI_DORSVKAK, 0) + NVL(tbba054g.KI_NINAZUKG, 0) + NVL(tbba052g.KI_NINHOKGE, 0) +
                NVL(tbba052g.KI_SITATSKA, 0) + NVL(tbba052g.KI_SITAKANG, 0) + NVL(tbba052g.KI_SITSATKA, 0) ) - NVL(tbba052g.KI_SYSNHOKN, 0) +
                    NVL(tbba055g.ki_kaptesu, 0) - (
                        CASE WHEN (NVL(tbba055g.ki_kaptesu, 0) + NVL(tbba052g.ki_kaptesuN, 0)) >= 0
                        THEN TRUNC(NVL(tbba055g.ki_kaptesu, 0) * NVL(tbi010001m.NU_KAPTESG, 0) / 100)
                        ELSE NVL(tbba055g.ki_kaptesu, 0) - TRUNC(NVL(tbba055g.ki_kaptesu, 0) * NVL(tbi010001m.NU_KAPTESG, 0) / 100)
                           END
                )
                )) AS rieki
        FROM
            (
            SELECT
                tbba001g.cd_hansya
                , tbba001g.cd_kaisya
                , tbba001g.cd_tenpo
                , tbba001g.no_cyumon
                , tbba001g.no_cyumoned
                , tbba001g.mj_sinkysed
                , tbba001g.mj_gaihansy
                , tbba001g.mj_hantenkt
                , (CASE
                    WHEN ft168g.dd_torokei IS NULL THEN tbba001g.dd_uriagekj
                    ELSE ft168g.dd_torokei
                END) AS 日付,
                1 AS calflg
            FROM
                ai21rep_ve_dx.tbba001g tbba001g
            LEFT JOIN(
                SELECT
                    t168g.cd_hansya
                    , t168g.cd_kaisya
                    , t168g.no_cyumon
                    , min(t168g.dd_torokei) AS dd_torokei
                FROM ai21rep_ve_dx.tbbg168g t168g
                WHERE
                    t168g.no_gyomu = '07'
                AND t168g.no_syori = '01'
                GROUP BY t168g.cd_hansya, t168g.cd_kaisya, t168g.no_cyumon
            ) ft168g ON
                ft168g.cd_kaisya = tbba001g.cd_kaisya
                AND ft168g.cd_hansya = tbba001g.cd_hansya
                AND ft168g.no_cyumon = tbba001g.no_cyumon
            WHERE
                tbba001g.kb_haraidas NOT IN ('00', '40')
                AND tbba001g.dd_jucyuke IS NOT NULL
                AND ( (ft168g.dd_torokei IS NULL AND tbba001g.dd_uriagekj >= TRUNC(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM'))
                    OR  (ft168g.dd_torokei IS NOT NULL
                    AND ft168g.dd_torokei >= TRUNC(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM'))
                )
            UNION ALL
                SELECT
                    tbba001g.cd_hansya
                    , tbba001g.cd_kaisya
                    , tbba001g.cd_tenpo
                    , tbba001g.no_cyumon
                    , tbba001g.no_cyumoned
                    , tbba001g.mj_sinkysed
                    , tbba001g.mj_gaihansy
                    , tbba001g.mj_hantenkt
                    , tbba001g.dd_uritrkkj AS 日付
                    , -1 AS calflg
                FROM
                    ai21rep_ve_dx.tbba001g tbba001g
                WHERE
                    tbba001g.kb_haraidas NOT IN ('00', '40')
                    AND tbba001g.dd_jucyuke IS NOT NULL
                    AND tbba001g.dd_uritrkkj >= TRUNC(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM')
        ) tbba001g
        LEFT JOIN ai21rep_ve_dx.tbbf008m TBBF008M
            ON tbba001g.cd_kaisya = tbbf008m.cd_kaisya
            AND tbba001g.cd_hansya = tbbf008m.cd_hansya
            AND tbba001g.mj_sinkysed = tbbf008m.mj_sinkysed
            AND tbba001g.mj_gaihansy = tbbf008m.cd_spec
            AND tbba001g.mj_hantenkt = tbbf008m.mj_hantenkt
            AND tbbf008m.kb_spec = 'G'
            LEFT JOIN ai21rep_ve_dx.tbbf001m tbbf001m
                ON
                tbbf001m.cd_kaisya = tbbf008m.cd_kaisya
                AND tbbf001m.cd_hansya = tbbf008m.cd_hansya
                AND tbbf001m.cd_ncsyamei = tbbf008m.mj_syamei
            LEFT JOIN ai21rep_ve_dx.tbba052g tbba052g
                ON tbba001g.cd_hansya = tbba052g.cd_hansya
                AND tbba001g.cd_kaisya = tbba052g.cd_kaisya
                AND tbba001g.no_cyumon = tbba052g.no_cyumon
                AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba052g.no_cyumoned)
                LEFT JOIN (
                    SELECT
                        tbba054g.cd_hansya
                        , tbba054g.cd_kaisya
                        , tbba054g.no_cyumon
                        , tbba054g.no_cyumoned
                        , SUM(KI_NINAZUK) AS KI_NINAZUK
                        , SUM(KI_NINAZUKG) AS KI_NINAZUKG
                    FROM
                        ai21rep_ve_dx.tbba054g tbba054g
                    WHERE
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
                        TBBA053G.cd_hansya
                        , TBBA053G.cd_kaisya
                        , TBBA053G.no_cyumon
                        , TBBA053G.no_cyumoned
                        , sum(KI_NINSYHKG) AS KI_NINSYHKG
                    FROM
                        ai21rep_ve_dx.tbba053g TBBA053G
                    WHERE
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
                        tbba055g.cd_hansya
                        , tbba055g.cd_kaisya
                        , tbba055g.no_cyumon
                        , tbba055g.no_cyumoned
                        , sum(ki_kaptesu) AS ki_kaptesu
                    FROM
                        ai21rep_ve_dx.tbba055g TBBA055G
                    WHERE
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
            LEFT JOIN dx_ve.tbi010001m tbi010001m
                ON tbba001g.cd_hansya = tbi010001m.cd_hansya
                AND tbba001g.cd_kaisya = tbi010001m.cd_kaisya
                AND tbba001g.cd_tenpo = tbi010001m.cd_tenpo
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
        tbv0014m.cd_hansya
        , tbv0014m.cd_kaisya
        , tbv0014m.cd_syozoten
        , COUNT(1) AS staffCount
    FROM
        ai21rep_ve_dx.tbv0014m tbv0014m
    WHERE
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
    ON (
    SELECT
        cd_hansya
        , cd_kaisya
        , cd_jytyuten
        , SUM(CASE WHEN 売上区分 = '11' THEN Ucar販売数 ELSE 0 END) AS UCar小売
        , SUM(CASE WHEN 売上区分 = '20' THEN Ucar販売数 ELSE 0 END) AS UCar卸
        , SUM(CASE WHEN 売上区分 = '11' THEN ucar売上 ELSE 0 END) AS UCar小売売上
        , SUM(CASE WHEN 売上区分 = '20' THEN ucar売上 ELSE 0 END) AS UCar卸売上
        , SUM(CASE WHEN 売上区分 = '11' THEN 収益 ELSE 0 END) AS UCar小売収益
        , SUM(CASE WHEN 売上区分 = '20' THEN 収益 ELSE 0 END) AS UCar卸収益
        , SUM(CASE WHEN 売上区分 = '14' THEN Ucar販売数 ELSE 0 END) AS TAD販売実績
        , SUM(CASE WHEN 売上区分 = '14' THEN ucar売上 ELSE 0 END) AS TAD売上実績
        , SUM(CASE WHEN 売上区分 = '14' THEN 収益 ELSE 0 END) AS TAD収益実績
    FROM
        (
        SELECT
            tbbc017g.cd_hansya
            , tbbc017g.cd_kaisya
            , tbbc017g.cd_jytyuten
            , tbbc017g.日付
            , tbbc017g.kb_uriage AS 売上区分
            , SUM(calflg) AS Ucar販売数
            , SUM(CASE WHEN NVL(tbbc020g.kb_mntpkkei, '') != '' THEN tbbc017g.calflg ELSE 0 END)  AS UCar入会数
            , SUM(calflg * (NVL(tbbc020g.ki_syryhnzk, 0) - NVL(tbbc020g.ki_syryhnez, 0))) AS ucar売上
            , SUM (calflg * (NVL(tbbc020g.ki_syryohon, 0) - NVL(tbbc020g.ki_syryoneb, 0) - (NVL(tbbc020g.ki_syryogen, 0) + NVL(TBBC001G.nu_kanrikgn, 0)) +
            (NVL(tbbc020g.ki_fuzkbuyk, 0) - NVL(tbbc020g.KI_FUZKHNNB, 0) + NVL(tbbc020g.ki_spsiybyk, 0) - NVL(tbbc020g.KI_SPSIYNEB, 0)) - NVL(tbbc020g.ki_sokamitu, 0)
            + NVL(tbbc020g.ki_nahnjibs, 0) - (NVL(tbbc020g.ki_mntpryok, 0) + NVL(tbbc020g.ki_seunetes, 0) + (NVL(tbbc020g.ki_glinkhiy, 0) -
            NVL(tbbc020g.ki_glinktes, 0))) + NVL(tbbc020g.nu_syrykage, 0) + NVL(tbbc020g.nu_syukage, 0) - NVL(tbbc020g.ki_hanbaihi, 0) - NVL(tbbc020g.ki_zaneksit, 0)
            - NVL(tbbc020g.ki_tasonkin, 0)+ NVL(tbbc020g.nu_sntkagen, 0) -
            (CASE
                WHEN tbbc017g.su_joknhens = 0 THEN TBPF070M.ki_honbkanr
                WHEN tbbc017g.su_joknhens>0 THEN tbbc020g.ki_zanehobk
            END) )) AS 収益
        FROM
            (
            SELECT
                tbbc017g.cd_hansya
                , tbbc017g.cd_kaisya
                , tbbc017g.cd_jytyuten
                , tbbc017g.no_cyumon
                , tbbc017g.no_cyumoned
                , tbbc017g.no_syaryou
                , tbbc017g.kb_uriage
                , tbbc017g.su_joknhens
                , (CASE
                    WHEN ft8006.dd_uriage IS NULL THEN tbbc017g.dd_uriagekj
                    ELSE to_timestamp(CAST(ft8006.dd_uriage AS string), 'yyyyMMdd HH:mm:ss')
                END) AS 日付,
                1 AS calflg
            FROM
                ai21rep_ve_dx.tbbc017g tbbc017g
            LEFT JOIN
                ON (
                SELECT
                    t8006.cd_hansya
                    , t8006.cd_kaisya
                    , t8006.no_cyumon
                    , MIN(t8006.dd_uriage) AS dd_uriage
                FROM
                    ai21rep_ve_dx.tbg8006m t8006
                GROUP BY
                    t8006.cd_hansya,
                    t8006.cd_kaisya,
                    t8006.no_cyumon
                )ft8006 ON
                tbbc017g.cd_kaisya = ft8006.cd_kaisya
                AND tbbc017g.cd_kaisya = ft8006.cd_kaisya
                AND tbbc017g.no_cyumon = ft8006.no_cyumon
                AND tbbc017g.dd_uritorik IS NULL
            WHERE
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
                tbbc017g.cd_hansya
                , tbbc017g.cd_kaisya
                , tbbc017g.cd_jytyuten
                , tbbc017g.no_cyumon
                , tbbc017g.no_cyumoned
                , tbbc017g.no_syaryou
                , tbbc017g.kb_uriage
                , tbbc017g.su_joknhens
                , tbbc017g.dd_uritorik
                , -1 AS calflg
            FROM
                ai21rep_ve_dx.tbbc017g tbbc017g
            WHERE
                tbbc017g.dd_jucyuke IS NOT NULL
                AND tbbc017g.dd_uritorik >= TRUNC(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM')
        ) tbbc017g
        LEFT JOIN ai21rep_ve_dx.tbbc001g TBBC001G
            ON TBBC001G.cd_kaisya = tbbc017g.cd_kaisya
            AND TBBC001G.cd_hansya = tbbc017g.cd_hansya
            AND TBBC001G.no_syaryou = tbbc017g.no_syaryou
        LEFT JOIN ai21rep_ve_dx.tbbc020g tbbc020g
            ON tbbc017g.cd_hansya = tbbc020g.cd_hansya
            AND tbbc017g.cd_kaisya = tbbc020g.cd_kaisya
            AND tbbc017g.no_cyumon = tbbc020g.no_cyumon
            AND TRIM(tbbc017g.no_cyumoned) = TRIM(tbbc020g.no_cyumoned)
        LEFT JOIN ai21rep_ve_dx.tbpf070m TBPF070M
            ON tbbc017g.cd_hansya = TBPF070M.cd_hansya
            AND tbbc017g.cd_kaisya = TBPF070M.cd_kaisya
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
        tbv0014m.cd_hansya
        , tbv0014m.cd_kaisya
        , tbv0014m.cd_syozoten
        , COUNT(1) AS staffCount
    FROM
        ai21rep_ve_dx.tbv0014m tbv0014m
    WHERE
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
;
