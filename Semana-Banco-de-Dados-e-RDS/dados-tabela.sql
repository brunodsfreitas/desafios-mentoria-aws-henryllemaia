-- Criar a tabela
CREATE TABLE got_cidades (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    familia_pertence VARCHAR(100),
    nome_do_rei VARCHAR(100)
);

-- Inserir dados na tabela
INSERT INTO got_cidades (nome, familia_pertence, nome_do_rei) VALUES
('Winterfell', 'Stark', 'Jon Snow'),
('King''s Landing', 'Lannister', 'Cersei Lannister'),
('Pyke', 'Greyjoy', 'Euron Greyjoy'),
('Highgarden', 'Tyrell', 'Margaery Tyrell'),
('Sunspear', 'Martell', 'Ellaria Sand'),
('The Eyrie', 'Arryn', 'Robin Arryn'),
('Riverrun', 'Tully', 'Edmure Tully'),
('Harrenhal', 'Baelish', 'Petyr Baelish'),
('Casterly Rock', 'Lannister', 'Cersei Lannister'),
('Dragonstone', 'Targaryen', 'Daenerys Targaryen'),
('Storms End', 'Baratheon', 'Stannis Baratheon'),
('Pentos', 'None', 'None'),
('Braavos', 'None', 'None'),
('Volantis', 'None', 'None'),
('Meereen', 'Targaryen', 'Daenerys Targaryen'),
('Astapor', 'None', 'None'),
('Yunkai', 'None', 'None'),
('Qarth', 'None', 'None');