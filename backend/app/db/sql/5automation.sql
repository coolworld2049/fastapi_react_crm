
--------------------------------------------------------index-----------------------------------------------------------
create index if not exists user_email_index on "user" using btree (email);
create index if not exists user_full_name_index on "user" using btree (full_name);


create or replace function truncate_tables(username in varchar) returns void as $$
declare
    statements cursor for
        select tablename from pg_tables
        where tableowner = username and schemaname = 'public';
begin
    for stmt in statements loop
        execute 'truncate table ' || quote_ident(stmt.tablename) || ' cascade;';
    end loop;
end;
$$ language plpgsql;
