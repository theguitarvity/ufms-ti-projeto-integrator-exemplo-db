-- 1) Vendas por dia
SELECT data_pedido, SUM(total) AS faturamento FROM pedido GROUP BY data_pedido ORDER BY data_pedido;

-- 2) Top produtos por quantidade vendida
SELECT p.nome, SUM(ip.quantidade) AS qtd
    FROM item_pedido ip JOIN produto p ON p.id_produto = ip.id_produto
    GROUP BY p.nome ORDER BY qtd DESC;

-- 3) Pedidos e itens
SELECT * FROM vw_pedidos_resumo ORDER BY data_pedido DESC;

-- 4) Produtos com baixo estoque
SELECT * FROM produto WHERE estoque < 5 ORDER BY estoque ASC;