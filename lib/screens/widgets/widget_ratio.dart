
import 'package:flutter/material.dart';
import 'package:pixelfy/main.dart';
import 'package:pixelfy/utils/provider_ratio.dart';
import 'package:provider/provider.dart';

class WidgetRatio extends StatefulWidget {
  const WidgetRatio({super.key});

  @override
  State<WidgetRatio> createState() => _WidgetRatioState();
}

class _WidgetRatioState extends State<WidgetRatio> {

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.aspect_ratio, color: Colors.white),
          onPressed: (){ _showRatioPicker(context);},
        ),
        Text("Ratio", style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  void _showRatioPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(10),
          height: 100, // Ajusta la altura del modal
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ratioOption(context, "1:1", Size(1, 1)),
                _ratioOption(context, "1:2", Size(1, 2)),
                _ratioOption(context, "2:3", Size(2, 3)),
                _ratioOption(context, "3:1", Size(3, 1)),
                _ratioOption(context, "3:4", Size(3, 4)),
                _ratioOption(context, "4:3", Size(4, 3)),
                _ratioOption(context, "4:6", Size(4, 6)),
                _ratioOption(context, "5:4", Size(5, 4)),
                _ratioOption(context, "5:7", Size(5, 7)),
                _ratioOption(context, "7:5", Size(7, 5)),
                _ratioOption(context, "9:16", Size(9, 16)),
                _ratioOption(context, "10:8", Size(10, 8)),
                _ratioOption(context, "8:10", Size(8, 10)),
                _ratioOption(context, "16:9", Size(16, 9)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _ratioOption(BuildContext context, String label, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[800],
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
        onPressed: () {
          // Cambiamos el ratio con Provider
          context.read<ConfigLayout>().cambioRatio(size);
          Navigator.pop(context);
        },
        child: Text(label, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
