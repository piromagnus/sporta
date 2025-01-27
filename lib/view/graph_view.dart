import 'package:graphview/GraphView.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:provider/provider.dart';
import '../models/quest.dart';


class TreeViewPage extends StatefulWidget {

  const TreeViewPage(
    {super.key,
    required this.quests,}
  );

  final QuestDB quests;

  @override
  _TreeViewPageState createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Les quêtes"),
      ),
        body: Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Wrap(
          children: [
            // Container(
            //   width: 100,
            //   child: TextFormField(
            //     initialValue: builder.siblingSeparation.toString(),
            //     decoration: InputDecoration(labelText: "Sibling Separation"),
            //     onChanged: (text) {
            //       builder.siblingSeparation = int.tryParse(text) ?? 100;
            //       this.setState(() {});
            //     },
            //   ),
            // ),
            // Container(
            //   width: 100,
            //   child: TextFormField(
            //     initialValue: builder.levelSeparation.toString(),
            //     decoration: InputDecoration(labelText: "Level Separation"),
            //     onChanged: (text) {
            //       builder.levelSeparation = int.tryParse(text) ?? 100;
            //       this.setState(() {});
            //     },
            //   ),
            // ),
            // Container(
            //   width: 100,
            //   child: TextFormField(
            //     initialValue: builder.subtreeSeparation.toString(),
            //     decoration: InputDecoration(labelText: "Subtree separation"),
            //     onChanged: (text) {
            //       builder.subtreeSeparation = int.tryParse(text) ?? 100;
            //       this.setState(() {});
            //     },
            //   ),
            // ),
            // Container(
            //   width: 100,
            //   child: TextFormField(
            //     initialValue: builder.orientation.toString(),
            //     decoration: InputDecoration(labelText: "Orientation"),
            //     onChanged: (text) {
            //       builder.orientation = int.tryParse(text) ?? 100;
            //       this.setState(() {});
            //     },
            //   ),
            // ),
            // ElevatedButton(
            //   onPressed: () {
            //     final node12 = Node.Id(r.nextInt(100));
            //     var edge = graph.getNodeAtPosition(r.nextInt(graph.nodeCount()));
            //     print(edge);
            //     graph.addEdge(edge, node12);
            //     setState(() {});
            //   },
            //   child: Text("Add"),
            // ),
            ElevatedButton(
              onPressed: () {
                widget.quests.resetCache();
              },
              child: Icon(Icons.delete),
            )
          ],
        ),
        Expanded(
          child: 
        InteractiveViewer(
              constrained: false,
              boundaryMargin: EdgeInsets.all(50),
              minScale: 0.01,
              maxScale: 5.6,
              child: GraphView(
                graph: graph,
                algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
                paint: Paint()
                  ..color = Colors.green
                  ..strokeWidth = 1
                  ..style = PaintingStyle.stroke,
                builder: (Node node) {
                  // I can decide what widget should be shown here based on the id
                  var a = node.key?.value.name;
                  return rectangleWidget(a);
                },
              )),
        ),
      ],
    ));
  }

  Random r = Random();

  Widget rectangleWidget(dynamic a) {
    return InkWell(
      onTap: () {
        print('clicked');
      },
      child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(color: Colors.lightBlueAccent, spreadRadius: 1),
            ],
          ),
          child: Text('${a}')),
    );
  }

  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  void initState() {
    
    final Map<String,Node> map = {};
    for (var i in widget.quests) {
      map[i.name]=Node.Id(i);
    }
    for (var  i in widget.quests) {
     
      for (var j in i.nextQuest!) {
        if (map[j] != null)
        {
          graph.addEdge(map[i.name]!, map[j]!);
        }
        else {
          print(j);
        }
      }
    }

    // final node1 = Node.Id("Hell");
    // final node2 = Node.Id(2);
    // final node3 = Node.Id(3);
    // final node4 = Node.Id(4);
    // final node5 = Node.Id(5);
    // final node6 = Node.Id(6);
    // final node8 = Node.Id(7);
    // final node7 = Node.Id(8);
    // final node9 = Node.Id(9);
    // final node10 = Node.Id(10);  
    // final node11 = Node.Id(11);
    // final node12 = Node.Id(12);

    // graph.addEdge(node1, node2);
    // graph.addEdge(node1, node3, paint: Paint()..color = Colors.red);
    // graph.addEdge(node1, node4, paint: Paint()..color = Colors.blue);
    // graph.addEdge(node2, node5);
    // graph.addEdge(node2, node6);
    // graph.addEdge(node6, node7, paint: Paint()..color = Colors.red);
    // graph.addEdge(node6, node8, paint: Paint()..color = Colors.red);
    // graph.addEdge(node4, node9);
    // graph.addEdge(node4, node10, paint: Paint()..color = Colors.black);
    // graph.addEdge(node4, node11, paint: Paint()..color = Colors.red);
    // graph.addEdge(node11, node12);

    builder
      ..siblingSeparation = (50)
      ..levelSeparation = (50)
      ..subtreeSeparation = (50)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
  }
}