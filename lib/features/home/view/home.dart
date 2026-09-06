import 'package:flutter/material.dart';
import 'package:xorr/features/home/widgets/main_content.dart';
import 'package:xorr/features/home/widgets/sidebar.dart';
import 'package:xorr/features/home/widgets/bottom_content.dart';

class Home extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Expanded(child: MainContent()),
                Divider(height: 1),
                BottomContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
