// group_detail_screen.dart
import 'package:flutter/material.dart';
import '../pages/contact_detail_page.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';
import '../providers/contact_provider.dart';
import '../models/contact.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/contact_card.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupName;

  const GroupDetailScreen({super.key, required this.groupName});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  String _sortOrder = 'asc';
  final Set<String> _changedContactNames = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchGroupContacts();
      Provider.of<GroupProvider>(
        context,
        listen: false,
      ).fetchAllContactsForGroupAssignment();
    });
  }

  Future<void> _fetchGroupContacts() async {
    await Provider.of<GroupProvider>(
      context,
      listen: false,
    ).fetchContactsByGroup(widget.groupName);
  }

  void _showAddContactDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('그룹에 연락처 추가'),
          content: Consumer<GroupProvider>(
            builder: (context, provider, _) {
              final contacts =
                  provider.allContactsForAssignment
                      .where(
                        (c) =>
                            c.group != widget.groupName ||
                            c.group == widget.groupName,
                      )
                      .toList();
              if (contacts.isEmpty) {
                return const Text('추가할 연락처가 없습니다.');
              }
              return SizedBox(
                width: double.maxFinite,
                child: StatefulBuilder(
                  builder: (context, dialogSetState) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: contacts.length,
                      itemBuilder: (ctx, i) {
                        final contact = contacts[i];
                        final isInGroup = contact.group == widget.groupName;
                        return ListTile(
                          title: Text(contact.name),
                          subtitle: Text(contact.phone ?? ''),
                          trailing:
                              isInGroup
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : const Icon(Icons.check_box_outline_blank),
                          onTap: () async {
                            try {
                              if (!isInGroup) {
                                await provider.updateContactGroup(
                                  contact.id!,
                                  widget.groupName,
                                );
                                _changedContactNames.add(
                                  '${contact.name}님을 추가했습니다.',
                                );
                              } else {
                                await provider.updateContactGroup(
                                  contact.id!,
                                  null,
                                );
                                _changedContactNames.add(
                                  '${contact.name}님을 해제했습니다.',
                                );
                              }
                              dialogSetState(() {});
                              _fetchGroupContacts();
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('오류: ${e.toString()}'),
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_changedContactNames.isNotEmpty && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_changedContactNames.join('\n'))),
                  );
                }
                Navigator.of(dialogContext).pop();
                _changedContactNames.clear();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '${widget.groupName} 그룹',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddContactDialog(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortOrder = value == 'name_desc' ? 'desc' : 'asc';
              });
              _fetchGroupContacts();
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'name_asc',
                    child: Text('이름 오름차순'),
                  ),
                  const PopupMenuItem(
                    value: 'name_desc',
                    child: Text('이름 내림차순'),
                  ),
                ],
          ),
        ],
      ),
      body: Consumer<GroupProvider>(
        builder: (context, provider, _) {
          final contacts = provider.contactsInSelectedGroup;
          final sorted = List<Contact>.from(contacts)..sort((a, b) {
            final cmp = a.name.compareTo(b.name);
            return _sortOrder == 'asc' ? cmp : -cmp;
          });
          if (sorted.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off_rounded,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '이 그룹에는 아직 연락처가 없습니다.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '오른쪽 상단 + 버튼으로 추가하세요.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final contact = sorted[index];
              return ContactCard(
                contact: contact,
                onTap: () async {
                  final bool? res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ContactDetailPage(contact: contact),
                    ),
                  );
                  if (res == true) _fetchGroupContacts();
                },
                onFavoriteToggled: _fetchGroupContacts,
              );
            },
          );
        },
      ),
    );
  }
}
