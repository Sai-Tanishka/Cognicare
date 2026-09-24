import 'package:flutter/material.dart';
import '../services/translation_service.dart';

/// Shows the unified bottom sheet modal allowing the user to select an Indian or North-Eastern language
void showLanguageSelectorSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      final current = TranslationService.instance.currentLanguage;
      final northEastLangs = TranslationService.supportedLanguages
          .where((l) => l.region.contains('North-East'))
          .toList();
      final otherLangs = TranslationService.supportedLanguages
          .where((l) => !l.region.contains('North-East'))
          .toList();

      return DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.translate_rounded, color: Color(0xFF376B5C), size: 26),
                    SizedBox(width: 10),
                    Text(
                      'Select Language / భాష / भाषा',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173B35),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose your preferred language. All screen text and voice assistant adapt automatically.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      // North-Eastern Indian Languages
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4EFEA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.stars_rounded, color: Color(0xFF376B5C), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'North-Eastern Indian Languages',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF173B35),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...northEastLangs.map((lang) => _buildLanguageItem(context, lang, current)),

                      const SizedBox(height: 16),
                      // Major Indian & National Languages
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4F2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Major Indian & National Languages',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173B35),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...otherLangs.map((lang) => _buildLanguageItem(context, lang, current)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildLanguageItem(BuildContext context, AppLanguage lang, AppLanguage current) {
  final isSelected = lang.code == current.code;
  return Container(
    margin: const EdgeInsets.only(bottom: 6),
    decoration: BoxDecoration(
      color: isSelected ? const Color(0xFFE4EFEA) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isSelected ? const Color(0xFF376B5C) : const Color(0xFFEEEEEE),
        width: isSelected ? 1.5 : 1.0,
      ),
    ),
    child: ListTile(
      dense: true,
      title: Text(
        lang.nativeName,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          color: isSelected ? const Color(0xFF173B35) : Colors.black87,
        ),
      ),
      subtitle: Text(
        '${lang.name} (${lang.region})',
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? const Color(0xFF376B5C) : Colors.grey,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF376B5C))
          : null,
      onTap: () {
        TranslationService.instance.setLanguage(lang);
        Navigator.pop(context);
      },
    ),
  );
}

/// Reusable Language Selector Chip/Button that can be placed in AppBar.actions or in any header
class LanguageSelectorButton extends StatelessWidget {
  final Color? color;
  final bool compact;

  const LanguageSelectorButton({
    super.key,
    this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TranslationService.instance,
      builder: (context, _) {
        final currentLang = TranslationService.instance.currentLanguage;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: ActionChip(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF376B5C), width: 1.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            avatar: const Icon(
              Icons.translate_rounded,
              size: 16,
              color: Color(0xFF376B5C),
            ),
            label: Text(
              compact ? currentLang.code.toUpperCase() : currentLang.nativeName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color ?? const Color(0xFF173B35),
              ),
            ),
            onPressed: () => showLanguageSelectorSheet(context),
          ),
        );
      },
    );
  }
}

/// Reactive translated text widget.
/// Translates dynamically when language changes and re-renders automatically without page reload.
class TrText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TrText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  State<TrText> createState() => _TrTextState();
}

class _TrTextState extends State<TrText> {
  String _displayText = '';
  String _lastLang = '';

  @override
  void initState() {
    super.initState();
    TranslationService.instance.addListener(_updateTranslation);
    _updateTranslation();
  }

  @override
  void didUpdateWidget(covariant TrText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _updateTranslation();
    }
  }

  @override
  void dispose() {
    TranslationService.instance.removeListener(_updateTranslation);
    super.dispose();
  }

  void _updateTranslation() {
    final service = TranslationService.instance;
    final langCode = service.currentLanguage.code;
    _lastLang = langCode;

    if (langCode == 'en') {
      if (mounted) {
        setState(() => _displayText = widget.text);
      } else {
        _displayText = widget.text;
      }
      return;
    }

    // Check synchronous in-memory cache
    if (service.isCached(widget.text, targetLang: langCode)) {
      final cached = service.getCached(widget.text, targetLang: langCode);
      if (mounted) {
        setState(() => _displayText = cached);
      } else {
        _displayText = cached;
      }
      return;
    }

    // If not cached yet, display original while fetching in background
    _displayText = widget.text;

    service.translate(widget.text, targetLang: langCode).then((translated) {
      if (mounted && _lastLang == langCode) {
        setState(() {
          _displayText = translated;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayText.isEmpty ? widget.text : _displayText,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}

