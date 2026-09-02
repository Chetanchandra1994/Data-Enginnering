from config import STORAGE_TYPE

from storage.local_storage import upload_file as local_upload_file


def upload_file(
    source_file,
    destination_folder
):
    """
    Upload a file using the configured storage backend.

    The extraction pipeline does not need to know
    whether storage is local or cloud-based.
    """

    if STORAGE_TYPE == "local":

        return local_upload_file(
            source_file=source_file,
            destination_folder=destination_folder
        )

    elif STORAGE_TYPE == "gcs":

        raise NotImplementedError(
            "GCS storage is not implemented yet."
        )

    else:

        raise ValueError(
            f"Unsupported STORAGE_TYPE: {STORAGE_TYPE}"
        )