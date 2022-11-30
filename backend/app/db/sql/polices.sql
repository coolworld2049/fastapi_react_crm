
------------------------------------------------------polices-----------------------------------------------------------
create role admin_base inherit superuser;
create role manager_base inherit;
create role ranker_base inherit;


--админ может изменить автора задания или внести изменения в завершенное задание.
grant all privileges on schema public to admin_base;
grant select, update, delete on all tables in schema public to admin_base;

--менеджеры назначают задания себе или кому-либо из рядовых сотрудников
grant all privileges on schema public to manager_base;
grant select, insert, update, delete on table public.task to manager_base;
grant select, insert, update on table contract to manager_base;
grant select on public."user" to manager_base;

--рядовые сотрудники не могут назначать задания
grant all privileges on schema public to ranker_base;
grant select, update, delete on table public.task to ranker_base;
grant select on public."user" to ranker_base;

alter table public.task enable row level security;


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


--менеджеры назначают задания себе или кому-либо из рядовых сотрудников. исполнитель - сотрудник, не являющийся автором.
create policy manager_base_insert_task_assign_self on task as permissive for insert to manager_base
    with check (is_manager_base(executor_id) = 1);

create policy manager_base_insert_task_assign_ranker_base on task as permissive for insert to manager_base
    with check (is_manager_base(author_id) = 1 and executor_id != author_id);


--помечать задание как выполненное и указывать дату завершения может ... автор, исполнитель задания.
create policy manager_base_update_task_self on task as permissive for update to manager_base using
    (is_manager_base(author_id) = 1);

create policy manager_base_update_task_ranker_base on task as permissive for update to manager_base using
    (is_manager_base(executor_id) = 1);

create policy ranker_base_update_tasks on task as permissive for update to ranker_base using
    (is_ranker_base(executor_id) = 1);


--просматривать задание, автором которого является менеджер, может ... автор, исполнитель задания.
create policy manager_base_select_task_self on task as permissive for select  to manager_base using
    (is_manager_base(author_id) = 1);

create policy manager_base_select_task_ranker_base on task as permissive for select to manager_base using
    (is_manager_base(executor_id) = 1);

create policy ranker_base_select_tasks on task as permissive for select to ranker_base using
    (is_ranker_base(executor_id) = 1);

create policy admin_base_select_tasks on task as permissive for select to admin_base using
    (session_user = (select concat('user_', split_part(email, '@', 1))
                     from "user" where concat('user_', split_part(email, '@', 1)) = session_user));

----по прошествии 12 месяцев после даты завершения задания сведения о нем удаляются из системы.
create policy manager_base_delete_task on task as permissive for delete to manager_base using
    (is_manager_base(executor_id) = 1
        or is_manager_base(author_id) = 1 and completion_date is not null);

create policy ranker_base_delete_tasks on task as permissive for delete to ranker_base using
    (is_ranker_base(executor_id) = 1 and completion_date is not null);

------------------------------------------------------check-role--------------------------------------------------------
