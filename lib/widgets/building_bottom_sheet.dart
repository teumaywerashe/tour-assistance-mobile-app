import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/constants.dart';
import '../data/models/building.dart';
import '../data/repositories/building_repository.dart';

class BuildingBottomSheet extends StatefulWidget {
  final Building? building; // null = create, non-null = edit
  final VoidCallback onSaved;

  const BuildingBottomSheet({super.key, this.building, required this.onSaved});

  @override
  State<BuildingBottomSheet> createState() => _BuildingBottomSheetState();
}

class _BuildingBottomSheetState extends State<BuildingBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _repo = BuildingRepository();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _hoursCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _tagsCtrl;
  late final TextEditingController _floorsCtrl;
  late final TextEditingController _roomsCtrl;
  late final TextEditingController _deptsCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late final TextEditingController _nearestNodeCtrl;

  String _category = 'Academic';
  File? _imageFile;
  bool _loading = false;
  bool _showMapPicker = false;
  LatLng? _pickedLatLng;

  @override
  void initState() {
    super.initState();
    final b = widget.building;
    _nameCtrl = TextEditingController(text: b?.name ?? '');
    _descCtrl = TextEditingController(text: b?.description ?? '');
    _hoursCtrl = TextEditingController(text: b?.hours ?? '');
    _locationCtrl = TextEditingController(text: b?.location ?? '');
    _tagsCtrl = TextEditingController(text: b?.tags.join(', ') ?? '');
    _floorsCtrl = TextEditingController(text: b?.floorinfo.floors.toString() ?? '1');
    _roomsCtrl = TextEditingController(text: b?.floorinfo.rooms.toString() ?? '0');
    _deptsCtrl = TextEditingController(text: b?.floorinfo.depts?.join(', ') ?? '');
    _latCtrl = TextEditingController(text: b?.lat.toString() ?? '');
    _lngCtrl = TextEditingController(text: b?.lng.toString() ?? '');
    _nearestNodeCtrl = TextEditingController(
      text: b != null ? b.nearestNodes.join(', ') : '',
    );
    _category = b?.category ?? 'Academic';
    if (b != null) _pickedLatLng = LatLng(b.lat, b.lng);
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _descCtrl, _hoursCtrl, _locationCtrl, _tagsCtrl,
        _floorsCtrl, _roomsCtrl, _deptsCtrl, _latCtrl, _lngCtrl, _nearestNodeCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null && mounted) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    setState(() => _loading = true);

    try {
      final tags = _tagsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final depts = _deptsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final nodes = _nearestNodeCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      final formData = FormData.fromMap({
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'category': _category,
        'hours': _hoursCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'lat': double.tryParse(_latCtrl.text) ?? 0.0,
        'lng': double.tryParse(_lngCtrl.text) ?? 0.0,
        'tags': tags,
        'nearestNode': nodes.length == 1 ? nodes.first : nodes,
        'floorinfo': {
          'floors': int.tryParse(_floorsCtrl.text) ?? 1,
          'rooms': int.tryParse(_roomsCtrl.text) ?? 0,
          if (depts.isNotEmpty) 'depts': depts,
        },
        if (_imageFile != null)
          'images': await MultipartFile.fromFile(_imageFile!.path, filename: _imageFile!.path.split('/').last),
      });

      if (widget.building == null) {
        await _repo.createBuilding(formData);
      } else {
        await _repo.updateBuilding(widget.building!.id.toString(), formData);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      widget.building == null ? 'Add Building' : 'Edit Building',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    if (_loading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  ],
                ),
              ),
              const Divider(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _field(_nameCtrl, 'Name *', validator: (v) => v!.isEmpty ? 'Required' : null),
                        _field(_descCtrl, 'Description', maxLines: 3),
                        _field(_hoursCtrl, 'Hours (e.g. Mon-Fri 8am-5pm)'),
                        _field(_locationCtrl, 'Location'),
                        _field(_tagsCtrl, 'Tags (comma-separated)'),

                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _category,
                          decoration: const InputDecoration(labelText: 'Category'),
                          items: ['Academic', 'Libraries', 'Sports', 'Outdoor', 'Parking']
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setState(() => _category = v!),
                        ),
                        const SizedBox(height: 16),

                        Row(children: [
                          Expanded(child: _field(_floorsCtrl, 'Floors', keyboardType: TextInputType.number)),
                          const SizedBox(width: 12),
                          Expanded(child: _field(_roomsCtrl, 'Rooms', keyboardType: TextInputType.number)),
                        ]),
                        _field(_deptsCtrl, 'Departments (comma-separated)'),
                        _field(_nearestNodeCtrl, 'Nearest Node(s) (e.g. N5, N6)'),

                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(child: _field(_latCtrl, 'Latitude', keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true))),
                          const SizedBox(width: 12),
                          Expanded(child: _field(_lngCtrl, 'Longitude', keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true))),
                        ]),

                        // Map picker toggle
                        TextButton.icon(
                          icon: Icon(_showMapPicker ? Icons.map : Icons.map_outlined),
                          label: Text(_showMapPicker ? 'Hide map picker' : 'Pick on map'),
                          onPressed: () => setState(() => _showMapPicker = !_showMapPicker),
                        ),
                        if (_showMapPicker)
                          SizedBox(
                            height: 200,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: _pickedLatLng ?? const LatLng(9.0409, 38.7621),
                                  initialZoom: 17,
                                  onTap: (_, latlng) {
                                    setState(() {
                                      _pickedLatLng = latlng;
                                      _latCtrl.text = latlng.latitude.toStringAsFixed(6);
                                      _lngCtrl.text = latlng.longitude.toStringAsFixed(6);
                                    });
                                  },
                                ),
                                children: [
                                  TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                                  if (_pickedLatLng != null)
                                    MarkerLayer(markers: [
                                      Marker(
                                        point: _pickedLatLng!,
                                        child: const Icon(Icons.location_pin, color: AppConstants.accent, size: 32),
                                      ),
                                    ]),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),
                        // Image picker
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.withOpacity(0.3)),
                            ),
                            child: _imageFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined, color: Colors.grey.shade400, size: 36),
                                      const SizedBox(height: 8),
                                      Text('Tap to add image', style: TextStyle(color: Colors.grey.shade400)),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _save,
                            child: Text(widget.building == null ? 'Create Building' : 'Update Building'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
        validator: validator,
      ),
    );
  }
}
