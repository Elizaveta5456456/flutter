import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../assets/app_icons.dart';
import '../services/profile_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_view.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ValueChanged<bool>? onEditingChanged;

  const ProfileScreen({super.key, this.onEditingChanged});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profile = ProfileService();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final ImagePicker _picker = ImagePicker();

  bool _loading = true;
  bool _editing = false;

  bool get isEditing => _editing;
  String? _avatarPath;
  Uint8List? _avatarBytes;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _loadProfile({bool showSpinner = true}) async {
    if (showSpinner) setState(() => _loading = true);
    final name = await _profile.getName();
    final avatar = await _profile.getAvatarPath();
    final bytes = await _profile.getAvatarBytes();
    if (!mounted) return;
    setState(() {
      _nameController.text = name;
      _avatarPath = avatar;
      _avatarBytes = bytes;
      _loading = false;
    });
  }

  void reload() => _loadProfile(showSpinner: false);

  Future<void> _enterEdit() async {
    setState(() => _editing = true);
    widget.onEditingChanged?.call(true);
  }

  Future<void> _exitEdit() async {
    await save();
  }

  
  Future<void> save() async {
    await _profile.setName(_nameController.text);
    if (!mounted) return;
    _nameFocus.unfocus();
    setState(() => _editing = false);
    widget.onEditingChanged?.call(false);
    await _loadProfile(showSpinner: false);
  }

  Future<void> _pickAvatar() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    await _profile.setAvatarBytes(bytes);
    final path = await _profile.getAvatarPath();
    if (!mounted) return;
    setState(() {
      _avatarBytes = bytes;
      _avatarPath = path;
    });
  }

  Future<void> _openFavorites() async {
    await Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (_) => const FavoritesScreen(tabIndex: 2),
      ),
    );
    if (!mounted) return;
    reload();
  }

  Future<void> _openCart() async {
    await Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (_) => const CartScreen(tabIndex: 2),
      ),
    );
    if (!mounted) return;
    reload();
  }

  void _editName() {
    if (!_editing) return;
    _nameFocus.requestFocus();
  }

  Future<void> _saveName() async {
    await _profile.setName(_nameController.text);
    if (!mounted) return;
    _nameFocus.unfocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ColoredBox(
        color: AppColors.bgPrimary,
        child: LoadingView(),
      );
    }

    final dimmed = _editing ? 0.4 : 1.0;

    return PopScope(
      canPop: !_editing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _editing) _exitEdit();
      },
      child: ColoredBox(
        color: AppColors.bgPrimary,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Opacity(
                opacity: dimmed,
                child: const Text(
                  'профиль',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppColors.textPrimary,
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    height: 48 / 40,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _Avatar(
                    avatarPath: _avatarPath,
                    avatarBytes: _avatarBytes,
                    showAdd: _editing,
                    onAdd: _pickAvatar,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: _editing
                                  ? GestureDetector(
                                      onTap: _editName,
                                      child: TextField(
                                        controller: _nameController,
                                        focusNode: _nameFocus,
                                        style: const TextStyle(
                                          fontFamily: AppTheme.fontFamily,
                                          color: AppColors.textPrimary,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          height: 24 / 20,
                                        ),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          border: InputBorder.none,
                                        ),
                                        textInputAction: TextInputAction.done,
                                        onSubmitted: (_) => _saveName(),
                                        onTapOutside: (_) => _saveName(),
                                      ),
                                    )
                                  : Text(
                                      _nameController.text,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        color: AppColors.textPrimary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        height: 24 / 20,
                                      ),
                                    ),
                            ),
                            if (_editing) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _editName,
                                child: SvgPicture.asset(
                                  AppIcons.penLine,
                                  width: 16,
                                  height: 16,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Opacity(
                          opacity: _editing ? 0.4 : 1,
                          child: const Text(
                            'более 100 покупок',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 22 / 16,
                              letterSpacing: -0.18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Opacity(
              opacity: dimmed,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MenuItem(
                      label: 'редактировать профиль',
                      onTap: _editing ? _exitEdit : _enterEdit,
                    ),
                    const SizedBox(height: 16),
                    _MenuItem(
                      label: 'избранное',
                      onTap: _editing ? null : _openFavorites,
                    ),
                    const SizedBox(height: 16),
                    _MenuItem(
                      label: 'корзина',
                      onTap: _editing ? null : _openCart,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _MenuItem({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 24 / 20,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? avatarPath;
  final Uint8List? avatarBytes;
  final bool showAdd;
  final VoidCallback? onAdd;

  const _Avatar({
    required this.avatarPath,
    required this.avatarBytes,
    required this.showAdd,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (avatarBytes != null) {
      image = Image.memory(
        avatarBytes!,
        fit: BoxFit.cover,
        width: 96,
        height: 96,
      );
    } else if (!kIsWeb && avatarPath != null) {
      image = Image.file(
        File(avatarPath!),
        fit: BoxFit.cover,
        width: 96,
        height: 96,
      );
    } else {
      image = Center(
        child: Image.asset(
          AppIcons.avatarDefault,
          width: 56,
          height: 47,
          fit: BoxFit.contain,
        ),
      );
    }

    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFBEF264),
                  Color(0xFFFDE047),
                ],
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: image,
          ),
          if (showAdd)
            Positioned(
              left: 72,
              top: 72,
              child: GestureDetector(
                onTap: onAdd,
                child: SvgPicture.asset(
                  AppIcons.avatarAdd,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
