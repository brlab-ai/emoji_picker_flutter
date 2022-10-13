import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:emoji_picker_flutter/src/skin_tone_overlay.dart';
import 'package:flutter/material.dart';

/// Default EmojiPicker Implementation
class RecentView extends EmojiPickerBuilder {
  /// Constructor
  const RecentView(Config config, EmojiViewState state, {super.key})
      : super(config, state);

  @override
  DefaultEmojiPickerViewState createState() => DefaultEmojiPickerViewState();
}

class DefaultEmojiPickerViewState extends State<RecentView>
    with SingleTickerProviderStateMixin, SkinToneOverlayStateMixin {
  final double _tabBarHeight = 46;

  late final _scrollController = ScrollController();

  late final _utils = EmojiPickerUtils();

  @override
  void initState() {
    var initCategory = widget.state.categoryEmoji.indexWhere(
        (element) => element.category == widget.config.initCategory);
    if (initCategory == -1) {
      initCategory = 0;
    }
    _scrollController.addListener(closeSkinToneOverlay);
    super.initState();
  }

  @override
  void dispose() {
    closeSkinToneOverlay();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final emojiSize = widget.config.getEmojiSize(constraints.maxWidth);
        return EmojiContainer(
          color: widget.config.bgColor,
          buttonMode: widget.config.buttonMode,
          child: _buildPage(emojiSize, widget.state.categoryEmoji[0]),
        );
      },
    );
  }

  Widget _buildPage(double emojiSize, CategoryEmoji categoryEmoji) {
    // Display notice if recent has no entries yet
    if (categoryEmoji.category == Category.recent &&
        categoryEmoji.emoji.isEmpty) {
      return _buildNoRecent();
    }
    // Build page normally
    return GestureDetector(
      onTap: closeSkinToneOverlay,
      child: GridView.count(
          scrollDirection: Axis.vertical,
          controller: _scrollController,
          primary: false,
          padding: widget.config.gridPadding,
          crossAxisCount: widget.config.columns,
          mainAxisSpacing: widget.config.verticalSpacing,
          crossAxisSpacing: widget.config.horizontalSpacing,
          children: [
            for (int i = 0; i < categoryEmoji.emoji.length; i++)
              EmojiCell.fromConfig(
                emoji: categoryEmoji.emoji[i],
                emojiSize: emojiSize,
                categoryEmoji: categoryEmoji,
                index: i,
                onEmojiSelected: (category, emoji) {
                  closeSkinToneOverlay();
                  widget.state.onEmojiSelected(category, emoji);
                },
                onSkinToneDialogRequested: _openSkinToneDialog,
                config: widget.config,
              )
          ]),
    );
  }

  /// Build Widget for when no recent emoji are available
  Widget _buildNoRecent() {
    return Center(
      child: widget.config.noRecents,
    );
  }

  void _openSkinToneDialog(
    Emoji emoji,
    double emojiSize,
    CategoryEmoji? categoryEmoji,
    int index,
  ) {
    closeSkinToneOverlay();
    if (!emoji.hasSkinTone || !widget.config.enableSkinTones) {
      return;
    }
    showSkinToneOverlay(
        emoji,
        emojiSize,
        categoryEmoji,
        index,
        kSkinToneCount,
        widget.config,
        _scrollController.offset,
        _tabBarHeight,
        _utils,
        _onSkinTonedEmojiSelected);
  }

  void _onSkinTonedEmojiSelected(Category? category, Emoji emoji) {
    widget.state.onEmojiSelected(category, emoji);
    closeSkinToneOverlay();
  }
}
