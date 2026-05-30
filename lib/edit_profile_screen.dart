import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'theme.dart';

// ─── Categories list (same as backend) ───────────────────────────────────────
const List<String> _kAllCategories = [
  'Food & Drinks', 'Groceries', 'Health', 'Shopping', 'Entertainment',
  'Fuel', 'Commute', 'Travel', 'Personal Care', 'Bills & Utilities',
  'Rental', 'Household', 'Insurance', 'Education', 'Fitness',
  'Credit Bills', 'Self Transfers',
];

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {

  // ─── Tab controller ──────────────────────────────────────────────────────
  late TabController _tabController;

  // ─── Avatar ──────────────────────────────────────────────────────────────
  File? _pickedImage;
  String _currentAvatarUrl = '';
  bool _isSaving = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  // ─── Personal details controllers ────────────────────────────────────────
  final _firstNameCtrl  = TextEditingController();
  final _lastNameCtrl   = TextEditingController();
  final _birthdayCtrl   = TextEditingController();
  String? _gender;
  String? _ageGroup;
  String? _maritalStatus;

  // ─── Address controllers ──────────────────────────────────────────────────
  String? _addressSaveAs;
  final _addressLine1Ctrl  = TextEditingController();
  final _colonyCtrl        = TextEditingController();
  final _areaCtrl          = TextEditingController();
  final _cityCtrl          = TextEditingController();
  final _stateCtrl         = TextEditingController();
  final _countryCtrl       = TextEditingController();
  final _pincodeCtrl       = TextEditingController();

  // ─── Lifestyle controllers ────────────────────────────────────────────────
  final Set<String> _personalInterests    = {};
  final Set<String> _shoppingHabits       = {};
  final Set<String> _discountCategories   = {};
  String? _favoriteDealType;
  String? _monthlyShopping;
  String? _shoppingFrequency;

  // ─── Remote IDs ──────────────────────────────────────────────────────────
  String _frooflyId  = '';
  String _userId     = '';

  static const _primaryColor = Color(0xFF0A3D62);
  static const _goldColor    = Color(0xFFD4AF37);
  static const _bgColor      = Color(0xFFF9F9F9);
  static const _baseUrl      = 'https://backend-froofly.onrender.com';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _loadAll();
    _animController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animController.dispose();
    for (final c in [
      _firstNameCtrl, _lastNameCtrl, _birthdayCtrl,
      _addressLine1Ctrl, _colonyCtrl, _areaCtrl,
      _cityCtrl, _stateCtrl, _countryCtrl, _pincodeCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ─── Load ─────────────────────────────────────────────────────────────────

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    _frooflyId = prefs.getString('frooflyId') ?? '';
    _userId    = prefs.getString('userId') ?? '';
    setState(() {
      _currentAvatarUrl = prefs.getString('avatarUrl') ?? '';
    });

    if (_frooflyId.isEmpty) return;

    try {
      final resp = await http.get(
        Uri.parse('$_baseUrl/auth/profile-details/$_frooflyId'),
      ).timeout(const Duration(seconds: 15));

      if (resp.statusCode == 200) {
        final d = jsonDecode(resp.body) as Map<String, dynamic>;
        if (!mounted) return;
        setState(() {
          _firstNameCtrl.text  = d['firstName'] ?? '';
          _lastNameCtrl.text   = d['lastName']  ?? '';
          _birthdayCtrl.text   = d['birthday']  ?? '';
          _gender        = d['gender'];
          _ageGroup      = d['ageGroup'];
          _maritalStatus = d['maritalStatus'];

          _addressSaveAs = d['addressSaveAs'];
          _addressLine1Ctrl.text = d['addressLine1']  ?? '';
          _colonyCtrl.text       = d['colonyStreet']  ?? '';
          _areaCtrl.text         = d['areaSector']    ?? '';
          _cityCtrl.text         = d['city']          ?? '';
          _stateCtrl.text        = d['state']         ?? '';
          _countryCtrl.text      = d['country']       ?? '';
          _pincodeCtrl.text      = d['pincode']       ?? '';

          if (d['personalInterests'] is List) {
            _personalInterests.addAll(List<String>.from(d['personalInterests']));
          }
          if (d['shoppingHabits'] is List) {
            _shoppingHabits.addAll(List<String>.from(d['shoppingHabits']));
          }
          if (d['discountCategories'] is List) {
            _discountCategories.addAll(List<String>.from(d['discountCategories']));
          }
          _favoriteDealType   = d['favoriteDealType'];
          _monthlyShopping    = d['monthlyShopping'];
          _shoppingFrequency  = d['shoppingFrequency'];
        });
      }
    } catch (e) {
      debugPrint('Load profile details error: $e');
    }
  }

  // ─── Image picker ─────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 600);
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300], borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text('Change Profile Photo',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textDark)),
              const SizedBox(height: 16),
              _sheetOption(icon: Icons.camera_alt_rounded, label: 'Take a Photo',
                onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.camera); }),
              const SizedBox(height: 12),
              _sheetOption(icon: Icons.photo_library_rounded, label: 'Choose from Gallery',
                onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.gallery); }),
              if (_pickedImage != null || _currentAvatarUrl.isNotEmpty) ...[
                const SizedBox(height: 12),
                _sheetOption(icon: Icons.delete_rounded, label: 'Remove Photo', color: _goldColor,
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() { _pickedImage = null; _currentAvatarUrl = ''; });
                  }),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetOption({
    required IconData icon, required String label,
    required VoidCallback onTap, Color color = _primaryColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(label, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // ─── Save ─────────────────────────────────────────────────────────────────

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();

    try {
      // 1. Avatar upload
      if (_pickedImage != null && _userId.isNotEmpty) {
        final bytes = await _pickedImage!.readAsBytes();
        final dir = await getApplicationDocumentsDirectory();
        final localFile = File('${dir.path}/avatar_$_userId.png');
        await localFile.writeAsBytes(bytes);
        await prefs.setString('avatarUrl', localFile.path);
        final base64Image = base64Encode(bytes);
        await http.post(
          Uri.parse('$_baseUrl/avatar/$_userId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'base64': base64Image}),
        ).timeout(const Duration(seconds: 15));
      } else if (_currentAvatarUrl.isEmpty) {
        await prefs.setString('avatarUrl', '');
      }

      // Update local name if first/last changed
      final fullName = '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'.trim();
      if (fullName.isNotEmpty) {
        await prefs.setString('fullName', fullName);
      }

      // 2. Post profile details to backend
      if (_frooflyId.isNotEmpty) {
        final body = {
          'firstName':        _firstNameCtrl.text.trim(),
          'lastName':         _lastNameCtrl.text.trim(),
          'birthday':         _birthdayCtrl.text.trim(),
          'gender':           _gender,
          'ageGroup':         _ageGroup,
          'maritalStatus':    _maritalStatus,
          'addressSaveAs':    _addressSaveAs,
          'addressLine1':     _addressLine1Ctrl.text.trim(),
          'colonyStreet':     _colonyCtrl.text.trim(),
          'areaSector':       _areaCtrl.text.trim(),
          'city':             _cityCtrl.text.trim(),
          'state':            _stateCtrl.text.trim(),
          'country':          _countryCtrl.text.trim(),
          'pincode':          _pincodeCtrl.text.trim(),
          'personalInterests':   _personalInterests.toList(),
          'shoppingHabits':      _shoppingHabits.toList(),
          'discountCategories':  _discountCategories.toList(),
          'favoriteDealType':    _favoriteDealType,
          'monthlyShopping':     _monthlyShopping,
          'shoppingFrequency':   _shoppingFrequency,
        };
        await http.post(
          Uri.parse('$_baseUrl/auth/profile-details/$_frooflyId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 15));
      }
    } catch (e) {
      debugPrint('Save error: $e');
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Profile updated successfully! ✨',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      backgroundColor: _primaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
    Navigator.pop(context, true);
  }

  // ─── Avatar widget ────────────────────────────────────────────────────────

  String get _initials {
    final first = _firstNameCtrl.text.trim();
    final last  = _lastNameCtrl.text.trim();
    if (first.isEmpty && last.isEmpty) return '?';
    return '${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}'.toUpperCase();
  }

  Widget _buildAvatar() {
    Widget child;
    if (_pickedImage != null) {
      child = Image.file(_pickedImage!, fit: BoxFit.cover);
    } else if (_currentAvatarUrl.isNotEmpty) {
      if (_currentAvatarUrl.startsWith('/') || _currentAvatarUrl.startsWith('file:')) {
        child = Image.file(File(_currentAvatarUrl), fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initialsWidget());
      } else {
        child = Image.network(_currentAvatarUrl, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initialsWidget());
      }
    } else {
      child = _initialsWidget();
    }

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTap: _showImageSourceSheet,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _primaryColor, width: 3),
                boxShadow: [
                  BoxShadow(color: _primaryColor.withOpacity(0.25), blurRadius: 20, spreadRadius: 2),
                ],
              ),
              child: ClipOval(child: child),
            ),
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: _primaryColor, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initialsWidget() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A3D62), Color(0xFFD4AF37)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(_initials,
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26)),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Profile',
          style: GoogleFonts.poppins(color: AppTheme.textDark, fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveChanges,
            child: _isSaving
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _primaryColor))
              : Text('Save', style: GoogleFonts.poppins(
                  color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Avatar + name preview ───────────────────────────────────────
          Container(
            color: _bgColor,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                _buildAvatar(),
                const SizedBox(height: 8),
                Text('Tap photo to change',
                  style: GoogleFonts.poppins(color: AppTheme.textGrey, fontSize: 12)),
              ],
            ),
          ),

          // ── Tab bar ─────────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(14),
              ),
              indicatorPadding: const EdgeInsets.all(4),
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textGrey,
              labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11),
              unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 11),
              tabs: const [
                Tab(text: 'Personal'),
                Tab(text: 'Address'),
                Tab(text: 'Lifestyle'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Tab views ───────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPersonalTab(),
                _buildAddressTab(),
                _buildLifestyleTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Personal tab ─────────────────────────────────────────────────────────

  Widget _buildPersonalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionCard(children: [
            _fieldLabel('First Name *'),
            _textField(_firstNameCtrl, 'Enter first name', Icons.person_outline),
            const SizedBox(height: 16),
            _fieldLabel('Last Name *'),
            _textField(_lastNameCtrl, 'Enter last name', Icons.person_outline),
            const SizedBox(height: 16),
            _fieldLabel('Birthday *'),
            _dateField(),
            const SizedBox(height: 16),
            _fieldLabel('Gender *'),
            _chipSelector(
              options: ['Male', 'Female', 'Other'],
              selected: _gender,
              onSelect: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 16),
            _fieldLabel('Age Group *'),
            _chipSelector(
              options: ['18-35', '35-50', '50 Above'],
              selected: _ageGroup,
              onSelect: (v) => setState(() => _ageGroup = v),
            ),
            const SizedBox(height: 16),
            _fieldLabel('Marital Status *'),
            _chipSelector(
              options: ['Single', 'Married', 'Other'],
              selected: _maritalStatus,
              onSelect: (v) => setState(() => _maritalStatus = v),
            ),
          ]),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─── Address tab ──────────────────────────────────────────────────────────

  Widget _buildAddressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionCard(children: [
            _fieldLabel('Save As'),
            _chipSelector(
              options: ['Home', 'Work', 'Other'],
              selected: _addressSaveAs,
              onSelect: (v) => setState(() => _addressSaveAs = v),
            ),
            const SizedBox(height: 16),
            _fieldLabel('Address Line 1 (Flat No / House No / Building Name)'),
            _textField(_addressLine1Ctrl, 'Flat no, House no, Building name', Icons.home_outlined),
            const SizedBox(height: 16),
            _fieldLabel('Colony / Street'),
            _textField(_colonyCtrl, 'Colony or street name', Icons.map_outlined),
            const SizedBox(height: 16),
            _fieldLabel('Area / Sector'),
            _textField(_areaCtrl, 'Area or sector', Icons.location_city_outlined),
            const SizedBox(height: 16),
            _fieldLabel('City'),
            _textField(_cityCtrl, 'City', Icons.location_on_outlined),
            const SizedBox(height: 16),
            _fieldLabel('State'),
            _textField(_stateCtrl, 'State', Icons.flag_outlined),
            const SizedBox(height: 16),
            _fieldLabel('Country'),
            _textField(_countryCtrl, 'Country', Icons.public_outlined),
            const SizedBox(height: 16),
            _fieldLabel('Pin Code'),
            _textField(_pincodeCtrl, '6-digit pin code', Icons.pin_outlined, isNumber: true),
          ]),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─── Lifestyle tab ────────────────────────────────────────────────────────

  Widget _buildLifestyleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal Interests
          _sectionCard(children: [
            _fieldLabel('Personal Interests'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _kAllCategories.map((cat) {
                final selected = _personalInterests.contains(cat);
                return FilterChip(
                  label: Text(cat,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : _primaryColor,
                    )),
                  selected: selected,
                  selectedColor: _primaryColor,
                  backgroundColor: const Color(0xFFE6EBF0),
                  checkmarkColor: Colors.white,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onSelected: (v) => setState(() {
                    if (v) _personalInterests.add(cat);
                    else _personalInterests.remove(cat);
                  }),
                );
              }).toList(),
            ),
          ]),
          const SizedBox(height: 16),

          // Shopping habits
          _sectionCard(label: 'When shopping, I usually:', children: [
            _checkItem('Wait for a sale (Big Billion/Freedom Sale)', _shoppingHabits),
            _checkItem('Compare on multiple apps', _shoppingHabits),
            _checkItem('Buy only if I have a coupon', _shoppingHabits),
            _checkItem('Buy immediately if needed', _shoppingHabits),
          ]),
          const SizedBox(height: 16),

          // Discount categories
          _sectionCard(label: 'I look for discounts mostly on:', children: [
            _checkItem('Monthly groceries & essentials', _discountCategories),
            _checkItem('Clothes & fashion', _discountCategories),
            _checkItem('Gadgets & appliances', _discountCategories),
            _checkItem('Dining out & food delivery', _discountCategories),
          ]),
          const SizedBox(height: 16),

          // Favourite deal type
          _sectionCard(label: 'My absolute favorite deal is:', children: [
            _radioItem('Flat %', _favoriteDealType, (v) => setState(() => _favoriteDealType = v)),
            _radioItem('BOGO (Buy 1 Get 1)', _favoriteDealType, (v) => setState(() => _favoriteDealType = v)),
            _radioItem('Cashback', _favoriteDealType, (v) => setState(() => _favoriteDealType = v)),
            _radioItem('Free delivery', _favoriteDealType, (v) => setState(() => _favoriteDealType = v)),
          ]),
          const SizedBox(height: 16),

          // Monthly shopping budget
          _sectionCard(label: 'My monthly shopping budget is around:', children: [
            _radioItem('Under ₹2,000', _monthlyShopping, (v) => setState(() => _monthlyShopping = v)),
            _radioItem('₹2,000 – ₹5,000', _monthlyShopping, (v) => setState(() => _monthlyShopping = v)),
            _radioItem('₹5,000 – ₹15,000', _monthlyShopping, (v) => setState(() => _monthlyShopping = v)),
            _radioItem('Above ₹15,000', _monthlyShopping, (v) => setState(() => _monthlyShopping = v)),
          ]),
          const SizedBox(height: 16),

          // Shopping frequency
          _sectionCard(label: 'I shop online/offline:', children: [
            _radioItem('Daily', _shoppingFrequency, (v) => setState(() => _shoppingFrequency = v)),
            _radioItem('Weekly', _shoppingFrequency, (v) => setState(() => _shoppingFrequency = v)),
            _radioItem('Monthly', _shoppingFrequency, (v) => setState(() => _shoppingFrequency = v)),
            _radioItem('Occasionally', _shoppingFrequency, (v) => setState(() => _shoppingFrequency = v)),
          ]),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _sectionCard({String? label, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(label,
              style: GoogleFonts.poppins(
                color: AppTheme.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              )),
            const SizedBox(height: 12),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
        style: GoogleFonts.poppins(
          color: AppTheme.textGrey,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        )),
    );
  }

  Widget _textField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      textCapitalization: TextCapitalization.words,
      style: GoogleFonts.poppins(color: AppTheme.textDark, fontWeight: FontWeight.w600, fontSize: 14),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: _primaryColor, size: 18),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: AppTheme.textGrey.withOpacity(0.6), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _dateField() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime(1995),
          firstDate: DateTime(1940),
          lastDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
          builder: (ctx, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(primary: _primaryColor, onPrimary: Colors.white),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          setState(() {
            _birthdayCtrl.text =
                '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: _birthdayCtrl,
          style: GoogleFonts.poppins(color: AppTheme.textDark, fontWeight: FontWeight.w600, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.calendar_today_outlined, color: _primaryColor, size: 18),
            hintText: 'DD/MM/YYYY',
            hintStyle: GoogleFonts.poppins(color: AppTheme.textGrey.withOpacity(0.6), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }

  Widget _chipSelector({
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelect,
  }) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selected == opt;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? _primaryColor : const Color(0xFFE6EBF0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(opt,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : _primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              )),
          ),
        );
      }).toList(),
    );
  }

  Widget _checkItem(String label, Set<String> set) {
    final checked = set.contains(label);
    return InkWell(
      onTap: () => setState(() {
        if (checked) set.remove(label); else set.add(label);
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: checked ? _primaryColor : Colors.transparent,
                border: Border.all(color: checked ? _primaryColor : Colors.grey.shade400, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: checked
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                style: GoogleFonts.poppins(
                  color: checked ? AppTheme.textDark : AppTheme.textGrey,
                  fontSize: 13,
                  fontWeight: checked ? FontWeight.w600 : FontWeight.normal,
                )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _radioItem(String label, String? groupValue, ValueChanged<String?> onChanged) {
    return InkWell(
      onTap: () => onChanged(label),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: groupValue == label ? _primaryColor : Colors.transparent,
                border: Border.all(
                  color: groupValue == label ? _primaryColor : Colors.grey.shade400, width: 2),
              ),
              child: groupValue == label
                ? const Icon(Icons.circle, color: Colors.white, size: 10)
                : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                style: GoogleFonts.poppins(
                  color: groupValue == label ? AppTheme.textDark : AppTheme.textGrey,
                  fontSize: 13,
                  fontWeight: groupValue == label ? FontWeight.w600 : FontWeight.normal,
                )),
            ),
          ],
        ),
      ),
    );
  }
}

