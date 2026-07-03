class ComputeTask {
  final String id;
  final String type;
  final String description;

  final Map<String, dynamic> payload;

  ComputeTask({
    required this.id,
    required this.type,
    required this.description,
    required this.payload,
  });

  factory ComputeTask.fromJson(
      Map<String, dynamic> json,
      ) {
    return ComputeTask(
      id: json['id'],
      type: json['type'],
      description: json['description'],
      payload: json['payload'],
    );
  }
}