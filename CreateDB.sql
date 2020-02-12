# Database for the flower delivery company

DROP DATABASE IF EXISTS flowers_delivery;

CREATE DATABASE flowers_delivery;

USE flowers_delivery;

DROP TABLE IF EXISTS categories;

CREATE TABLE categories(
id SERIAL PRIMARY KEY,
name VARCHAR(255)
);

DROP TABLE IF EXISTS flowers;

CREATE TABLE flowers(
id SERIAL PRIMARY KEY,
name VARCHAR(255),
color VARCHAR(255),
description TEXT,
price DECIMAL(7,2) UNSIGNED NOT NULL,
country_produced VARCHAR(255),
image_url VARCHAR(255),

FOREIGN KEY category_for_flowers (category_id) REFERENCES categories(id),
INDEX category_for_flowers(category_id)

);

DROP TABLE IF EXISTS bouquets;

CREATE TABLE bouquets(
id SERIAL PRIMARY KEY,
name VARCHAR(255),
description TEXT,
price DECIMAL(7,2) UNSIGNED NOT NULL,
image_url VARCHAR(255),
category_id BIGINT UNSIGNED NOT NULL

FOREIGN KEY category_for_flowers (category_id) REFERENCES categories(id),
INDEX category_for_flowers(category_id)

);

DROP TABLE IF EXISTS flowers_in_bouquets;

CREATE TABLE flowers_in_bouquets(
bouquet_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
flower_id BIGINT UNSIGNED NOT NULL,

FOREIGN KEY bouquet_from (bouquet_id) REFERENCES bouquets(id),
FOREIGN KEY flower_in(flower_id) REFERENCES flowers(id),

);

DROP TABLE IF EXISTS discounts;

CREATE TABLE discount(
id SERIAL PRIMARY KEY,
starting_at DATETIME,
finishing_at DATETIME,
amount BIGINT UNSIGNED NOT NULL,
catergory_id BIGINT UNSIGNED NOT NULL,

FOREIGN KEY discounts_by_categories (catergory_id) REFERENCES categories(id),
INDEX discounts_by_categories (catergory_id)
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
created DATETIME,
deliver_at DATETIME,
`status` ENUM('pending payment', 'paid', 'preparing', 'outForDelivery', 'delivered', 'canceled'),
message TEXT,

FOREIGN KEY sender (user_id) REFERENCES users(id),
FOREIGN KEY item_to_delivery (item_id) REFERENCES bouquets(id),
FOREIGN KEY deliver_to (destination_id) REFERENCES delivery_destinations(id),

INDEX sender (user_id),
INDEX item_to_delivery (item_id),
INDEX deliver_to (destination_id)


);

















