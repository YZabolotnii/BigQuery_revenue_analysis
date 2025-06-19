-- знаходимо загальну виручку та виручку за типами пристроїв по кожному континенту
WITH revenue_usd AS (
    SELECT
      sp.continent
      , round(sum(p.price), 2) as revenue
      , round(sum(case when sp.device = 'mobile' then p.price end), 2) as revenue_from_mobile
      , round(sum(case when sp.device = 'desktop' then p.price end), 2) as revenue_from_desktop
    FROM `product` p
    JOIN `order` o
    ON p.item_id = o.item_id
    RIGHT JOIN `session_params` sp
    ON sp.ga_session_id = o.ga_session_id
    GROUP BY 1
),
-- обчислюємо загальну виручку по всіх континентах
revenue_percent AS (
    SELECT DISTINCT
      sp.continent
      , sum(p.price) over() as revenue_total
    FROM `product` p
    JOIN `order` o
    ON p.item_id = o.item_id
    RIGHT JOIN `session_params` sp
    ON sp.ga_session_id = o.ga_session_id
),
-- рахуємо сесії, кількість унікальних акаунтів та перевірених акаунтів по континенту
account_info AS (
    SELECT
      sp.continent
      , count(sp.ga_session_id) as session_cnt
      , count(distinct acs.account_id) as account_cnt
      , count(case when ac.is_verified = 1 then ac.id end) as verified_account
    FROM `session_params` sp
    LEFT JOIN `account_session` acs
    ON sp.ga_session_id = acs.ga_session_id
    LEFT JOIN `account` ac
    ON ac.id = acs.account_id
    GROUP BY 1
)
-- об'єднуємо дані з усіх трьох CTE
SELECT
  r.continent
  , r.revenue
  , r.revenue_from_mobile
  , r.revenue_from_desktop
  , round(r.revenue / rpc.revenue_total * 100, 2) as revenue_from_total
  , aci.account_cnt
  , aci.verified_account
  , aci.session_cnt
FROM revenue_usd r
JOIN revenue_percent rpc
ON r.continent = rpc.continent
JOIN account_info aci
ON r.continent = aci.continent






