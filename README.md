# ShopMKT — Plataforma de Serviços Técnicos e Assistência Domiciliar

## Visão Geral

Plataforma digital para conectar clientes a profissionais especializados em serviços técnicos e assistências domiciliares.

O objetivo é facilitar a contratação de profissionais qualificados, com pesquisa por categoria, solicitações detalhadas, chat integrado, pagamento e histórico de atendimentos.

## Estrutura do Projeto

- `backend/` — API Node.js + Express para gerenciar usuários, solicitações, profissionais, pagamentos e avaliações.
- `mobile/` — App Flutter para Android e iOS, com interface para clientes e profissionais.
- `web-admin/` — Painel administrativo Angular para gerenciar cadastros, aprovações, promoções, relatórios e estatísticas.

## Tecnologias Sugeridas

- Mobile: Flutter
- Web Admin: Angular
- Backend: Node.js + Express
- Banco de Dados: MySQL
- Hospedagem: VPS ou nuvem (AWS, Azure, Google Cloud)

## Funcionalidades Principais

- Cadastro de clientes e profissionais
- Solicitação de serviço por categoria, problema, fotos e endereço
- Acompanhamento do status do atendimento
- Chat integrado entre cliente e profissional
- Avaliações e histórico de serviços
- Painel administrativo para aprovações, gerenciamento e relatórios
- Pagamentos por PIX, cartão e carteira digital

## Próximos Passos

1. Definir o modelo de dados e o esquema do banco MySQL.
2. Implementar a API backend com autenticação, rotas e validação.
3. Criar o app Flutter com fluxo de cadastro, solicitação e chat.
4. Desenvolver o painel Angular para administração e monitoramento.
5. Configurar implantação em ambiente de nuvem ou VPS.
