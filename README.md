# Food Cost – Supabase + Render

App web de un solo HTML. Los datos se guardan en Supabase (PostgreSQL) y se publica en Render como sitio estático.

## Archivos

| Archivo | Para qué sirve |
|---|---|
| `index.html` | La aplicación (login + 4 pestañas). |
| `schema.sql` | Crea tablas, seguridad (RLS) y triggers en Supabase. |
| `build.sh` | Lo ejecuta Render: genera `dist/` con `config.js` a partir de las variables de entorno. |
| `config.example.js` | Plantilla para probar en tu computadora (copiar como `config.js`). |
| `.gitignore` | Evita subir `config.js` y `dist/` a GitHub. |

---

## Paso 1 – Crear el proyecto en Supabase

1. Entra a https://supabase.com y crea una cuenta (puedes usar GitHub o Google).
2. **New project**:
   - Name: `food-cost`
   - Database password: genera una y guárdala.
   - Region: **South America (São Paulo)**, la más cercana a Perú.
3. Espera 1–2 minutos a que el proyecto quede listo.

## Paso 2 – Crear las tablas

1. Menú izquierdo → **SQL Editor** → **New query**.
2. Pega todo el contenido de `schema.sql` y pulsa **Run**.
3. Verifica en **Table Editor** que existan: `config`, `insumos`, `recetas`, `receta_items`, `inventario` (las 5 con el candado de RLS activado).

## Paso 3 – Configurar el acceso (usuarios)

1. **Authentication → Sign In / Providers**:
   - **Email** activado.
   - **Desactiva "Allow new users to sign up"**: así nadie puede registrarse por su cuenta; solo entran los usuarios que tú crees.
2. **Authentication → Users → Add user → Create new user**:
   - Correo y contraseña de cada persona que usará la app.
   - Marca **Auto Confirm User**.
3. Todos los usuarios ven y editan los **mismos datos**.

## Paso 4 – Copiar las credenciales

En **Project Settings → API Keys** (o el botón **Connect** del proyecto) copia:

- **Project URL** → `https://xxxxxxxx.supabase.co`
- **Publishable key** → empieza con `sb_publishable_...`
  (si tu proyecto solo muestra la *anon key* también funciona, pero Supabase la retira a fines de 2026: crea la publishable).

⚠️ **Nunca** uses la *secret key* ni la *service_role* en la app: esas saltan la seguridad.

## Paso 5 – Subir el código a GitHub

1. Crea una cuenta en https://github.com si no tienes.
2. **New repository** → nombre `food-cost` → **Private** → Create.
3. **Add file → Upload files** y sube: `index.html`, `build.sh`, `schema.sql`, `config.example.js`, `.gitignore`, `README.md`.
   (No subas ningún `config.js` con tus claves.)
4. **Commit changes**.

## Paso 6 – Publicar en Render

1. Entra a https://render.com y crea cuenta con tu GitHub.
2. **New + → Static Site** → conecta el repositorio `food-cost`.
3. Configuración:
   - **Name:** `food-cost` (será `https://food-cost.onrender.com` o similar)
   - **Branch:** `main`
   - **Root Directory:** (vacío)
   - **Build Command:** `bash build.sh`
   - **Publish Directory:** `dist`
4. **Environment Variables** → agrega:
   - `SUPABASE_URL` = tu Project URL
   - `SUPABASE_KEY` = tu publishable key
5. **Create Static Site**. En ~1 minuto el log dirá `Build OK -> dist/` y tendrás la URL.

Los sitios estáticos en Render son gratuitos y no "se duermen".

## Paso 7 – Ajustes finales en Supabase

**Authentication → URL Configuration → Site URL** = la URL de Render (ej. `https://food-cost.onrender.com`).

## Paso 8 – Primer ingreso

1. Abre la URL de Render e ingresa con un usuario del Paso 3.
2. Si la base está vacía, la app carga automáticamente los **datos de ejemplo** y los guarda.
3. ¿Tenías datos en la versión anterior (local)? Ahí usa **Exportar**, y en la nueva **Importar** ese JSON (reemplaza todo lo de la base).

---

## Cómo funciona el guardado

- Cada cambio se guarda solo, ~0,7 s después de dejar de escribir. El indicador del encabezado muestra *Cambios sin guardar… / Guardando… / Guardado ✓*.
- Si se corta internet, reintenta cada 5 s y avisa si intentas cerrar la pestaña con cambios pendientes.
- Si dos personas editan a la vez, gana el último cambio de cada campo. Usa **Recargar** para traer lo que editaron otros.
- **Datos de ejemplo** e **Importar** reemplazan TODO el contenido de la base (piden confirmación).

## Actualizar la app

Sube el nuevo `index.html` a GitHub → Render vuelve a publicar automáticamente.

## Probar en tu computadora (opcional)

Copia `config.example.js` como `config.js`, pon tus datos y abre `index.html` con un servidor local
(ej. `npx serve .` o la extensión *Live Server* de VS Code).

## Plan gratuito de Supabase

Un proyecto gratuito se **pausa si pasa 1 semana sin uso**. Si te pasa, entra al dashboard y pulsa *Restore*. Con uso diario no ocurre; para evitarlo del todo, el plan Pro (~US$ 25/mes) no se pausa e incluye backups diarios.

## Respaldos

El plan gratuito de Supabase no incluye backups descargables: usa **Exportar** periódicamente (ej. al cierre de cada mes) y guarda el JSON.
