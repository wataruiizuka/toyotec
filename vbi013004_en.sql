CREATE TABLE gold.vbi013004_en (
    `cd_hansya` STRING,
    `cd_kaisya` STRING,
    `cd_jytyuten` STRING,
    `cd_hansya_kaisya_jytyuten` STRING,
    `su_jucyu` STRING,
    `su_uketuke` STRING,
    `no_trade_in_vehicles_registered_this_month` STRING,
    `currently_registered_but_uncollected_cases` STRING,
    `currently_registered_uncollected_amount` STRING,
    `registered_but_uncollected_items_from_the_previous_month` STRING,
    `uncollected_amount_registered_in_the_previous_month` STRING,
    `uncollected_cases_registered_two_months_prior` STRING,
    `uncollected_amount_registered_two_months_prior` STRING,
    `su_pieces` STRING,
    `su_amount` STRING,
    `mj_sortjyun` STRING
) USING PARQUET
;
