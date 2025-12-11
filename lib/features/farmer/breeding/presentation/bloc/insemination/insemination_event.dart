
abstract class InseminationEvent {
  const InseminationEvent();
}

class LoadInseminationList extends InseminationEvent {
  final Map<String, dynamic>? filters;
  const LoadInseminationList({this.filters});
}

class LoadInseminationDetail extends InseminationEvent {
  final int id;
  const LoadInseminationDetail(this.id);
}

class AddInsemination extends InseminationEvent {
  final Map<String, dynamic> recordData; // Form submission data
  const AddInsemination(this.recordData);
}

class UpdateInsemination extends InseminationEvent {
  final int id;
  final Map<String, dynamic> updatedData;
  const UpdateInsemination(this.id, this.updatedData);
}

class DeleteInsemination extends InseminationEvent {
  final int id;
  const DeleteInsemination(this.id);
}