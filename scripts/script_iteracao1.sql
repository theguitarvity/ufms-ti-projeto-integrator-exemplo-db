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