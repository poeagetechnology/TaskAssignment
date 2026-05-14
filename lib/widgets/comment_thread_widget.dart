import 'package:flutter/material.dart';
import '../config/index.dart';
import '../models/index.dart';

/// Enhanced comment thread widget with replies and reactions
class CommentThreadWidget extends StatefulWidget {
  final TaskComment comment;
  final Function(CommentReaction) onAddReaction;
  final Function(String, String) onRemoveReaction;
  final Function(CommentReply) onAddReply;
  final bool canInteract;

  const CommentThreadWidget({
    required this.comment,
    required this.onAddReaction,
    required this.onRemoveReaction,
    required this.onAddReply,
    this.canInteract = true,
    super.key,
  });

  @override
  State<CommentThreadWidget> createState() => _CommentThreadWidgetState();
}

class _CommentThreadWidgetState extends State<CommentThreadWidget> {
  bool _showReplies = false;
  bool _showReplyInput = false;
  final _replyController = TextEditingController();
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = AppConfig.authService.currentUserId ?? 'unknown';
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  /// Get reaction emoji count
  Map<String, int> _getReactionCounts() {
    final counts = <String, int>{};
    for (final reaction in widget.comment.reactions) {
      counts[reaction.emoji] = (counts[reaction.emoji] ?? 0) + 1;
    }
    return counts;
  }

  /// Check if current user has reacted with emoji
  bool _userHasReacted(String emoji) {
    return widget.comment.reactions.any(
      (r) => r.emoji == emoji && r.userId == _currentUserId,
    );
  }

  void _handleAddReply() {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    final userName = AppConfig.authService.currentUser?.email ?? 'Unknown';
    final reply = CommentReply(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: _currentUserId,
      authorName: userName,
      text: text,
      createdAt: DateTime.now(),
    );

    widget.onAddReply(reply);
    _replyController.clear();
    setState(() => _showReplyInput = false);
  }

  void _toggleReaction(String emoji) {
    if (_userHasReacted(emoji)) {
      widget.onRemoveReaction(emoji, _currentUserId);
    } else {
      final userName = AppConfig.authService.currentUser?.email ?? 'Unknown';
      final reaction = CommentReaction(
        emoji: emoji,
        userId: _currentUserId,
        userName: userName,
        createdAt: DateTime.now(),
      );
      widget.onAddReaction(reaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reactionCounts = _getReactionCounts();

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md16),
      color: widget.comment.isPinned ? Colors.amber[50] : AppColors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: widget.comment.isPinned
                ? Colors.amber
                : AppColors.deepNavy.withValues(alpha: 0.1),
            width: widget.comment.isPinned ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Comment header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.constructionGold
                                  .withValues(alpha: 0.2),
                              child: Text(
                                widget.comment.authorName.isNotEmpty
                                    ? widget.comment.authorName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.constructionGold,
                                ),
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.comment.authorName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          fontWeight: AppTypography.bold,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _formatTime(widget.comment.createdAt),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: AppColors.slateGrey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widget.comment.isPinned)
                    Icon(
                      Icons.push_pin_rounded,
                      size: 18,
                      color: Colors.amber[700],
                    ),
                ],
              ),

              SizedBox(height: AppSpacing.md16),

              // Comment text
              Text(
                widget.comment.text,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.deepNavy),
              ),

              SizedBox(height: AppSpacing.md16),

              // Reactions row
              if (reactionCounts.isNotEmpty || widget.canInteract)
                Container(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...reactionCounts.entries.map((e) {
                          final isUserReacted = _userHasReacted(e.key);
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs8,
                            ),
                            child: GestureDetector(
                              onTap: () => _toggleReaction(e.key),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm12,
                                  vertical: AppSpacing.xs8,
                                ),
                                decoration: BoxDecoration(
                                  color: isUserReacted
                                      ? AppColors.constructionGold.withValues(
                                          alpha: 0.2,
                                        )
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isUserReacted
                                        ? AppColors.constructionGold
                                        : Colors.grey[300]!,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusSm,
                                  ),
                                ),
                                child: Text(
                                  '${e.key} ${e.value}',
                                  style: TextStyle(
                                    fontWeight: AppTypography.medium,
                                    color: isUserReacted
                                        ? AppColors.constructionGold
                                        : AppColors.deepNavy,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        if (widget.canInteract)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs8,
                            ),
                            child: _buildReactionMenu(),
                          ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: AppSpacing.md16),

              // Action buttons
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        setState(() => _showReplies = !_showReplies),
                    icon: Icon(
                      _showReplies
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 18,
                    ),
                    label: Text('Replies (${widget.comment.replies.length})'),
                  ),
                  const Spacer(),
                  if (widget.canInteract)
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _showReplyInput = !_showReplyInput),
                      icon: const Icon(Icons.reply_rounded, size: 18),
                      label: const Text('Reply'),
                    ),
                ],
              ),

              // Replies section
              if (_showReplies && widget.comment.replies.isNotEmpty) ...[
                SizedBox(height: AppSpacing.md16),
                Divider(color: AppColors.deepNavy.withValues(alpha: 0.1)),
                SizedBox(height: AppSpacing.md16),
                ...widget.comment.replies.map((reply) {
                  return _buildReplyItem(reply);
                }),
              ],

              // Reply input
              if (_showReplyInput && widget.canInteract) ...[
                SizedBox(height: AppSpacing.md16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: AppColors.constructionGold.withValues(alpha: 0.3),
                    ),
                  ),
                  padding: EdgeInsets.all(AppSpacing.md16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextField(
                        controller: _replyController,
                        decoration: InputDecoration(
                          hintText: 'Write a reply...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: AppColors.slateGrey),
                        ),
                        maxLines: 3,
                        minLines: 1,
                      ),
                      SizedBox(height: AppSpacing.md16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () =>
                                setState(() => _showReplyInput = false),
                            child: const Text('Cancel'),
                          ),
                          SizedBox(width: AppSpacing.sm12),
                          FilledButton.icon(
                            onPressed: _handleAddReply,
                            icon: const Icon(Icons.send_rounded, size: 18),
                            label: const Text('Reply'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.constructionGold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build reply item
  Widget _buildReplyItem(CommentReply reply) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md16),
      padding: EdgeInsets.all(AppSpacing.md16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.deepNavy.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reply header
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.constructionGold.withValues(
                  alpha: 0.15,
                ),
                child: Text(
                  reply.authorName.isNotEmpty ? reply.authorName[0] : '?',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.constructionGold,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reply.authorName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: AppTypography.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatTime(reply.createdAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.slateGrey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm12),
          // Reply text
          Text(
            reply.text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.deepNavy),
          ),
          // Reply reactions
          if (reply.reactions.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: reply.reactions.map((reaction) {
                  return Padding(
                    padding: EdgeInsets.only(right: AppSpacing.xs8),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: Text(
                        reaction.emoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build reaction emoji picker menu
  Widget _buildReactionMenu() {
    const emojis = ['👍', '❤️', '😂', '😮', '🎉', '🔥', '👏', '💯'];
    return PopupMenuButton<String>(
      onSelected: _toggleReaction,
      itemBuilder: (context) => emojis
          .map(
            (emoji) => PopupMenuItem<String>(
              value: emoji,
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          )
          .toList(),
      icon: Icon(
        Icons.add_reaction_rounded,
        size: 20,
        color: AppColors.constructionGold,
      ),
      tooltip: 'Add reaction',
    );
  }

  /// Format time difference
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }
}
