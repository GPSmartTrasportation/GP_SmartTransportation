from __future__ import annotations

import pandas as pd
import streamlit as st

from agent import answer_question
from branding import inject_brand_styles, render_main_header, render_sidebar_logo
from config import POWERBI_REPORT_URL


def _sidebar_button(label: str, key: str | None = None) -> bool:
    kwargs = {"width": "stretch"}
    if key:
        kwargs["key"] = key
    try:
        return st.button(label, **kwargs)
    except TypeError:
        kwargs.pop("width", None)
        kwargs["use_container_width"] = True
        return st.button(label, **kwargs)


def _sidebar_link_button(label: str, url: str) -> None:
    try:
        st.link_button(label, url, width="stretch")
    except TypeError:
        st.link_button(label, url, use_container_width=True)


st.set_page_config(page_title="Massar AI Analytics", page_icon="🚕", layout="wide")
inject_brand_styles()

if "messages" not in st.session_state:
    st.session_state.messages = []


def render_chart(df: pd.DataFrame, chart: dict) -> None:
    if chart["type"] == "line":
        chart_df = df.sort_values(chart["x"]).set_index(chart["x"])[chart["y"]]
        st.line_chart(chart_df, width="stretch")
    elif chart["type"] == "bar":
        chart_df = df.set_index(chart["x"])[chart["y"]]
        st.bar_chart(chart_df, width="stretch")


def render_assistant_payload(result: dict) -> pd.DataFrame | None:
    answer_text = result.get("answer") or result.get("content") or ""
    st.markdown(answer_text)

    dataframe = result.get("dataframe")
    if dataframe is None and result.get("columns") and result.get("rows"):
        dataframe = pd.DataFrame(result["rows"], columns=result["columns"])

    if dataframe is not None and not dataframe.empty:
        if result.get("chart"):
            st.subheader("Chart")
            render_chart(dataframe, result["chart"])

        with st.expander("Data table", expanded=result.get("chart") is None):
            st.dataframe(dataframe, width="stretch")

    return dataframe


with st.sidebar:
    render_sidebar_logo()
    st.divider()
    show_charts = st.checkbox("Show charts | إظهار الرسوم", value=True)

    if POWERBI_REPORT_URL:
        _sidebar_link_button(
            "Open Power BI dashboards | فتح Power BI",
            POWERBI_REPORT_URL,
        )
    else:
        st.info("Add POWERBI_REPORT_URL in ai/.env to link your published Power BI report.")

    st.divider()
    st.subheader("Demo questions")
    demos = [
        "What is completion rate?",
        "What about cancellation rate?",
        "Total rides by month in 2025",
        "Top 5 pickup zones by ride count",
        "Cancellation reasons during Ramadan 2025",
        "Average minutes to accept during peak hours",
    ]
    for index, demo in enumerate(demos):
        if _sidebar_button(demo, key=f"demo_{index}"):
            st.session_state.pending_question = demo

    if _sidebar_button("Clear chat | مسح المحادثة", key="clear_chat"):
        st.session_state.messages = []
        st.rerun()

render_main_header()

for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        if message["role"] == "assistant":
            render_assistant_payload(message)
        else:
            st.markdown(message.get("content", ""))

pending = st.session_state.pop("pending_question", None)
prompt = pending or st.chat_input("Ask about rides, KPIs, zones, SLA, or ratings...")

if prompt:
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    with st.chat_message("assistant"):
        with st.spinner("Agent is analyzing..."):
            history = [
                {"role": m["role"], "content": m.get("content", "")}
                for m in st.session_state.messages[:-1]
            ]
            result = answer_question(prompt, history=history)
            result["original_question"] = prompt
            if not show_charts:
                result["chart"] = None
            dataframe = render_assistant_payload(result)

        st.session_state.messages.append(
            {
                "role": "assistant",
                "answer": result.get("answer", ""),
                "content": result.get("answer", ""),
                "dataframe": dataframe,
                "chart": result.get("chart"),
            }
        )
