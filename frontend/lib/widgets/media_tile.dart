import 'package:flutter/material.dart';

import '../models/media_entry.dart';

/// MediaTile displays a single media entry in a list.
/// Shows title, type, status, rating, and optional notes.
/// Tappable to edit, swipeable to delete.
class MediaTile extends StatelessWidget {
  const MediaTile({
    super.key,
    /// The media entry to display
    required this.entry,
    /// Callback when the tile is tapped (usually opens edit sheet)
    required this.onTap,
    /// Callback when the tile is swiped to delete
    required this.onDelete,
  });

  final MediaEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  /// Returns the color associated with the entry's watch status.
  /// Used for the status badge coloring.
  Color _statusColor() {
    switch (entry.status) {
      case WatchStatus.watchlist:
        return Colors.blueGrey; // Neutral blue-gray
      case WatchStatus.watching:
        return Colors.amber; // Warm amber/yellow
      case WatchStatus.watched:
        return Colors.green; // Positive green
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor();

    return Dismissible(
      // Unique key for this dismissible item (required for lists)
      key: ValueKey(entry.id),
      // Only allow swiping from right to left
      direction: DismissDirection.endToStart,
      // Call onDelete when item is dismissed
      onDismissed: (_) => onDelete(),
      
      // ========== DELETE BACKGROUND ==========
      // Visual shown behind the tile when swiping to delete
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(16),
        ),
        // Delete icon shown on the red background
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      
      // ========== MAIN TILE CONTENT ==========
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        // InkWell provides the tap ripple effect
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          // All the content inside
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========== MEDIA TYPE ICON BOX ==========
                // Colored box with icon indicating the media type
                Container(
                  width: 52,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: entry.posterUrl == null
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: entry.type == MediaType.film
                                ? [
                                    const Color(0xFF9333EA),
                                    const Color(0xFF581C87)
                                  ]
                                : entry.type == MediaType.show
                                    ? [
                                        const Color(0xFF2563EB),
                                        const Color(0xFF1E3A8A)
                                      ]
                                    : [
                                        const Color(0xFF0F766E),
                                        const Color(0xFF134E4A)
                                      ],
                          )
                        : null,
                    color: entry.posterUrl == null ? null : Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: entry.posterUrl != null
                      ? Image.network(
                          entry.posterUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            entry.type.icon,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 28,
                          ),
                        )
                      : Icon(
                          entry.type.icon,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 28,
                        ),
                ),
                
                const SizedBox(width: 14),
                
                // ========== MAIN CONTENT ==========
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ========== TITLE ==========
                      Text(
                        entry.year == null
                            ? entry.title
                            : '${entry.title} (${entry.year})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      
                      // ========== BADGES ROW ==========
                      // Show type, status, and season badges
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Media type badge (Film/Show/Game)
                          _Badge(
                            label: entry.type.label,
                            color: entry.type == MediaType.film
                                ? const Color(0xFF9333EA)
                                : entry.type == MediaType.show
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF14B8A6),
                          ),
                          
                          // Status badge (Watchlist/Watching/Watched)
                          _Badge(label: entry.status.label, color: statusColor),
                          
                          // Season number (only for shows)
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
                      
                      // ========== STAR RATING ==========
                      // Show 5 stars, filled up to the rating value
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
                      
                      // ========== NOTES ==========
                      // Show user's personal notes (max 2 lines)
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
                      
                      // ========== WATCHED DATE ==========
                      // Show when the user finished watching/playing
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
                
                // ========== CHEVRON ICON ==========
                // Right-pointing arrow indicating the tile is tappable
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

/// _Badge is a small colored label for displaying metadata.
/// Used for type, status, and season information.
class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        // Colored background with low opacity (18% alpha)
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
