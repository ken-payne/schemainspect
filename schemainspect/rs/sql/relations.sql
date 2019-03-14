with r as (
    select
        c.relname as name,
        n.nspname as schema,
        c.relkind as relationtype,
        c.oid as oid,
        case when c.relkind in ('m', 'v') then
          pg_get_viewdef(c.oid)
        else null end
          as definition
    from
        pg_catalog.pg_class c
        inner join pg_catalog.pg_namespace n
          ON n.oid = c.relnamespace
    where c.relkind in ('r', 'v', 'm', 'c')
    -- SKIP_INTERNAL and n.nspname not in ('pg_catalog', 'information_schema', 'pg_toast')
    -- SKIP_INTERNAL and n.nspname not like 'pg_temp_%' and n.nspname not like 'pg_toast_temp_%'
)
select
    r.relationtype,
    r.schema,
    r.name,
    r.definition as definition,
    a.attnum as position_number,
    a.attname as attname,
    a.attnotnull as not_null,
    a.atttypid::regtype AS datatype,
    pg_get_expr(ad.adbin, ad.adrelid) as defaultdef,
    r.oid as oid,
    format_type(atttypid, atttypmod) AS datatypestring,
    pg_catalog.obj_description(r.oid) as comment
FROM
    r
    left join pg_catalog.pg_attribute a
        on r.oid = a.attrelid and a.attnum > 0
    left join pg_catalog.pg_attrdef ad
        on a.attrelid = ad.adrelid
        and a.attnum = ad.adnum
where a.attisdropped is not true
-- SKIP_INTERNAL and r.schema not in ('pg_catalog', 'information_schema', 'pg_toast')
-- SKIP_INTERNAL and r.schema not like 'pg_temp_%' and r.schema not like 'pg_toast_temp_%'
order by relationtype, r.schema, r.name, position_number;