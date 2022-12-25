--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1 (Debian 15.1-1.pgdg110+1)
-- Dumped by pg_dump version 15.1 (Debian 15.1-1.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: student_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.student_role AS ENUM (
    'student',
    'leader'
);


ALTER TYPE public.student_role OWNER TO postgres;

--
-- Name: student_task_grade; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.student_task_grade AS ENUM (
    'good',
    'great',
    'normal',
    'bad',
    'passed',
    'not_passed'
);


ALTER TYPE public.student_task_grade OWNER TO postgres;

--
-- Name: task_priority; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.task_priority AS ENUM (
    'high',
    'medium',
    'low'
);


ALTER TYPE public.task_priority OWNER TO postgres;

--
-- Name: task_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.task_status AS ENUM (
    'unassigned',
    'pending',
    'started',
    'verifying',
    'accepted',
    'overdue',
    'completed'
);


ALTER TYPE public.task_status OWNER TO postgres;

--
-- Name: teacher_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.teacher_role AS ENUM (
    'lecturer',
    'practicioner'
);


ALTER TYPE public.teacher_role OWNER TO postgres;

--
-- Name: user_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.user_role AS ENUM (
    'admin',
    'anon',
    'student',
    'teacher'
);


ALTER TYPE public.user_role OWNER TO postgres;

--
-- Name: change_password(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.change_password(username text, old_password text, new_password text) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    execute 'alter user ' || username || ' identified by ' || old_password || ' replace ' || new_password;
end;
$$;


ALTER FUNCTION public.change_password(username text, old_password text, new_password text) OWNER TO postgres;

--
-- Name: check_overdue_student_task(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_overdue_student_task() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin

    if (select deadline_date from student_task where id = new.id) >= now() then
        update student_task set status = 'overdue'::task_status where id = new.id;
    end if;
    return new;
end;
$$;


ALTER FUNCTION public.check_overdue_student_task() OWNER TO postgres;

--
-- Name: check_student_task_completion_date(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_student_task_completion_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if (select status from student_task where id = new.id) = 'completed'::task_status then
        update student_task set completion_date = clock_timestamp() where id = new.id;
    end if;
    return new;
end;
$$;


ALTER FUNCTION public.check_student_task_completion_date() OWNER TO postgres;

--
-- Name: check_student_task_old_rows(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_student_task_old_rows() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    delete from student_task where completion_date < localtimestamp - '1 year'::interval;
end;
$$;


ALTER FUNCTION public.check_student_task_old_rows() OWNER TO postgres;

--
-- Name: check_study_group_task_old_rows(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_study_group_task_old_rows() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    delete from study_group_task where deadline_date < localtimestamp - '1 year'::interval;
end;
$$;


ALTER FUNCTION public.check_study_group_task_old_rows() OWNER TO postgres;

--
-- Name: check_user_role_after(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_user_role_after() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if new.role::text = 'student' then
        insert into student(id) values (new.id);
    end if;
    return old;
end;
$$;


ALTER FUNCTION public.check_user_role_after() OWNER TO postgres;

--
-- Name: create_user_in_role(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_user_in_role(db_user text, hashed_password text, current_user_role text) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
    query text := 'create user ';
begin
    if db_user is not null and hashed_password is not null  and current_user_role  is not null then
        query := query || db_user || ' inherit login password ' || quote_nullable(hashed_password) || ' in role ' || current_user_role;
    end if;
    execute query ;
end
$$;


ALTER FUNCTION public.create_user_in_role(db_user text, hashed_password text, current_user_role text) OWNER TO postgres;

--
-- Name: truncate_tables(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.truncate_tables(username character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
    statements cursor for
        select tablename from pg_tables
        where tableowner = username and schemaname = 'public';
begin
    for stmt in statements loop
        execute 'truncate table ' || quote_ident(stmt.tablename) || ' cascade;';
    end loop;
end;
$$;


ALTER FUNCTION public.truncate_tables(username character varying) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: campus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.campus (
    id character varying(255) NOT NULL,
    address text
);


ALTER TABLE public.campus OWNER TO postgres;

--
-- Name: discipline; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.discipline (
    id bigint NOT NULL,
    title text NOT NULL
);


ALTER TABLE public.discipline OWNER TO postgres;

--
-- Name: discipline_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.discipline_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.discipline_id_seq OWNER TO postgres;

--
-- Name: discipline_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.discipline_id_seq OWNED BY public.discipline.id;


--
-- Name: student; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student (
    id bigint NOT NULL,
    role public.student_role,
    study_group_cipher_id character varying(30)
);


ALTER TABLE public.student OWNER TO postgres;

--
-- Name: student_task; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_task (
    id bigint NOT NULL,
    student_id bigint NOT NULL,
    status public.task_status DEFAULT 'pending'::public.task_status NOT NULL,
    priority public.task_priority NOT NULL,
    points smallint,
    comment text,
    grade public.student_task_grade,
    deadline_date timestamp with time zone,
    completion_date timestamp with time zone,
    CONSTRAINT student_task_check CHECK ((completion_date <= deadline_date))
);


ALTER TABLE public.student_task OWNER TO postgres;

--
-- Name: student_task_store; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_task_store (
    id bigint NOT NULL,
    task_id bigint NOT NULL,
    student_id bigint NOT NULL,
    url text NOT NULL,
    size bigint NOT NULL,
    filename text,
    create_date timestamp with time zone DEFAULT LOCALTIMESTAMP,
    CONSTRAINT student_task_store_size_check CHECK ((size <= 160000000))
);


ALTER TABLE public.student_task_store OWNER TO postgres;

--
-- Name: student_task_store_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_task_store_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.student_task_store_id_seq OWNER TO postgres;

--
-- Name: study_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.study_group (
    id character varying(30) NOT NULL,
    discipline_id bigint NOT NULL
);


ALTER TABLE public.study_group OWNER TO postgres;

--
-- Name: study_group_cipher; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.study_group_cipher (
    id character varying(30) NOT NULL
);


ALTER TABLE public.study_group_cipher OWNER TO postgres;

--
-- Name: study_group_task; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.study_group_task (
    id bigint NOT NULL,
    study_group_cipher_id character varying(30) NOT NULL,
    status public.task_status DEFAULT 'accepted'::public.task_status NOT NULL,
    deadline_date timestamp with time zone
);


ALTER TABLE public.study_group_task OWNER TO postgres;

--
-- Name: task; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task (
    id bigint NOT NULL,
    teacher_user_id bigint NOT NULL,
    teacher_role public.teacher_role NOT NULL,
    teacher_discipline_id bigint NOT NULL,
    title text NOT NULL,
    description text,
    create_date timestamp with time zone DEFAULT LOCALTIMESTAMP
);


ALTER TABLE public.task OWNER TO postgres;

--
-- Name: task_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.task_id_seq OWNER TO postgres;

--
-- Name: teacher; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teacher (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    role public.teacher_role NOT NULL,
    discipline_id bigint NOT NULL,
    room_number character varying(10),
    campus_id character varying(255)
);


ALTER TABLE public.teacher OWNER TO postgres;

--
-- Name: teacher_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.teacher_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.teacher_id_seq OWNER TO postgres;

--
-- Name: teacher_lecturer_discipline_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.teacher_lecturer_discipline_view AS
 SELECT teacher.user_id,
    array_agg(teacher.discipline_id) AS discipline_id
   FROM public.teacher
  WHERE (teacher.role = 'lecturer'::public.teacher_role)
  GROUP BY teacher.user_id;


ALTER TABLE public.teacher_lecturer_discipline_view OWNER TO postgres;

--
-- Name: teacher_practicioner_discipline_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.teacher_practicioner_discipline_view AS
 SELECT teacher.user_id,
    array_agg(teacher.discipline_id) AS discipline_id
   FROM public.teacher
  WHERE (teacher.role = 'practicioner'::public.teacher_role)
  GROUP BY teacher.user_id;


ALTER TABLE public.teacher_practicioner_discipline_view OWNER TO postgres;

--
-- Name: user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."user" (
    id bigint NOT NULL,
    email text NOT NULL,
    hashed_password text,
    role public.user_role DEFAULT 'anon'::public.user_role NOT NULL,
    full_name text,
    username text NOT NULL,
    age smallint,
    phone character varying(20),
    avatar text,
    is_active boolean DEFAULT true NOT NULL,
    is_superuser boolean DEFAULT false NOT NULL,
    create_date timestamp with time zone DEFAULT LOCALTIMESTAMP,
    CONSTRAINT user_check CHECK ((full_name <> (role)::text)),
    CONSTRAINT user_check1 CHECK ((username <> (role)::text))
);


ALTER TABLE public."user" OWNER TO postgres;

--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_id_seq OWNER TO postgres;

--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;


--
-- Name: discipline id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline ALTER COLUMN id SET DEFAULT nextval('public.discipline_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- Data for Name: campus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.campus (id, address) FROM stdin;
IZ-5	6584 Jessica Ramp\nHansenhaven, SD 91531
VZ-9	75759 Wells Gateway Suite 710\nWest Tylerchester, CA 08077
BT-9	799 Howard Tunnel Apt. 073\nBrandtfort, ME 27876
CI-2	Unit 0349 Box 7327\nDPO AA 82354
GQ-8	USNS Keller\nFPO AP 23238
OR-4	3685 Jonathan Hollow\nAndrewfurt, OR 97813
NW-2	2187 Brandon Square\nSouth Amy, CO 82562
PS-3	7596 Tiffany Loaf\nHessshire, FM 30876
FP-1	849 Eric Square\nPamelamouth, NC 10926
OI-3	520 Wood Crest Suite 850\nWilliamstown, VT 58536
\.


--
-- Data for Name: discipline; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discipline (id, title) FROM stdin;
1	Software Modeling
2	C++
3	Python
4	C#
5	Java
6	Kotlin
\.


--
-- Data for Name: student; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student (id, role, study_group_cipher_id) FROM stdin;
251	leader	ABCD-07-22
253	leader	ABCD-12-22
254	student	ABCD-04-22
256	leader	ABCD-15-22
258	leader	ABCD-04-22
259	leader	ABCD-04-22
261	leader	ABCD-16-22
262	leader	ABCD-10-22
264	student	ABCD-14-22
266	leader	ABCD-20-22
267	student	ABCD-16-22
269	student	ABCD-06-22
271	student	ABCD-10-22
272	student	ABCD-16-22
274	student	ABCD-12-22
275	student	ABCD-10-22
277	student	ABCD-10-22
279	student	ABCD-03-22
280	student	ABCD-11-22
282	student	ABCD-20-22
284	student	ABCD-18-22
285	student	ABCD-04-22
287	leader	ABCD-11-22
288	student	ABCD-18-22
290	leader	ABCD-04-22
292	leader	ABCD-08-22
293	leader	ABCD-13-22
295	student	ABCD-15-22
297	student	ABCD-04-22
298	student	ABCD-10-22
300	leader	ABCD-01-22
301	student	ABCD-09-22
303	student	ABCD-18-22
305	leader	ABCD-15-22
306	student	ABCD-14-22
308	student	ABCD-19-22
310	leader	ABCD-11-22
311	leader	ABCD-07-22
313	leader	ABCD-04-22
314	student	ABCD-18-22
316	leader	ABCD-01-22
318	leader	ABCD-11-22
319	student	ABCD-20-22
321	student	ABCD-17-22
323	leader	ABCD-17-22
324	student	ABCD-18-22
326	student	ABCD-14-22
327	student	ABCD-04-22
329	student	ABCD-14-22
331	leader	ABCD-12-22
332	student	ABCD-13-22
334	leader	ABCD-09-22
336	student	ABCD-09-22
337	student	ABCD-06-22
339	student	ABCD-04-22
340	leader	ABCD-11-22
342	leader	ABCD-10-22
344	student	ABCD-07-22
345	leader	ABCD-01-22
347	leader	ABCD-07-22
349	student	ABCD-07-22
350	student	ABCD-15-22
352	leader	ABCD-13-22
353	leader	ABCD-01-22
355	leader	ABCD-11-22
250	leader	ABCD-08-22
252	leader	ABCD-08-22
255	student	ABCD-19-22
257	leader	ABCD-10-22
260	leader	ABCD-19-22
263	student	ABCD-11-22
265	student	ABCD-14-22
268	student	ABCD-04-22
270	student	ABCD-02-22
273	leader	ABCD-17-22
276	leader	ABCD-02-22
278	student	ABCD-09-22
281	leader	ABCD-14-22
283	leader	ABCD-05-22
286	student	ABCD-06-22
289	leader	ABCD-04-22
291	student	ABCD-04-22
294	leader	ABCD-04-22
296	leader	ABCD-13-22
299	leader	ABCD-10-22
302	leader	ABCD-12-22
304	leader	ABCD-13-22
307	student	ABCD-11-22
309	student	ABCD-13-22
312	leader	ABCD-18-22
315	student	ABCD-02-22
317	leader	ABCD-07-22
320	student	ABCD-06-22
322	student	ABCD-08-22
325	leader	ABCD-12-22
328	student	ABCD-03-22
330	leader	ABCD-07-22
333	leader	ABCD-20-22
335	student	ABCD-14-22
338	student	ABCD-04-22
341	leader	ABCD-03-22
343	student	ABCD-06-22
346	student	ABCD-14-22
348	leader	ABCD-03-22
351	student	ABCD-08-22
354	student	ABCD-14-22
356	leader	ABCD-20-22
357	student	ABCD-14-22
358	student	ABCD-04-22
359	leader	ABCD-03-22
360	student	ABCD-01-22
361	leader	ABCD-15-22
362	student	ABCD-15-22
363	leader	ABCD-20-22
364	leader	ABCD-03-22
365	leader	ABCD-03-22
366	student	ABCD-16-22
367	student	ABCD-10-22
368	student	ABCD-16-22
369	student	ABCD-11-22
370	leader	ABCD-09-22
371	leader	ABCD-09-22
372	student	ABCD-02-22
373	leader	ABCD-08-22
374	student	ABCD-08-22
375	leader	ABCD-05-22
376	student	ABCD-11-22
377	leader	ABCD-15-22
378	student	ABCD-17-22
379	leader	ABCD-20-22
380	leader	ABCD-10-22
381	student	ABCD-03-22
382	student	ABCD-15-22
383	student	ABCD-12-22
384	leader	ABCD-08-22
385	student	ABCD-04-22
386	student	ABCD-11-22
387	leader	ABCD-17-22
388	leader	ABCD-20-22
389	leader	ABCD-20-22
390	student	ABCD-14-22
391	student	ABCD-08-22
392	leader	ABCD-17-22
393	leader	ABCD-19-22
394	student	ABCD-09-22
395	leader	ABCD-12-22
396	student	ABCD-10-22
397	leader	ABCD-05-22
398	student	ABCD-04-22
399	student	ABCD-02-22
400	leader	ABCD-04-22
401	leader	ABCD-12-22
402	student	ABCD-03-22
403	student	ABCD-02-22
404	student	ABCD-15-22
405	student	ABCD-10-22
406	leader	ABCD-03-22
407	student	ABCD-05-22
408	leader	ABCD-01-22
409	student	ABCD-15-22
410	student	ABCD-13-22
411	leader	ABCD-16-22
412	student	ABCD-15-22
413	student	ABCD-18-22
414	leader	ABCD-09-22
415	leader	ABCD-15-22
416	student	ABCD-01-22
417	leader	ABCD-17-22
418	student	ABCD-19-22
419	leader	ABCD-08-22
420	student	ABCD-18-22
421	leader	ABCD-08-22
422	student	ABCD-12-22
423	student	ABCD-17-22
424	student	ABCD-05-22
425	leader	ABCD-06-22
426	leader	ABCD-13-22
427	leader	ABCD-20-22
428	leader	ABCD-10-22
429	student	ABCD-07-22
430	leader	ABCD-02-22
431	student	ABCD-06-22
432	student	ABCD-06-22
433	student	ABCD-15-22
434	leader	ABCD-11-22
435	student	ABCD-13-22
436	leader	ABCD-01-22
437	student	ABCD-01-22
438	leader	ABCD-12-22
439	leader	ABCD-01-22
440	leader	ABCD-20-22
441	leader	ABCD-12-22
442	leader	ABCD-08-22
443	leader	ABCD-07-22
444	leader	ABCD-18-22
445	student	ABCD-07-22
446	leader	ABCD-10-22
447	leader	ABCD-06-22
448	student	ABCD-15-22
449	student	ABCD-16-22
450	student	ABCD-04-22
451	leader	ABCD-02-22
452	student	ABCD-19-22
453	student	ABCD-16-22
478	leader	ABCD-11-22
480	student	ABCD-14-22
481	leader	ABCD-03-22
483	leader	ABCD-02-22
484	student	ABCD-11-22
486	leader	ABCD-05-22
488	student	ABCD-17-22
489	leader	ABCD-04-22
491	student	ABCD-11-22
493	leader	ABCD-10-22
494	leader	ABCD-03-22
496	leader	ABCD-14-22
497	leader	ABCD-13-22
499	student	ABCD-12-22
501	leader	ABCD-07-22
454	student	ABCD-10-22
455	student	ABCD-01-22
456	leader	ABCD-06-22
457	leader	ABCD-03-22
458	student	ABCD-14-22
459	leader	ABCD-01-22
460	leader	ABCD-12-22
461	student	ABCD-17-22
462	leader	ABCD-04-22
463	leader	ABCD-19-22
464	leader	ABCD-19-22
465	leader	ABCD-11-22
466	student	ABCD-15-22
467	leader	ABCD-14-22
468	student	ABCD-09-22
469	student	ABCD-11-22
470	leader	ABCD-01-22
471	student	ABCD-11-22
472	student	ABCD-05-22
473	student	ABCD-05-22
474	leader	ABCD-17-22
475	leader	ABCD-05-22
476	student	ABCD-18-22
477	student	ABCD-08-22
479	leader	ABCD-07-22
482	leader	ABCD-06-22
485	leader	ABCD-02-22
487	leader	ABCD-13-22
490	student	ABCD-09-22
492	student	ABCD-04-22
495	student	ABCD-12-22
498	student	ABCD-18-22
500	student	ABCD-11-22
\.


--
-- Data for Name: student_task; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_task (id, student_id, status, priority, points, comment, grade, deadline_date, completion_date) FROM stdin;
1	459	started	low	\N	\N	good	2022-12-30 16:25:37.962221+03	\N
2	359	started	low	\N	\N	good	2022-12-28 16:25:38.743427+03	\N
3	379	started	high	\N	\N	passed	2022-12-26 16:25:38.754999+03	\N
4	357	started	low	\N	\N	bad	2022-12-27 16:25:38.764999+03	\N
5	297	started	high	\N	\N	great	2022-12-27 16:25:38.775997+03	\N
6	374	started	low	\N	\N	bad	2022-12-28 16:25:38.785997+03	\N
7	262	started	low	\N	\N	good	2022-12-30 16:25:38.796998+03	\N
8	270	started	low	\N	\N	bad	2022-12-26 16:25:38.805998+03	\N
9	458	started	low	\N	\N	not_passed	2022-12-27 16:25:38.815997+03	\N
10	466	started	high	\N	\N	normal	2022-12-26 16:25:38.825997+03	\N
11	252	started	medium	\N	\N	not_passed	2022-12-26 16:25:38.835999+03	\N
12	283	started	medium	\N	\N	good	2022-12-29 16:25:38.8467+03	\N
13	404	started	low	\N	\N	passed	2022-12-28 16:25:38.856231+03	\N
14	397	started	high	\N	\N	great	2022-12-28 16:25:38.86623+03	\N
15	484	started	high	\N	\N	not_passed	2022-12-29 16:25:38.876231+03	\N
16	300	started	high	\N	\N	good	2022-12-27 16:25:38.885414+03	\N
17	415	started	low	\N	\N	normal	2022-12-26 16:25:38.895414+03	\N
18	414	started	low	\N	\N	great	2022-12-28 16:25:38.905414+03	\N
19	458	started	low	\N	\N	passed	2022-12-26 16:25:38.917414+03	\N
20	413	started	medium	\N	\N	great	2022-12-27 16:25:38.927414+03	\N
21	398	started	high	\N	\N	normal	2022-12-29 16:25:38.938415+03	\N
22	457	started	high	\N	\N	bad	2022-12-27 16:25:38.949422+03	\N
23	400	started	medium	\N	\N	great	2022-12-27 16:25:38.959807+03	\N
24	267	started	high	\N	\N	normal	2022-12-27 16:25:38.969807+03	\N
25	350	started	low	\N	\N	normal	2022-12-27 16:25:38.979805+03	\N
26	250	started	medium	\N	\N	bad	2022-12-28 16:25:38.989806+03	\N
27	458	started	medium	\N	\N	good	2022-12-26 16:25:38.999806+03	\N
28	479	started	medium	\N	\N	good	2022-12-29 16:25:39.010806+03	\N
29	393	started	medium	\N	\N	bad	2022-12-27 16:25:39.020806+03	\N
30	457	started	low	\N	\N	not_passed	2022-12-28 16:25:39.03084+03	\N
31	459	started	medium	\N	\N	not_passed	2022-12-27 16:25:39.040861+03	\N
32	407	started	low	\N	\N	bad	2022-12-30 16:25:39.05086+03	\N
33	352	started	high	\N	\N	great	2022-12-26 16:25:39.060873+03	\N
34	254	started	medium	\N	\N	passed	2022-12-27 16:25:39.070873+03	\N
35	357	started	low	\N	\N	normal	2022-12-30 16:25:39.080873+03	\N
36	295	started	medium	\N	\N	good	2022-12-29 16:25:39.090886+03	\N
37	274	started	low	\N	\N	good	2022-12-28 16:25:39.100978+03	\N
38	497	started	low	\N	\N	bad	2022-12-30 16:25:39.110977+03	\N
39	300	started	high	\N	\N	great	2022-12-28 16:25:39.120977+03	\N
40	484	started	low	\N	\N	normal	2022-12-29 16:25:39.130978+03	\N
41	460	started	low	\N	\N	bad	2022-12-28 16:25:39.140982+03	\N
42	270	started	high	\N	\N	good	2022-12-30 16:25:39.150981+03	\N
43	497	started	medium	\N	\N	good	2022-12-27 16:25:39.161506+03	\N
44	260	started	low	\N	\N	bad	2022-12-27 16:25:39.171492+03	\N
45	322	started	medium	\N	\N	not_passed	2022-12-29 16:25:39.183492+03	\N
46	398	started	low	\N	\N	not_passed	2022-12-26 16:25:39.195506+03	\N
47	456	started	low	\N	\N	normal	2022-12-29 16:25:39.206504+03	\N
48	296	started	high	\N	\N	good	2022-12-26 16:25:39.216504+03	\N
49	398	started	medium	\N	\N	not_passed	2022-12-27 16:25:39.227505+03	\N
50	370	started	low	\N	\N	good	2022-12-26 16:25:39.237516+03	\N
51	462	started	low	\N	\N	bad	2022-12-30 16:25:39.248538+03	\N
52	398	started	high	\N	\N	normal	2022-12-30 16:25:39.25986+03	\N
53	481	started	low	\N	\N	bad	2022-12-30 16:25:39.27111+03	\N
54	297	started	high	\N	\N	great	2022-12-26 16:25:39.281112+03	\N
55	407	started	low	\N	\N	great	2022-12-30 16:25:39.291123+03	\N
56	440	started	high	\N	\N	passed	2022-12-28 16:25:39.301123+03	\N
57	291	started	low	\N	\N	normal	2022-12-30 16:25:39.311124+03	\N
58	413	started	medium	\N	\N	good	2022-12-29 16:25:39.322123+03	\N
59	481	started	low	\N	\N	bad	2022-12-30 16:25:39.332124+03	\N
60	260	started	medium	\N	\N	not_passed	2022-12-28 16:25:39.342128+03	\N
61	260	started	medium	\N	\N	normal	2022-12-26 16:25:39.352135+03	\N
62	497	started	low	\N	\N	bad	2022-12-26 16:25:39.362666+03	\N
63	360	started	low	\N	\N	passed	2022-12-28 16:25:39.373666+03	\N
64	442	started	medium	\N	\N	normal	2022-12-28 16:25:39.383668+03	\N
65	403	started	medium	\N	\N	not_passed	2022-12-26 16:25:39.393666+03	\N
66	323	started	high	\N	\N	normal	2022-12-26 16:25:39.403666+03	\N
67	250	started	high	\N	\N	normal	2022-12-30 16:25:39.413666+03	\N
68	318	started	high	\N	\N	normal	2022-12-27 16:25:39.423666+03	\N
69	359	started	medium	\N	\N	bad	2022-12-26 16:25:39.434666+03	\N
70	478	started	high	\N	\N	normal	2022-12-27 16:25:39.445672+03	\N
71	367	started	low	\N	\N	good	2022-12-28 16:25:39.456761+03	\N
72	308	started	medium	\N	\N	great	2022-12-28 16:25:39.466761+03	\N
73	441	started	high	\N	\N	good	2022-12-29 16:25:39.47676+03	\N
74	466	started	low	\N	\N	not_passed	2022-12-28 16:25:39.48676+03	\N
75	470	started	low	\N	\N	not_passed	2022-12-26 16:25:39.497827+03	\N
76	372	started	high	\N	\N	bad	2022-12-27 16:25:39.507828+03	\N
77	286	started	high	\N	\N	great	2022-12-28 16:25:39.517827+03	\N
78	496	started	medium	\N	\N	normal	2022-12-29 16:25:39.528828+03	\N
79	320	started	low	\N	\N	normal	2022-12-29 16:25:39.538827+03	\N
80	282	started	medium	\N	\N	normal	2022-12-30 16:25:39.549832+03	\N
81	413	started	high	\N	\N	great	2022-12-29 16:25:39.560205+03	\N
82	472	started	high	\N	\N	passed	2022-12-28 16:25:39.570204+03	\N
83	257	started	high	\N	\N	normal	2022-12-30 16:25:39.581206+03	\N
84	499	started	low	\N	\N	passed	2022-12-27 16:25:39.591205+03	\N
85	382	started	low	\N	\N	good	2022-12-26 16:25:39.601205+03	\N
86	491	started	low	\N	\N	passed	2022-12-30 16:25:39.610648+03	\N
87	302	started	high	\N	\N	bad	2022-12-30 16:25:39.62065+03	\N
88	481	started	high	\N	\N	great	2022-12-26 16:25:39.630648+03	\N
89	444	started	medium	\N	\N	good	2022-12-27 16:25:39.640667+03	\N
90	338	started	low	\N	\N	bad	2022-12-29 16:25:39.649667+03	\N
91	332	started	low	\N	\N	good	2022-12-27 16:25:39.659821+03	\N
92	327	started	low	\N	\N	passed	2022-12-30 16:25:39.669821+03	\N
93	464	started	high	\N	\N	passed	2022-12-30 16:25:39.679837+03	\N
94	372	started	low	\N	\N	great	2022-12-28 16:25:39.69085+03	\N
95	452	started	high	\N	\N	passed	2022-12-27 16:25:39.702847+03	\N
96	432	started	high	\N	\N	passed	2022-12-29 16:25:39.714838+03	\N
97	317	started	low	\N	\N	not_passed	2022-12-29 16:25:39.726838+03	\N
98	307	started	high	\N	\N	good	2022-12-29 16:25:39.738837+03	\N
99	351	started	medium	\N	\N	good	2022-12-29 16:25:39.749841+03	\N
100	463	started	medium	\N	\N	great	2022-12-27 16:25:39.760352+03	\N
101	307	started	high	\N	\N	good	2022-12-27 16:25:39.771351+03	\N
102	335	started	high	\N	\N	passed	2022-12-29 16:25:39.781352+03	\N
103	273	started	low	\N	\N	not_passed	2022-12-26 16:25:39.791352+03	\N
104	253	started	high	\N	\N	good	2022-12-27 16:25:39.801367+03	\N
105	278	started	low	\N	\N	bad	2022-12-29 16:25:39.811368+03	\N
106	254	started	high	\N	\N	good	2022-12-30 16:25:39.821367+03	\N
107	342	started	low	\N	\N	great	2022-12-28 16:25:39.831366+03	\N
108	352	started	medium	\N	\N	passed	2022-12-28 16:25:39.841374+03	\N
109	425	started	medium	\N	\N	great	2022-12-26 16:25:39.850425+03	\N
110	401	started	medium	\N	\N	bad	2022-12-26 16:25:39.860949+03	\N
111	476	started	medium	\N	\N	great	2022-12-28 16:25:39.870949+03	\N
112	450	started	high	\N	\N	great	2022-12-26 16:25:39.880949+03	\N
113	327	started	high	\N	\N	passed	2022-12-26 16:25:39.890949+03	\N
114	476	started	medium	\N	\N	passed	2022-12-29 16:25:39.900948+03	\N
115	445	started	medium	\N	\N	great	2022-12-30 16:25:39.910951+03	\N
116	490	started	low	\N	\N	not_passed	2022-12-26 16:25:39.919949+03	\N
117	355	started	low	\N	\N	bad	2022-12-28 16:25:39.930949+03	\N
118	380	started	medium	\N	\N	great	2022-12-26 16:25:39.940953+03	\N
119	446	started	high	\N	\N	great	2022-12-29 16:25:39.950953+03	\N
120	269	started	low	\N	\N	passed	2022-12-27 16:25:39.961449+03	\N
121	485	started	low	\N	\N	good	2022-12-29 16:25:39.97146+03	\N
122	397	started	high	\N	\N	bad	2022-12-30 16:25:39.981473+03	\N
123	459	started	medium	\N	\N	passed	2022-12-29 16:25:39.991527+03	\N
124	441	started	medium	\N	\N	good	2022-12-27 16:25:40.001527+03	\N
\.


--
-- Data for Name: student_task_store; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_task_store (id, task_id, student_id, url, size, filename, create_date) FROM stdin;
1	1	387	https://cloud.com/YpxpVCMrdzINeFKNpmkBrbdGVkRXAUmNpkvVxzZEPitKzdrBWbrGAUbmkHTIRKIzsKlWlMDjAfdWCUNwBENHVgSIWGLcaCrsIQDJ	38815222	\N	2022-12-25 16:25:38.733388+03
2	2	322	https://cloud.com/xoeSHEQxbpCKCFxqnvVJWAwpzGCqpFPEubdswoMuWpPjpvtdnzkxVcMDELcHPjGKoALXhHEhXvdgiHLzPCFaVGoQKezSsrbkriaE	60437117	\N	2022-12-25 16:25:38.748525+03
3	3	371	https://cloud.com/RwcBdjdJnQFVWRZZYtPGcIfTjrwAKXfykztoxmZVegeHZihZhKHFcRmUFlTCJXkrqcNlEyxpFYAncYTKEaoyEfALNVJYYkkKFKet	84830720	\N	2022-12-25 16:25:38.759311+03
4	4	369	https://cloud.com/nPXMrlXbcKeopDrqEPFXPigUizjIWoOCNzsDdgUiVYtDzVEBraWfYmqeTjZHvHwNdaSTkgRvAmjALlPGJEyeQrFcFRYogKKQliXQ	98658676	\N	2022-12-25 16:25:38.769552+03
5	5	278	https://cloud.com/cPtYmgaPjxtQUezUHjmyVZyOYGKjWxTQWmYbWfpXoLsuFwAiYyNvWEQdcTJiXlAtAtmiYJRhEMyGudPcRrEVFNuDdMgiRSzEgqkK	68223512	\N	2022-12-25 16:25:38.780093+03
6	6	459	https://cloud.com/wxqffziBtGkLfeGreXVFjCKQFKmIiolOtKtsppJPwXzwkwKjYVfeFSHPFPxpHvjFYNlZSWqxRKUbvGQnrmiCcVCsXCbMKQAINRaq	98547139	\N	2022-12-25 16:25:38.79061+03
7	7	292	https://cloud.com/MYFXMWRcmIadEwEaNnXVwKhsMwWiiODjIHYimVYnctmAbAerqjoaCwyhPenaAdrkyORotKpAnLzFRRjCcZnawDwukvblJRacWfAW	21628290	\N	2022-12-25 16:25:38.80091+03
8	8	455	https://cloud.com/bTisZZwfORGfOhwwPHRrIcwQJaxRLGpUzFXqKuHgGgBAZVHzDlwjEcHLgEXykZanwxgesegruxtMCHjZQhRTSKJSpHeekNCmgAZd	42987810	\N	2022-12-25 16:25:38.810723+03
9	9	394	https://cloud.com/nQWhrLCEAxmDgfpncxVgJGlchCZtybQmEXIGTdvpxNCpnBlGzSronTkcjnICtfNKCrEppKrHQkjFjgdlAvkRyhmUZDnGpSQVCzes	60694710	\N	2022-12-25 16:25:38.82056+03
10	10	360	https://cloud.com/rdLTDyWIijxPwIQFKOeHrqFzAKyEJWbnCPbnRCUkNVlIdSZeazevGWIQSCKAfnxERJPpoIdppWkdgiSSZsQWPiLfJhXnUQzaLhAx	58168169	\N	2022-12-25 16:25:38.830752+03
11	11	385	https://cloud.com/esdJumNYslfEMGuvZYQljELoSJYiWsFdWqJndrRBsUPkRxEMbfyYNhlTQKbZElkGWVzlAanJVtVzUqHOpzFITCDcSwRoMTVSisIL	50660716	\N	2022-12-25 16:25:38.840706+03
12	12	406	https://cloud.com/wLgJfADAowlaQCTLHlkvbPTgZWzCDZBJgWiFmRQfWUmAazHCsyBsDQpfulTjqqZgHYwEXqBXwrMLffVCeecQdHKMMmJvlpPyhPMW	29266785	\N	2022-12-25 16:25:38.850773+03
13	13	296	https://cloud.com/bVXLynZgdkdteJwVtMFkxyhPooHvvwQwtfGOXiHNaxTKaTYROfxIRpMauduQNMKXEdolXDtXkaEyuWSxBJRqKxQtwRQnGlsBTCPQ	87947846	\N	2022-12-25 16:25:38.860518+03
14	14	373	https://cloud.com/QdWNOGMxgYQrKgzRERpaGpCEwQiIfTyrbaJzRSPAlqEtbVpdqMzqxCrgWxCFZbyByuQFcANuxBMVquqxnyClsAXvjKpNbzDKNxmJ	22434636	\N	2022-12-25 16:25:38.870302+03
15	15	437	https://cloud.com/OqOQdZBbtHJBVaLlHbtxclEhtQtnlYnBPlkTnoXvHWPyjyEDRzINfAXeEpmVBwgelpqwrgTjIYRHDluExoqZfmRWeNTchpukRWkE	75768490	\N	2022-12-25 16:25:38.880503+03
16	16	437	https://cloud.com/qXZtlJTppnzCgNbtVEjIGgXhKsMGOFSFCZLTyWhyzudwmNDBcooVEhpqkyQChchYsYnAxZunwSPkgTxDpSNRoDDpoBPpXitsQfMQ	88622497	\N	2022-12-25 16:25:38.890304+03
17	17	250	https://cloud.com/ieZJtMczLEWjZdrwVSOesIPipsguIOPpZWZmRHhKBpnxswQPuSrDahjXuXfjkJEfASXARkhcpePhCJVQkGNUvlyWLfZYHlgCTEzu	57865196	\N	2022-12-25 16:25:38.900207+03
18	18	278	https://cloud.com/pqSXKxtwRVFaRJkUZcYyCBelVCyUXLWuGpclRwTcwYBMhsbESlwcoVdjZswiyQBSTjiRRsWXzkUoVTfniIAGkLlPLhcsWLNUIvjz	57595560	\N	2022-12-25 16:25:38.91052+03
19	19	269	https://cloud.com/KcCGblTZzYrBeIBcKQsoNcBFoGRTCvRznyNIRIkEviHURKqpHAnbkQiWryTMWwiSATHBvixUQwinLMRwxsbWzKqMGeCMEKJYaJTj	13368308	\N	2022-12-25 16:25:38.921365+03
20	20	478	https://cloud.com/ZXZSmDaFcPgIsstrYwQNUVoHxyedAmYPeAfqlDTToBgxxaWqgPDkvEGqjnQhijjaJHkSWvuDPhGOBXeIzPSKyZiSZLmtjNGavXkD	77322681	\N	2022-12-25 16:25:38.932085+03
21	21	498	https://cloud.com/CsuJBLhuirzYyWCXPxubuSCTUvZPnynTzQtJAsoGOLuxXGhnXXpTTzQvECxWTHYkwGzSVUbHqDVXgtlhSfycaQoRvJBjEUWUYgZi	5020766	\N	2022-12-25 16:25:38.943352+03
22	22	300	https://cloud.com/OjbEIUBDzzwftHElCWSHlmqCWvHHIOjfQUHMhVszBeDmXcrDWmzAHjdtKYecMFPgLEXwkRumxHFofUobuPyfNmlGeEWMtvrzWcly	31454819	\N	2022-12-25 16:25:38.953754+03
23	23	477	https://cloud.com/JACHFMgxHxkcTiwGbmuAoBWJDDabEIZsuehifbqWajmKSDTWcZFTgCnliminbbRaqwMIfCShQOlFWvLRCpfrKRHwGCRluwVvuqzk	73777356	\N	2022-12-25 16:25:38.964329+03
24	24	412	https://cloud.com/ESHDyByaWNteGALcYmCxxjkEtIaLpeyWguAgTqgqVaVOswZuRUpVBNKLndwjWqheIVLJIwgjEkLNJIraKdoalDOUPUcIaBKTZdZJ	35222032	\N	2022-12-25 16:25:38.974454+03
25	25	367	https://cloud.com/iWJvanprLJbIihBuFzXpwxWuzFoPKdwPzMHVCvZzjvGlqfcUjePECiJRFDJGHvssQcesjZCnXgrFNeXVhaxsRwSVvFyzxxyLIYiG	5840260	\N	2022-12-25 16:25:38.984345+03
26	26	393	https://cloud.com/iXpkKaJbridNaVapgCRKIEYpjUNwzADuSUeemvceWTQxvcOPIMlXNVTmbZDSJGAuzJCZZfrHXyfMfMlpDdaHwfBwfMXiiEhHpzqw	84081285	\N	2022-12-25 16:25:38.994357+03
27	27	328	https://cloud.com/dieGhPAKEYhVvMdqSXEDaeilHhFQNErrluPWaCGwUhHNuGnOXjewumTtJwsUSntUvzwFtndSYenSAXaeBUSPrFQEqbHWSYZqHBHl	82674061	\N	2022-12-25 16:25:39.004532+03
28	28	382	https://cloud.com/VrANCJjxtgIDYkKLJwdSfgdgxsoiCRwyhgNNZnSeRKjXOyJazlfQRvEVMyhWsyfCViDKbcyVJttMnKuaVDjpJIHZoMiJsjhHGYdQ	62035379	\N	2022-12-25 16:25:39.014772+03
29	29	286	https://cloud.com/hCMtGTEOBnoKtnTIeluWVhiHsLJTgvXVTdwhixymdRfQJbqdByGyBAnMGjsTOxVLmpNnLqnbJkDWIusWDldnMWJGTSuqsREIvoox	37636113	\N	2022-12-25 16:25:39.024997+03
30	30	474	https://cloud.com/jDfjXlIaiPdwiEfcyJUiodZfQKjzrMpcppPjmRUDkHGHuGNoHvKmswzlqiNNPpALpePombbjJUsfstTEUXGgsUmjNkiONYOBEWHI	4575601	\N	2022-12-25 16:25:39.03467+03
31	31	494	https://cloud.com/ybtqQTpdjqSpyleobmcInvyPSnzqmEfhROkKFbXfEWdPltIamQVkISxjpiVhNmIhtQeggNUIjJfEbZwjnWaqLxlHjkKjUnPxOpJZ	92802063	\N	2022-12-25 16:25:39.045042+03
32	32	377	https://cloud.com/qVTcTvgHvVNEWqCyicDUFVDSbcRCvWNGflwUcKYNnLpyPIyYXAEmmEBZQScXEAWlajvuMzkmByfmLwweyJAEqPhNayeoJTpskkhz	92647980	\N	2022-12-25 16:25:39.055252+03
33	33	471	https://cloud.com/IZaIDyQDMHnpKVhxYBWXCYRrWgeTLTvwUTxUldwxPfWpMrvQoVzNYMLgNncOrJxrUwjgBpHZiKvytydhdjMVyIMPRBnSSpvJAbqN	52852654	\N	2022-12-25 16:25:39.065328+03
34	34	476	https://cloud.com/VzTrPAVBrHJtxrVmbDWfEbZQhqDxbAbtEqQplkUJLfanWMzFpjuUInpflxYTKWxFxEsLfWiyseRaSmeTEDWkrBQXcgiBXehwyjGf	69954388	\N	2022-12-25 16:25:39.075539+03
35	35	377	https://cloud.com/ADTlhXZGGmybZtMVoHxgPcdDJXiyDKehCTfwgGNeqeRSxieXrYGQxZaIMoJqDzmeAHYyfTOenpGPmCuPxWIltHcjObCTWIpZezta	64287281	\N	2022-12-25 16:25:39.085323+03
36	36	476	https://cloud.com/nDMcgNyGgquUqFSOVRAyeUHutAqZdOpmXmnWhxRxKByOtuhygSmJfYnvhSFMXDuOtQnHKbnAMEVsQkuujEZtSrYMqJapnwKCVBYc	42373791	\N	2022-12-25 16:25:39.095339+03
37	37	492	https://cloud.com/YLOuSUFuzKHqjNWNzIflTDOaSkoZoxwtkRkeYXNxFrpklGtgxtZDXHndqbAltGwooMjJDdKaOVxoNAtaQCYqaICukKkaZodGTKUy	52804546	\N	2022-12-25 16:25:39.105067+03
38	38	469	https://cloud.com/GUjsucvRutXwOiJAOyWaYhMHsWkTfoGOnDWLmPYhGyHsXoPymJFKMzBLZiMyuIcwTFtKWfBfALIkSjveWKQKLrEkRmeVcyboKYGi	24517336	\N	2022-12-25 16:25:39.114985+03
39	39	283	https://cloud.com/ZELXyoxeFxzcfDgGaPprprsxNJELpWVmTmkhNNyhiPAaHZCBPztLqYurixDLwHfOVkEacAGMcfPCkFHRCrwdhUNTddGDWrjnBQiU	96998336	\N	2022-12-25 16:25:39.125055+03
40	40	371	https://cloud.com/GaqZqhGIzXzQCRqOLFRfbDVkqYlyhmUhNRRyyFBkNwQWdfDveFisbKgrDsFkVAlCkWpMyCTourmArNJgCKuAobUqssPQLWZbDOfb	43954404	\N	2022-12-25 16:25:39.134931+03
41	41	390	https://cloud.com/IxtyggTKQYUkvLNdgBjMQeEBXSTCwPCBKjlkGrAgIMsALPzdeWHvdeLyLsogDVnThHaBPkIfXJqWuYQZzPzamRzWTvbThcfmGfoV	5535338	\N	2022-12-25 16:25:39.14491+03
42	42	250	https://cloud.com/dFxlyQTeTUwTTuGuXEVBFBwvneNGjitSzQayaBGsVskBGDohaVwwvYfFlxyCzpWCHksFvmLsyjvhvKpdPpDezLCMAnCQxcniRQhz	62999618	\N	2022-12-25 16:25:39.155262+03
43	43	280	https://cloud.com/GVRqSGGPkkUCSfXubbEFGuIIfQDwtXexfHACtfmJmMEEsBMAptJqtgZfwjXoeOUqNFrhJbcjapvWeaFjYwxDIISNdavdhhdzJyLX	56641302	\N	2022-12-25 16:25:39.165991+03
44	44	265	https://cloud.com/yFdpjtuYIGtoobBWPFbncrnZxXNMHhRcvwRPqMSsVTiOOxFksYXIRYtlxFQPfUtpqQiNKWbDfsJomTmOaxnegnTOZVWeTWnHcOYI	4274567	\N	2022-12-25 16:25:39.176509+03
45	45	324	https://cloud.com/UTyKFWVfIPAnqdLsOSDeAUkYxVycSBMVsmXPhSUvmwwQtRYUjfNEhMOcbhtbvJYiidifQUHnRgFwymIffBXDzLajQtVMlZQGduTl	29169506	\N	2022-12-25 16:25:39.18891+03
46	46	351	https://cloud.com/VeoCPPUjfkVhPngALcRKcXLMCGWOjkbtcuROxGsLSJWHYgJOaDBnPxNWlovvrquzZKztOpBbFWLnMmOQDADjXFwRurYfvYvOxYIz	5171359	\N	2022-12-25 16:25:39.200602+03
47	47	352	https://cloud.com/qTJyYDhxpWDHdmfjIBtpcctWhOTyXWMSHIrOOuvNbjSniRqeDgopTsTQlqgsVpxgsdpcCnZAFxNdTfOvyqihZQUtgjCmXtzAZUTN	14616627	\N	2022-12-25 16:25:39.210953+03
48	48	271	https://cloud.com/xGptuNZHRfbJpVEwTcceDpkhFaPvHzGXdBTLIdgiSxOdyabVKLjACVoeQJvGPrPzUiaCKjcudEFDFCTXtqMGBkvKvZpXUBtskueL	90022807	\N	2022-12-25 16:25:39.221238+03
49	49	383	https://cloud.com/yMyqCCeLsRlagQiFNwYEyCtNHFPnXMQgEHYpgWTQdtSHPDbwWDujBeQzFJoIgjKVizJuhREhuARWsOtxcnjdvaeawMYWLbbhDvMJ	61309621	\N	2022-12-25 16:25:39.231837+03
50	50	304	https://cloud.com/fwEBHqCHuREXqbpSBLRSfhVIxrPlWHWVlUMbMKeuzodjeXOPtnkHqzAihcienDtkxchkSGLJQVObQNKjFSvMQLBIcVqtlUHZXdTe	23985370	\N	2022-12-25 16:25:39.242749+03
51	51	411	https://cloud.com/aQsupsGXbwmEcngEWGPUIgTIhOTfhREAyWLCidZhbCeGgDoRrpClfqxucPFjYPFgLeSMDIEsOUWkKjlSKvNMdRpitOxupaAMYKtk	16793408	\N	2022-12-25 16:25:39.253541+03
52	52	388	https://cloud.com/PwIrstKZgNaLZwWCByVakcOSkzGEPbabskjNPBwwMhegqpyrfmYKQLrZgWmARjEiMjCdYPnvRGiXwWXbeiknjzbAtZUDufHVUBwh	26069443	\N	2022-12-25 16:25:39.264814+03
53	53	321	https://cloud.com/sNbRmpJApicAhaQAeHoHazRPTuoiIlbiIcWFzsFivLClevrFciKslJobIGpUenXMkqWDvyOIIeDMJAWeeSqLaQOYqILENDfJSfkR	39596910	\N	2022-12-25 16:25:39.275306+03
54	54	273	https://cloud.com/tTKsJItLwGMTHZrdSfLMRMTlUdSVgyAwgvQfGlFzQiKSceYNmuLXNbhgJPRqtpHSwuSyGlYdMGqFveJPXLiWOGfrhHHKZbospKTt	52098595	\N	2022-12-25 16:25:39.285341+03
55	55	457	https://cloud.com/KGsfDcddWRMKWMLyFrNehXfuQQfRrmxTxCRanNWFdBewCGyBmmiRMBprYZOiWrteDzaZRkqwOqvNyuukYTtilkEkomefaQOXmZZr	30036392	\N	2022-12-25 16:25:39.295245+03
56	56	305	https://cloud.com/geqJDHEefQlhYCwMllBsSBoFEZfFoPxNeQBXDhzbelMabnbUMMJvxCwVCXvjjVUGZDqXPsDYTMHRPkygYxaoHpAqJiwvttohUCmj	14091768	\N	2022-12-25 16:25:39.305322+03
57	57	436	https://cloud.com/ltuLKUmUdqRwvLuStLLkjmIlMevwOeZkuNbHrJVeGWsHTXxwXmlxLHFJiYxmfVhNfXobvTRTVgPXESbeTaqdMwbnmhfblYUWVscb	69871241	\N	2022-12-25 16:25:39.3157+03
58	58	428	https://cloud.com/GtpvyPBxbufNVeDOjNXLILhCKTONPYUXBeKGeSzPXtkyyDpWKmLdRuMIforOktUNczODZkkWwahensbIFYhwgLqtHyWoOeqcfJcm	53424616	\N	2022-12-25 16:25:39.326336+03
59	59	265	https://cloud.com/cbcNeLxmyRGMtVsiHnjOLldCyILvaUKVsBfmMAPcFFyWZGlBjIgkmPxVeqEBqHtZxpknZNbZQaaOIYgJpLuXMeJcbrzYAMidFuqB	44365414	\N	2022-12-25 16:25:39.33675+03
60	60	352	https://cloud.com/GBKOMdfpxUGUgHMvxXlUPRxJJMsbBQmGRpQonyXAlXYcJnktPIFQOoVskSZSOzzzprDxmAKyokMRxPFrbCAIQIqGDyGEwFhYBkkb	85106562	\N	2022-12-25 16:25:39.347064+03
61	61	272	https://cloud.com/PYCujLzMYRinvtyonQQjDJzskCINaiWeMKyWTwmvZhXPkLmWhhSuuNkPPOgWeEcAglmxLKtWbUJhYIFFTGbKtgEFvkwknsLTYSrt	42050129	\N	2022-12-25 16:25:39.357268+03
62	62	439	https://cloud.com/iTBehYUSXobQhPMWasukSAkklTWMtdPBezpdRbqIsCyeLHcRdjKhucpvHWHvlPLdfbNslxMHKGkUsNnVsbslPXDbWYKNDmZlhmsk	86106890	\N	2022-12-25 16:25:39.367633+03
63	63	406	https://cloud.com/ipGCzhDybDBQuqOJsaXfLbrXyNZqYfdEUSCeyUYTknpCuNKagTHUQhcpUwNmLBiacUjbrATfeFisaHzzVgZdVGvmjJlCEajKRjhi	59105330	\N	2022-12-25 16:25:39.377714+03
64	64	267	https://cloud.com/ItWivcoleyDtXgOrpxTpRCoPIZivNnPKOZHhHreDwSWWGlGDvZmEvlHuZFqGNlbcsJJVNsbzHeGVqvPljFenbjeSZZSiPtVVNhTk	95789855	\N	2022-12-25 16:25:39.387748+03
65	65	381	https://cloud.com/YwAOFrIAafnQkmULyZZoVIfwdUBeNngBvxawuuWTseXqphtISseZEyAafXaqzGnjOHthulbPmWYXdUBYCqaPIgZFKMsKgSiuQseZ	17112800	\N	2022-12-25 16:25:39.398037+03
66	66	429	https://cloud.com/aQNWxZEQMtTgxmuOgYLcllWPKszrxbujXOLKOndKmFroQrEXOjOnUIvcRgVXctkgcqvwTwKyimsjfqgKXOrJPRRsToePghHEJEni	71714339	\N	2022-12-25 16:25:39.408332+03
67	67	447	https://cloud.com/sdkDotKsVwXmwmeSPhxYjVMVAfvbeBcosNlOxQYCRRpSOuuvmbtmSMetJiDnASlibeIjjiaYXJoofhROTpihfQpEKzXEWUyAyXOa	8059555	\N	2022-12-25 16:25:39.41866+03
68	68	338	https://cloud.com/KWMgjWsnCBymYlLAZUHNdCTDfPrQtBLdgwWsLiHnPBcAMNjScSsWDppAEPrnrjngAKDQdvEvNmdkiYqCMMghcITtyubdZUwCrdHm	63124096	\N	2022-12-25 16:25:39.428819+03
69	69	338	https://cloud.com/ztgQeYxBwAQlNKXDyvMRBQrBZqdheFqkvfLPopQdtHRIyKEaYmxVDENiZRTQOszIfilWewWeVDSRlufWBJdCVkKxjrTTIQatNmul	56454519	\N	2022-12-25 16:25:39.43939+03
70	70	439	https://cloud.com/goFTFgEeykPUvuVLPIhKsjokfUATfQTHLJZGpPnjZErSPLULXwgTMcFbCqitsiYqOdhSixcJbsYVEsfkXAHgCKJttEbTDvXwTLiU	21637119	\N	2022-12-25 16:25:39.450667+03
71	71	478	https://cloud.com/ozKZEMZXTAwzsJagOtTjvTeNVPFQXIThUWAZRvuaZQJvxqbMymAntSobUsEzPIIHPuXRcNHqBkXsAcooXEWfRAcKePKsZBBCBXVb	23718430	\N	2022-12-25 16:25:39.460773+03
72	72	424	https://cloud.com/EuRGqGsglWLUqOxIYQfKiLspMGpJECdPqsWdnAkMwMiJJHZBJBBviDyfJxhDbUiwkFuVFvwexOnijBLfUxpTiriaYVdndvdsXbNY	85976286	\N	2022-12-25 16:25:39.471226+03
73	73	411	https://cloud.com/LcctqdQbfMLshTcrTxlzMQZyPvXQjTvywOnYSQBQkFpfmFykJbUWqztzoZEOEovhGeSxdNRwwcTATywNFQgMPnTlMAkLxxxzZkdO	9895267	\N	2022-12-25 16:25:39.481666+03
74	74	360	https://cloud.com/KRwjKlKHplUbCgXjOiMYQYKtJTveEmCRqwlDEphEpGQbDhyFdPmBEVvmypShIYoxcrREMypfcudAzVKQiOOkRSYjuaBsYrwIgcYH	56177455	\N	2022-12-25 16:25:39.491913+03
75	75	412	https://cloud.com/EqHmEQJKEyGMqJHUaYJcZogtcGUpQoXgYjLVMkoUFWYFBJCCIEyjkdDdLouQVYCvkSTanrWNsLxGqjpzitRkLHVNEnnPbqJhAecL	635183	\N	2022-12-25 16:25:39.502436+03
76	76	396	https://cloud.com/hAEXEvVlIqhIgeKImuCKyXozyZuAPppBYrtlpJihIWvFhbQBFRwaxvhXQgMfHgBmXygChEFeGpVHfFJVWRLZrIRipDFgBmwUBIvB	15074171	\N	2022-12-25 16:25:39.512635+03
77	77	489	https://cloud.com/pZaQsSbMLyOpHFCohJEiPfhhsTqBJKiUiAcXGVAVBfZeBIJcUajhHXJKdFEIOtlCjpnyRqMQpNYSFYeqCAXOQOJkAdLECrfSIoCj	9796341	\N	2022-12-25 16:25:39.5227+03
78	78	284	https://cloud.com/GsIzBdqLNHaskkEixqIuzPblOHPOjPKEGFXpyDScQjOuXXResSoXOpUVeYSJCvzJTcyvTIACQOgNvMIcRVbHRyLmfGCtnRirWFgt	98582660	\N	2022-12-25 16:25:39.533218+03
79	79	481	https://cloud.com/cIPMjXXZuMgzUokaQdVVElpfkuxqOasPdnoMkprYwcPnCmDBMaOJOENpLTKsdyEhGgXkLdxsNWkHDWPXztemawGKVUVHGKmQLerF	17455709	\N	2022-12-25 16:25:39.543264+03
80	80	336	https://cloud.com/AcPhdQrWMkLSmbuKQjYNTzvIxkjrxRzjzpxPZfNabNgKNXFkYJWfQXVHKNrqqKszivMfLKKTXFRuzvAoclxEbTzeugxiKmDVOhdQ	74777770	\N	2022-12-25 16:25:39.55395+03
81	81	465	https://cloud.com/wLePjrkYzEDNOHnPjttetZhbztDsMrHZajzTwHiHTvpKETjbsWgRBmssTMYCucIxVCHTMWhyEFCCeHluXRDIpHkcgrGwyIJjrRxh	39879085	\N	2022-12-25 16:25:39.565105+03
82	82	291	https://cloud.com/ZWTHwOUQlpEQUeQgBHlfKFPgbvJwPhLRbKOWTlyUoAdSDVaXDeMQQISpdKsmsZWnisBZysUrHIPlKmtctOFNULtSoGZBnYsITKoY	12487521	\N	2022-12-25 16:25:39.575219+03
83	83	442	https://cloud.com/DJiyavsYbWmTVeRklgwXbDFxsANSbxWmqAqiIvFwsvZVMSlPouOFCDMWxjUwMAcaXHidYlUiyiaPyRYELaqazDAUnOlfYiJMuajy	36616947	\N	2022-12-25 16:25:39.585291+03
84	84	438	https://cloud.com/noLFNGDSXwVWaSJcvxDVokITcNDFdzLTIlIUglgNCzWFfNIsZGXlRwLzihLsuNHuIoVatZXiPIbDOtvjQGGiakxAvbulmQFoQDdM	53266980	\N	2022-12-25 16:25:39.595374+03
85	85	325	https://cloud.com/PqliBXdGOMtIHoLjIDBTnFzMGEKBuMAjfaZHBqFEcJTLUGsrnhySoKYkhJLziHBUsuXwUPvxLNYgYTOZVzXJOjyoGORkqvtvqbGY	77555507	\N	2022-12-25 16:25:39.60523+03
86	86	341	https://cloud.com/mGqdQDRABTgQsicyjpPMmcVSjeSHitOkZKRQphQyAuUsOHeEzQhJTwNaNvfqJyvIzgqhKWRuFbLpSOumJlDXQnZXeUUWGVfpBrLg	40877141	\N	2022-12-25 16:25:39.615014+03
87	87	303	https://cloud.com/WmEhfhAkOeRYidyXFfIOIVgsGszLMmUXsFoYdyNWvlpZhaiGmKSpKMKdPdZthUJRWWNQPCiCjVYybfKhURCBeyaKtkMuMAUEzKXx	47068316	\N	2022-12-25 16:25:39.624734+03
88	88	466	https://cloud.com/wuqTSXxLkSLdlbOPkFHKzOrKZhYGhhAUUSavoRKJhAEFKvTsRlqzKAyASwaZJcyioCEjaagBjwCyfaKbzrSWYRKVKiGKwWOmoCsF	36973079	\N	2022-12-25 16:25:39.634583+03
89	89	400	https://cloud.com/NwLLvUHLgOvrzCSlFNRyGWiEJyKbZYUHxOdQXPcprpPUDrfuQSeUdaUILKuZPQKiNzUvDPlDPKvOoyCQIueCRWwYFPPlxzKHdvOE	1585475	\N	2022-12-25 16:25:39.644693+03
90	90	318	https://cloud.com/xkNLCeXIEgWRdgyIaYrfdkachOeyLieULWcaoJvcwJaGpSLqGGduPzfBbPhXcjVOrPRUuJPRGPQDsYhWlHHdlYwXDnBAJrnwswuR	28420709	\N	2022-12-25 16:25:39.654603+03
91	91	475	https://cloud.com/cTZyhxDgVCliWzpLUmKmSnHpGppvTuAMrEBhXBOPstYJEcewlBBLPFcFaSJlOMYAulctfhcSUQhrAJGlEEGFcgXSoBYPQOnuiJBJ	19540256	\N	2022-12-25 16:25:39.664281+03
92	92	470	https://cloud.com/ovrQxwsfGkEQgyjfBHGAVFQWiSCWKlMhKqrUtLMnzuEnELCvfWkOWmTLFsVWyLBTRIKKnJmRrIikAsTNpvPUkzoPEnWEagzfCPBe	3933185	\N	2022-12-25 16:25:39.674073+03
93	93	370	https://cloud.com/NJaaUtrYFjNbtBufPQXdHkXDuHewdWbmoRgnmDRRTgTtXMokgzGLlzbZMxcdwGXQxrwEuCMGlfLGrNyHvvqqMYnsBLqUjawgUkJE	55755887	\N	2022-12-25 16:25:39.683906+03
94	94	474	https://cloud.com/TjlIxNdGQWgHrkRTXMqlbFOPfRKQQOorzIydbGXNHmirjbbzllfokkrHFnTxHJeBLBEWPurQhuCtgJKlgmYHWaujGsqJMpAogujw	93198581	\N	2022-12-25 16:25:39.69558+03
95	95	323	https://cloud.com/ntAyfxLJLzITYEgvZNswMWelhXoghuAdTykXfzVuEvCfAMWzHfhMLgTgITljpwSFzoFCXHvNpEIwKuNckEdHRYBSkAdrfTGxCAhu	8382602	\N	2022-12-25 16:25:39.708205+03
96	96	261	https://cloud.com/ZVlHpdmiwmRIpujrAktmEQmnSIZorhsreouaapECiLwigTAldMXaRfFoAFYMnfmXBumxMKnCVCMQgXYwQkoiSgIRBYKHNCSldFJi	81012036	\N	2022-12-25 16:25:39.720014+03
97	97	471	https://cloud.com/PUGXWTzWNFwnUdRPIHjgiseszKsXPljNJgjGUNnHjmQmuwpdjJlBJTIgCuqZXVdWvtMVwhySqThAKmLFBnENpgImdpVrjLyPnOEX	60359784	\N	2022-12-25 16:25:39.731754+03
98	98	412	https://cloud.com/tCBxqzxEvTsxoymrcKluAbzZZthsPBRLOOpENBkxPnZjYHvafvqUvdBymkOLTxrPVuXPDYXZPnuKTSKejsmpdomVPPORbpoHRDty	86895524	\N	2022-12-25 16:25:39.743769+03
99	99	458	https://cloud.com/ljJcLlZVIFAWdCdaWumVNHsSwOXJZlkFdzDugSRHMMoTclFdgctzJXfKwoqITwCtuHHMwnBaSKNIuNBAKvHxgzohPeTiPxqvtTEY	20060326	\N	2022-12-25 16:25:39.754713+03
100	100	449	https://cloud.com/arwGVedLvShWpvekvUedbuKkFhApqoNADvBuNxmXsHmCZXiYaMEOFwhHLthDZklXfoItZJEGfwOBuDevvttKmovmwGJzBShQXYSJ	31651878	\N	2022-12-25 16:25:39.765596+03
101	101	331	https://cloud.com/ksFkvonlMpojTiBfSEYCrzyvbZwOtBFgIceNROHtaXNRLVdOfNRFLzBmTUNVSMqCMYiLFLJegxTeQJWJwByvMycxSojJWOBgkMWl	92556959	\N	2022-12-25 16:25:39.776051+03
102	102	491	https://cloud.com/ywOvOdlzVfXWAxgHNFAAVwJzMeDaYNvdZZuhMGTTRefyyzgXBwhJainqeiypjrxxROGjDjTlEVgreKQehiWDPCJxxYEosjeCBinH	45336704	\N	2022-12-25 16:25:39.786015+03
103	103	463	https://cloud.com/EZAyPspncvRMcIQfFAPerAZOUNOTAyVZvQVmBwaTlKUzdWhWSIhKPlceAJjbihMbWiWRUbvydQaimZFOpCTeyUwHSMKsRJLfdnMw	70195356	\N	2022-12-25 16:25:39.795663+03
104	104	420	https://cloud.com/pKGgduYgrurJzmYmPPOaCilwEtaPidAhSUDtIwlOQBXnSrdcLSdJfOsMyMTDfJwvTZoYYVVnznFzEUSiDUeDTvjkhrgMsCBaqOPR	54923314	\N	2022-12-25 16:25:39.805649+03
105	105	471	https://cloud.com/rGliCHQVENzeoiAvvWtPCunmwmyfqddxUHZmDCKAuGquxbmqjtULunmmcqOczfOJtXILcsADvbkwQLNIEVJAxeREpsSbEJAaWklA	56302813	\N	2022-12-25 16:25:39.815613+03
106	106	377	https://cloud.com/NYxmkGcRairCPCsOzkKUkxDSGrobjkqLLDFngSDerwygyMmCaFuOqKGuqZueQrPzRXittcVblxLMQDbcYbNUCvDHPhZmRvuXfZwJ	23428687	\N	2022-12-25 16:25:39.82564+03
107	107	452	https://cloud.com/vfmJMpWHfuJXeWFrEmauiBuTOUJPGrgNOOVHxvTyjJjoLSaDKjvODEjzdksdShKaKxnXGAJtqnmxXabWLTEoBhTEXQLxLlnFhflH	67790583	\N	2022-12-25 16:25:39.835418+03
108	108	405	https://cloud.com/obRNnOVfSFkvIIrOgILMrunRjALqUOYwpqNxLTUYBLhTaWBCkXVGruAUycmWLbSevKZdnMxlkjEesDfnAsFDKkspPMjFegOYSKyz	57692568	\N	2022-12-25 16:25:39.845536+03
109	109	392	https://cloud.com/EvakvtbWGpxVmqLGKhaZDzADHBLTclYnKqlCllSisYdtVBXSjJlbmdMBnEpCNyxoURKgtccWjplBSFoDSFxpmhctokFoPXSMxCaQ	68514551	\N	2022-12-25 16:25:39.855212+03
110	110	494	https://cloud.com/ofouHNOHVRCTPEBIKYoRhlVZQyTXghjdFuLLOprWHfopjuUOsIrYHwsdgZVaLKDcZHVYIFRSVjSpLpNWFpGhrGdsjhiGzzgGaTzu	97054049	\N	2022-12-25 16:25:39.865362+03
111	111	393	https://cloud.com/WWzLrZBysacqUCWdTWvumFgTAzDcFBZJVxFYcfgSVHpErvFUjmUDDNoQpYXSSdSZtAXkWgAlXWUcjgSfnAbPYndVVVvQPaKfKdDj	59620072	\N	2022-12-25 16:25:39.875083+03
112	112	264	https://cloud.com/qKLiXmKucxhgzBCjuoXpksasrWdOgjxvguNwjrGmrUUpVaShMmBAmviMnrflmhXSYFBewQDcUhidIaWrujvODTnWTbckDlgoiTAT	39792620	\N	2022-12-25 16:25:39.884885+03
113	113	426	https://cloud.com/vZegvXgiBmASjvlbxHKroBYaXancALvAUthjpxYDhhBULmnlEkexjVCokqswmChAwjOaCimHUjTSNuvooHzHNEZHWJlfLVctPGEP	19258881	\N	2022-12-25 16:25:39.895066+03
114	114	408	https://cloud.com/QVvFJNwUQMsKZnocAKFpdxKMWwMhFMCjDrorbQBzmZAdHhKbMusLpJyytVTsIFnZuXnKfWssSUkxkgeCvzJYxMmJinZepprXAuSr	15905104	\N	2022-12-25 16:25:39.904884+03
115	115	336	https://cloud.com/epZwKtPYxyqNRUffXyWIZeJITlpGurUigvnViPLFZGouROhUsHNNoaLvUuckHKQVApvoIWDeDcrMRMVmMAzpNTcmPvGUXnhGEmFk	78944457	\N	2022-12-25 16:25:39.914922+03
116	116	426	https://cloud.com/KrsJuYwjjQEIuMGGRYENSJudwVqBNXrznTUNScvZRaaUoiVnifgQLDvenvwdwSIEFOPFlZopHOFdyfmSuHYhfbbqKDeBjKJbLiaV	25291441	\N	2022-12-25 16:25:39.924915+03
117	117	369	https://cloud.com/GfEYmFIudkdbHinbqCiTcUdqtcHrXPRPKWmPbNTQdgmcYQKPZZdDBMLaleFMfjuHIRulBmRHgBUMlEwahlRIIhYdJBGAwEoHEuoR	79361232	\N	2022-12-25 16:25:39.934889+03
118	118	264	https://cloud.com/CxQHWmPPoSbsKDtlPoAlzSZEbYNsNyvKVXbdKzBZLpBoZxIWDpQDpjwBARKxnXCmOfmQwEQkGsnZANQBPKShazPWgJZqFxpTXuwe	27966650	\N	2022-12-25 16:25:39.945565+03
119	119	360	https://cloud.com/KkNfRHxfsHISObCLOWdZiydnsZruRGoPArnFfogNkNnuhUqxfbfuGWpwucWrsfXxEjGWzNtwhMIOssyGgdckctZmAzzCunIJWXBi	94115051	\N	2022-12-25 16:25:39.955634+03
120	120	376	https://cloud.com/ZmPJHMWDrStLKZtoWUsDvBoiuKSyyLpyhuWXoWNApeXglcHibnokCdYGaIiTujTndxkTazGLUzFdTthjbqycgNteNZXxSLwLfyFq	36791081	\N	2022-12-25 16:25:39.966052+03
121	121	387	https://cloud.com/WbBYtNdiSlfQZZHEEVtLohZROHUmldRGBNdxjfHFjnaHilcpeGFuyJCCkcYtrUmhqfHJcWZVXSkPUCLJBUEDzEPsjxbtpDLEhqIt	98420923	\N	2022-12-25 16:25:39.975806+03
122	122	455	https://cloud.com/GLpXDkRvSfOoccXMNxyCgdeIGBEsGrSMCViGMnyakrPOvYkWIrXSGrzZKbahlGmMwzBmGIUkttlfwvhTQjMRGUqepbBytIpYIrWF	36991955	\N	2022-12-25 16:25:39.985934+03
123	123	466	https://cloud.com/VPAobddRjticAxrUYhjNPkhGILgIUnJIyWGlMpKOhSUjvqkKiuAJXOFIxIEMbpMnNmfxahqGlkxYalHCLwILFEmmCVcxIExsowNk	77014547	\N	2022-12-25 16:25:39.995629+03
124	124	343	https://cloud.com/pYbPNmXeANPZWSDRbUbiyuqPyRLIYjQDyHjILVFBosrPBAafQCnFdPFWQEordeUCKEpiuhMQlfVzrUnNjxmwUeLyZhFdnHkabuKn	81690250	\N	2022-12-25 16:25:40.005594+03
\.


--
-- Data for Name: study_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.study_group (id, discipline_id) FROM stdin;
ABCD-01-22	1
ABCD-01-22	2
ABCD-01-22	3
ABCD-01-22	4
ABCD-02-22	1
ABCD-02-22	2
ABCD-02-22	3
ABCD-02-22	4
ABCD-02-22	5
ABCD-02-22	6
ABCD-03-22	1
ABCD-03-22	2
ABCD-04-22	1
ABCD-04-22	2
ABCD-04-22	3
ABCD-04-22	4
ABCD-05-22	1
ABCD-05-22	2
ABCD-05-22	3
ABCD-05-22	4
ABCD-05-22	5
ABCD-06-22	1
ABCD-06-22	2
ABCD-06-22	3
ABCD-07-22	1
ABCD-07-22	2
ABCD-08-22	1
ABCD-08-22	2
ABCD-08-22	3
ABCD-08-22	4
ABCD-08-22	5
ABCD-08-22	6
ABCD-09-22	1
ABCD-09-22	2
ABCD-09-22	3
ABCD-10-22	1
ABCD-10-22	2
ABCD-10-22	3
ABCD-11-22	1
ABCD-11-22	2
ABCD-12-22	1
ABCD-12-22	2
ABCD-12-22	3
ABCD-13-22	1
ABCD-13-22	2
ABCD-14-22	1
ABCD-14-22	2
ABCD-15-22	1
ABCD-15-22	2
ABCD-16-22	1
ABCD-16-22	2
ABCD-17-22	1
ABCD-17-22	2
ABCD-17-22	3
ABCD-17-22	4
ABCD-17-22	5
ABCD-17-22	6
ABCD-18-22	1
ABCD-18-22	2
ABCD-18-22	3
ABCD-19-22	1
ABCD-19-22	2
ABCD-19-22	3
ABCD-19-22	4
ABCD-19-22	5
ABCD-19-22	6
ABCD-20-22	1
ABCD-20-22	2
ABCD-20-22	3
ABCD-20-22	4
ABCD-20-22	5
ABCD-20-22	6
\.


--
-- Data for Name: study_group_cipher; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.study_group_cipher (id) FROM stdin;
ABCD-01-22
ABCD-02-22
ABCD-03-22
ABCD-04-22
ABCD-05-22
ABCD-06-22
ABCD-07-22
ABCD-08-22
ABCD-09-22
ABCD-10-22
ABCD-11-22
ABCD-12-22
ABCD-13-22
ABCD-14-22
ABCD-15-22
ABCD-16-22
ABCD-17-22
ABCD-18-22
ABCD-19-22
ABCD-20-22
\.


--
-- Data for Name: study_group_task; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.study_group_task (id, study_group_cipher_id, status, deadline_date) FROM stdin;
125	ABCD-01-22	pending	2022-12-26 16:25:40.011528+03
125	ABCD-02-22	pending	2022-12-30 16:25:40.019527+03
126	ABCD-01-22	pending	2022-12-30 16:25:40.024539+03
126	ABCD-02-22	pending	2022-12-30 16:25:40.029527+03
127	ABCD-01-22	pending	2022-12-28 16:25:40.034541+03
127	ABCD-02-22	pending	2022-12-27 16:25:40.039532+03
127	ABCD-03-22	pending	2022-12-27 16:25:40.044532+03
127	ABCD-04-22	pending	2022-12-30 16:25:40.049532+03
127	ABCD-05-22	pending	2022-12-27 16:25:40.05404+03
127	ABCD-06-22	pending	2022-12-26 16:25:40.059045+03
128	ABCD-01-22	pending	2022-12-26 16:25:40.064046+03
128	ABCD-02-22	pending	2022-12-30 16:25:40.069057+03
128	ABCD-03-22	pending	2022-12-27 16:25:40.073902+03
128	ABCD-04-22	pending	2022-12-29 16:25:40.077901+03
128	ABCD-05-22	pending	2022-12-28 16:25:40.0829+03
128	ABCD-06-22	pending	2022-12-26 16:25:40.0879+03
128	ABCD-07-22	pending	2022-12-30 16:25:40.092902+03
128	ABCD-08-22	pending	2022-12-30 16:25:40.097901+03
128	ABCD-09-22	pending	2022-12-27 16:25:40.102901+03
129	ABCD-01-22	pending	2022-12-29 16:25:40.107903+03
129	ABCD-02-22	pending	2022-12-26 16:25:40.111902+03
129	ABCD-03-22	pending	2022-12-29 16:25:40.117901+03
129	ABCD-04-22	pending	2022-12-30 16:25:40.121903+03
129	ABCD-05-22	pending	2022-12-30 16:25:40.126902+03
129	ABCD-06-22	pending	2022-12-29 16:25:40.131901+03
129	ABCD-07-22	pending	2022-12-29 16:25:40.136901+03
129	ABCD-08-22	pending	2022-12-29 16:25:40.141936+03
129	ABCD-09-22	pending	2022-12-30 16:25:40.146936+03
130	ABCD-01-22	pending	2022-12-27 16:25:40.151936+03
130	ABCD-02-22	pending	2022-12-27 16:25:40.1572+03
130	ABCD-03-22	pending	2022-12-26 16:25:40.1612+03
130	ABCD-04-22	pending	2022-12-30 16:25:40.166199+03
130	ABCD-05-22	pending	2022-12-30 16:25:40.171199+03
131	ABCD-01-22	pending	2022-12-28 16:25:40.176201+03
131	ABCD-02-22	pending	2022-12-28 16:25:40.1822+03
131	ABCD-03-22	pending	2022-12-28 16:25:40.186199+03
132	ABCD-01-22	pending	2022-12-27 16:25:40.191199+03
132	ABCD-02-22	pending	2022-12-27 16:25:40.196199+03
132	ABCD-03-22	pending	2022-12-28 16:25:40.201202+03
132	ABCD-04-22	pending	2022-12-29 16:25:40.2062+03
132	ABCD-05-22	pending	2022-12-27 16:25:40.2122+03
133	ABCD-01-22	pending	2022-12-26 16:25:40.217198+03
133	ABCD-02-22	pending	2022-12-28 16:25:40.2232+03
133	ABCD-03-22	pending	2022-12-29 16:25:40.228199+03
133	ABCD-04-22	pending	2022-12-29 16:25:40.233199+03
133	ABCD-05-22	pending	2022-12-30 16:25:40.2382+03
134	ABCD-01-22	pending	2022-12-26 16:25:40.243724+03
134	ABCD-02-22	pending	2022-12-29 16:25:40.247724+03
134	ABCD-03-22	pending	2022-12-29 16:25:40.252724+03
134	ABCD-04-22	pending	2022-12-29 16:25:40.258266+03
134	ABCD-05-22	pending	2022-12-28 16:25:40.263254+03
135	ABCD-01-22	pending	2022-12-26 16:25:40.267254+03
135	ABCD-02-22	pending	2022-12-28 16:25:40.272252+03
135	ABCD-03-22	pending	2022-12-26 16:25:40.277255+03
135	ABCD-04-22	pending	2022-12-27 16:25:40.282253+03
135	ABCD-05-22	pending	2022-12-30 16:25:40.287253+03
135	ABCD-06-22	pending	2022-12-28 16:25:40.292263+03
135	ABCD-07-22	pending	2022-12-28 16:25:40.297265+03
136	ABCD-01-22	pending	2022-12-28 16:25:40.302264+03
136	ABCD-02-22	pending	2022-12-30 16:25:40.311264+03
136	ABCD-03-22	pending	2022-12-26 16:25:40.317265+03
136	ABCD-04-22	pending	2022-12-30 16:25:40.322264+03
136	ABCD-05-22	pending	2022-12-29 16:25:40.327263+03
136	ABCD-06-22	pending	2022-12-29 16:25:40.332262+03
136	ABCD-07-22	pending	2022-12-26 16:25:40.337264+03
136	ABCD-08-22	pending	2022-12-27 16:25:40.342269+03
136	ABCD-09-22	pending	2022-12-26 16:25:40.348269+03
136	ABCD-10-22	pending	2022-12-27 16:25:40.353268+03
137	ABCD-01-22	pending	2022-12-29 16:25:40.35829+03
137	ABCD-02-22	pending	2022-12-28 16:25:40.362861+03
137	ABCD-03-22	pending	2022-12-29 16:25:40.368862+03
137	ABCD-04-22	pending	2022-12-29 16:25:40.372863+03
137	ABCD-05-22	pending	2022-12-29 16:25:40.377861+03
138	ABCD-01-22	pending	2022-12-29 16:25:40.383682+03
138	ABCD-02-22	pending	2022-12-30 16:25:40.387681+03
138	ABCD-03-22	pending	2022-12-28 16:25:40.392681+03
138	ABCD-04-22	pending	2022-12-26 16:25:40.398682+03
138	ABCD-05-22	pending	2022-12-27 16:25:40.403813+03
139	ABCD-01-22	pending	2022-12-28 16:25:40.407815+03
139	ABCD-02-22	pending	2022-12-26 16:25:40.413814+03
139	ABCD-03-22	pending	2022-12-28 16:25:40.418813+03
140	ABCD-01-22	pending	2022-12-28 16:25:40.422826+03
140	ABCD-02-22	pending	2022-12-27 16:25:40.427816+03
141	ABCD-01-22	pending	2022-12-26 16:25:40.432813+03
141	ABCD-02-22	pending	2022-12-26 16:25:40.437813+03
141	ABCD-03-22	pending	2022-12-29 16:25:40.443833+03
142	ABCD-01-22	pending	2022-12-26 16:25:40.449833+03
143	ABCD-01-22	pending	2022-12-30 16:25:40.454337+03
143	ABCD-02-22	pending	2022-12-29 16:25:40.460355+03
143	ABCD-03-22	pending	2022-12-27 16:25:40.465342+03
143	ABCD-04-22	pending	2022-12-29 16:25:40.470342+03
143	ABCD-05-22	pending	2022-12-28 16:25:40.476344+03
143	ABCD-06-22	pending	2022-12-26 16:25:40.481342+03
144	ABCD-01-22	pending	2022-12-28 16:25:40.486342+03
144	ABCD-02-22	pending	2022-12-26 16:25:40.491342+03
144	ABCD-03-22	pending	2022-12-28 16:25:40.496342+03
144	ABCD-04-22	pending	2022-12-30 16:25:40.501342+03
144	ABCD-05-22	pending	2022-12-26 16:25:40.506364+03
144	ABCD-06-22	pending	2022-12-30 16:25:40.511364+03
144	ABCD-07-22	pending	2022-12-28 16:25:40.516365+03
144	ABCD-08-22	pending	2022-12-30 16:25:40.522365+03
145	ABCD-01-22	pending	2022-12-30 16:25:40.526365+03
145	ABCD-02-22	pending	2022-12-30 16:25:40.531365+03
145	ABCD-03-22	pending	2022-12-27 16:25:40.537378+03
145	ABCD-04-22	pending	2022-12-29 16:25:40.542373+03
145	ABCD-05-22	pending	2022-12-28 16:25:40.547373+03
145	ABCD-06-22	pending	2022-12-29 16:25:40.552372+03
145	ABCD-07-22	pending	2022-12-30 16:25:40.557882+03
145	ABCD-08-22	pending	2022-12-29 16:25:40.563881+03
145	ABCD-09-22	pending	2022-12-29 16:25:40.568881+03
146	ABCD-01-22	pending	2022-12-26 16:25:40.573883+03
147	ABCD-01-22	pending	2022-12-26 16:25:40.578441+03
147	ABCD-02-22	pending	2022-12-27 16:25:40.583444+03
147	ABCD-03-22	pending	2022-12-28 16:25:40.588441+03
147	ABCD-04-22	pending	2022-12-29 16:25:40.592443+03
147	ABCD-05-22	pending	2022-12-27 16:25:40.597443+03
147	ABCD-06-22	pending	2022-12-29 16:25:40.602442+03
147	ABCD-07-22	pending	2022-12-30 16:25:40.607486+03
147	ABCD-08-22	pending	2022-12-26 16:25:40.611487+03
147	ABCD-09-22	pending	2022-12-28 16:25:40.616487+03
148	ABCD-01-22	pending	2022-12-26 16:25:40.621486+03
149	ABCD-01-22	pending	2022-12-29 16:25:40.625487+03
149	ABCD-02-22	pending	2022-12-29 16:25:40.630485+03
149	ABCD-03-22	pending	2022-12-29 16:25:40.635487+03
149	ABCD-04-22	pending	2022-12-29 16:25:40.640507+03
149	ABCD-05-22	pending	2022-12-28 16:25:40.645507+03
149	ABCD-06-22	pending	2022-12-27 16:25:40.650509+03
149	ABCD-07-22	pending	2022-12-27 16:25:40.654522+03
149	ABCD-08-22	pending	2022-12-28 16:25:40.659252+03
149	ABCD-09-22	pending	2022-12-29 16:25:40.664233+03
149	ABCD-10-22	pending	2022-12-27 16:25:40.669233+03
150	ABCD-01-22	pending	2022-12-26 16:25:40.674233+03
150	ABCD-02-22	pending	2022-12-30 16:25:40.679233+03
150	ABCD-03-22	pending	2022-12-30 16:25:40.684234+03
150	ABCD-04-22	pending	2022-12-27 16:25:40.689233+03
150	ABCD-05-22	pending	2022-12-29 16:25:40.693233+03
151	ABCD-01-22	pending	2022-12-29 16:25:40.698234+03
151	ABCD-02-22	pending	2022-12-26 16:25:40.703298+03
152	ABCD-01-22	pending	2022-12-28 16:25:40.708286+03
152	ABCD-02-22	pending	2022-12-26 16:25:40.713286+03
152	ABCD-03-22	pending	2022-12-28 16:25:40.718285+03
152	ABCD-04-22	pending	2022-12-30 16:25:40.723286+03
152	ABCD-05-22	pending	2022-12-26 16:25:40.727289+03
152	ABCD-06-22	pending	2022-12-30 16:25:40.732286+03
152	ABCD-07-22	pending	2022-12-29 16:25:40.737286+03
152	ABCD-08-22	pending	2022-12-26 16:25:40.7423+03
152	ABCD-09-22	pending	2022-12-30 16:25:40.746684+03
153	ABCD-01-22	pending	2022-12-26 16:25:40.751699+03
153	ABCD-02-22	pending	2022-12-29 16:25:40.75571+03
153	ABCD-03-22	pending	2022-12-28 16:25:40.760709+03
154	ABCD-01-22	pending	2022-12-27 16:25:40.765711+03
154	ABCD-02-22	pending	2022-12-28 16:25:40.770725+03
154	ABCD-03-22	pending	2022-12-29 16:25:40.775761+03
154	ABCD-04-22	pending	2022-12-27 16:25:40.780761+03
155	ABCD-01-22	pending	2022-12-26 16:25:40.784762+03
155	ABCD-02-22	pending	2022-12-29 16:25:40.789762+03
155	ABCD-03-22	pending	2022-12-26 16:25:40.794763+03
155	ABCD-04-22	pending	2022-12-29 16:25:40.798762+03
155	ABCD-05-22	pending	2022-12-26 16:25:40.803762+03
155	ABCD-06-22	pending	2022-12-27 16:25:40.808761+03
155	ABCD-07-22	pending	2022-12-26 16:25:40.813762+03
155	ABCD-08-22	pending	2022-12-29 16:25:40.818762+03
156	ABCD-01-22	pending	2022-12-30 16:25:40.823762+03
156	ABCD-02-22	pending	2022-12-30 16:25:40.827762+03
156	ABCD-03-22	pending	2022-12-30 16:25:40.832762+03
156	ABCD-04-22	pending	2022-12-29 16:25:40.837762+03
156	ABCD-05-22	pending	2022-12-29 16:25:40.841766+03
156	ABCD-06-22	pending	2022-12-27 16:25:40.846766+03
156	ABCD-07-22	pending	2022-12-28 16:25:40.850765+03
156	ABCD-08-22	pending	2022-12-30 16:25:40.855863+03
157	ABCD-01-22	pending	2022-12-27 16:25:40.861482+03
157	ABCD-02-22	pending	2022-12-29 16:25:40.865483+03
157	ABCD-03-22	pending	2022-12-29 16:25:40.870483+03
157	ABCD-04-22	pending	2022-12-26 16:25:40.875483+03
158	ABCD-01-22	pending	2022-12-28 16:25:40.880482+03
158	ABCD-02-22	pending	2022-12-30 16:25:40.884482+03
158	ABCD-03-22	pending	2022-12-27 16:25:40.889482+03
158	ABCD-04-22	pending	2022-12-28 16:25:40.894482+03
159	ABCD-01-22	pending	2022-12-26 16:25:40.899482+03
159	ABCD-02-22	pending	2022-12-28 16:25:40.903814+03
159	ABCD-03-22	pending	2022-12-29 16:25:40.908814+03
160	ABCD-01-22	pending	2022-12-28 16:25:40.912815+03
160	ABCD-02-22	pending	2022-12-27 16:25:40.917814+03
160	ABCD-03-22	pending	2022-12-30 16:25:40.922814+03
160	ABCD-04-22	pending	2022-12-29 16:25:40.927815+03
160	ABCD-05-22	pending	2022-12-30 16:25:40.932814+03
160	ABCD-06-22	pending	2022-12-27 16:25:40.936814+03
161	ABCD-01-22	pending	2022-12-28 16:25:40.941819+03
161	ABCD-02-22	pending	2022-12-27 16:25:40.947821+03
161	ABCD-03-22	pending	2022-12-26 16:25:40.95282+03
161	ABCD-04-22	pending	2022-12-29 16:25:40.956951+03
161	ABCD-05-22	pending	2022-12-26 16:25:40.96195+03
161	ABCD-06-22	pending	2022-12-29 16:25:40.967352+03
161	ABCD-07-22	pending	2022-12-27 16:25:40.972352+03
162	ABCD-01-22	pending	2022-12-29 16:25:40.977353+03
162	ABCD-02-22	pending	2022-12-30 16:25:40.982351+03
162	ABCD-03-22	pending	2022-12-26 16:25:40.987352+03
162	ABCD-04-22	pending	2022-12-28 16:25:40.992352+03
162	ABCD-05-22	pending	2022-12-27 16:25:40.997385+03
162	ABCD-06-22	pending	2022-12-27 16:25:41.002386+03
162	ABCD-07-22	pending	2022-12-27 16:25:41.007384+03
162	ABCD-08-22	pending	2022-12-26 16:25:41.011383+03
163	ABCD-01-22	pending	2022-12-28 16:25:41.016396+03
163	ABCD-02-22	pending	2022-12-29 16:25:41.021383+03
163	ABCD-03-22	pending	2022-12-27 16:25:41.026384+03
163	ABCD-04-22	pending	2022-12-26 16:25:41.031384+03
163	ABCD-05-22	pending	2022-12-27 16:25:41.035384+03
163	ABCD-06-22	pending	2022-12-30 16:25:41.040387+03
164	ABCD-01-22	pending	2022-12-28 16:25:41.045388+03
164	ABCD-02-22	pending	2022-12-28 16:25:41.0494+03
164	ABCD-03-22	pending	2022-12-27 16:25:41.053387+03
164	ABCD-04-22	pending	2022-12-30 16:25:41.058896+03
164	ABCD-05-22	pending	2022-12-28 16:25:41.063897+03
164	ABCD-06-22	pending	2022-12-27 16:25:41.067852+03
164	ABCD-07-22	pending	2022-12-29 16:25:41.072852+03
164	ABCD-08-22	pending	2022-12-29 16:25:41.077852+03
165	ABCD-01-22	pending	2022-12-28 16:25:41.082852+03
165	ABCD-02-22	pending	2022-12-28 16:25:41.086852+03
165	ABCD-03-22	pending	2022-12-30 16:25:41.092443+03
165	ABCD-04-22	pending	2022-12-28 16:25:41.096439+03
165	ABCD-05-22	pending	2022-12-26 16:25:41.101438+03
165	ABCD-06-22	pending	2022-12-28 16:25:41.106439+03
165	ABCD-07-22	pending	2022-12-28 16:25:41.111439+03
165	ABCD-08-22	pending	2022-12-28 16:25:41.116467+03
166	ABCD-01-22	pending	2022-12-27 16:25:41.121467+03
166	ABCD-02-22	pending	2022-12-28 16:25:41.126466+03
166	ABCD-03-22	pending	2022-12-30 16:25:41.130466+03
166	ABCD-04-22	pending	2022-12-30 16:25:41.135466+03
167	ABCD-01-22	pending	2022-12-27 16:25:41.140471+03
167	ABCD-02-22	pending	2022-12-28 16:25:41.145471+03
167	ABCD-03-22	pending	2022-12-29 16:25:41.150471+03
167	ABCD-04-22	pending	2022-12-29 16:25:41.154976+03
167	ABCD-05-22	pending	2022-12-28 16:25:41.158983+03
167	ABCD-06-22	pending	2022-12-27 16:25:41.163981+03
167	ABCD-07-22	pending	2022-12-29 16:25:41.168984+03
167	ABCD-08-22	pending	2022-12-29 16:25:41.173981+03
167	ABCD-09-22	pending	2022-12-27 16:25:41.177981+03
168	ABCD-01-22	pending	2022-12-29 16:25:41.182983+03
168	ABCD-02-22	pending	2022-12-27 16:25:41.187981+03
168	ABCD-03-22	pending	2022-12-29 16:25:41.192995+03
168	ABCD-04-22	pending	2022-12-28 16:25:41.197578+03
169	ABCD-01-22	pending	2022-12-26 16:25:41.202577+03
169	ABCD-02-22	pending	2022-12-27 16:25:41.206592+03
170	ABCD-01-22	pending	2022-12-27 16:25:41.211578+03
170	ABCD-02-22	pending	2022-12-29 16:25:41.216579+03
170	ABCD-03-22	pending	2022-12-29 16:25:41.221618+03
170	ABCD-04-22	pending	2022-12-30 16:25:41.229618+03
170	ABCD-05-22	pending	2022-12-28 16:25:41.235618+03
170	ABCD-06-22	pending	2022-12-26 16:25:41.240641+03
170	ABCD-07-22	pending	2022-12-28 16:25:41.245638+03
170	ABCD-08-22	pending	2022-12-27 16:25:41.251663+03
170	ABCD-09-22	pending	2022-12-26 16:25:41.256206+03
171	ABCD-01-22	pending	2022-12-27 16:25:41.261206+03
171	ABCD-02-22	pending	2022-12-27 16:25:41.265204+03
171	ABCD-03-22	pending	2022-12-29 16:25:41.270206+03
171	ABCD-04-22	pending	2022-12-27 16:25:41.275206+03
171	ABCD-05-22	pending	2022-12-30 16:25:41.280667+03
171	ABCD-06-22	pending	2022-12-27 16:25:41.285005+03
172	ABCD-01-22	pending	2022-12-26 16:25:41.290004+03
172	ABCD-02-22	pending	2022-12-26 16:25:41.295003+03
172	ABCD-03-22	pending	2022-12-28 16:25:41.299004+03
172	ABCD-04-22	pending	2022-12-28 16:25:41.304216+03
173	ABCD-01-22	pending	2022-12-28 16:25:41.309214+03
173	ABCD-02-22	pending	2022-12-28 16:25:41.314214+03
174	ABCD-01-22	pending	2022-12-30 16:25:41.318214+03
175	ABCD-01-22	pending	2022-12-26 16:25:41.323214+03
175	ABCD-02-22	pending	2022-12-27 16:25:41.328216+03
175	ABCD-03-22	pending	2022-12-30 16:25:41.333215+03
175	ABCD-04-22	pending	2022-12-28 16:25:41.338214+03
175	ABCD-05-22	pending	2022-12-26 16:25:41.34222+03
175	ABCD-06-22	pending	2022-12-30 16:25:41.34722+03
175	ABCD-07-22	pending	2022-12-30 16:25:41.352221+03
175	ABCD-08-22	pending	2022-12-26 16:25:41.356736+03
175	ABCD-09-22	pending	2022-12-30 16:25:41.361737+03
176	ABCD-01-22	pending	2022-12-28 16:25:41.366042+03
176	ABCD-02-22	pending	2022-12-27 16:25:41.371042+03
176	ABCD-03-22	pending	2022-12-30 16:25:41.376042+03
176	ABCD-04-22	pending	2022-12-27 16:25:41.381042+03
176	ABCD-05-22	pending	2022-12-29 16:25:41.385548+03
176	ABCD-06-22	pending	2022-12-26 16:25:41.390549+03
176	ABCD-07-22	pending	2022-12-26 16:25:41.395548+03
176	ABCD-08-22	pending	2022-12-29 16:25:41.399548+03
176	ABCD-09-22	pending	2022-12-30 16:25:41.404548+03
176	ABCD-10-22	pending	2022-12-30 16:25:41.409549+03
177	ABCD-01-22	pending	2022-12-29 16:25:41.414547+03
178	ABCD-01-22	pending	2022-12-27 16:25:41.419549+03
178	ABCD-02-22	pending	2022-12-27 16:25:41.423548+03
178	ABCD-03-22	pending	2022-12-28 16:25:41.428548+03
178	ABCD-04-22	pending	2022-12-28 16:25:41.432738+03
178	ABCD-05-22	pending	2022-12-30 16:25:41.437737+03
179	ABCD-01-22	pending	2022-12-29 16:25:41.442758+03
179	ABCD-02-22	pending	2022-12-28 16:25:41.447758+03
179	ABCD-03-22	pending	2022-12-26 16:25:41.453758+03
179	ABCD-04-22	pending	2022-12-26 16:25:41.458287+03
179	ABCD-05-22	pending	2022-12-30 16:25:41.463288+03
179	ABCD-06-22	pending	2022-12-26 16:25:41.468289+03
179	ABCD-07-22	pending	2022-12-28 16:25:41.474256+03
180	ABCD-01-22	pending	2022-12-26 16:25:41.478785+03
180	ABCD-02-22	pending	2022-12-29 16:25:41.483785+03
180	ABCD-03-22	pending	2022-12-26 16:25:41.488785+03
180	ABCD-04-22	pending	2022-12-27 16:25:41.492785+03
180	ABCD-05-22	pending	2022-12-28 16:25:41.497786+03
180	ABCD-06-22	pending	2022-12-27 16:25:41.502786+03
180	ABCD-07-22	pending	2022-12-26 16:25:41.507785+03
180	ABCD-08-22	pending	2022-12-26 16:25:41.511786+03
180	ABCD-09-22	pending	2022-12-26 16:25:41.517805+03
181	ABCD-01-22	pending	2022-12-28 16:25:41.522806+03
181	ABCD-02-22	pending	2022-12-26 16:25:41.526806+03
181	ABCD-03-22	pending	2022-12-26 16:25:41.532806+03
181	ABCD-04-22	pending	2022-12-29 16:25:41.537806+03
181	ABCD-05-22	pending	2022-12-26 16:25:41.542827+03
181	ABCD-06-22	pending	2022-12-30 16:25:41.547826+03
181	ABCD-07-22	pending	2022-12-30 16:25:41.552827+03
181	ABCD-08-22	pending	2022-12-30 16:25:41.557335+03
181	ABCD-09-22	pending	2022-12-29 16:25:41.562335+03
181	ABCD-10-22	pending	2022-12-29 16:25:41.568335+03
182	ABCD-01-22	pending	2022-12-29 16:25:41.573335+03
182	ABCD-02-22	pending	2022-12-27 16:25:41.578335+03
182	ABCD-03-22	pending	2022-12-30 16:25:41.583336+03
182	ABCD-04-22	pending	2022-12-30 16:25:41.587897+03
183	ABCD-01-22	pending	2022-12-27 16:25:41.592896+03
183	ABCD-02-22	pending	2022-12-28 16:25:41.597864+03
183	ABCD-03-22	pending	2022-12-27 16:25:41.601865+03
183	ABCD-04-22	pending	2022-12-29 16:25:41.610865+03
183	ABCD-05-22	pending	2022-12-30 16:25:41.615939+03
183	ABCD-06-22	pending	2022-12-30 16:25:41.620098+03
183	ABCD-07-22	pending	2022-12-27 16:25:41.625098+03
183	ABCD-08-22	pending	2022-12-26 16:25:41.630097+03
184	ABCD-01-22	pending	2022-12-30 16:25:41.634098+03
185	ABCD-01-22	pending	2022-12-28 16:25:41.639127+03
185	ABCD-02-22	pending	2022-12-26 16:25:41.644131+03
185	ABCD-03-22	pending	2022-12-30 16:25:41.648132+03
185	ABCD-04-22	pending	2022-12-29 16:25:41.653143+03
186	ABCD-01-22	pending	2022-12-27 16:25:41.657298+03
186	ABCD-02-22	pending	2022-12-29 16:25:41.662298+03
186	ABCD-03-22	pending	2022-12-27 16:25:41.667313+03
187	ABCD-01-22	pending	2022-12-28 16:25:41.672297+03
187	ABCD-02-22	pending	2022-12-26 16:25:41.676299+03
187	ABCD-03-22	pending	2022-12-27 16:25:41.68168+03
187	ABCD-04-22	pending	2022-12-30 16:25:41.686686+03
188	ABCD-01-22	pending	2022-12-26 16:25:41.691685+03
188	ABCD-02-22	pending	2022-12-26 16:25:41.69586+03
188	ABCD-03-22	pending	2022-12-29 16:25:41.700873+03
188	ABCD-04-22	pending	2022-12-26 16:25:41.705861+03
188	ABCD-05-22	pending	2022-12-30 16:25:41.709862+03
188	ABCD-06-22	pending	2022-12-28 16:25:41.71486+03
189	ABCD-01-22	pending	2022-12-26 16:25:41.719904+03
189	ABCD-02-22	pending	2022-12-28 16:25:41.724903+03
189	ABCD-03-22	pending	2022-12-27 16:25:41.728903+03
189	ABCD-04-22	pending	2022-12-30 16:25:41.733904+03
189	ABCD-05-22	pending	2022-12-30 16:25:41.738904+03
189	ABCD-06-22	pending	2022-12-28 16:25:41.743907+03
189	ABCD-07-22	pending	2022-12-29 16:25:41.747908+03
189	ABCD-08-22	pending	2022-12-28 16:25:41.75291+03
189	ABCD-09-22	pending	2022-12-30 16:25:41.758435+03
190	ABCD-01-22	pending	2022-12-30 16:25:41.762452+03
190	ABCD-02-22	pending	2022-12-28 16:25:41.767436+03
190	ABCD-03-22	pending	2022-12-28 16:25:41.772451+03
190	ABCD-04-22	pending	2022-12-28 16:25:41.776449+03
190	ABCD-05-22	pending	2022-12-30 16:25:41.781448+03
191	ABCD-01-22	pending	2022-12-30 16:25:41.786447+03
191	ABCD-02-22	pending	2022-12-29 16:25:41.791448+03
191	ABCD-03-22	pending	2022-12-28 16:25:41.796458+03
192	ABCD-01-22	pending	2022-12-27 16:25:41.801458+03
192	ABCD-02-22	pending	2022-12-26 16:25:41.805462+03
192	ABCD-03-22	pending	2022-12-28 16:25:41.810456+03
192	ABCD-04-22	pending	2022-12-26 16:25:41.816031+03
192	ABCD-05-22	pending	2022-12-28 16:25:41.820045+03
192	ABCD-06-22	pending	2022-12-27 16:25:41.825033+03
192	ABCD-07-22	pending	2022-12-27 16:25:41.830032+03
192	ABCD-08-22	pending	2022-12-29 16:25:41.836031+03
193	ABCD-01-22	pending	2022-12-28 16:25:41.841039+03
193	ABCD-02-22	pending	2022-12-29 16:25:41.84604+03
193	ABCD-03-22	pending	2022-12-28 16:25:41.85204+03
193	ABCD-04-22	pending	2022-12-29 16:25:41.85855+03
193	ABCD-05-22	pending	2022-12-30 16:25:41.86355+03
194	ABCD-01-22	pending	2022-12-27 16:25:41.868549+03
194	ABCD-02-22	pending	2022-12-30 16:25:41.87455+03
194	ABCD-03-22	pending	2022-12-28 16:25:41.87955+03
194	ABCD-04-22	pending	2022-12-26 16:25:41.884549+03
194	ABCD-05-22	pending	2022-12-29 16:25:41.889549+03
194	ABCD-06-22	pending	2022-12-26 16:25:41.89455+03
195	ABCD-01-22	pending	2022-12-29 16:25:41.900057+03
195	ABCD-02-22	pending	2022-12-29 16:25:41.905055+03
195	ABCD-03-22	pending	2022-12-29 16:25:41.910055+03
195	ABCD-04-22	pending	2022-12-30 16:25:41.915054+03
195	ABCD-05-22	pending	2022-12-29 16:25:41.920056+03
196	ABCD-01-22	pending	2022-12-26 16:25:41.928105+03
196	ABCD-02-22	pending	2022-12-26 16:25:41.933105+03
197	ABCD-01-22	pending	2022-12-30 16:25:41.938105+03
197	ABCD-02-22	pending	2022-12-29 16:25:41.943111+03
197	ABCD-03-22	pending	2022-12-27 16:25:41.949111+03
197	ABCD-04-22	pending	2022-12-27 16:25:41.95411+03
197	ABCD-05-22	pending	2022-12-29 16:25:41.959621+03
197	ABCD-06-22	pending	2022-12-30 16:25:41.964479+03
197	ABCD-07-22	pending	2022-12-27 16:25:41.969479+03
197	ABCD-08-22	pending	2022-12-30 16:25:41.974481+03
197	ABCD-09-22	pending	2022-12-29 16:25:41.979481+03
197	ABCD-10-22	pending	2022-12-27 16:25:41.98448+03
198	ABCD-01-22	pending	2022-12-26 16:25:41.989479+03
198	ABCD-02-22	pending	2022-12-30 16:25:41.993479+03
198	ABCD-03-22	pending	2022-12-27 16:25:41.998854+03
198	ABCD-04-22	pending	2022-12-30 16:25:42.003851+03
198	ABCD-05-22	pending	2022-12-27 16:25:42.007851+03
198	ABCD-06-22	pending	2022-12-29 16:25:42.012853+03
198	ABCD-07-22	pending	2022-12-28 16:25:42.017852+03
198	ABCD-08-22	pending	2022-12-26 16:25:42.023853+03
198	ABCD-09-22	pending	2022-12-26 16:25:42.028853+03
198	ABCD-10-22	pending	2022-12-27 16:25:42.032853+03
199	ABCD-01-22	pending	2022-12-27 16:25:42.03785+03
200	ABCD-01-22	pending	2022-12-26 16:25:42.04286+03
201	ABCD-01-22	pending	2022-12-27 16:25:42.047862+03
201	ABCD-02-22	pending	2022-12-26 16:25:42.05286+03
201	ABCD-03-22	pending	2022-12-30 16:25:42.05794+03
201	ABCD-04-22	pending	2022-12-29 16:25:42.061939+03
201	ABCD-05-22	pending	2022-12-28 16:25:42.067534+03
201	ABCD-06-22	pending	2022-12-27 16:25:42.072533+03
201	ABCD-07-22	pending	2022-12-26 16:25:42.077536+03
201	ABCD-08-22	pending	2022-12-26 16:25:42.081533+03
201	ABCD-09-22	pending	2022-12-27 16:25:42.086532+03
201	ABCD-10-22	pending	2022-12-28 16:25:42.091533+03
202	ABCD-01-22	pending	2022-12-30 16:25:42.096536+03
202	ABCD-02-22	pending	2022-12-30 16:25:42.100533+03
202	ABCD-03-22	pending	2022-12-26 16:25:42.105534+03
203	ABCD-01-22	pending	2022-12-26 16:25:42.110019+03
203	ABCD-02-22	pending	2022-12-26 16:25:42.11502+03
203	ABCD-03-22	pending	2022-12-28 16:25:42.12002+03
203	ABCD-04-22	pending	2022-12-26 16:25:42.125019+03
203	ABCD-05-22	pending	2022-12-30 16:25:42.130031+03
203	ABCD-06-22	pending	2022-12-30 16:25:42.135018+03
204	ABCD-01-22	pending	2022-12-30 16:25:42.139016+03
205	ABCD-01-22	pending	2022-12-26 16:25:42.144023+03
205	ABCD-02-22	pending	2022-12-27 16:25:42.150023+03
205	ABCD-03-22	pending	2022-12-30 16:25:42.156023+03
206	ABCD-01-22	pending	2022-12-26 16:25:42.160555+03
206	ABCD-02-22	pending	2022-12-30 16:25:42.165553+03
206	ABCD-03-22	pending	2022-12-27 16:25:42.170554+03
206	ABCD-04-22	pending	2022-12-28 16:25:42.175554+03
206	ABCD-05-22	pending	2022-12-30 16:25:42.180554+03
206	ABCD-06-22	pending	2022-12-27 16:25:42.185554+03
206	ABCD-07-22	pending	2022-12-30 16:25:42.190554+03
206	ABCD-08-22	pending	2022-12-29 16:25:42.195553+03
207	ABCD-01-22	pending	2022-12-28 16:25:42.200553+03
207	ABCD-02-22	pending	2022-12-28 16:25:42.204554+03
207	ABCD-03-22	pending	2022-12-28 16:25:42.209554+03
207	ABCD-04-22	pending	2022-12-28 16:25:42.214553+03
207	ABCD-05-22	pending	2022-12-30 16:25:42.219554+03
207	ABCD-06-22	pending	2022-12-27 16:25:42.22466+03
207	ABCD-07-22	pending	2022-12-28 16:25:42.230508+03
208	ABCD-01-22	pending	2022-12-26 16:25:42.236855+03
208	ABCD-02-22	pending	2022-12-27 16:25:42.242058+03
208	ABCD-03-22	pending	2022-12-26 16:25:42.248806+03
208	ABCD-04-22	pending	2022-12-29 16:25:42.253811+03
209	ABCD-01-22	pending	2022-12-26 16:25:42.259339+03
210	ABCD-01-22	pending	2022-12-27 16:25:42.268338+03
210	ABCD-02-22	pending	2022-12-27 16:25:42.274355+03
210	ABCD-03-22	pending	2022-12-28 16:25:42.279374+03
210	ABCD-04-22	pending	2022-12-30 16:25:42.284375+03
210	ABCD-05-22	pending	2022-12-26 16:25:42.290373+03
210	ABCD-06-22	pending	2022-12-26 16:25:42.295373+03
210	ABCD-07-22	pending	2022-12-27 16:25:42.300375+03
210	ABCD-08-22	pending	2022-12-27 16:25:42.305374+03
211	ABCD-01-22	pending	2022-12-27 16:25:42.310478+03
211	ABCD-02-22	pending	2022-12-26 16:25:42.315491+03
211	ABCD-03-22	pending	2022-12-27 16:25:42.320491+03
211	ABCD-04-22	pending	2022-12-26 16:25:42.32549+03
211	ABCD-05-22	pending	2022-12-30 16:25:42.330491+03
211	ABCD-06-22	pending	2022-12-30 16:25:42.334503+03
212	ABCD-01-22	pending	2022-12-29 16:25:42.339492+03
212	ABCD-02-22	pending	2022-12-30 16:25:42.344512+03
212	ABCD-03-22	pending	2022-12-27 16:25:42.349512+03
213	ABCD-01-22	pending	2022-12-29 16:25:42.354512+03
213	ABCD-02-22	pending	2022-12-30 16:25:42.360053+03
213	ABCD-03-22	pending	2022-12-30 16:25:42.365052+03
213	ABCD-04-22	pending	2022-12-29 16:25:42.369278+03
213	ABCD-05-22	pending	2022-12-30 16:25:42.374265+03
213	ABCD-06-22	pending	2022-12-26 16:25:42.379263+03
213	ABCD-07-22	pending	2022-12-29 16:25:42.385263+03
213	ABCD-08-22	pending	2022-12-27 16:25:42.390263+03
213	ABCD-09-22	pending	2022-12-28 16:25:42.395263+03
214	ABCD-01-22	pending	2022-12-29 16:25:42.400263+03
214	ABCD-02-22	pending	2022-12-27 16:25:42.405263+03
214	ABCD-03-22	pending	2022-12-26 16:25:42.409263+03
214	ABCD-04-22	pending	2022-12-28 16:25:42.414263+03
214	ABCD-05-22	pending	2022-12-29 16:25:42.419264+03
214	ABCD-06-22	pending	2022-12-28 16:25:42.424263+03
214	ABCD-07-22	pending	2022-12-27 16:25:42.428265+03
214	ABCD-08-22	pending	2022-12-29 16:25:42.433568+03
214	ABCD-09-22	pending	2022-12-29 16:25:42.438568+03
214	ABCD-10-22	pending	2022-12-27 16:25:42.443585+03
215	ABCD-01-22	pending	2022-12-29 16:25:42.448574+03
215	ABCD-02-22	pending	2022-12-29 16:25:42.454573+03
215	ABCD-03-22	pending	2022-12-26 16:25:42.460093+03
215	ABCD-04-22	pending	2022-12-27 16:25:42.465093+03
215	ABCD-05-22	pending	2022-12-30 16:25:42.470092+03
215	ABCD-06-22	pending	2022-12-28 16:25:42.476093+03
215	ABCD-07-22	pending	2022-12-28 16:25:42.481092+03
215	ABCD-08-22	pending	2022-12-28 16:25:42.485097+03
215	ABCD-09-22	pending	2022-12-30 16:25:42.490094+03
216	ABCD-01-22	pending	2022-12-28 16:25:42.495092+03
216	ABCD-02-22	pending	2022-12-26 16:25:42.500097+03
216	ABCD-03-22	pending	2022-12-27 16:25:42.505091+03
217	ABCD-01-22	pending	2022-12-30 16:25:42.511126+03
217	ABCD-02-22	pending	2022-12-28 16:25:42.516127+03
217	ABCD-03-22	pending	2022-12-28 16:25:42.520126+03
217	ABCD-04-22	pending	2022-12-26 16:25:42.525127+03
218	ABCD-01-22	pending	2022-12-26 16:25:42.530126+03
218	ABCD-02-22	pending	2022-12-26 16:25:42.535127+03
218	ABCD-03-22	pending	2022-12-28 16:25:42.540126+03
218	ABCD-04-22	pending	2022-12-30 16:25:42.545135+03
218	ABCD-05-22	pending	2022-12-29 16:25:42.550135+03
219	ABCD-01-22	pending	2022-12-26 16:25:42.555135+03
219	ABCD-02-22	pending	2022-12-27 16:25:42.560646+03
219	ABCD-03-22	pending	2022-12-29 16:25:42.565646+03
219	ABCD-04-22	pending	2022-12-30 16:25:42.571646+03
220	ABCD-01-22	pending	2022-12-26 16:25:42.577645+03
221	ABCD-01-22	pending	2022-12-30 16:25:42.583645+03
221	ABCD-02-22	pending	2022-12-27 16:25:42.589645+03
221	ABCD-03-22	pending	2022-12-26 16:25:42.594704+03
221	ABCD-04-22	pending	2022-12-28 16:25:42.599704+03
221	ABCD-05-22	pending	2022-12-29 16:25:42.604704+03
221	ABCD-06-22	pending	2022-12-30 16:25:42.609717+03
221	ABCD-07-22	pending	2022-12-29 16:25:42.613706+03
222	ABCD-01-22	pending	2022-12-29 16:25:42.618707+03
222	ABCD-02-22	pending	2022-12-29 16:25:42.623633+03
222	ABCD-03-22	pending	2022-12-29 16:25:42.628865+03
222	ABCD-04-22	pending	2022-12-30 16:25:42.633881+03
222	ABCD-05-22	pending	2022-12-26 16:25:42.638867+03
223	ABCD-01-22	pending	2022-12-26 16:25:42.643889+03
223	ABCD-02-22	pending	2022-12-30 16:25:42.647889+03
223	ABCD-03-22	pending	2022-12-30 16:25:42.652888+03
223	ABCD-04-22	pending	2022-12-26 16:25:42.658429+03
223	ABCD-05-22	pending	2022-12-27 16:25:42.662773+03
223	ABCD-06-22	pending	2022-12-30 16:25:42.667772+03
223	ABCD-07-22	pending	2022-12-29 16:25:42.672773+03
224	ABCD-01-22	pending	2022-12-27 16:25:42.677773+03
224	ABCD-02-22	pending	2022-12-30 16:25:42.682773+03
224	ABCD-03-22	pending	2022-12-27 16:25:42.687784+03
224	ABCD-04-22	pending	2022-12-26 16:25:42.692782+03
224	ABCD-05-22	pending	2022-12-26 16:25:42.697783+03
224	ABCD-06-22	pending	2022-12-26 16:25:42.702783+03
224	ABCD-07-22	pending	2022-12-26 16:25:42.707795+03
224	ABCD-08-22	pending	2022-12-26 16:25:42.712796+03
224	ABCD-09-22	pending	2022-12-28 16:25:42.717782+03
225	ABCD-01-22	pending	2022-12-29 16:25:42.722783+03
225	ABCD-02-22	pending	2022-12-27 16:25:42.727781+03
225	ABCD-03-22	pending	2022-12-27 16:25:42.732784+03
225	ABCD-04-22	pending	2022-12-28 16:25:42.737783+03
225	ABCD-05-22	pending	2022-12-28 16:25:42.742805+03
225	ABCD-06-22	pending	2022-12-30 16:25:42.746806+03
225	ABCD-07-22	pending	2022-12-29 16:25:42.751805+03
225	ABCD-08-22	pending	2022-12-30 16:25:42.756806+03
225	ABCD-09-22	pending	2022-12-26 16:25:42.761892+03
226	ABCD-01-22	pending	2022-12-28 16:25:42.766892+03
226	ABCD-02-22	pending	2022-12-27 16:25:42.771894+03
226	ABCD-03-22	pending	2022-12-29 16:25:42.776892+03
226	ABCD-04-22	pending	2022-12-28 16:25:42.781587+03
226	ABCD-05-22	pending	2022-12-28 16:25:42.786584+03
226	ABCD-06-22	pending	2022-12-29 16:25:42.791584+03
227	ABCD-01-22	pending	2022-12-27 16:25:42.796597+03
227	ABCD-02-22	pending	2022-12-29 16:25:42.839586+03
227	ABCD-03-22	pending	2022-12-30 16:25:42.846592+03
227	ABCD-04-22	pending	2022-12-30 16:25:42.852439+03
227	ABCD-05-22	pending	2022-12-26 16:25:42.856944+03
228	ABCD-01-22	pending	2022-12-29 16:25:42.861949+03
229	ABCD-01-22	pending	2022-12-26 16:25:42.866949+03
229	ABCD-02-22	pending	2022-12-28 16:25:42.871948+03
229	ABCD-03-22	pending	2022-12-28 16:25:42.877765+03
229	ABCD-04-22	pending	2022-12-28 16:25:42.882765+03
229	ABCD-05-22	pending	2022-12-26 16:25:42.887766+03
230	ABCD-01-22	pending	2022-12-28 16:25:42.892766+03
230	ABCD-02-22	pending	2022-12-27 16:25:42.898766+03
230	ABCD-03-22	pending	2022-12-27 16:25:42.904766+03
230	ABCD-04-22	pending	2022-12-26 16:25:42.909765+03
230	ABCD-05-22	pending	2022-12-26 16:25:42.915764+03
230	ABCD-06-22	pending	2022-12-28 16:25:42.920765+03
230	ABCD-07-22	pending	2022-12-28 16:25:42.926766+03
230	ABCD-08-22	pending	2022-12-27 16:25:42.931765+03
230	ABCD-09-22	pending	2022-12-29 16:25:42.937766+03
230	ABCD-10-22	pending	2022-12-27 16:25:42.942787+03
231	ABCD-01-22	pending	2022-12-28 16:25:42.948788+03
231	ABCD-02-22	pending	2022-12-28 16:25:42.954787+03
231	ABCD-03-22	pending	2022-12-27 16:25:42.960295+03
231	ABCD-04-22	pending	2022-12-29 16:25:42.966296+03
231	ABCD-05-22	pending	2022-12-26 16:25:42.972296+03
231	ABCD-06-22	pending	2022-12-28 16:25:42.978296+03
231	ABCD-07-22	pending	2022-12-30 16:25:42.984297+03
231	ABCD-08-22	pending	2022-12-29 16:25:42.990298+03
232	ABCD-01-22	pending	2022-12-26 16:25:42.996297+03
232	ABCD-02-22	pending	2022-12-28 16:25:43.001296+03
232	ABCD-03-22	pending	2022-12-26 16:25:43.007299+03
232	ABCD-04-22	pending	2022-12-30 16:25:43.013297+03
232	ABCD-05-22	pending	2022-12-30 16:25:43.019298+03
232	ABCD-06-22	pending	2022-12-27 16:25:43.026296+03
232	ABCD-07-22	pending	2022-12-27 16:25:43.032296+03
232	ABCD-08-22	pending	2022-12-26 16:25:43.037295+03
232	ABCD-09-22	pending	2022-12-30 16:25:43.043302+03
232	ABCD-10-22	pending	2022-12-29 16:25:43.049301+03
233	ABCD-01-22	pending	2022-12-28 16:25:43.054302+03
233	ABCD-02-22	pending	2022-12-26 16:25:43.059813+03
234	ABCD-01-22	pending	2022-12-28 16:25:43.064829+03
235	ABCD-01-22	pending	2022-12-29 16:25:43.069811+03
235	ABCD-02-22	pending	2022-12-27 16:25:43.074811+03
235	ABCD-03-22	pending	2022-12-29 16:25:43.079823+03
235	ABCD-04-22	pending	2022-12-27 16:25:43.085097+03
235	ABCD-05-22	pending	2022-12-27 16:25:43.090097+03
235	ABCD-06-22	pending	2022-12-28 16:25:43.095098+03
235	ABCD-07-22	pending	2022-12-30 16:25:43.099098+03
235	ABCD-08-22	pending	2022-12-28 16:25:43.104097+03
236	ABCD-01-22	pending	2022-12-26 16:25:43.109097+03
236	ABCD-02-22	pending	2022-12-27 16:25:43.114097+03
236	ABCD-03-22	pending	2022-12-27 16:25:43.119097+03
236	ABCD-04-22	pending	2022-12-30 16:25:43.124098+03
236	ABCD-05-22	pending	2022-12-30 16:25:43.129097+03
236	ABCD-06-22	pending	2022-12-30 16:25:43.133096+03
237	ABCD-01-22	pending	2022-12-29 16:25:43.138097+03
237	ABCD-02-22	pending	2022-12-28 16:25:43.143101+03
237	ABCD-03-22	pending	2022-12-28 16:25:43.148114+03
237	ABCD-04-22	pending	2022-12-26 16:25:43.153101+03
237	ABCD-05-22	pending	2022-12-27 16:25:43.158198+03
237	ABCD-06-22	pending	2022-12-29 16:25:43.162198+03
237	ABCD-07-22	pending	2022-12-28 16:25:43.167198+03
237	ABCD-08-22	pending	2022-12-27 16:25:43.172199+03
237	ABCD-09-22	pending	2022-12-30 16:25:43.177198+03
238	ABCD-01-22	pending	2022-12-29 16:25:43.182197+03
238	ABCD-02-22	pending	2022-12-26 16:25:43.187198+03
238	ABCD-03-22	pending	2022-12-30 16:25:43.192199+03
238	ABCD-04-22	pending	2022-12-30 16:25:43.197198+03
238	ABCD-05-22	pending	2022-12-26 16:25:43.202198+03
238	ABCD-06-22	pending	2022-12-27 16:25:43.207198+03
238	ABCD-07-22	pending	2022-12-30 16:25:43.211198+03
238	ABCD-08-22	pending	2022-12-29 16:25:43.217198+03
238	ABCD-09-22	pending	2022-12-30 16:25:43.22172+03
239	ABCD-01-22	pending	2022-12-26 16:25:43.226721+03
239	ABCD-02-22	pending	2022-12-27 16:25:43.231721+03
239	ABCD-03-22	pending	2022-12-26 16:25:43.23672+03
239	ABCD-04-22	pending	2022-12-28 16:25:43.242743+03
239	ABCD-05-22	pending	2022-12-29 16:25:43.247743+03
239	ABCD-06-22	pending	2022-12-29 16:25:43.252816+03
239	ABCD-07-22	pending	2022-12-30 16:25:43.25734+03
240	ABCD-01-22	pending	2022-12-30 16:25:43.262347+03
240	ABCD-02-22	pending	2022-12-30 16:25:43.268345+03
240	ABCD-03-22	pending	2022-12-27 16:25:43.273098+03
240	ABCD-04-22	pending	2022-12-28 16:25:43.278099+03
240	ABCD-05-22	pending	2022-12-30 16:25:43.284098+03
240	ABCD-06-22	pending	2022-12-29 16:25:43.290098+03
240	ABCD-07-22	pending	2022-12-30 16:25:43.296099+03
240	ABCD-08-22	pending	2022-12-28 16:25:43.302371+03
240	ABCD-09-22	pending	2022-12-26 16:25:43.307371+03
240	ABCD-10-22	pending	2022-12-26 16:25:43.312371+03
241	ABCD-01-22	pending	2022-12-26 16:25:43.317371+03
241	ABCD-02-22	pending	2022-12-27 16:25:43.321867+03
241	ABCD-03-22	pending	2022-12-26 16:25:43.326869+03
241	ABCD-04-22	pending	2022-12-30 16:25:43.331868+03
241	ABCD-05-22	pending	2022-12-28 16:25:43.335867+03
241	ABCD-06-22	pending	2022-12-28 16:25:43.340867+03
241	ABCD-07-22	pending	2022-12-28 16:25:43.345888+03
242	ABCD-01-22	pending	2022-12-29 16:25:43.350892+03
242	ABCD-02-22	pending	2022-12-27 16:25:43.355889+03
242	ABCD-03-22	pending	2022-12-30 16:25:43.361399+03
242	ABCD-04-22	pending	2022-12-27 16:25:43.366603+03
242	ABCD-05-22	pending	2022-12-28 16:25:43.371603+03
242	ABCD-06-22	pending	2022-12-29 16:25:43.376602+03
242	ABCD-07-22	pending	2022-12-28 16:25:43.382603+03
242	ABCD-08-22	pending	2022-12-28 16:25:43.386603+03
243	ABCD-01-22	pending	2022-12-27 16:25:43.392605+03
243	ABCD-02-22	pending	2022-12-29 16:25:43.397603+03
243	ABCD-03-22	pending	2022-12-26 16:25:43.402656+03
244	ABCD-01-22	pending	2022-12-30 16:25:43.407656+03
244	ABCD-02-22	pending	2022-12-27 16:25:43.412656+03
244	ABCD-03-22	pending	2022-12-30 16:25:43.417656+03
244	ABCD-04-22	pending	2022-12-30 16:25:43.422656+03
245	ABCD-01-22	pending	2022-12-28 16:25:43.427656+03
245	ABCD-02-22	pending	2022-12-30 16:25:43.43177+03
245	ABCD-03-22	pending	2022-12-27 16:25:43.436769+03
245	ABCD-04-22	pending	2022-12-26 16:25:43.44177+03
245	ABCD-05-22	pending	2022-12-26 16:25:43.446775+03
245	ABCD-06-22	pending	2022-12-26 16:25:43.452776+03
245	ABCD-07-22	pending	2022-12-30 16:25:43.458285+03
245	ABCD-08-22	pending	2022-12-26 16:25:43.463284+03
246	ABCD-01-22	pending	2022-12-28 16:25:43.468284+03
246	ABCD-02-22	pending	2022-12-30 16:25:43.473285+03
246	ABCD-03-22	pending	2022-12-29 16:25:43.478308+03
246	ABCD-04-22	pending	2022-12-28 16:25:43.483307+03
246	ABCD-05-22	pending	2022-12-30 16:25:43.488387+03
246	ABCD-06-22	pending	2022-12-28 16:25:43.493394+03
246	ABCD-07-22	pending	2022-12-30 16:25:43.498394+03
247	ABCD-01-22	pending	2022-12-27 16:25:43.503405+03
247	ABCD-02-22	pending	2022-12-28 16:25:43.508392+03
247	ABCD-03-22	pending	2022-12-28 16:25:43.513393+03
247	ABCD-04-22	pending	2022-12-26 16:25:43.518394+03
247	ABCD-05-22	pending	2022-12-28 16:25:43.523392+03
247	ABCD-06-22	pending	2022-12-28 16:25:43.527966+03
247	ABCD-07-22	pending	2022-12-30 16:25:43.532967+03
247	ABCD-08-22	pending	2022-12-28 16:25:43.537968+03
247	ABCD-09-22	pending	2022-12-26 16:25:43.542988+03
247	ABCD-10-22	pending	2022-12-28 16:25:43.547987+03
248	ABCD-01-22	pending	2022-12-30 16:25:43.552987+03
\.


--
-- Data for Name: task; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task (id, teacher_user_id, teacher_role, teacher_discipline_id, title, description, create_date) FROM stdin;
1	2	practicioner	1	Task[1]. Great near affect attack watch.	Then bag bill also.	2022-12-25 16:25:36.365915+03
2	3	practicioner	5	Task[2]. Laugh gun successful note according.	Garden leave religious party parent each word.	2022-12-25 16:25:36.374604+03
3	4	practicioner	4	Task[3]. Church exist low receive pull today.	Letter use successful.	2022-12-25 16:25:36.381963+03
4	5	practicioner	3	Task[4]. Drive into age you current product man.	Out high it include consider song people significant.	2022-12-25 16:25:36.388508+03
5	6	lecturer	4	Task[5]. Operation cut sit opportunity security party medical expert.	Happy style feeling establish teach serve herself.	2022-12-25 16:25:36.395116+03
6	7	lecturer	4	Task[6]. Color world feel put history discussion.	Executive including answer.	2022-12-25 16:25:36.401839+03
7	8	practicioner	2	Task[7]. Central finally water likely third.	Tough attorney prepare support away.	2022-12-25 16:25:36.408252+03
8	9	practicioner	1	Task[8]. Adult model claim challenge music decade seven where.	Fill interview agreement conference hear.	2022-12-25 16:25:36.41451+03
9	10	practicioner	3	Task[9]. Ago trade bit decade teacher raise read toward.	View mother wear maintain describe answer bank.	2022-12-25 16:25:36.420856+03
10	11	lecturer	4	Task[10]. Morning tell a model speech mother much.	Business model though.	2022-12-25 16:25:36.427173+03
11	12	lecturer	2	Task[11]. Never he decade data nation success.	Hit prepare move she.	2022-12-25 16:25:36.433938+03
12	13	practicioner	4	Task[12]. Test size yeah spring memory really.	On PM just significant alone.	2022-12-25 16:25:36.441061+03
13	14	practicioner	5	Task[13]. Allow participant skin fast.	Family town common avoid reveal.	2022-12-25 16:25:36.44799+03
14	15	lecturer	1	Task[14]. Evening surface mention building market music behavior.	Speak about moment born later performance change act.	2022-12-25 16:25:36.454899+03
15	16	practicioner	3	Task[15]. Technology individual especially.	Run chair organization while reality.	2022-12-25 16:25:36.461232+03
16	17	practicioner	5	Task[16]. Gun result education miss quite wish hand.	Send property natural.	2022-12-25 16:25:36.467525+03
17	18	practicioner	1	Task[17]. Parent add produce management career test raise.	Fish only successful write least.	2022-12-25 16:25:36.473773+03
18	19	practicioner	4	Task[18]. Many practice avoid door oil degree.	Grow fill challenge anyone grow later.	2022-12-25 16:25:36.479641+03
19	20	practicioner	4	Task[19]. Cold compare career small expert peace.	Certainly body economy ground however customer.	2022-12-25 16:25:36.485546+03
20	21	practicioner	4	Task[20]. Me order modern factor way most these effect.	Fund conference until able with area understand.	2022-12-25 16:25:36.491084+03
21	22	lecturer	6	Task[21]. Benefit treatment bag like.	Party federal season candidate scientist challenge certainly.	2022-12-25 16:25:36.496458+03
22	23	practicioner	4	Task[22]. Girl while light organization should learn player.	Heart TV line hit man quality strong hotel.	2022-12-25 16:25:36.502194+03
23	24	lecturer	3	Task[23]. Return trial expect continue or or.	Fire discover quality last we candidate.	2022-12-25 16:25:36.507586+03
24	25	lecturer	2	Task[24]. Yes matter adult sense from.	Short difference close your common.	2022-12-25 16:25:36.513032+03
25	26	practicioner	5	Task[25]. Hand team also.	Marriage such brother book difficult strong.	2022-12-25 16:25:36.519319+03
26	27	practicioner	1	Task[26]. Professor city expect hope school more account.	Special institution everybody election shake democratic while.	2022-12-25 16:25:36.524638+03
27	28	practicioner	5	Task[27]. Often station wide war rest team.	Him true number present response dark.	2022-12-25 16:25:36.530105+03
28	29	lecturer	4	Task[28]. System third dinner beautiful call research.	More whole manage cold our raise minute test.	2022-12-25 16:25:36.536263+03
29	30	practicioner	5	Task[29]. Such fear almost four over those.	Adult heart the push whether blood this cold.	2022-12-25 16:25:36.541897+03
30	31	practicioner	5	Task[30]. Reveal suddenly onto effect ever attack.	Choose PM likely same century role hour.	2022-12-25 16:25:36.547798+03
31	32	practicioner	3	Task[31]. Letter sea feeling control here ability answer attorney.	Out training international prepare cold matter.	2022-12-25 16:25:36.55704+03
32	33	lecturer	6	Task[32]. Parent member series weight morning chair others standard.	With own give.	2022-12-25 16:25:36.562745+03
33	34	lecturer	3	Task[33]. Economy new base along card white color.	Wrong career inside move show.	2022-12-25 16:25:36.568166+03
34	35	practicioner	3	Task[34]. How always remain guess fast.	Bar them get realize.	2022-12-25 16:25:36.574083+03
35	36	practicioner	5	Task[35]. Lose husband onto main.	Education now they wish machine movement team mother.	2022-12-25 16:25:36.580599+03
36	37	practicioner	1	Task[36]. Exist also need success painting sport fact.	Example care similar take.	2022-12-25 16:25:36.587082+03
37	38	lecturer	1	Task[37]. Rich old price local.	Heavy learn write member yet.	2022-12-25 16:25:36.593176+03
38	39	lecturer	1	Task[38]. Alone at team dog account.	Stay or successful approach.	2022-12-25 16:25:36.599473+03
39	40	practicioner	5	Task[39]. Hundred sense service population.	Official decade knowledge eight Republican seek reality.	2022-12-25 16:25:36.605731+03
40	41	practicioner	6	Task[40]. Artist record fly than.	Last it television cold.	2022-12-25 16:25:36.612324+03
41	42	lecturer	6	Task[41]. Will institution test home.	Must thought ground culture major build.	2022-12-25 16:25:36.618649+03
42	43	practicioner	3	Task[42]. All business send area.	Must good run world end fill none.	2022-12-25 16:25:36.625271+03
43	44	lecturer	6	Task[43]. Region policy break soldier.	True alone system nor board side do.	2022-12-25 16:25:36.631578+03
44	45	practicioner	4	Task[44]. Make child less itself international defense movement history.	Car special you and daughter long during feel.	2022-12-25 16:25:36.638409+03
45	46	practicioner	3	Task[45]. Stop probably easy determine travel image behind.	Financial prevent officer cause.	2022-12-25 16:25:36.645069+03
46	47	practicioner	4	Task[46]. Worry month free anything city simple draw.	Too suffer contain civil paper.	2022-12-25 16:25:36.651854+03
47	48	lecturer	1	Task[47]. Certain peace oil there.	Company expect raise market material once century.	2022-12-25 16:25:36.658552+03
48	49	lecturer	1	Task[48]. Break too small describe.	Mention attorney especially director.	2022-12-25 16:25:36.664842+03
49	50	lecturer	6	Task[49]. Low ok culture night.	Meet provide already attention article.	2022-12-25 16:25:36.671306+03
50	51	lecturer	6	Task[50]. Only store election fast through degree.	Film weight issue several people toward.	2022-12-25 16:25:36.677696+03
51	52	practicioner	1	Task[51]. Instead court describe others.	Political behind home any pattern write.	2022-12-25 16:25:36.683388+03
52	53	practicioner	4	Task[52]. Early trip share form evening determine sing.	Consider forward early market radio here.	2022-12-25 16:25:36.688919+03
53	54	lecturer	5	Task[53]. Leader early business yes.	Morning source example test.	2022-12-25 16:25:36.695278+03
54	55	practicioner	3	Task[54]. Successful idea life impact view board.	Appear maybe top mission father campaign.	2022-12-25 16:25:36.70084+03
55	56	practicioner	2	Task[55]. College happen card.	The cell real raise deal value its prevent.	2022-12-25 16:25:36.706394+03
56	57	practicioner	6	Task[56]. Large safe call reveal.	Involve less contain live safe board.	2022-12-25 16:25:36.711864+03
57	58	lecturer	5	Task[57]. Example data agent pattern.	Attack sport house popular whole everyone.	2022-12-25 16:25:36.717276+03
58	59	practicioner	2	Task[58]. Cost voice be test wrong.	Cause into year enough total safe home.	2022-12-25 16:25:36.722785+03
59	60	practicioner	4	Task[59]. Admit end much western resource out.	Pick several group site.	2022-12-25 16:25:36.728223+03
60	61	practicioner	2	Task[60]. Teacher stuff political forget open.	None with well agreement occur adult hard discussion.	2022-12-25 16:25:36.733807+03
61	62	lecturer	2	Task[61]. Century care claim civil hour.	Before herself song continue anyone about.	2022-12-25 16:25:36.739299+03
62	63	lecturer	4	Task[62]. How ground require stage book husband.	Focus television son fact one tough.	2022-12-25 16:25:36.744584+03
63	64	practicioner	2	Task[63]. Catch thousand economic hour.	Name reason later run pass.	2022-12-25 16:25:36.750192+03
64	65	practicioner	2	Task[64]. Child part case according.	To next away group situation detail.	2022-12-25 16:25:36.755677+03
65	66	practicioner	4	Task[65]. Fund occur street sense its green.	Enjoy per include hit practice deep feel.	2022-12-25 16:25:36.761029+03
66	67	practicioner	6	Task[66]. Technology any leader if between ready play room.	Call language carry Republican may.	2022-12-25 16:25:36.766845+03
67	68	practicioner	2	Task[67]. Practice art science cover prove follow.	Call discuss mother wall.	2022-12-25 16:25:36.772619+03
68	69	practicioner	2	Task[68]. Talk including outside increase network born.	Green personal pay between message manager against be.	2022-12-25 16:25:36.778601+03
69	70	lecturer	1	Task[69]. Establish will agent debate community service sea.	Direction sister change.	2022-12-25 16:25:36.785646+03
70	71	lecturer	5	Task[70]. Improve top hospital main book trade.	So she military religious technology.	2022-12-25 16:25:36.791709+03
71	72	practicioner	1	Task[71]. Father significant his modern for.	Read owner miss why may.	2022-12-25 16:25:36.798413+03
72	73	practicioner	6	Task[72]. Put cell report.	That among city decision.	2022-12-25 16:25:36.804902+03
73	74	practicioner	5	Task[73]. Use popular although under my billion.	Such measure its choice easy note miss.	2022-12-25 16:25:36.811209+03
74	75	lecturer	1	Task[74]. Account style manager statement.	Firm skill available.	2022-12-25 16:25:36.817917+03
75	76	practicioner	4	Task[75]. Set marriage bill seat identify technology.	Test team fly administration religious behind.	2022-12-25 16:25:36.824554+03
76	77	practicioner	1	Task[76]. Relate should whom reach opportunity about.	Piece realize country scene eye.	2022-12-25 16:25:36.830874+03
77	78	practicioner	2	Task[77]. Herself daughter amount I sea stock.	Radio claim stuff.	2022-12-25 16:25:36.837401+03
78	79	practicioner	3	Task[78]. Reason check analysis common community.	Child positive ask police keep.	2022-12-25 16:25:36.843508+03
79	80	lecturer	4	Task[79]. Whom bad meet brother site institution expect.	Always for wall many move.	2022-12-25 16:25:36.850387+03
80	81	practicioner	6	Task[80]. Join my film behavior summer plan environment campaign.	Final soldier person action cause behavior.	2022-12-25 16:25:36.856895+03
81	82	practicioner	2	Task[81]. Hand training him tree term.	Chair resource with.	2022-12-25 16:25:36.863913+03
82	83	lecturer	2	Task[82]. Visit professor whatever toward traditional from since.	Girl interest social skill drive travel accept artist.	2022-12-25 16:25:36.870733+03
83	84	practicioner	6	Task[83]. Often allow door sound these others five.	Race professional decide treat hair test general.	2022-12-25 16:25:36.877165+03
84	85	practicioner	3	Task[84]. Entire ground decide trouble never bit by.	Employee choose ever world along answer north.	2022-12-25 16:25:36.883391+03
85	86	lecturer	1	Task[85]. Drug food serious dinner pass chance put each.	Note ok day save listen among.	2022-12-25 16:25:36.889354+03
86	87	practicioner	4	Task[86]. Property coach protect.	Beat plant especially public around.	2022-12-25 16:25:36.894914+03
87	88	practicioner	2	Task[87]. Especially training property certainly point series leg PM.	Open couple ten blood.	2022-12-25 16:25:36.90017+03
88	89	practicioner	1	Task[88]. With not certainly power.	Wind concern use strong open method small those.	2022-12-25 16:25:36.905669+03
89	90	lecturer	5	Task[89]. Friend else thus dark edge sign effect.	Floor assume quickly allow.	2022-12-25 16:25:36.911123+03
90	91	practicioner	5	Task[90]. Anything sense example discuss business couple.	Arrive sit red away coach magazine study all.	2022-12-25 16:25:36.916636+03
91	92	lecturer	3	Task[91]. Thank set meeting enough person attack instead.	Bank during career.	2022-12-25 16:25:36.922068+03
92	93	practicioner	5	Task[92]. Spend state hotel doctor.	Yet coach appear point walk strong.	2022-12-25 16:25:36.927532+03
93	94	practicioner	5	Task[93]. Capital measure our control wait bring third.	Need well study describe require.	2022-12-25 16:25:36.932872+03
94	95	practicioner	5	Task[94]. Particularly as owner word call price contain.	Agree brother accept body since push.	2022-12-25 16:25:36.939286+03
95	96	lecturer	1	Task[95]. Name perform clear poor performance.	All student put enter continue base realize.	2022-12-25 16:25:36.945253+03
96	97	lecturer	4	Task[96]. Hear couple attorney per past thank president.	Fire include current simply final.	2022-12-25 16:25:36.950895+03
97	98	practicioner	1	Task[97]. Nice image well next car.	Nature response identify address organization spring purpose office.	2022-12-25 16:25:36.95666+03
98	99	lecturer	2	Task[98]. Discover child radio develop.	Building direction ability such actually role among.	2022-12-25 16:25:36.962308+03
99	100	lecturer	1	Task[99]. Back very reason level mention something.	Four security similar.	2022-12-25 16:25:36.967503+03
100	101	practicioner	2	Task[100]. Pay high country myself.	Full go find space create.	2022-12-25 16:25:36.972872+03
101	102	practicioner	2	Task[101]. Use yes rest several court wonder than.	Front back each yourself though political catch career.	2022-12-25 16:25:36.978748+03
102	103	lecturer	2	Task[102]. Same lay nice thing nothing feeling.	Stock receive born work street.	2022-12-25 16:25:36.984828+03
103	104	lecturer	6	Task[103]. Million Republican very inside.	True involve statement mother.	2022-12-25 16:25:36.991331+03
104	105	practicioner	1	Task[104]. Early ball season member.	Vote himself who continue throw.	2022-12-25 16:25:36.997843+03
105	106	practicioner	1	Task[105]. Now newspaper whom certainly mother effort all.	Break public its likely.	2022-12-25 16:25:37.004119+03
106	107	lecturer	6	Task[106]. Republican maintain next pull issue lose happy.	Child middle behind benefit official near upon.	2022-12-25 16:25:37.010517+03
107	108	lecturer	4	Task[107]. Debate will tough other need million return member.	Require find position room especially.	2022-12-25 16:25:37.017041+03
108	109	practicioner	6	Task[108]. Face area very staff blue.	Way single property firm lose police.	2022-12-25 16:25:37.023683+03
109	110	lecturer	5	Task[109]. Measure idea most which she.	Similar order woman energy plant recognize when.	2022-12-25 16:25:37.030067+03
110	111	practicioner	4	Task[110]. Remain coach our issue wind sense leader race.	Player such say several scientist around make.	2022-12-25 16:25:37.036775+03
111	112	lecturer	1	Task[111]. Place analysis degree second.	Spring when who property.	2022-12-25 16:25:37.043767+03
112	113	practicioner	4	Task[112]. Specific forward factor coach consumer.	Together carry himself probably peace tonight not.	2022-12-25 16:25:37.050739+03
113	114	lecturer	1	Task[113]. Increase some light size daughter very.	Later institution great safe team everybody general including.	2022-12-25 16:25:37.057403+03
114	115	practicioner	1	Task[114]. Least lead company threat safe north.	Upon security picture very arrive.	2022-12-25 16:25:37.064159+03
115	116	practicioner	1	Task[115]. Cup wonder pull him much specific value.	Art operation make executive gas.	2022-12-25 16:25:37.070654+03
116	117	practicioner	2	Task[116]. Collection oil fund herself hospital of.	Which huge in break rock.	2022-12-25 16:25:37.077079+03
117	118	lecturer	1	Task[117]. Attack result drive student reflect.	Film black care stay daughter.	2022-12-25 16:25:37.083076+03
118	119	practicioner	4	Task[118]. Later heart hair deep.	Huge seat development condition suffer month measure.	2022-12-25 16:25:37.088963+03
119	120	practicioner	2	Task[119]. Despite firm partner those.	Blue family stock attack ten yeah.	2022-12-25 16:25:37.094507+03
120	121	lecturer	1	Task[120]. Choose admit job might artist evening.	Rule health indeed coach.	2022-12-25 16:25:37.100563+03
121	122	practicioner	4	Task[121]. Bit themselves bring.	Democrat large budget.	2022-12-25 16:25:37.105954+03
122	123	practicioner	3	Task[122]. Style commercial know financial.	Far agree consider this these.	2022-12-25 16:25:37.111078+03
123	124	lecturer	1	Task[123]. Wish blood prove sense.	Fund order play drive.	2022-12-25 16:25:37.11676+03
124	125	practicioner	2	Task[124]. Career break side standard.	Low over history window white adult western green.	2022-12-25 16:25:37.12196+03
125	126	practicioner	1	Task[125]. Interest edge win wall treat lot must.	Test military wide reflect site.	2022-12-25 16:25:37.127042+03
126	127	practicioner	3	Task[126]. Truth whether paper agent or structure section.	Event college number trip this than reflect.	2022-12-25 16:25:37.133253+03
127	128	lecturer	2	Task[127]. Believe focus rule table why baby.	Attorney respond across pretty.	2022-12-25 16:25:37.139428+03
128	129	practicioner	5	Task[128]. Issue step positive grow policy.	Fear only song adult listen loss raise.	2022-12-25 16:25:37.145314+03
129	130	practicioner	6	Task[129]. Administration eat ahead candidate song good resource this.	Whose political simple same senior free.	2022-12-25 16:25:37.151267+03
130	131	practicioner	3	Task[130]. Top and American opportunity sing Republican meet radio.	Matter report institution one stage.	2022-12-25 16:25:37.156656+03
131	132	lecturer	2	Task[131]. Billion deep financial summer would various evidence fire.	Long receive rather second economic never specific.	2022-12-25 16:25:37.162002+03
132	133	practicioner	6	Task[132]. Writer staff move join evening.	Process camera house someone third note beautiful.	2022-12-25 16:25:37.167387+03
133	134	practicioner	2	Task[133]. Far place sport.	Degree fund over yard road.	2022-12-25 16:25:37.172618+03
134	135	practicioner	5	Task[134]. Industry seven pretty wall national.	Rate around onto suddenly performance later.	2022-12-25 16:25:37.177813+03
135	136	practicioner	4	Task[135]. Blood real beautiful.	Onto offer between sure mission on within.	2022-12-25 16:25:37.183256+03
136	137	lecturer	6	Task[136]. Prevent yes skin.	Daughter themselves page head reach.	2022-12-25 16:25:37.189044+03
137	138	lecturer	5	Task[137]. Whom entire mind.	Possible recognize affect hundred.	2022-12-25 16:25:37.194962+03
138	139	lecturer	4	Task[138]. Difference model degree cultural blood discussion environmental.	To pattern only and.	2022-12-25 16:25:37.201092+03
139	140	practicioner	6	Task[139]. Together look learn with enjoy trial.	Note husband difference carry story trouble.	2022-12-25 16:25:37.207903+03
140	141	practicioner	5	Task[140]. Make low fine key scene first network.	Skin group again buy coach end.	2022-12-25 16:25:37.214632+03
141	142	practicioner	1	Task[141]. Where hundred hear world popular should.	Never network happen similar ahead decade.	2022-12-25 16:25:37.221287+03
142	143	lecturer	1	Task[142]. Say away develop listen require.	Report pretty social exist how school hundred article.	2022-12-25 16:25:37.228898+03
143	144	practicioner	3	Task[143]. Two type hot back.	Education head win open water hold.	2022-12-25 16:25:37.236643+03
144	145	lecturer	6	Task[144]. Least only its once real skin.	Task game develop financial toward project treat find.	2022-12-25 16:25:37.244014+03
145	146	practicioner	2	Task[145]. Purpose material about identify.	Investment serve collection before.	2022-12-25 16:25:37.251223+03
146	147	lecturer	1	Task[146]. Book carry entire rich large.	Far risk quickly peace.	2022-12-25 16:25:37.257998+03
147	148	practicioner	6	Task[147]. Per support interest high ago.	Director general mouth note least.	2022-12-25 16:25:37.264142+03
148	149	practicioner	1	Task[148]. Discussion remember drug fall really make.	Story reason generation show most moment among.	2022-12-25 16:25:37.270659+03
149	150	lecturer	5	Task[149]. Return old however through now expect.	Every politics role seven beyond because movement.	2022-12-25 16:25:37.277365+03
150	151	practicioner	1	Task[150]. Single protect few place family seem of possible.	Night paper wall have series worker build.	2022-12-25 16:25:37.284001+03
151	152	lecturer	2	Task[151]. Claim middle enter radio coach.	Line do response coach.	2022-12-25 16:25:37.290762+03
152	153	practicioner	2	Task[152]. Color produce true organization minute only theory involve.	Sport once fast back.	2022-12-25 16:25:37.296274+03
153	154	practicioner	6	Task[153]. Admit bed treatment word increase avoid.	Media week century know.	2022-12-25 16:25:37.302015+03
154	155	lecturer	4	Task[154]. Item somebody explain growth free according.	Most southern much surface.	2022-12-25 16:25:37.30793+03
155	156	practicioner	4	Task[155]. Usually short Mr nature.	Within under nation turn security.	2022-12-25 16:25:37.313287+03
156	157	lecturer	2	Task[156]. Rock life unit read former require shoulder.	Past establish tough.	2022-12-25 16:25:37.318883+03
157	158	practicioner	6	Task[157]. Over college strong everyone two.	Central shoulder just yard box.	2022-12-25 16:25:37.324573+03
158	159	lecturer	5	Task[158]. Effect listen manager group couple along nation.	Congress thought bit most.	2022-12-25 16:25:37.330379+03
159	160	practicioner	3	Task[159]. Require determine understand coach.	Staff arrive young stock notice black realize change.	2022-12-25 16:25:37.336528+03
160	161	practicioner	5	Task[160]. Mean eye claim close office including would.	Hot during team claim rich particular.	2022-12-25 16:25:37.342532+03
161	162	practicioner	3	Task[161]. Thus smile might.	Stop month still pass arrive happen.	2022-12-25 16:25:37.349617+03
162	163	lecturer	3	Task[162]. Official federal stuff there piece important.	Save respond risk media.	2022-12-25 16:25:37.356796+03
163	164	practicioner	3	Task[163]. Hard three pay perhaps get floor.	Also involve yes.	2022-12-25 16:25:37.363306+03
164	165	practicioner	6	Task[164]. Eat right vote evening result conference.	Show thing different.	2022-12-25 16:25:37.370572+03
165	166	practicioner	5	Task[165]. Be fall child that clear house.	Around baby make major phone about.	2022-12-25 16:25:37.377194+03
166	167	lecturer	3	Task[166]. Doctor themselves certain pull effort value.	Blood lay prepare above five wife run whom.	2022-12-25 16:25:37.383981+03
167	168	practicioner	2	Task[167]. Others develop miss young write western staff room.	Cost turn amount fine large build computer.	2022-12-25 16:25:37.390543+03
168	169	practicioner	2	Task[168]. Both million quality hope.	Past let special.	2022-12-25 16:25:37.397293+03
169	170	practicioner	5	Task[169]. Improve between tonight example end enjoy party.	Manager as reach nation computer clearly blood.	2022-12-25 16:25:37.403923+03
170	171	lecturer	6	Task[170]. Trip material especially rest bed anyone.	Street just civil.	2022-12-25 16:25:37.410656+03
171	172	practicioner	4	Task[171]. Soon somebody yet significant us.	Direction career news deal.	2022-12-25 16:25:37.417846+03
172	173	practicioner	3	Task[172]. Personal democratic dark arm drop leave sometimes.	Current then person thus minute level behavior.	2022-12-25 16:25:37.424758+03
173	174	practicioner	2	Task[173]. Any whose Republican someone affect check national require.	Fall door teach five yard parent finish.	2022-12-25 16:25:37.432225+03
174	175	lecturer	6	Task[174]. Several agent development trial draw cold stand officer.	Through be the drive.	2022-12-25 16:25:37.439112+03
175	176	practicioner	5	Task[175]. Course pull discover as hope the stuff.	House task certainly hit executive remain the.	2022-12-25 16:25:37.446402+03
176	177	practicioner	3	Task[176]. Rock time you everyone tend near.	Reveal boy across thousand.	2022-12-25 16:25:37.453764+03
177	178	lecturer	1	Task[177]. Though worry run.	Way area analysis head heavy also.	2022-12-25 16:25:37.460692+03
178	179	practicioner	5	Task[178]. Learn at fund marriage moment.	Financial responsibility field again determine discuss character.	2022-12-25 16:25:37.467549+03
179	180	practicioner	4	Task[179]. Low tend control western story physical both cup.	Almost who information there lawyer woman sort.	2022-12-25 16:25:37.474281+03
180	181	practicioner	1	Task[180]. Middle mission must at also someone some.	Pm remain language draw.	2022-12-25 16:25:37.480594+03
181	182	lecturer	1	Task[181]. Might table people brother report.	Drug item our protect news ok performance.	2022-12-25 16:25:37.48729+03
182	183	lecturer	2	Task[182]. Me provide medical home environmental.	Production care simply grow director.	2022-12-25 16:25:37.49391+03
183	184	practicioner	2	Task[183]. Sport certain dream field maintain role.	Chance wrong wear recently.	2022-12-25 16:25:37.500312+03
184	185	lecturer	2	Task[184]. During show deep fill mouth money.	Sport power live it.	2022-12-25 16:25:37.50625+03
185	186	practicioner	2	Task[185]. Itself culture here figure significant test.	Admit board situation each important.	2022-12-25 16:25:37.512526+03
186	187	practicioner	4	Task[186]. Already discussion look pull purpose commercial.	They second ability shake institution.	2022-12-25 16:25:37.518021+03
187	188	practicioner	4	Task[187]. International same investment see series.	Billion agreement consider respond out bring.	2022-12-25 16:25:37.523789+03
188	189	practicioner	3	Task[188]. Prove wear market leader maintain also yet.	Little arrive drive reveal energy color majority.	2022-12-25 16:25:37.530108+03
189	190	lecturer	6	Task[189]. Night statement page old majority.	Ground shake food child.	2022-12-25 16:25:37.535685+03
190	191	practicioner	5	Task[190]. Everything report if large business.	Everyone knowledge wait.	2022-12-25 16:25:37.541635+03
191	192	lecturer	6	Task[191]. State future process life consider along.	Wide check exist in great understand.	2022-12-25 16:25:37.547413+03
192	193	lecturer	5	Task[192]. Return black red kitchen consider couple loss eight.	Good culture type hit challenge mean institution.	2022-12-25 16:25:37.55299+03
193	194	lecturer	4	Task[193]. Year exactly often.	Term something court particularly.	2022-12-25 16:25:37.559605+03
194	195	lecturer	1	Task[194]. Better possible inside hospital citizen.	Alone no window onto lawyer.	2022-12-25 16:25:37.565444+03
195	196	practicioner	2	Task[195]. Check word build central less generation stuff.	Cell almost attack quite without really attorney.	2022-12-25 16:25:37.571104+03
196	197	practicioner	4	Task[196]. Consider oil prepare no.	Stop generation second just church remain.	2022-12-25 16:25:37.578799+03
197	198	practicioner	3	Task[197]. Light especially city discussion effort change day.	Loss ok agree cell guy.	2022-12-25 16:25:37.587561+03
198	199	lecturer	6	Task[198]. Itself more lead attorney party.	Admit I sign day.	2022-12-25 16:25:37.594453+03
199	200	lecturer	2	Task[199]. Skill employee they many recently ahead reflect thank.	Record threat market buy suddenly green truth.	2022-12-25 16:25:37.601615+03
200	201	lecturer	2	Task[200]. Pay ball house treat party rest rate.	Method relate meet lead present show.	2022-12-25 16:25:37.609794+03
201	202	practicioner	4	Task[201]. Leader sense series morning loss.	Tend shoulder front computer concern high trip us.	2022-12-25 16:25:37.617231+03
202	203	lecturer	1	Task[202]. Adult produce choose control total project clear.	Thus sit soldier popular fast get room grow.	2022-12-25 16:25:37.624461+03
203	204	practicioner	3	Task[203]. Peace figure pretty.	Natural national capital player low baby so reduce.	2022-12-25 16:25:37.63185+03
204	205	lecturer	5	Task[204]. Care blue stay like.	Generation trial all bad say year sure.	2022-12-25 16:25:37.639385+03
205	206	lecturer	5	Task[205]. Live there process debate.	Rock discover central section why baby.	2022-12-25 16:25:37.646372+03
206	207	lecturer	5	Task[206]. Those foot beyond sense throughout down.	When employee drug must trip.	2022-12-25 16:25:37.654541+03
207	208	lecturer	6	Task[207]. Natural short scene major forget before.	Government firm agent trip one letter environment.	2022-12-25 16:25:37.662244+03
208	209	practicioner	5	Task[208]. Direction will dark house chair institution political.	Him agency field network.	2022-12-25 16:25:37.671063+03
209	210	lecturer	4	Task[209]. Poor wife fall herself.	Research notice piece effect member section.	2022-12-25 16:25:37.678751+03
210	211	practicioner	3	Task[210]. Investment direction down decide huge.	Deep hope program note civil culture hour.	2022-12-25 16:25:37.686387+03
211	212	practicioner	4	Task[211]. Western husband today election.	Degree toward pay former.	2022-12-25 16:25:37.69397+03
212	213	practicioner	6	Task[212]. Raise watch nation.	View spring support develop PM down.	2022-12-25 16:25:37.701055+03
213	214	lecturer	1	Task[213]. White make entire science dog practice than.	Beyond significant feel card various chance free.	2022-12-25 16:25:37.707597+03
214	215	lecturer	5	Task[214]. Remain house admit traditional Mrs focus.	End make summer event.	2022-12-25 16:25:37.714098+03
215	216	lecturer	2	Task[215]. Bill begin those believe cold.	Under cut determine different.	2022-12-25 16:25:37.72163+03
216	217	lecturer	3	Task[216]. Lay continue against give your why watch better.	Role significant against party score thank mean best.	2022-12-25 16:25:37.727619+03
217	218	practicioner	3	Task[217]. Guess along get central customer war next sit.	Life identify behind bag.	2022-12-25 16:25:37.733727+03
218	219	practicioner	3	Task[218]. Production money garden another personal cut until.	After sing memory direction season.	2022-12-25 16:25:37.740281+03
219	220	practicioner	5	Task[219]. Stay interest purpose middle letter artist western.	Off TV sit suddenly ever claim onto.	2022-12-25 16:25:37.746292+03
220	221	lecturer	1	Task[220]. Necessary any pressure TV point by step.	Marriage room customer.	2022-12-25 16:25:37.753207+03
221	222	lecturer	3	Task[221]. Account prevent local pass respond space.	Program to never ball floor language improve.	2022-12-25 16:25:37.76116+03
222	223	practicioner	5	Task[222]. Up table sit.	Then employee open assume example kitchen.	2022-12-25 16:25:37.767866+03
223	224	lecturer	2	Task[223]. Yard between away sound tend together.	Fly audience technology themselves since sometimes so.	2022-12-25 16:25:37.773932+03
224	225	practicioner	6	Task[224]. All medical job quickly affect example create event.	Magazine little story practice.	2022-12-25 16:25:37.783252+03
225	226	practicioner	6	Task[225]. Analysis step no.	Research husband off.	2022-12-25 16:25:37.790523+03
226	227	practicioner	4	Task[226]. Present soldier evidence campaign official six.	Tend end art treatment yeah.	2022-12-25 16:25:37.797775+03
227	228	practicioner	5	Task[227]. Certain write surface role year professional.	Happy figure dinner inside kind another after.	2022-12-25 16:25:37.805089+03
228	229	practicioner	2	Task[228]. Follow myself health drop bed office when.	Recognize southern very woman.	2022-12-25 16:25:37.812675+03
229	230	lecturer	3	Task[229]. Idea believe common fill.	Start almost behavior room speech.	2022-12-25 16:25:37.820577+03
230	231	practicioner	6	Task[230]. Certain must catch certainly kitchen share start.	Return morning almost ball.	2022-12-25 16:25:37.827816+03
231	232	practicioner	6	Task[231]. Sport door tree event.	Case prepare just church she keep describe.	2022-12-25 16:25:37.834961+03
232	233	lecturer	1	Task[232]. Change store everything world.	Congress relationship step table bag alone.	2022-12-25 16:25:37.842484+03
233	234	practicioner	3	Task[233]. Article close up.	The remember which image sometimes lose enjoy.	2022-12-25 16:25:37.849674+03
234	235	practicioner	1	Task[234]. Amount risk situation each.	Hard suggest job security else determine dog ask.	2022-12-25 16:25:37.857133+03
235	236	practicioner	3	Task[235]. Ten director billion director example near.	Leader here future fire church.	2022-12-25 16:25:37.864595+03
236	237	lecturer	5	Task[236]. Artist think child free resource continue from.	Wind campaign sign myself collection.	2022-12-25 16:25:37.873296+03
237	238	lecturer	2	Task[237]. Really second reflect.	Into relationship value success region.	2022-12-25 16:25:37.879511+03
238	239	lecturer	5	Task[238]. Office real again point.	Respond president enjoy she behind.	2022-12-25 16:25:37.885984+03
239	240	lecturer	2	Task[239]. Catch pattern ago itself.	Past live police ball hospital.	2022-12-25 16:25:37.892444+03
240	241	lecturer	2	Task[240]. Stand peace five soldier report visit within thing.	Want like management five month.	2022-12-25 16:25:37.899792+03
241	242	lecturer	4	Task[241]. Memory nature often newspaper.	Serious poor project believe.	2022-12-25 16:25:37.907068+03
242	243	lecturer	5	Task[242]. To grow do some charge join should.	Mission factor may green relationship.	2022-12-25 16:25:37.913871+03
243	244	lecturer	5	Task[243]. Send team land wide.	This clear who when coach.	2022-12-25 16:25:37.92021+03
244	245	lecturer	5	Task[244]. Year good poor appear financial hand democratic.	Real bad poor show affect check information.	2022-12-25 16:25:37.927551+03
245	246	practicioner	1	Task[245]. Brother it top wide more network.	Test make several act manage.	2022-12-25 16:25:37.934088+03
246	247	practicioner	6	Task[246]. Happen community good meet system health provide.	Health evidence type thus.	2022-12-25 16:25:37.941667+03
247	248	practicioner	5	Task[247]. Next with trouble several.	Garden bit end anything soldier difficult.	2022-12-25 16:25:37.947871+03
248	249	lecturer	6	Task[248]. Everybody establish country health interview despite name.	Live call spring every deal.	2022-12-25 16:25:37.954751+03
\.


--
-- Data for Name: teacher; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teacher (id, user_id, role, discipline_id, room_number, campus_id) FROM stdin;
1	2	practicioner	1	Y-109	GQ-8
2	3	practicioner	5	o-159	GQ-8
3	4	practicioner	4	n-281	OI-3
4	5	practicioner	3	I-165	NW-2
5	6	lecturer	4	k-380	OR-4
6	7	lecturer	4	e-389	PS-3
7	8	practicioner	2	u-217	OR-4
8	9	practicioner	1	Q-326	BT-9
9	10	practicioner	3	h-29	PS-3
10	11	lecturer	4	k-188	BT-9
11	12	lecturer	2	J-144	OR-4
12	13	practicioner	4	V-336	NW-2
13	14	practicioner	5	G-125	BT-9
14	15	lecturer	1	Z-181	PS-3
15	16	practicioner	3	L-14	OI-3
16	17	practicioner	5	Z-191	NW-2
17	18	practicioner	1	p-124	OR-4
18	19	practicioner	4	r-256	VZ-9
19	20	practicioner	4	o-338	VZ-9
20	21	practicioner	4	u-17	IZ-5
21	22	lecturer	6	w-262	FP-1
22	23	practicioner	4	r-320	CI-2
23	24	lecturer	3	l-268	FP-1
24	25	lecturer	2	l-15	OI-3
25	26	practicioner	5	j-120	NW-2
26	27	practicioner	1	U-76	OI-3
27	28	practicioner	5	r-345	OR-4
28	29	lecturer	4	V-395	OR-4
29	30	practicioner	5	D-280	OI-3
30	31	practicioner	5	o-56	BT-9
31	32	practicioner	3	m-279	OI-3
32	33	lecturer	6	i-208	FP-1
33	34	lecturer	3	i-327	OR-4
34	35	practicioner	3	G-334	NW-2
35	36	practicioner	5	b-364	FP-1
36	37	practicioner	1	T-328	OI-3
37	38	lecturer	1	o-293	OI-3
38	39	lecturer	1	o-114	FP-1
39	40	practicioner	5	G-319	PS-3
40	41	practicioner	6	K-376	CI-2
41	42	lecturer	6	c-65	FP-1
42	43	practicioner	3	z-76	NW-2
43	44	lecturer	6	l-247	PS-3
44	45	practicioner	4	n-236	BT-9
45	46	practicioner	3	Y-305	BT-9
46	47	practicioner	4	o-181	OR-4
47	48	lecturer	1	H-362	OR-4
48	49	lecturer	1	q-302	OR-4
49	50	lecturer	6	i-239	NW-2
50	51	lecturer	6	l-126	NW-2
51	52	practicioner	1	s-196	NW-2
52	53	practicioner	4	T-73	IZ-5
53	54	lecturer	5	f-141	CI-2
54	55	practicioner	3	k-378	BT-9
55	56	practicioner	2	o-396	CI-2
56	57	practicioner	6	F-63	GQ-8
57	58	lecturer	5	A-86	CI-2
58	59	practicioner	2	b-396	NW-2
59	60	practicioner	4	w-205	OR-4
60	61	practicioner	2	Z-117	VZ-9
61	62	lecturer	2	G-371	OR-4
62	63	lecturer	4	J-204	NW-2
63	64	practicioner	2	J-397	OR-4
64	65	practicioner	2	F-308	IZ-5
65	66	practicioner	4	t-360	IZ-5
66	67	practicioner	6	B-353	PS-3
67	68	practicioner	2	R-111	NW-2
68	69	practicioner	2	d-154	FP-1
69	70	lecturer	1	q-188	OR-4
70	71	lecturer	5	c-214	NW-2
71	72	practicioner	1	I-184	OR-4
72	73	practicioner	6	u-8	CI-2
73	74	practicioner	5	r-77	BT-9
74	75	lecturer	1	y-173	OI-3
75	76	practicioner	4	F-108	FP-1
76	77	practicioner	1	d-206	GQ-8
77	78	practicioner	2	q-155	CI-2
78	79	practicioner	3	c-22	OI-3
79	80	lecturer	4	V-14	CI-2
80	81	practicioner	6	c-148	BT-9
81	82	practicioner	2	g-249	IZ-5
82	83	lecturer	2	G-179	FP-1
83	84	practicioner	6	c-46	OI-3
84	85	practicioner	3	T-112	FP-1
85	86	lecturer	1	x-15	BT-9
86	87	practicioner	4	R-279	GQ-8
87	88	practicioner	2	O-322	BT-9
88	89	practicioner	1	M-378	NW-2
89	90	lecturer	5	a-172	IZ-5
90	91	practicioner	5	s-379	BT-9
91	92	lecturer	3	B-330	BT-9
92	93	practicioner	5	n-128	PS-3
93	94	practicioner	5	k-93	FP-1
94	95	practicioner	5	V-336	OI-3
95	96	lecturer	1	K-168	NW-2
96	97	lecturer	4	A-85	BT-9
97	98	practicioner	1	D-95	IZ-5
98	99	lecturer	2	C-206	BT-9
99	100	lecturer	1	g-82	BT-9
100	101	practicioner	2	C-393	PS-3
101	102	practicioner	2	O-108	FP-1
102	103	lecturer	2	X-26	BT-9
103	104	lecturer	6	m-65	OR-4
104	105	practicioner	1	n-89	FP-1
105	106	practicioner	1	F-389	BT-9
106	107	lecturer	6	n-63	PS-3
107	108	lecturer	4	X-274	BT-9
108	109	practicioner	6	u-239	NW-2
109	110	lecturer	5	B-184	CI-2
110	111	practicioner	4	Y-140	VZ-9
111	112	lecturer	1	O-1	VZ-9
112	113	practicioner	4	m-159	GQ-8
113	114	lecturer	1	S-275	GQ-8
114	115	practicioner	1	H-325	BT-9
115	116	practicioner	1	f-97	VZ-9
116	117	practicioner	2	e-213	PS-3
117	118	lecturer	1	I-359	FP-1
118	119	practicioner	4	I-53	NW-2
119	120	practicioner	2	b-263	BT-9
120	121	lecturer	1	X-367	FP-1
121	122	practicioner	4	M-20	FP-1
122	123	practicioner	3	M-232	NW-2
123	124	lecturer	1	I-32	FP-1
124	125	practicioner	2	V-189	VZ-9
125	126	practicioner	1	e-162	CI-2
126	127	practicioner	3	M-360	VZ-9
127	128	lecturer	2	o-172	CI-2
128	129	practicioner	5	x-194	OR-4
129	130	practicioner	6	I-92	OI-3
130	131	practicioner	3	D-131	NW-2
131	132	lecturer	2	d-45	NW-2
132	133	practicioner	6	F-8	VZ-9
133	134	practicioner	2	C-180	NW-2
134	135	practicioner	5	z-185	CI-2
135	136	practicioner	4	U-59	GQ-8
136	137	lecturer	6	Q-387	OI-3
137	138	lecturer	5	t-293	NW-2
138	139	lecturer	4	z-1	GQ-8
139	140	practicioner	6	t-370	PS-3
140	141	practicioner	5	F-285	FP-1
141	142	practicioner	1	L-91	GQ-8
142	143	lecturer	1	m-260	NW-2
143	144	practicioner	3	t-262	NW-2
144	145	lecturer	6	y-15	PS-3
145	146	practicioner	2	h-111	OI-3
146	147	lecturer	1	g-62	FP-1
147	148	practicioner	6	d-102	GQ-8
148	149	practicioner	1	k-120	OI-3
149	150	lecturer	5	e-119	GQ-8
150	151	practicioner	1	S-46	GQ-8
151	152	lecturer	2	J-275	OR-4
152	153	practicioner	2	n-140	CI-2
153	154	practicioner	6	E-332	BT-9
154	155	lecturer	4	L-45	NW-2
155	156	practicioner	4	m-311	VZ-9
156	157	lecturer	2	A-122	FP-1
157	158	practicioner	6	P-114	NW-2
158	159	lecturer	5	w-144	BT-9
159	160	practicioner	3	C-308	BT-9
160	161	practicioner	5	O-287	OI-3
161	162	practicioner	3	L-157	OR-4
162	163	lecturer	3	s-57	GQ-8
163	164	practicioner	3	q-29	OR-4
164	165	practicioner	6	L-157	GQ-8
165	166	practicioner	5	L-170	CI-2
166	167	lecturer	3	s-370	CI-2
167	168	practicioner	2	t-267	PS-3
168	169	practicioner	2	e-167	OI-3
169	170	practicioner	5	R-51	VZ-9
170	171	lecturer	6	s-260	OR-4
171	172	practicioner	4	m-127	BT-9
172	173	practicioner	3	n-384	IZ-5
173	174	practicioner	2	b-305	FP-1
174	175	lecturer	6	w-183	OI-3
175	176	practicioner	5	l-392	FP-1
176	177	practicioner	3	e-86	VZ-9
177	178	lecturer	1	P-96	PS-3
178	179	practicioner	5	h-334	GQ-8
179	180	practicioner	4	e-275	PS-3
180	181	practicioner	1	M-285	CI-2
181	182	lecturer	1	s-124	BT-9
182	183	lecturer	2	Y-173	IZ-5
183	184	practicioner	2	B-195	PS-3
184	185	lecturer	2	F-42	GQ-8
185	186	practicioner	2	e-341	OR-4
186	187	practicioner	4	y-367	CI-2
187	188	practicioner	4	C-153	IZ-5
188	189	practicioner	3	D-338	FP-1
189	190	lecturer	6	u-119	NW-2
190	191	practicioner	5	p-35	GQ-8
191	192	lecturer	6	C-65	VZ-9
192	193	lecturer	5	o-225	OI-3
193	194	lecturer	4	x-388	GQ-8
194	195	lecturer	1	H-8	VZ-9
195	196	practicioner	2	u-261	IZ-5
196	197	practicioner	4	C-328	OR-4
197	198	practicioner	3	E-78	PS-3
198	199	lecturer	6	k-332	OR-4
199	200	lecturer	2	g-273	OR-4
200	201	lecturer	2	p-319	OI-3
201	202	practicioner	4	a-308	BT-9
202	203	lecturer	1	R-212	PS-3
203	204	practicioner	3	t-156	FP-1
204	205	lecturer	5	A-99	VZ-9
205	206	lecturer	5	L-365	IZ-5
206	207	lecturer	5	z-179	NW-2
207	208	lecturer	6	g-238	FP-1
208	209	practicioner	5	M-347	IZ-5
209	210	lecturer	4	s-353	NW-2
210	211	practicioner	3	E-61	CI-2
211	212	practicioner	4	L-107	VZ-9
212	213	practicioner	6	S-39	OI-3
213	214	lecturer	1	w-179	GQ-8
214	215	lecturer	5	M-112	OI-3
215	216	lecturer	2	e-335	CI-2
216	217	lecturer	3	b-86	CI-2
217	218	practicioner	3	J-383	VZ-9
218	219	practicioner	3	D-60	CI-2
219	220	practicioner	5	N-252	FP-1
220	221	lecturer	1	L-251	BT-9
221	222	lecturer	3	p-306	GQ-8
222	223	practicioner	5	v-211	GQ-8
223	224	lecturer	2	U-337	FP-1
224	225	practicioner	6	S-104	GQ-8
225	226	practicioner	6	B-165	FP-1
226	227	practicioner	4	e-150	NW-2
227	228	practicioner	5	w-89	GQ-8
228	229	practicioner	2	e-277	IZ-5
229	230	lecturer	3	X-165	IZ-5
230	231	practicioner	6	d-136	NW-2
231	232	practicioner	6	q-236	VZ-9
232	233	lecturer	1	P-30	OR-4
233	234	practicioner	3	M-143	IZ-5
234	235	practicioner	1	q-111	FP-1
235	236	practicioner	3	F-102	VZ-9
236	237	lecturer	5	X-19	NW-2
237	238	lecturer	2	y-259	FP-1
238	239	lecturer	5	y-248	VZ-9
239	240	lecturer	2	z-22	PS-3
240	241	lecturer	2	N-389	PS-3
241	242	lecturer	4	M-44	BT-9
242	243	lecturer	5	S-159	CI-2
243	244	lecturer	5	A-104	NW-2
244	245	lecturer	5	p-267	NW-2
245	246	practicioner	1	G-356	NW-2
246	247	practicioner	6	m-140	CI-2
247	248	practicioner	5	v-136	BT-9
248	249	lecturer	6	A-367	PS-3
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."user" (id, email, hashed_password, role, full_name, username, age, phone, avatar, is_active, is_superuser, create_date) FROM stdin;
1	admin@gmail.com	$2b$12$zgHvIM9zT0udSth.FRULxeWIRb7tB9xhkKVRIdk8jq9tgeFmtDZJe	admin	Super User	ka52	\N	\N	\N	t	t	2022-12-25 16:23:47.81638+03
2	teacher2@gmail.com	$2b$12$wKn4CWG2vWtH2e78AJ8yCefBuoZdlJMdPdEuHRlmr/DnMRA.QFMjy	teacher	Michaela White	teacher22037	22	+71155053224	\N	t	f	2022-12-25 16:23:48.299041+03
3	teacher3@gmail.com	$2b$12$6CdRSo6QZo6VDgj1/eNZpODclrfDaidA.1QayebZtZ8XY9/IqmHWG	teacher	Jennifer Coleman	teacher34935	18	+74503101154	\N	t	f	2022-12-25 16:23:48.505293+03
4	teacher4@gmail.com	$2b$12$mPVFOozgwHJfem6X.eeu.eD0uWerU71NqHoM5u9nnstpjlnBxYxpW	teacher	Duane Butler	teacher48668	25	+73045339452	\N	t	f	2022-12-25 16:23:48.714906+03
5	teacher5@gmail.com	$2b$12$tp7kPQeYjuXz.ydfz2hY9.gexEgaOMDk3H//yAoPFnq23k2F/ldCm	teacher	Kristen Mays	teacher55689	22	+76583256356	\N	t	f	2022-12-25 16:23:48.926859+03
6	teacher6@gmail.com	$2b$12$SulGQBdQKDy84zo30j6v/ue3tROmc7dwL.LNX1ZVNrHtFNx/jiwkm	teacher	Anthony Freeman	teacher67959	25	+75375487998	\N	t	f	2022-12-25 16:23:49.135173+03
7	teacher7@gmail.com	$2b$12$CMZ3AU8zLLLXda2BA3CeduV.KcH21mYXqCNs6kxGnYD9wZe1duPFK	teacher	Alex Hensley	teacher72693	22	+79965586858	\N	t	f	2022-12-25 16:23:49.345341+03
8	teacher8@gmail.com	$2b$12$xbp6cvhNHok0iR8VtqSR0umHa3.XBJHU9WNyYCTtKdG5DojkCljwa	teacher	Richard Peck	teacher87333	20	+75085391180	\N	t	f	2022-12-25 16:23:49.552932+03
9	teacher9@gmail.com	$2b$12$4g6oTnZxsBMSXlCKJiDXGOdtbrat95AyzeKNj0U7kKR3ihXxUpHoi	teacher	Ricky Hall	teacher93428	25	+70264334007	\N	t	f	2022-12-25 16:23:49.76257+03
10	teacher10@gmail.com	$2b$12$7RThKVId2v7VENbMcW0LbOQ/0mEE80NHVk7n.qDhokn7dbE.0zo8K	teacher	Laura Patterson	teacher106811	18	+75953460706	\N	t	f	2022-12-25 16:23:49.969538+03
11	teacher11@gmail.com	$2b$12$VlR5koU.X6HvP6faktYuYO0wOGUYwlRvybFsk86bIBjb1OKkh5lou	teacher	Allison Rodriguez	teacher112074	23	+77019184706	\N	t	f	2022-12-25 16:23:50.173252+03
12	teacher12@gmail.com	$2b$12$9o10nplBlYOsOJwTk2RYeODJkmGrrIFHqfKxCE2wHUpWEAhk0X.O.	teacher	Rodney Blake	teacher127714	21	+76429257950	\N	t	f	2022-12-25 16:23:50.375933+03
13	teacher13@gmail.com	$2b$12$MGU4jYBhYOUM7ruOquGTRecj1DQdvFqdo0uWxw9cj5/hYHLS.iPta	teacher	Rachel Lewis	teacher137170	24	+77951862222	\N	t	f	2022-12-25 16:23:50.578008+03
14	teacher14@gmail.com	$2b$12$EA2tkgvob4D4FWm2oFw0dO5aKJgbY8zj.9qS4kkYPA5Q35DUgA5sW	teacher	James James	teacher146487	24	+75529163472	\N	t	f	2022-12-25 16:23:50.784727+03
15	teacher15@gmail.com	$2b$12$C0t7EAynEXbnWmnXrVNaJOlOftiE71LIrnHsnuvgq4mYaIFCwhYcq	teacher	Christopher Martinez	teacher157353	18	+72238210749	\N	t	f	2022-12-25 16:23:50.986504+03
16	teacher16@gmail.com	$2b$12$rXW4y9mFgi/TQKAuna7zI.MpsQQ7BF2A6wKP5yCrw2tZ3/E475f..	teacher	Jessica Savage	teacher163493	18	+70556639998	\N	t	f	2022-12-25 16:23:51.191228+03
17	teacher17@gmail.com	$2b$12$bgG.1LOtNL/u/oQGvsLlX.4ODG9AbQEkDBNQuTFgsQKdicAjj4jk6	teacher	Shari Ryan	teacher177661	21	+74401801098	\N	t	f	2022-12-25 16:23:51.394575+03
18	teacher18@gmail.com	$2b$12$.qWhfx/892EEvO1pFdkNo.vonjJVveOmYbHYpX9kVLvEX/HOYTnxG	teacher	Mark Morrow	teacher182003	23	+79946375457	\N	t	f	2022-12-25 16:23:51.599492+03
19	teacher19@gmail.com	$2b$12$K5w8S4ExEiZ727ajtwXTUua1GP94BP7utNmzNF/rqqAlZdpCJp/VC	teacher	Alice Padilla	teacher193800	23	+76103072593	\N	t	f	2022-12-25 16:23:51.803943+03
20	teacher20@gmail.com	$2b$12$nuRMZCjN1LaLa29/3fY/UO6v3.uykoFHKwGSpQl0oBSwzzFWZ0/SW	teacher	Lindsey Hawkins	teacher208180	19	+74832640275	\N	t	f	2022-12-25 16:23:52.007341+03
21	teacher21@gmail.com	$2b$12$bOTQqaDpgoFWEBSPoXFxvOlQ4DwEX1VbQfd4eQwcRVYhsHX60F3om	teacher	Jennifer Ramirez	teacher219536	22	+72623317303	\N	t	f	2022-12-25 16:23:52.214418+03
22	teacher22@gmail.com	$2b$12$/GVvDCwcgm4Wlh0eO1zIf.VZ7g2m0mLkKQ4gsm2caCP5bzM5MijVy	teacher	Jason Arellano	teacher223136	20	+71563211622	\N	t	f	2022-12-25 16:23:52.421265+03
23	teacher23@gmail.com	$2b$12$RKxPa1gByPSqhdWonKaA..8NAxfD8c6QSuW9dBjtDjsx0U9HtN9p6	teacher	Mrs. Sue Carter DDS	teacher231045	21	+72576892488	\N	t	f	2022-12-25 16:23:52.6245+03
24	teacher24@gmail.com	$2b$12$QX8L049sE0mkPRvPNI0QLu41pHmmFFv1zDKbhWCOr9LcOrQxDIOSW	teacher	Kristen Russell	teacher246275	19	+74775932136	\N	t	f	2022-12-25 16:23:52.82958+03
25	teacher25@gmail.com	$2b$12$5Mu2NIjBIfLhhNUzfPrpFuXjM0BxHEnKdsRlvoj1kFt6ypTpbBVoa	teacher	Lori Willis	teacher253340	23	+70081476530	\N	t	f	2022-12-25 16:23:53.032105+03
26	teacher26@gmail.com	$2b$12$evEaoRLUVnFjoy56FzjVSuvrKiOgMmlYTjXEcCZ/SEm.fD36Sfe3i	teacher	Tracy Bates	teacher263338	21	+77305697165	\N	t	f	2022-12-25 16:23:53.236665+03
27	teacher27@gmail.com	$2b$12$lbcU5pTz9jKe5y21oAAQ.Ol5TN30d7TGJa9R3t4o/yRqcxiYIkcK6	teacher	Summer Henry	teacher272708	25	+77473940373	\N	t	f	2022-12-25 16:23:53.441264+03
28	teacher28@gmail.com	$2b$12$pi0v.VkBMaFA6Q4UnOPW6OatKYY3TxrFKjBRXNZ7n8zyToPEAahBq	teacher	Teresa Williams	teacher284307	25	+76781832521	\N	t	f	2022-12-25 16:23:53.645548+03
29	teacher29@gmail.com	$2b$12$Pel7ZAxYfAk8AUX2xGOb1O4e2DFGp5xo/vH5kYbgNrPc1V7D4FJby	teacher	Susan Aguilar	teacher291389	21	+76911724774	\N	t	f	2022-12-25 16:23:53.850211+03
30	teacher30@gmail.com	$2b$12$.Ev5B.BfWBDcMLCMS9mMvO4v7/orQqS/jU1yqAodN1ouEAHsalQtu	teacher	Thomas Key MD	teacher305434	20	+75053460260	\N	t	f	2022-12-25 16:23:54.053924+03
31	teacher31@gmail.com	$2b$12$6rqy7A2dvo0a9vyrEKRcVu9tGlwxENeJuyZwvgNM.u9XaJiV3d.nS	teacher	Alan Dougherty	teacher312223	24	+77721564107	\N	t	f	2022-12-25 16:23:54.261497+03
32	teacher32@gmail.com	$2b$12$qwYJJa1I0gSWXNGtpNE/Mel52tBQVztqkhenwB48TrbHj.1oJyYpq	teacher	Patricia Macias	teacher328541	18	+75258407504	\N	t	f	2022-12-25 16:23:54.465096+03
33	teacher33@gmail.com	$2b$12$rxypCa/uR1oXszbPL8sku.iwiDodUWq9qdgwbdTvOgZVkGJ8r4tl2	teacher	Tracey Joyce	teacher331775	19	+78992017082	\N	t	f	2022-12-25 16:23:54.667877+03
34	teacher34@gmail.com	$2b$12$AHbaYKI/UvQxIo.iTpZ3U.SpqmcUL7aq0ydqsDqM.LrlQ8RVjWlly	teacher	Jesse Miller	teacher342077	24	+70052941144	\N	t	f	2022-12-25 16:23:54.872011+03
35	teacher35@gmail.com	$2b$12$NGzoPSMVpwJIMWZ3X05Et.gYOS7zzTdxM4x37T6chTphZ6am1vpvK	teacher	Elizabeth Swanson	teacher359528	21	+79412941214	\N	t	f	2022-12-25 16:23:55.076603+03
36	teacher36@gmail.com	$2b$12$FaDxsjM5XsInYgMbAUQfQu590gVRa4gAe4DC0CJonbMHyPyDBM3e.	teacher	Jade Rodriguez	teacher369476	19	+76806771027	\N	t	f	2022-12-25 16:23:55.283009+03
37	teacher37@gmail.com	$2b$12$LGpgAUkjEZz2X38coXJkXO4MP5uEW3JMTeJ8s7u/DgGFrycxLy2qm	teacher	Jennifer Hawkins	teacher371806	20	+71920180191	\N	t	f	2022-12-25 16:23:55.493729+03
38	teacher38@gmail.com	$2b$12$bMDRIQKZbE7/Oil/14e3vOcldctGaWYEuvMBYQglNWgXb0I7NRaFm	teacher	Dennis Davenport	teacher389074	25	+78942891231	\N	t	f	2022-12-25 16:23:55.703327+03
39	teacher39@gmail.com	$2b$12$gwtlqh0dVDpNbjsUcJi5ROqm1QszQwlqTjm62ule1.gq1gg.CrZEG	teacher	Linda Tran	teacher394667	19	+79857123964	\N	t	f	2022-12-25 16:23:55.911495+03
40	teacher40@gmail.com	$2b$12$sbbiioGQbzgw1LK15rIVNOeN/zRXqqNH9w/WZHsRLd42e8olYxczm	teacher	Derek Pope	teacher403760	18	+74607346284	\N	t	f	2022-12-25 16:23:56.120293+03
41	teacher41@gmail.com	$2b$12$GyfHsvL1fYd.xaWrdxznqOyGzqQH0zXWdPXwfi3u4F8TUkpp.w/4a	teacher	Thomas Martin Jr.	teacher413968	22	+70453616808	\N	t	f	2022-12-25 16:23:56.329174+03
42	teacher42@gmail.com	$2b$12$0/VmOqP44/k4J42aZZQkWeHo/57GLnmgI6HOGrIqrD4lvBZdkOhGC	teacher	Robert Munoz	teacher427171	21	+78198677278	\N	t	f	2022-12-25 16:23:56.538098+03
43	teacher43@gmail.com	$2b$12$wO.FsB4ODT/X60SJSipsrebg0Xr9/Xpjt2709RT.AMGiMkLPWrraC	teacher	Tanya Hamilton	teacher437120	22	+79196843212	\N	t	f	2022-12-25 16:23:56.747362+03
44	teacher44@gmail.com	$2b$12$mdztkSmkdC/zqbaCIT1dde.SvZKTz4W4w8/rrhCDTO.0uYoSqIqsK	teacher	Sarah Crawford	teacher444723	25	+73678949024	\N	t	f	2022-12-25 16:23:56.958107+03
45	teacher45@gmail.com	$2b$12$266GArmh.KkUlb/eycsICO2itpMCm0chjGemX9lceoZHHURxnDZ5W	teacher	Hailey Williams	teacher455378	21	+70968534035	\N	t	f	2022-12-25 16:23:57.170734+03
46	teacher46@gmail.com	$2b$12$L1BgJzyHEJgUbmaloPkePuTfM1cnRkYNX7c8Uoqzx5LcNSO5O4Zce	teacher	Becky King	teacher464983	22	+76269928278	\N	t	f	2022-12-25 16:23:57.382321+03
47	teacher47@gmail.com	$2b$12$V1Fdjifmc7dJMKSoroA44OgIpFBLrKpYzi67I.AAWl6mW0yO31K0m	teacher	Craig Foster	teacher479573	21	+71326248367	\N	t	f	2022-12-25 16:23:57.589044+03
48	teacher48@gmail.com	$2b$12$1HwoybrF4KB5.CX6RZ/r9OtWnZ9fGMfTOegZ1R1jr1LUusLbeYoRW	teacher	Joseph Johnson	teacher487308	23	+74516364720	\N	t	f	2022-12-25 16:23:57.800073+03
49	teacher49@gmail.com	$2b$12$SelhOXJLGOVnLeYc1UuR8.MhPm1sg8R7yWmJoprEPpZpAGpnlsyPS	teacher	April Moore	teacher499669	20	+73300293509	\N	t	f	2022-12-25 16:23:58.009757+03
50	teacher50@gmail.com	$2b$12$FEizqOeH2feiEy9YajkWO.TDcoXKb5SmaCIA.SxyUlHYfUlnxVpFW	teacher	Lauren Moore	teacher508138	25	+73690224869	\N	t	f	2022-12-25 16:23:58.21878+03
51	teacher51@gmail.com	$2b$12$FPY3HjPNcCUra71552u6decLWJcW8bgnCkgP.GVB.HP3P.Q2awHn.	teacher	Amy Stuart	teacher516611	20	+70820557266	\N	t	f	2022-12-25 16:23:58.428617+03
52	teacher52@gmail.com	$2b$12$KoJxU6KOfHGgT55D2kOiLetsYmoIORTrS6sZ5u1J6JsL2glpapLsG	teacher	Adrian Monroe	teacher524256	25	+74530679162	\N	t	f	2022-12-25 16:23:58.638289+03
53	teacher53@gmail.com	$2b$12$R7/JlhonC34Xfp1r0dr.OOABDCYQli7yGiHwVUZ9UwbevSroOMnp.	teacher	Jillian Travis	teacher533620	20	+74966669664	\N	t	f	2022-12-25 16:23:58.851501+03
54	teacher54@gmail.com	$2b$12$aYpHwKr7nYXbJGW0sDYA1u9kAuLRlJa7GByV3DnxcYlVhlzlXvHTK	teacher	Dan Morse	teacher542121	22	+71642261269	\N	t	f	2022-12-25 16:23:59.064696+03
55	teacher55@gmail.com	$2b$12$Jt13.fPzwhrW3.maVRINve6AicISJChMCseiksrZd6097DJdjCHem	teacher	Brian Reid	teacher559034	21	+77305245179	\N	t	f	2022-12-25 16:23:59.273611+03
56	teacher56@gmail.com	$2b$12$eg8wUuuvAnb.ykGX4hrUM.8Q3k.SluSYrHSnY6jJEad8Wz/EyaKpy	teacher	Tonya White	teacher564461	22	+72416261020	\N	t	f	2022-12-25 16:23:59.48429+03
57	teacher57@gmail.com	$2b$12$j91Jy4NrYpzR8kq4GKXxB.VuKYepnFp0Ueb6znLDM0ZXXBO774Kvy	teacher	Laurie Thompson	teacher579727	20	+72719881106	\N	t	f	2022-12-25 16:23:59.68984+03
58	teacher58@gmail.com	$2b$12$JpO/I94ziXz8K8hxqq73N.I6KN3EEjX8.ktHmmLI6x9v828iUCpgq	teacher	Lisa Smith	teacher583665	25	+76239864591	\N	t	f	2022-12-25 16:23:59.899416+03
59	teacher59@gmail.com	$2b$12$BQiVwTlR4QNGVgQ1co2wdu/poketOrC6dg9ZwDJBT7.AblMdlrNwm	teacher	Troy Harris	teacher599876	20	+77599255254	\N	t	f	2022-12-25 16:24:00.11381+03
60	teacher60@gmail.com	$2b$12$S6uYH3f9bYVnxKC0V8LlPeSq312OU3oCNwb14VsGXXjmXJ9PDQrhe	teacher	Suzanne Sellers	teacher602925	19	+72522130970	\N	t	f	2022-12-25 16:24:00.321942+03
61	teacher61@gmail.com	$2b$12$j8yo4hkUvnPoRmcw3oSTxuzestnrjS5OQlOdFo7R6ho56I0fVIM9a	teacher	Brittney Conley	teacher614540	20	+78938819804	\N	t	f	2022-12-25 16:24:00.534321+03
62	teacher62@gmail.com	$2b$12$rZKhkhPj2JkVBu4h5I5STOoX9M5fayQLfr/ome9pobO823JaFgddm	teacher	Caitlin Cantu	teacher626430	23	+77272861584	\N	t	f	2022-12-25 16:24:00.748621+03
63	teacher63@gmail.com	$2b$12$/SGRRV9MdTNmA/eZSDCSeO/MQ8CVrOJjowWnfQ.2OyjJUBY4EADom	teacher	Phyllis Jenkins	teacher638064	21	+72662386635	\N	t	f	2022-12-25 16:24:00.961834+03
64	teacher64@gmail.com	$2b$12$JofMM5f0EwRVbbW85YxcAu00gg6OaEiB.qCbMdZAuGynd9MWz.NgG	teacher	Jack Ortiz	teacher643644	18	+70091440117	\N	t	f	2022-12-25 16:24:01.168073+03
65	teacher65@gmail.com	$2b$12$HoASiEXmo5b52wlr.T5daOH5Ef.Rrzmi6W9yHDTiMqKuzxUldAigm	teacher	Michael Murphy	teacher658083	24	+72130264512	\N	t	f	2022-12-25 16:24:01.383667+03
66	teacher66@gmail.com	$2b$12$ZuR29rs6wTv8Gp1KG3nA1uZ4zwM4kF3dz/9137vJj3OYWDmo1SM/m	teacher	Elizabeth Nguyen	teacher666494	23	+77972741335	\N	t	f	2022-12-25 16:24:01.593327+03
67	teacher67@gmail.com	$2b$12$nFEPxLlAeJI4er/K2zsWSe184HWu3j9h1vjlkHXO7hflGzQa/.Q/2	teacher	Jasmine Willis	teacher675997	19	+72767812291	\N	t	f	2022-12-25 16:24:01.803295+03
68	teacher68@gmail.com	$2b$12$U708Tqru7HLWnOUxZJbbLO7MRXgTNw2AQn8vHjw2beQTnFYCMLDee	teacher	John Mora	teacher683842	21	+75420597844	\N	t	f	2022-12-25 16:24:02.011968+03
69	teacher69@gmail.com	$2b$12$uLvcDDJ8uULh/ldYXhXe5..cnnKqfpzwuLmkj0ecziKeLAxQazrOK	teacher	Bryan Hicks	teacher698271	20	+78952238899	\N	t	f	2022-12-25 16:24:02.216994+03
70	teacher70@gmail.com	$2b$12$mQrVKKin0ggKU9S054Cv6eomhhIeaaOygK3XRQuhZ.dLLGBchH6WK	teacher	Vanessa Garrison	teacher707381	18	+77932092770	\N	t	f	2022-12-25 16:24:02.431112+03
71	teacher71@gmail.com	$2b$12$vKCfVuzIjD1dsA8tACXQ3OKeCereBRrNaQKD8OkV7xuTF9j85de9y	teacher	Kyle Walker	teacher714839	25	+75345425182	\N	t	f	2022-12-25 16:24:02.634369+03
72	teacher72@gmail.com	$2b$12$RaaUMDA6Ww0PXoocxRLw1OjjTlJ6rmhQcgOGa6Q0eW2YwwgzSq1MO	teacher	Brent Johnston	teacher728689	24	+76842347646	\N	t	f	2022-12-25 16:24:02.838261+03
73	teacher73@gmail.com	$2b$12$QlvVY2vHy.yhTrOeS8FrceVmvOKxCvyKsDZDJEI2e.VttkXT1pGqS	teacher	Stephanie Davis	teacher733515	23	+77489511808	\N	t	f	2022-12-25 16:24:03.048393+03
74	teacher74@gmail.com	$2b$12$IvkaJGYHv6XcW85P2WtAWO1gS/LdWKrdustJuLiIzjcLi6PKoztMe	teacher	Joshua Young	teacher746431	23	+70420318176	\N	t	f	2022-12-25 16:24:03.253804+03
75	teacher75@gmail.com	$2b$12$YzUHGQLn4DE/0Be/d/cmgerB9g6fP32dBwOmNodSUARyV.aAa6zf2	teacher	Francis Obrien	teacher753236	19	+75824727103	\N	t	f	2022-12-25 16:24:03.46798+03
76	teacher76@gmail.com	$2b$12$BnVn8E6LUTdKN79yvXb6N.xD9fdPcUyIlMvbWsh5O.JpHsP7mm/om	teacher	Olivia Miller	teacher764440	20	+79012846499	\N	t	f	2022-12-25 16:24:03.669725+03
77	teacher77@gmail.com	$2b$12$95fwHNuW74bH6YpFY8Gvaua7idfn91/FhuRbOVG/1GC52i4ehdpXi	teacher	Roy Mendoza	teacher779694	20	+70743853575	\N	t	f	2022-12-25 16:24:03.874033+03
78	teacher78@gmail.com	$2b$12$Sv9ZhKeVQqEKM72BzDy.5e6pAFYdG8Cf2AwHk1S356XsiH4EDCAYC	teacher	Wendy Moore	teacher783882	25	+78250544389	\N	t	f	2022-12-25 16:24:04.080264+03
79	teacher79@gmail.com	$2b$12$GBwYkAHnpPLpQ/gPtqdHw.HgKGCXuQepa5VDaom37sZBlWnKEIecm	teacher	Calvin Adams	teacher797682	21	+77264084620	\N	t	f	2022-12-25 16:24:04.285849+03
80	teacher80@gmail.com	$2b$12$FbJMjTq75dD4N5CN/iHdHerTRKe6V.6tWq6MY9/E8B64bCDuCXN0u	teacher	Mrs. Nichole Paul MD	teacher806000	25	+79224409308	\N	t	f	2022-12-25 16:24:04.489101+03
81	teacher81@gmail.com	$2b$12$HTeSX0hYeJ9BqHHOi3V40ebxotDxcixJbfqMTYHZuLju2WrCkC/dC	teacher	Robert Mitchell	teacher815635	21	+79772119972	\N	t	f	2022-12-25 16:24:04.691929+03
82	teacher82@gmail.com	$2b$12$b.nfMGWhxEloaNAJIG8xS.jBDyrGGpSOczrGbbvimpdY9WduyNm2y	teacher	William Garza	teacher822586	22	+75559605250	\N	t	f	2022-12-25 16:24:04.895199+03
83	teacher83@gmail.com	$2b$12$CAONxqXrQY/AV9i9fWlOHO0j0qYW1E/PmFrIZ9RcVsaduXvPvO3C.	teacher	Kayla Graves	teacher832289	19	+79422276255	\N	t	f	2022-12-25 16:24:05.10062+03
84	teacher84@gmail.com	$2b$12$1Vp.K9zKoRYyRN6571Sbb.fUbTbWWYZ8yqx3w7AlCVJy7DMLjfYCC	teacher	Marisa Peck	teacher844926	19	+78451163177	\N	t	f	2022-12-25 16:24:05.307282+03
85	teacher85@gmail.com	$2b$12$/R8.0n1P38HSUwIdUSNYPeffDjwgwChmBVrD3QSts.iQfcAYvOjky	teacher	Jonathan Marshall	teacher859336	18	+70164582048	\N	t	f	2022-12-25 16:24:05.51374+03
86	teacher86@gmail.com	$2b$12$DR0n9BA/q/u46dJyBz/MtOD9Zj8Aj1foYkeSIOit/evbBOqaay66y	teacher	William Lane	teacher866446	18	+79480970936	\N	t	f	2022-12-25 16:24:05.718159+03
87	teacher87@gmail.com	$2b$12$g2TxkoPYgDF/S3NqWDKOLOJ9iy3iTpEH2n8Uz1dd3ws/4aq1IvYRS	teacher	Jennifer Ramirez	teacher871806	23	+77558989793	\N	t	f	2022-12-25 16:24:05.920012+03
88	teacher88@gmail.com	$2b$12$xQSyNP8/N9IUpksqMxjv2eQ0kmhgC1IRbHnarRlZ.X.wvyxGJ7VcO	teacher	Michael Anthony	teacher885406	21	+72534672046	\N	t	f	2022-12-25 16:24:06.12944+03
89	teacher89@gmail.com	$2b$12$E0/iReeXmF1DAc3Pdpknfe4K7eA1U7ebGKA75gRtLtRBi5/XIBy6a	teacher	Jose Pierce	teacher891920	18	+71001938302	\N	t	f	2022-12-25 16:24:06.334289+03
90	teacher90@gmail.com	$2b$12$T5UhBx3ycUlar7lQ7WFQZelBdemScAFyWKcTXqR59eLa7Q2cBJCYy	teacher	Jeffrey Taylor	teacher906429	20	+72296765229	\N	t	f	2022-12-25 16:24:06.53759+03
91	teacher91@gmail.com	$2b$12$j5HJIP7esXSy8ylkViUQC.NDEb8EQBC23S97LXwIdkTkECKBzMzlq	teacher	Deborah Padilla	teacher917383	24	+72947547103	\N	t	f	2022-12-25 16:24:06.740817+03
92	teacher92@gmail.com	$2b$12$jznswQA/vGZelGNkhBzqIuSs.MF0E0w9GVnSrhfd3PDQbObOVssWS	teacher	Christina Smith	teacher928183	19	+70720705558	\N	t	f	2022-12-25 16:24:06.942537+03
93	teacher93@gmail.com	$2b$12$NmA6xuDbCy4ZLy2YptKNReSrdommKfj4eOwi3M3G2hogBw7fon.ZC	teacher	Joseph Brown	teacher937454	20	+71971092154	\N	t	f	2022-12-25 16:24:07.147467+03
94	teacher94@gmail.com	$2b$12$JuM0sTKVPZ.jtsBWrYSkxOTAYYh9upmCwh0gogUMdWRpgc/R3Dihu	teacher	Eric Vega	teacher945805	22	+73773228017	\N	t	f	2022-12-25 16:24:07.357867+03
95	teacher95@gmail.com	$2b$12$o/WhiZ5fO1KIMmBoTyBIfeL.AstJn9AGEXUZMoX70QbRCJoc11Ddm	teacher	Lorraine Zamora	teacher953491	21	+77247738470	\N	t	f	2022-12-25 16:24:07.560713+03
96	teacher96@gmail.com	$2b$12$McFxZbQNk8JNWCMf2.hvxusH1IZ1xugJ0DH2yEANg5Rushf2Iyp9G	teacher	Steven Houston	teacher963891	24	+75721086674	\N	t	f	2022-12-25 16:24:07.77469+03
97	teacher97@gmail.com	$2b$12$sH17CohIj3//eIOcMEElluVx2T63c.amyGLphI1NyXct2wFpr6Rpm	teacher	Daniel Garcia	teacher979772	20	+75412801943	\N	t	f	2022-12-25 16:24:07.976699+03
98	teacher98@gmail.com	$2b$12$nOK6TfzTK006McAHeI7f0.DP8SBeXXLFmfYl5m/TsT4qMBj6qjIa6	teacher	Robert Patterson	teacher981687	22	+77156734402	\N	t	f	2022-12-25 16:24:08.181928+03
99	teacher99@gmail.com	$2b$12$N4E.VzPgTN6mDQG02QufjenIJfUmk.XFJYO6ELDaC8gfPAkKzFXKe	teacher	Amy Bullock	teacher993429	20	+73430968322	\N	t	f	2022-12-25 16:24:08.395739+03
100	teacher100@gmail.com	$2b$12$BAPo2wTMtJXogkdqqiEWEehm8EJ9tle.1N5PZ6jDR0g4w6InAJptW	teacher	Regina Reynolds	teacher1002668	18	+71542106119	\N	t	f	2022-12-25 16:24:08.600847+03
101	teacher101@gmail.com	$2b$12$HEpCwJdChrAb9.ArdFI8qOk0bbvWBxGO3l21ovsY9TU3kUorH813C	teacher	Gary Massey	teacher1015436	24	+70902159728	\N	t	f	2022-12-25 16:24:08.806277+03
102	teacher102@gmail.com	$2b$12$WaJ/NsX93Zo0q8oEXEOJ5.DPEYuC5iq7.7pBJV4udczMjZ7z44uQu	teacher	Stanley Page	teacher1029881	24	+78915761347	\N	t	f	2022-12-25 16:24:09.010768+03
103	teacher103@gmail.com	$2b$12$ShjKupwG7TbUHTbmQCHhquYntORrTEtaL9gBH3vFV4Lb7DXsu3Fa2	teacher	Tyler Anderson	teacher1038469	20	+76433618014	\N	t	f	2022-12-25 16:24:09.213802+03
104	teacher104@gmail.com	$2b$12$Wz.o.hk6L6aJ4WxtdoECl.gZANnmN.U4VPlrI6sC8wgfSGCMnxNZ2	teacher	Billy Morton	teacher1045647	25	+78337911809	\N	t	f	2022-12-25 16:24:09.4212+03
105	teacher105@gmail.com	$2b$12$Xkmc6NJPekICxXaUzLRgaOxs9XJVpHhAKB/IbS1CtTnr80YDxbu82	teacher	Edwin Hudson	teacher1056561	25	+71760327323	\N	t	f	2022-12-25 16:24:09.633193+03
106	teacher106@gmail.com	$2b$12$CRFwqppg5RgaWUm870u.xOCmZ2GvU/aTdTLfRBLPwwTyHbtetS7dG	teacher	Lisa Smith	teacher1069568	21	+76477977898	\N	t	f	2022-12-25 16:24:09.837203+03
107	teacher107@gmail.com	$2b$12$vTXClDEmZe1TO7GnH2QbYud7Ppf7e5dwK/Bt4zDzwU19fRiYnbCKW	teacher	Whitney Thompson	teacher1071436	20	+71377407173	\N	t	f	2022-12-25 16:24:10.040114+03
108	teacher108@gmail.com	$2b$12$Z/9kdvXGPYSmPqoGMtsP3uMPgXfrjwr8YrHdSoW893KXICKqLYsbC	teacher	Sara Riley	teacher1088567	19	+79312227643	\N	t	f	2022-12-25 16:24:10.246324+03
109	teacher109@gmail.com	$2b$12$0.yua/TA3SsejHgxCqZUL.OijG2ALw0piUGovEfaxraPvzoRKeMY2	teacher	Jacob Perez	teacher1095228	25	+75427388646	\N	t	f	2022-12-25 16:24:10.453537+03
110	teacher110@gmail.com	$2b$12$oPUyyg5NkEETNpU2qemzoev0CrzNee4izY9iniJKyG3/f3yJxjzRC	teacher	Maria Carroll	teacher1107594	24	+78322260223	\N	t	f	2022-12-25 16:24:10.665742+03
111	teacher111@gmail.com	$2b$12$UEcq/6ZuvrVc75bJOe9ifOwK4cdsGOszyaC1EcLsaoaSJ2pjC5Fdu	teacher	Kathleen Marsh	teacher1119968	22	+78339551750	\N	t	f	2022-12-25 16:24:10.876695+03
112	teacher112@gmail.com	$2b$12$IV2RqU1Y63kQPuZ1jDWIG.OrMbWNMsVzLnWIXL9Y0ROCan17RRUoq	teacher	Steven Moreno	teacher1125380	24	+70321922458	\N	t	f	2022-12-25 16:24:11.080213+03
113	teacher113@gmail.com	$2b$12$YpmGPNnJhK7JYJlQ3EulyOBqYggbYRSPpICdwt8VCUz.PvTOpgHMe	teacher	Jerome Schroeder	teacher1133320	22	+73931817849	\N	t	f	2022-12-25 16:24:11.285851+03
114	teacher114@gmail.com	$2b$12$uYoJvssg5/BuOU/cOfKwA.voiU/Alk.QRh.kr6NAXouOHQpMDM.TG	teacher	Mary Blackburn	teacher1146902	24	+76542557409	\N	t	f	2022-12-25 16:24:11.489821+03
115	teacher115@gmail.com	$2b$12$JJoMFCZsDP07X29o3qD3h.M7RMLeTPXExawleQOmnUFRHeeqWYFpG	teacher	Matthew Porter	teacher1153481	18	+73733948207	\N	t	f	2022-12-25 16:24:11.693286+03
116	teacher116@gmail.com	$2b$12$tFcjZtIBbunigEDxeTsY.extUMnUQUS7FeAbxwYCaZDL5YwRBf1T6	teacher	Jessica Avery	teacher1168226	18	+73758955152	\N	t	f	2022-12-25 16:24:11.908173+03
117	teacher117@gmail.com	$2b$12$ZBhwhVUCPjBtNtEWO/Qyve8CSxPx25xfpsvjWZIVpH3enk8Ka6Jnu	teacher	Sara Coleman	teacher1178165	20	+76290086095	\N	t	f	2022-12-25 16:24:12.112544+03
118	teacher118@gmail.com	$2b$12$aR6W6NEEUAU3ydXKHVIg0e7LPhCW4aXwg4icFDuImQloU2pjw6PVS	teacher	Crystal Buck	teacher1185159	22	+76531724474	\N	t	f	2022-12-25 16:24:12.324626+03
119	teacher119@gmail.com	$2b$12$WGnlgRec96QLP46awuwY4.64hg8q5.vJ2/o4fReuwsZlSizSPFjXK	teacher	Michele Williams	teacher1193537	20	+72592677767	\N	t	f	2022-12-25 16:24:12.532949+03
120	teacher120@gmail.com	$2b$12$XFgQQTVZ12Ytxhi0S0NDJuLlBnf8sbpf7ZXkLa/mGFpQ6JZ8J0zSa	teacher	Victoria King	teacher1204322	20	+73215235855	\N	t	f	2022-12-25 16:24:12.745673+03
121	teacher121@gmail.com	$2b$12$LdcfAZpGk4uDTAWIAmSbq.B.hmv//ThZ6pmR1K.bHifuB6lFIe0FS	teacher	Robert Kent	teacher1219557	20	+73552502329	\N	t	f	2022-12-25 16:24:12.949018+03
122	teacher122@gmail.com	$2b$12$Aj.pXxk0TCQVCH9lhQ5/X.bWa38NeytrRzplV3wiOdn5X9EF/Ygc6	teacher	Ashley Stevens	teacher1224105	24	+75604847367	\N	t	f	2022-12-25 16:24:13.159122+03
123	teacher123@gmail.com	$2b$12$qsRQxlWawNxyBlRHV3mYeeQdoe5cTwwlStzaAV4SfekI5RuHiIb1y	teacher	Heather Lopez	teacher1231095	22	+77332735528	\N	t	f	2022-12-25 16:24:13.368827+03
124	teacher124@gmail.com	$2b$12$q7p2IGJpqyauEwrR.QhHOuPxxwk4/GvB3CYLzZeaa5GuKzkHXM0qm	teacher	Jorge Singleton	teacher1249327	24	+74151280389	\N	t	f	2022-12-25 16:24:13.584578+03
125	teacher125@gmail.com	$2b$12$p7ybOslpSpL43XOqL4aXXO7kb5T1RGgkz2.2302tGOl6ujo11Rg5O	teacher	Jean Hudson	teacher1253419	25	+77393808172	\N	t	f	2022-12-25 16:24:13.79126+03
126	teacher126@gmail.com	$2b$12$YFxjiidVf4S23ear3skFkeesdehHQuB8BMDE8nFLy4hJvtG6kIYJu	teacher	Michael Delgado	teacher1262751	23	+73132049351	\N	t	f	2022-12-25 16:24:13.997326+03
127	teacher127@gmail.com	$2b$12$yiny2svBx0sCtXsZV7fZyeWRYzZdf/Lzee3ettzPVqDBhTAlAmT1O	teacher	Hunter Marquez Jr.	teacher1271758	22	+76266559787	\N	t	f	2022-12-25 16:24:14.199485+03
128	teacher128@gmail.com	$2b$12$0xEXhKWQShO63umcJ1AB/upZNQkHpTAAQBm/8h2krVxe1ePKHQjPy	teacher	Michael Wood DDS	teacher1286544	22	+76480867150	\N	t	f	2022-12-25 16:24:14.406562+03
129	teacher129@gmail.com	$2b$12$iXgR.s0tX7t5h0dSDWfkRucfxbMh9qB55Rq/DoZ.429dAPJ0WWtW6	teacher	Lindsey Briggs	teacher1291865	23	+75260499360	\N	t	f	2022-12-25 16:24:14.611708+03
130	teacher130@gmail.com	$2b$12$mIdjMSc37B5fAZlqTEojJOGqLFtjPlzZfjmNAORnA8Kr1cDrq7npK	teacher	Michael Hester	teacher1307917	25	+76700483974	\N	t	f	2022-12-25 16:24:14.816718+03
131	teacher131@gmail.com	$2b$12$8XIyZrMa4UY17dHeXnxW2ufUUtSF7E6f2D55wNZhs26BlzNrmyxp.	teacher	Mark Cochran	teacher1315702	18	+75879104893	\N	t	f	2022-12-25 16:24:15.020143+03
132	teacher132@gmail.com	$2b$12$vXOXrc87C8ri1uI9oZbhiu1vPXwG/oUcv2kR0T/kfVdTU5sGwfT/2	teacher	Martin Vasquez	teacher1329816	18	+71003704123	\N	t	f	2022-12-25 16:24:15.225376+03
133	teacher133@gmail.com	$2b$12$sPJcsAFM0JhWFhJOMVPh5elZUcNN7bbWcqu8AALhq.7TkcpMhlp/u	teacher	Bob Lawson	teacher1333738	22	+73633354670	\N	t	f	2022-12-25 16:24:15.432351+03
134	teacher134@gmail.com	$2b$12$Bh5sAYb1vJAJK6Y9be3Rp.5nFDWXNooUnoUc6FAjWkks7ru5cMFAK	teacher	Tracy Lam	teacher1343160	20	+73643501230	\N	t	f	2022-12-25 16:24:15.637241+03
135	teacher135@gmail.com	$2b$12$SfcNUp73ZlKeF/tSW2zIa.zTdnfdmCJjn/PxP4OUGiS1JeCh8mPNG	teacher	Jacob Griffith MD	teacher1353024	21	+78801934048	\N	t	f	2022-12-25 16:24:15.852765+03
136	teacher136@gmail.com	$2b$12$5YW31v0o7vrgcv2gB3uR3ef.UFBkTX6bkakp55QdN55AwKsk0d6aa	teacher	Keith Newman	teacher1367613	22	+77866998098	\N	t	f	2022-12-25 16:24:16.064991+03
137	teacher137@gmail.com	$2b$12$CISV7tMGuOQFYEXUixapK.IyS1EcUCEucy/yM1Usv0aNNC28gmPeO	teacher	Krystal Henson	teacher1375785	22	+73270061466	\N	t	f	2022-12-25 16:24:16.277096+03
138	teacher138@gmail.com	$2b$12$QyYfgUggtMu2wOixX0n8veIsH6AuNHg9P4NgyB0FBJI6WiUV7WUy.	teacher	Lisa Anderson	teacher1387507	22	+76265351354	\N	t	f	2022-12-25 16:24:16.486053+03
139	teacher139@gmail.com	$2b$12$o2evJbR0kJ/j4Y5kGGmywOZvwLXEBHPDsxqvRuD99IwynxQWmKh8C	teacher	Joshua Ochoa	teacher1397671	18	+72993931847	\N	t	f	2022-12-25 16:24:16.6889+03
140	teacher140@gmail.com	$2b$12$yBB/WAo4WFF2B/0Nj36B.uWPJtxDs2PbUB6EFVIoG9k0hWPPuP28m	teacher	Samantha Sanchez	teacher1403809	22	+77734003045	\N	t	f	2022-12-25 16:24:16.892511+03
141	teacher141@gmail.com	$2b$12$BuIT5Gky5Gn9XNae17ijV./xCJ/Tt/iqYukiCt.8Vss7ut8L2LnSG	teacher	James Henderson	teacher1418767	21	+75454262615	\N	t	f	2022-12-25 16:24:17.097083+03
142	teacher142@gmail.com	$2b$12$lQLrLLbtCr3Cuc1l5TW0veb4sCHF7ZbryzA7Yu/nwz63TEZUb88Z6	teacher	Kelly Gregory	teacher1423074	19	+74098562188	\N	t	f	2022-12-25 16:24:17.307533+03
143	teacher143@gmail.com	$2b$12$gCaXfX/.PqsZIByzxqojT.fAkXQKIMie6OAmHoC5R/iJrPdlC64oq	teacher	Michelle Freeman	teacher1433890	21	+72818730984	\N	t	f	2022-12-25 16:24:17.511416+03
144	teacher144@gmail.com	$2b$12$uFakCganmXhO2/nJPrSEveyvCoGU54oz6hT9l7icsyr85sjgM9c3W	teacher	Melissa Pugh	teacher1446556	24	+70090560912	\N	t	f	2022-12-25 16:24:17.71551+03
145	teacher145@gmail.com	$2b$12$v7kk8ZDUMc1YXz8Ksr1VXeNWsWbfTyH.MFnp4I/0E1pXlbJ08ijRS	teacher	Jonathan Thompson	teacher1456753	24	+76097625990	\N	t	f	2022-12-25 16:24:17.919183+03
146	teacher146@gmail.com	$2b$12$SOfKn6UdHANQdawxI7feJOgwPm2oq23j/b.6OabL4tvj71sObSftW	teacher	Dr. Larry Mcmahon MD	teacher1462734	23	+79673104859	\N	t	f	2022-12-25 16:24:18.123696+03
147	teacher147@gmail.com	$2b$12$.jCLKNmTKQr8dQ4chWF0Hubml.sA2r1mQzvD5x5Jgng7XaTxgotKu	teacher	Alicia Smith	teacher1477090	22	+72868562734	\N	t	f	2022-12-25 16:24:18.329286+03
148	teacher148@gmail.com	$2b$12$ysxhSkh4zbM3OVtShNv8JuEtJjNh76xk/I1yxb9Eky4rNyTJuf54W	teacher	Scott Lozano	teacher1481535	24	+71477237514	\N	t	f	2022-12-25 16:24:18.532282+03
149	teacher149@gmail.com	$2b$12$rKV96U6VlIlumDX/1N4TJuOfNSZ.8GLfDuZVhNKm6FFy199Y/PrwK	teacher	Timothy Price	teacher1493020	23	+75389713543	\N	t	f	2022-12-25 16:24:18.736627+03
150	teacher150@gmail.com	$2b$12$M6rwwAMAFpUnDR80yfrlRurCY8FrPDBYgD4Hhaaz3GTCQsbJWc23W	teacher	Lisa Pearson	teacher1501283	20	+74850327567	\N	t	f	2022-12-25 16:24:18.939401+03
151	teacher151@gmail.com	$2b$12$tBNU4HKqd4Zx68D/gO0t4Oecu7RBTr/fMMBBNL4NW/1EljFW8rpx.	teacher	Denise Ford	teacher1519289	18	+76769353184	\N	t	f	2022-12-25 16:24:19.146779+03
152	teacher152@gmail.com	$2b$12$hZe0pOslA7.JgQHu2fu4j.medp2AcR13BllMghyXJ1zaz2klO3V52	teacher	Michelle Hopkins	teacher1529361	23	+71455035615	\N	t	f	2022-12-25 16:24:19.350938+03
153	teacher153@gmail.com	$2b$12$E6J6PRQRxKtvOI1FnC1Pkebo1ZE9tnOL7M9GBu5JPZCCam8yduD6a	teacher	Tammy Jones	teacher1536015	22	+79232679896	\N	t	f	2022-12-25 16:24:19.556318+03
154	teacher154@gmail.com	$2b$12$toBb5/76RfU02kKcBXfxSOpgjv1PdfAFcFmgCNw04rxrgaRbUWOxm	teacher	Justin Davis	teacher1545962	24	+72991416539	\N	t	f	2022-12-25 16:24:19.761016+03
155	teacher155@gmail.com	$2b$12$MjRwIw1tAaWHQSEcSPYfpO4YzXz9vvi/VIC7qtiqvx3q70nK8yTh6	teacher	Scott Sellers	teacher1552537	19	+75731420992	\N	t	f	2022-12-25 16:24:19.963838+03
156	teacher156@gmail.com	$2b$12$nQV4eEznbFK1H6l1u40Pc.7mM/UxfuIWmDW2p1LKJ9b4QhNWgQs/O	teacher	Michael Orozco	teacher1569543	18	+72981659113	\N	t	f	2022-12-25 16:24:20.169534+03
157	teacher157@gmail.com	$2b$12$R4dXrs21dAXUJr5LYpDifeNq9srgt9oHWCyMAspv.yrvUtBryWsBW	teacher	Samantha Green	teacher1572524	20	+70734294340	\N	t	f	2022-12-25 16:24:20.37529+03
158	teacher158@gmail.com	$2b$12$TbGQ3HGJUx5oAoQjrJUEGuua/gP8mC6xrKJzrasrm03ODJdZYJW4S	teacher	Karen Arellano	teacher1586254	23	+75314531474	\N	t	f	2022-12-25 16:24:20.579211+03
159	teacher159@gmail.com	$2b$12$6g4UtUd4yFEEVZIvI5Ny8uWEkHwz1ALF94QjB0xacepY5zrg70yAi	teacher	Lucas Pacheco	teacher1597608	20	+70682072560	\N	t	f	2022-12-25 16:24:20.783595+03
160	teacher160@gmail.com	$2b$12$TG0LP3rozhvadclxLGMhSuiOmK4dqQUlHJMxcbURjRhutN56a6Iai	teacher	Jamie Hernandez	teacher1605259	24	+73759117062	\N	t	f	2022-12-25 16:24:20.986978+03
161	teacher161@gmail.com	$2b$12$qvq.FEvbmw0WiePddfDFKe8j15WD0u7v.zNiiJpXmgLl6Cv4ybWb6	teacher	Michael Oconnor	teacher1611989	19	+73301533036	\N	t	f	2022-12-25 16:24:21.191072+03
162	teacher162@gmail.com	$2b$12$t89V/rKd4BTtI3o8EAYsGe63WzOr4pb0GkTh871j8BBf.WqTJt98K	teacher	Alicia Green	teacher1627151	19	+73511371384	\N	t	f	2022-12-25 16:24:21.39855+03
163	teacher163@gmail.com	$2b$12$tJVbIl7GrhqnoWlnVfFjRe9OhHWgzT5dk1cUYfwxxuIK1ftnwbt/C	teacher	Peter Wright MD	teacher1638766	22	+76421555993	\N	t	f	2022-12-25 16:24:21.602817+03
164	teacher164@gmail.com	$2b$12$/eulW79fLX90SjlqfI7S/uKOWeMyfRmqU3OW2Inu19/2HmEIOKhfe	teacher	Mr. Daniel Kirby	teacher1641408	18	+74663435969	\N	t	f	2022-12-25 16:24:21.80813+03
165	teacher165@gmail.com	$2b$12$cMEGH2WrSMOVtW6oj6Y.UuJkPcRocZWfFb2aOjcDAjSPZB6mfM/Pi	teacher	Kevin Jones	teacher1659744	19	+72020347270	\N	t	f	2022-12-25 16:24:22.012809+03
166	teacher166@gmail.com	$2b$12$St5rFvmd3xVuDcCHUEwfAebMS0PJnpu.2tUDhm35W3jG.ViuBu.Ie	teacher	Kristin Torres	teacher1666031	24	+73372577576	\N	t	f	2022-12-25 16:24:22.216618+03
167	teacher167@gmail.com	$2b$12$DZZPaUJNc0eGN8Pt05lBPOGHSB57BDlsTVzZ/EqIJXWyXwLK49N.e	teacher	Crystal Lara	teacher1675882	20	+77343655009	\N	t	f	2022-12-25 16:24:22.42313+03
168	teacher168@gmail.com	$2b$12$VlH/QDoAAGecFXmcTCR7rO6flAPTwdCoYcEnX90r4GxjriKe5yQ4q	teacher	Joshua Peterson	teacher1688399	24	+70433307463	\N	t	f	2022-12-25 16:24:22.631776+03
169	teacher169@gmail.com	$2b$12$oMDCmKPw3qTDTh9Xul0c.umXCLlsoWtk2Pj4J4EXOUId6isIRViCy	teacher	Sarah Clarke	teacher1693234	25	+72422106640	\N	t	f	2022-12-25 16:24:22.841334+03
170	teacher170@gmail.com	$2b$12$.BVQfmqNKXY8axStdf1tE.oCh9LnbUu3aXutWavOAO5NW63HFlJee	teacher	Kevin Dalton	teacher1707435	22	+74707873885	\N	t	f	2022-12-25 16:24:23.044586+03
171	teacher171@gmail.com	$2b$12$EVmwx8FzP9sQkbG80gzske85GeXYxYgCi0NzMe.Wqmm6nqeKbb9NK	teacher	Nancy Levine	teacher1712429	18	+76207868455	\N	t	f	2022-12-25 16:24:23.248368+03
172	teacher172@gmail.com	$2b$12$FD/Y6HDXhX4NFGaQbE3zfu3Z4IXu2e0GxTpJUxqHeIaaK3wOecgtO	teacher	Jennifer Swanson	teacher1728941	21	+70086266184	\N	t	f	2022-12-25 16:24:23.452437+03
173	teacher173@gmail.com	$2b$12$a2f196y62mYRd4HD31tRKeWBFjaUyTdpt4Rev6IauvEk2d28yXaW6	teacher	Robert Morgan	teacher1739444	25	+70454540594	\N	t	f	2022-12-25 16:24:23.656517+03
174	teacher174@gmail.com	$2b$12$o3ZlAA.3zbR1WFS3Mfoh3eolsT/Qsb.8/evSfFFtxmL1Nf/J5ytvG	teacher	Danny Gonzales	teacher1747600	25	+74745758320	\N	t	f	2022-12-25 16:24:23.86027+03
175	teacher175@gmail.com	$2b$12$YBenUkx7LzxucCrGv996Y.5StvXxDnEhXu2uLZxLqMd7iGqHqGGsa	teacher	Rebecca Ellison	teacher1751211	23	+76224992848	\N	t	f	2022-12-25 16:24:24.062037+03
176	teacher176@gmail.com	$2b$12$k292ggxnADM0ef/UNxQHJuCRL4O8HMm/UIL027koXxffslyWZzvam	teacher	Steven Morrison	teacher1764338	20	+76840770363	\N	t	f	2022-12-25 16:24:24.266999+03
177	teacher177@gmail.com	$2b$12$7UUtWiIkIpUrNhB1/p.zHe//s4svaKyNRCoQZ4VujB036RdLZZkTu	teacher	James Schultz	teacher1776726	21	+78969209383	\N	t	f	2022-12-25 16:24:24.46855+03
178	teacher178@gmail.com	$2b$12$DNh9GD.08xG2GaRr8C5LzeTqgJ.2YQvOvAzQL4IMsewlrqQNWlITC	teacher	Natasha Silva	teacher1785779	21	+79770628646	\N	t	f	2022-12-25 16:24:24.671452+03
179	teacher179@gmail.com	$2b$12$e74FPC2g2Cj9ohBOE4ioEOYeubdLEG5ii5f71YFXgsHk/UJruWOwa	teacher	John Whitney	teacher1791769	23	+70627510629	\N	t	f	2022-12-25 16:24:24.880221+03
180	teacher180@gmail.com	$2b$12$kxwnjOWkqPhqjnhbQMJkZeOBpTbjOp/cOZbpeVNlPvyO5Sfm7S4Mq	teacher	Julie Keller MD	teacher1806185	25	+77256980149	\N	t	f	2022-12-25 16:24:25.082548+03
181	teacher181@gmail.com	$2b$12$skK4JycgTaKwipF5xQmiCe3x04aKCkch8er0.l9HW2qdmjPwEbteG	teacher	Kristin Salazar	teacher1817919	24	+79053002478	\N	t	f	2022-12-25 16:24:25.287233+03
182	teacher182@gmail.com	$2b$12$kqx1zWWWHff03PKESPbtQuXRuRg8sh06YZVTuUFPDPfaqlLRx2FMS	teacher	Joshua Freeman	teacher1827259	21	+77247829548	\N	t	f	2022-12-25 16:24:25.492055+03
183	teacher183@gmail.com	$2b$12$anJGbaQ8O3KXMsRqaa4ace0fAaz5lSDMTEzDoqJUAr1S8rrMBSGzC	teacher	Jennifer Landry	teacher1834993	22	+75923239382	\N	t	f	2022-12-25 16:24:25.696158+03
184	teacher184@gmail.com	$2b$12$72rd4Y96WAHBe.VunrhKGOuxs/nPpHNY72DxwmswvKz28f.NiPgde	teacher	Gabriel Davis	teacher1848457	22	+77920852953	\N	t	f	2022-12-25 16:24:25.900262+03
185	teacher185@gmail.com	$2b$12$3AKJdNOkoy9RPSmkGCXcP.l1JiZpCh8F13xJcjlyqDM6y2Cz1GuSe	teacher	Jacqueline Horton	teacher1855927	22	+79246363980	\N	t	f	2022-12-25 16:24:26.103053+03
186	teacher186@gmail.com	$2b$12$mQ0IoJl0lNQNPeQ4moFdhucRa7jOt9sZ6g1HXkOdJEm0dM6bd9bl6	teacher	Sarah Conway	teacher1866104	23	+79461757085	\N	t	f	2022-12-25 16:24:26.306376+03
187	teacher187@gmail.com	$2b$12$WLggx9sueNOpvurfBE2XH.9svlrETQVMwzNgC50if2dzcIT7JcFP6	teacher	Denise Gomez	teacher1879250	19	+75365165129	\N	t	f	2022-12-25 16:24:26.51006+03
188	teacher188@gmail.com	$2b$12$3qa.PUa9h/7Pq0khQk3/zOua6D/zQg5CgZWe6h31DOm2rtvReC/.e	teacher	Tina Roach	teacher1883109	21	+72011005640	\N	t	f	2022-12-25 16:24:26.712349+03
189	teacher189@gmail.com	$2b$12$6AGNLlaBEoXSF9pifmIOJ.ZzquGI58ed8/Uc66TaLj9lLNRGnKjLK	teacher	Zachary Huffman	teacher1895578	21	+77310671269	\N	t	f	2022-12-25 16:24:26.914203+03
190	teacher190@gmail.com	$2b$12$Si2cQ2KkbHG/zYaZzVCvguz6Ct14caSpfzX1m9K86dtlAyUmm13DW	teacher	Ronald Aguirre	teacher1907889	22	+75902006506	\N	t	f	2022-12-25 16:24:27.124489+03
191	teacher191@gmail.com	$2b$12$uOJ.uyCrbscYZ3iqgpho1.rcL8ZNQjqPHZ.3BjphowUO76qElaXXK	teacher	Joyce Kim	teacher1918787	22	+78897147180	\N	t	f	2022-12-25 16:24:27.333665+03
192	teacher192@gmail.com	$2b$12$2tTyIMM707OCXY6gtKLwVe4C.8dtp3ENinKA9H8RoNPgCVPJ5Frwi	teacher	Juan Anderson	teacher1929464	19	+72035551352	\N	t	f	2022-12-25 16:24:27.538018+03
193	teacher193@gmail.com	$2b$12$TuheBeai6r1Ev4.guzKFwOx3o2tOqTd77HwROrE1C/hghgjRsx3Ca	teacher	Cheryl Davis	teacher1938333	24	+71199595198	\N	t	f	2022-12-25 16:24:27.739968+03
194	teacher194@gmail.com	$2b$12$HxuZ1OHU.4m0II8tT6LnZ.AyhfS6i4TcAS8dRpwac30tyH/evxmcO	teacher	Anthony Hall	teacher1944871	20	+78093227990	\N	t	f	2022-12-25 16:24:27.943297+03
195	teacher195@gmail.com	$2b$12$kmfl/YFCQMzW/xFAHijgt.D/NZqJ49GC/Vob.Swpn/e4N0oPTLLJS	teacher	Timothy Ewing	teacher1952143	24	+78429373052	\N	t	f	2022-12-25 16:24:28.152651+03
196	teacher196@gmail.com	$2b$12$xkFTq7nmSPFw/eM6eUXRU.Ai76ganYGWTYjWhe1r1oCUD9gNxnSAC	teacher	Cassandra Kim	teacher1966113	18	+77039015550	\N	t	f	2022-12-25 16:24:28.360114+03
197	teacher197@gmail.com	$2b$12$zCUWYlpRWDKqKL3NQqktI.pDDgxQRBkCdNjtxx1sX4S6neNUgunlC	teacher	Timothy Thomas	teacher1974400	21	+74761029427	\N	t	f	2022-12-25 16:24:28.575721+03
198	teacher198@gmail.com	$2b$12$uxl7MlWAm/ccY02IjG5rV.C6Ar2cK6xvi.oBxyLosc3AbsejSArme	teacher	Sheila Adkins	teacher1981320	23	+74221929660	\N	t	f	2022-12-25 16:24:28.790126+03
199	teacher199@gmail.com	$2b$12$h.FH4uWzQCF2xq6ugawJouRy.WPRyfSnnPpasyTDVpS/Vw59L.PLG	teacher	Thomas Rose	teacher1997562	24	+77402441140	\N	t	f	2022-12-25 16:24:28.999838+03
200	teacher200@gmail.com	$2b$12$1FecTVgsRT.18ya.yfkZreLHcIxAZjR7XCsVPqgRm0kgDdKoN34au	teacher	Donald Harris	teacher2004118	23	+77204352282	\N	t	f	2022-12-25 16:24:29.210763+03
201	teacher201@gmail.com	$2b$12$lypn/1yGg2nRzjugeRbd/e9/4fvbUa73Pb1uQjmdCvEbzrQhX.0da	teacher	Colleen White	teacher2013495	24	+78900044264	\N	t	f	2022-12-25 16:24:29.418548+03
202	teacher202@gmail.com	$2b$12$AvcgevxaYpmiOiJAE0N2oexaXfdoDnBMY3.4eWISGNWSECbjD/Pnq	teacher	Emily Lowe	teacher2021618	23	+78890829275	\N	t	f	2022-12-25 16:24:29.623239+03
203	teacher203@gmail.com	$2b$12$vSQkGMf8la5uPua8FQsrkOX58vo2WyZwRz0Ibmd00R0OjYwg8aR6W	teacher	David Collins	teacher2034235	25	+74868444204	\N	t	f	2022-12-25 16:24:29.828738+03
204	teacher204@gmail.com	$2b$12$zmuYqKKjDbLyUymrkgj/YuiQ4AeIBVbFvdo0ArbsGrEMLAIOpRopS	teacher	Jessica Jones	teacher2047900	18	+74018957245	\N	t	f	2022-12-25 16:24:30.03352+03
205	teacher205@gmail.com	$2b$12$COtkgTcXBw5zwmCE8rE1xe3p8h/G86ac75SU0y46HNDAEilh8grSC	teacher	Andrew Henson	teacher2056433	20	+73977478822	\N	t	f	2022-12-25 16:24:30.235725+03
206	teacher206@gmail.com	$2b$12$r/PbJGJ.mwp1nuQHd0yFXO23XO0o359jZvY.fNrZN46/NKDXJCcMK	teacher	Joshua Stewart	teacher2068854	18	+73137962526	\N	t	f	2022-12-25 16:24:30.44035+03
207	teacher207@gmail.com	$2b$12$7vWiY3YxGLKRXE3jNylYNumgJJ0S15qEmseJGky2THzYTM9gtyCiK	teacher	Dustin Clayton	teacher2076280	24	+78320015792	\N	t	f	2022-12-25 16:24:30.641917+03
208	teacher208@gmail.com	$2b$12$0mjQj7vjf0kD4b1L3Hdhm.uMMv3gmMsIa0mWl9MK7bwW99mMYHLOq	teacher	Matthew King	teacher2088605	23	+77699900600	\N	t	f	2022-12-25 16:24:30.84761+03
209	teacher209@gmail.com	$2b$12$TNUtkpjIaTbMkB621w8bgOdsNbXn1CVYYcGSwEA8UQodtQ7qkzOvG	teacher	Darrell Neal	teacher2093188	18	+75180867355	\N	t	f	2022-12-25 16:24:31.049549+03
210	teacher210@gmail.com	$2b$12$lqHuGl7yFOqy2mbd7Ir06.4jEjFiVdU.zo6p5G/0jHo1Svm5OhFNi	teacher	Matthew Brooks DDS	teacher2104850	22	+74984729683	\N	t	f	2022-12-25 16:24:31.251862+03
211	teacher211@gmail.com	$2b$12$IlAOmchkZqZkJgZ5o4RFF.cI2OaawAZrPHnPPmayJIcCw0xuZn7gS	teacher	Jonathan Sanchez Jr.	teacher2115353	20	+77221307301	\N	t	f	2022-12-25 16:24:31.471374+03
212	teacher212@gmail.com	$2b$12$fwq5AI34acjqQqZTVVVJzuI3ArojPusYFX7.1lwfP7XolBJpkKYDK	teacher	Ricardo Vargas	teacher2129281	23	+70145885035	\N	t	f	2022-12-25 16:24:31.676019+03
213	teacher213@gmail.com	$2b$12$dozo4Efuq2A5bnphKpyrq.5g0e4Rc30DlH38uVn.R4PVtpAy4zClS	teacher	Linda Murphy	teacher2134542	20	+73279162715	\N	t	f	2022-12-25 16:24:31.881007+03
214	teacher214@gmail.com	$2b$12$9GHL7DyXsALJwHZ8vafU9uZPMudzNNUhrGfrq3vgaHZhtCVWAkYpS	teacher	William Haas	teacher2143588	22	+74517986157	\N	t	f	2022-12-25 16:24:32.084632+03
215	teacher215@gmail.com	$2b$12$nsW5mUqc.JCne88OrgN3E.3Gh19WFpYrAHs6zmosBEVTiLQo/ck8i	teacher	Martha Drake	teacher2154764	23	+73479211184	\N	t	f	2022-12-25 16:24:32.295106+03
216	teacher216@gmail.com	$2b$12$QkVdsSxMq0mtQJaec2fYSeWPvKg9NUzC2OrnpBhsmIv0LuWGzLuT6	teacher	Ian Palmer	teacher2169838	22	+78752525963	\N	t	f	2022-12-25 16:24:32.497523+03
217	teacher217@gmail.com	$2b$12$LG0RRuhaaLd3UKex99mkSuPOFg915kBUXHu6VjjMYts1NSuNpzayy	teacher	Lauren Lee	teacher2178424	18	+72569456565	\N	t	f	2022-12-25 16:24:32.702168+03
218	teacher218@gmail.com	$2b$12$RcerxiP2HsMSweXKv3/RiepYjHSv1PX/zQOVYYV.uqal.XdnW9M6e	teacher	Terri Deleon	teacher2189333	20	+73397483178	\N	t	f	2022-12-25 16:24:32.907588+03
219	teacher219@gmail.com	$2b$12$5luuIeiImskgrBKo3d6iDun7lDdGxsMRl6470JPtugSZ64v2vGU0a	teacher	Amber Blankenship	teacher2199334	19	+77130689706	\N	t	f	2022-12-25 16:24:33.11077+03
220	teacher220@gmail.com	$2b$12$RGw27NCXrJBdvyrtfkbEruyJC4Jhf81xRfDlgA.9WzrdWkpWXtdym	teacher	Kathy Gomez	teacher2204902	20	+74611247749	\N	t	f	2022-12-25 16:24:33.316479+03
221	teacher221@gmail.com	$2b$12$nLQvw9bejfzZ7T6tfVrLauJMcsTJKm38qdTnzA4acDbDwXpFmX5O6	teacher	Steven Blevins	teacher2215995	22	+70182209468	\N	t	f	2022-12-25 16:24:33.519213+03
222	teacher222@gmail.com	$2b$12$HJqxT38XXfkvgfL34zASf.P/LasDaZCYcaVqZaIad5vtxjUeRZwQi	teacher	Thomas Hudson	teacher2222197	22	+78100092161	\N	t	f	2022-12-25 16:24:33.723637+03
223	teacher223@gmail.com	$2b$12$ZRONtFgwUmGo/rNa/d4mzOvN191ocY.at6wtQ1kPjQQg6xB4LrCNO	teacher	Paul Harrison	teacher2231475	18	+71470555951	\N	t	f	2022-12-25 16:24:33.928187+03
224	teacher224@gmail.com	$2b$12$eDoDb0AW8.j29aPEaJNa4.NSU/7TMbJhup65B5HxWm2mUFViiQou.	teacher	Douglas English	teacher2243095	20	+73189652450	\N	t	f	2022-12-25 16:24:34.131249+03
225	teacher225@gmail.com	$2b$12$QNyiM1JMik2QDb5bbvCGPevxqCt8Aw/Dq8vnQxwcvhvnPTl.xqWtm	teacher	Gabrielle Johnson	teacher2254487	19	+74227331462	\N	t	f	2022-12-25 16:24:34.342252+03
226	teacher226@gmail.com	$2b$12$FZozjWYt.sYtxbDXihpzvOxLfEj1ghWmZh8/0mvWVhXI0g4g/.Jx.	teacher	Candace Phillips	teacher2266117	25	+70945702657	\N	t	f	2022-12-25 16:24:34.545753+03
227	teacher227@gmail.com	$2b$12$kGbvzhbbygaUYoNTyh34OO97cZhrsPG4tIOfWoIIQkRUjXNi9Sene	teacher	Stacy Wright	teacher2273179	22	+73050424156	\N	t	f	2022-12-25 16:24:34.760271+03
228	teacher228@gmail.com	$2b$12$w6cdAdI1DrZQ2jBdzPcWHOW961o8iQxVCUvMHfOmz7J0YA2wE/4fO	teacher	Mary Arroyo	teacher2286101	23	+74898079900	\N	t	f	2022-12-25 16:24:34.96465+03
229	teacher229@gmail.com	$2b$12$iB2exRw.iEvniMYVvxo8ruoUr3eeO/FMP2mHJ.vuwVmHpOz8HtzQ.	teacher	Kim Santos	teacher2295697	18	+74739493433	\N	t	f	2022-12-25 16:24:35.170138+03
230	teacher230@gmail.com	$2b$12$N/SnP1HUyRzpmcoppcDVAuWR8.pBarQUGncJ0jfltwfLPsDv.4PvC	teacher	Kendra Day	teacher2302764	22	+77558155001	\N	t	f	2022-12-25 16:24:35.388273+03
231	teacher231@gmail.com	$2b$12$vnhSyFEZnm7HyLj4Py1wzeyXKD7oDtcufg0wMmfUQANM4HW0cEgCy	teacher	Stephanie Barnes	teacher2314917	18	+73769917608	\N	t	f	2022-12-25 16:24:35.596016+03
232	teacher232@gmail.com	$2b$12$iwPUmSX/Qje9OfXzG72bu.OwX9F2TQUodbxixbfH672UQKpSJ5/XK	teacher	Lacey Rowland	teacher2322468	22	+70346020035	\N	t	f	2022-12-25 16:24:35.810346+03
233	teacher233@gmail.com	$2b$12$37wtJLeOXNUmUWUgYu/PgO7cSh6Fm2.ZfIc2DWJIL651NWpqm1xJ6	teacher	Jennifer Briggs	teacher2338720	18	+75030428158	\N	t	f	2022-12-25 16:24:36.021047+03
234	teacher234@gmail.com	$2b$12$OCS5G.UVzMUCWOYUX/Y1Ru49cfRBIgQrXkIiXD1ycgx4vWe71FRX6	teacher	Ryan Bradford	teacher2347379	18	+70873930672	\N	t	f	2022-12-25 16:24:36.224495+03
235	teacher235@gmail.com	$2b$12$roKqsHiR30Wd4U3GR0A6oOgr5ubDczdJFN7QHKN46D4eTzWIv1Mdq	teacher	Christopher Gonzales	teacher2357326	25	+76372955529	\N	t	f	2022-12-25 16:24:36.426757+03
236	teacher236@gmail.com	$2b$12$K1CT5IjtI8ZbbxKXuRBcieo0MiStEK.IbPGRG2cLsDFdhq3VQBp12	teacher	Sara Burnett	teacher2365403	20	+76968669451	\N	t	f	2022-12-25 16:24:36.628768+03
237	teacher237@gmail.com	$2b$12$gxx/hZMPKDg4NhvdpnUonuEAqtkxEAtruUUSAemItNeLdT3aKbW6y	teacher	Mark Wagner	teacher2374418	23	+79801211499	\N	t	f	2022-12-25 16:24:36.839561+03
238	teacher238@gmail.com	$2b$12$iKcCOtdHosxAmzO6dVavx.AU1GGjtYiQFNVLo/by/sxskynl0nysW	teacher	Lisa Jacobs	teacher2387546	21	+72045211491	\N	t	f	2022-12-25 16:24:37.043096+03
239	teacher239@gmail.com	$2b$12$jZosOnciEb48utBc0uQDeOccxORbO8dmY0vqXQH2RvP1Ud9jNNZTa	teacher	Dwayne Hawkins	teacher2391957	25	+72555065807	\N	t	f	2022-12-25 16:24:37.246948+03
240	teacher240@gmail.com	$2b$12$RQW2ItHezf1KP0WB2dMxsOaWoiBjS0KJdvqptOz8tpovOnUV/Exr.	teacher	Lee Robertson	teacher2409671	22	+72319975250	\N	t	f	2022-12-25 16:24:37.457416+03
241	teacher241@gmail.com	$2b$12$RfBEydPsMW8xIDI1ZvpNz.TQksbbw/6rG1iElSEbJ4j8IZa1bLNBG	teacher	Michelle Fuentes	teacher2417435	22	+75474194985	\N	t	f	2022-12-25 16:24:37.666683+03
242	teacher242@gmail.com	$2b$12$1aHqSxi5uXpL4GCZ2ML1e.ykeFVxjan57Z1YYjrD2MTxfX.8zJlyG	teacher	Jason Roy	teacher2421832	18	+70651581881	\N	t	f	2022-12-25 16:24:37.874366+03
243	teacher243@gmail.com	$2b$12$Z0ff/7MRywEV.WtYdR.nyOV3OqBulxhZaVYAs8YnrpnBSzopEgQAK	teacher	Christopher Cruz	teacher2432041	25	+72428833548	\N	t	f	2022-12-25 16:24:38.077078+03
244	teacher244@gmail.com	$2b$12$7MxdlJTcjjgKP2rZ1N/GyuEYBibUVU/sClaP7qiGHtwzem2RW7GEq	teacher	Shelley Garcia	teacher2443043	21	+79168527963	\N	t	f	2022-12-25 16:24:38.293074+03
245	teacher245@gmail.com	$2b$12$nLHN07n97rMXgCZO8i4K3uyumNl8bZfr9yQ7Ma0UQ/tL3hML.V5cy	teacher	Michael Rogers	teacher2458034	25	+71831625039	\N	t	f	2022-12-25 16:24:38.507085+03
246	teacher246@gmail.com	$2b$12$3PmCPqZYQJvTEg4y39d.T.oTWWW3agdNu.1ayt3DdnPPXByPS0lYK	teacher	Brad Newman	teacher2465668	18	+70048915988	\N	t	f	2022-12-25 16:24:38.717629+03
247	teacher247@gmail.com	$2b$12$wHBeTKc6dWC2GtuiSkAAWuSd5i2Otz6qwzhpRpZHjKSl.TYbZ5DC6	teacher	Carol Rios	teacher2471270	21	+75104121791	\N	t	f	2022-12-25 16:24:38.93117+03
248	teacher248@gmail.com	$2b$12$Af5IzQxhAcR17F4QP10qzeNK3mMmbMYsHqUn31HcDKyGO4bfjhqvy	teacher	Benjamin Madden	teacher2481830	19	+75150402511	\N	t	f	2022-12-25 16:24:39.132912+03
249	teacher249@gmail.com	$2b$12$bHS5B0YX2pI0AdHQTWKml.UqVgDvyLvn5LtkoqEWAYZbHZAdv33Ze	teacher	Robert Burns	teacher2495180	18	+78047418176	\N	t	f	2022-12-25 16:24:39.34844+03
250	student250@gmail.com	$2b$12$uHIgkY70iLKxcnSrA/0v9udltPVT3GAfT9OeROzMLNLo7Rz0FTiAO	student	Andrew Wong	student2509403	20	+75293307648	\N	t	f	2022-12-25 16:24:39.562168+03
251	student251@gmail.com	$2b$12$CbSlJOSqMS4JlgfD5uu8gOmIbKpQeLZxpK9i.BUP6d0hfQnZcfexi	student	Amanda Sandoval	student2519051	18	+76097016505	\N	t	f	2022-12-25 16:24:39.767418+03
252	student252@gmail.com	$2b$12$q/QZaeNZLu3BRTTJCVyazuV7ZsCvMol58c2A36nui5t4Fr.rIBGOW	student	Dale Lewis	student2522783	21	+78434142115	\N	t	f	2022-12-25 16:24:39.973157+03
253	student253@gmail.com	$2b$12$rbqISdqhQ4t7H6VNd.FqJeNl807dar1zy8AbOUpnx/vA/vvi/LWYW	student	Aaron Robinson	student2532560	21	+75589156298	\N	t	f	2022-12-25 16:24:40.187094+03
254	student254@gmail.com	$2b$12$IHxxBTjTPq.GiDQbAWpNKO9O2434fH/3dhkFXDRYLz5lrhlVkgHOS	student	Breanna Schwartz MD	student2545638	21	+77419939418	\N	t	f	2022-12-25 16:24:40.393717+03
255	student255@gmail.com	$2b$12$mBnszWfhd5uyA8aWQSfAueaWGMotNHyxFPENCY5iHW5FRU1MbSe9G	student	Kyle Walker	student2551219	19	+74044488637	\N	t	f	2022-12-25 16:24:40.61487+03
256	student256@gmail.com	$2b$12$WDUfOX3mkB/sTxNavr9CcuBrYiEoJp8U2qgInt5CpipBWmB4IQFyy	student	James Fisher	student2568371	25	+77045041260	\N	t	f	2022-12-25 16:24:40.847919+03
257	student257@gmail.com	$2b$12$R49A2lMAF3j18tvK0nKNPO8jMA2YaszT9yLS0x6fIp5NWraXbM8Wi	student	Theodore Henry	student2579535	18	+72656148205	\N	t	f	2022-12-25 16:24:41.058428+03
258	student258@gmail.com	$2b$12$IFS/ENfiP5OrRh/rRQl5pOrd1j8ZVvXVJK533deRJuMHaPLB/PIqa	student	Lisa Woodard	student2584529	18	+76499369674	\N	t	f	2022-12-25 16:24:41.271946+03
259	student259@gmail.com	$2b$12$A0VWVzqe6N0vmpsSXPPWFewwoX7f6jq.T.yGklhM7ECGlvtCDnUzG	student	Michael Duncan	student2592603	20	+78394709121	\N	t	f	2022-12-25 16:24:41.485063+03
260	student260@gmail.com	$2b$12$fu.OA0eOh2KuyL6x/rps8uPnkyGZxBwZFJn3K2MWnLOLKbTDt.zwi	student	Steven Holt	student2606531	19	+71741125641	\N	t	f	2022-12-25 16:24:41.691262+03
261	student261@gmail.com	$2b$12$YPnI5FWPNcxNvLrPx8/2gul8xD1swwY3nwFt3UqSuk5rjkPuIlCnK	student	Bryan Jackson	student2614215	21	+70310341075	\N	t	f	2022-12-25 16:24:41.903677+03
262	student262@gmail.com	$2b$12$iY1VQ7sNNneoA/h/c/eBQONJS43SAqN6h63vj1Jo4Pla6rMVkCGFu	student	Mitchell Webster	student2625002	22	+70103448423	\N	t	f	2022-12-25 16:24:42.110889+03
263	student263@gmail.com	$2b$12$LS3cHF.zdzuKY81w1BRGu.xW8p2JGfEIc6Gte.3tBVnZF5fDlZq.2	student	Mark Thompson	student2637034	18	+70740470682	\N	t	f	2022-12-25 16:24:42.323102+03
264	student264@gmail.com	$2b$12$2bksWzXmdjCYraiS7tcli.soDWX.3XpNJNB11vhsMRe5Iu6Vs6eta	student	Jessica Wilson	student2645491	21	+73699752153	\N	t	f	2022-12-25 16:24:42.535026+03
265	student265@gmail.com	$2b$12$sbIjL3pDS04rXTAif0sdN.kA.J08VKnnS4KyfBAE7kMD3g3MZgnkq	student	Deborah Mayo	student2654976	24	+78922920519	\N	t	f	2022-12-25 16:24:42.746989+03
266	student266@gmail.com	$2b$12$YGjgV3V9if.xrNMJwTqyheOrv/l/VSCYBLmd02r4oKmrBvcoUUqu6	student	Sabrina Martin	student2662307	22	+71041174627	\N	t	f	2022-12-25 16:24:42.957137+03
267	student267@gmail.com	$2b$12$2RjqcX2H7JNmc2QRNSoijejBhTHIL79NXzaTfM.URqxVprVZbYQfm	student	Brent Murphy	student2679038	19	+77196612597	\N	t	f	2022-12-25 16:24:43.170539+03
268	student268@gmail.com	$2b$12$dShpte8im6SZQ8xisLzmuesFD86FC3h3xOhxyTaABCE.DLpPNb1ly	student	Andrew Harris	student2685246	18	+79097712973	\N	t	f	2022-12-25 16:24:43.385068+03
269	student269@gmail.com	$2b$12$DW199GCi.tAabsTrBkGpFOd4P.3lBkENT884CylE7dZFgWazG/dbi	student	Frederick Woods	student2692757	18	+72893066054	\N	t	f	2022-12-25 16:24:43.595095+03
270	student270@gmail.com	$2b$12$i2fuZ1DKNetF5ySiVRNkru9M/e3ZO93yZjeidf7owZcn4jWNuH1hC	student	Dean Bailey	student2702858	24	+78016461270	\N	t	f	2022-12-25 16:24:43.807033+03
271	student271@gmail.com	$2b$12$0NP4uKjQHPnC0BVRv0brpuOp4HLOEoUbv/gRGp1ABG7vPSHbOe64u	student	Michelle Henry	student2716525	25	+77064713908	\N	t	f	2022-12-25 16:24:44.018961+03
272	student272@gmail.com	$2b$12$yNzNTzt5Y4Nrm6WipGOJjO6fi73y.7XvwuT085fYInz73bFfxJnE.	student	Elizabeth Zavala	student2729865	21	+78970929693	\N	t	f	2022-12-25 16:24:44.230738+03
273	student273@gmail.com	$2b$12$GSSoDUcyWCwRpY4FcDxeb.Ero2tWZgx/K.2TcaWoCZ8lNlI2BFKy6	student	Madison Watkins	student2734044	24	+77235248438	\N	t	f	2022-12-25 16:24:44.443474+03
274	student274@gmail.com	$2b$12$eALDuDuYMRfjr388p7Kdh./iZ83UZzobICTTR7XHegf5OQX2jYtsu	student	Michael Larsen	student2743910	18	+74830266680	\N	t	f	2022-12-25 16:24:44.654479+03
275	student275@gmail.com	$2b$12$iCfZZ/0wyzKuQJjpJCkgROHucxPAQh2PUFIekk6NUvD8SjG8/n4/u	student	Tracy Dawson	student2752882	24	+71046789026	\N	t	f	2022-12-25 16:24:44.868629+03
276	student276@gmail.com	$2b$12$Y0myGn0T9dbOxH7hvgFzMe4phCvoQ1PKIIehBpdaTDut3FIuOzzLe	student	Sarah Hicks	student2762978	21	+72806095445	\N	t	f	2022-12-25 16:24:45.07865+03
277	student277@gmail.com	$2b$12$XTV5wAQ4HWl5q5TvWJ.Z3eS1tYVu9UFNl1SZK4EGjo/D/AUvioCFO	student	Greg Smith	student2775348	20	+79332873715	\N	t	f	2022-12-25 16:24:45.296117+03
278	student278@gmail.com	$2b$12$EDEuY5ABdWEl19uAKvA/q.WKKabcfMhzCVlwj0.KSMSP92QbNG1JW	student	Marcus Harris	student2789832	19	+77721417676	\N	t	f	2022-12-25 16:24:45.513084+03
279	student279@gmail.com	$2b$12$e3SaFZTadhINtQoPPdpWiOZT8IkD2bgaYh0VqPn5lHtkHDZDmZK5m	student	Lisa Barnes	student2791666	23	+72459812190	\N	t	f	2022-12-25 16:24:45.727108+03
280	student280@gmail.com	$2b$12$whXoSq8GkBVTupVTTNZSKuEraZtBA9xszi20ZiCc97tsgUomMHTqC	student	Amy Hall	student2805483	20	+79367608485	\N	t	f	2022-12-25 16:24:45.943226+03
281	student281@gmail.com	$2b$12$F/n2z8TOCzcH7W51nGQ.YeDiY.v7KNSTH85GOB1hLb8GjZ13oPpCC	student	Andrea Ferrell	student2819359	25	+74156782494	\N	t	f	2022-12-25 16:24:46.161103+03
282	student282@gmail.com	$2b$12$Su.M9NcHr8egEEL7sfX3OeaFKPTVJA9rN576rGVmWsEt8JMlZovym	student	Matthew Nichols	student2825750	24	+79658019826	\N	t	f	2022-12-25 16:24:46.372228+03
283	student283@gmail.com	$2b$12$O.4PQ6FXfD/HdNYsuhqzau.OzfYUKrMIiVPd06QYz0wJAd1okfntO	student	Erik Frazier	student2836083	19	+70525122761	\N	t	f	2022-12-25 16:24:46.587343+03
284	student284@gmail.com	$2b$12$zHWYnGZq46g1c835XGqctOyLO6LhEZoN5eS1jpJ2bsgUiyRGBzmUe	student	Steven White	student2849784	21	+72128388515	\N	t	f	2022-12-25 16:24:46.794248+03
285	student285@gmail.com	$2b$12$Cc0nkjB1TyS3PI4xxpInSuoYd.ff1AdkarMSGIIDHG2f1CcYuASJ2	student	James Galloway	student2856511	18	+75110046725	\N	t	f	2022-12-25 16:24:47.00423+03
286	student286@gmail.com	$2b$12$ZD0Jf4m8zsqTNwWqf7Xl/u9/4yETpRMxc/eHIpnN2G5HGiRBNmF7a	student	Christopher Wallace	student2866381	21	+79614830299	\N	t	f	2022-12-25 16:24:47.219807+03
287	student287@gmail.com	$2b$12$wiaSUmncfKp5Qdo29GR/WOqHVPCycWSADv6fs3uEsN3fekASLgTKa	student	Andrea Gordon	student2871220	25	+72549189569	\N	t	f	2022-12-25 16:24:47.437378+03
288	student288@gmail.com	$2b$12$Mqgmp530OC5d/S6iTig4nuzN8Hbqt5MkOl//q9/DIPi2lAloWpuwe	student	Daniel Perez	student2883157	23	+74556090164	\N	t	f	2022-12-25 16:24:47.653232+03
289	student289@gmail.com	$2b$12$i9Qv0wOgCUSXD7rC7xS6AubUupd4PcBjCoumf8vUXbZ1q7TlXhQvG	student	Stephen Ortega	student2892743	24	+76986105318	\N	t	f	2022-12-25 16:24:47.858824+03
290	student290@gmail.com	$2b$12$RVBpiohxP.LimgUkHziJmeYJYv8vioX09lcpQ4rGBqmJbInQDbnfi	student	Anthony Miller	student2903972	24	+75000348933	\N	t	f	2022-12-25 16:24:48.063175+03
291	student291@gmail.com	$2b$12$EkHOejlc2a0MLvGit9JFyOQpNJbSp6swWvlVB4Uay2IdUXDoJq8P6	student	Dawn Monroe	student2918780	20	+73262475929	\N	t	f	2022-12-25 16:24:48.279318+03
292	student292@gmail.com	$2b$12$DW.w2N4EtSEGnpRVoa7qs.QZOx3OoHWharyvRivfT0NE741zieCGm	student	Ashley Salazar	student2926728	23	+74567855277	\N	t	f	2022-12-25 16:24:48.493526+03
293	student293@gmail.com	$2b$12$IEOaZbhDuxdXjE0MnUQhc.fTOH4IOwA.EZovjZIOUIfEnQod2Ls32	student	Stephanie Sanchez	student2939594	19	+78600985173	\N	t	f	2022-12-25 16:24:48.704378+03
294	student294@gmail.com	$2b$12$N9tYjhrX4K6y9woOVidHiuTVQkXtYrqkoB1af7MuW/4XM6SI8vCrK	student	Dustin Alexander	student2949908	22	+75958593917	\N	t	f	2022-12-25 16:24:48.927306+03
295	student295@gmail.com	$2b$12$tOWekK9saHOq3GiGvs.V5uhGOODVcaPSH2NRdAydX6BAAco37Xduq	student	Danielle Bryan	student2951798	21	+78118356258	\N	t	f	2022-12-25 16:24:49.155436+03
296	student296@gmail.com	$2b$12$miTMrCyyhRzPjLoZ8sAJyuzObn3WSh4np/laQzHqvQWyEEImty6kC	student	Zoe Martin	student2961629	25	+73237011093	\N	t	f	2022-12-25 16:24:49.376966+03
297	student297@gmail.com	$2b$12$pXEJ1trdb9kEjaN1R3BqoO8.Y4YMKqFwk8wAmbRW3TQ5etrgX3zvm	student	Sharon Cain	student2973852	22	+77361430628	\N	t	f	2022-12-25 16:24:49.585925+03
298	student298@gmail.com	$2b$12$1gaIxvGTg.pHQnlo5U5q8eVefa0iLvcP5gA7vnlcSobApWaJONdyO	student	Alexis Sparks	student2988603	23	+79308727401	\N	t	f	2022-12-25 16:24:49.789702+03
299	student299@gmail.com	$2b$12$0JjTcCWlU0SXoO.T0ZlsK.b7h8N5BB/faqzO0G9CqJOorWhxvA6dW	student	Keith Simmons	student2993498	19	+70670924229	\N	t	f	2022-12-25 16:24:50.005237+03
300	student300@gmail.com	$2b$12$rCazxse.jtOm6EFhppmDfegfBxcwHmYmH5JIlDUtkBnPA.p7XfwI2	student	Mackenzie Hernandez	student3005775	22	+78035805336	\N	t	f	2022-12-25 16:24:50.215641+03
301	student301@gmail.com	$2b$12$gG66alNsm1x8PkMnY6fB7uEUjuUtE7/A7lBt6CTgoqipwmd1LL70S	student	Diana Long	student3019916	20	+72292215867	\N	t	f	2022-12-25 16:24:50.426124+03
302	student302@gmail.com	$2b$12$BMprnS.vBdQ1mov5i844luBudNRATz1uXJtt4TwH.FeflPcLsMsAC	student	Christian Rodriguez	student3023569	20	+75941531068	\N	t	f	2022-12-25 16:24:50.636551+03
303	student303@gmail.com	$2b$12$OpMeQOQ3erQE3RbpadOYv.5aJ83SvSFTGR0IU9zP.BP7N8QkeeIVy	student	Christian Phillips	student3038705	19	+72958961336	\N	t	f	2022-12-25 16:24:50.844362+03
304	student304@gmail.com	$2b$12$.kDVha7U6a.6hcmkJDO2p.KPxfhT0RIFomC7Ygbs.HWbKrkEZC2fG	student	Melissa Webster	student3046342	24	+71496071953	\N	t	f	2022-12-25 16:24:51.059201+03
305	student305@gmail.com	$2b$12$N.sf9/HRCjdR/kHs4LlCLOCyEeVA3tDyzRHIEmWgYUrLmLbnPapIK	student	Jeffrey Delacruz	student3058261	22	+74207067974	\N	t	f	2022-12-25 16:24:51.268091+03
306	student306@gmail.com	$2b$12$I.d059WCaZ8Vj0ug9Xuc4eEjV1LMjDex7IQuaGkmSxK5LZQzvN0eq	student	Jamie Cooper	student3064767	19	+70336736789	\N	t	f	2022-12-25 16:24:51.479155+03
307	student307@gmail.com	$2b$12$eQRyNfP4Jb4WM50/S/UJ8unN04C4nfD7ztaGS4kI3gLl4CRDa6SOK	student	Michael Davis	student3071137	18	+72373456191	\N	t	f	2022-12-25 16:24:51.690971+03
308	student308@gmail.com	$2b$12$JT1sq2BNXlduN5uMgD8Hfu/9qOpTzgTkroh2qVAug/kAbWMxgZMyC	student	Grace Daugherty	student3082149	20	+70249758188	\N	t	f	2022-12-25 16:24:51.901352+03
309	student309@gmail.com	$2b$12$Daqd7dWRbJX.sy/TSXGM6uIuj1NH8NyB5cheZ0eGvk5u6Lhe2XTSq	student	Barbara Williams	student3091731	22	+78786430510	\N	t	f	2022-12-25 16:24:52.115115+03
310	student310@gmail.com	$2b$12$pGOWTm8gH30dh2z58uPhTuPtsB7ah42wUe9QCbUYbAJweAvBK9MXa	student	Zoe Bowman	student3108955	19	+71215550157	\N	t	f	2022-12-25 16:24:52.330469+03
311	student311@gmail.com	$2b$12$jCyRHi5U9jmghsa9BnK1DO/EYRydrP8ZDe8ZZfa12GCuXgzrt7fYm	student	Brian Jackson	student3119170	20	+77373659637	\N	t	f	2022-12-25 16:24:52.542084+03
312	student312@gmail.com	$2b$12$jyOU8MMQoF5QH2qsA3ndE.AW/Pm5welLD.QDElnKoeD0cUh2NQzoO	student	Christina Walsh	student3128162	22	+78585485998	\N	t	f	2022-12-25 16:24:52.750813+03
313	student313@gmail.com	$2b$12$uTnYYk5yMqQRn00f9uAIduqN71jJbNMDXjkB.4bihIw7TXgjpBBYW	student	Donald Johnson	student3132704	23	+77053996417	\N	t	f	2022-12-25 16:24:52.958364+03
314	student314@gmail.com	$2b$12$TtGA1JUHPZbdNorXepOrRutJJSUquFJzbxppd97.PfrRz83lFHRSy	student	Bryan Morrison	student3141261	20	+70527397466	\N	t	f	2022-12-25 16:24:53.164405+03
315	student315@gmail.com	$2b$12$4/pTj2Zp1FF8B88EMtO53ObFnDrIA99gimFfUQnXu8bRTsl6kxlu2	student	Kyle Fields	student3153187	24	+74926629082	\N	t	f	2022-12-25 16:24:53.380211+03
316	student316@gmail.com	$2b$12$se4Q42MtfT.FwhpxidiTQuLgt.bTa1eiiOtwuNrOBSGcGdqFqoCKq	student	Robert King	student3162317	22	+74398398514	\N	t	f	2022-12-25 16:24:53.586291+03
317	student317@gmail.com	$2b$12$K//P/H5HUQH9mhLZvOFvHu75GA8C0iQLGayLqxmf2quKt.QiWtakC	student	Michael Gross	student3173987	21	+78669653904	\N	t	f	2022-12-25 16:24:53.793904+03
318	student318@gmail.com	$2b$12$8wr8Dqtl39VHdFriaUrlUuGZINIm2LXtpNnMMBdH/8hknPA4XNbCu	student	Lisa White	student3182266	24	+71082728694	\N	t	f	2022-12-25 16:24:54.004519+03
319	student319@gmail.com	$2b$12$aaXml180x5JgnI.iaQeOxuog9mgZiLTtlDRsrfYCPxFI14T.oujNS	student	Andrea Fuentes	student3193499	22	+71151732701	\N	t	f	2022-12-25 16:24:54.220911+03
320	student320@gmail.com	$2b$12$QsLYiQLrTLITMcOygBcILuIsqmWdIDkf0gwIbCrTbnEA16rmzAx8.	student	Felicia Lane	student3206969	20	+73279243068	\N	t	f	2022-12-25 16:24:54.438813+03
321	student321@gmail.com	$2b$12$ZnjLjeUJ4e3q0UESorY3yOXZnnBi0yZanvcI7TeXy9lmEA2c4V/Sa	student	Jamie Mclaughlin	student3217055	18	+78591249720	\N	t	f	2022-12-25 16:24:54.645048+03
322	student322@gmail.com	$2b$12$aWEEMXNTAG2ts42XLJXLq.3AQXPamtoNRxIEBxzLZ9.nqE0B.CduC	student	David Brady	student3222631	19	+77094530672	\N	t	f	2022-12-25 16:24:54.853623+03
323	student323@gmail.com	$2b$12$E1UmP8FLbHf9BQQSmjgPiOeLhzIUwv26Au2cHp3BmCMo0oV06PwA2	student	Maria Lewis	student3237044	23	+76771761610	\N	t	f	2022-12-25 16:24:55.064605+03
324	student324@gmail.com	$2b$12$lyJ8CIAHSDGOYeiLtwAwyOYwKDUzJ5Zfkp/QqyiGn6/g/b1n.DSje	student	Kaitlin Moyer	student3248625	24	+72999342290	\N	t	f	2022-12-25 16:24:55.272075+03
325	student325@gmail.com	$2b$12$iWO0YVjwt1uGq5iDbdaXreLvDb5WSafwFw/Vff1.xpsB6iCYo7QpW	student	Megan Jarvis	student3256605	21	+78925994334	\N	t	f	2022-12-25 16:24:55.477727+03
326	student326@gmail.com	$2b$12$O6yhFroru9hoWK7mWI34zuM4b2mHS5hvsUQPSWz/DwGdggXaZhFCK	student	Jose Mcmillan	student3267958	21	+79064197226	\N	t	f	2022-12-25 16:24:55.686291+03
327	student327@gmail.com	$2b$12$46nSoYv3sjPky5RQmDXYZOS8360Qw6lAe.Y6D3K9wDbh/wdv2OiXG	student	Bridget Watson	student3277547	19	+76529878879	\N	t	f	2022-12-25 16:24:55.893809+03
328	student328@gmail.com	$2b$12$Fyfcyzeut5hEmsLw9SB4aeaBfTVf7/0f30pbC60Wy2x72DkcKset2	student	Susan Miller	student3287801	21	+74185442248	\N	t	f	2022-12-25 16:24:56.106218+03
329	student329@gmail.com	$2b$12$La7KJkbdNfDUWaO6kOtai.WbbYjPl9WC/CWRumg4WBcHpgerfEXbC	student	Taylor Olson	student3296496	18	+79143626370	\N	t	f	2022-12-25 16:24:56.313671+03
330	student330@gmail.com	$2b$12$DCmFmC1OijCgN04/7IkbQONYMIct1rFdMhfTba5teJq9K8FQYYnXG	student	Katherine Knapp	student3302907	20	+77653899452	\N	t	f	2022-12-25 16:24:56.521947+03
331	student331@gmail.com	$2b$12$Q9Mf.iiDgmp9E9/9C3qhfOonLr47/xrxeHWUGLJSD5WFy86NrsCg6	student	Stephanie Bartlett	student3313203	23	+79701989807	\N	t	f	2022-12-25 16:24:56.727165+03
332	student332@gmail.com	$2b$12$Lymq5QbQiLFwqoOQyuf6ZOvjcUxiIA3vOeR7SKlj6Qwa3m9sGRYbK	student	Allison Diaz	student3327573	18	+78755000252	\N	t	f	2022-12-25 16:24:56.934036+03
333	student333@gmail.com	$2b$12$MrDrmjtUT6DCCW3KjdPl/.szn/j3yb9sl5mPrubD5q6p2yGt9qywm	student	Stephanie Davis	student3336388	23	+71368985898	\N	t	f	2022-12-25 16:24:57.136623+03
334	student334@gmail.com	$2b$12$HJHOrHSwmTLIoJT/J6kxYOdCmeXgVLv8nrtESzbW1YFrddTFV3pka	student	Mark Greene	student3348073	21	+78894281287	\N	t	f	2022-12-25 16:24:57.34357+03
335	student335@gmail.com	$2b$12$83f9/aiKEVV.sqRv299FjO/o1crHLMSYP59cXb.jQLJFMe8PlyJhe	student	Karen Jennings	student3358867	18	+72473401236	\N	t	f	2022-12-25 16:24:57.550055+03
336	student336@gmail.com	$2b$12$chpKdOn58Mp8vS.eD9owyeB7JTH4CJfsLhYtwhSd0T31aSIiD82ua	student	Jessica Garcia	student3363730	25	+79549937169	\N	t	f	2022-12-25 16:24:57.754941+03
337	student337@gmail.com	$2b$12$F82c3ZbOOcvwCHQvjj9WHew/5Mzw2dbWGeOHEMyfT1fmJQJmoJqDC	student	Maria Holland	student3378372	18	+74643413875	\N	t	f	2022-12-25 16:24:57.959984+03
338	student338@gmail.com	$2b$12$Frl9NQ3Qs8H6Cvz.3nnhMuKagQ7IPy0CdHzSCQ219rw9F/HqTThlu	student	Barbara Cruz	student3384188	18	+71580791052	\N	t	f	2022-12-25 16:24:58.163527+03
339	student339@gmail.com	$2b$12$boRMUtD4hUP.Y67wmXBpVOIv.J0s5y3vEBW2Dj0Y1DmtfXhnEPx3C	student	Lori Wilson	student3398863	19	+77737325097	\N	t	f	2022-12-25 16:24:58.371112+03
340	student340@gmail.com	$2b$12$uQqiiZuYRcrCGNJp4KlUmOmqYVqEpxQjIWtoFKCLlDcD8vDQElwmi	student	Brandon Gates	student3405868	20	+74099698648	\N	t	f	2022-12-25 16:24:58.580853+03
341	student341@gmail.com	$2b$12$oorSDfo3MVGMKhB2cjife.AVam/qrbgV459shGeYmoetLkMpoT2Ti	student	Sarah Parker	student3412667	18	+76120613195	\N	t	f	2022-12-25 16:24:58.786405+03
342	student342@gmail.com	$2b$12$9M3h7YsLqy5ZePQ0n3IecOE3.h93NtXEmN4CINNruSbCttULoTgli	student	Lisa Simmons	student3429904	25	+72620404513	\N	t	f	2022-12-25 16:24:58.990606+03
343	student343@gmail.com	$2b$12$5Cffl6fzcDURf//oTbrDHObBuQKDkVjmnfumG1WwdOuvpGLl0EV6W	student	William Larson	student3439988	23	+72858826761	\N	t	f	2022-12-25 16:24:59.194355+03
344	student344@gmail.com	$2b$12$bQVLV.veWYK4W31fgVqoSO01SouCN1KpOyyb/wy9xCyAAKatOvFe.	student	Erin Cortez	student3445821	18	+72782399934	\N	t	f	2022-12-25 16:24:59.412309+03
345	student345@gmail.com	$2b$12$.m86wty3vb4WEh8AB8uuF..xkqtfGxubDosVjYoD46L2Z959pH6NG	student	Michael Pena	student3454348	18	+79756211048	\N	t	f	2022-12-25 16:24:59.62538+03
346	student346@gmail.com	$2b$12$NXgRbjIiwtTswqQhlBP6MuK4x.IaR5BDrsHIoZZQs3u8Qu4cylOfu	student	Brian Knight	student3466460	21	+76939298883	\N	t	f	2022-12-25 16:24:59.838684+03
347	student347@gmail.com	$2b$12$j.48hAGozPDneZuT2LvHPedjJkUZri5txXTDqpGW.967Xo8fNwwGq	student	Tina Hamilton	student3474829	20	+75295509079	\N	t	f	2022-12-25 16:25:00.04821+03
348	student348@gmail.com	$2b$12$61yha89CW3AbtUprj3oeDu02p.gFy8dqzjZdMmKhH8vKQnD4jvxWa	student	Michael Hudson	student3486611	23	+75696117859	\N	t	f	2022-12-25 16:25:00.256561+03
349	student349@gmail.com	$2b$12$e90ErHhVomEou/QhIfwKCOGvbtKt5HtFxehLdA2YbZ/SxBvNyeODu	student	Martha Leonard	student3496855	22	+77232065187	\N	t	f	2022-12-25 16:25:00.471808+03
350	student350@gmail.com	$2b$12$w6Ym2zRjDYhmu2jd4ugYtemg/NOAOqbPSV.x946rQPI9kA69awVxa	student	Natasha Sparks	student3506483	21	+72007954703	\N	t	f	2022-12-25 16:25:00.682246+03
351	student351@gmail.com	$2b$12$NnRjovilOfcqTsh/TZ4L0euvyu9Guswrh.2X69WpKCMPJAIC2ocru	student	James Richmond	student3512514	18	+74396230940	\N	t	f	2022-12-25 16:25:00.896699+03
352	student352@gmail.com	$2b$12$2ZE60iuvFYZEv402pphmQeHpw0I4qYfy849vJly6NxKOeZ5p/fmqW	student	Kara Crawford	student3529401	21	+74533571872	\N	t	f	2022-12-25 16:25:01.107044+03
353	student353@gmail.com	$2b$12$m0.0KDORhoFxRzh4gkJ2D.iN4q2Dyh8uPmt1p2KGin2R7UztsEtsO	student	Travis Serrano	student3532219	23	+78432164599	\N	t	f	2022-12-25 16:25:01.321422+03
354	student354@gmail.com	$2b$12$jr28RGDYbnJNH0bvwTSjFeb8yIOVmgUrLgFUpEROJ3JQAhd41elRG	student	Angela Nguyen	student3542106	22	+74356564879	\N	t	f	2022-12-25 16:25:01.528543+03
355	student355@gmail.com	$2b$12$D.xbWSuSpdM7eiUENiIxa.78mhhZG8dY9btma0o3besYx49UP/lqy	student	Randall Robertson	student3559335	20	+75765390338	\N	t	f	2022-12-25 16:25:01.735123+03
356	student356@gmail.com	$2b$12$Dd.VAOh5NXsIrmKHRpHqj.EU5uVQMYNCPRIHxgrx6vN60hQSasWYe	student	Katelyn Buchanan	student3563647	22	+75791992308	\N	t	f	2022-12-25 16:25:01.981902+03
357	student357@gmail.com	$2b$12$UblnzDza7WTwVzjkfrkvl.SXSO0FmNZ6M6VYE39P/FGYb8r5ZVwfi	student	Mary Butler	student3578759	22	+72990064713	\N	t	f	2022-12-25 16:25:02.203166+03
358	student358@gmail.com	$2b$12$/eh5eR3Ak1LMGWj3NPgSr.YvUyVpdNXi25ZIb0tK1OOfqt2T8.qQe	student	Kathleen Long	student3583821	24	+73559197639	\N	t	f	2022-12-25 16:25:02.433004+03
359	student359@gmail.com	$2b$12$kEx/80VVj0Od6cKJZkVpseghpvzZw4WW6KrmhWl/Ee6n3PclVVja6	student	Michael Ortega	student3599530	20	+76191810161	\N	t	f	2022-12-25 16:25:02.648521+03
360	student360@gmail.com	$2b$12$IvUlmbjt7s.dodWreUIQ..PcM/uniPHceIxJKG5jHZYN7WMRU0EwG	student	Debra Richards	student3602199	23	+71632580751	\N	t	f	2022-12-25 16:25:02.856058+03
361	student361@gmail.com	$2b$12$rPZUQRc8/Di1NIGFizRJYOGZPNBaLkHdtWbvJSK3bjpxbiw5WPJTG	student	Tanya Grant	student3615417	25	+72355221047	\N	t	f	2022-12-25 16:25:03.06223+03
362	student362@gmail.com	$2b$12$k0tRHbJFefNZt/67czhZh.uO8TBIrMxVjf9gDa8PLr8GsXAm4s2bO	student	Sheila Watts	student3629557	18	+72428089997	\N	t	f	2022-12-25 16:25:03.279366+03
363	student363@gmail.com	$2b$12$SYaYS/OL2FoJkSmaHE1oUumgoh9gsTsSImOWOJYV0urs19JPEj3.O	student	Ashley Jordan	student3633002	18	+70472701447	\N	t	f	2022-12-25 16:25:03.490965+03
364	student364@gmail.com	$2b$12$8cO18r7sNW2wMojDTX.b6ufmzC98d4Pi.EQ/vQnX67aHEJlWqm7tq	student	Raymond Conner	student3641467	24	+73491518047	\N	t	f	2022-12-25 16:25:03.697166+03
365	student365@gmail.com	$2b$12$q2O7/gwSR2cOCs3NKMi3Eej9UhTbQ5136U8Y5acychlYE2zYDcWca	student	Kenneth Young	student3656280	24	+74865505739	\N	t	f	2022-12-25 16:25:03.906044+03
366	student366@gmail.com	$2b$12$8GKlsy7VGXFNuzRGuhIUZOcJDUUeX54cuKCJHGEDChDsfKZtCtj6K	student	Jacob Greer	student3664569	24	+76544218551	\N	t	f	2022-12-25 16:25:04.112458+03
367	student367@gmail.com	$2b$12$LIkNUOmz1ov81Ahjjiclmeymg/ih7mhNC3w1Q0/NGIcG1VVsQKzpC	student	Kevin Burke	student3675280	24	+73248224139	\N	t	f	2022-12-25 16:25:04.323946+03
368	student368@gmail.com	$2b$12$5uAzGiObE4KL36Z3zyykcuUfz9QPHZ5CkBv0.sl7BSps3sYcH6sTe	student	Kyle Soto	student3688671	20	+79695712206	\N	t	f	2022-12-25 16:25:04.531808+03
369	student369@gmail.com	$2b$12$XFjesVGoSRSu3V6jlN2V7.FbNBIIO3nFxqB/AE1xHdCQaTZhcN6.q	student	Keith Fry	student3698560	24	+70851209253	\N	t	f	2022-12-25 16:25:04.764031+03
370	student370@gmail.com	$2b$12$9AbqKtj1UZvsEZyOmZUGqOC./yWEWISaWksXl4nY8UEb7dNBpMXBC	student	Christopher Smith	student3707544	20	+74466207273	\N	t	f	2022-12-25 16:25:04.97362+03
371	student371@gmail.com	$2b$12$ThkxybQLtlY9C3zsWfSFButKGngiyGYafAWVe5mflYU8cA6/1r.U2	student	Darryl Flowers	student3715660	20	+75002083189	\N	t	f	2022-12-25 16:25:05.181324+03
372	student372@gmail.com	$2b$12$WgUPbVsbDxDLFLMGns/vQuGmTDKO0.t49QmrWH3GiE0etls/T6hRK	student	Cassandra Ayers	student3727354	23	+72492563285	\N	t	f	2022-12-25 16:25:05.389941+03
373	student373@gmail.com	$2b$12$kLGLLKcB2FPDxedQJNTfKuhzu7L/ZfbruBMgPzm9Pv7sRcBGdRBtG	student	Jeremy Griffin	student3738234	24	+74085412171	\N	t	f	2022-12-25 16:25:05.596245+03
374	student374@gmail.com	$2b$12$P.ZDhe69rxaPt8Xr0nBi1umfI5wi2wkd7ZltZrfFF7meTK0Hhwmem	student	Daniel Bell	student3749554	24	+72671502018	\N	t	f	2022-12-25 16:25:05.804268+03
375	student375@gmail.com	$2b$12$2NFREEF/eb5jAG5AiEKzSum8iq/KJfPsKiA9EytCiiNv2CM5AwM6a	student	Andrew Santos	student3753108	24	+77650368602	\N	t	f	2022-12-25 16:25:06.010798+03
376	student376@gmail.com	$2b$12$tr.cKrIvTIBYY0Jgr3HwX.ycqoMrgqgfe1t7nWkdhnUnyHHsWkXgq	student	Deborah Dunn	student3764697	23	+75602803683	\N	t	f	2022-12-25 16:25:06.218934+03
377	student377@gmail.com	$2b$12$8P9pNagB6Xq6v7He/DCNn.B.pbxRZ8W2H.j5fa3zedqpjYZdnZcdS	student	Daniel Howell	student3772218	25	+78340356205	\N	t	f	2022-12-25 16:25:06.425065+03
378	student378@gmail.com	$2b$12$t60iS1FL.xGhyDX2/K3Cie1i7osFOuZfPO93vJ8fS/CSNH3yxzJ5m	student	Regina Kennedy	student3785165	18	+79811693728	\N	t	f	2022-12-25 16:25:06.630242+03
379	student379@gmail.com	$2b$12$t34/UV17RvwACSi4huG.TO/yWeQ78/ZiKtXSHICsyCLF3cafO3rFW	student	Jenna Clark	student3798618	24	+76253578532	\N	t	f	2022-12-25 16:25:06.832558+03
380	student380@gmail.com	$2b$12$s9HQVcD5rGEbJ8umAu/RluSWuIx/G0S2Mful0LU5HKNQU4efygqDu	student	Darryl Mclaughlin	student3802554	24	+79324145776	\N	t	f	2022-12-25 16:25:07.037578+03
381	student381@gmail.com	$2b$12$SKUiCCeqPy.0Jnd4OUqrNOf/9T22iQSPEPWFDAQT8x5ySTLM/l25m	student	Anthony Montgomery	student3813608	18	+78829977704	\N	t	f	2022-12-25 16:25:07.246628+03
382	student382@gmail.com	$2b$12$WAoBVROU4csJAp/5YX0hyOQiL6bGe9DD5MIsT.ViPhXDPW34fevOe	student	Sharon Rangel	student3823535	21	+74597013192	\N	t	f	2022-12-25 16:25:07.452599+03
383	student383@gmail.com	$2b$12$aql7Rv3Ta6gtvFHSWnUPD.mogr6LVvtnAyroFARMl0NY6UJAgOO8i	student	Donna Palmer	student3835935	19	+71492982595	\N	t	f	2022-12-25 16:25:07.657811+03
384	student384@gmail.com	$2b$12$QEdOJalzpm1CFXQztSeLbOx4eapoOms.wUbDWhw29BybkUkQk1Gry	student	Danielle Mason	student3848650	22	+74309975093	\N	t	f	2022-12-25 16:25:07.892897+03
385	student385@gmail.com	$2b$12$M7Er/dmIOT0MaMVBP3aMLOchYVAQm8GtphOgOB2D60SnOcoMYrDie	student	Brittany Mccoy	student3851629	20	+73526756129	\N	t	f	2022-12-25 16:25:08.096822+03
386	student386@gmail.com	$2b$12$3vdGyOJwALscf0XviqoR3eF8dZVVtPfAoMrIeTWmjcHvykXWdo17u	student	David Taylor	student3864152	23	+79920571780	\N	t	f	2022-12-25 16:25:08.299519+03
387	student387@gmail.com	$2b$12$c1Ml0DYbHOAshg3wEgpKCeP.sJdyx3MkIGQlEImPQ8d9D.8fDQ9Vq	student	Robert Smith	student3878412	19	+73328570919	\N	t	f	2022-12-25 16:25:08.503638+03
388	student388@gmail.com	$2b$12$Oy0up7XVY8wdIYvf3b9y2.R2Cc8.h77dQqy1NXGryvV9iPeV/dukG	student	Juan Jackson	student3884294	22	+70901562259	\N	t	f	2022-12-25 16:25:08.709705+03
389	student389@gmail.com	$2b$12$wSuZYB4VWOymFQsQNspr1uUYpnYezxQWi9mZUoF240AQOqwAWBsim	student	Dr. Matthew Delgado	student3896183	22	+77197403639	\N	t	f	2022-12-25 16:25:08.923833+03
390	student390@gmail.com	$2b$12$MBwv4m7zoq1MZqF3ArHZcutl7aeteUyYNy12obQJI0DbXJL7Q1hwu	student	Veronica Moore	student3907376	23	+77126979631	\N	t	f	2022-12-25 16:25:09.131452+03
391	student391@gmail.com	$2b$12$OpY6VDoPSwZEW.wo1qflG.xGfXaVGDhRUMmzMtV9ZhXzWWwJhYzs.	student	Daniel Proctor	student3913415	18	+79530286000	\N	t	f	2022-12-25 16:25:09.343831+03
392	student392@gmail.com	$2b$12$ldSVKqtGQBn8RNFBdN09DOV2vFwLfQPGoTy7A4S1VBFgtjFCT.FfG	student	Mark Barber	student3928085	20	+76192597146	\N	t	f	2022-12-25 16:25:09.562776+03
393	student393@gmail.com	$2b$12$M2QjX3TeTy6T7XSWqSkjSOGgqgdgiTP3qBejYGvrz1fRY.fTiRkGS	student	Brett Velez	student3938817	21	+79362766301	\N	t	f	2022-12-25 16:25:09.771084+03
394	student394@gmail.com	$2b$12$R5hNqBls5kc32di5WN9A2OZe2RgvnOlfeehvK/2PbZUZn4I6Vl9We	student	Devin Good	student3948338	22	+78760232646	\N	t	f	2022-12-25 16:25:09.978034+03
395	student395@gmail.com	$2b$12$zZ9viH4anxR47WVsI7DqjOLOPbE1HyMT9Qfl2OjjzGt7jrCAWSKdi	student	Theresa Tran	student3952744	19	+76751856821	\N	t	f	2022-12-25 16:25:10.185707+03
396	student396@gmail.com	$2b$12$JpFuOp/UvBXT8fJ24zIWIusDTsAauBLAtqtL9UtJIfCBpIHtDj8Om	student	Marco Rodriguez	student3966867	20	+78997467518	\N	t	f	2022-12-25 16:25:10.393938+03
397	student397@gmail.com	$2b$12$VHNWgmPukEibx.FSujc/w.8MI/11kQ2hTZ.N8n5LffWGyWudWjtI.	student	Jennifer Hodge	student3971220	23	+79167093258	\N	t	f	2022-12-25 16:25:10.602021+03
398	student398@gmail.com	$2b$12$xMrr/iCnvHVHGFW0oaHW0uicCBh8KiWgV3b9E2geipgqLzwi3q6O.	student	Christopher Brown	student3985689	19	+75659019746	\N	t	f	2022-12-25 16:25:10.809658+03
399	student399@gmail.com	$2b$12$je9BmuwFUm41I3BIzkuvJOrCpZ7pLKNGT91fHTWgLTCElwr9JYy0y	student	Edgar Martinez	student3992711	23	+79166621840	\N	t	f	2022-12-25 16:25:11.016393+03
400	student400@gmail.com	$2b$12$xMapayYtxm1c98V71CgDVuFAk7iXEABNpEyoJsiw1jlPwsB/4mloK	student	Abigail Perez	student4002610	18	+71925332794	\N	t	f	2022-12-25 16:25:11.222878+03
401	student401@gmail.com	$2b$12$W7BzDTVP4wsa7mPWJ2jOauLafCwslRcMXQnFT3hk5KN/CpntR3zrW	student	Elizabeth Reese	student4011977	19	+77897893410	\N	t	f	2022-12-25 16:25:11.43177+03
402	student402@gmail.com	$2b$12$srkhFAjWv/9gfdm7w8y3bu3dlXUTu2St3JkMlroq5qxNkmv.ANEQG	student	Mary Davenport	student4022053	21	+79822685179	\N	t	f	2022-12-25 16:25:11.639698+03
403	student403@gmail.com	$2b$12$fdjMN7hR2ziIEPHR4yWO..J/.ZkbQvucZYAFtGVgltKcw02pDcbnS	student	Michelle Ortega	student4032910	24	+76596387977	\N	t	f	2022-12-25 16:25:11.852573+03
404	student404@gmail.com	$2b$12$liUPwYJ4lB8K5HffA0J9POd3mPFv9wnoe9M./MmHmZcyG3mKTFUO2	student	Elizabeth Taylor	student4043584	19	+77794994302	\N	t	f	2022-12-25 16:25:12.061848+03
405	student405@gmail.com	$2b$12$NTK5aynr5ILbE0I6zAVmp.yxyIsooS9r1si.3wkOywKDG9GgaCNfm	student	Cristian Perkins	student4058235	23	+79297627089	\N	t	f	2022-12-25 16:25:12.270244+03
406	student406@gmail.com	$2b$12$3iK5MfnCEnAnhOGZBHzw6..8338nV.9RjZXiU2.SleQHWuQWxwpL6	student	Stacy Heath	student4064475	22	+75071491319	\N	t	f	2022-12-25 16:25:12.480355+03
407	student407@gmail.com	$2b$12$/qz7GS1KKBgFs4HU/7tSBeOLEg4oQFbRdVeWU04SvcJ.tauGJByzW	student	Natalie Webb	student4077518	22	+74372577833	\N	t	f	2022-12-25 16:25:12.689801+03
408	student408@gmail.com	$2b$12$wYs5t/c/f9g/pVQnCLKmquXN.z.ToFfDhek3lZrCWf4nhQKwBg/aG	student	Meagan Young	student4086975	20	+74473934133	\N	t	f	2022-12-25 16:25:12.900014+03
409	student409@gmail.com	$2b$12$PIezkUsaG3cMAjuZaKE/xOLzLbjmd3pEu8wjrq2QZZwP4GhFahch6	student	Tristan Sanchez	student4099870	22	+72459275084	\N	t	f	2022-12-25 16:25:13.108411+03
410	student410@gmail.com	$2b$12$Ne2WTy.fi.xMCzWo8/oMdu6KkXZuj8KUk.rFQUxO/KnaVGqtlppHO	student	Patricia Skinner	student4101139	23	+75214625554	\N	t	f	2022-12-25 16:25:13.315122+03
411	student411@gmail.com	$2b$12$/tVWwATnleciQEqfEed7gOrsa46y3wIH1g/c3nS45Yqf9yACYNi3C	student	Kirk Marks	student4114304	19	+72488852774	\N	t	f	2022-12-25 16:25:13.521683+03
412	student412@gmail.com	$2b$12$Z6F2/XIS.NZ9mX28yz1zuekcS/J4UBwThuHWSUZkP.ujt4r15Prwe	student	Jordan Roach	student4126520	18	+77957103751	\N	t	f	2022-12-25 16:25:13.729263+03
413	student413@gmail.com	$2b$12$s/RfTsk1uPrTBYnke1t4f.uadvAnGbX6zNmM8whHy08xKSzrHaJEG	student	Nicole Hernandez	student4135054	23	+75326161783	\N	t	f	2022-12-25 16:25:13.982523+03
414	student414@gmail.com	$2b$12$5rxvjHuV894u.FiYtzF2yulAzw9ORetzxrSHdqGY/pqV7tS.JfOJa	student	Katrina Klein	student4142398	20	+74358159172	\N	t	f	2022-12-25 16:25:14.201669+03
415	student415@gmail.com	$2b$12$UxGR0eJb4h/KEcaidtaDN.YPsbKcKWJ7jO74sc7.zeGiw.dauDCYK	student	Kara Zavala	student4151509	18	+71958421353	\N	t	f	2022-12-25 16:25:14.435224+03
416	student416@gmail.com	$2b$12$1Ritn2oA.LEtklkR.s5gF.z4ggsFsZg9VwUVAZpZzqWPLFVMQ/qgC	student	Paul Cole	student4165087	22	+70481113090	\N	t	f	2022-12-25 16:25:14.645326+03
417	student417@gmail.com	$2b$12$FEzenp.6u29nkpyT/siAtur4uAPzEOOmJ4BtMh46EO5K9X0sczlLe	student	Denise York	student4178072	22	+75371710290	\N	t	f	2022-12-25 16:25:14.857602+03
418	student418@gmail.com	$2b$12$Dawr/sSUHEaLR.a.yfoheeodbBtOHuDKIRPB4Vp389LARn0SUjXJC	student	Samantha Jones	student4182567	24	+71846589953	\N	t	f	2022-12-25 16:25:15.067976+03
419	student419@gmail.com	$2b$12$ron8Unhjyb57nzj8SnjnZ.0j0bJDXtRNUKrRIgAmRu6ycL0P7pWfi	student	Karina Carter	student4193848	19	+70587322697	\N	t	f	2022-12-25 16:25:15.274271+03
420	student420@gmail.com	$2b$12$B.FEk9icQchiCsSKwSBky.VnZ/L2xGHyH1i/jXIT7OhjrXqqPbcXq	student	Cameron Fisher	student4207558	22	+72227793011	\N	t	f	2022-12-25 16:25:15.479981+03
421	student421@gmail.com	$2b$12$L9aGjMDQYzqX8YZYlQhv9eOuaoYvRW.NH7aVm7qudl4ZIV7DiYRoG	student	Sarah Bowman	student4217046	18	+70422806754	\N	t	f	2022-12-25 16:25:15.687759+03
422	student422@gmail.com	$2b$12$KYKLygJML5sdx15J0PKhDOB7/98uvJriCHiubbNhzfAHPWqUu.mYW	student	Rachael Hall	student4225520	24	+71281363309	\N	t	f	2022-12-25 16:25:15.895458+03
423	student423@gmail.com	$2b$12$pzYpC.XnSyW.7ejANxls8eXZLgf07E4FWc2bXPq.BvMTlvOd2.rU6	student	Holly Moody	student4234407	18	+77642072115	\N	t	f	2022-12-25 16:25:16.104253+03
424	student424@gmail.com	$2b$12$rV10e2JBFsmKgLo1MdDFO.7LqtFQem3GwjHxtfs/g8yKylKOY/qy2	student	Courtney Evans	student4245381	20	+72150482134	\N	t	f	2022-12-25 16:25:16.309563+03
425	student425@gmail.com	$2b$12$4LR4no56HopXYQliWWOsvuwro2e1i9KKE8iug5QB78Mtk9X12vS2m	student	Shannon Barker	student4259684	22	+73797570099	\N	t	f	2022-12-25 16:25:16.516644+03
426	student426@gmail.com	$2b$12$yIkGD.p5I9D2NwMb5v7HLeKTrTm5xb4nh1Jtthyu8W0YicVzrdFWG	student	Howard Andrews	student4264377	22	+79142663254	\N	t	f	2022-12-25 16:25:16.721194+03
427	student427@gmail.com	$2b$12$LzUN0jFGxO8hidIHMlg6QuG4sdrWcSo19g89R65h.6NvCpyQOrqCG	student	Isabella Cox	student4276306	18	+74790292642	\N	t	f	2022-12-25 16:25:16.925778+03
428	student428@gmail.com	$2b$12$h46UxZbZ7ttY03kg5TBYSe/RHunIkD7lhe20MF70pDtdrToN/EeQ.	student	Jason Diaz	student4287344	18	+74746824129	\N	t	f	2022-12-25 16:25:17.132503+03
429	student429@gmail.com	$2b$12$fBYShPp3tfO5U4W4.4SS9uDoGeepGlZb9hVcGmMdWQa1i9FhOuEwu	student	Taylor Gonzalez	student4298606	24	+75628615573	\N	t	f	2022-12-25 16:25:17.347147+03
430	student430@gmail.com	$2b$12$/E.E0EMpUbZsd6bxtlHXSuxXKVgIREyTfVPyrnWHyNxjU5cZb/wAy	student	Wesley Suarez	student4306677	23	+70505218443	\N	t	f	2022-12-25 16:25:17.556136+03
431	student431@gmail.com	$2b$12$tswrzWheSxrZyTY2p.l7teytOwcXJYYiAm1dAjfKWwxAX34/M0jCi	student	Matthew Mcdonald	student4315630	21	+74774680475	\N	t	f	2022-12-25 16:25:17.764892+03
432	student432@gmail.com	$2b$12$WCJE0/x9KT4wxyo6hB16OOYUF9m1oM0rNc3onJQH8A8VoScXLxVOa	student	Sara Brown	student4323441	25	+77125034606	\N	t	f	2022-12-25 16:25:17.971237+03
433	student433@gmail.com	$2b$12$mbNHDMgbR2an8NwtUqxIOO4CE2icHQkldhXxSmm5QilZSNBAaJG7y	student	Richard Gross	student4334550	23	+73555418199	\N	t	f	2022-12-25 16:25:18.174932+03
434	student434@gmail.com	$2b$12$tTfAtABeheEUhort5PQAmuHDJZI11LHfgO8pNFf1orwmRcp5TkWRq	student	Rebecca Tucker	student4345414	19	+78869674427	\N	t	f	2022-12-25 16:25:18.386433+03
435	student435@gmail.com	$2b$12$ImjIyb1KQ5DqG4pq1dgs4OFqfb6mrr6poFxU7Ys1x.HCGob/4SE6e	student	Matthew Richmond	student4354932	20	+77719918722	\N	t	f	2022-12-25 16:25:18.589141+03
436	student436@gmail.com	$2b$12$nWV1jvPJ/tgH3bPM/d8Rf.tF3okGUf50Mu1ETRu85qdPHDY9LlXRK	student	Patrick Brooks	student4363560	24	+77782613445	\N	t	f	2022-12-25 16:25:18.795198+03
437	student437@gmail.com	$2b$12$eniviGsmT871Qmw4j2RB4.h9fQpyuyNjub2QKeyWVzZZXXY2liGH2	student	Jacob Braun	student4374854	19	+78714859300	\N	t	f	2022-12-25 16:25:18.997966+03
438	student438@gmail.com	$2b$12$c6h0zjKkRHVjoju8nwVMF.pohHmKLxTdbwUsiUFofmLO422zLSKt2	student	Monica Russell	student4383323	22	+75369188978	\N	t	f	2022-12-25 16:25:19.201216+03
439	student439@gmail.com	$2b$12$.uIGRR3fmSI8N4MmhPA2F.kdMHmJC/./H4D1VQkO6OZTDsOqZN8XW	student	Jennifer Rivera	student4391849	22	+77696786548	\N	t	f	2022-12-25 16:25:19.407392+03
440	student440@gmail.com	$2b$12$YJzYTCcFP2xN/xhsBCVxJeTbmnf9RxNXIKzD8SvFigkmnN3emN69e	student	Bruce Bullock	student4408208	22	+79984228656	\N	t	f	2022-12-25 16:25:19.615415+03
441	student441@gmail.com	$2b$12$ZQvfGAgqPoZIlA6WOMPMjuhsrO1ThmKOuO/Rpl71pETDRoQlvbIWy	student	Dominic Bennett	student4418577	22	+72796639348	\N	t	f	2022-12-25 16:25:19.819305+03
442	student442@gmail.com	$2b$12$t86J5/19.1OeWPZfb0ZXHeG3iWx/0xerrhSWHojDSq023gSeIOe9q	student	Dr. Ashley Davis	student4422541	25	+72989897507	\N	t	f	2022-12-25 16:25:20.024244+03
443	student443@gmail.com	$2b$12$vv3.d.9VVqhqKv0BkcfPN.uiJ1eljiWaomQAN15V5yfl7QrWegS/K	student	Stephanie Sanchez	student4439015	19	+79678120079	\N	t	f	2022-12-25 16:25:20.227993+03
444	student444@gmail.com	$2b$12$yQ4e7qipS5yAii5EwhQZSuxR0aFu2Qj.Q9k2gZszyLMjfUQRD9VvW	student	Sara Lambert	student4444465	19	+77012553708	\N	t	f	2022-12-25 16:25:20.433124+03
445	student445@gmail.com	$2b$12$bqNvEXo/Ri3Wl55ca0ZiEOwCcVxLJZfwluJlFcD3sX5vp96A4Fh3W	student	Timothy Morrison	student4452583	23	+71709644831	\N	t	f	2022-12-25 16:25:20.636414+03
446	student446@gmail.com	$2b$12$.caXy/VR.DDrX45uZXYel.OikRlDByUBWWWwV0NqZJtU/We50b4HC	student	Jacob Small	student4467431	24	+75649826024	\N	t	f	2022-12-25 16:25:20.841292+03
447	student447@gmail.com	$2b$12$QZCDKDXAS4ls9k94R2D4Wu/V5wNdKVVWFAP9kKvd1zo1hi9ErxwDC	student	Mr. James Harrison	student4473523	21	+75769067195	\N	t	f	2022-12-25 16:25:21.049989+03
448	student448@gmail.com	$2b$12$GnPeF1353sE8fBvlNOtf/uCiiK8k2b39Rt9eUXvxcrOaMapmdnLqq	student	Sean Waller	student4483031	22	+70178172644	\N	t	f	2022-12-25 16:25:21.258234+03
449	student449@gmail.com	$2b$12$QT3jEOkcDQYBDAjMAsljuegyX1cbzi/NijHcsj5obFJrdQzSd7CzW	student	Mrs. Stacy Brown	student4492665	25	+70173317223	\N	t	f	2022-12-25 16:25:21.467394+03
450	student450@gmail.com	$2b$12$Sg0m9wvitKlEVdM1LhpdNeQKCilwbnqt827x15xsDGM8kOrD73/AG	student	Tracy Grant	student4507168	21	+73442227330	\N	t	f	2022-12-25 16:25:21.681777+03
451	student451@gmail.com	$2b$12$pCl.ADSaB4T3YZTtiUyF2.wd7IbFQ3Keek6Pk13A1dxVNufcyt3Em	student	Alexandra Sharp	student4514526	20	+78481613977	\N	t	f	2022-12-25 16:25:21.892177+03
452	student452@gmail.com	$2b$12$.d/u2NR9g6xxgCI6arK.n.6Q8rG1aTpo7Ww2Qph1MTkpovTT2IXZO	student	Brooke Francis	student4524392	22	+74203406493	\N	t	f	2022-12-25 16:25:22.103683+03
453	student453@gmail.com	$2b$12$VamE.gIEwmsklkgkN785AugQ.WgXmTllNk4sDdfFc5Ggewmy6lQyC	student	Stacy Carter	student4532052	22	+71487307448	\N	t	f	2022-12-25 16:25:22.313563+03
454	student454@gmail.com	$2b$12$GnAXYapFkz9gBFpuReYaJOtuf0aBuP7nucIZ9WHlDE371CDXO/JSC	student	Crystal White	student4543580	22	+78295740536	\N	t	f	2022-12-25 16:25:22.528947+03
455	student455@gmail.com	$2b$12$ptLFzfp8swhJYYU6afbQNui5K17ARITx7sLZE5ScT4ISCNj0nQBLi	student	Donna Kelly	student4555147	19	+75339466390	\N	t	f	2022-12-25 16:25:22.741412+03
456	student456@gmail.com	$2b$12$e01jmRRIFFe7pRL66/zdL.nT/Cx6oBy5edEUUkN2w7j4ZsJ/aGKEK	student	Brittany Meyer	student4569838	21	+78602755763	\N	t	f	2022-12-25 16:25:22.956925+03
457	student457@gmail.com	$2b$12$BFM7OdN71XBlp/vBSPI6re1ofZdyAFD7DjLwKR3AxRvg/M9vJUW3q	student	Mathew Stark	student4579993	23	+74008330439	\N	t	f	2022-12-25 16:25:23.173271+03
458	student458@gmail.com	$2b$12$fdh2QHS4cO.eN..QI1r.9OoLtUoEyobRXxuivFq0TT6gqT55fAway	student	Amanda Glover	student4582675	18	+75064018159	\N	t	f	2022-12-25 16:25:23.387143+03
459	student459@gmail.com	$2b$12$f3E4quY/rYZeT6mnIu.bI.XZmc0.ujHuMueFdmximtEEiLyQpJIP.	student	Joseph Smith	student4593514	20	+73213267885	\N	t	f	2022-12-25 16:25:23.596633+03
460	student460@gmail.com	$2b$12$YGAU6.GY083Rt8xFaw7ujOF4zqi/yEmges8Ine0TRqGd4MAWdrqqG	student	Danielle Smith	student4603014	24	+77303409684	\N	t	f	2022-12-25 16:25:23.807927+03
461	student461@gmail.com	$2b$12$L9aziS6w2Wz05bCN.L9Y1OT5I7jHUFkEJdsjvo/Eu/ELWbIjUbIx6	student	Jack Garcia	student4617146	19	+71012203897	\N	t	f	2022-12-25 16:25:24.020466+03
462	student462@gmail.com	$2b$12$NScZxVfU8ZhxHQJ1NEhjEezum7krolecqvE827XA6uvFy3xfx7inK	student	William Escobar	student4626085	25	+70350726319	\N	t	f	2022-12-25 16:25:24.234301+03
463	student463@gmail.com	$2b$12$fOIKihJISKl5sDGCILoZT.TtJBVMgNb2B5r8CUdBuBa0jpuxTAGqe	student	Natalie Taylor	student4637854	21	+79629758256	\N	t	f	2022-12-25 16:25:24.444565+03
464	student464@gmail.com	$2b$12$uJm/hxpMQ06slUXz/Q/7KepQvlsYMbWzLutjKgeww3yjiqZvR213a	student	Mike Morton	student4643758	24	+75408919233	\N	t	f	2022-12-25 16:25:24.652545+03
465	student465@gmail.com	$2b$12$fSoKfGrGcY5Uf7p1TqB1hOmTIgtu1lQf9/P2T.tsvIaqr54dRHvcW	student	Don Woods	student4658328	24	+79077509306	\N	t	f	2022-12-25 16:25:24.866593+03
466	student466@gmail.com	$2b$12$kRgngfYgJwm3Nb.ykrWDFuBvnsJzT8.DSQPz9MZRvkDmKfCIJC6OW	student	Gail Schwartz	student4663003	20	+70323153033	\N	t	f	2022-12-25 16:25:25.071592+03
467	student467@gmail.com	$2b$12$JwtBMxyn3UzNweIsaF6o8.jum7q7SxK.15hnxBe2VyzudvDwskaxi	student	Joseph Young	student4675477	20	+70469443627	\N	t	f	2022-12-25 16:25:25.276804+03
468	student468@gmail.com	$2b$12$5/eTRnanCA2wSj/4gsl5WuWPG4yImosjy1FJtV3vMcABprEtGXHI2	student	Marcia Johns	student4687022	25	+72684874568	\N	t	f	2022-12-25 16:25:25.483081+03
469	student469@gmail.com	$2b$12$5lmgwSHZk8g0YAh383f3POwgbpTbHBoEJ1BYKy6c2sTuBKyxjmKya	student	Janet Ortiz	student4696587	21	+76995357452	\N	t	f	2022-12-25 16:25:25.687075+03
470	student470@gmail.com	$2b$12$3b40nkiEkTRmRJnm77WKnOSwlqdvKOioYEMNZFpOcPrnz/CmeQxjS	student	Eric Pittman	student4707438	22	+71399531717	\N	t	f	2022-12-25 16:25:25.891746+03
471	student471@gmail.com	$2b$12$Sq6Yl6h..Bt9rRqwFm1VEufmdCFnOJdZsFqXOMMQIfzCE.QAt.Lvq	student	John Hayden	student4713942	20	+71612215401	\N	t	f	2022-12-25 16:25:26.107095+03
472	student472@gmail.com	$2b$12$tapbYDlpnzt3Pgr9DRRoUetxXfyeu6VdCFg2obvmzFOQFGd0KGC.a	student	Sherry Figueroa	student4721427	25	+79280243269	\N	t	f	2022-12-25 16:25:26.313924+03
473	student473@gmail.com	$2b$12$Vwv/3SkHCR9/FEubpJNrUuuO/rKGpjkMqTlowxU5sXHhrQ/v6CNMG	student	Jerry Hamilton	student4732351	19	+73512908691	\N	t	f	2022-12-25 16:25:26.527225+03
474	student474@gmail.com	$2b$12$fhVpC5R1wd70YJ.Ii5kZoeJG2Rr4LAohyXAn/qe8d3YHJgRZVQo.G	student	Samantha Willis	student4748830	21	+70406246213	\N	t	f	2022-12-25 16:25:26.737638+03
475	student475@gmail.com	$2b$12$sZVCfIqbybfszpDkOt1BpO1O3FYJLGrJZAoFacKc/IBji5FgfES12	student	Betty Benitez	student4757815	21	+77672016833	\N	t	f	2022-12-25 16:25:26.950511+03
476	student476@gmail.com	$2b$12$X1b5q9uUlBlOF1YhvN6hNOPmLL3oaMTx39LYJzD4QvnFUllatH386	student	Harold Swanson	student4761131	25	+77236212852	\N	t	f	2022-12-25 16:25:27.155111+03
477	student477@gmail.com	$2b$12$KqnydvW90FyHfZ/s4BUM8.4.LZQwgTK55yZdpu/Md0cjtRxek/b0e	student	Amber Watson	student4776112	22	+74260185909	\N	t	f	2022-12-25 16:25:27.365663+03
478	student478@gmail.com	$2b$12$LF9SkgaODD2Esek9iAgd1uPFXjFF52n892iKCHO8EWF1xaaw4llkS	student	Amy Bates	student4786650	19	+77019207663	\N	t	f	2022-12-25 16:25:27.57632+03
479	student479@gmail.com	$2b$12$H43VN5NG1YdO7gTwoUh0Hek/hy.R3J53sNddSKLV6aOnnePfMhboi	student	Ricky Harris	student4793829	21	+79670826024	\N	t	f	2022-12-25 16:25:27.784037+03
480	student480@gmail.com	$2b$12$XE/VX8ojwZqfpm6dguFod.qiDt3TyrDL/8S8OUQL/KpGNVMobNDE6	student	Dana Carpenter	student4805667	19	+76703781726	\N	t	f	2022-12-25 16:25:27.99925+03
481	student481@gmail.com	$2b$12$P70oMqAJbyvSZnOig30/h.mbQRvpRg070q9oNM/jvekjNt1Ykf8kK	student	Megan Williams	student4817343	24	+76837095395	\N	t	f	2022-12-25 16:25:28.206612+03
482	student482@gmail.com	$2b$12$.YAHgJQcNxrNCOfkeQtWsuZj8/LoDXoWksNSqU9PNqIAzGFjU48nK	student	Jacob Little	student4828270	21	+72509271775	\N	t	f	2022-12-25 16:25:28.416907+03
483	student483@gmail.com	$2b$12$QhpShbh5aU6KQcchaDAEUuXpCvUj1UTyevCaA3eLR8jlrV5GXGBGe	student	William Carter	student4838794	22	+76017060652	\N	t	f	2022-12-25 16:25:28.635265+03
484	student484@gmail.com	$2b$12$g4cqJQUycUsVnpVy0JieSeTp6I4OFuf7rqGfijdwrcoYzSc3rMjHO	student	Pedro Fisher	student4842073	25	+78692878194	\N	t	f	2022-12-25 16:25:28.853387+03
485	student485@gmail.com	$2b$12$9w5xksOtGEB5UOymw6J4QOJJE6HK0jdHdtCtczU.nmcA5yi3vlUum	student	Julia Jackson	student4856620	25	+79211238387	\N	t	f	2022-12-25 16:25:29.070736+03
486	student486@gmail.com	$2b$12$UZF6h7P.VYu2lhMzB8IE0.uHi47GG9visscx0A7lCgwo0a7PVLh5O	student	Nathan Sandoval	student4866630	23	+71086749194	\N	t	f	2022-12-25 16:25:29.285014+03
487	student487@gmail.com	$2b$12$GkbSE7886eF9MoQb3O6jvewkavE5YmRr3RJnefi3R6W/DuIB3cjRW	student	Anthony Murphy	student4879319	24	+77028055655	\N	t	f	2022-12-25 16:25:29.489697+03
488	student488@gmail.com	$2b$12$OVnvKX1RipeWvLRt/fgot.Iw2rY7xbHcCiHrz1gI2jwoIetRedFAy	student	Tina Flynn	student4885622	22	+72932486671	\N	t	f	2022-12-25 16:25:29.704041+03
489	student489@gmail.com	$2b$12$oMVAdyyBQ1hjh9vZyvoJgOR4a8Tln78rS2E7IhLf7Q69OYRpw2SUy	student	Katherine Lee	student4894876	22	+77045661954	\N	t	f	2022-12-25 16:25:29.910666+03
490	student490@gmail.com	$2b$12$B.ZsXMCCSQh5EljEEBagg.Rxw7Dt1BWWlo1LR1GHLjso23pMr/LKS	student	Christina Rodriguez	student4904916	21	+75553995276	\N	t	f	2022-12-25 16:25:30.115681+03
491	student491@gmail.com	$2b$12$g9v609p7QMhbVS5xvwYAWOTM7YvrE9WItaySKJr8F5a8MFdmZRDBG	student	David Bennett	student4911154	21	+70597654309	\N	t	f	2022-12-25 16:25:30.320873+03
492	student492@gmail.com	$2b$12$82sXwRmh9SotI/V2JnIqX.RuIzbCL9AdhxAZjYXBI7SUWoAz0XR4i	student	Dr. Katie Garcia	student4929313	25	+73439021623	\N	t	f	2022-12-25 16:25:30.525172+03
493	student493@gmail.com	$2b$12$7kmWrBtIbUGvkwoFvX9FZu7VqPifpVSgKUNeCsooupe12yzO7QUwa	student	Susan Gibson	student4933688	20	+70814914938	\N	t	f	2022-12-25 16:25:30.729829+03
494	student494@gmail.com	$2b$12$A0BqUqtegSIPW/ZNYqnxbO2HBJkjMNkaxT.PaHADrOrT.eVLfJmMy	student	James Nguyen	student4948780	23	+72493523544	\N	t	f	2022-12-25 16:25:30.943412+03
495	student495@gmail.com	$2b$12$1/HOHiMG3CgYdTTXd9swyeW23BYIfGKoRXtk/igtZRfkzbmyuK1Tm	student	Patrick Larson	student4952541	21	+76593930355	\N	t	f	2022-12-25 16:25:31.149758+03
496	student496@gmail.com	$2b$12$pYek3/GMwKhsE4NSGdhope7MjlyjJ5aRyIIr4R81dTTDxkSRwjDUW	student	Jeffrey Cox	student4961837	23	+72967095402	\N	t	f	2022-12-25 16:25:31.354878+03
497	student497@gmail.com	$2b$12$4ARjTgdjpQlw0lZ9k7QbouzKYV45oAV53qE7zSocRNDFo2u0wER3G	student	Andrew Adams	student4975366	21	+71813084062	\N	t	f	2022-12-25 16:25:31.559544+03
498	student498@gmail.com	$2b$12$bXeLhy2WtjZLNzpVUbkWbOmXW3u1sxipVyw3QaY3zsoTgJOoFXbOi	student	Shirley Rogers	student4989258	20	+76422758165	\N	t	f	2022-12-25 16:25:31.763868+03
499	student499@gmail.com	$2b$12$EGqcQorPAd.qfN.Te8PDg.otGDYf6p5.lpqIb56AB.YVe1W/If8ga	student	Jonathan Weaver	student4997318	18	+77841100321	\N	t	f	2022-12-25 16:25:31.969649+03
500	student500@gmail.com	$2b$12$wuYYnOAzZHQPAdJMUteFPO2OTYsaElR6ZJR9DfQyIbUPybEjcg6Qm	student	Hannah Dixon	student5004128	20	+78641195811	\N	t	f	2022-12-25 16:25:32.174528+03
501	student501@gmail.com	$2b$12$txnBpGJJZWkQ3ztLiXKH8OCRXQ7NNxPD52P9xWFvnY6za5D5iZIqC	student	Matthew Pace	student5017178	23	+77563786545	\N	t	f	2022-12-25 16:25:32.382177+03
\.


--
-- Name: discipline_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.discipline_id_seq', 6, true);


--
-- Name: student_task_store_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_task_store_id_seq', 124, true);


--
-- Name: task_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_id_seq', 248, true);


--
-- Name: teacher_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.teacher_id_seq', 248, true);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_id_seq', 501, true);


--
-- Name: campus campus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.campus
    ADD CONSTRAINT campus_pkey PRIMARY KEY (id);


--
-- Name: discipline discipline_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline
    ADD CONSTRAINT discipline_pkey PRIMARY KEY (id);


--
-- Name: student student_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_pkey PRIMARY KEY (id);


--
-- Name: student_task student_task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_task
    ADD CONSTRAINT student_task_pkey PRIMARY KEY (id, student_id);


--
-- Name: student_task_store student_task_store_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_task_store
    ADD CONSTRAINT student_task_store_id_key UNIQUE (id);


--
-- Name: student_task_store student_task_store_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_task_store
    ADD CONSTRAINT student_task_store_pkey PRIMARY KEY (task_id, student_id, url);


--
-- Name: study_group_cipher study_group_cipher_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.study_group_cipher
    ADD CONSTRAINT study_group_cipher_pkey PRIMARY KEY (id);


--
-- Name: study_group study_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.study_group
    ADD CONSTRAINT study_group_pkey PRIMARY KEY (id, discipline_id);


--
-- Name: study_group_task study_group_task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.study_group_task
    ADD CONSTRAINT study_group_task_pkey PRIMARY KEY (id, study_group_cipher_id);


--
-- Name: task task_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_id_key UNIQUE (id);


--
-- Name: task task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_pkey PRIMARY KEY (teacher_user_id, teacher_role, teacher_discipline_id, title);


--
-- Name: teacher teacher_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher
    ADD CONSTRAINT teacher_id_key UNIQUE (id);


--
-- Name: teacher teacher_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher
    ADD CONSTRAINT teacher_pkey PRIMARY KEY (user_id, role, discipline_id);


--
-- Name: user user_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_email_key UNIQUE (email);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: user user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_username_key UNIQUE (username);


--
-- Name: task_description; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX task_description ON public.task USING btree (description);


--
-- Name: task_title; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX task_title ON public.task USING btree (title);


--
-- Name: user_email_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_email_index ON public."user" USING btree (email);


--
-- Name: user_full_name_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_full_name_index ON public."user" USING btree (full_name);


--
-- Name: student_task _check_overdue_student_task; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER _check_overdue_student_task BEFORE UPDATE ON public.student_task FOR EACH ROW EXECUTE FUNCTION public.check_overdue_student_task();


--
-- Name: student_task delete_student_task_old_rows; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER delete_student_task_old_rows BEFORE UPDATE ON public.student_task FOR EACH ROW EXECUTE FUNCTION public.check_student_task_old_rows();


--
-- Name: study_group_task delete_study_group_task_old_rows; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER delete_study_group_task_old_rows BEFORE UPDATE ON public.study_group_task FOR EACH ROW EXECUTE FUNCTION public.check_study_group_task_old_rows();


--
-- Name: user insert_user_role_after; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER insert_user_role_after AFTER INSERT ON public."user" FOR EACH ROW EXECUTE FUNCTION public.check_user_role_after();


--
-- Name: student_task set_student_task_completion_date; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_student_task_completion_date BEFORE UPDATE ON public.student_task FOR EACH STATEMENT EXECUTE FUNCTION public.check_student_task_completion_date();


--
-- Name: student student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_id_fkey FOREIGN KEY (id) REFERENCES public."user"(id);


--
-- Name: student_task student_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_task
    ADD CONSTRAINT student_task_id_fkey FOREIGN KEY (id) REFERENCES public.task(id);


--
-- Name: student_task_store student_task_store_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_task_store
    ADD CONSTRAINT student_task_store_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.student(id);


--
-- Name: student_task_store student_task_store_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_task_store
    ADD CONSTRAINT student_task_store_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(id);


--
-- Name: student_task student_task_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_task
    ADD CONSTRAINT student_task_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.student(id);


--
-- Name: study_group study_group_discipline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.study_group
    ADD CONSTRAINT study_group_discipline_id_fkey FOREIGN KEY (discipline_id) REFERENCES public.discipline(id);


--
-- Name: study_group study_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.study_group
    ADD CONSTRAINT study_group_id_fkey FOREIGN KEY (id) REFERENCES public.study_group_cipher(id);


--
-- Name: study_group_task study_group_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.study_group_task
    ADD CONSTRAINT study_group_task_id_fkey FOREIGN KEY (id) REFERENCES public.task(id);


--
-- Name: study_group_task study_group_task_study_group_cipher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.study_group_task
    ADD CONSTRAINT study_group_task_study_group_cipher_id_fkey FOREIGN KEY (study_group_cipher_id) REFERENCES public.study_group_cipher(id);


--
-- Name: task task_teacher_user_id_teacher_role_teacher_discipline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_teacher_user_id_teacher_role_teacher_discipline_id_fkey FOREIGN KEY (teacher_user_id, teacher_role, teacher_discipline_id) REFERENCES public.teacher(user_id, role, discipline_id);


--
-- Name: teacher teacher_campus_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher
    ADD CONSTRAINT teacher_campus_id_fkey FOREIGN KEY (campus_id) REFERENCES public.campus(id);


--
-- Name: teacher teacher_discipline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher
    ADD CONSTRAINT teacher_discipline_id_fkey FOREIGN KEY (discipline_id) REFERENCES public.discipline(id);


--
-- Name: teacher teacher_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher
    ADD CONSTRAINT teacher_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: TABLE campus; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.campus TO admin;
GRANT SELECT ON TABLE public.campus TO student;
GRANT SELECT,INSERT,UPDATE ON TABLE public.campus TO leader;
GRANT SELECT,INSERT,UPDATE ON TABLE public.campus TO teacher;


--
-- Name: TABLE discipline; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.discipline TO admin;
GRANT SELECT ON TABLE public.discipline TO student;
GRANT SELECT,INSERT,UPDATE ON TABLE public.discipline TO leader;
GRANT SELECT ON TABLE public.discipline TO teacher;


--
-- Name: SEQUENCE discipline_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.discipline_id_seq TO admin;
GRANT USAGE ON SEQUENCE public.discipline_id_seq TO teacher;
GRANT USAGE ON SEQUENCE public.discipline_id_seq TO student;
GRANT USAGE ON SEQUENCE public.discipline_id_seq TO leader;


--
-- Name: TABLE student; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.student TO admin;
GRANT SELECT,UPDATE ON TABLE public.student TO student;
GRANT SELECT,INSERT,UPDATE ON TABLE public.student TO leader;
GRANT SELECT ON TABLE public.student TO teacher;


--
-- Name: TABLE student_task; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.student_task TO admin;
GRANT SELECT,UPDATE ON TABLE public.student_task TO student;
GRANT SELECT,UPDATE ON TABLE public.student_task TO leader;
GRANT SELECT,INSERT,UPDATE ON TABLE public.student_task TO teacher;


--
-- Name: TABLE student_task_store; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.student_task_store TO admin;
GRANT SELECT,INSERT,UPDATE ON TABLE public.student_task_store TO student;
GRANT SELECT,INSERT,UPDATE ON TABLE public.student_task_store TO leader;
GRANT SELECT ON TABLE public.student_task_store TO teacher;


--
-- Name: SEQUENCE student_task_store_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.student_task_store_id_seq TO admin;
GRANT USAGE ON SEQUENCE public.student_task_store_id_seq TO teacher;
GRANT USAGE ON SEQUENCE public.student_task_store_id_seq TO student;
GRANT USAGE ON SEQUENCE public.student_task_store_id_seq TO leader;


--
-- Name: TABLE study_group; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.study_group TO admin;
GRANT SELECT ON TABLE public.study_group TO student;
GRANT SELECT,INSERT,UPDATE ON TABLE public.study_group TO leader;
GRANT SELECT,INSERT,UPDATE ON TABLE public.study_group TO teacher;


--
-- Name: TABLE study_group_cipher; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.study_group_cipher TO admin;
GRANT SELECT ON TABLE public.study_group_cipher TO student;
GRANT SELECT,INSERT,UPDATE ON TABLE public.study_group_cipher TO leader;
GRANT SELECT,INSERT,UPDATE ON TABLE public.study_group_cipher TO teacher;


--
-- Name: TABLE study_group_task; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.study_group_task TO admin;
GRANT SELECT ON TABLE public.study_group_task TO student;
GRANT SELECT,UPDATE ON TABLE public.study_group_task TO leader;
GRANT SELECT,INSERT,UPDATE ON TABLE public.study_group_task TO teacher;


--
-- Name: TABLE task; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.task TO admin;
GRANT SELECT ON TABLE public.task TO student;
GRANT SELECT ON TABLE public.task TO leader;
GRANT SELECT,INSERT ON TABLE public.task TO teacher;


--
-- Name: SEQUENCE task_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.task_id_seq TO admin;
GRANT USAGE ON SEQUENCE public.task_id_seq TO teacher;
GRANT USAGE ON SEQUENCE public.task_id_seq TO student;
GRANT USAGE ON SEQUENCE public.task_id_seq TO leader;


--
-- Name: TABLE teacher; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.teacher TO admin;
GRANT SELECT ON TABLE public.teacher TO student;
GRANT SELECT ON TABLE public.teacher TO leader;
GRANT SELECT,INSERT,UPDATE ON TABLE public.teacher TO teacher;


--
-- Name: SEQUENCE teacher_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.teacher_id_seq TO admin;
GRANT USAGE ON SEQUENCE public.teacher_id_seq TO teacher;
GRANT USAGE ON SEQUENCE public.teacher_id_seq TO student;
GRANT USAGE ON SEQUENCE public.teacher_id_seq TO leader;


--
-- Name: TABLE teacher_lecturer_discipline_view; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.teacher_lecturer_discipline_view TO admin;


--
-- Name: TABLE teacher_practicioner_discipline_view; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.teacher_practicioner_discipline_view TO admin;


--
-- Name: TABLE "user"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public."user" TO admin;
GRANT SELECT,UPDATE ON TABLE public."user" TO student;
GRANT SELECT,INSERT,UPDATE ON TABLE public."user" TO leader;
GRANT SELECT,INSERT,UPDATE ON TABLE public."user" TO teacher;


--
-- Name: SEQUENCE user_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.user_id_seq TO admin;
GRANT USAGE ON SEQUENCE public.user_id_seq TO teacher;
GRANT USAGE ON SEQUENCE public.user_id_seq TO student;
GRANT USAGE ON SEQUENCE public.user_id_seq TO leader;


--
-- PostgreSQL database dump complete
--

