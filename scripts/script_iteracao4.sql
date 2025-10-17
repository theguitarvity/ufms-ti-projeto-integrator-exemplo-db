-- =====================================================================
-- ITERAÇÃO 4: Demonstração de DELETE + consultas analíticas
-- Objetivo: mostrar remoção em cascata e exemplos de SELECTs
-- =====================================================================

BEGIN;

-- Exemplo de DELETE: remover um pedido específico (cascata remove itens)
-- (Escolhemos o pedido do João Souza - id 2 no seed)
DELETE FROM pedido WHERE id_pedido = 2;

-- Exemplo de UPDATE: reabrir um pedido e depois fechar (ciclo de estado)
UPDATE pedido SET status = 'ABERTO', updated_at = NOW()
WHERE id_pedido = 1;
UPDATE pedido SET status = 'FECHADO', updated_at = NOW()
WHERE id_pedido = 1;

COMMIT;