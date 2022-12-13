
------------------------------------------------------privileges--------------------------------------------------------
create role admin noinherit createrole;
create role student noinherit;
create role student_leader noinherit;
create role student_leader_assistant noinherit;
create role teacher noinherit;

grant all privileges on schema public to admin;
grant select, insert, update, delete on all tables in schema public to admin;
grant usage, select, update on all sequences in schema public to admin;
grant select, insert, update, delete on table task to admin;
grant select, insert, update, delete on table "user" to admin;

grant select, insert, update, delete on table public.task to student;
grant usage, select, update on all sequences in schema public to student;
grant select, update on table "user" to student;

grant select, update, delete on table public.task to student_leader;
grant usage, select, update on all sequences in schema public to student_leader;
grant select on "user" to student_leader;

grant select on table public.task to teacher;
grant usage, select, update on all sequences in schema public to teacher;
grant select on "user" to teacher;

------------------------------------------------------task-policies-----------------------------------------------------
