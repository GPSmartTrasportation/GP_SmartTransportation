from __future__ import annotations

from pathlib import Path

from langchain_community.vectorstores import Chroma
from langchain_core.documents import Document
from langchain_openai import AzureOpenAIEmbeddings, OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

from config import (
    AZURE_OPENAI_API_KEY,
    AZURE_OPENAI_BASE_URL,
    AZURE_OPENAI_DEPLOYMENT_EMBEDDINGS,
    AZURE_OPENAI_ENDPOINT,
    AZURE_OPENAI_API_VERSION,
    AZURE_OPENAI_USE_V1,
    CHROMA_DIR,
    DOCUMENTS_DIR,
    LLM_PROVIDER,
    OPENAI_API_KEY,
    OPENAI_EMBEDDING_MODEL,
)


def get_embeddings():
    if LLM_PROVIDER == "azure":
        if AZURE_OPENAI_USE_V1:
            return OpenAIEmbeddings(
                base_url=AZURE_OPENAI_BASE_URL,
                api_key=AZURE_OPENAI_API_KEY,
                model=AZURE_OPENAI_DEPLOYMENT_EMBEDDINGS,
            )

        return AzureOpenAIEmbeddings(
            azure_endpoint=AZURE_OPENAI_ENDPOINT,
            api_key=AZURE_OPENAI_API_KEY,
            azure_deployment=AZURE_OPENAI_DEPLOYMENT_EMBEDDINGS,
            api_version=AZURE_OPENAI_API_VERSION,
        )

    return OpenAIEmbeddings(model=OPENAI_EMBEDDING_MODEL, api_key=OPENAI_API_KEY)


def load_markdown_documents(documents_dir: Path = DOCUMENTS_DIR) -> list[Document]:
    documents: list[Document] = []
    for path in sorted(documents_dir.glob("*.md")):
        text = path.read_text(encoding="utf-8")
        documents.append(
            Document(
                page_content=text,
                metadata={"source": path.name, "path": str(path)},
            )
        )
    return documents


def build_vector_store(force_rebuild: bool = True) -> Chroma:
    if not DOCUMENTS_DIR.exists():
        raise FileNotFoundError(f"Documents folder not found: {DOCUMENTS_DIR}")

    docs = load_markdown_documents()
    if not docs:
        raise ValueError(f"No markdown files found in {DOCUMENTS_DIR}")

    splitter = RecursiveCharacterTextSplitter(chunk_size=900, chunk_overlap=120)
    chunks = splitter.split_documents(docs)

    CHROMA_DIR.mkdir(parents=True, exist_ok=True)
    embeddings = get_embeddings()

    if force_rebuild and any(CHROMA_DIR.iterdir()):
        import shutil

        shutil.rmtree(CHROMA_DIR)
        CHROMA_DIR.mkdir(parents=True, exist_ok=True)

    return Chroma.from_documents(
        documents=chunks,
        embedding=embeddings,
        persist_directory=str(CHROMA_DIR),
    )


if __name__ == "__main__":
    store = build_vector_store(force_rebuild=True)
    print(f"Embedded documents into {CHROMA_DIR}")
    print(f"Vector count: {store._collection.count()}")
