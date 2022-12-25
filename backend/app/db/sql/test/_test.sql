
insert into "user"
values (1, 'admin@gmail.com', 'admin', 'admin', 'i`m admin', 'ka52helicopter', 30, null, true, true),
       (2, 'student1@gmail.com', 'student1', 'student', 'i`m student1', 'mig30fighter', 20, null, true, false),
       (3, 'student2@gmail.com', 'student2', 'student', 'i`m student2', 'mig31fighter', 20, null, true, false),
       (4, 'student3@gmail.com', 'student3', 'student', 'i`m student3', 'mig32fighter', 20, null, true, false),
       (5, 'teacher1@gmail.com', 'teacher1', 'teacher', 'i`m teacher1', 'mig28fighter', 35, null, true, false),
       (6, 'teacher2@gmail.com', 'teacher2', 'teacher', 'i`m teacher2', 'mig29fighter', 35, null, true, false),
       (7, 'teacher7@gmail.com', 'teacher7', 'teacher', 'i`m teacher7', 'mig27fighter', 35, null, true, false);


insert into campus
values ('В-78', 'Moсква, ...'), ('С-20', 'Moсква, ...'), ('П-1', 'Moсква, ...');

insert into discipline
values (10, 'Программные средства манипулирования данными (часть 1/1) [I.22-23]', '{exam,coursework}'),
       (20, 'Интерпретируемый язык программирования высокого уровня (часть 2/2) [I.22-23]', '{test}');

insert into study_group_cipher
values ('ABCD-04-20'),
       ('ABCD-05-20'),
       ('ABCD-06-20');

insert into study_group
values ('ABCD-04-20', 10),
       ('ABCD-04-20', 20),
       ('ABCD-05-20', 10),
       ('ABCD-05-20', 20),
       ('ABCD-06-20', 10),
       ('ABCD-06-20', 20);

insert into student
values (2, 'student', 'ABCD-04-20'),
       (3, 'leader', 'ABCD-04-20'),
       (4, 'student', 'ABCD-06-20');

insert into teacher
values (1, 5, 'lecturer', 10, '105-2', 'В-78'),
       (2, 5, 'practicioner', 10, 'A-10', 'В-78'),
       (3, 6, 'lecturer', 20, '223', 'С-20'),
       (4, 6, 'practicioner', 20, '512', 'П-1'),
       (5, 7, 'practicioner', 20, '512', 'П-1');

insert into teacher
values (6, 7, 'practicioner', 10, '512', 'П-1');

insert into teacher
values (7, 7, 'lecturer', 10, '512', 'П-1');



--teacher
insert into task
values (9001, 5, 'practicioner', 10, 'практики1-4'),
       (9002, 5, 'practicioner', 10, 'доп задание'),
       (9003, 7, 'lecturer', 10, 'курсовая работа'),

       (9004, 6, 'lecturer', 20, 'доклад'),
       (9005, 6, 'lecturer', 20, 'реферат'),
       (9006, 7, 'practicioner', 20, 'asd');


insert into study_group_task
values (9001, 'ABCD-04-20', 'pending', timestamptz('09-12-2023 12:00:00')),
       (9003, 'ABCD-06-20', 'pending', timestamptz('09-12-2023 12:00:00')),
       (9006, 'ABCD-06-20', 'pending', timestamptz('09-12-2023 12:00:00'));


insert into student_task
values (9002, 2, 'pending', 'low', null, null, null, null, timestamptz('09-12-2023 12:00:00')),
       (9004, 3, 'started', 'low', null, null, null, null, timestamptz('09-12-2023 12:00:00')),
       (9005, 4, 'started', 'low', null, null, null, null, timestamptz('09-12-2023 12:00:00'));

insert into student_task_store values (7001, 9002, 2, 'https://drive.google.com/drive/...', 7879878, 'report1.pdf');
insert into student_task_store values (7002, 9004, 3, 'https://drive.google.com/drive/asad', 15545888, 'report2.pdf');


/*
--student
update task set status = 'started' where id = 9003;

update student_task set start_date = clock_timestamp() where id = 9003; --trigger
insert into task_store values (8001, 9003, 'https://drive.google.com/drive/...', 7879878, 'report.pdf');
select pg_sleep(3.0);
update task set status = 'accepted' where id = 9003;

--teacher
select pg_sleep(3.0);
update task set status = 'verifying' where id = 9003;
select pg_sleep(3.0);
update task set status = 'completed' where id = 9003;

-- noinspection SqlResolve
update student_task set points = 5, grade = 'great', feedback = 'good job', completion_date = clock_timestamp()
                    where id = 9003; --trigger
*/
