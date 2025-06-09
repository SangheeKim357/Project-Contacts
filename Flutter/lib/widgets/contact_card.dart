import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contact.dart';
import '../providers/contact_provider.dart';
import '../providers/favorite_provider.dart';

class ContactCard extends StatefulWidget {
  final Contact contact;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggled;

  const ContactCard({
    super.key,
    required this.contact,
    this.onTap,
    this.onFavoriteToggled,
  });

  @override
  State<ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {
  @override
  Widget build(BuildContext context) {
    final contactProvider = Provider.of<ContactProvider>(
      context,
      listen: false,
    );
    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );

    final contact = widget.contact; // widget.contact 바로 사용

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  contact.name.isNotEmpty ? contact.name[0] : '?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (contact.phone != null && contact.phone!.isNotEmpty)
                      Text(
                        contact.phone!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    if (contact.group != null && contact.group!.isNotEmpty)
                      Text(
                        '그룹: ${contact.group}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  // ✅ contact.favorite가 null이면 false로 간주
                  (contact.favorite ?? false)
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color:
                      // ✅ contact.favorite가 null이면 false로 간주
                      (contact.favorite ?? false)
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                  size: 28,
                ),
                onPressed: () async {
                  // 낙관적 업데이트: widget.contact 객체가 외부에서 변경되지 않는다면,
                  // 임시로 새 Contact 객체를 만들거나 Provider가 변경된 객체를 전달해줘야 함.
                  // 여기서는 간단히 외부에서 객체가 변경된다는 가정 하에 rebuild 유도

                  try {
                    // contactProvider.toggleFavoriteStatus도 contact.favorite가 nullable임을 처리해야 합니다.
                    await contactProvider.toggleFavoriteStatus(contact);
                    print("눌림001");
                    await favoriteProvider.fetchFavoriteContacts();
                    widget.onFavoriteToggled?.call();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '즐겨찾기 상태 변경 실패: ${e.toString().split(":")[1].trim()}',
                        ),
                      ),
                    );
                    debugPrint('즐겨찾기 토글 실패: $e');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
