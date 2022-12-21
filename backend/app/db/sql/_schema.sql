create type user_role as enum (
    'admin',
    'anon',
    'student',
    'teacher'
);

create type student_role as enum (
    'student',
    'leader'
);

create type teacher_role as enum (
    'lecturer',
    'practicioner'
);

create type type_assessment as enum (
    'test',
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
    full_name text,
    username text unique not null,
    age smallint,
    phone varchar(20),
    avatar text,
    is_online boolean default true,
    is_active boolean not null default true,
    "is_superuser" boolean not null default false,
    create_date timestamptz default localtimestamp,
    constraint c_username_is_not_role check ( username != "role"::text),
    constraint c_full_name_is_not_role check ( full_name != "role"::text)
);

create table if not exists discipline (
    id bigserial primary key,
    title text not null,
    assessment type_assessment
);

create table if not exists campus (
    id varchar(20) primary key,
    address text
);

create table if not exists study_group_cipher (
    id varchar(30) primary key
);

create table if not exists study_group (
    id varchar(30) references study_group_cipher not null,
    discipline_id bigint references discipline(id) not null,
    primary key (id, discipline_id)
);

create table if not exists student (
    id bigserial references "user"(id) primary key,
    "role" student_role not null,
    study_group_cipher_id varchar(30)
);


create table if not exists teacher (
    id bigserial primary key,
    user_id bigserial references "user"(id) not null,
    "role" teacher_role not null,
    discipline_id bigint references discipline(id) not null,
    room_number varchar(10),
    campus_id varchar(20) references campus(id)
);

create table if not exists task (
    id bigserial unique not null,
    teacher_id bigint references teacher(id) not null,
    title text not null,
    description text,
    priority task_priority not null default 'medium'::task_priority,
    create_date timestamptz default localtimestamp,
    primary key (teacher_id, title)
);

create table if not exists study_group_task (
    id bigint references task(id) not null,
    study_group_cipher_id varchar(30) references study_group_cipher(id) not null,
    status task_status not null default 'accepted'::task_status,
    deadline_date timestamptz,
    primary key (id, study_group_cipher_id)
);

create table if not exists student_task (
    id bigint references task(id) not null,
    student_id bigint references student(id) not null,
    status task_status not null default 'pending'::task_status,
    points smallint,
    "comment" text,
    feedback text,
    grade task_grade_type,
    deadline_date timestamptz,
    completion_date timestamptz,
    constraint c_date check ( completion_date < deadline_date ),
    primary key (id, student_id)
);

create table if not exists student_task_store (
    id bigserial unique not null,
    task_id bigint references task(id) not null,
    student_id bigint references student(id) not null,
    url text not null,
    size bigint not null,
    filename text,
    create_date timestamptz default localtimestamp,
    constraint c_file_size check ( size <= 160000000 ), --20MB max
    primary key (task_id, student_id, url)
);
