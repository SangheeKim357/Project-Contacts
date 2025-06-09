import 'package:flutter/material.dart';
import '../services/group_service.dart';

class GroupSelectionDialog extends StatefulWidget {
  final String? initialGroup;

  const GroupSelectionDialog({Key? key, this.initialGroup}) : super(key: key);

  @override
  State<GroupSelectionDialog> createState() => _GroupSelectionDialogState();
}

class _GroupSelectionDialogState extends State<GroupSelectionDialog> {
  String? _selectedGroup;
  final TextEditingController _newGroupController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedGroup = widget.initialGroup; // 초기 선택된 그룹 설정
  }

  @override
  void dispose() {
    _newGroupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('그룹 선택 또는 추가'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: ListBody(
            children: <Widget>[
              // 기존 그룹 목록
              ...GroupService.groups.map((group) {
                return RadioListTile<String>(
                  title: Text(group),
                  value: group,
                  groupValue: _selectedGroup,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedGroup = value;
                    });
                  },
                );
              }).toList(),
              const Divider(),
              // 새 그룹 추가 입력 필드
              TextFormField(
                controller: _newGroupController,
                decoration: const InputDecoration(
                  labelText: '새 그룹 이름',
                  hintText: '새로운 그룹명 입력',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      GroupService.groups.contains(value.trim())) {
                    return '이미 존재하는 그룹 이름입니다.';
                  }
                  return null;
                },
                onFieldSubmitted: (value) {
                  // 엔터키로도 추가 가능하도록
                  _addNewGroupAndSelect();
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _addNewGroupAndSelect,
                  child: const Text('새 그룹 추가'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('취소'),
          onPressed: () {
            Navigator.of(context).pop(); // 아무것도 선택하지 않고 닫기
          },
        ),
        TextButton(
          child: const Text('선택'),
          onPressed: () {
            if (_selectedGroup != null) {
              Navigator.of(context).pop(_selectedGroup);
            } else if (_newGroupController.text.isNotEmpty &&
                _formKey.currentState!.validate()) {
              final newGroupName = _newGroupController.text.trim();
              final added = GroupService.addGroup(newGroupName);
              if (added) {
                setState(() {
                  _selectedGroup = newGroupName;
                  _newGroupController.clear();
                });
                Navigator.of(context).pop(_selectedGroup);
              } else {
                // 그룹 추가 실패 시 메시지 처리 등
              }
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  void _addNewGroupAndSelect() {
    if (_formKey.currentState!.validate()) {
      final newGroupName = _newGroupController.text.trim();
      if (newGroupName.isNotEmpty) {
        if (GroupService.addGroup(newGroupName)) {
          setState(() {
            _selectedGroup = newGroupName; // 새로 추가된 그룹을 선택
            _newGroupController.clear(); // 입력 필드 초기화
          });
          // 새 그룹이 추가되고 바로 선택되었으니 다이얼로그 닫기
          Navigator.of(context).pop(_selectedGroup);
        }
      }
    }
  }
}
