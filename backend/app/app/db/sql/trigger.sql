
create or replace function check_user_role_after() returns trigger as $insert_user_role_after$
begin
    if new.role::text = 'student' then
        insert into student(id) values (new.id);
    end if;
    return old;
end;
$insert_user_role_after$ language plpgsql;

create or replace trigger insert_user_role_after after insert on "user"
    for each row execute function check_user_role_after();



create or replace function check_student_task_completion_date()
    returns trigger as $set_student_task_start_date$
begin
    if (select status from student_task where id = new.id) = 'completed'::task_status then
        update student_task set completion_date = clock_timestamp() where id = new.id;
    end if;
    return new;
end;
$set_student_task_start_date$ language plpgsql;

create or replace trigger set_student_task_completion_date before update on student_task
    for statement execute function check_student_task_completion_date();



create or replace function check_overdue_student_task()
    returns trigger as $set_student_task_start_date$
begin

    if (select deadline_date from student_task where id = new.id) >= now() then
        update student_task set status = 'overdue'::task_status where id = new.id;
    end if;
    return new;
end;
$set_student_task_start_date$ language plpgsql;

create or replace trigger _check_overdue_student_task before update on student_task
    for each row execute function check_overdue_student_task();



create or replace function check_study_group_task_old_rows() returns trigger as $delete_study_group_task_old_rows$
begin
    delete from study_group_task where deadline_date < localtimestamp - '1 year'::interval;
end;
$delete_study_group_task_old_rows$ language plpgsql;

create or replace trigger delete_study_group_task_old_rows before update on study_group_task
    for each row execute procedure check_study_group_task_old_rows();



create or replace function check_student_task_old_rows() returns trigger as $$
begin
    delete from student_task where completion_date < localtimestamp - '1 year'::interval;
end;
$$language plpgsql;

create or replace trigger delete_student_task_old_rows before update on student_task
    for each row execute procedure check_student_task_old_rows();
