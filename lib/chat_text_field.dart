import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatTextField extends StatefulWidget {
  final FocusNode focusNode;
  final TextEditingController textController;
  final VoidCallback onSubmit;

  const ChatTextField({Key? key, required this.focusNode, required this.textController, required this.onSubmit}) : super(key: key);

  @override
  State<ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
  int? maxLine;

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      focusNode: widget.focusNode,
      maxLines: maxLine,
      minLines: 1,
      maxLength: 200,
      padding: const EdgeInsets.all(8),
      onSubmitted: (value){
        widget.onSubmit();
      },
      controller: widget.textController,
      textInputAction: TextInputAction.send,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
      onChanged: (value) {
        var viewHeight = context.findRenderObject()?.paintBounds.size.height ?? 0;
        if (maxLine == null && viewHeight > 100) {
          setState(() {
            maxLine = 5;
          });
        } else if (maxLine != null && viewHeight < 100) {
          setState(() {
            maxLine = null;
          });
        }
      },
    );
  }
}
