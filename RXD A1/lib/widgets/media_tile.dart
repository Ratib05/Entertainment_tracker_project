import 'package:flutter/material.dart';

import '../models/media_entry.dart';

class MediaTile extends StatelessWidget {
  const MediaTile({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  final MediaEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  Color _statusColor() {
    switch (entry.status) {
      case WatchStatus.watchlist:
        return Colors.blueGrey;
      case WatchStatus.watching:
        return Colors.amber;
      case WatchStatus.watched:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor();

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: entry.type == MediaType.film
                          ? [const Color(0xFF9333EA), const Color(0xFF581C87)]
                          : [const Color(0xFF2563EB), const Color(0xFF1E3A8A)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    entry.type.icon,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _Badge(
                            label: entry.type.label,
                            color: entry.type == MediaType.film
                                ? const Color(0xFF9333EA)
                                : const Color(0xFF2563EB),
                          ),
                          _Badge(label: entry.status.label, color: statusColor),
                          if (entry.type == MediaType.show &&
                              entry.season != null)
                            Text(
                              'S${entry.season}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                        ],
                      ),
                      if (entry.rating != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < entry.rating!
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 16,
                              color: i < entry.rating!
                                  ? Colors.amber
                                  : Colors.grey.shade600,
                            );
                          }),
                        ),
                      ],
                      if (entry.note.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          entry.note,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                      if (entry.watchedDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Watched ${formatShortDate(entry.watchedDate!)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
