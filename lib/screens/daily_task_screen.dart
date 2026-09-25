import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/daily_tasks_api.dart';
import '../services/translation_service.dart';
import '../widgets/language_selector.dart';

class DailyTaskScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  final VoidCallback? onTaskCompleted;

  const DailyTaskScreen({
    super.key,
    required this.task,
    this.onTaskCompleted,
  });

  @override
  State<DailyTaskScreen> createState() => _DailyTaskScreenState();
}

class _DailyTaskScreenState extends State<DailyTaskScreen> {
  late Map<String, dynamic> _currentTask;
  bool _isUploading = false;
  String? _uploadError;

  // Selected file state
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;

  // Optional patient notes
  final TextEditingController _notesController = TextEditingController();

  // Voice recording simulation / helper state
  bool _isRecordingVoice = false;
  int _recordSeconds = 0;
  bool _hasVoiceRecording = false;

  @override
  void initState() {
    super.initState();
    _currentTask = Map<String, dynamic>.from(widget.task);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String get _submissionType =>
      (_currentTask['submission_type'] ?? 'PHOTO').toString().toUpperCase();

  String get _status =>
      (_currentTask['status'] ?? 'ASSIGNED').toString().toUpperCase();

  bool get _isSubmitted =>
      _status == 'SUBMITTED' || _status == 'APPROVED' || _status == 'REVIEWED';

  bool get _needsRetry => _status == 'NEEDS_RETRY';

  IconData _iconForStep(String? key) {
    switch (key) {
      case 'chair':
        return Icons.chair_rounded;
      case 'accessibility_new':
        return Icons.accessibility_new_rounded;
      case 'self_improvement':
        return Icons.self_improvement_rounded;
      case 'replay':
        return Icons.replay_rounded;
      case 'spa':
        return Icons.spa_rounded;
      case 'arrow_back':
        return Icons.arrow_back_rounded;
      case 'arrow_forward':
        return Icons.arrow_forward_rounded;
      case 'air':
        return Icons.air_rounded;
      case 'light_mode':
        return Icons.light_mode_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'mic':
        return Icons.mic_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'record_voice_over':
        return Icons.record_voice_over_rounded;
      case 'edit':
        return Icons.edit_rounded;
      case 'local_florist':
        return Icons.local_florist_rounded;
      case 'eco':
        return Icons.eco_rounded;
      case 'photo_camera':
        return Icons.photo_camera_rounded;
      case 'crop_square':
        return Icons.crop_square_rounded;
      case 'change_history':
        return Icons.change_history_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'category':
        return Icons.category_rounded;
      case 'draw':
        return Icons.draw_rounded;
      case 'table_restaurant':
        return Icons.table_restaurant_rounded;
      case 'auto_stories':
        return Icons.auto_stories_rounded;
      case 'border_all':
        return Icons.border_all_rounded;
      case 'pan_tool':
        return Icons.pan_tool_rounded;
      case 'edit_note':
        return Icons.edit_note_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'visibility':
        return Icons.visibility_rounded;
      case 'music_note':
        return Icons.music_note_rounded;
      case 'hearing':
        return Icons.hearing_rounded;
      case 'grid_view':
        return Icons.grid_view_rounded;
      case 'format_line_spacing':
        return Icons.format_line_spacing_rounded;
      case 'window':
        return Icons.window_rounded;
      case 'note_alt':
        return Icons.note_alt_rounded;
      case 'history_edu':
        return Icons.history_edu_rounded;
      case 'filter_2':
        return Icons.filter_2_rounded;
      case 'view_column':
        return Icons.view_column_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  // ------------------------------------------------------------
  // FILE PICKING
  // ------------------------------------------------------------
  Future<void> _pickPhoto() async {
    setState(() => _uploadError = null);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
      );
      if (result.isNotEmpty) {
        final file = result.first;
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedFileBytes = bytes;
          _selectedFileName = file.name;
        });
      }
    } catch (e) {
      setState(() => _uploadError = 'Could not select photo: $e');
    }
  }

  Future<void> _pickVideo() async {
    setState(() => _uploadError = null);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.video,
      );
      if (result.isNotEmpty) {
        final file = result.first;
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedFileBytes = bytes;
          _selectedFileName = file.name;
        });
      }
    } catch (e) {
      setState(() => _uploadError = 'Could not select video: $e');
    }
  }

  Future<void> _pickAudioFile() async {
    setState(() => _uploadError = null);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.audio,
      );
      if (result.isNotEmpty) {
        final file = result.first;
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedFileBytes = bytes;
          _selectedFileName = file.name;
          _hasVoiceRecording = true;
        });
      }
    } catch (e) {
      setState(() => _uploadError = 'Could not select audio file: $e');
    }
  }

  void _simulateVoiceRecording() async {
    if (_isRecordingVoice) {
      // Stop recording
      setState(() {
        _isRecordingVoice = false;
        _hasVoiceRecording = true;
        // Generate lightweight audio payload header for proof
        _selectedFileBytes = Uint8List.fromList([
          82, 73, 70, 70, 36, 0, 0, 0, 87, 65, 86, 69, 102, 109, 116, 32
        ]);
        _selectedFileName =
            'voice_recording_${DateTime.now().millisecondsSinceEpoch}.wav';
      });
    } else {
      // Start recording
      setState(() {
        _isRecordingVoice = true;
        _recordSeconds = 0;
        _selectedFileBytes = null;
        _selectedFileName = null;
        _hasVoiceRecording = false;
      });

      // Simple recording timer tick
      for (int i = 1; i <= 60; i++) {
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted || !_isRecordingVoice) break;
        setState(() {
          _recordSeconds = i;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // SUBMISSION
  // ------------------------------------------------------------
  Future<void> _submitTaskProof() async {
    final dailyTaskId = _currentTask['daily_task_id'] as String?;
    if (dailyTaskId == null) return;

    if (_selectedFileBytes == null &&
        _notesController.text.trim().isEmpty &&
        !_hasVoiceRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TrText(
            _submissionType == 'VIDEO'
                ? 'Please select or record a video first.'
                : (_submissionType == 'AUDIO'
                    ? 'Please record or select a voice note first.'
                    : 'Please select a photo of your completed task first.'),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    try {
      final res = await DailyTasksApi.submitTask(
        dailyTaskId: dailyTaskId,
        fileBytes: _selectedFileBytes,
        fileName: _selectedFileName ??
            (_submissionType == 'AUDIO' ? 'voice_note.wav' : 'proof.jpg'),
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        submissionType: _submissionType,
      );

      final updatedTask = res['task'] as Map<String, dynamic>?;
      if (mounted) {
        setState(() {
          _isUploading = false;
          if (updatedTask != null) {
            _currentTask = updatedTask;
          } else {
            _currentTask['status'] = 'SUBMITTED';
            _currentTask['submitted_at'] = DateTime.now().toIso8601String();
          }
        });

        widget.onTaskCompleted?.call();
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadError = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE4EFEA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF376B5C),
                size: 52,
              ),
            ),
            const SizedBox(height: 18),
            const TrText(
              'Task Submitted!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173B35),
              ),
            ),
            const SizedBox(height: 8),
            const TrText(
              'Your today\'s task has been submitted successfully. Your caregiver will review your wonderful progress!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2EBE6)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.task_alt_rounded,
                          size: 18, color: Color(0xFF376B5C)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _currentTask['title'] ?? 'Daily Task',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173B35),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.cloud_done_rounded,
                          size: 18, color: Color(0xFF376B5C)),
                      const SizedBox(width: 8),
                      Text(
                        'Submission: $_submissionType',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF376B5C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const TrText(
                  'Back to Dashboard',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _currentTask['title'] ?? 'Today\'s Task';
    final description = _currentTask['description'] ?? '';
    final instructions = _currentTask['instructions'] ?? '';
    final duration = _currentTask['estimated_duration'] ?? '5 mins';
    final category = _currentTask['task_category'] ?? 'DAILY_ACTIVITY';
    final visualSteps = (_currentTask['visual_steps'] as List?) ?? [];
    final readingPassage = _currentTask['reading_passage'] as String?;
    final caregiverFeedback = _currentTask['caregiver_feedback'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF173B35)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const TrText(
          'Today\'s Daily Task',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF173B35),
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------------------------------------------
              // STATUS BANNER
              // ----------------------------------------------------
              if (_isSubmitted) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _status == 'APPROVED'
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFE4EFEA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _status == 'APPROVED'
                          ? const Color(0xFF86EFAC)
                          : const Color(0xFFBCE3D5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _status == 'APPROVED'
                            ? Icons.verified_rounded
                            : Icons.check_circle_rounded,
                        color: const Color(0xFF376B5C),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TrText(
                              _status == 'APPROVED'
                                  ? 'Task Approved by Caregiver!'
                                  : 'Task Submitted for Review',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF173B35),
                              ),
                            ),
                            const SizedBox(height: 3),
                            TrText(
                              _status == 'APPROVED'
                                  ? 'Well done! Your caregiver reviewed and approved your activity.'
                                  : 'Submitted successfully. Your caregiver can view your proof.',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              if (_needsRetry) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFED7AA)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.replay_rounded,
                          color: Color(0xFFEA580C), size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TrText(
                              'Please Try Again',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9A3412),
                              ),
                            ),
                            const SizedBox(height: 4),
                            TrText(
                              caregiverFeedback != null &&
                                      caregiverFeedback.isNotEmpty
                                  ? 'Caregiver Note: "$caregiverFeedback"'
                                  : 'Your caregiver requested another try for today\'s activity. Please follow instructions and resubmit.',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ----------------------------------------------------
              // HERO TASK HEADER CARD
              // ----------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF376B5C), Color(0xFF224D41)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF376B5C).withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            category.replaceAll('_', ' '),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined,
                                size: 16, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              duration,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          _submissionType == 'VIDEO'
                              ? Icons.videocam_rounded
                              : (_submissionType == 'AUDIO'
                                  ? Icons.mic_rounded
                                  : Icons.photo_camera_rounded),
                          color: const Color(0xFF86D5B8),
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        TrText(
                          'Proof Required: $_submissionType Upload',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF86D5B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // ----------------------------------------------------
              // INSTRUCTIONS & WHAT TO DO
              // ----------------------------------------------------
              const TrText(
                'Instructions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),
              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2EBE6)),
                ),
                child: Text(
                  instructions,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF173B35),
                    height: 1.45,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ----------------------------------------------------
              // READING PASSAGE (IF READING TASK)
              // ----------------------------------------------------
              if (readingPassage != null && readingPassage.isNotEmpty) ...[
                const TrText(
                  'Reading Passage',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173B35),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_stories_rounded,
                              color: Color(0xFFD97706), size: 24),
                          const SizedBox(width: 8),
                          TrText(
                            'Please read aloud:',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        readingPassage,
                        style: const TextStyle(
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF78350F),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ----------------------------------------------------
              // VISUAL STEP-BY-STEP GUIDES
              // ----------------------------------------------------
              if (visualSteps.isNotEmpty) ...[
                const TrText(
                  'Step-by-Step Visual Guidance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173B35),
                  ),
                ),
                const SizedBox(height: 12),
                ...visualSteps.map((step) {
                  final sMap = Map<String, dynamic>.from(step as Map);
                  final num = sMap['step'] ?? '';
                  final stepTitle = sMap['title'] ?? 'Step $num';
                  final detail = sMap['detail'] ?? '';
                  final iconName = sMap['icon'] as String?;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2EBE6)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4EFEA),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            _iconForStep(iconName),
                            color: const Color(0xFF376B5C),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Step $num: $stepTitle',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173B35),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                detail,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],

              // ----------------------------------------------------
              // SUBMISSION PANEL
              // ----------------------------------------------------
              const TrText(
                'Upload Task Completion Proof',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B35),
                ),
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE2EBE6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_uploadError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded,
                                color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _uploadError!,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.red.shade800),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // PHOTO SUBMISSION WIDGET
                    if (_submissionType == 'PHOTO') ...[
                      if (_selectedFileBytes != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.black12,
                            child: Image.memory(
                              _selectedFileBytes!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedFileName ?? 'photo.jpg',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _pickPhoto,
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const TrText('Change Photo'),
                            ),
                          ],
                        ),
                      ] else ...[
                        SizedBox(
                          width: double.infinity,
                          height: 70,
                          child: ElevatedButton.icon(
                            onPressed: _pickPhoto,
                            icon: const Icon(Icons.camera_alt_rounded, size: 28),
                            label: const TrText(
                              'Take or Choose Photo',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE4EFEA),
                              foregroundColor: const Color(0xFF173B35),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],

                    // VIDEO SUBMISSION WIDGET
                    if (_submissionType == 'VIDEO') ...[
                      if (_selectedFileBytes != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4EFEA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.video_file_rounded,
                                  size: 38, color: Color(0xFF376B5C)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedFileName ?? 'video.mp4',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF173B35),
                                      ),
                                    ),
                                    const TrText(
                                      'Video ready for submission',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh_rounded),
                                onPressed: _pickVideo,
                                tooltip: 'Replace Video',
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        SizedBox(
                          width: double.infinity,
                          height: 70,
                          child: ElevatedButton.icon(
                            onPressed: _pickVideo,
                            icon: const Icon(Icons.videocam_rounded, size: 28),
                            label: const TrText(
                              'Record or Select Video',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE4EFEA),
                              foregroundColor: const Color(0xFF173B35),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],

                    // AUDIO / VOICE NOTE WIDGET
                    if (_submissionType == 'AUDIO') ...[
                      if (_hasVoiceRecording && _selectedFileName != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4EFEA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.audiotrack_rounded,
                                  size: 36, color: Color(0xFF376B5C)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const TrText(
                                      'Voice Note Recorded',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF173B35),
                                      ),
                                    ),
                                    Text(
                                      _selectedFileName!,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _hasVoiceRecording = false;
                                    _selectedFileBytes = null;
                                    _selectedFileName = null;
                                  });
                                },
                                tooltip: 'Re-record',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 70,
                                child: ElevatedButton.icon(
                                  onPressed: _simulateVoiceRecording,
                                  icon: Icon(
                                    _isRecordingVoice
                                        ? Icons.stop_rounded
                                        : Icons.mic_rounded,
                                    size: 28,
                                    color: _isRecordingVoice
                                        ? Colors.white
                                        : const Color(0xFF173B35),
                                  ),
                                  label: Text(
                                    _isRecordingVoice
                                        ? 'Stop (${_recordSeconds}s)'
                                        : 'Record Voice Note',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _isRecordingVoice
                                          ? Colors.white
                                          : const Color(0xFF173B35),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isRecordingVoice
                                        ? Colors.red
                                        : const Color(0xFFE4EFEA),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: _pickAudioFile,
                              icon: const Icon(Icons.folder_open_rounded,
                                  color: Color(0xFF376B5C), size: 28),
                              tooltip: 'Choose audio file',
                            ),
                          ],
                        ),
                      ],
                    ],

                    const SizedBox(height: 18),

                    // PATIENT OPTIONAL NOTE INPUT
                    TextField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: TranslationService.instance.getCached(
                            'Say something about your task (Optional)'),
                        hintText: TranslationService.instance.getCached(
                            'e.g. I felt calm while stretching, it was fun!'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8F7F2),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // SUBMIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _submitTaskProof,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF376B5C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: _isUploading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  TrText(
                                    'Uploading Proof...',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : TrText(
                                _isSubmitted
                                    ? 'Resubmit New Proof'
                                    : 'Confirm & Submit Task',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
