
--------------------------------------------------------index-----------------------------------------------------------
create index company_name_index on company using btree (name);
create index company_address_index on company using btree (address);
create index user_full_name_index on "user" using btree (full_name);
create index user_phone_index on "user" using btree (phone);
create index user_email_index on "user" using btree (email);


--------------------------------------------------------trigger---------------------------------------------------------
create or replace function delete_old_rows() returns trigger language plpgsql as
$body$
begin
    delete from task where completion_date < localtimestamp - '1 year'::interval;
    return null;
end;
$body$;

--по прошествии 12 месяцев после даты завершения задания сведения о нем удаляются из системы.
create or replace trigger task_mgmt before insert or update on task
    for each statement execute procedure delete_old_rows();

--------------------------------------------------------report----------------------------------------------------------
set role postgres;

-- общее количество заданий для данного сотрудника в указанный период
create or replace function total_number_employee_tasks_in_period
    (start_timestamp timestamp with time zone , end_timestamp timestamp with time zone , employee_id integer)
    returns integer language plpgsql as
$body$
begin
    return (select count(*) from task where executor_id = employee_id
                                                     or author_id = employee_id
                                                  and create_date between start_timestamp and end_timestamp);
end;
$body$;

-- сколько заданий завершено вовремя
create or replace function number_employee_tasks_completed_on_time
    (start_timestamp timestamp with time zone , end_timestamp timestamp with time zone , employee_id integer)
    returns integer language plpgsql as
$body$
begin
    return (select count(*) from task where executor_id = employee_id
                                                     or author_id = employee_id
                                                            and deadline_date::timestamp with time zone >= completion_date::timestamp with time zone
                                                            and create_date between start_timestamp and end_timestamp);
end;
$body$;

-- сколько заданий завершено с нарушением срока исполнения
create or replace function number_employee_tasks_not_completed_on_time
    (start_timestamp timestamp with time zone , end_timestamp timestamp with time zone , employee_id integer)
    returns integer language plpgsql as
$body$
begin
    return (select count(*) from task where executor_id = employee_id
                                                     or author_id = employee_id
                                                            and deadline_date::timestamp with time zone < completion_date::timestamp with time zone
                                                            and create_date between start_timestamp and end_timestamp);
end;
$body$;

-- сколько заданий с истекшим сроком исполнения не завершено
create or replace function number_employee_tasks_unfinished
    (start_timestamp timestamp with time zone , end_timestamp timestamp with time zone , employee_id integer)
    returns integer language plpgsql as
$body$
begin
    return (select count(*) from task where executor_id = employee_id
                                                     or author_id = employee_id
                                                            and current_timestamp > deadline_date::timestamp with time zone
                                                            and completion_date is null
                                                            and create_date between start_timestamp and end_timestamp);
end;
$body$;


-- сколько не завершенных заданий, срок исполнения которых не истек
create or replace function number_employee_tasks_unfinished_that_not_expired
    (start_timestamp timestamp with time zone , end_timestamp timestamp with time zone , employee_id integer)
    returns integer language plpgsql as
$body$
begin
    return (select count(*) from task where executor_id = employee_id
                                                     or author_id = employee_id
                                                            and current_timestamp < deadline_date::timestamp
                                                            and completion_date is null
                                                            and create_date between start_timestamp and end_timestamp);
end;
$body$;

-- система генерирует отчет по исполнению заданий каким-либо сотрудником
-- в течение периода времени, указываемого в параметре отчета.
create or replace function generate_report_by_period_and_employee(start_timestamp timestamp with time zone , end_timestamp timestamp with time zone, employee_id integer)
    returns record language plpgsql as
$body$
declare
    report record;
begin
    select gen_random_uuid(),
            employee_id,
            total_number_employee_tasks_in_period(start_timestamp, end_timestamp, employee_id),
            number_employee_tasks_completed_on_time(start_timestamp, end_timestamp, employee_id),
            number_employee_tasks_not_completed_on_time(start_timestamp, end_timestamp, employee_id),
            number_employee_tasks_unfinished(start_timestamp, end_timestamp, employee_id),
            number_employee_tasks_unfinished_that_not_expired(start_timestamp, end_timestamp, employee_id),
            "start_timestamp",
            "end_timestamp",
            localtimestamp into report;
    return report;
