import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:emoji_picker_flutter/src/emoji_picker_internal_utils.dart';
import 'package:emoji_picker_flutter/src/recent_emoji.dart';
import 'package:flutter/material.dart';

class RecentEmojiView extends StatefulWidget {
  /// EmojiPicker for flutter
  const RecentEmojiView({
    Key? key,
    this.onEmojiSelected,
    this.config = const Config(),
  }) : super(key: key);

  /// The function called when the emoji is selected
  final OnEmojiSelected? onEmojiSelected;

  /// Config for customizations
  final Config config;

  @override
  RecentEmojiViewState createState() => RecentEmojiViewState();
}

/// EmojiPickerState
class RecentEmojiViewState extends State<RecentEmojiView> {
  final List<CategoryEmoji> _categoryEmoji = List.empty(growable: true);
  List<RecentEmoji> _recentEmoji = List.empty(growable: true);
  late EmojiViewState _state;

  // Prevent emojis to be reloaded with every build
  bool _loaded = false;

  // Internal helper
  final _emojiPickerInternalUtils = EmojiPickerInternalUtils();

  /// Update recentEmoji list from outside using EmojiPickerUtils
  void updateRecentEmoji(List<RecentEmoji> recentEmoji,
      {bool refresh = false}) {
    _recentEmoji = recentEmoji;
    _categoryEmoji[0] = _categoryEmoji[0]
        .copyWith(emoji: _recentEmoji.map((e) => e.emoji).toList());
    if (mounted && refresh) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _updateEmojis();
  }

  @override
  void didUpdateWidget(covariant RecentEmojiView oldWidget) {
    if (oldWidget.config != widget.config) {
      // Config changed - rebuild EmojiPickerView completely
      _loaded = false;
      _updateEmojis();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return widget.config.loadingIndicator;
    }
    return RecentView(widget.config, _state);
  }

  // Add recent emoji handling to tap listener
  OnEmojiSelected _getOnEmojiListener() {
    return (category, emoji) {
      if (widget.config.showRecentsTab) {
        _emojiPickerInternalUtils
            .addEmojiToRecentlyUsed(emoji: emoji, config: widget.config)
            .then((newRecentEmoji) => {
                  // we don't want to rebuild the widget if user is currently on
                  // the RECENT tab, it will make emojis jump since sorting
                  // is based on the use frequency
                  updateRecentEmoji(newRecentEmoji,
                      refresh: category != Category.recent),
                });
      }

      widget.onEmojiSelected?.call(category, emoji);
    };
  }

  // Initialize emoji data
  Future<void> _updateEmojis() async {
    _categoryEmoji.clear();
    if (widget.config.showRecentsTab) {
      _recentEmoji = await _emojiPickerInternalUtils.getRecentEmojis();
      final recentEmojiMap = _recentEmoji.map((e) => e.emoji).toList();
      _categoryEmoji.add(CategoryEmoji(Category.recent, recentEmojiMap));
    }
    final data = widget.config.emojiSet ?? defaultEmojiSet;
    _categoryEmoji.addAll(widget.config.checkPlatformCompatibility
        ? await _emojiPickerInternalUtils.filterUnsupported(data)
        : data);
    _state = EmojiViewState(
      _categoryEmoji,
      _getOnEmojiListener(),
      null,
    );
    if (mounted) {
      setState(() {
        _loaded = true;
      });
    }
  }
}
