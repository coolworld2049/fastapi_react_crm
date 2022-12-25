
grant usage on all sequences in schema public to admin;
grant usage on all sequences in schema public to teacher;
grant usage on all sequences in schema public to student;
grant usage on all sequences in schema public to leader;


grant all privileges on all tables in schema public to admin;
grant usage, select, update on all sequences in schema public to admin;
grant insert, select, update, delete on table campus to admin;
grant insert, select, update, delete on table discipline to admin;
grant insert, select, update, delete on table student to admin;
grant         select, update, delete on table student_task to admin;
grant         select                 on table student_task_store to admin;
grant insert, select, update, delete on table study_group_cipher to admin;
grant insert, select, update, delete on table study_group to admin;
grant         select, update, delete on table study_group_task to admin;
grant         select, update         on table task to admin;
grant insert, select, update, delete on table teacher to admin;
grant insert, select, update         on table "user" to admin;


grant         select         on table campus to student;
grant         select         on table discipline to student;
grant         select, update on table student to student;
grant         select, update on table student_task to student;
grant insert, select, update on table student_task_store to student;
grant         select         on table study_group to student;
grant         select         on table study_group_cipher to student;
grant         select         on table study_group_task to student;
grant         select         on table task to student;
grant         select         on table teacher to student;
grant         select, update on table "user" to student;



grant insert, select, update on table discipline to leader;
grant insert, select, update on table campus to leader;
grant insert, select, update on table student to leader;
grant         select, update on table student_task to leader;
grant insert, select, update on table student_task_store to leader;
grant insert, select, update on table study_group to leader;
grant insert, select, update on table study_group_cipher to leader;
grant         select, update on table study_group_task to leader;
grant         select         on table task to leader;
grant         select         on table teacher to leader;
grant insert, select, update on table "user" to leader;



grant insert, select, update on table campus to teacher;
grant         select         on table discipline to teacher;
grant         select         on table student to teacher;
grant insert, select, update on table student_task to teacher;
grant         select         on table student_task_store to teacher;
grant insert, select, update on table study_group to teacher;
grant insert, select, update on table study_group_cipher to teacher;
grant insert, select, update on table study_group_task to teacher;
grant insert, select         on table task to teacher;
grant insert, select, update on table teacher to teacher;
grant insert, select, update on table "user" to teacher;
