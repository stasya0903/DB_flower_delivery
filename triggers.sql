#тригеры

#не позволяющий добавить скидку на категорию если она уже есть в этот период времени
DROP TRIGGER IF EXISTS only_one_promo_per_time;
DELIMITER //
CREATE TRIGGER only_one_promo_per_time BEFORE INSERT ON promo
FOR EACH ROW 
BEGIN
	DECLARE begins DATETIME;
	DECLARE ends DATETIME;
	DECLARE is_end INT DEFAULT 0;
	DECLARE curcat CURSOR FOR SELECT starting_on, finishing_on  FROM promo WHERE bouquets_applied_for = NEW.bouquets_applied_for;
  	DECLARE CONTINUE HANDLER FOR NOT FOUND SET is_end = 1;
  	

  OPEN curcat;

  cycle : LOOP
	FETCH curcat INTO begins, ends;
	IF is_end THEN LEAVE cycle;
	END IF;
	IF (ends >= NEW.starting_on OR begins < NEW.finishing_on) THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'INSERT CANCELED there is another promotion for this category at that time ';
  END IF;
  END LOOP cycle;

  CLOSE curcat;
END//


#при добавлении нового товара к заказу, расчет и втоматическое добавление стоимости и обновление общей стоимости заказа
DROP TRIGGER IF EXISTS add_new_product_to_order//
CREATE TRIGGER add_new_product_to_order BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
	DECLARE summary INT DEFAULT 0;
	DECLARE order_id INT DEFAULT NEW.order_id;

SELECT total INTO @total FROM orders WHERE id = order_id;
SELECT price INTO @price FROM bouquets WHERE id = NEW.bouquets_id;
SELECT amount INTO @discount_for_bouquet FROM promo as p WHERE bouquets_applied_for = NEW.bouquets_id AND 
											p.finishing_on > NOW() ORDER BY amount DESC LIMIT 1;
SELECT amount INTO @discount_for_category 	FROM promo as p 
											JOIN bouquets as b ON b.id = p.bouquets_applied_for 
											WHERE p.category_applied_for = p.category_applied_for AND 
											p.finishing_on > NOW()ORDER BY amount DESC LIMIT 1;


	IF (@discount_for_bouquet IS NOT NULL ) 
			THEN SET @price = @price - (@price/100 * @discount_for_bouquet);  
	ELSEIF(@discount_for_category IS NOT NULL ) 
			THEN SET @price = @price - (@price/100 * @discount_for_category); 
	END IF;


SET @price = @price * NEW.amount;
SET summary = @total + @price;
UPDATE orders
SET  total = summary
WHERE id = order_id;

SET NEW.price = @price;
 
END//

#при изменени количества товаров, перерасчет общей стоимости  и обновление общей стоимости заказа
DROP TRIGGER IF EXISTS update_amount_of_product_in_order//
CREATE TRIGGER update_amount_of_product_in_order BEFORE UPDATE ON order_items
FOR EACH ROW
BEGIN
	DECLARE summary INT DEFAULT 0;
	DECLARE price INT DEFAULT OLD.price;
	DECLARE order_id INT DEFAULT NEW.order_id;

SELECT total INTO @total FROM orders WHERE id = order_id;

SET price = @total / OLD.amount;
SET NEW.price = price * NEW.amount;
SET summary = (@total - OLD.price) + NEW.price;

UPDATE orders
SET  total = summary
WHERE id = order_id;


 
END//


#при удалении товара из заказа обновление общей стоимости заказа
DROP TRIGGER IF EXISTS delete_items_from_order//
CREATE TRIGGER delete_items_from_order AFTER DELETE ON order_items
FOR EACH ROW
BEGIN
DECLARE summary INT DEFAULT 0;
SELECT total INTO @total FROM orders WHERE id = OLD.order_id;

SET summary = @total - OLD.price;


UPDATE orders
SET  total = summary
WHERE id = OLD.order_id;

END//

DELIMITER ;

			
 