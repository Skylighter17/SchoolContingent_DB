-- Получить список представителей, у которых есть более одного подопечного
SELECT rod.representative_id,
       rod.last_name,
       rod.first_name,
       rod.middle_name,
       COUNT(DISTINCT child_id) AS "num_of_children"
FROM representative rod
JOIN representation bond USING (representative_id)
GROUP BY rod.representative_id, last_name, first_name, middle_name
HAVING COUNT(DISTINCT child_id) >= 2
ORDER BY num_of_children DESC;


-- Вывести список детей с их классами и порядковым номером ребёнка в классе
SELECT c.last_name,
       first_name,
       middle_name,
       class_name,
       ROW_NUMBER() OVER (PARTITION BY (class_name)
           ORDER BY CONCAT(last_name, ' ', first_name, ' ', middle_name))
FROM child c
JOIN application a ON c.child_id = a.child_id
JOIN personalrecord pr ON pr.application_id = a.application_id
JOIN class cl ON pr.class_id = cl.class_id
ORDER BY class_name;


-- Для каждого класса вывести ученика, его дату рождения и средний возраст детей
SELECT cl.class_name,
       c.last_name,
       c.first_name,
       c.middle_name,
       c.birth_date,
       AVG(DATE_PART('year', AGE(CURRENT_TIMESTAMP, c.birth_date)))
       OVER (PARTITION BY class_name)
FROM child c
JOIN application a USING (child_id)
JOIN personalrecord pr USING (application_id)
JOIN class cl USING (class_id)
ORDER BY class_name;

-- Найти всех детей, у которых есть аттестат с отличием,
-- а также вывести количество отличников в каждом классе
SELECT
    cl.class_name AS "Класс",
    c.last_name || ' ' || c.first_name || ' ' || c.middle_name AS "ФИО",
    COUNT(*) OVER (PARTITION BY cl.class_name) AS "Кол-во отличников в классе",
    d.diploma_name AS "Название аттестата"
FROM Class cl
JOIN PersonalRecord pr ON cl.class_id = pr.class_id
JOIN application a ON pr.application_id = a.application_id
JOIN Child c ON a.child_id = c.child_id
JOIN Graduate g ON pr.record_id = g.record_id
JOIN Diploma d ON g.graduate_id = d.graduate_id
WHERE d.diploma_name LIKE '%с отличием%';

-- Функция, которая выдаст количество отчислений в определенную школу за определенный период
CREATE OR REPLACE FUNCTION count_orders_by_type_reason_period(
    p_order_type VARCHAR,
    p_order_basis VARCHAR,
    p_start_date DATE,
    p_end_date DATE
)
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM AcademicOrder ao
        WHERE order_type = p_order_type
          AND basis = p_order_basis
          AND issue_date BETWEEN p_start_date AND p_end_date
    );
END;
$$ LANGUAGE plpgsql;


SELECT count_orders_by_type_reason_period('Об отчислении',
    'Заявление родителя о переводе в ГБОУ Школа № 1234',
    '2023-09-01',
    '2025-09-05'
) AS "Количество приказов";



-- Создать отчет по отчислениям за определенный период
WITH filtered_orders AS (
  SELECT reason_name
  FROM OrderReason
  JOIN public.academicorder a ON OrderReason.reason_id = a.reason_id
  WHERE order_type = 'Об отчислении'
    AND status = 'Издан'
    AND issue_date BETWEEN :start_date AND :end_date
    AND (:order_reasons IS NULL OR reason_name = ANY(:order_reasons))
)
SELECT
  reason_name as "Причина отчисления",
  COUNT(*) AS "Количество приказов",
  CASE WHEN total = 0 THEN 0 ELSE ROUND(100.0 * COUNT(*) / total, 2) END AS "Процент от общего"
FROM filtered_orders,
  (SELECT COUNT(*) FROM AcademicOrder
   WHERE order_type = 'Об отчислении'
     AND status = 'Издан'
     AND issue_date BETWEEN :start_date AND :end_date) AS t(total)
GROUP BY reason_name, total
UNION ALL
SELECT
  'ИТОГО:' AS "Причина отчисления",
  total AS "Количество приказов",
  100.00 AS "Процент от общего"
FROM (SELECT COUNT(*) AS total FROM filtered_orders) AS t
ORDER BY "Процент от общего" ASC;