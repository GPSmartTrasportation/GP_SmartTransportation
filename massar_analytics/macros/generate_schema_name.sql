{#-
    Override of dbt's default `generate_schema_name`.

    Default dbt behavior:
        +schema: staging   +   target.schema: dbo   ->   dbo_staging

    Our behavior:
        +schema: staging   ->   staging          (used as-is when set)
        no +schema         ->   target.schema    (fallback)
-#}

{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}

{%- endmacro %}
