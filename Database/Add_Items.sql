DROP FUNCTION IF EXISTS add_items;
DELIMITER $$
CREATE FUNCTION add_items(in_cash_in varchar(10), in_on_us_check varchar(10), in_not_on_us_check varchar(10), in_deadline varchar(20), in_priority int(1), in_postpone varchar(20)) 
	RETURNS int(6)
BEGIN
    IF in_deadline = "" THEN
		SET in_deadline = NULL;
	END IF;
    IF in_postpone = "" THEN
		SET in_postpone = NULL;
	END IF;
	INSERT INTO `uipath`.`queue`
(`transaction_id`,
`status`,
`cash_in`,
`on_us_check`,
`not_on_us_check`,
`deadline_date`,
`postpone_date`,
`priority`,
`retry_count`)
VALUES
(DATE_FORMAT(NOW(), '%Y-%m-%d %T.%f'),
"new",
in_cash_in,
in_on_us_check,
in_not_on_us_check,
CAST(in_deadline AS DATETIME),
CAST(in_postpone AS DATETIME),
in_priority,
0);

	return 0;
END$$
DELIMITER ;
