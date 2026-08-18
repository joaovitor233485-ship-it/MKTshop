# ShopMKT Backend

API Node.js + Express para a plataforma de serviços técnicos e assistência domiciliar.

## Como usar

1. Copie `.env.example` para `.env`.
2. Ajuste os dados de conexão ao MySQL.
3. Instale as dependências:

```bash
cd backend
npm install
```

4. Inicie o servidor:

```bash
npm run dev
```

5. Acesse `http://localhost:3000`.

## Estrutura

- `server.js` — inicializa o app.
- `src/app.js` — configura o Express e rotas.
- `src/config/db.js` — conexão MySQL.
- `src/routes` — rotas REST.
- `src/controllers` — lógica de negócio.
- `database/schema.sql` — modelo inicial do banco.

## Funcionalidades iniciais

- Cadastro de clientes e profissionais
- Login de usuários
- Consulta de categorias de serviços
- Criação de solicitações de serviço
- Avaliações

## Próximos passos

- Implementar validação de entrada completa
- Adicionar upload de fotos e histórico de chats
- Integrar gateways de pagamento
- Criar frontend mobile e painel administrativo