end;
$body$;

create or replace function generate_report_for_all_employees(start_timestamp timestamp with time zone , end_timestamp timestamp with time zone)
    returns table (employee_id integer,
                    total_number_employee_tasks_in_period integer,
                    number_employee_tasks_completed_on_time integer,
                    number_employee_tasks_not_completed_on_time integer,
                    number_employee_tasks_unfinished integer,
                    number_employee_tasks_unfinished_that_not_expired integer,
                    period json,
                    create_date timestamp with time zone) language plpgsql as $body$
    declare ctm timestamp with time zone = current_timestamp;
    declare filter_by json = json_build_object(
        'start_timestamp',start_timestamp,
        'end_timestamp', end_timestamp
        );
begin
    return query
        select id,
                total_number_employee_tasks_in_period(start_timestamp, end_timestamp, id),
                number_employee_tasks_completed_on_time(start_timestamp, end_timestamp, id),
                number_employee_tasks_not_completed_on_time(start_timestamp, end_timestamp, id),
                number_employee_tasks_unfinished(start_timestamp, end_timestamp, id),
                number_employee_tasks_unfinished_that_not_expired(start_timestamp, end_timestamp, id),
                filter_by,
                ctm from "user";
end;
$body$;


------------------------------------------------------------------------------------------------------------------------

create or replace function generate_report_for_all_employees_to_csv(
    start_timestamp timestamp with time zone,
    end_timestamp timestamp with time zone
) returns void
language plpgsql
as $body$
    declare rec record;
begin
    select generate_report_for_all_employees(
    start_timestamp::timestamp with time zone,
    end_timestamp::timestamp with time zone
    ) into rec;
    copy rec to '/tmp/report.csv' delimiter ',' csv header;
end;
$body$;


create or replace function generate_report_for_all_employees_to_json(
    start_timestamp timestamp with time zone,
    end_timestamp timestamp with time zone
) returns void
language plpgsql
as $body$
    declare rec record;
begin
    select generate_report_for_all_employees(
    start_timestamp::timestamp with time zone,
    end_timestamp::timestamp with time zone
    ) into rec;
    copy (select row_to_json(results) from rec  as results) to '/tmp/report.json'
    with (format text, header false);
end;
$body$;

------------------------------------------------------------------------------------------------------------------------

create or replace function generate_report_for_employee_to_csv(
    start_timestamp timestamp with time zone,
    end_timestamp timestamp with time zone,
    employee_id integer) returns void
language plpgsql
as $body$
    declare rec record;
begin
    select generate_report_by_period_and_employee(
        start_timestamp::timestamp with time zone,
        end_timestamp::timestamp with time zone,
        employee_id) into rec;
    copy rec to '/tmp/report.csv' delimiter ',' csv header;
end;
$body$;


create or replace function generate_report_for_employee_to_json(
    start_timestamp timestamp with time zone,
    end_timestamp timestamp with time zone,
    employee_id integer) returns void
language plpgsql
as $body$
    declare rec record;
begin
    select generate_report_by_period_and_employee(
        start_timestamp::timestamp with time zone,
        end_timestamp::timestamp with time zone,
        employee_id) into rec;

    copy (select row_to_json(results) from rec as results) to '/tmp/report.json'
    with (format text, header false);
end;
$body$;


/*
copy (select * from generate_report_for_all_employees(
    '2022-07-01 04:05:06 +00:00'::timestamp with time zone,
    '2022-11-01 04:05:06 +00:00'::timestamp with time zone
    ))
    to '/tmp/report.csv' delimiter ',' csv header;

copy (select row_to_json(results) from generate_report_for_all_employees(
    '2022-07-01 04:05:06 +00:00'::timestamp with time zone,
    '2022-11-01 04:05:06 +00:00'::timestamp with time zone
    ) as results) to '/tmp/report.json'
    with (format text, header false);
*/
