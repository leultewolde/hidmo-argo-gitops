DO
    $$
    BEGIN
      IF NOT EXISTS (
        SELECT FROM pg_database WHERE datname = 'micro1'
      ) THEN
        CREATE DATABASE micro1;
      END IF;
    END
    $$;