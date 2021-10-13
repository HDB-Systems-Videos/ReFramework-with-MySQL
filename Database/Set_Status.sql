DROP FUNCTION IF EXISTS set_status;
DELIMITER $$
CREATE FUNCTION set_status(in_transaction_id VARCHAR(30) ,in_status VARCHAR(12), in_exception VARCHAR(35), in_max_retry INT(6)) 
	RETURNS int(6)
BEGIN
	DECLARE p_transaction_id VARCHAR(30);
    DECLARE p_status VARCHAR(30);
    DECLARE p_deadline_date DATETIME;
    DECLARE p_postpone_date DATETIME;
    DECLARE p_priority VARCHAR(30);
    DECLARE p_retry_count int(10);
    DECLARE p_cash_in int(10);
    DECLARE p_on_us_check int(10);
    DECLARE p_not_on_us_check int(10);
    CASE
		WHEN in_status = "sucessful" THEN 
        UPDATE queue
			SET
				status = in_status,
                ended_date = now(),
                exception = null
			WHERE transaction_id = in_transaction_id AND status = "in progress";
		WHEN in_status = "failed" THEN
        IF in_exception = "business" THEN
			UPDATE queue
            SET
				status = "failed",
                ended_date = now(),
                exception = in_exception
			WHERE transaction_id = in_transaction_id AND status = "in progress";
		ELSEIF in_exception = "application" THEN
			SELECT `transaction_id`,`status`,`cash_in`,`on_us_check`,`not_on_us_check`,`deadline_date`,`postpone_date`,`priority`,`retry_count` into p_transaction_id, p_status, p_cash_in, p_on_us_check, p_not_on_us_check, p_deadline_date, p_postpone_date, p_priority, p_retry_count FROM queue WHERE transaction_id = in_transaction_id AND status = "in progress";
            IF p_retry_count < in_max_retry THEN
				INSERT INTO `uipath`.`queue` (`transaction_id`,`status`,`cash_in`,`on_us_check`,`not_on_us_check`, `deadline_date`,`postpone_date`,`priority`,`retry_count`) VALUES (p_transaction_id, "new", p_cash_in, p_on_us_check, p_not_on_us_check, p_deadline_date, p_postpone_date, p_priority, p_retry_count + 1);
				UPDATE queue
					SET
						status = "retried",
						ended_date = now(),
						exception = in_exception
					WHERE transaction_id = in_transaction_id AND status = "in progress";
			ELSEIF p_retry_count >= in_max_retry THEN
				UPDATE queue
					SET
						status = "failed",
						ended_date = now(),
						exception = in_exception
					WHERE transaction_id = in_transaction_id AND status = "in progress";
			END IF;
		END IF;
	END CASE;
    RETURN 0;
END$$
DELIMITER ;
