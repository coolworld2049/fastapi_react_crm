
--------------------------------------------------------index-----------------------------------------------------------
create index company_name_index on company using btree ("name");
create index company_address_index on company using btree (address);
create index user_full_name_index on "user" using btree (full_name);
create index user_phone_index on "user" using btree (phone);
create index user_email_index on "user" using btree (email);


--------------------------------------------------------trigger---------------------------------------------------------
create or replace function delete_old_rows() returns trigger language plpgsql as
$body$
begin
    delete from task where completion_date::timestamp < clock_timestamp() at time zone 'MSK' - '1 year'::interval;
    return null;
end;
$body$;

--по прошествии 12 месяцев после даты завершения задания сведения о нем удаляются из системы.
create or replace trigger task_mgmt before insert or update on task
    for each statement execute procedure delete_old_rows();

--------------------------------------------------------report----------------------------------------------------------

-- общее количество заданий для данного сотрудника в указанный период
drop function if exists total_number_employee_tasks_in_period(timestamp, timestamp, integer);
create or replace function total_number_employee_tasks_in_period
    (start_timestamp timestamp , end_timestamp timestamp , employee_id integer)
    returns integer language plpgsql as
$body$
begin
    return (select count(*) from task where executor_id = employee_id
                                                     or author_id = employee_id
                                                  and create_date between start_timestamp and end_timestamp);
end;
$body$;

-- сколько заданий завершено вовремя
drop function if exists number_employee_tasks_completed_on_time(timestamp, timestamp, integer);
create or replace function number_employee_tasks_completed_on_time
    (start_timestamp timestamp , end_timestamp timestamp , employee_id integer)
    returns integer language plpgsql as
$body$
begin
    return (select count(*) from task where executor_id = employee_id
                                                     or author_id = employee_id
                                                            and completion_date is not null
                                                            and deadline_date::timestamp >= completion_date::timestamp
                                                            and create_date between start_timestamp and end_timestamp);
end;
$body$;

-- сколько заданий завершено с нарушением срока исполнения
drop function if exists number_employee_tasks_not_completed_on_time(timestamp, timestamp, integer);
create or replace function number_employee_tasks_not_completed_on_time
    (start_timestamp timestamp , end_timestamp timestamp , employee_id integer)
    returns integer language plpgsql as
$body$
begin
    return (select count(*) from task where executor_id = employee_id
                                                     or author_id = employee_id
                                                            and completion_date is not null  and deadline_date is not null
                                                            and deadline_date::timestamp < completion_date::timestamp
                                                            and create_date between start_timestamp and end_timestamp);
end;
$body$;

-- сколько заданий с истекшим сроком исполнения не завершено
drop function if exists number_employee_tasks_unfinished(timestamp, timestamp, integer);
create or replace function number_employee_tasks_unfinished
    (start_timestamp timestamp , end_timestamp timestamp , employee_id integer)
    returns integer language plpgsql as
$body$
begin
    return (select count(*) from task where executor_id = employee_id
                                                     or author_id = employee_id
                                                            and deadline_date is not null
                                                            and clock_timestamp() at time zone 'MSK' > deadline_date::timestamp
                                                            and completion_date is null
                                                            and create_date between start_timestamp and end_timestamp);
end;
$body$;


-- сколько не завершенных заданий, срок исполнения которых не истек
drop function if exists number_employee_tasks_unfinished_that_not_expired(timestamp, timestamp, integer);
create or replace function number_employee_tasks_unfinished_that_not_expired
    (start_timestamp timestamp , end_timestamp timestamp , employee_id integer)
    returns integer language plpgsql as
$body$
begin
    return (select count(*) from task where executor_id = employee_id
                                                     or author_id = employee_id
                                                            and deadline_date is not null
                                                            and clock_timestamp() at time zone 'MSK' < deadline_date::timestamp
                                                            and completion_date is null
                                                            and create_date between start_timestamp and end_timestamp);
end;
$body$;

-- система генерирует отчет по исполнению заданий каким-либо сотрудником
-- в течение периода времени, указываемого в параметре отчета.
drop function if exists generate_report_by_period_and_employee(timestamp, timestamp, integer);
create or replace function generate_report_by_period_and_employee(start_timestamp timestamp , end_timestamp timestamp, _employee_id integer)
    returns table (report_id uuid,
                    employee_id integer,
                    total_number_employee_tasks_in_period integer,
                    number_employee_tasks_completed_on_time integer,
                    number_employee_tasks_not_completed_on_time integer,
                    number_employee_tasks_unfinished integer,
                    number_employee_tasks_unfinished_that_not_expired integer,
                    start_period timestamp,
                    end_period timestamp,
                    create_date timestamp) language plpgsql
as $body$
begin
    return query
        select gen_random_uuid(),
                _employee_id,
                total_number_employee_tasks_in_period(start_timestamp, end_timestamp, _employee_id),
                number_employee_tasks_completed_on_time(start_timestamp, end_timestamp, _employee_id),
                number_employee_tasks_not_completed_on_time(start_timestamp, end_timestamp, _employee_id),
                number_employee_tasks_unfinished(start_timestamp, end_timestamp, _employee_id),
                number_employee_tasks_unfinished_that_not_expired(start_timestamp, end_timestamp, _employee_id),
                start_timestamp AT TIME ZONE 'Europe/Moscow',
                end_timestamp AT TIME ZONE 'Europe/Moscow',
                (SELECT clock_timestamp() AT TIME ZONE 'Europe/Moscow');
