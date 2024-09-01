GRANT SELECT ON smartfan.* TO 'intern_smartfan'@'%';
GRANT CREATE ROUTINE ON smartfan.* TO 'intern_smartfan'@'%';
SELECT 
    db.id, 
    db.fan_id, 
    dbo.datetime, 
    dbo.temperature, 
    dbo.humidity, 
    dbo.mode, 
    dbo.speed, 
    dbo.opTime, 
    dbo.eSpent, 
    dbo.eSaved, 
    dbo.timestampReal
FROM 
    data_batch AS db
JOIN 
    data_bulk_onchange AS dbo ON db.id = dbo.batch_id
WHERE 
    db.fan_id = 175;
    -- Create a stored procedure
DELIMITER //

CREATE PROCEDURE insert_duplicate_rows()
BEGIN
    DECLARE current_datetime DATETIME;
    DECLARE prev_datetime DATETIME;
    DECLARE time_diff INT;
    DECLARE i INT;
    DECLARE duplicate_count INT;

    -- Declare cursor to iterate through rows
    DECLARE cur CURSOR FOR 
        SELECT datetime
        FROM your_table_name
        ORDER BY datetime;

    -- Open the cursor
    OPEN cur;

    -- Initialize previous datetime variable
    FETCH cur INTO prev_datetime;

    -- Iterate through rows
    WHILE FETCH_STATUS = 0 DO
        -- Fetch current datetime
        FETCH cur INTO current_datetime;

        -- Calculate time difference in seconds
        SET time_diff = TIMESTAMPDIFF(SECOND, prev_datetime, current_datetime);

        -- If time difference is greater than 1 minute
        IF time_diff > 60 THEN
            -- Calculate number of duplicate rows to insert
            SET duplicate_count = (time_diff / 60) - 1;

            -- Insert duplicate rows
            SET i = 0;
            WHILE i < duplicate_count DO
                INSERT INTO your_table_name (datetime, temperature, humidity, mode, speed, opTime, eSpent, eSaved, timestampReal)
                SELECT 
                    DATE_ADD(prev_datetime, INTERVAL (i + 1) MINUTE),
                    temperature,
                    humidity,
                    mode,
                    speed,
                    opTime,
                    eSpent,
                    eSaved,
                    timestampReal
                FROM your_table_name
                WHERE datetime = prev_datetime;

                SET i = i + 1;
            END WHILE;
        END IF;

        -- Set previous datetime for next iteration
        SET prev_datetime = current_datetime;
    END WHILE;

    -- Close the cursor
    CLOSE cur;
END //

DELIMITER ;

    