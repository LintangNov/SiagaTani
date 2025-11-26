import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/dashboard_controller.dart';
import '../services/firestore_service.dart';
import '../models/farm_model.dart';
import 'farm_detail_screen.dart'; // Penting: Ini fix error "isn't a class"

class MyFarmScreen extends StatelessWidget {
  const MyFarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan DashboardController sudah di-put di MainScreen atau Bindings
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
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.grass_rounded, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text(
                    "Belum ada lahan tersimpan.",
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

  // --- WIDGET CARD ALA "MOON CHICKEN" TAPI VERSI TANI ---
  Widget _buildFarmCard(BuildContext context, FarmModel farm, FirestoreService service) {
    return GestureDetector(
      onTap: () => Get.to(() => const FarmDetailScreen(), arguments: farm),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. BAGIAN ATAS: MAP PREVIEW
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: Stack(
                  children: [
                    // Peta non-interaktif sebagai gambar header
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(farm.latitude, farm.longitude),
                        initialZoom: 15.5,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none, // Map diam seperti gambar
                        ),
                      ),
                      children: [
                        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
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
                    // Tombol Option (Titik Tiga) di pojok
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.more_horiz, size: 20, color: Colors.black87),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                          onPressed: () => _showOptionsDialog(context, farm, service),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. BAGIAN BAWAH: INFO LAHAN
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Lahan
                  Text(
                    farm.farmName,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3312),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Baris Info (Variety & Phase)
                  Row(
                    children: [
                      _buildTag(Icons.eco, farm.variety, Colors.green),
                      const SizedBox(width: 8),
                      _buildTag(Icons.timeline, farm.currentPhase, Colors.orange),
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

  Widget _buildTag(IconData icon, String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.shade700),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.shade800,
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIKA OPSI: EDIT & DELETE ---
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                child: Icon(Icons.edit, color: Colors.blue.shade700),
              ),
              title: Text("Ubah Nama Lahan", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              onTap: () {
                Get.back();
                _showEditDialog(context, farm, service);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: Icon(Icons.delete_forever, color: Colors.red.shade700),
              ),
              title: Text("Hapus Lahan", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.red)),
              subtitle: Text("Data akan hilang permanen", style: GoogleFonts.poppins(fontSize: 12)),
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

  void _showEditDialog(BuildContext context, FarmModel farm, FirestoreService service) {
    final TextEditingController nameCtrl = TextEditingController(text: farm.farmName);
    Get.defaultDialog(
      title: "Ubah Nama",
      titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Nama Lahan Baru",
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          if (nameCtrl.text.isNotEmpty && farm.id != null) {
            await service.updateFarmName(farm.id!, nameCtrl.text);
            Get.back();
            Get.snackbar("Sukses", "Nama lahan berhasil diubah", backgroundColor: Colors.green, colorText: Colors.white);
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
      middleText: "Apakah Anda yakin ingin menghapus '${farm.farmName}'? Data tidak dapat dikembalikan.",
      middleTextStyle: GoogleFonts.poppins(fontSize: 14),
      confirm: ElevatedButton(
        onPressed: () async {
          if (farm.id != null) {
            await service.deleteFarm(farm.id!);
            Get.back();
            Get.snackbar("Terhapus", "Lahan telah dihapus", backgroundColor: Colors.red, colorText: Colors.white);
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Text("Hapus", style: TextStyle(color: Colors.white)),
      ),
      cancel: OutlinedButton(onPressed: () => Get.back(), child: const Text("Batal")),
      contentPadding: const EdgeInsets.all(20),
    );
  }
}