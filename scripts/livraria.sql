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
-- Inserção de registros (idempotente: só insere se estiver vazio)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM produto) THEN
    INSERT INTO produto (nome, preco, estoque) VALUES
    ('Dom Casmurro', 39.90, 15),
    ('O Pequeno Príncipe', 29.90, 20),
    ('A Revolução dos Bichos', 35.00, 10);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pedido) THEN
    INSERT INTO pedido (data_pedido, nome_cliente) VALUES
    ('2025-10-12', 'Maria Silva'),
    ('2025-10-12', 'João Souza'),
    ('2025-10-13', 'Ana Lima');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM item_pedido) THEN
    INSERT INTO item_pedido (id_pedido, id_produto, quantidade, subtotal) VALUES
    (1, 1, 1, 39.90),
    (1, 2, 2, 59.80),
    (2, 3, 1, 35.00),
    (3, 2, 1, 29.90);
  END IF;
END$$;

COMMIT;



-- =====================================================================
-- ITERAÇÃO 1: Reforço de integridade + colunas novas + chaves/índices
-- Objetivo: normalizar regras, evitar dados inválidos e preparar totais
-- =====================================================================

BEGIN;

-- Restrições de domínio
ALTER TABLE produto
  ADD CONSTRAINT produto_preco_ck CHECK (preco >= 0),
  ADD CONSTRAINT produto_estoque_ck CHECK (estoque >= 0);

ALTER TABLE item_pedido
  ADD CONSTRAINT item_pedido_qtd_ck CHECK (quantidade > 0),
  ADD CONSTRAINT item_pedido_subtotal_ck CHECK (subtotal >= 0);

-- Nome de produto único (evita duplicidade de catálogo)
ALTER TABLE produto
  ADD CONSTRAINT produto_nome_uk UNIQUE (nome);

-- Colunas novas em pedido: status, total, timestamps
ALTER TABLE pedido
  ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'ABERTO',
  ADD COLUMN IF NOT EXISTS total DECIMAL(12,2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT NOW();

-- Fortalecendo FKs com ações em cascata
ALTER TABLE item_pedido DROP CONSTRAINT IF EXISTS item_pedido_id_pedido_fkey;
ALTER TABLE item_pedido ADD CONSTRAINT item_pedido_pedido_fk
  FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE CASCADE;

ALTER TABLE item_pedido DROP CONSTRAINT IF EXISTS item_pedido_id_produto_fkey;
ALTER TABLE item_pedido ADD CONSTRAINT item_pedido_produto_fk
  FOREIGN KEY (id_produto) REFERENCES produto(id_produto) ON DELETE RESTRICT;

-- Índices úteis
CREATE INDEX IF NOT EXISTS idx_item_pedido_pedido ON item_pedido (id_pedido);
CREATE INDEX IF NOT EXISTS idx_item_pedido_produto ON item_pedido (id_produto);
CREATE INDEX IF NOT EXISTS idx_produto_nome ON produto (nome);

COMMIT;

