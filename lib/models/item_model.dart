class Item {
  final String name;
  final String client;
  final String pageId;

  const Item({
    required this.name,
    required this.client,
    required this.pageId,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    final properties = map['properties'] as Map<String, dynamic>;
    final nameList = (properties['Name']?['title'] ?? []) as List;
    final clientList = (properties['Client']?['rich_text'] ?? []) as List;
    return Item(
      name: nameList.isNotEmpty ? nameList[0]['plain_text'] : '?',
      client: clientList.isNotEmpty ? clientList[0]['plain_text'] : '?',
      pageId: map['id'],
    );
  }
}
