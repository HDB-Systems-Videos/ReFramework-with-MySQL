DROP FUNCTION IF EXISTS get_item;
DELIMITER $$
CREATE FUNCTION get_item() 
	RETURNS int(6)
BEGIN
	DECLARE p_queue_id INT(10);
    DECLARE p_status VARCHAR(15);
    DECLARE p_deadline_date DATETIME;
    DECLARE p_postpone_date DATETIME;
    DECLARE p_priority int(10);
    DECLARE p_cash_in VARCHAR(10);
    DECLARE p_on_us_check VARCHAR(10);
    DECLARE p_not_on_us_check VARCHAR(10);
	SELECT queue_id, cash_in, on_us_check, not_on_us_check, status, deadline_date, postpone_date, priority INTO p_queue_id, p_cash_in, p_on_us_check, p_not_on_us_check, p_status, p_deadline_date, p_postpone_date, p_priority FROM queue WHERE status = "new" AND deadline_date IS NOT NULL AND(postpone_date IS NULL OR postpone_date <= now()) ORDER BY priority DESC, deadline_date ASC LIMIT 1;
    IF p_queue_id IS NULL THEN
		SELECT queue_id, cash_in, on_us_check, not_on_us_check, status, deadline_date, postpone_date, priority INTO p_queue_id, p_cash_in, p_on_us_check, p_not_on_us_check, p_status, p_deadline_date, p_postpone_date, p_priority FROM queue WHERE status = 'new' AND deadline_date IS NULL AND (postpone_date IS NULL or postpone_date <= now()) ORDER BY priority DESC, queue_id ASC LIMIT 1;
	END IF;
    UPDATE queue
		SET status = "in progress",
			started_date = now()
        WHERE queue_id = p_queue_id;
	RETURN p_queue_id;
END$$
DELIMITER ;
