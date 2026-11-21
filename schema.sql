-- =========================================================
-- Food Cost – esquema de base de datos para Supabase
-- Ejecutar completo en: Supabase > SQL Editor > New query > Run
-- =========================================================

-- Configuración general (una sola fila)
create table if not exists public.config (
  id          int primary key default 1 check (id = 1),
  meta        numeric not null default 30,
  inc_igv     boolean not null default true,
  updated_at  timestamptz not null default now()
);

-- Insumos
create table if not exists public.insumos (
  id          text primary key,
  nombre      text not null default '',
  unidad      text not null default 'kg',
  costo       numeric not null default 0,   -- costo de compra sin IGV, por unidad
  merma       numeric not null default 0,   -- % de merma (0-99)
  orden       int not null default 0,
  updated_at  timestamptz not null default now()
);

-- Recetas / platos
create table if not exists public.recetas (
  id          text primary key,
  nombre      text not null default '',
  precio      numeric not null default 0,   -- precio de venta
  ventas      numeric not null default 0,   -- unidades vendidas en el período
  orden       int not null default 0,
  updated_at  timestamptz not null default now()
);

-- Ingredientes de cada receta
create table if not exists public.receta_items (
  id          text primary key,
  receta_id   text not null references public.recetas(id) on delete cascade,
  insumo_id   text references public.insumos(id) on delete cascade,
  cantidad    numeric not null default 0,   -- en la unidad del insumo
  orden       int not null default 0,
  updated_at  timestamptz not null default now()
);
create index if not exists receta_items_receta_idx on public.receta_items(receta_id);
create index if not exists receta_items_insumo_idx on public.receta_items(insumo_id);

-- Inventario del período (uno por insumo)
create table if not exists public.inventario (
  insumo_id   text primary key references public.insumos(id) on delete cascade,
  inicial     numeric not null default 0,
  compras     numeric not null default 0,
  final       numeric not null default 0,
  updated_at  timestamptz not null default now()
);

-- updated_at automático
create or replace function public.touch_updated_at() returns trigger
language plpgsql set search_path = '' as $$ begin new.updated_at = now(); return new; end $$;

do $$ declare t text;
begin
  foreach t in array array['config','insumos','recetas','receta_items','inventario'] loop
    execute format('drop trigger if exists trg_touch on public.%I', t);
    execute format('create trigger trg_touch before update on public.%I for each row execute function public.touch_updated_at()', t);
  end loop;
end $$;

-- =========================================================
-- Seguridad: solo usuarios con sesión iniciada pueden leer/escribir.
-- Todos los usuarios autenticados comparten los mismos datos.
-- =========================================================
do $$ declare t text;
begin
  foreach t in array array['config','insumos','recetas','receta_items','inventario'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists "auth_all" on public.%I', t);
    execute format('create policy "auth_all" on public.%I for all to authenticated using (true) with check (true)', t);
  end loop;
end $$;

grant select, insert, update, delete on
  public.config, public.insumos, public.recetas, public.receta_items, public.inventario
  to authenticated;
revoke all on
  public.config, public.insumos, public.recetas, public.receta_items, public.inventario
  from anon;
