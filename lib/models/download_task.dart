class RunningDownloadTask {
  int progress;
  String filename = "";
  final String taskId;
  RunningDownloadTask(
      {required this.taskId, required this.progress, required this.filename});
}
