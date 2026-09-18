/// Local draft state for the diary writing screen.
class DiaryState {
  const DiaryState({this.text = ''});

  final String text;

  bool get hasContent => text.trim().isNotEmpty;

  DiaryState copyWith({String? text}) => DiaryState(text: text ?? this.text);
}
