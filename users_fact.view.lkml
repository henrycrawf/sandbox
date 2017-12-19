view: users_fact {

   derived_table: {
    sql: SELECT
    o.user_id
    ,MIN(a.lifetime_orders) as lifetime_orders
    ,MIN(a.first_purchase) as first_purchase
    ,MIN(a.last_purchase) as last_purchase
    ,COUNT(DISTINCT(CASE WHEN o.created_at <= a.first_purchase + INTERVAL 30  DAY THEN o.id ELSE null END)) AS 30day_orders
    ,COUNT(DISTINCT(CASE WHEN o.created_at <= a.first_purchase + INTERVAL 60  DAY THEN o.id ELSE null END)) AS 60day_orders
    ,COUNT(DISTINCT(CASE WHEN o.created_at <= a.first_purchase + INTERVAL 90  DAY THEN o.id ELSE null END)) AS 90day_orders
    ,COUNT(DISTINCT(CASE WHEN o.created_at <= a.first_purchase + INTERVAL 120 DAY THEN o.id ELSE null END)) AS 120day_orders
    ,COUNT(DISTINCT(CASE WHEN o.created_at <= a.first_purchase + INTERVAL 150 DAY THEN o.id ELSE null END)) AS 150day_orders
    ,COUNT(DISTINCT(CASE WHEN o.created_at <= a.first_purchase + INTERVAL 180 DAY THEN o.id ELSE null END)) AS 180day_orders

    FROM orders o
    INNER JOIN
    (
    SELECT
    user_id as user_id
    , COUNT(*) as lifetime_orders
    , MIN(orders.created_at) as first_purchase
    , MAX(orders.created_at) as last_purchase
    FROM orders
    WHERE user_id < 10
    GROUP BY user_id
    ) a on a.user_id = o.user_id

    GROUP BY o.user_id
    ;;
    indexes: ["user_id"]  #Builds an index on the PDT for faster joins
    sql_trigger_value: SELECT_CURDATE() ;; #refreshes table at midnight. Could cause errors around etl load time
   }

   dimension: user_id {
     description: "Unique ID for each user that has ordered"
     hidden: yes
     type: number
     sql: ${TABLE}.user_id ;;
   }

   dimension: lifetime_orders {
     description: "The total number of orders for each user"
     type: number
     sql: ${TABLE}.lifetime_orders ;;
   }

  dimension: lifetime_number_of_orders_tier {
    type: tier
    style: integer
    tiers: [0, 1, 2, 3, 5, 10]
    sql: ${lifetime_orders} ;;
  }

   dimension_group: last_purchase{
     description: "The date when each user last ordered"
     type: time
     timeframes: [date, week, month, year]
     sql: ${TABLE}.last_purchase ;;
   }

  dimension_group: first_purchase{
    description: "The date when each user first ordered"
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.first_purchase ;;
  }
  measure: 30day_orders {
    type: sum
    sql: ${TABLE}.30day_orders ;;
  }

  measure: 60day_orders {
    type: sum
    sql: ${TABLE}.60day_orders ;;
  }

  measure: 90day_orders {
    type: sum
    sql: ${TABLE}.90day_orders ;;
  }

  measure: 120day_orders {
    type: sum
    sql: ${TABLE}.120day_orders ;;
  }

  measure: 150day_orders {
    type: sum
    sql: ${TABLE}.150day_orders ;;
  }

  measure: 180day_orders {
    type: sum
    sql: ${TABLE}.180day_orders ;;
  }

  measure: average_lifetime_orders {
    type: average
    value_format_name: decimal_1
    drill_fields: [lifetime_orders, users.count]
    sql: ${lifetime_orders} ;;
  }

   measure: total_lifetime_orders {
     description: "Use this for counting lifetime orders across many users"
     type: sum
     sql: ${lifetime_orders} ;;
   }
 }
