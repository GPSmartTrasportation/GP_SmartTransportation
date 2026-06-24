from __future__ import annotations

import re


def _last_user_message(history: list[dict]) -> str | None:
    for message in reversed(history):
        if message.get("role") == "user" and message.get("content"):
            return message["content"]
    return None


def _extract_filters(text: str) -> dict[str, str]:
    lowered = text.lower()
    filters: dict[str, str] = {}

    year_match = re.search(r"\b(20\d{2})\b", text)
    if year_match:
        filters["year"] = year_match.group(1)

    if "ramadan" in lowered:
        filters["occasion"] = "Ramadan"
    elif "eid al-fitr" in lowered or "eid al fitr" in lowered:
        filters["occasion"] = "Eid al-Fitr"
    elif "eid al-adha" in lowered or "eid al adha" in lowered:
        filters["occasion"] = "Eid al-Adha"

    if re.search(r"\blast month\b", lowered):
        filters["period"] = "last month"
    elif re.search(r"\bthis month\b", lowered):
        filters["period"] = "this month"

    for domain in ("mobility", "carrier", "freight"):
        if domain in lowered:
            filters["domain"] = domain.title()

    return filters


def _append_filters(question: str, filters: dict[str, str]) -> str:
    parts = [question.rstrip("?. ")]
    if filters.get("year") and filters["year"] not in question:
        parts.append(f"in {filters['year']}")
    if filters.get("occasion") and filters["occasion"].lower() not in question.lower():
        parts.append(f"during {filters['occasion']}")
    if filters.get("period") and filters["period"] not in question.lower():
        parts.append(filters["period"])
    if filters.get("domain") and filters["domain"].lower() not in question.lower():
        parts.append(f"for {filters['domain']}")
    return " ".join(parts)


def resolve_follow_up(question: str, history: list[dict]) -> str:
    """
    Expand short follow-ups using the previous user question.
    Example:
      Q1: What is completion rate in 2025?
      Q2: What about cancellation rate?
      -> What is cancellation rate in 2025?
    """
    cleaned = question.strip()
    lowered = cleaned.lower()

    follow_up_markers = (
        r"^what about\b",
        r"^how about\b",
        r"^and what about\b",
        r"^same for\b",
        r"^compare\b",
    )
    is_follow_up = any(re.search(pattern, lowered) for pattern in follow_up_markers)
    is_short = len(cleaned.split()) <= 8

    if not history or not (is_follow_up or is_short):
        return cleaned

    previous = _last_user_message(history)
    if not previous:
        return cleaned

    filters = _extract_filters(previous)

    for pattern, replacement in (
        (r"^what about\s+(.+)$", r"What is \1"),
        (r"^how about\s+(.+)$", r"What is \1"),
        (r"^and what about\s+(.+)$", r"What is \1"),
        (r"^same for\s+(.+)$", r"What is \1"),
    ):
        match = re.match(pattern, lowered)
        if match:
            topic = match.group(1).strip("?. ")
            resolved = f"What is {topic}"
            return _append_filters(resolved, filters)

    if is_follow_up and "rate" in lowered and "what is" not in lowered:
        resolved = cleaned.replace("what about", "What is", 1)
        resolved = resolved.replace("how about", "What is", 1)
        return _append_filters(resolved, filters)

    if is_short and not re.search(r"\b20\d{2}\b", cleaned):
        return _append_filters(cleaned, filters)

    return cleaned
