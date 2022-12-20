
--------------------------------------------------------index-----------------------------------------------------------
create index if not exists user_email_index on "user" using btree (email);
create index if not exists user_full_name_index on "user" using btree (full_name);


--------------------------------------------------------trigger---------------------------------------------------------

create or replace function check_user_role() returns trigger as $insert_user_check_role$
begin
    if split_part(new.role::text, '_', 1) = 'student' or new.role::text = 'student' then
        insert into student(id) values (new.id);
    else
        if split_part(new.role::text, '_', 1) = 'teacher' or new.role::text = 'teacher' then
            insert into teacher(user_id) values (new.id);
        else
            raise exception 'invalid user role';
        end if;
    end if;
    return new;
end;
$insert_user_check_role$ language plpgsql;

create or replace trigger insert_user_check_role after insert on "user"
    for each row execute function check_user_role();


create or replace function check_student_role() returns trigger as $insert_student_check_role$
begin
    if (select  split_part(role::text, '_', 1) from "user" where id = new.id) = 'student' then
        insert into student(id, study_group_cipher_id) values (new.id, new.study_group_cipher_id);
    else
        raise exception 'user_role is not in student roles';
    end if;
    return null;
end;
$insert_student_check_role$ language plpgsql;

create or replace trigger insert_student_check_role before insert or update on student
    for each row execute function check_student_role();



create or replace function check_teacher_role() returns trigger as $insert_teacher_check_role$
begin
    if (select split_part(role::text, '_', 1) from "user" where id = new.user_id) = 'teacher' then
        insert into teacher values (new.id, new.typed_discipline_id, new.user_id);
    else
        raise exception 'user_role is not in teacher roles';
    end if;
    return null;
end
$insert_teacher_check_role$ language plpgsql;

create or replace trigger set_teacher_check_role before insert or update on teacher
    for each row execute function check_teacher_role();



create or replace function check_task_expiration_date()
    returns trigger as $set_task_expiration_date$
begin
    if old.expiration_date >= clock_timestamp()
           or new.expiration_date >= clock_timestamp() then
        update task set status = 'overdue'::task_status where id = new.id;
    end if;
    return null;
end;
$set_task_expiration_date$ language plpgsql;

create or replace trigger set_task_expiration_date before update on task
    for statement execute function check_task_expiration_date();



create or replace function check_student_task_completion_date()
    returns trigger as $set_student_task_start_date$
    declare t_id bigint;
begin
    if (select status from task where id = new.id) = 'completed'::task_status then
        update student_task set completion_date = clock_timestamp()
                            where id = new.id
                            returning student_task.id into t_id;
    end if;
    if (select expiration_date from task where id = new.id) >= new.deadline_date then
            update task set status = 'overdue'::task_status
                        where id = new.id
                        returning task.id into t_id;
            return t_id;
    end if;
    return t_id;
end;
$set_student_task_start_date$ language plpgsql;

create or replace trigger set_student_task_completion_date before update on student_task
    for statement execute function check_student_task_completion_date();


--------------------------------------------------------functions-------------------------------------------------------
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


create or replace function create_user_in_role(db_user text, hashed_password text, current_user_role text)
  returns void as $$
declare
    query text := 'create user ';
begin
    if db_user is not null and hashed_password is not null  and current_user_role  is not null then
        query := query || db_user || ' inherit login password ' || quote_nullable(hashed_password) || ' in role ' || current_user_role;
    end if;
    execute query;
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
