import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pm_ajay/features/collaboration_hub/models/server_model.dart';

class MediaView extends ConsumerStatefulWidget {
  final ChannelModel channel;

  const MediaView({
    super.key,
    required this.channel,
  });

  @override
  ConsumerState<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends ConsumerState<MediaView> {
  final List<MediaItem> _mediaItems = [];

  @override
  void initState() {
    super.initState();
    _initializeDemoMedia();
  }

  void _initializeDemoMedia() {
    // Demo media items
    _mediaItems.addAll([
      MediaItem(
        id: 'media-1',
        channelId: widget.channel.id,
        fileName: 'Project_Overview.pdf',
        fileType: MediaType.document,
        uploadedBy: 'Admin User',
        uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
        fileSize: '2.4 MB',
      ),
      MediaItem(
        id: 'media-2',
        channelId: widget.channel.id,
        fileName: 'Site_Photos_Q4.zip',
        fileType: MediaType.archive,
        uploadedBy: 'Project Manager',
        uploadedAt: DateTime.now().subtract(const Duration(days: 3)),
        fileSize: '15.7 MB',
      ),
      MediaItem(
        id: 'media-3',
        channelId: widget.channel.id,
        fileName: 'Budget_Allocation.xlsx',
        fileType: MediaType.spreadsheet,
        uploadedBy: 'Finance Team',
        uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
        fileSize: '1.8 MB',
      ),
      MediaItem(
        id: 'media-4',
        channelId: widget.channel.id,
        fileName: 'Construction_Progress.jpg',
        fileType: MediaType.image,
        uploadedBy: 'Site Engineer',
        uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
        fileSize: '3.2 MB',
      ),
    ]);
  }

  void _uploadMedia() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File upload functionality coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _downloadMedia(MediaItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${item.fileName}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deleteMedia(MediaItem item) {
    setState(() {
      _mediaItems.removeWhere((m) => m.id == item.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.fileName} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _mediaItems.add(item);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Channel header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF36393F) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.photo_library, size: 24),
              const SizedBox(width: 8),
              Text(
                widget.channel.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              if (widget.channel.description != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.channel.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _uploadMedia,
                icon: const Icon(Icons.upload_file, size: 20),
                label: const Text('Upload'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Media statistics
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.insert_drive_file,
                  label: 'Total Files',
                  value: _mediaItems.length.toString(),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.storage,
                  label: 'Total Size',
                  value: _calculateTotalSize(),
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.image,
                  label: 'Images',
                  value: _mediaItems
                      .where((m) => m.fileType == MediaType.image)
                      .length
                      .toString(),
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),

        // Media grid/list
        Expanded(
          child: _mediaItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No media yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload your first file to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _mediaItems.length,
                  itemBuilder: (context, index) {
                    final item = _mediaItems[index];
                    return _buildMediaCard(item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaCard(MediaItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _downloadMedia(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File type icon/preview
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _getMediaTypeColor(item.fileType).withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getMediaTypeIcon(item.fileType),
                    size: 48,
                    color: _getMediaTypeColor(item.fileType),
                  ),
                ),
              ),
            ),
            // File info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.fileName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.fileSize,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.uploadedBy,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(item.uploadedAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 16),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'download',
                            child: Row(
                              children: [
                                Icon(Icons.download, size: 18),
                                SizedBox(width: 8),
                                Text('Download'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'download') {
                            _downloadMedia(item);
                          } else if (value == 'delete') {
                            _deleteMedia(item);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMediaTypeIcon(MediaType type) {
    switch (type) {
      case MediaType.image:
        return Icons.image;
      case MediaType.document:
        return Icons.description;
      case MediaType.spreadsheet:
        return Icons.table_chart;
      case MediaType.archive:
        return Icons.folder_zip;
      case MediaType.video:
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getMediaTypeColor(MediaType type) {
    switch (type) {
      case MediaType.image:
        return Colors.green;
      case MediaType.document:
        return Colors.blue;
      case MediaType.spreadsheet:
        return Colors.purple;
      case MediaType.archive:
        return Colors.orange;
      case MediaType.video:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _calculateTotalSize() {
    // Simple demo calculation
    double totalMB = 0;
    for (var item in _mediaItems) {
      final sizeStr = item.fileSize.replaceAll(' MB', '');
      totalMB += double.tryParse(sizeStr) ?? 0;
    }
    return '${totalMB.toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class MediaItem {
  final String id;
  final String channelId;
  final String fileName;
  final MediaType fileType;
  final String uploadedBy;
  final DateTime uploadedAt;
  final String fileSize;

  MediaItem({
    required this.id,
    required this.channelId,
    required this.fileName,
    required this.fileType,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.fileSize,
  });
}

enum MediaType {
  image,
  document,
  spreadsheet,
  archive,
  video,
  other,
}