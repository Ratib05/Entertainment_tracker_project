import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/media_entry.dart';

class AddMediaSheet extends StatefulWidget {
  const AddMediaSheet({super.key, this.entry});

  final MediaEntry? entry;

  @override
  State<AddMediaSheet> createState() => _AddMediaSheetState();
}

class _AddMediaSheetState extends State<AddMediaSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late final TextEditingController _seasonController;
  late MediaType _type;
  late WatchStatus _status;
  int? _rating;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _titleController = TextEditingController(text: entry?.title ?? '');
    _noteController = TextEditingController(text: entry?.note ?? '');
    _seasonController = TextEditingController(
      text: entry?.season?.toString() ?? '',
    );
    _type = entry?.type ?? MediaType.film;
    _status = entry?.status ?? WatchStatus.watchlist;
    _rating = entry?.rating;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _seasonController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final seasonText = _seasonController.text.trim();
    final season = seasonText.isEmpty ? null : int.tryParse(seasonText);

    Navigator.pop(context, {
      'title': title,
      'note': _noteController.text.trim(),
      'type': _type,
      'status': _status,
      'rating': _rating,
      'season': _type == MediaType.show ? season : null,
      'watchedDate': _status == WatchStatus.watched ? DateTime.now() : null,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  _isEditing ? 'Edit Entry' : 'Log Title',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.movie_filter_outlined),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            Text(
              'Type',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<MediaType>(
              segments: MediaType.values
                  .map(
                    (t) => ButtonSegment(
                      value: t,
                      icon: Icon(t.icon),
                      label: Text(t.label),
                    ),
                  )
                  .toList(),
              selected: {_type},
              onSelectionChanged: (selection) {
                setState(() => _type = selection.first);
              },
            ),
            if (_type == MediaType.show) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _seasonController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Season (optional)',
                  prefixIcon: Icon(Icons.layers_outlined),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Status',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<WatchStatus>(
              segments: WatchStatus.values
                  .map(
                    (s) => ButtonSegment(
                      value: s,
                      label: Text(s.label),
                    ),
                  )
                  .toList(),
              selected: {_status},
              onSelectionChanged: (selection) {
                setState(() => _status = selection.first);
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Rating',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (index) {
                  final starValue = index + 1;
                  final filled = _rating != null && starValue <= _rating!;
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _rating = filled && _rating == starValue
                            ? null
                            : starValue;
                      });
                    },
                    icon: Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: filled ? Colors.amber : Colors.grey.shade600,
                      size: 32,
                    ),
                  );
                }),
                if (_rating != null)
                  TextButton(
                    onPressed: () => setState(() => _rating = null),
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(_isEditing ? 'Save Changes' : 'Add to Log'),
            ),
          ],
        ),
      ),
    );
  }
}
