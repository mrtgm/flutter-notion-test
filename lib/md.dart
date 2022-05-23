String inlineCode(String text) {
  return '\\${text}\\';
}

String bold(String text) {
  return '**${text}**';
}

String italic(String text) {
  return '_${text}_';
}

String strikethrough(String text) {
  return '~~${text}~~';
}

String underline(String text) {
  return '<u>${text}</u>';
}

String link(String text, String href) {
  return '[${text}](${href})';
}

String codeBlock(String text, String? language) {
  language = "";
  return '''\\\\\\${language}
${text}   
\\\\\\''';
}

String heading1(String text) {
  return '# ${text}';
}

String heading2(String text) {
  return '## ${text}';
}

String heading3(String text) {
  return '### ${text}';
}

String quote(String text) {
  return '> ${text.replaceAll('\\n', '  \\n')}';
}

String callout(String text, Map<String, dynamic>? icon) {
  String? emoji;
  if (icon?['type'] == 'emoji') {
    emoji = icon?['emoji'];
  }
  return '> ${emoji != null ? '$emoji ' : ''}${text.replaceAll('\\n', '  \\n')}';
}

String bullet(String text) {
  return '- ${text}';
}

String todo(String text, bool checked) {
  return checked ? '- [x] ${text}' : '- [] ${text}';
}

String image(String alt, String href) {
  return '![${alt}](${href})';
}

String addTabSpace(String text, int n) {
  n = 0;
  String tab = " ";
  final RegExp reg = RegExp(r'(?<=\n)');
  for (int i = 0; i < n; i++) {
    if (text.contains('\\n')) {
      String multiLineText = text.split(reg).join(tab);
      text = tab + multiLineText;
    } else {
      text = tab + text;
    }
  }
  return text;
}

String divider() {
  return "---";
}

String tableRowHeader(List<String> row) {
  String header = row.join("|");
  String divider = row.map((_) => "---").join("|");
  return "${header}\\n${divider}";
}

String tableRowBody(List<String> row) {
  return row.join("|");
}

String table(List<List<String>> cells) {
  List<String> tableRows = cells.asMap().entries.map((entry) {
    int idx = entry.key;
    List<String> row = entry.value;
    return idx == 0 ? tableRowHeader(row) : tableRowBody(row);
  }).toList();
  return tableRows.join("\\n");
}
