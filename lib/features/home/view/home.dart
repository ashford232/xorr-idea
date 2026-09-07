import 'package:flutter/material.dart';
import 'package:xorr/features/home/widgets/main_content.dart';
import 'package:xorr/features/home/widgets/sidebar.dart';
import 'package:xorr/features/home/widgets/bottom_content.dart';

class Home extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  child: Container(
                    clipBehavior: .antiAlias,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: .only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                    ),
                    child: MainContent(),
                  ),
                ),
                //   Divider(height: 1),
                BottomContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
