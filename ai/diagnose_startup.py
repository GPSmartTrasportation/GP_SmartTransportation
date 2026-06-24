"""Write startup diagnostics to startup_check.log — run: python diagnose_startup.py"""
from __future__ import annotations

import traceback
from pathlib import Path

LOG = Path(__file__).resolve().parent / "startup_check.log"


def main() -> None:
    lines: list[str] = []
    try:
        lines.append("1) import streamlit ...")
        import streamlit  # noqa: F401

        lines.append(f"   OK streamlit {streamlit.__version__}")

        lines.append("2) import config ...")
        import config  # noqa: F401

        lines.append("   OK")

        lines.append("3) import agent ...")
        import agent  # noqa: F401

        lines.append("   OK")

        lines.append("4) import branding ...")
        import branding  # noqa: F401

        lines.append("   OK")

        lines.append("5) import streamlit_app module (no Streamlit server) ...")
        import importlib.util

        spec = importlib.util.spec_from_file_location(
            "streamlit_app_check",
            Path(__file__).resolve().parent / "streamlit_app.py",
        )
        assert spec and spec.loader
        # Do not execute streamlit_app top-level (would need runtime); syntax check only
        source = (Path(__file__).resolve().parent / "streamlit_app.py").read_text(encoding="utf-8")
        compile(source, "streamlit_app.py", "exec")
        lines.append("   OK syntax")

        lines.append("\nALL CHECKS PASSED. Run: run_app.bat or streamlit run streamlit_app.py")
    except Exception as exc:
        lines.append(f"\nFAILED: {exc}")
        lines.append(traceback.format_exc())

    LOG.write_text("\n".join(lines), encoding="utf-8")
    print(LOG.read_text(encoding="utf-8"))


if __name__ == "__main__":
    main()
