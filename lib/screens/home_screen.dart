import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../theme/app_theme.dart';
import '../widgets/note_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/category_chip.dart';
import '../widgets/stats_bar.dart';
import 'add_note_screen.dart';
import 'note_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final NoteService noteService;

  const HomeScreen({super.key, required this.noteService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  NoteCategory? _selectedCategory;
  bool _isGridView = true;
  String _searchQuery = '';
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  List<Note> get _filteredNotes {
    List<Note> notes = widget.noteService.sortedNotes;
    if (_searchQuery.isNotEmpty) {
      notes = widget.noteService.searchNotes(_searchQuery);
    }
    if (_selectedCategory != null) {
      notes = notes.where((n) => n.category == _selectedCategory).toList();
    }
    return notes;
  }

  void _navigateToAddNote() async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddNoteScreen(noteService: widget.noteService),
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      ),
    );
    setState(() {});
  }

  void _navigateToDetail(Note note) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NoteDetailScreen(
          note: note,
          noteService: widget.noteService,
        ),
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
      ),
    );
    setState(() {});
  }

  void _showDeleteDialog(Note note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Note',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${note.title.isEmpty ? "Untitled" : note.title}"?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await widget.noteService.deleteNote(note.id);
              if (ctx.mounted) Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.neonPink),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = _filteredNotes;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: FadeInDown(
                  duration: const Duration(milliseconds: 400),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Qnote',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    letterSpacing: 2,
                                    foreground: Paint()
                                      ..shader = const LinearGradient(
                                        colors: [
                                          AppTheme.neonCyan,
                                          AppTheme.neonPurple,
                                        ],
                                      ).createShader(
                                        const Rect.fromLTWH(0, 0, 150, 50),
                                      ),
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your thoughts, amplified.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      // View toggle
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.glassBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildViewToggle(
                              icon: Icons.grid_view_rounded,
                              isActive: _isGridView,
                              onTap: () => setState(() => _isGridView = true),
                            ),
                            _buildViewToggle(
                              icon: Icons.view_list_rounded,
                              isActive: !_isGridView,
                              onTap: () => setState(() => _isGridView = false),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Stats bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  duration: const Duration(milliseconds: 400),
                  child: StatsBar(
                    totalNotes: widget.noteService.totalNotes,
                    pinnedNotes: widget.noteService.totalPinned,
                    favoriteNotes: widget.noteService.totalFavorites,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 400),
                  child: SearchBarWidget(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    onClear: () {
                      setState(() => _searchQuery = '');
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Category chips
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: FadeInDown(
                  delay: const Duration(milliseconds: 300),
                  duration: const Duration(milliseconds: 400),
                  child: CategoryChipBar(
                    selectedCategory: _selectedCategory,
                    onSelected: (cat) {
                      setState(() => _selectedCategory = cat);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Notes list/grid
              Expanded(
                child: notes.isEmpty
                    ? _buildEmptyState()
                    : _isGridView
                        ? _buildGridView(notes)
                        : _buildListView(notes),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabController,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: AppTheme.neonGlow(AppTheme.neonCyan, intensity: 2),
          ),
          child: FloatingActionButton(
            onPressed: _navigateToAddNote,
            child: const Icon(Icons.add_rounded, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.neonCyan.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? AppTheme.neonCyan : AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cardDark,
                border: Border.all(color: AppTheme.glassBorder),
              ),
              child: const Icon(
                Icons.note_add_rounded,
                size: 36,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No notes yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + to create your first note',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(List<Note> notes) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return FadeInUp(
            delay: Duration(milliseconds: 50 * (index % 6)),
            duration: const Duration(milliseconds: 400),
            child: Slidable(
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) async {
                      await widget.noteService.togglePin(note.id);
                      setState(() {});
                    },
                    backgroundColor: AppTheme.neonGreen.withAlpha(50),
                    foregroundColor: AppTheme.neonGreen,
                    icon: note.isPinned
                        ? Icons.push_pin_outlined
                        : Icons.push_pin_rounded,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  SlidableAction(
                    onPressed: (_) => _showDeleteDialog(note),
                    backgroundColor: AppTheme.neonPink.withAlpha(50),
                    foregroundColor: AppTheme.neonPink,
                    icon: Icons.delete_rounded,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ],
              ),
              child: NoteCard(
                note: note,
                isGridView: true,
                onTap: () => _navigateToDetail(note),
                onLongPress: () => _showNoteOptions(note),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView(List<Note> notes) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return FadeInUp(
          delay: Duration(milliseconds: 50 * (index % 8)),
          duration: const Duration(milliseconds: 400),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Slidable(
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) async {
                      await widget.noteService.togglePin(note.id);
                      setState(() {});
                    },
                    backgroundColor: AppTheme.neonGreen.withAlpha(50),
                    foregroundColor: AppTheme.neonGreen,
                    icon: note.isPinned
                        ? Icons.push_pin_outlined
                        : Icons.push_pin_rounded,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  SlidableAction(
                    onPressed: (_) async {
                      await widget.noteService.toggleFavorite(note.id);
                      setState(() {});
                    },
                    backgroundColor: AppTheme.neonPink.withAlpha(50),
                    foregroundColor: AppTheme.neonPink,
                    icon: note.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  SlidableAction(
                    onPressed: (_) => _showDeleteDialog(note),
                    backgroundColor: Colors.red.withAlpha(50),
                    foregroundColor: Colors.red,
                    icon: Icons.delete_rounded,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ],
              ),
              child: NoteCard(
                note: note,
                onTap: () => _navigateToDetail(note),
                onLongPress: () => _showNoteOptions(note),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showNoteOptions(Note note) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: AppTheme.glassBorder),
            left: BorderSide(color: AppTheme.glassBorder),
            right: BorderSide(color: AppTheme.glassBorder),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              note.title.isEmpty ? 'Untitled' : note.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionTile(
              icon: note.isPinned
                  ? Icons.push_pin_outlined
                  : Icons.push_pin_rounded,
              label: note.isPinned ? 'Unpin' : 'Pin to top',
              color: AppTheme.neonGreen,
              onTap: () async {
                await widget.noteService.togglePin(note.id);
                if (ctx.mounted) Navigator.pop(ctx);
                setState(() {});
              },
            ),
            _buildOptionTile(
              icon: note.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              label: note.isFavorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
              color: AppTheme.neonPink,
              onTap: () async {
                await widget.noteService.toggleFavorite(note.id);
                if (ctx.mounted) Navigator.pop(ctx);
                setState(() {});
              },
            ),
            _buildOptionTile(
              icon: Icons.edit_rounded,
              label: 'Edit',
              color: AppTheme.neonCyan,
              onTap: () {
                Navigator.pop(ctx);
                _navigateToDetail(note);
              },
            ),
            _buildOptionTile(
              icon: Icons.delete_rounded,
              label: 'Delete',
              color: AppTheme.neonPink,
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteDialog(note);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(color: AppTheme.textPrimary),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
