-- =====================================================================
-- ITERAÇÃO 3: Automação com funções e triggers (boas práticas)
-- Objetivo: manter subtotal/total automaticamente e proteger o estoque
-- =====================================================================

BEGIN;

-- Função: mantém subtotal do item e atualiza total do pedido
CREATE OR REPLACE FUNCTION fn_sync_item_e_pedido()
RETURNS TRIGGER AS $$
DECLARE v_preco DECIMAL(10,2);
BEGIN
  -- Subtotal = quantidade * preço atual
  SELECT preco INTO v_preco FROM produto WHERE id_produto = NEW.id_produto;
  NEW.subtotal := ROUND(NEW.quantidade * v_preco, 2);

  -- Atualiza total do pedido após INSERT/UPDATE
  PERFORM 1;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Função: baixa/restaura estoque e recalcula total do pedido
CREATE OR REPLACE FUNCTION fn_estoque_total_pedido()
RETURNS TRIGGER AS $$
DECLARE v_delta INT;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_delta := NEW.quantidade;
    UPDATE produto SET estoque = estoque - v_delta
    WHERE id_produto = NEW.id_produto AND estoque - v_delta >= 0;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Estoque insuficiente para o produto %', NEW.id_produto;
    END IF;

  ELSIF TG_OP = 'UPDATE' THEN
    v_delta := NEW.quantidade - OLD.quantidade;
    IF v_delta <> 0 THEN
      UPDATE produto SET estoque = estoque - v_delta
      WHERE id_produto = NEW.id_produto AND estoque - v_delta >= 0;
      IF NOT FOUND THEN
        RAISE EXCEPTION 'Estoque insuficiente para o produto %', NEW.id_produto;
      END IF;
    END IF;

  ELSIF TG_OP = 'DELETE' THEN
    -- devolve estoque
    UPDATE produto SET estoque = estoque + OLD.quantidade
    WHERE id_produto = OLD.id_produto;
  END IF;

  -- Recalcula total do pedido
  UPDATE pedido pd
  SET total = COALESCE((
      SELECT ROUND(SUM(subtotal),2) FROM item_pedido WHERE id_pedido = pd.id_pedido
    ), 0),
      updated_at = NOW()
  WHERE pd.id_pedido = COALESCE(NEW.id_pedido, OLD.id_pedido);

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Triggers:
-- 1) Antes de inserir/atualizar item, sincroniza subtotal
DROP TRIGGER IF EXISTS trg_item_sync_subtotal ON item_pedido;
CREATE TRIGGER trg_item_sync_subtotal
BEFORE INSERT OR UPDATE OF id_produto, quantidade
ON item_pedido
FOR EACH ROW
EXECUTE FUNCTION fn_sync_item_e_pedido();

-- 2) Após I/U/D do item, ajusta estoque e total do pedido
DROP TRIGGER IF EXISTS trg_item_estoque_total ON item_pedido;
CREATE TRIGGER trg_item_estoque_total
AFTER INSERT OR UPDATE OR DELETE
ON item_pedido
FOR EACH ROW
EXECUTE FUNCTION fn_estoque_total_pedido();

-- View de resumo para consultas
CREATE OR REPLACE VIEW vw_pedidos_resumo AS
SELECT
  pd.id_pedido,
  pd.data_pedido,
  pd.nome_cliente,
  pd.status,
  pd.total,
  COUNT(ip.id_item) AS itens,
  MIN(pd.created_at) AS criado_em,
  MAX(pd.updated_at) AS atualizado_em
FROM pedido pd
LEFT JOIN item_pedido ip ON ip.id_pedido = pd.id_pedido
GROUP BY pd.id_pedido;

COMMIT;