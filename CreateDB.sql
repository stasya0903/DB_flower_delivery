#Database for the flower delivery company

DROP DATABASE IF EXISTS flowers_delivery;

CREATE DATABASE flowers_delivery;

USE flowers_delivery;

DROP TABLE IF EXISTS occasions;

CREATE TABLE occasions(
id SERIAL PRIMARY KEY,
name VARCHAR(255)
);

DROP TABLE IF EXISTS shelf_life_periods;

CREATE TABLE shelf_life_periods(
id SERIAL PRIMARY KEY,
name VARCHAR(255),
amount_of_days BIGINT UNSIGNED NOT NULL
);

DROP TABLE IF EXISTS categories;
CREATE TABLE categories(
id SERIAL PRIMARY KEY,
name VARCHAR(255)
);




DROP TABLE IF EXISTS flowers_and_herbs;

CREATE TABLE flowers_and_herbs(
id SERIAL PRIMARY KEY,
category_id BIGINT UNSIGNED NOT NULL,
name VARCHAR(255),
color VARCHAR(255),
description TEXT,
price DECIMAL(7,2) UNSIGNED NOT NULL,
country_produced VARCHAR(255),

FOREIGN KEY category_for_item (category_id) REFERENCES categories(id),

INDEX category_for_item (category_id)
);


DROP TABLE IF EXISTS decorations;

CREATE TABLE decorations(
id SERIAL PRIMARY KEY,
category_id BIGINT UNSIGNED NOT NULL,
name VARCHAR(255),
color VARCHAR(255),
description TEXT,
price DECIMAL(7,2) UNSIGNED NOT NULL,
material VARCHAR(255),

FOREIGN KEY category_for_item (category_id) REFERENCES categories(id),
INDEX category_for_item (category_id)

);


DROP TABLE IF EXISTS bouquets_size;

CREATE TABLE bouquets_size(
id SERIAL PRIMARY KEY,
name VARCHAR(255)
);

DROP TABLE IF EXISTS bouquets;

CREATE TABLE bouquets(
id SERIAL PRIMARY KEY,
name VARCHAR(255),
description TEXT,
price DECIMAL(7,2) UNSIGNED NOT NULL,
image_url VARCHAR(255),
occasion_id BIGINT UNSIGNED NOT NULL,
size_id BIGINT UNSIGNED NOT NULL,

FOREIGN KEY occasion_for_bouquete (occasion_id) REFERENCES occasions(id),
FOREIGN KEY size_of_bouquets(size_id) REFERENCES bouquets_size(id),

INDEX occasion_for_bouquete(occasion_id),
INDEX size_of_bouquets (size_id)

);


DROP TABLE IF EXISTS flowers_and_herbs_in_bouquets;

CREATE TABLE flowers_and_herbs_in_bouquets(
bouquet_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
item_id BIGINT UNSIGNED NOT NULL,
quantity_of_used_flowers BIGINT UNSIGNED NOT NULL,

FOREIGN KEY bouquet_from (bouquet_id) REFERENCES bouquets(id),
FOREIGN KEY item_in(item_id) REFERENCES flowers_and_herbs(id)

);

DROP TABLE IF EXISTS decorations_in_bouquets;

CREATE TABLE decorations_in_bouquets(
bouquet_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
item_id BIGINT UNSIGNED NOT NULL,
quantity_of_used_decoration BIGINT UNSIGNED NOT NULL,

FOREIGN KEY bouquet_from (bouquet_id) REFERENCES bouquets(id),
FOREIGN KEY item_in(item_id) REFERENCES decorations(id)

);

DROP TABLE IF EXISTS discounts;

CREATE TABLE discount(
id SERIAL PRIMARY KEY,
starting_on DATETIME,
finishing_on DATETIME,
amount BIGINT UNSIGNED NOT NULL,
made_for_item_id BIGINT UNSIGNED NOT NULL,

FOREIGN KEY discounts_by_occasion(made_for_item_id) REFERENCES occasions(id),
FOREIGN KEY bouquets_by_bouquets (made_for_item_id) REFERENCES bouquets(id),

INDEX discounts_by (made_for_item_id)
);

DROP TABLE IF EXISTS users;

CREATE TABLE users(
id SERIAL PRIMARY KEY,
first_name VARCHAR(255),
last_name VARCHAR(255),
email VARCHAR(255),
phone BIGINT,
password_hash VARCHAR(255),
bithday DATE,
register_at DATETIME DEFAULT NOW(),

INDEX last_name_first_name (last_name, first_name),
INDEX users_phone_idx(phone),
INDEX users_email_idx(email)

);

DROP TABLE IF EXISTS delivery_destinations;

CREATE TABLE delivery_destinations(
id SERIAL PRIMARY KEY,
sender_id BIGINT UNSIGNED NOT NULL,
city VARCHAR(255),
street VARCHAR(255),
house VARCHAR(255),
flat VARCHAR(255),
receiver VARCHAR(255),


FOREIGN KEY sender (sender_id) REFERENCES users(id),
INDEX sender (sender_id)
);


DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
id SERIAL PRIMARY KEY,
sender BIGINT UNSIGNED NOT NULL,
item_id BIGINT UNSIGNED NOT NULL,
destination_id BIGINT UNSIGNED NOT NULL,
discount_id BIGINT UNSIGNED NOT NULL,
created DATETIME,
deliver_at DATETIME,
`status` ENUM('pending payment', 'paid', 'preparing', 'outForDelivery', 'delivered', 'canceled'),
message TEXT,

FOREIGN KEY sender_key (sender) REFERENCES users(id),
FOREIGN KEY item_to_delivery (item_id) REFERENCES bouquets(id),
FOREIGN KEY deliver_to (destination_id) REFERENCES delivery_destinations(id),
FOREIGN KEY discount_for_order (discount_id) REFERENCES discount(id),

INDEX sender_indx (sender),
INDEX item_to_delivery (item_id),
INDEX deliver_to (destination_id)


);

DROP TABLE IF EXISTS supplies;
CREATE TABLE supplies (
  id SERIAL PRIMARY KEY,
  item_id BIGINT UNSIGNED NOT NULL,
  category_id BIGINT UNSIGNED NOT NULL,
  value INT UNSIGNED,
  supplied_on DATETIME DEFAULT CURRENT_TIMESTAMP,
  shelf_life_period_id BIGINT UNSIGNED NOT NULL,
  expiration_date DATETIME NOT NULL, # должен расчитываться???
   
  FOREIGN KEY item_id_key(item_id) REFERENCES flowers_and_herbs(id),
  FOREIGN KEY item_id_key(item_id) REFERENCES decorations(id),
  FOREIGN KEY category_of_item(category_id) REFERENCES categories (id),
  FOREIGN KEY shelf_life_period_id_of_item(shelf_life_period_id) REFERENCES shelf_life_periods(id),
  
  INDEX item_id_indx (item_id),
  INDEX category_of_item(category_id)
);


DROP TABLE IF EXISTS inventory;
CREATE TABLE inventory (
  item_id BIGINT UNSIGNED NOT NULL,
  category_id BIGINT UNSIGNED NOT NULL,
  supply_id BIGINT UNSIGNED NOT NULL,
  value INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
   
  PRIMARY KEY(item_id, category_id),
  FOREIGN KEY item_id_key(item_id) REFERENCES flowers_and_herbs(id),
  FOREIGN KEY item_id_key(item_id) REFERENCES decorations(id),
  FOREIGN KEY sypply_info(supply_id) REFERENCES supplies (id),
  
  
  INDEX item_id_indx (item_id)
);






















