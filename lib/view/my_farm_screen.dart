import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/dashboard_controller.dart';
import '../services/firestore_service.dart';
import '../models/farm_model.dart';
import 'farm_detail_screen.dart';

class MyFarmScreen extends StatelessWidget {
  const MyFarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.put(DashboardController());
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Lahan Saya",
          style: GoogleFonts.poppins(
            color: const Color(0xFF2C3312),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<FarmModel>>(
        stream: controller.farmListStream, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2C3312)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Gagal memuat data.", style: GoogleFonts.poppins()),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.spa_outlined, size: 60, color: Colors.green.shade300),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Belum ada lahan.",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2C3312),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Tambah lahan pertamamu di menu Beranda.",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final farms = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: farms.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final farm = farms[index];
              return _buildFarmCard(context, farm, firestoreService);
            },
          );
        },
      ),
    );
  }

  Widget _buildFarmCard(BuildContext context, FarmModel farm, FirestoreService service) {
    return GestureDetector(
      onTap: () => Get.to(() => const FarmDetailScreen(), arguments: farm),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(farm.latitude, farm.longitude),
                        initialZoom: 15.0,
                        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.siaga_tani',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(farm.latitude, farm.longitude),
                              child: const Icon(Icons.location_on, color: Colors.red, size: 35),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [Colors.black.withOpacity(0.2), Colors.transparent],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _showOptionsDialog(context, farm, service),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.more_horiz, size: 20, color: Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          farm.farmName,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3312),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        farm.landSize,
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: Colors.black12),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(Icons.grass, farm.variety, Colors.green),
                      const SizedBox(width: 8),
                      _buildInfoChip(Icons.timeline, farm.currentPhase, Colors.orange),
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

  Widget _buildInfoChip(IconData icon, String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: color.shade800),
          ),
        ],
      ),
    );
  }

  void _showOptionsDialog(BuildContext context, FarmModel farm, FirestoreService service) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                child: Icon(Icons.update, color: Colors.orange.shade700, size: 20),
              ),
              title: Text("Update Fase Tanam", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text("Ubah fase (misal: Berbunga -> Berbuah)", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              onTap: () {
                Get.back();
                _showUpdatePhaseDialog(context, farm, service);
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                child: Icon(Icons.edit, color: Colors.blue.shade700, size: 20),
              ),
              title: Text("Ubah Nama Lahan", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              onTap: () {
                Get.back();
                _showEditDialog(context, farm, service);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: Icon(Icons.delete_outline, color: Colors.red.shade700, size: 20),
              ),
              title: Text("Hapus Lahan", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.red)),
              onTap: () {
                Get.back();
                _showDeleteConfirmation(context, farm, service);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdatePhaseDialog(BuildContext context, FarmModel farm, FirestoreService service) {
    final phases = [
      {"label": "Bibit", "enum": "CropStage.seedling"},
      {"label": "Vegetatif", "enum": "CropStage.vegetative"},
      {"label": "Berbunga", "enum": "CropStage.flowering"},
      {"label": "Berbuah", "enum": "CropStage.fruiting"},
      {"label": "Panen", "enum": "CropStage.harvesting"},
    ];

    Get.defaultDialog(
      title: "Pilih Fase Baru",
      titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: phases.map((phase) {
              bool isSelected = farm.currentPhase == phase['label'];
              return Column(
                children: [
                  const Divider(height: 1),
                  ListTile(
                    title: Text(phase['label']!, style: GoogleFonts.poppins()),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                    onTap: () async {
                      if (farm.id != null) {
                        await service.updateFarmPhase(
                          farm.id!, 
                          phase['label']!, 
                          phase['enum']!
                        );
                        Get.back();
                        Get.snackbar("Sukses", "Fase tanaman diperbarui!", backgroundColor: Colors.green, colorText: Colors.white);
                      }
                    },
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, FarmModel farm, FirestoreService service) {
    final TextEditingController nameCtrl = TextEditingController(text: farm.farmName);
    Get.defaultDialog(
      title: "Ubah Nama",
      titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      content: Padding(
        padding: const EdgeInsets.all(15),
        child: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Nama Lahan Baru",
            isDense: true,
          ),
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          if (nameCtrl.text.isNotEmpty && farm.id != null) {
            await service.updateFarmName(farm.id!, nameCtrl.text);
            Get.back();
            Get.snackbar("Sukses", "Nama lahan diperbarui", backgroundColor: Colors.green, colorText: Colors.white);
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C3312)),
        child: const Text("Simpan", style: TextStyle(color: Colors.white)),
      ),
      cancel: TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
    );
  }

  void _showDeleteConfirmation(BuildContext context, FarmModel farm, FirestoreService service) {
    Get.defaultDialog(
      title: "Hapus Lahan?",
      titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red),
      middleText: "Anda yakin ingin menghapus '${farm.farmName}'? Data ini tidak bisa dikembalikan.",
      middleTextStyle: GoogleFonts.poppins(),
      confirm: ElevatedButton(
        onPressed: () async {
          if (farm.id != null) {
            await service.deleteFarm(farm.id!);
            Get.back();
            Get.snackbar("Terhapus", "Lahan berhasil dihapus", backgroundColor: Colors.red, colorText: Colors.white);
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Text("Hapus", style: TextStyle(color: Colors.white)),
      ),
      cancel: OutlinedButton(onPressed: () => Get.back(), child: const Text("Batal")),
    );
  }
}