DROP TABLE IF EXISTS gold.vbi013004;
CREATE TABLE gold.vbi013004 AS
SELECT
    cd_hansya AS `販社コード`
    , cd_kaisya AS `会社コード`
    , cd_jytyuten AS `店舗コード`
    , cd_hansya_kaisya_jytyuten AS `販社会社店舗コード`
    , su_jucyu AS `受注台数`
    , su_touroku AS `登録台数`
    , no_trade_in_vehicles_registered_this_month AS `当月登録内下取車なし`
    , currently_registered_but_uncollected_cases AS `現在登録済未回収件数`
    , currently_registered_uncollected_amount AS `現在登録済未回収金額`
    , registered_but_uncollected_items_from_the_previous_month AS `前月登録済未回収件数`
    , uncollected_amount_registered_in_the_previous_month AS `前月登録済未回収金額`
    , uncollected_cases_registered_two_months_prior AS `前々月以前登録済未回収件数`
    , uncollected_amount_registered_two_months_prior AS `前々月以前登録済未回収金額`
    , su_pieces AS `件数`
    , su_amount AS `金額`
    , mj_sortjyun AS `ソート順`
FROM dx_ve.vbi013004_en vbi013004