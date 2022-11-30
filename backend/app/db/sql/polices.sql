
------------------------------------------------------polices-----------------------------------------------------------
create role admin inherit createdb createrole;
create role manager inherit;
create role ranker inherit;

alter table public.task enable row level security;

--админ может изменить автора задания или внести изменения в завершенное задание.
grant all on schema public to admin;
grant select, update, delete on all tables in schema public to admin;

--менеджеры назначают задания себе или кому-либо из рядовых сотрудников
grant all on schema public  to manager;
grant select, insert, update, delete on table public.task to manager;
grant select, insert, update on table contract to manager;
grant select on public."user" to manager;

--рядовые сотрудники не могут назначать задания
grant all on schema public to ranker;
grant select, update, delete on table public.task to ranker;
grant select on public."user" to ranker;


--polices functions
create or replace function is_manager(_id integer) returns integer language plpgsql as
$body$
begin
    if (select 1 from "user" where id = _id and "role" = 'manager'::"UserRole") = 1 then
        return 1;
    else
        return 0;
    end if;
end;
$body$;

create or replace function is_ranker(_id integer) returns integer language plpgsql as
$body$
begin
    if (select 1 from "user" where id = _id and "role" = 'ranker'::"UserRole") = 1 then
        return 1;
    else
        return 0;
    end if;
end;
$body$;


--менеджеры назначают задания себе или кому-либо из рядовых сотрудников. исполнитель - сотрудник, не являющийся автором.
create policy manager_insert_task_assign_self on task as permissive for insert to manager
    with check (is_manager(executor_id) = 1);

create policy manager_insert_task_assign_ranker on task as permissive for insert to manager
    with check (is_manager(author_id) = 1 and executor_id != author_id);


--помечать задание как выполненное и указывать дату завершения может ... автор, исполнитель задания.
create policy manager_update_task_self on task as permissive for update to manager using
    (is_manager(author_id) = 1);

create policy manager_update_task_ranker on task as permissive for update to manager using
    (is_manager(executor_id) = 1);

create policy ranker_update_tasks on task as permissive for update to ranker using
    (is_ranker(executor_id) = 1);


--просматривать задание, автором которого является менеджер, может ... автор, исполнитель задания.
create policy manager_select_task_self on task as permissive for select  to manager using
    (is_manager(author_id) = 1);

create policy manager_select_task_ranker on task as permissive for select to manager using
    (is_manager(executor_id) = 1);

create policy ranker_select_tasks on task as permissive for select to ranker using
    (is_ranker(executor_id) = 1);


----по прошествии 12 месяцев после даты завершения задания сведения о нем удаляются из системы.
create policy manager_delete_task on task as permissive for delete to manager using
    (is_manager(executor_id) = 1
        or is_manager(author_id) = 1 and completion_date is not null);

create policy ranker_delete_tasks on task as permissive for delete to ranker using
    (is_ranker(executor_id) = 1 and completion_date is not null);

------------------------------------------------------check-role--------------------------------------------------------
