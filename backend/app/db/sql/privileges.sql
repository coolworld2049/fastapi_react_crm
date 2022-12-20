
create user app_user with password 'password';
grant connect on database myapp to app_user;
grant usage on schema public to app_user;
grant select on all tables in schema public to app_user;

------------------------------------------------------privileges--------------------------------------------------------

grant all privileges on all tables in schema public to admin;
grant usage, select, update on all sequences in schema public to admin;
grant select, insert, update, delete on table task to admin;
grant select, insert, update, delete on table "user" to admin;

grant select, insert, update, delete on table task to student;
grant usage, select, update on all sequences in schema public to student;
grant select, update on table "user" to student;

grant select, update, delete on table task to student_leader;
grant usage, select, update on all sequences in schema public to student_leader;
grant select on "user" to student_leader;

grant select on table task to teacher;
grant usage, select, update on all sequences in schema public to teacher;
grant select on "user" to teacher;

------------------------------------------------------task-policies-----------------------------------------------------
