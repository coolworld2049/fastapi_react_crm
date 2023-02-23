create index if not exists user_email_index on "user" using btree (email);
create index if not exists user_full_name_index on "user" using btree (full_name);

create index if not exists task_title on task using btree (title);
create index if not exists task_description on task using btree (description);

create index if not exists task_title on task using btree (title);
create index if not exists task_description on task using btree (description);
