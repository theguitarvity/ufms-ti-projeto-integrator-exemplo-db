-- =====================================================================
-- ITERAÇÃO 2: Correção e atualização de dados (UPDATE/DELETE/INSERT)
-- Objetivo: alinhar preços/estoques e calcular totais dos pedidos
-- =====================================================================

BEGIN;

-- Ajuste de preços (ex.: revisão de tabela)
UPDATE produto SET preco = 41.90 WHERE nome = 'Dom Casmurro';
UPDATE produto SET preco = 31.90 WHERE nome = 'O Pequeno Príncipe';

-- Recalcular subtotal dos itens conforme preço atual (exercício de sincronização)
UPDATE item_pedido ip
SET subtotal = ROUND(ip.quantidade * p.preco, 2)
FROM produto p
WHERE ip.id_produto = p.id_produto;

-- Baixa de estoque conforme itens já lançados
-- (estoque = estoque - quantidade agregada vendida)
UPDATE produto p
SET estoque = GREATEST(0, p.estoque - COALESCE(v.qtd,0))
FROM (
  SELECT id_produto, SUM(quantidade) AS qtd
  FROM item_pedido
  GROUP BY id_produto
) v
WHERE p.id_produto = v.id_produto;

-- Calcular total do pedido e fechar pedidos de 12/10/2025 (exemplo)
WITH tot AS (
  SELECT id_pedido, SUM(subtotal) AS soma
  FROM item_pedido
  GROUP BY id_pedido
)
UPDATE pedido pd
SET total = t.soma,
    status = CASE WHEN pd.data_pedido = DATE '2025-10-12' THEN 'FECHADO' ELSE pd.status END,
    updated_at = NOW()
FROM tot t
WHERE pd.id_pedido = t.id_pedido;

-- Inserir um novo produto e um novo pedido (exercício de INSERT)
INSERT INTO produto (nome, preco, estoque) VALUES
('Capitães da Areia', 27.50, 30)
ON CONFLICT (nome) DO NOTHING;

INSERT INTO pedido (data_pedido, nome_cliente) VALUES
('2025-10-14', 'Carlos Mendes');

-- Inserir item no pedido recém-criado (supondo último id gerado)
INSERT INTO item_pedido (id_pedido, id_produto, quantidade, subtotal)
SELECT (SELECT MAX(id_pedido) FROM pedido),
       p.id_produto, 2, ROUND(2 * p.preco, 2)
FROM produto p
WHERE p.nome = 'Capitães da Areia';

COMMIT;