import 'package:flutter/material.dart';
import 'step_counter_service.dart';
import 'privacy_policy_dialog.dart';

class ProfileSettingsSheet extends StatefulWidget {
  final StepCounterService service;
  final VoidCallback onUpdate;

  const ProfileSettingsSheet({super.key, required this.service, required this.onUpdate});

  @override
  State<ProfileSettingsSheet> createState() => _ProfileSettingsSheetState();
}

class _ProfileSettingsSheetState extends State<ProfileSettingsSheet> {
  final TextEditingController _nameController = TextEditingController();
  double _dailyGoal = 10000;
  double _height = 175;
  double _weight = 70;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() async {
    final name = await widget.service.getUserName();
    final goal = await widget.service.getDailyGoal();
    final h = await widget.service.getUserHeight();
    final w = await widget.service.getUserWeight();
    
    if (mounted) {
      setState(() {
        _nameController.text = name;
        _dailyGoal = goal.toDouble();
        _height = h;
        _weight = w;
        _isLoading = false;
      });
    }
  }

  void _saveSettings() async {
    if (_nameController.text.isNotEmpty) {
      await widget.service.setUserName(_nameController.text);
    }
    await widget.service.setDailyGoal(_dailyGoal.toInt());
    await widget.service.setUserHeight(_height);
    await widget.service.setUserWeight(_weight);
    
    widget.onUpdate();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24, 
        right: 24, 
        top: 24, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 24
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('个人设置', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 24),
          if (_isLoading) 
            const Center(child: CircularProgressIndicator())
          else ...[
            // Nickname
            const Text('昵称', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '输入你的昵称',
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),

            // Daily Goal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('每日目标', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                Text('${_dailyGoal.toInt()} 步', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 6,
                activeTrackColor: Colors.blueAccent,
                inactiveTrackColor: Colors.blueAccent.withOpacity(0.2),
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 2),
                overlayColor: Colors.blueAccent.withOpacity(0.1),
              ),
              child: Slider(
                value: _dailyGoal,
                min: 1000,
                max: 30000,
                divisions: 29,
                onChanged: (v) => setState(() => _dailyGoal = v),
              ),
            ),
            const SizedBox(height: 16),

            // Height & Weight Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('身高 (cm)', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
                        child: Text('${_height.toInt()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      SliderTheme(
                         data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.green,
                          inactiveTrackColor: Colors.green.withOpacity(0.2),
                          thumbColor: Colors.white,
                         ),
                         child: Slider(
                          value: _height,
                          min: 100,
                          max: 250,
                          onChanged: (v) => setState(() => _height = v),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      const Text('体重 (kg)', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
                        child: Text('${_weight.toInt()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      SliderTheme(
                         data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.orange,
                          inactiveTrackColor: Colors.orange.withOpacity(0.2),
                          thumbColor: Colors.white,
                         ),
                        child: Slider(
                          value: _weight,
                          min: 30,
                          max: 150,
                          onChanged: (v) => setState(() => _weight = v),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Privacy Link
            Center(
              child: TextButton.icon(
                onPressed: () => PrivacyPolicyDialog.showInfoDialog(context),
                icon: const Icon(Icons.privacy_tip_outlined, size: 16, color: Colors.grey),
                label: const Text('隐私政策', style: TextStyle(color: Colors.grey)),
              ),
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Text('保存修改', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
