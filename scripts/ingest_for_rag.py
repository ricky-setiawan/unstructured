from typing import Callable, Generator, List

from sentence_transformers import SentenceTransformer

from unstructured.logger import logger
from unstructured.partition.auto import partition
from unstructured.staging.base import convert_to_dict


class SingletonEncoder:
    _instance = None

    def __init__(self):
        raise RuntimeError("Call instance() instead")

    @classmethod
    def instance(cls):
        if cls._instance is None:
            print("Creating new instance")
            cls._instance = SentenceTransformer("microsoft/mpnet-base")
            # Put any initialization here.
        return cls._instance


def ingest_with_embedding(files: List[str]) -> Generator[dict, None, None]:
    # TODO: batching size
    for fname in files:
        logger.info("partitioning %s", fname)
        elements = partition(filename=fname, strategy="hi_res")
        record = convert_to_dict(elements)
        # record["embeddings"] = SingletonEncoder.instance()(element.text)
        yield record


def ingest_to_db(files: List[str], writer: Callable) -> int:
    n_records = 0
    for record in ingest_with_embedding(files):
        writer(record)
        n_records += 1
    return n_records
