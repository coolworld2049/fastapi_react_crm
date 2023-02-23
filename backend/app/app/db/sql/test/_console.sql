
--список дисциплин cтуд групп
select id, array_agg(discipline_id) as discipline_id
from study_group group by id;

--список студентов студ групп
select study_group_cipher_id, array_agg(id) as id
from student group by study_group_cipher_id;

--список дисциплин преподавателей
select user_id, role, array_agg(discipline_id) as discipline_id
from teacher group by user_id, role;

--список дисциплин преподавателей практик
select user_id, array_agg(discipline_id) as discipline_id
from teacher where "role" = 'practicioner' group by user_id;

--список дисциплин преподавателей лекций
select user_id, array_agg(discipline_id) as discipline_id
from teacher where "role" = 'lecturer' group by user_id;


--список преподователей и их дисциплин
select user_id, discipline_id, array_agg(role) as discipline_id_role_type
from teacher group by user_id, discipline_id;


--задачи студ групп
explain select study_group_cipher_id, array_agg(t.id) as task_id
from study_group_task
    join task t on t.id = study_group_task.id
group by study_group_cipher_id
order by study_group_cipher_id;


--задачи студентов
explain select student_id, array_agg(t.id) as task_id
from student_task
    join task t on t.id = student_task.id
group by student_id
order by student_id;


--group role by username
with recursive cte as (
   select oid from pg_roles where rolname = 'ka52'

   union all
   select m.roleid
   from   cte
   join   pg_auth_members m on m.member = cte.oid
   )
select oid, oid::regrole::text as rolename from cte;  -- oid & name
