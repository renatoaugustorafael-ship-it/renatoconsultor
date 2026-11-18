-- Execute no SQL Editor do Supabase ANTES de publicar o site.
-- Habilite confirmação de e-mail em Authentication > Providers > Email.
-- O único administrador é o titular do e-mail confirmado indicado abaixo.
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 email text not null, full_name text not null default '',
 role text not null default 'user' check(role in ('admin','user')),
 status text not null default 'pending' check(status in ('pending','approved','blocked','rejected')),
 created_at timestamptz not null default now()
);
create or replace function public.create_profile() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
 insert into public.profiles(id,email,full_name,role,status) values (
 new.id, lower(new.email), coalesce(new.raw_user_meta_data->>'full_name',''),
 case when lower(new.email)='renatoaugustorafael@gmail.com' then 'admin' else 'user' end,
 case when lower(new.email)='renatoaugustorafael@gmail.com' then 'approved' else 'pending' end
 ) on conflict (id) do nothing;
 return new;
end $$;
drop trigger if exists on_auth_user_created_profile on auth.users;
create trigger on_auth_user_created_profile after insert on auth.users for each row execute function public.create_profile();
-- Criar perfil para usuários já existentes (inclusive o administrador).
insert into public.profiles(id,email,full_name,role,status)
select id,lower(email),coalesce(raw_user_meta_data->>'full_name',''),
 case when lower(email)='renatoaugustorafael@gmail.com' then 'admin' else 'user' end,
 case when lower(email)='renatoaugustorafael@gmail.com' then 'approved' else 'pending' end
from auth.users on conflict (id) do nothing;
-- Reconciliar somente o administrador existente; demais usuários mantêm status.
update public.profiles p set role='admin',status='approved'
from auth.users u where p.id=u.id and lower(u.email)='renatoaugustorafael@gmail.com';
update public.profiles set role='user' where email <> 'renatoaugustorafael@gmail.com' and role='admin';
-- Função de autorização: confere e-mail ATUAL e CONFIRMADO no servidor.
create or replace function public.is_renato_admin() returns boolean
language sql stable security definer set search_path = '' as $$
 select exists(select 1 from auth.users u join public.profiles p on p.id=u.id
 where u.id=(select auth.uid()) and lower(u.email)='renatoaugustorafael@gmail.com'
 and u.email_confirmed_at is not null and p.role='admin' and p.status='approved')
$$;
revoke all on function public.is_renato_admin() from public;
grant execute on function public.is_renato_admin() to authenticated;
alter table public.profiles enable row level security;
drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles for select to authenticated
 using ((id=(select auth.uid()) and exists(select 1 from auth.users u where u.id=(select auth.uid()) and u.email_confirmed_at is not null)) or (select public.is_renato_admin()));
drop policy if exists profiles_update_admin on public.profiles;
create policy profiles_update_admin on public.profiles for update to authenticated
 using ((select public.is_renato_admin()) and role='user')
 with check ((select public.is_renato_admin()) and role='user');
-- Não conceder INSERT/DELETE de perfis ao cliente.
revoke insert,delete on public.profiles from anon,authenticated;
grant select on public.profiles to authenticated;
-- Somente a coluna status pode ser alterada por usuários autenticados,
-- e a policy acima restringe a alteração ao administrador.
revoke update on public.profiles from anon,authenticated;
grant update(status) on public.profiles to authenticated;
