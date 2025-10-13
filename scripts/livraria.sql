-- Criação das tabelas
CREATE TABLE produto (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    estoque INT NOT NULL
);

CREATE TABLE pedido (
    id_pedido SERIAL PRIMARY KEY,
    data_pedido DATE NOT NULL,
    nome_cliente VARCHAR(100) NOT NULL
);

CREATE TABLE item_pedido (
    id_item SERIAL PRIMARY KEY,
    id_pedido INT REFERENCES pedido(id_pedido),
    id_produto INT REFERENCES produto(id_produto),
    quantidade INT NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL
);

-- Inserção de registros
INSERT INTO produto (nome, preco, estoque) VALUES
('Dom Casmurro', 39.90, 15),
('O Pequeno Príncipe', 29.90, 20),
('A Revolução dos Bichos', 35.00, 10);

INSERT INTO pedido (data_pedido, nome_cliente) VALUES
('2025-10-12', 'Maria Silva'),
('2025-10-12', 'João Souza'),
('2025-10-13', 'Ana Lima');

INSERT INTO item_pedido (id_pedido, id_produto, quantidade, subtotal) VALUES
(1, 1, 1, 39.90),
(1, 2, 2, 59.80),
(2, 3, 1, 35.00),
(3, 2, 1, 29.90);
