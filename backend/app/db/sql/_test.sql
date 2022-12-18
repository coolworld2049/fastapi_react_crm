
insert into "user"
values (1, 'admin@gmail.com', 'admin', 'admin', 'i`m admin', 'ka52helicopter', 30, null, true, true),
       (2, 'student1@gmail.com', 'student1', 'student', 'i`m student1', 'mig30fighter', 20, null, true, false),
       (3, 'student2@gmail.com', 'student2', 'student', 'i`m student2', 'mig31fighter', 20, null, true, false),
       (4, 'student3@gmail.com', 'student3', 'student', 'i`m student3', 'mig32fighter', 20, null, true, false),
       (5, 'teacher1@gmail.com', 'teacher1', 'teacher', 'i`m teacher1', 'mig28fighter', 35, null, true, false),
       (6, 'teacher2@gmail.com', 'teacher2', 'teacher', 'i`m teacher2', 'mig29fighter', 35, null, true, false);


insert into user_contact
values (1, '+79998887766'),
       (2, '+79998887754'),
       (3, '+79998887745'),
       (4, '+79998887775'),
       (5, '+79998887741');

insert into campus
values ('В-78'), ('С-20'), ('П-1');

insert into discipline
values (10, 'Программные средства манипулирования данными (часть 1/1) [I.22-23]', 'exam'),
       (20, 'Интерпретируемый язык программирования высокого уровня (часть 2/2) [I.22-23]', 'exam');

insert into discipline_typed
values (100, 10, 'practice'::type_discipline, '105-2', 'В-78'),
       (200, 10, 'lecture'::type_discipline, 'A-10', 'В-78');


insert into study_group_cipher
values ('БСБО-07-20'),
       ('БСБО-06-20'),
       ('БСБО-04-20');

insert into study_group
values (1111, 1000, 10),
       (2222, 1000, 20),
       (3333, 2000, 10),
       (4444, 2000, 20),
       (5555, 3000, 10),
       (6666, 3000, 20);

insert into student
values (2, 1000),
       (3, 2000),
       (4, 3000);

insert into teacher
values (1010, 10, 5),
       (1020, 20, 6);

--teacher
insert into task
values (9001, 1010, 1000, null, 'практики 1-8', 'do', 'pending', 'medium', '09-12-2023 12:00:00 +03:00'),
       (9002, 1010, 1000, null, 'курсовая работа', 'do', 'pending', 'high', '24-12-2023 12:00:00 +03:00'),
       (9003, 1020, null, 2, 'доклад postgres', 'do', 'pending', 'high', '28-12-2023 12:00:00 +03:00'),
       (9004, 1020, null, 3, 'доклад mongodb', 'do', 'pending', 'medium', '29-12-2023 12:00:00 +03:00'),
       (9005, 1020, null, 4, 'доклад mssql', 'do', 'pending', 'low', '30-12-2023 12:00:00 +03:00');
insert into student_task values (9003, null, null, null, null, '01-12-2023 12:00:00 +03:00');

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
