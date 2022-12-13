
--------------------------------------------------------index-----------------------------------------------------------
create index if not exists user_email_index on "user" using btree (email);
create index if not exists user_full_name_index on "user" using btree (full_name);


--------------------------------------------------------trigger---------------------------------------------------------

create or replace function check_student_role() returns trigger as $insert_user_check_role$
begin
    if (select role from "user" where id = new.id) in ('student','student_leader','student_leader_assistant') = true then
        insert into student(id, study_group_base_id) values (new.id, new.study_group_base_id);
    end if;
    return null;
end;
$insert_user_check_role$ language plpgsql;

create or replace trigger insert_student_check_role before insert or update on student
    for statement execute function check_student_role();



create or replace function check_teacher_role() returns trigger as $insert_teacher_check_role$
begin
    if (select role from "user" where id = new.user_id) = 'teacher'::user_role then
        insert into teacher values (new.id, new.discipline_id, new.user_id);
    end if;
    return null;
end;
$insert_teacher_check_role$ language plpgsql;

create or replace trigger set_teacher_check_role before insert or update on teacher
    for statement execute function check_teacher_role();



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
CREATE OR REPLACE FUNCTION truncate_tables(username IN VARCHAR) RETURNS void AS $$
DECLARE
    statements CURSOR FOR
        SELECT tablename FROM pg_tables
        WHERE tableowner = username AND schemaname = 'public';
BEGIN
    FOR stmt IN statements LOOP
        EXECUTE 'TRUNCATE TABLE ' || quote_ident(stmt.tablename) || ' CASCADE;';
    END LOOP;
END;
$$ LANGUAGE plpgsql;
