
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
end;
$set_student_task_start_date$ language plpgsql;

create or replace trigger _check_overdue_student_task before update on student_task
    for statement execute procedure check_overdue_student_task();
