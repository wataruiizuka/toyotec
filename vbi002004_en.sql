CREATE TABLE gold.vbi002004_en (
    `cd_hansya` STRING,
    `cd_kaisya` STRING,
    `cd_tenpo` STRING,
    `cd_hansya_kaisya_tenpo` STRING,
    `su_order` STRING,
    `su_registered_vehicle` STRING,
    `su_no_trade_in_vehicle_registered_this_month` STRING,
    `su_average_lead_time_for_collections_completed_this_month` STRING,
    `su_currently_registered_but_uncollected_case` STRING,
    `su_currently_registered_uncollected_amount` STRING,
    `su_registered_but_uncollected_items_from_the_previous_month` STRING,
    `su_uncollected_amount_registered_in_the_previous_month` STRING,
    `su_registered_but_uncollected_items_from_the_previous_month_or_earlier` STRING,
    `su_uncollected_amount_registered_in_the_previous_month_or_earlier` STRING,
    `su_pieces` STRING,
    `su_amount` STRING,
    `sort_order` STRING
) USING PARQUET
;
