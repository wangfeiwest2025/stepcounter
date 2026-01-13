import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyPolicyDialog extends StatefulWidget {
  final bool showOnFirstLaunch;

  const PrivacyPolicyDialog({Key? key, this.showOnFirstLaunch = false})
      : super(key: key);

  @override
  _PrivacyPolicyDialogState createState() => _PrivacyPolicyDialogState();

  static Future<bool> showFirstLaunchDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final bool accepted = prefs.getBool('privacy_accepted') ?? false;
    if (accepted) {
      return true;
    }
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PrivacyPolicyDialog(showOnFirstLaunch: true),
    );
    return result ?? false;
  }

  static Future<void> showInfoDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => PrivacyPolicyDialog(showOnFirstLaunch: false),
    );
  }
}

class _PrivacyPolicyDialogState extends State<PrivacyPolicyDialog> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.privacy_tip, color: Colors.blue),
          SizedBox(width: 8),
          Text('隐私政策', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '欢迎使用 StepCounter 计步器应用。为保障您的权益，请仔细阅读以下隐私政策：',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 12),
            Text(
              '1. 数据收集',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '我们仅收集步数传感器数据用于统计和展示，不会上传个人身份信息。',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 8),
            Text(
              '2. 数据存储',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '步数数据仅存储在您的设备本地，不会传输到外部服务器。',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 8),
            Text(
              '3. 权限说明',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '应用需要传感器权限以读取步数，需要后台运行权限以持续计步。',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 16),
            Text(
              '继续使用本应用表示您同意以上隐私政策。',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            if (widget.showOnFirstLaunch) ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _accepted,
                    onChanged: (value) {
                      setState(() {
                        _accepted = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      '我已阅读并同意隐私政策',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (widget.showOnFirstLaunch)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('拒绝并退出'),
          ),
        TextButton(
          onPressed: widget.showOnFirstLaunch && !_accepted
              ? null
              : () async {
                  if (widget.showOnFirstLaunch) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('privacy_accepted', true);
                  }
                  Navigator.of(context).pop(true);
                },
          child: Text(widget.showOnFirstLaunch ? '同意并继续' : '关闭'),
        ),
      ],
    );
  }

}