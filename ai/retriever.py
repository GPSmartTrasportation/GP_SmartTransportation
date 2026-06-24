from __future__ import annotations

from langchain_community.vectorstores import Chroma

from config import CHROMA_DIR
from embed_pipeline import get_embeddings


def get_vector_store() -> Chroma:
    if not CHROMA_DIR.exists():
        raise FileNotFoundError(
            f"Chroma store not found at {CHROMA_DIR}. Run: python embed_pipeline.py"
        )

    return Chroma(
        persist_directory=str(CHROMA_DIR),
        embedding_function=get_embeddings(),
    )


def get_retriever(k: int = 5):
    return get_vector_store().as_retriever(search_kwargs={"k": k})


def retrieve_context(question: str, k: int = 5) -> str:
    docs = get_retriever(k=k).invoke(question)
    if not docs:
        return "No relevant documentation found."

    parts: list[str] = []
    for index, doc in enumerate(docs, start=1):
        source = doc.metadata.get("source", "unknown")
        parts.append(f"[Source {index}: {source}]\n{doc.page_content}")
    return "\n\n---\n\n".join(parts)
