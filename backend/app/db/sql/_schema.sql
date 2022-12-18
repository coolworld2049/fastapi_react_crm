create type user_role as enum (
    'admin',
    'anon',
    'student',
    'student_leader',
    'student_leader_assistant',
    'teacher'
);

create type discipline_type as enum (
    'lecture',
    'practice',
    'laboratory',
    'coursework',
    'test',
    'consultation',
    'exam',
    'project'
);

create type type_assessment as enum (
    'test',
    'test_diff',
    'coursework',
    'exam'
);

create type task_status as enum (
    'unassigned',
    'pending',
    'started',
    'verifying',
    'accepted',
    'overdue',
    'completed'
);

create type task_grade_type as enum (
    'good',
    'great',
    'normal',
    'bad',
    'passed',
    'not_passed'
);

create type task_priority as enum ('high', 'medium', 'low');


create table if not exists "user"
(
    id bigserial primary key,
    email text unique not null,
    hashed_password text,
    "role" user_role not null default 'anon'::user_role ,
    full_name text
        constraint c_full_name_is_not_role check ( full_name != "role"::text),
    username text unique not null
        constraint c_username_is_not_role check ( username != "role"::text),
    age smallint,
    phone varchar(20) not null,
    avatar text,
    is_active boolean not null default true,
    "is_superuser" boolean not null default false,
    create_date timestamp with time zone default localtimestamp
);

create table if not exists campus (
    id text primary key,
    address text
);

create table if not exists discipline (
    id bigserial primary key,
    title text not null,
    assessment type_assessment
);

create table if not exists discipline_typed (
    id bigserial primary key,
    discipline_id bigint references discipline(id) not null,
    "type" discipline_type not null,
    classroom_number text not null,
    campus_id text references campus(id) not null,
    create_date timestamp with time zone default localtimestamp
);

create table if not exists study_group_cipher (
    id varchar(30) primary key
);

create table if not exists study_group (
    id bigserial primary key,
    study_group_base_id varchar references study_group_cipher(id) not null,
    discipline_id bigint references discipline(id) not null
);

create table if not exists student (
    id bigserial references "user"(id) primary key,
    study_group_base_id varchar references study_group_cipher(id) not null
);


create table if not exists teacher (
    id bigserial primary key,
    user_id bigint references "user"(id) not null,
    discipline_id bigint references discipline(id) not null
);

create table if not exists task (
    id bigserial primary key,
    teacher_id bigint references teacher(id) not null,
    study_group_base_id varchar references study_group_cipher(id) ,
    student_id bigint references student(id),
    title text not null,
    description text,
    status task_status not null default 'pending'::task_status,
    priority task_priority not null default 'medium'::task_priority,
    expiration_date timestamp with time zone not null,
    create_date timestamp with time zone default localtimestamp,
    constraint c_date check ( task.expiration_date >= task.create_date )
);

create table if not exists task_store (
    id bigserial primary key,
    task_id bigint references task(id) not null,
    url text not null,
    size bigint constraint c_file_size check ( size <= 838860800 ) not null, --100mb
    filename text,
    media_type varchar(150),
    create_date timestamp with time zone default localtimestamp
);

create table if not exists student_task (
    id bigint references task(id) primary key not null,
    points smallint,
    "comment" text,
    feedback text,
    grade task_grade_type,
    deadline_date timestamp with time zone,
    start_date timestamp with time zone,
    completion_date timestamp with time zone,
    constraint c_data check ( student_task.completion_date < student_task.deadline_date )
);





create or replace function check_student_role() returns trigger as $insert_user_check_role$
begin
    if (select role from "user" where id = new.id) in ('student','student_leader','student_leader_assistant') = true then
        insert into student values (new);
    end if;
    return null;
end;
$insert_user_check_role$ language plpgsql;

create or replace trigger insert_student_check_role before insert or update on student
    for statement execute function check_student_role();

create or replace function check_teacher_role() returns trigger as $insert_teacher_check_role$
begin
    if (select role from "user" where id = new.user_id) = 'teacher'::user_role then
        insert into student values (new);
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
