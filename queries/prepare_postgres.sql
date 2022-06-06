drop table if exists node;
drop table if exists edge;

create table node
(
    id     int primary key not null,
    labels varchar(30)     not null,
    name   varchar         not null
);

insert into node(id, labels, name)
select import._id :: int,
       import._labels,
       import.name
from offshoreleaks_import import
where import._id is not null;

create table edge
(
    node_start int         not null references node (id),
    node_end   int         not null references node (id),
    type       varchar(30) not null
);

insert into edge
select import.edge_start :: int,
       import.edge_end :: int,
       import.edge_type
from offshoreleaks_import import
where import.edge_start is not null;

create materialized view edge_mirrored as
select distinct *
from (
         select node_start, node_end
         from edge
         union
         select node_end, node_start
         from edge) combined
