from __future__ import annotations

from config import (
    BRAND_BACKGROUND,
    BRAND_PRIMARY,
    BRAND_SECONDARY,
    BRAND_SURFACE,
    LOGO_PATH,
)


def inject_brand_styles() -> None:
    import streamlit as st

    st.markdown(
        f"""
        <style>
            .stApp {{
                background-color: {BRAND_BACKGROUND};
            }}

            [data-testid="stSidebar"] {{
                background-color: {BRAND_PRIMARY};
            }}

            [data-testid="stSidebar"] * {{
                color: #FFFFFF !important;
            }}

            [data-testid="stSidebar"] .stCheckbox label p,
            [data-testid="stSidebar"] .stMarkdown p,
            [data-testid="stSidebar"] .stMarkdown li,
            [data-testid="stSidebar"] h1,
            [data-testid="stSidebar"] h2,
            [data-testid="stSidebar"] h3 {{
                color: #FFFFFF !important;
            }}

            [data-testid="stSidebar"] .stButton button {{
                background-color: {BRAND_SECONDARY} !important;
                color: {BRAND_PRIMARY} !important;
                border: none !important;
                font-weight: 600 !important;
            }}

            [data-testid="stSidebar"] .stButton button:hover {{
                filter: brightness(1.05);
            }}

            [data-testid="stSidebar"] a {{
                color: {BRAND_SECONDARY} !important;
            }}

            .massar-header {{
                background: {BRAND_SURFACE};
                border: 1px solid #D9E2EC;
                border-left: 6px solid {BRAND_SECONDARY};
                border-radius: 12px;
                padding: 1rem 1.25rem;
                margin-bottom: 1rem;
            }}

            .massar-header-title {{
                color: {BRAND_PRIMARY};
                font-size: 1.6rem;
                font-weight: 700;
                margin: 0;
            }}

            .massar-header-subtitle {{
                color: #52606D;
                margin-top: 0.35rem;
                font-size: 0.95rem;
            }}

            .massar-logo-wrap {{
                background: #FFFFFF;
                border-radius: 10px;
                padding: 0.5rem 0.75rem;
                display: inline-block;
            }}
        </style>
        """,
        unsafe_allow_html=True,
    )


def render_sidebar_logo() -> None:
    import streamlit as st

    if LOGO_PATH.exists():
        st.image(str(LOGO_PATH), width=220)
    else:
        st.markdown(
            f"""
            <div class="massar-logo-wrap">
                <span style="color:{BRAND_PRIMARY}; font-size:1.4rem; font-weight:700;">MASSAR</span>
            </div>
            """,
            unsafe_allow_html=True,
        )
        st.caption("Add logo at ai/assets/massar_logo.png")


def render_main_header() -> None:
    import streamlit as st

    left, right = st.columns([1.2, 4.8])
    with left:
        if LOGO_PATH.exists():
            st.image(str(LOGO_PATH), width=180)
        else:
            st.markdown(
                f'<div class="massar-logo-wrap"><span style="color:{BRAND_PRIMARY}; '
                f'font-size:1.5rem; font-weight:700;">MASSAR</span></div>',
                unsafe_allow_html=True,
            )
    with right:
        st.markdown(
            """
            <div class="massar-header">
                <p class="massar-header-title">AI Analytics Assistant</p>
                <p class="massar-header-subtitle">
                    Agentic LangChain RAG + governed text-to-SQL over semantic KPI views
                </p>
            </div>
            """,
            unsafe_allow_html=True,
        )
