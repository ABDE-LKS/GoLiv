import 'package:flutter/material.dart';
import 'package:wassali/core/theme/color_tokens.dart';
import '../../../core/theme/text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  String _language = 'العربية';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('عام'),
          _buildLanguageTile(),
          _buildToggleTile(Icons.dark_mode_outlined, 'الوضع الداكن', _darkMode, (v) => setState(() => _darkMode = v)),
          _buildToggleTile(Icons.notifications_none_outlined, 'الإشعارات', _notifications, (v) => setState(() => _notifications = v)),
          
          const SizedBox(height: 32),
          _buildSectionHeader('الأمان'),
          _buildMenuTile(Icons.phone_android_outlined, 'تغيير رقم الهاتف', onTap: () => _showChangePhone(context)),
          _buildMenuTile(Icons.lock_outline, 'تغيير كلمة المرور', onTap: () => _showChangePassword(context)),
          
          const SizedBox(height: 32),
          _buildSectionHeader('المنطقة الخطرة'),
          _buildMenuTile(Icons.delete_outline, 'حذف الحساب', isDanger: true, onTap: () => _showDeleteAccount(context)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(title, style: AppTextStyles.h3.copyWith(color: ColorTokens.textSecondary, fontSize: 14)),
    );
  }

  Widget _buildLanguageTile() {
    return ListTile(
      leading: const Icon(Icons.language_outlined, color: ColorTokens.textPrimary),
      title: const Text('اللغة'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: ColorTokens.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Text(_language, style: AppTextStyles.labelSmall.copyWith(color: ColorTokens.secondary, fontWeight: FontWeight.bold)),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('اختر اللغة'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLangOption('العربية'),
                _buildLangOption('Français'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLangOption(String lang) {
    return ListTile(
      title: Text(lang),
      trailing: _language == lang ? const Icon(Icons.check, color: ColorTokens.accent) : null,
      onTap: () {
        setState(() => _language = lang);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildToggleTile(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: Icon(icon, color: ColorTokens.textPrimary),
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: ColorTokens.accent,
    );
  }

  void _showChangePhone(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير رقم الهاتف', textAlign: TextAlign.right),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'رقم الهاتف الجديد',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال رمز التأكيد إلى الرقم الجديد')));
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير كلمة المرور', textAlign: TextAlign.right),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'كلمة المرور الحالية', border: OutlineInputBorder()),
              obscureText: true,
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(labelText: 'كلمة المرور الجديدة', border: OutlineInputBorder()),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')));
            },
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الحساب', style: TextStyle(color: Colors.red), textAlign: TextAlign.right),
        content: const Text('هل أنت متأكد من رغبتك في حذف حسابك نهائياً؟', textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب حذف الحساب')));
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, {bool isDanger = false, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: isDanger ? ColorTokens.error : ColorTokens.textPrimary),
      title: Text(title, style: TextStyle(color: isDanger ? ColorTokens.error : ColorTokens.textPrimary)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: ColorTokens.textMuted),
      onTap: onTap,
    );
  }
}