end;
$body$;

drop function if exists generate_report_for_all_employees(timestamp, timestamp);
create or replace function generate_report_for_all_employees(start_timestamp timestamp , end_timestamp timestamp)
    returns table (report_id uuid,
                    employee_id integer,
                    total_number_employee_tasks_in_period integer,
                    number_employee_tasks_completed_on_time integer,
                    number_employee_tasks_not_completed_on_time integer,
                    number_employee_tasks_unfinished integer,
                    number_employee_tasks_unfinished_that_not_expired integer,
                    start_period timestamp,
                    end_period timestamp,
                    create_date timestamp) language plpgsql
    as $body$
begin
    return query
        (select gen_random_uuid(),
                id,
                total_number_employee_tasks_in_period(start_timestamp, end_timestamp, id),
                number_employee_tasks_completed_on_time(start_timestamp, end_timestamp, id),
                number_employee_tasks_not_completed_on_time(start_timestamp, end_timestamp, id),
                number_employee_tasks_unfinished(start_timestamp, end_timestamp, id),
                number_employee_tasks_unfinished_that_not_expired(start_timestamp, end_timestamp, id),
                start_timestamp AT TIME ZONE 'Europe/Moscow',
                end_timestamp AT TIME ZONE 'Europe/Moscow',
                (SELECT clock_timestamp() AT TIME ZONE 'Europe/Moscow') from "user");
end;
$body$;

------------------------------------------------------------------------------------------------------------------------

drop function if exists generate_report_for_all_employees_to_csv(timestamp, timestamp);
create or replace function generate_report_for_all_employees_to_csv(
    start_timestamp timestamp,
    end_timestamp timestamp
) returns void
language plpgsql
as $body$
begin

    copy (select * from generate_report_for_all_employees(
    start_timestamp::timestamp,
    end_timestamp::timestamp))
    to '/tmp/report.csv' delimiter ',' csv header;
end;
$body$;


drop function if exists generate_report_for_all_employees_to_json(timestamp, timestamp);
create or replace function generate_report_for_all_employees_to_json(
    start_timestamp timestamp,
    end_timestamp timestamp
) returns void
language plpgsql
as $body$
begin
    copy (select array_to_json(array_agg(row_to_json(results))) from (select * from generate_report_for_all_employees(
    start_timestamp::timestamp,
    end_timestamp::timestamp)) as results) to '/tmp/report.json'
    with (format text, header false);
end;
$body$;

------------------------------------------------------------------------------------------------------------------------
/*
drop procedure if exists generate_report_for_employee_to_csv(timestamp, timestamp, integer);
create or replace procedure generate_report_for_employee_to_csv(
    start_timestamp timestamp,
    end_timestamp timestamp,
    employee_id integer)
language plpgsql
as $body$
    declare rec table (report_id uuid,
                        employee_id integer,
                        total_number_employee_tasks_in_period integer,
                        number_employee_tasks_completed_on_time integer,
                        number_employee_tasks_not_completed_on_time integer,
                        number_employee_tasks_unfinished integer,
                        number_employee_tasks_unfinished_that_not_expired integer,
                        start_period timestamp,
                        end_period timestamp,
                        create_date timestamp);
begin
    select results into rec from (select * from generate_report_by_period_and_employee(
        start_timestamp::timestamp,
        end_timestamp::timestamp,
        employee_id)) as results;
    copy rec to '/tmp/report.csv' delimiter ',' csv header;
end;
$body$;

drop procedure if exists generate_report_for_employee_to_json(timestamp, timestamp, integer);
create or replace procedure generate_report_for_employee_to_json(
    start_timestamp timestamp,
    end_timestamp timestamp,
    employee_id integer)
language plpgsql
as $body$
    declare rec table (report_id uuid,
                        employee_id integer,
                        total_number_employee_tasks_in_period integer,
                        number_employee_tasks_completed_on_time integer,
                        number_employee_tasks_not_completed_on_time integer,
                        number_employee_tasks_unfinished integer,
                        number_employee_tasks_unfinished_that_not_expired integer,
                        start_period timestamp,
                        end_period timestamp,
                        create_date timestamp);
begin
    select results into rec from (select * from generate_report_by_period_and_employee(
        start_timestamp::timestamp,
        end_timestamp::timestamp,
        employee_id)) as results;
    copy (select array_to_json(array_agg(row_to_json(rec)))) to '/tmp/report.json'
    with (format text, header false);
end;
$body$;
*/

/*
COPY (select * from generate_report_for_all_employees(
    '2021-12-01 14:51:00 +00:00'::timestamp,
    '2023-12-01 14:51:00 +00:00'::timestamp
    )) to '/tmp/report.csv' delimiter ',' csv header;

COPY (select array_to_json(array_agg(row_to_json(results))) from generate_report_for_all_employees(
    '2021-12-01 14:51:00 +00:00'::timestamp,
    '2023-12-01 14:51:00 +00:00'::timestamp
    ) as results) to '/tmp/report.json' with (format text, header false );
*/
