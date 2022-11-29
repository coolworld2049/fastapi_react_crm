\connect app;

--------------------------------------------------------INDEX-----------------------------------------------------------
CREATE INDEX company_address_index ON company USING btree (address);
CREATE INDEX company_name_index ON company USING btree (name);
CREATE INDEX client_name_index ON "user" USING btree (full_name);


--------------------------------------------------------TRIGGER---------------------------------------------------------
CREATE OR REPLACE FUNCTION delete_old_rows() RETURNS trigger LANGUAGE plpgsql AS
$BODY$
BEGIN
    DELETE FROM task WHERE completion_date < localtimestamp - '1 year'::interval;
    RETURN NULL;
END;
$BODY$;

--По прошествии 12 месяцев после даты завершения задания сведения о нем удаляются из системы.
CREATE OR REPLACE TRIGGER task_mgmt BEFORE INSERT OR UPDATE ON task
    FOR EACH STATEMENT EXECUTE PROCEDURE delete_old_rows();

--------------------------------------------------------REPORT----------------------------------------------------------
SET ROLE postgres;

-- общее количество заданий для данного сотрудника в указанный период
CREATE OR REPLACE FUNCTION total_number_employee_tasks_in_period
    (start_timestamp timestamp with time zone , end_timestamp timestamp with time zone , employee_id integer)
    RETURNS integer LANGUAGE plpgsql AS
$BODY$
BEGIN
    RETURN (SELECT count(*) FROM task WHERE executor_id = employee_id
                                                     or author_id = employee_id
                                                  and create_date BETWEEN start_timestamp and end_timestamp);
END;
$BODY$;

-- сколько заданий завершено вовремя
CREATE OR REPLACE FUNCTION number_employee_tasks_completed_on_time
    (start_timestamp timestamp with time zone , end_timestamp timestamp with time zone , employee_id integer)
    RETURNS integer LANGUAGE plpgsql AS
$BODY$
BEGIN
    RETURN (SELECT count(*) FROM task WHERE executor_id = employee_id
                                                     or author_id = employee_id
                                                            and deadline_date::timestamp with time zone >= completion_date::timestamp with time zone
                                                            and create_date BETWEEN start_timestamp and end_timestamp);
END;
$BODY$;

-- сколько заданий завершено с нарушением срока исполнения
CREATE OR REPLACE FUNCTION number_employee_tasks_not_completed_on_time
    (start_timestamp timestamp with time zone , end_timestamp timestamp with time zone , employee_id integer)
    RETURNS integer LANGUAGE plpgsql AS
$BODY$
BEGIN
    RETURN (SELECT count(*) FROM task WHERE executor_id = employee_id
                                                     or author_id = employee_id
                                                            and deadline_date::timestamp with time zone < completion_date::timestamp with time zone
                                                            and create_date BETWEEN start_timestamp and end_timestamp);
END;
$BODY$;

-- сколько заданий с истекшим сроком исполнения не завершено
CREATE OR REPLACE FUNCTION number_employee_tasks_unfinished
    (start_timestamp timestamp with time zone , end_timestamp timestamp with time zone , employee_id integer)
    RETURNS integer LANGUAGE plpgsql AS
$BODY$
BEGIN
    RETURN (SELECT count(*) FROM task WHERE executor_id = employee_id
                                                     or author_id = employee_id
                                                            and current_timestamp > deadline_date::timestamp with time zone
                                                            and completion_date is null
                                                            and create_date BETWEEN start_timestamp and end_timestamp);
END;
$BODY$;


-- сколько не завершенных заданий, срок исполнения которых не истек
CREATE OR REPLACE FUNCTION number_employee_tasks_unfinished_that_not_expired
    (start_timestamp timestamp with time zone , end_timestamp timestamp with time zone , employee_id integer)
    RETURNS integer LANGUAGE plpgsql AS
$BODY$
BEGIN
    RETURN (SELECT count(*) FROM task WHERE executor_id = employee_id
                                                     or author_id = employee_id
                                                            and current_timestamp < deadline_date::timestamp
                                                            and completion_date is null
                                                            and create_date BETWEEN start_timestamp and end_timestamp);
END;
$BODY$;

-- Система генерирует отчет по исполнению заданий каким-либо сотрудником
-- в течение периода времени, указываемого в параметре отчета.
CREATE OR REPLACE FUNCTION generate_report_by_period_and_employee(start_timestamp timestamp with time zone , end_timestamp timestamp with time zone, employee_id integer)
    RETURNS RECORD LANGUAGE plpgsql AS
$BODY$
DECLARE
    report RECORD;
BEGIN
    SELECT gen_random_uuid(),
            employee_id,
            total_number_employee_tasks_in_period(start_timestamp, end_timestamp, employee_id),
            number_employee_tasks_completed_on_time(start_timestamp, end_timestamp, employee_id),
            number_employee_tasks_not_completed_on_time(start_timestamp, end_timestamp, employee_id),
            number_employee_tasks_unfinished(start_timestamp, end_timestamp, employee_id),
            number_employee_tasks_unfinished_that_not_expired(start_timestamp, end_timestamp, employee_id),
            "start_timestamp",
            "end_timestamp",
            localtimestamp INTO report;
    RETURN report;
END;
$BODY$;

CREATE OR REPLACE FUNCTION generate_report_for_all_employees(start_timestamp timestamp with time zone , end_timestamp timestamp with time zone)
    RETURNS TABLE (employee_id integer,
                    total_number_employee_tasks_in_period integer,
                    number_employee_tasks_completed_on_time integer,
                    number_employee_tasks_not_completed_on_time integer,
                    number_employee_tasks_unfinished integer,
                    number_employee_tasks_unfinished_that_not_expired integer,
                    period json,
                    create_date timestamp with time zone) LANGUAGE plpgsql AS $BODY$
    DECLARE ctm timestamp with time zone = current_timestamp;
    DECLARE filter_by json = json_build_object(
        'start_timestamp',start_timestamp,
        'end_timestamp', end_timestamp
        );
BEGIN
    RETURN QUERY
        SELECT id,
                total_number_employee_tasks_in_period(start_timestamp, end_timestamp, id),
                number_employee_tasks_completed_on_time(start_timestamp, end_timestamp, id),
                number_employee_tasks_not_completed_on_time(start_timestamp, end_timestamp, id),
                number_employee_tasks_unfinished(start_timestamp, end_timestamp, id),
                number_employee_tasks_unfinished_that_not_expired(start_timestamp, end_timestamp, id),
                filter_by,
                ctm FROM "user";
END;
$BODY$;


COPY (SELECT * FROM generate_report_for_all_employees(
    '2022-07-01 04:05:06 +00:00'::timestamp with time zone,
    '2022-11-01 04:05:06 +00:00'::timestamp with time zone
    ))
    TO '/tmp/report.csv' DELIMITER ',' CSV HEADER;

COPY (SELECT row_to_json(results) FROM generate_report_for_all_employees(
    '2022-07-01 04:05:06 +00:00'::timestamp with time zone,
    '2022-11-01 04:05:06 +00:00'::timestamp with time zone
    ) as results) TO '/tmp/report.json'
    WITH (FORMAT text, HEADER FALSE);
