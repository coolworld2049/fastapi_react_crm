

create or replace function create_user_in_role(db_user text, hashed_password text, current_user_role text)
  returns void as $$
declare
    query text := 'create user ';
begin
    if db_user is not null and hashed_password is not null  and current_user_role  is not null then
        query := query || db_user || ' inherit login password ' || quote_nullable(hashed_password) || ' in role ' || current_user_role;
    end if;
    execute query ;
end
$$ language plpgsql;



create or replace function change_password(username text, old_password text, new_password text) returns void
as $$
begin
    execute 'alter user ' || username || ' identified by ' || old_password || ' replace ' || new_password;
end;
$$ language plpgsql;



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
