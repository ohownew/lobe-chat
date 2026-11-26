-- Custom SQL migration file, put your code below! --
-- pg_search is optional: plain PostgreSQL services (Aiven, RDS, Neon projects without the
-- extension) run LobeHub with FTS_SEARCH_PROVIDER=pg_like or elasticsearch, so a missing
-- extension must not block the remaining migrations. The pg_search provider still fails
-- visibly at query time when its extension or BM25 indexes are absent.
-- Neon can list pg_search in pg_available_extensions and still reject CREATE EXTENSION
-- (deprecated extension, SQLSTATE 42501). That refusal must be caught too.
-- Editing this shipped migration is safe: Drizzle only compares `created_at`, so databases
-- that already applied it never re-run it.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'pg_search') THEN
    BEGIN
      CREATE EXTENSION IF NOT EXISTS pg_search;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE NOTICE 'pg_search could not be created (%); skipping BM25 search setup', SQLERRM;
    END;
  ELSE
    RAISE NOTICE 'pg_search is not available on this database; skipping BM25 search setup';
  END IF;
END $$;
