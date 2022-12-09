
------------------------------------------------------privileges--------------------------------------------------------
create role admin_base noinherit superuser bypassrls;
create role manager_base noinherit;
create role ranker_base noinherit;
create role client_base noinherit;

--админ может изменить автора задания или внести изменения в завершенное задание.
grant all privileges on schema public to admin_base;
grant select, insert, update, delete on all tables in schema public to admin_base;
grant usage, select, update on all sequences in schema public to admin_base;
grant select, insert, update, delete on table task to admin_base;
grant select, insert, update, delete on table "user" to admin_base;

--менеджеры назначают задания себе или кому-либо из рядовых сотрудников
grant select, insert, update, delete on table public.task to manager_base;
grant usage, select, update on all sequences in schema public to manager_base;
grant select, update on table "user" to manager_base;
grant select on table company to manager_base;

--рядовые сотрудники не могут назначать задания
grant select, update, delete on table public.task to ranker_base;
grant usage, select, update on all sequences in schema public to ranker_base;
grant select on "user" to ranker_base;
grant select on table company to ranker_base;

--клиенты могут просматривать задания
grant select on table public.task to client_base;
grant usage, select, update on all sequences in schema public to client_base;
grant select on "user" to client_base;
grant select on table company to client_base;

------------------------------------------------------task-policies-----------------------------------------------------

--polices functions
create or replace function is_admin_base(_id integer) returns integer language plpgsql as
$body$
begin
    if (select 1 from "user" where id = _id and "role" = 'admin_base'::"UserRole") = 1 then
        return 1;
    else
        return 0;
    end if;
end;
$body$;

create or replace function is_manager_base(_id integer) returns integer language plpgsql as
$body$
begin
    if (select 1 from "user" where id = _id and "role" = 'manager_base'::"UserRole") = 1 then
        return 1;
    else
        return 0;
    end if;
end;
$body$;

create or replace function is_executor(exc_id integer) returns integer language plpgsql as
$body$
begin
    if (select is_ranker_base from is_ranker_base(exc_id)) = 1 then
        return 1;
    else
        if (select is_manager_base from is_manager_base(exc_id)) = 1  then
            return 1;
        else
            return 0;
        end if;
    end if;
end;
$body$;

create or replace function is_ranker_base(_id integer) returns integer language plpgsql as
$body$
begin
    if (select 1 from "user" where id = _id and "role" = 'ranker_base'::"UserRole") = 1 then
        return 1;
    else
        return 0;
    end if;
end;
$body$;

create or replace function is_client_base(_id integer) returns integer language plpgsql as
$body$
begin
    if (select 1 from "user" where id = _id and "role" = 'client_base'::"UserRole") = 1 then
        return 1;
    else
        return 0;
    end if;
end;
$body$;

create or replace function is_session_user() returns integer language plpgsql as
$body$
begin
    if (select 1 from "user" where username = session_user limit 1) = 1 then
        return 1;
    else
        return 0;
    end if;
end
$body$;

------------------------------------------------------task-policies-----------------------------------------------------

alter table public.task enable row level security;


--менеджеры назначают задания себе или кому-либо из рядовых сотрудников. исполнитель - сотрудник, не являющийся автором.
create policy admin_base_select_tasks on task as permissive for select to admin_base using
    (is_session_user() = 1);

create policy admin_base_update_tasks on task as permissive for update to admin_base using
    (is_session_user() = 1);



create policy manager_base_insert_task_assign_self on task as permissive for insert to manager_base
    with check (is_manager_base(executor_id) = 1);

--помечать задание как выполненное и указывать дату завершения может ... автор, исполнитель задания.
create policy manager_base_update_task_self on task as permissive for update to manager_base using
    (is_manager_base(author_id) = 1);

create policy manager_base_update_task_ranker_base on task as permissive for update to manager_base using
    (is_manager_base(executor_id) = 1);

create policy manager_base_insert_task_assign_ranker_base on task as permissive for insert to manager_base
    with check (is_manager_base(author_id) = 1);

--просматривать задание, автором которого является менеджер, может ... автор, исполнитель задания.
create policy manager_base_select_task_self on task as permissive for select  to manager_base using
    (is_manager_base(author_id) = 1);

create policy manager_base_select_task_ranker_base on task as permissive for select to manager_base using
    (is_manager_base(executor_id) = 1);

----по прошествии 12 месяцев после даты завершения задания сведения о нем удаляются из системы.
create policy manager_base_delete_task on task as permissive for delete to manager_base using
    (is_manager_base(executor_id) = 1
        or is_manager_base(author_id) = 1
               and completion_date is not null);



create policy ranker_base_update_tasks on task as permissive for update to ranker_base using
    (is_ranker_base(executor_id) = 1);

create policy ranker_base_select_tasks on task as permissive for select to ranker_base using
    (is_ranker_base(executor_id) = 1);



create policy client_base_delete_tasks on task as permissive for select to client_base using
    (is_client_base(client_id) = 1);





------------------------------------------------------user-policies-----------------------------------------------------

alter table public."user" enable row level security;


create policy admin_base_insert_users on "user" as permissive for insert to admin_base with check
    (role = 'manager_base'::"UserRole" or role = 'client_base'::"UserRole" or role = 'ranker_base'::"UserRole"
         or role = 'admin_base'::"UserRole");

create policy admin_base_select_users on "user" as permissive for select to admin_base using
    (role = 'manager_base'::"UserRole" or role = 'client_base'::"UserRole" or role = 'ranker_base'::"UserRole"
         or role = 'admin_base'::"UserRole");

create policy admin_base_update_users on "user" as permissive for update to admin_base using
    (role = 'manager_base'::"UserRole" or role = 'client_base'::"UserRole" or role = 'ranker_base'::"UserRole"
         or role = 'admin_base'::"UserRole");

create policy admin_base_delete_users on "user" as permissive for delete to admin_base using
    (role = 'manager_base'::"UserRole" or role = 'client_base'::"UserRole" or role = 'ranker_base'::"UserRole"
         or role = 'admin_base'::"UserRole");



create policy manager_base_select_users on "user" as permissive for select to manager_base using
    (role = 'manager_base'::"UserRole" or role = 'client_base'::"UserRole" or role = 'ranker_base'::"UserRole"
         or role = 'admin_base'::"UserRole");

create policy manager_base_update_users on "user" as permissive for update to manager_base using
    (is_manager_base(id) = 1);



create policy ranker_base_select_users on "user" as permissive for select to ranker_base using
    (role = 'manager_base'::"UserRole" or role = 'client_base'::"UserRole" or role = 'ranker_base'::"UserRole"
         or role = 'admin_base'::"UserRole");

create policy ranker_base_update_users on "user" as permissive for update to ranker_base using
    (is_ranker_base(id) = 1);



create policy client_base_select_users on "user" as permissive for select to client_base using
    (role = 'manager_base'::"UserRole" or role = 'client_base'::"UserRole" or role = 'ranker_base'::"UserRole"
         or role = 'admin_base'::"UserRole");




