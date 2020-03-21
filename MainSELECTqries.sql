#основные выборки

#букеты по категориям 

SELECT * FROM bouquets AS b JOIN categories_of_bouquets AS c  WHERE c.id = 1;

#букеты по случаю

SELECT * FROM bouquets AS b JOIN occasions_bouquets AS o  WHERE o.id = 1;

#показать по 10 букетов на странице

SELECT * FROM bouquets LIMIT 0,10;
SELECT * FROM bouquets LIMIT 10,10;

# показать все букеты цены которых ниже выбранной суммы

SELECT * FROM bouquets WHERE price < 1000;

# показать все букеты на которые действует акция  с обновленной ценой

SELECT p.id, p.finishing_on, b.id, b.name, b.description , b.price AS old_price, TRUNCATE(b.price - (b.price/100 * p.amount), 2) AS newPrice 
FROM promo AS p 
JOIN bouquets AS b ON p.bouquets_applied_for = b.id 
WHERE p.finishing_on > NOW();

SELECT finishing_on  FROM promo;

#показать букеты из цветов определенного цвета

SELECT b.* FROM bouquets b 	JOIN items_in_bouquets as ib ON b.id = ib.bouquet_id
							JOIN items as i ON ib.item_id = i.id 
							WHERE i.category_id = 1 AND i.color = "green";

#показать состав букета 

SELECT ib.quantity_used , i.name, i.description, i.country_produced FROM items_in_bouquets ib 
																	JOIN items as i ON ib.item_id = i.id 
																	WHERE ib.bouquet_id =2;


# выбрать букеты, составляющих которыx нет в наличии 
														
SELECT DISTINCT b.* FROM bouquets b JOIN items_in_bouquets as ib ON b.id = ib.bouquet_id
							JOIN inventory AS i ON ib.item_id = i.item_id 
							WHERE i.value = 0 ORDER BY b.id;
							
#показать заказы определенного пользователя 

SELECT * FROM orders where sender = 26;	

#недоставленые заказы определенного пользователя с списком букетов

SELECT o.id, o.delivery_timе, o.destination_id, b.id, b.name, b.price, o.status FROM bouquets AS b JOIN order_items AS oi ON oi.bouquets_id = b.id 
							JOIN orders AS o ON o.id = oi.order_id 
where sender = 26 AND o.status ='paid';	

#показать все заказы которые нужно доставить сегодня 

SELECT * FROM orders WHERE DATE_FORMAT(delivery_timе, '%d,%c,%y')= DATE_FORMAT(now(), '%d,%c,%y') AND status = 'paid';


#показать все букеты  которые заказаны на сегодня

SELECT b.* FROM bouquets as  b JOIN order_items as oi ON b.id = oi.bouquets_id 
							JOIN orders as o ON o.id = oi.order_id 
							WHERE DATE_FORMAT(o.delivery_timе, '%d,%c,%y')= DATE_FORMAT(now(), '%d,%c,%y');

#показать все цветы которые в ходят в состав букетов которые нужно доставить сегодня

SELECT i.* FROM items AS i JOIN order_items AS oi ON i.id=oi.bouquets_id
							JOIN orders AS o ON o.id = oi.order_id
							WHERE DATE_FORMAT(o.delivery_timе, '%d,%c,%y')= DATE_FORMAT(now(), '%d,%c,%y') AND category_id = 1; 
						


#показать 10 самыx популярныx букетов

SELECT count(*) as purchased , b.* 	FROM bouquets AS b 
									JOIN order_items AS oi ON b.id = oi.bouquets_id 
									GROUP BY b.id 
									ORDER BY purchased DESC ;
															

#показать наиболее часто используемые цветы

SELECT SUM(ib.quantity_used ) as total , ib.item_id, i.name  FROM items AS i JOIN items_in_bouquets AS ib ON ib.item_id = i.id 
							JOIN order_items AS oi ON oi.bouquets_id = ib.bouquet_id 
WHERE i.category_id = 1  GROUP BY ib.item_id ORDER BY total DESC LIMIT 5;								



#показать сколько осталось цветов на базе в порядке убывания

SELECT * FROM items WHERE category_id = 1 ORDER BY  amount_avaliable DESC;

#показать 5 букетов который дольше всего не покупали 
SELECT o.created, b.id, b.name FROM bouquets as b JOIN order_items as oi ON b.id = oi.bouquets_id 
							JOIN orders as o ON oi.order_id = o.id ORDER BY o.created LIMIT 5;
						
#показать букеты которые не были куплены ни разу

SELECT  b.* FROM bouquets as b LEFT JOIN order_items as oi ON b.id = oi.bouquets_id WHERE oi.order_id  is NULL GROUP BY b.id;

#показать те items которые не были использованы ни разу

SELECT  i.* FROM items as i JOIN items_in_bouquets AS ib ON i.id = ib.item_id 
							LEFT JOIN order_items as oi ON ib.bouquet_id = oi.bouquets_id WHERE oi.order_id  is NULL 
							GROUP BY i.id 
							ORDER BY i.category_id ;

!!!!#показать цены на букеты с учетом скидки определенного покупателя

SELECT * FROM bouquets as b JOIN order_items as oi ON b.id = oi.bouquets_id 
							JOIN orders as o ON o.id = oi.order_id 
							JOIN users_points as up ON o.sender = up.user_id 
							JOIN loyalty_programm as lp ON lp.tier_id = up.tier_id 
							WHERE o.sender = 11;

							
								
SELECT b.price INTO @price FROM bouquets as b JOIN order_items as oi ON b.id = oi.bouquets_id 
							JOIN orders as o ON o.id = oi.order_id
							WHERE o.id = 5;



#представления 

						
#букеты с ценой до 5000		

CREATE OR REPLACE VIEW cheap_bouquets AS
SELECT * FROM bouquets WHERE price < 5000
WITH CHECK OPTION;						

						
#букеты с ценой до от 5000 до 10000

CREATE OR REPLACE VIEW cheap_bouquets AS
SELECT * FROM bouquets WHERE price >= 5000 AND price < 10000
WITH CHECK OPTION;

#букеты дороже 10000

CREATE OR REPLACE VIEW cheap_bouquets AS
SELECT * FROM bouquets WHERE price >= 10000
WITH CHECK OPTION;

#букеты среднего размера

CREATE OR REPLACE VIEW medium_bouquets AS
SELECT * FROM bouquets WHERE size_id = 2
WITH CHECK OPTION;



#букеты из роз 

CREATE OR REPLACE VIEW rose_bouquets AS
SELECT * FROM bouquets WHERE category_id = 1
WITH CHECK OPTION;


