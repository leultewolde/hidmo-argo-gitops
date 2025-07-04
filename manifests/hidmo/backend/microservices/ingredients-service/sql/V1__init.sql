-- example migration
CREATE TABLE IF NOT EXISTS sample (id SERIAL PRIMARY KEY);
create table ingredient (date_bought date, expiry_date date, price numeric(38,2), quantity numeric(38,2), id uuid not null, barcode varchar(255), image_path varchar(255), location varchar(255), name varchar(255), status varchar(255) check (status in ('AVAILABLE','LOW_STOCK','OUT_OF_STOCK','EXPIRED','USED','SPOILED')), unit varchar(255), primary key (id));
create table ingredient_usage (quantity numeric(38,2), id uuid not null, ingredient_id uuid, primary key (id));
create table prepared_food (date_prepared date, id uuid not null, prepared_status varchar(255) check (prepared_status in ('STORED','USED_AS_INGREDIENT','CONSUMED','DISCARDED','FROZEN')), storage_location varchar(255), primary key (id));
create table prepared_food_ingredients_used (ingredients_used_id uuid not null unique, prepared_food_id uuid not null);
alter table if exists ingredient_usage add constraint FK6h451y9dgf5lxu0a4jsxq4guc foreign key (ingredient_id) references ingredient;
alter table if exists prepared_food add constraint FK12vu11ly23myjny7pe6m5wm4o foreign key (id) references ingredient;
alter table if exists prepared_food_ingredients_used add constraint FKct67omw1ysua547wklx8g94wy foreign key (ingredients_used_id) references ingredient_usage;
alter table if exists prepared_food_ingredients_used add constraint FK4sjv0xlnhtg6cxri8c7v794gd foreign key (prepared_food_id) references prepared_food;