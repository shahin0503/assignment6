import 'package:assignment6/controller/simple_ui_controller.dart';
import 'package:assignment6/view/chat_detail_view.dart';
import 'package:assignment6/view/chat_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    SimpleUIController simpleUIController = Get.put(SimpleUIController());

  @override
  Widget build(BuildContext context) {
     var size = MediaQuery.of(context).size;
    var theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return _buildLargeScreen(size, simpleUIController, theme);
            } else {
              return _buildSmallScreen(size, simpleUIController, theme);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLargeScreen(
      Size size, SimpleUIController simpleUIController, ThemeData theme) {
    return const Row(
      children: [
        Expanded(
            flex: 2,
            child: ChatView()
            ),
        // SizedBox(
        //   width: size.width * 0.06,
        // ),
        Expanded(
            flex: 5,
            child: ChatDetailView()
            // child: _buildMainBody(
            //   size,
            //   simpleUIController,
            //   theme,
            // ))
        )
      ],
    );
  }

  Widget _buildSmallScreen(
      Size size, SimpleUIController simpleUIController, ThemeData theme) {
    return const Center(
      child: ChatView()
      // child: _buildMainBody(
      //   size,
      //   simpleUIController,
      //   theme,
      // ),
    );
  }

}
