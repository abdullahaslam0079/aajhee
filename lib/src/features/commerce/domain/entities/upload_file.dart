/// A local file the repository will send as multipart data.
class UploadFile {
  const UploadFile({
    required this.path,
    required this.filename,
  });

  final String path;
  final String filename;
}
