{% macro to_date_key(column) %}
cast(convert(varchar(8), cast({{ column }} as date), 112) as int)
{% endmacro %}
