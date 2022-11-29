\connect app;

------------------------------------------------------POLICES-----------------------------------------------------------
DROP ROLE admin;
DROP ROLE manager;
DROP ROLE ranker;
CREATE ROLE admin INHERIT CREATEDB CREATEROLE;
CREATE ROLE manager INHERIT;
CREATE ROLE ranker INHERIT;

ALTER TABLE public.task ENABLE ROW LEVEL SECURITY;

--Админ Может изменить автора задания или внести изменения в завершенное задание.
GRANT ALL ON SCHEMA public to admin;
GRANT SELECT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public to admin;

--Менеджеры назначают задания себе или кому-либо из рядовых сотрудников
GRANT ALL ON SCHEMA public  to manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.task to manager;
GRANT SELECT, INSERT, UPDATE ON TABLE contract to manager;
GRANT SELECT ON public."user" to manager;

--Рядовые сотрудники не могут назначать задания
GRANT ALL ON SCHEMA public to ranker;
GRANT SELECT, UPDATE, DELETE ON TABLE public.task to ranker;
GRANT SELECT ON public."user" to ranker;


--POLICES FUNCTIONS
CREATE OR REPLACE FUNCTION is_manager(_id integer) RETURNS integer LANGUAGE plpgsql AS
$BODY$
BEGIN
    IF (SELECT 1 FROM "user" WHERE id = _id and "role" = 'manager'::"UserRole") = 1 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END;
$BODY$;

CREATE OR REPLACE FUNCTION is_ranker(_id integer) RETURNS integer LANGUAGE plpgsql AS
$BODY$
BEGIN
    IF (SELECT 1 FROM "user" WHERE id = _id and "role" = 'ranker'::"UserRole") = 1 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END;
$BODY$;


--Менеджеры назначают задания себе или кому-либо из рядовых сотрудников. Исполнитель - сотрудник, не являющийся автором.
CREATE POLICY manager_insert_task_assign_self ON task AS PERMISSIVE FOR INSERT TO manager
    with check (is_manager(executor_id) = 1);

CREATE POLICY manager_insert_task_assign_ranker ON task AS PERMISSIVE FOR INSERT TO manager
    with check (is_manager(author_id) = 1 and executor_id != author_id);


--Помечать задание как выполненное и указывать дату завершения может ... автор, исполнитель задания.
CREATE POLICY manager_update_task_self ON task AS PERMISSIVE FOR UPDATE TO manager USING
    (is_manager(author_id) = 1);

CREATE POLICY manager_update_task_ranker ON task AS PERMISSIVE FOR UPDATE TO manager USING
    (is_manager(executor_id) = 1);

CREATE POLICY ranker_update_tasks ON task AS PERMISSIVE FOR UPDATE TO ranker USING
    (is_ranker(executor_id) = 1);


--Просматривать задание, автором которого является менеджер, может ... автор, исполнитель задания.
CREATE POLICY manager_select_task_self ON task AS PERMISSIVE FOR SELECT  TO manager USING
    (is_manager(author_id) = 1);

CREATE POLICY manager_select_task_ranker ON task AS PERMISSIVE FOR SELECT TO manager USING
    (is_manager(executor_id) = 1);

CREATE POLICY ranker_select_tasks ON task AS PERMISSIVE FOR SELECT TO ranker USING
    (is_ranker(executor_id) = 1);


----По прошествии 12 месяцев после даты завершения задания сведения о нем удаляются из системы.
CREATE POLICY manager_delete_task ON task AS PERMISSIVE FOR DELETE TO manager USING
    (is_manager(executor_id) = 1
        or is_manager(author_id) = 1 and completion_date is not null);

CREATE POLICY ranker_delete_tasks ON task AS PERMISSIVE FOR DELETE TO ranker USING
    (is_ranker(executor_id) = 1 and completion_date is not null);
