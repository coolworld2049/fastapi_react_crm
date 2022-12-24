
create or replace function is_reserved_username(_username text) returns boolean as $$
begin
    if (select true from reserved_usernames where username = _username) = true then
        raise exception 'this username is not available';
    else
        return true;
    end if;
end;
$$ language plpgsql;


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

with recursive cte as (
   select oid from pg_roles where rolname = 'ka52'

   union all
   select m.roleid
   from   cte
   join   pg_auth_members m on m.member = cte.oid
   )
select oid, oid::regrole::text as rolename from cte;  -- oid & name
