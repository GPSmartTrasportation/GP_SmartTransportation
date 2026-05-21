{% macro to_time_key(column) %}
cast(
    datepart(hour, cast({{ column }} as datetime2(0))) * 100
    + datepart(minute, cast({{ column }} as datetime2(0)))
as smallint)
{% endmacro %}
