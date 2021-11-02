CREATE DATABASE airflow_db;
CREATE DATABASE data;

CREATE TABLE IF NOT EXISTS people (
    id SERIAL PRIMARY KEY,
    name VARCHAR,
    height VARCHAR,
    mass VARCHAR,
    hair_color VARCHAR,
    skin_color VARCHAR,
    eye_color VARCHAR,
    birth_year VARCHAR,
    gender VARCHAR,
    homeworld INT,
    films TEXT [],
    species TEXT [],
    vehicles TEXT [],
    starships TEXT [],
    created TIMESTAMP WITH TIME ZONE,
    edited TIMESTAMP WITH TIME ZONE,
    url VARCHAR
);

CREATE TABLE IF NOT EXISTS films (
    id SERIAL PRIMARY KEY,
    title VARCHAR,
    episode_id INT,
    opening_crawl VARCHAR,
    director VARCHAR,
    producer VARCHAR,
    release_date DATE,
    characters TEXT [],
    planets TEXT [],
    starships TEXT [],
    vehicles TEXT [],
    species TEXT [],
    created TIMESTAMP WITH TIME ZONE,
    edited TIMESTAMP WITH TIME ZONE,
    url VARCHAR
);

CREATE TABLE IF NOT EXISTS starships (
    id SERIAL PRIMARY KEY,
    name VARCHAR,
    model VARCHAR,
    manufacturer VARCHAR,
    cost_in_credits VARCHAR,
    length VARCHAR,
	max_atmosphering_speed VARCHAR,
    crew VARCHAR,
    passengers VARCHAR,
	cargo_capacity VARCHAR,
    consumables VARCHAR,
    hyperdrive_rating VARCHAR,
    mglt VARCHAR,
	starship_class VARCHAR,
    pilots TEXT [],
    films TEXT [],
    created TIMESTAMP WITH TIME ZONE,
    edited TIMESTAMP WITH TIME ZONE,
    url VARCHAR
);

CREATE TABLE IF NOT EXISTS vehicles (
    id SERIAL PRIMARY KEY,
    name VARCHAR,
    model VARCHAR,
    manufacturer VARCHAR,
    cost_in_credits VARCHAR,
    length VARCHAR,
    max_atmosphering_speed VARCHAR,
    crew VARCHAR,
    passengers VARCHAR,
    cargo_capacity VARCHAR,
    consumables VARCHAR,
    vehicle_class VARCHAR,
    pilots TEXT [],
    films TEXT [],
    created TIMESTAMP WITH TIME ZONE,
    edited TIMESTAMP WITH TIME ZONE,
    url VARCHAR
);

CREATE TABLE IF NOT EXISTS planets (
    id SERIAL PRIMARY KEY,
    name VARCHAR,
    rotation_period VARCHAR,
    orbital_period VARCHAR,
    diameter VARCHAR,
    climate VARCHAR,
    gravity VARCHAR,
    terrain VARCHAR,
    surface_water VARCHAR,
    population VARCHAR,
    residents TEXT [],
    films TEXT [],
    created TIMESTAMP WITH TIME ZONE,
    edited TIMESTAMP WITH TIME ZONE,
    url VARCHAR
);

CREATE TABLE IF NOT EXISTS species (
    id SERIAL PRIMARY KEY,
    name VARCHAR,
    classification VARCHAR,
    designation VARCHAR,
    average_height VARCHAR,
    skin_colors VARCHAR,
    hair_colors VARCHAR,
    eye_colors VARCHAR,
    average_lifespan VARCHAR,
    homeworld INT,
    language VARCHAR,
    people TEXT [],
    films TEXT [],
    created TIMESTAMP WITH TIME ZONE,
    edited TIMESTAMP WITH TIME ZONE,
    url VARCHAR,
	CONSTRAINT fk_planets
        FOREIGN KEY(homeworld)
            REFERENCES Planets(id)
);

CREATE TABLE IF NOT EXISTS people_films (
	id SERIAL PRIMARY KEY,
	id_people INT,
	id_films INT,
	CONSTRAINT fk_people
        FOREIGN KEY(id_people)
            REFERENCES People(id),
	CONSTRAINT fk_films
        FOREIGN KEY(id_films)
            REFERENCES Films(id)
);

CREATE TABLE IF NOT EXISTS people_planets (
	id SERIAL PRIMARY KEY,
	id_people INT,
	id_planets INT,
	CONSTRAINT fk_people
        FOREIGN KEY(id_people)
            REFERENCES People(id),
	CONSTRAINT fk_planets
        FOREIGN KEY(id_planets)
            REFERENCES Planets(id)
);

CREATE TABLE IF NOT EXISTS people_species (
	id SERIAL PRIMARY KEY,
	id_people INT,
	id_species INT,
	CONSTRAINT fk_people
        FOREIGN KEY(id_people)
            REFERENCES People(id),
	CONSTRAINT fk_species
        FOREIGN KEY(id_species)
            REFERENCES Species(id)
);

CREATE TABLE IF NOT EXISTS people_vehicles (
	id SERIAL PRIMARY KEY,
	id_people INT,
	id_vehicles INT,
	CONSTRAINT fk_people
        FOREIGN KEY(id_people)
            REFERENCES People(id),
	CONSTRAINT fk_vehicles
        FOREIGN KEY(id_vehicles)
            REFERENCES Vehicles(id)
);

CREATE TABLE IF NOT EXISTS people_starships (
	id SERIAL PRIMARY KEY,
	id_people INT,
	id_starships INT,
	CONSTRAINT fk_people
        FOREIGN KEY(id_people)
            REFERENCES People(id),
	CONSTRAINT fk_starships
        FOREIGN KEY(id_starships)
            REFERENCES Starships(id)
);

CREATE TABLE IF NOT EXISTS films_planets (
	id SERIAL PRIMARY KEY,
	id_films INT,
	id_planets INT,
	CONSTRAINT fk_films
        FOREIGN KEY(id_films)
            REFERENCES Films(id),
	CONSTRAINT fk_planets
        FOREIGN KEY(id_planets)
            REFERENCES Planets(id)
);

CREATE TABLE IF NOT EXISTS films_species (
	id SERIAL PRIMARY KEY,
	id_films INT,
	id_species INT,
	CONSTRAINT fk_films
        FOREIGN KEY(id_films)
            REFERENCES Films(id),
	CONSTRAINT fk_species
        FOREIGN KEY(id_species)
            REFERENCES Species(id)
);

CREATE TABLE IF NOT EXISTS films_vehicles (
	id SERIAL PRIMARY KEY,
	id_films INT,
	id_vehicles INT,
	CONSTRAINT fk_films
        FOREIGN KEY(id_films)
            REFERENCES Films(id),
	CONSTRAINT fk_vehicles
        FOREIGN KEY(id_vehicles)
            REFERENCES Vehicles(id)
);

CREATE TABLE IF NOT EXISTS films_starships (
	id SERIAL PRIMARY KEY,
	id_films INT,
	id_starships INT,
	CONSTRAINT fk_films
        FOREIGN KEY(id_films)
            REFERENCES Films(id),
	CONSTRAINT fk_starships
        FOREIGN KEY(id_starships)
            REFERENCES Starships(id)
);