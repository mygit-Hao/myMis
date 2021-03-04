import 'package:flui/flui.dart';
import 'package:flutter/material.dart';
import 'package:mis_app/utils/utils.dart';

class SearchTextField extends StatefulWidget {
  final List<String> suggestList;
  final ValueChanged onTextChanged;
  final Function onSearch;
  final String hintText;
  final TextStyle style;

  SearchTextField(
      {Key key,
      this.suggestList,
      this.onTextChanged,
      this.onSearch,
      this.hintText = '',
      this.style})
      : super(key: key);

  @override
  _SearchTextFieldState createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  TextEditingController _textController = TextEditingController();
  final GlobalKey<FLAutoCompleteState> _key = GlobalKey<FLAutoCompleteState>();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _textController.addListener(() {
      widget.onTextChanged(_textController.text);
    });
  }

  @override
  void dispose() {
    _textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: _textField),
        if (!Utils.textIsEmpty(_textController.text))
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _textController.text = '';
            },
          ),
        IconButton(
          icon: Icon(
            Icons.search,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: widget.onSearch,
        ),
      ],
    );
  }

  Widget get _textField {
    return FLAutoComplete(
      key: _key,
      focusNode: _focusNode,
      itemBuilder: (context, suggestion) => Padding(
        padding: EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(suggestion),
        ),
      ),
      onSelectedSuggestion: (suggestion) {
        _textController.text = suggestion;
        widget.onTextChanged(suggestion);
      },
      child: TextField(
        controller: _textController,
        decoration: InputDecoration(
          hintText: widget.hintText,
          isDense: true,
        ),
        style: widget.style,
        focusNode: _focusNode,
        onChanged: (text) {
          List<String> sugList = [];
          if (text != null && text.isNotEmpty) {
            for (String option in widget.suggestList) {
              if (option.toLowerCase().contains(text.toLowerCase())) {
                sugList.add(option);
              }
            }
          }
          _key.currentState.updateSuggestionList(sugList);
        },
      ),
    );
  }
}
