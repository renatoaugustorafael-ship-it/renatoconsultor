[README.md](https://github.com/user-attachments/files/35001813/README.md)
# Renato Consultor — autenticação com Google Authenticator

Esta versão BLOQUEIA o painel até configurar autenticação real. Não há senha padrão ou acesso de demonstração sem login.

## Configurar
1. Crie um projeto em https://supabase.com/dashboard.
2. Em Authentication > Providers, habilite Email; desabilite novos cadastros públicos (Allow new users to sign up = off).
3. Em Authentication > Multi-Factor Authentication, habilite TOTP (Authenticator App). Use configurações de segurança apropriadas para produção.
4. Em Authentication > Users, crie manualmente APENAS o seu usuário (e-mail e senha forte). Não compartilhe essa senha.
5. Em Project Settings > API, copie Project URL e a chave **publishable/anon** (NUNCA service_role/secret). Preencha `auth-config.js`.
6. Publique todos os arquivos na Vercel (via repositório Git). Configure Site URL e Redirect URLs em Supabase Authentication > URL Configuration para seu domínio Vercel.
7. Entre com e-mail/senha, escaneie o QR com Google Authenticator, informe o código para ativar. Nos acessos seguintes, será exigido código TOTP.

## Segurança importante
- A autenticação está funcional somente após configuração do Supabase. Sem ela, o painel permanece bloqueado.
- O painel e a navegação são protegidos pela interface, mas **isso não é proteção de backend**. Para dados reais, use tabelas com Row Level Security (RLS) exigindo `auth.uid()` e `auth.jwt()->>'aal' = 'aal2'`, além de autorização de proprietário. Nunca confie só na verificação JavaScript.
- O cadastro demonstrativo de nomes de bancos continua em `localStorage` do navegador; NÃO coloque CPFs, senhas, tokens ou dados sigilosos nele.
- Nenhuma simulação bancária real está implementada. Não use o protótipo para clientes reais.
- Considere configurar recuperação de acesso MFA, política de sessões, proteção contra força bruta, logs, backups e revisão de segurança antes de produção.
- A Vercel não é automaticamente atualizada por este arquivo ZIP: faça novo deploy dos arquivos.

## Clientes e contratos (demonstração)
Nova aba para cadastro, edição, exclusão e filtro por status. Os dados são mantidos apenas em memória durante a sessão da página; NÃO usar dados reais. Persistência segura requer backend, banco de dados com RLS e autenticação MFA configurada.

## Painel de produção (atualização)
Inclui contagem de contratos, propostas em análise, contratos integrados, valor integrado, gráficos de status, banco, convênio e mês da primeira parcela, filtros e exportação CSV. Os dados de clientes permanecem somente em memória durante a sessão, sem persistência. A autenticação exige configurar Supabase; não usar dados reais até configurar autenticação, políticas de acesso e armazenamento seguro. O ZIP não atualiza automaticamente o site já publicado na Vercel.
