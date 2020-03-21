#процедуры 

#процедура которая предлагает 5 случайных букетов  ( со скидкой или из той же категории что заказаны ранее)

DROP PROCEDURE IF EXISTS bouquets_offer;
DELIMITER //
CREATE PROCEDURE bouquets_offer(IN user_id INT)
BEGIN
	
SELECT * FROM bouquets 
  WHERE category_id in 
	(	SELECT category_id
  		FROM bouquets as b  
  		JOIN order_items  AS oi ON b.id = oi.bouquets_id 
  		JOIN orders AS o ON o.id = oi.order_id 
  		WHERE o.sender = user_id)
UNION 

SELECT b.* FROM bouquets AS b 
	JOIN promo AS p ON p.bouquets_applied_for = b.id
	WHERE p.finishing_on < NOW()
	
  ORDER BY rand() LIMIT 5;
END//




DROP PROCEDURE IF EXISTS add_supply//
CREATE PROCEDURE add_supply(item_id INT, value INT , supplied_on DATETIME, shelf_life_period_id INT, expiration_date DATETIME, OUT tran_result varchar(200))
BEGIN
	DECLARE `_rollback` BOOL DEFAULT 0;
    DECLARE code varchar(100);
    DECLARE error_string varchar(100);
   	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
   begin
      SET `_rollback` = 1;
  GET stacked DIAGNOSTICS CONDITION 1
          code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
      set tran_result := concat('Error occured. Code: ', code, '. Text: ', error_string);
    end;
    
   	SELECT amount_avaliable INTO @cur_amount FROM items  WHERE id = item_id;
    START TRANSACTION;
	INSERT INTO flowers_delivery.supplies (item_id, value, supplied_on, shelf_life_period_id, expiration_date)
									VALUES(item_id, value, supplied_on, shelf_life_period_id, expiration_date);
	
	UPDATE flowers_delivery.items
	SET  amount_avaliable= @cur_amount + value 
	WHERE id=item_id;

IF `_rollback` THEN
         ROLLBACK;
      ELSE
    set tran_result := 'ok';
         COMMIT;
      END IF;
END//

DELIMITER ;
