enum MessageSender { owner, vet }

enum MessageStatus { sent, delivered, read }

enum MessageKind { text, consultationSummary, liveTelemetryShare, photoAttachment }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.kind = MessageKind.text,
    this.summaryDiagnosis,
    this.summaryTreatment,
    this.summaryFollowUp,
    this.dogName,
    this.heartRate,
    this.vitalityScore,
    this.temperature,
    this.photoLabel,
  });

  final String id;
  final MessageSender sender;
  final String text;
  final DateTime timestamp;
  final MessageStatus status;
  final MessageKind kind;

  // Rich clinical & telemetry metadata
  final String? summaryDiagnosis;
  final String? summaryTreatment;
  final String? summaryFollowUp;
  final String? dogName;
  final int? heartRate;
  final int? vitalityScore;
  final double? temperature;
  final String? photoLabel;
}
