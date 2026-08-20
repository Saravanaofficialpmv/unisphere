import 'package:flutter/material.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/widgets/common/custom_loader.dart';

class LoaderPreviewScreen extends StatefulWidget {
  const LoaderPreviewScreen({super.key});

  @override
  State<LoaderPreviewScreen> createState() => _LoaderPreviewScreenState();
}

class _LoaderPreviewScreenState extends State<LoaderPreviewScreen> {
  double _size = 72.0;
  String _label = 'Fetching latest campus records...';
  String _subtitle = 'Synchronizing with university database';
  bool _isDarkBackground = false;
  bool _showCard = true;
  double _simulatedUploadProgress = 0.45;

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkBackground ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBgColor = _isDarkBackground ? const Color(0xFF1E293B) : Colors.white;
    final textColor = _isDarkBackground ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Unisphere Loading System', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: cardBgColor,
        foregroundColor: textColor,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview Canvas (Pattern 1 & 4: Main Animated Branded Loader)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: _isDarkBackground
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Center(
                child: Loader(
                  size: _size,
                  label: _label.isNotEmpty ? _label : null,
                  subtitle: _subtitle.isNotEmpty ? _subtitle : null,
                  showCard: _showCard,
                  backgroundColor: _showCard
                      ? (_isDarkBackground ? const Color(0xFF1E293B) : Colors.white)
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Pattern 5: File & Media Upload Progress Card
            Text(
              'File & Media Upload Progress (Pattern 5)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            AppUploadProgressCard(
              progress: _simulatedUploadProgress,
              status: 'Uploading Academic Schedule...',
              subStatus: 'Processing PDF & generating index (45%)',
              fileName: 'VSBEC_Semester6_Schedule_2026.pdf',
              onCancel: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Upload cancelled')),
                );
              },
            ),

            const SizedBox(height: 24),

            // Pattern 8: Shimmer Skeleton List
            Text(
              'Shimmer Skeleton Loading (Pattern 8)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isDarkBackground
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: AppSkeletonLoader.list(
                itemCount: 2,
                itemHeight: 56,
                padding: const EdgeInsets.all(12),
              ),
            ),

            const SizedBox(height: 24),

            // Controls Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isDarkBackground
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Interactive Controls',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Size Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Loader Size: ${_size.toInt()} px', style: TextStyle(fontSize: 13, color: textColor)),
                      Text('Range: 32 - 140', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                  Slider(
                    value: _size,
                    min: 32,
                    max: 140,
                    divisions: 18,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _size = val),
                  ),

                  // Upload Progress Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Simulated Upload: ${(_simulatedUploadProgress * 100).toInt()}%', style: TextStyle(fontSize: 13, color: textColor)),
                    ],
                  ),
                  Slider(
                    value: _simulatedUploadProgress,
                    min: 0.0,
                    max: 1.0,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _simulatedUploadProgress = val),
                  ),

                  const SizedBox(height: 8),

                  // Dark Background Switch
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Dark Mode Background', style: TextStyle(fontSize: 13, color: textColor)),
                    value: _isDarkBackground,
                    onChanged: (val) => setState(() => _isDarkBackground = val),
                  ),

                  // Show Card Switch
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Elevated Card Container', style: TextStyle(fontSize: 13, color: textColor)),
                    value: _showCard,
                    onChanged: (val) => setState(() => _showCard = val),
                  ),

                  const SizedBox(height: 12),

                  // Label Input
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Primary Status Label',
                      hintText: 'Enter loader message...',
                      filled: true,
                      fillColor: _isDarkBackground ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    style: TextStyle(color: textColor, fontSize: 13),
                    controller: TextEditingController(text: _label)..selection = TextSelection.collapsed(offset: _label.length),
                    onChanged: (val) => _label = val,
                  ),

                  const SizedBox(height: 10),

                  // Subtitle Input
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Secondary Subtitle',
                      hintText: 'Enter detail subtitle...',
                      filled: true,
                      fillColor: _isDarkBackground ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    style: TextStyle(color: textColor, fontSize: 13),
                    controller: TextEditingController(text: _subtitle)..selection = TextSelection.collapsed(offset: _subtitle.length),
                    onChanged: (val) => _subtitle = val,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Demo Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.fullscreen_rounded, size: 18),
                    label: const Text('Fullscreen Test', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => Loader.fullscreen(
                            label: 'Loading UNISPHERE...',
                            subtitle: 'Verifying permissions and preparing your portal',
                            backgroundColor: _isDarkBackground ? const Color(0xFF0F172A) : Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    icon: const Icon(Icons.picture_in_picture_rounded, size: 18, color: AppColors.primary),
                    label: const Text('Dialog Modal Test', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    onPressed: () {
                      AppLoadingOverlay.show(
                        context,
                        message: 'Authenticating Credentials...',
                        subtitle: 'Establishing secure session with server',
                      );
                      Future.delayed(const Duration(seconds: 2), () {
                        AppLoadingOverlay.hide();
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
