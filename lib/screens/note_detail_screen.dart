import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../theme/app_theme.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  final NoteService noteService;

  const NoteDetailScreen({
    super.key,
    required this.note,
    required this.noteService,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late NoteCategory _selectedCategory;
  late int _selectedColorIndex;
  bool _isEditing = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _selectedCategory = widget.note.category;
    _selectedColorIndex = widget.note.colorIndex;

    _titleController.addListener(_onChanged);
    _contentController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _saveChanges() async {
    widget.note.title = _titleController.text.trim();
    widget.note.content = _contentController.text.trim();
    widget.note.category = _selectedCategory;
    widget.note.colorIndex = _selectedColorIndex;
    await widget.noteService.updateNote(widget.note);
    setState(() {
      _isEditing = false;
      _hasChanges = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Note saved'),
          backgroundColor: AppTheme.neonGreen.withAlpha(200),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _deleteNote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Note',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.neonPink),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.noteService.deleteNote(widget.note.id);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasChanges) {
      final result = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Unsaved Changes',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          content: const Text(
            'Do you want to save your changes?',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'discard'),
              child: const Text(
                'Discard',
                style: TextStyle(color: AppTheme.neonPink),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'save'),
              child: const Text('Save'),
            ),
          ],
        ),
      );

      if (result == 'save') {
        await _saveChanges();
      }
      return true;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = AppTheme.noteAccentColors[
        _selectedColorIndex % AppTheme.noteAccentColors.length];

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        body: Container(
          decoration:
              const BoxDecoration(gradient: AppTheme.backgroundGradient),
          child: SafeArea(
            child: Column(
              children: [
                // App bar
                FadeInDown(
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            if (_hasChanges) {
                              final shouldPop = await _onWillPop();
                              if (shouldPop && context.mounted) {
                                Navigator.pop(context);
                              }
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        // Pin toggle
                        IconButton(
                          onPressed: () async {
                            await widget.noteService
                                .togglePin(widget.note.id);
                            setState(() {});
                          },
                          icon: Icon(
                            widget.note.isPinned
                                ? Icons.push_pin_rounded
                                : Icons.push_pin_outlined,
                            color: widget.note.isPinned
                                ? AppTheme.neonGreen
                                : AppTheme.textSecondary,
                            size: 22,
                          ),
                        ),
                        // Favorite toggle
                        IconButton(
                          onPressed: () async {
                            await widget.noteService
                                .toggleFavorite(widget.note.id);
                            setState(() {});
                          },
                          icon: Icon(
                            widget.note.isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: widget.note.isFavorite
                                ? AppTheme.neonPink
                                : AppTheme.textSecondary,
                            size: 22,
                          ),
                        ),
                        // Edit/Save toggle
                        GestureDetector(
                          onTap: () {
                            if (_isEditing && _hasChanges) {
                              _saveChanges();
                            } else {
                              setState(() => _isEditing = !_isEditing);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: _isEditing
                                  ? LinearGradient(
                                      colors: [
                                        accentColor,
                                        accentColor.withAlpha(180),
                                      ],
                                    )
                                  : null,
                              color: _isEditing ? null : AppTheme.cardDark,
                              borderRadius: BorderRadius.circular(10),
                              border: _isEditing
                                  ? null
                                  : Border.all(color: AppTheme.glassBorder),
                              boxShadow: _isEditing
                                  ? AppTheme.neonGlow(accentColor,
                                      intensity: 0.5)
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isEditing
                                      ? Icons.check_rounded
                                      : Icons.edit_rounded,
                                  size: 16,
                                  color: _isEditing
                                      ? AppTheme.primaryDark
                                      : AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isEditing ? 'Save' : 'Edit',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _isEditing
                                        ? AppTheme.primaryDark
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Delete
                        IconButton(
                          onPressed: _deleteNote,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppTheme.neonPink,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Color picker (visible in edit mode)
                if (_isEditing) ...[
                  const SizedBox(height: 12),
                  FadeIn(
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox(
                      height: 32,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: AppTheme.noteAccentColors.length,
                        itemBuilder: (context, index) {
                          final color = AppTheme.noteAccentColors[index];
                          final isSelected = _selectedColorIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedColorIndex = index);
                              _hasChanges = true;
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 28,
                              height: 28,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check_rounded,
                                      size: 14, color: AppTheme.primaryDark)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeIn(
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox(
                      height: 32,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: NoteCategory.values.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedCategory = cat);
                              _hasChanges = true;
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? accentColor.withAlpha(30)
                                    : AppTheme.cardDark,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? accentColor
                                      : AppTheme.glassBorder,
                                ),
                              ),
                              child: Text(
                                '${cat.emoji} ${cat.label}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected
                                      ? accentColor
                                      : AppTheme.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // Note metadata
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    duration: const Duration(milliseconds: 300),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: accentColor.withAlpha(60),
                            ),
                          ),
                          child: Text(
                            '${widget.note.category.emoji} ${widget.note.category.label}',
                            style: TextStyle(
                              fontSize: 12,
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, yyyy • h:mm a')
                              .format(widget.note.updatedAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FadeInDown(
                    delay: const Duration(milliseconds: 150),
                    duration: const Duration(milliseconds: 300),
                    child: TextField(
                      controller: _titleController,
                      enabled: _isEditing,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Untitled',
                        hintStyle: TextStyle(
                          color: AppTheme.textSecondary.withAlpha(100),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                // Accent divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor,
                          accentColor.withAlpha(50),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FadeInDown(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 300),
                      child: TextField(
                        controller: _contentController,
                        enabled: _isEditing,
                        maxLines: null,
                        expands: true,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                          height: 1.7,
                        ),
                        decoration: InputDecoration(
                          hintText: _isEditing
                              ? 'Start writing...'
                              : 'No content',
                          hintStyle: TextStyle(
                            color: AppTheme.textSecondary.withAlpha(100),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                        textAlignVertical: TextAlignVertical.top,
                      ),
                    ),
                  ),
                ),
                // Word count footer
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_contentController.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length} words',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${_contentController.text.length} characters',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
