import 'package:flutter/material.dart';
import 'package:led_control/core/models/device.dart';

/// 设备列表项组件
class DeviceListItem extends StatelessWidget {
  const DeviceListItem({
    super.key,
    required this.device,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Device device;
  final VoidCallback? onTap;
  final void Function(Device)? onEdit;
  final void Function(Device)? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _buildLeading(context),
        title: Text(
          device.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(device.ipAddress),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusIndicator(context),
                const SizedBox(width: 4),
                Text(
                  device.statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: device.isOnline ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '最后在线: ${_formatLastSeen(device.lastSeen)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: _buildTrailing(context, device),
        onTap: onTap,
      ),
    );
  }

  /// 构建前置图标
  Widget _buildLeading(BuildContext context) {
    return CircleAvatar(
      backgroundColor: device.isOnline
          ? Theme.of(context).colorScheme.primaryContainer
          : Colors.grey.shade300,
      child: Icon(
        Icons.lightbulb_outline,
        color: device.isOnline
            ? Theme.of(context).colorScheme.primary
            : Colors.grey,
      ),
    );
  }

  /// 构建状态指示器
  Widget _buildStatusIndicator(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: device.isOnline ? Colors.green : Colors.grey,
      ),
    );
  }

  /// 构建 trailing 按钮
  Widget? _buildTrailing(BuildContext context, Device device) {
    if (onEdit == null && onDelete == null) {
      return null;
    }

    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call(device);
            break;
          case 'delete':
            onDelete?.call(device);
            break;
        }
      },
      itemBuilder: (context) => [
        if (onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 20),
                SizedBox(width: 12),
                Text('编辑'),
              ],
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 20, color: Colors.red),
                SizedBox(width: 12),
                Text('删除', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
      ],
    );
  }

  /// 格式化最后在线时间
  String _formatLastSeen(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} 分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} 小时前';
    } else {
      return '${difference.inDays} 天前';
    }
  }
}
