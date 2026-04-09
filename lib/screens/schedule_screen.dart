import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/schedule_model.dart';
import '../theme/app_theme.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // ==================== STATE ====================

  List<ScheduleItemModel> _items = [];
  bool _isLoading = true;
  bool _isGenerating = false;

  // ==================== LIFECYCLE ====================

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    _loadSchedule();
  }

  // ==================== DATA ====================

  Future<void> _loadSchedule() async {
    _setLoading(true);

    try {
      final data = await ApiService.getSchedule();
      _applySchedule(data);
    } catch (e) {
      // silent
    } finally {
      _setLoading(false);
    }
  }

  void _applySchedule(Map<String, dynamic> data) {
    setState(() {
      _items = _mapItems(data);
    });
  }

  List<ScheduleItemModel> _mapItems(Map<String, dynamic> data) {
    return (data['items'] as List?)
            ?.map((e) => ScheduleItemModel.fromJson(e))
            .toList() ??
        [];
  }

  void _setLoading(bool value) {
    setState(() => _isLoading = value);
  }

  void _setGenerating(bool value) {
    setState(() => _isGenerating = value);
  }

  // ==================== ACTIONS ====================

  Future<void> _generateSchedule() async {
    _setGenerating(true);

    try {
      await ApiService.generateSchedule();
      await _loadSchedule();
      _showSnack('AI schedule generated!', success: true);
    } catch (e) {
      _showSnack('Failed to generate schedule', isError: true);
    } finally {
      _setGenerating(false);
    }
  }

  void _showSnack(String message,
      {bool success = false, bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            success ? AppTheme.success : isError ? AppTheme.error : null,
      ),
    );
  }

  // ==================== UI ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Schedule'),
        actions: [_buildGenerateButton()],
      ),
      body: Container(
<<<<<<< HEAD
        decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : _items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 64, color: AppTheme.accent.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        const Text('No schedule yet', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                        const SizedBox(height: 8),
                        const Text('Add tasks first, then generate', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _generateSchedule,
                            icon: const Icon(Icons.auto_awesome_rounded),
                            label: const Text('Generate Schedule'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadSchedule,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        final color = AppTheme.getPriorityColor(item.priority);
                        final isLast = index == _items.length - 1;

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Timeline
                              SizedBox(
                                width: 60,
                                child: Column(
                                  children: [
                                    Text(item.startTime,
                                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6)],
                                      ),
                                    ),
                                    if (!isLast)
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          color: color.withValues(alpha: 0.2),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Card
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        color.withValues(alpha: 0.08),
                                        AppTheme.background,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: color.withValues(alpha: 0.15)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(item.title,
                                                style: const TextStyle(
                                                    color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: color.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(item.priority.toUpperCase(),
                                                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time_rounded, size: 14, color: AppTheme.textSecondary.withValues(alpha: 0.7)),
                                          const SizedBox(width: 4),
                                          Text('${item.startTime} – ${item.endTime}',
                                              style: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.7), fontSize: 13)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
=======
        decoration:
            const BoxDecoration(gradient: AppTheme.splashGradient),
        child: _buildBody(),
>>>>>>> 65dac9efce6f6a05af3a069d93ff0bb2b9fe5af1
      ),
    );
  }

  Widget _buildGenerateButton() {
    return IconButton(
      onPressed: _isGenerating ? null : _generateSchedule,
      tooltip: 'Generate Schedule',
      icon: _isGenerating
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.accent,
              ),
            )
          : const Icon(Icons.auto_awesome_rounded,
              color: AppTheme.accent),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (_items.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadSchedule,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, index) =>
            _buildScheduleItem(_items[index], index),
      ),
    );
  }

  // ==================== UI STATES ====================

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded,
              size: 64,
              color: AppTheme.accent.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('No schedule yet',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Add tasks first, then generate',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13)),
          const SizedBox(height: 24),
          _buildGenerateButtonCTA(),
        ],
      ),
    );
  }

  Widget _buildGenerateButtonCTA() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ElevatedButton.icon(
        onPressed: _generateSchedule,
        icon: const Icon(Icons.auto_awesome_rounded),
        label: const Text('Generate Schedule'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }

  // ==================== ITEM BUILDER ====================

  Widget _buildScheduleItem(
      ScheduleItemModel item, int index) {
    final color = AppTheme.getPriorityColor(item.priority);
    final isLast = index == _items.length - 1;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTimeline(item, color, isLast),
          const SizedBox(width: 12),
          _buildItemCard(item, color, isLast),
        ],
      ),
    );
  }

  Widget _buildTimeline(
      ScheduleItemModel item, Color color, bool isLast) {
    return SizedBox(
      width: 60,
      child: Column(
        children: [
          Text(item.startTime,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 6)
              ],
            ),
          ),
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                color: color.withValues(alpha: 0.2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemCard(
      ScheduleItemModel item, Color color, bool isLast) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.08),
              Colors.white.withValues(alpha: 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItemHeader(item, color),
            const SizedBox(height: 8),
            _buildItemTime(item),
          ],
        ),
      ),
    );
  }

  Widget _buildItemHeader(
      ScheduleItemModel item, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(item.title,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(item.priority.toUpperCase(),
              style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _buildItemTime(ScheduleItemModel item) {
    return Row(
      children: [
        Icon(Icons.access_time_rounded,
            size: 14,
            color:
                AppTheme.textSecondary.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text('${item.startTime} – ${item.endTime}',
            style: TextStyle(
                color: AppTheme.textSecondary
                    .withValues(alpha: 0.7),
                fontSize: 13)),
      ],
    );
  }
}
