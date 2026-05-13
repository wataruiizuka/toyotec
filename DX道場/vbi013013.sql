DROP TABLE IF EXISTS gold.vbi013013;
CREATE TABLE gold.vbi013013 AS
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