import 'package:flutter/material.dart';
import 'package:flutter_riverpod_template/core/theme/app_preview.dart';
import 'package:flutter_riverpod_template/core/theme/app_spacing.dart';
import 'package:flutter_riverpod_template/l10n/app_localizations.dart';

/// 新建任务输入条。
class TodoComposer extends StatefulWidget {
  const TodoComposer({required this.onSubmit, super.key});

  final Future<void> Function(String title) onSubmit;

  @override
  State<TodoComposer> createState() => _TodoComposerState();
}

class _TodoComposerState extends State<TodoComposer> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 提交标题：空值和重复提交直接忽略，成功后清空输入并保持焦点。
  Future<void> _submit() async {
    final title = _controller.text.trim();
    if (title.isEmpty || _isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);
    await widget.onSubmit(title);
    if (!mounted) {
      return;
    }
    _controller.clear();
    setState(() => _isSubmitting = false);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: !_isSubmitting,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: l10n.newTodoHint,
              prefixIcon: Icon(Icons.add_task),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.small),
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.addTodo),
          ),
        ),
      ],
    );
  }
}

@AppPreview(name: '输入条', group: 'todo')
Widget previewTodoComposer() {
  return TodoComposer(onSubmit: (_) async {});
}
