create table devices (
  id serial primary key,
  uid text not null,
  action_to_sync_id_to_output_json text not null,
  completed_action_to_sync_id int not null
);

create unique index idx_devices_uid on devices(uid);

create table todo_items(
  id serial primary key,
  title text not null,
  completed boolean not null
);
