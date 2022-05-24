class MdBlock {
  String parent;
  List<MdBlock> children;

  MdBlock({required this.parent, required this.children});

  @override
  String toString() {
    return "{parent: $parent, children: ${children.toString()}}";
  }
}
