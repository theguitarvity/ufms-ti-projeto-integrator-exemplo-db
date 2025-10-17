# Sistema de Banco de Dados — Livraria

Este projeto contém a modelagem, o script SQL e a configuração Docker para criar e inicializar um banco de dados PostgreSQL para uma livraria fictícia.  
O objetivo é demonstrar a integração entre modelagem de banco de dados relacional e versionamento de código utilizando Git e Docker Compose.

---

## 1. Estrutura do Projeto

```
livraria-db/
├──scripts
    ├──livraria.sql          # Script SQL com criação e inserção de dados
    ├──relatorios.sql        # Script SQL com criação de relatorios
    ├──script_iteracao1.sql  # Script SQL com ITERAÇÃO 1
    ├──script_iteracao2.sql  # Script SQL com ITERAÇÃO 2
    ├──script_iteracao3.sql  # Script SQL com ITERAÇÃO 3
    ├──script_iteracao4.sql  # Script SQL com ITERAÇÃO 4
├── docker-compose.yml       # Configuração do container PostgreSQL
├── .gitignore               # Arquivos e pastas ignoradas pelo Git
└── README.md                # Documentação do projeto
```

---

## 2. Modelagem do Banco de Dados

O sistema é composto por três tabelas relacionadas: `produto`, `pedido` e `item_pedido`.  
A relação é de um para muitos entre `pedido` e `item_pedido`, e também entre `produto` e `item_pedido`.

**Modelo lógico:**

```
PRODUTO
- id_produto (INT, PK)
- nome (VARCHAR)
- preco (DECIMAL)
- estoque (INT)

PEDIDO
- id_pedido (INT, PK)
- data_pedido (DATE)
- nome_cliente (VARCHAR)

ITEM_PEDIDO
- id_item (INT, PK)
- id_pedido (FK → PEDIDO.id_pedido)
- id_produto (FK → PRODUTO.id_produto)
- quantidade (INT)
- subtotal (DECIMAL)
```
---
## 3. Configuração Docker (`docker-compose.yml`)

```yaml
version: '3.9'

services:
  postgres:
    image: postgres:16
    container_name: livraria-db
    restart: always
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: livraria
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./livraria.sql:/docker-entrypoint-initdb.d/livraria.sql:ro

volumes:
  postgres_data:
```

---

## 4. Instruções de Execução

1. Certifique-se de ter o **Docker** instalado e em execução.  
2. No diretório do projeto, execute o comando abaixo para subir o banco de dados:

   ```bash
   docker compose up -d
   ```

3. O PostgreSQL será iniciado na porta `5432` e o script `livraria.sql` será executado automaticamente.

4. Para acessar o banco de dados:

   ```bash
   docker exec -it livraria-db psql -U postgres -d livraria
   ```

5. Dentro do terminal do PostgreSQL, use os comandos abaixo para verificar as tabelas e registros:

   ```sql
   \dt
   SELECT * FROM produto;
   ```

---

## 5. Resetar o Banco de Dados

Para remover e recriar o banco de dados (incluindo os dados iniciais), execute:

```bash
docker compose down -v
docker compose up -d
```

O parâmetro `-v` remove o volume persistente, garantindo que o script SQL seja reexecutado do zero.

---


## 6. Autor

Projeto desenvolvido por **Victor Lopes**  
Disciplina: **Projeto Integrador II**  
Instituição: **Universidade Federal de Mato Grosso do Sul**