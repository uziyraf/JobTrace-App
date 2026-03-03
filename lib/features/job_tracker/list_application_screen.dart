import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobtracker/data/models/daos/application_dao.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:jobtracker/features/job_tracker/detail_application_screen.dart';

import 'package:jobtracker/features/job_tracker/add_application_screen.dart';
import '../../data/models/application_model.dart';

class ListApplicationScreen extends StatefulWidget {
  const ListApplicationScreen({super.key});

  @override
  State<ListApplicationScreen> createState() => _ListApplicationScreenState();
}

class _ListApplicationScreenState extends State<ListApplicationScreen> {
  String selectedFilter = 'All';

  // 2. UBAH VARIABEL UNTUK MENAMPUNG DATA ASLI
  List<ApplicationModel> applications = [];
  bool isLoading = true; // Indikator loading saat mengambil data

  @override
  void initState() {
    super.initState();
    _refreshApplications(); // Panggil data saat halaman pertama kali dibuka
  }

  // 3. FUNGSI UNTUK MENGAMBIL DATA DARI DATABASE
  Future<void> _refreshApplications() async {
    setState(() => isLoading = true);
    final data = await ApplicationDao().getAllApplications();
    setState(() {
      applications = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterBar(),
            Expanded(
              // 4. CEK APAKAH SEDANG LOADING ATAU KOSONG
              child: isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF13EC80)))
                  : applications.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: applications.length,
                          itemBuilder: (context, index) {
                            final item = applications[index];

                            // Logic filter
                            if (selectedFilter != 'All' &&
                                item.status != selectedFilter) {
                              return const SizedBox.shrink();
                            }
                            return _buildJobCard(item);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 5. TUNGGU HASIL KEMBALIAN DARI ADD SCREEN (Jika true, refresh data)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddApplicationScreen()),
          );

          if (result == true) {
            _refreshApplications();
          }
        },
        backgroundColor: const Color(0xFF13EC80),
        child: const Icon(LucideIcons.plus, color: Color(0xFF0F172A)),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Applications',
            style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A)),
          ),
          const Icon(LucideIcons.search, color: Color(0xFF0F172A)),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Applied', 'Interview', 'Offer', 'Rejected'];
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: filters.map((f) => _filterItem(f)).toList(),
      ),
    );
  }

  Widget _filterItem(String title) {
    bool isSelected = selectedFilter == title;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = title),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF13EC80) : Colors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFF13EC80)
                  : const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  // 6. TAMPILAN JIKA BELUM ADA DATA
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.folderOpen,
              size: 64, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          Text("No applications yet.",
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B))),
          const SizedBox(height: 8),
          Text("Click the + button to add your first job application!",
              style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildJobCard(ApplicationModel job) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailApplicationScreen(job: job),
          ),
        );

        if (result == true) {
          _refreshApplications();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      job.company.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0EB562)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. ROLE DI ATAS (Contoh: "junior dev" - Tebal & Gelap)
                      Text(
                        job.role,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold, // Dibuat tebal
                          color: const Color(0xFF0F172A), // Warna gelap
                        ),
                      ),

                      const SizedBox(height: 4),

                      // 2. COMPANY DI BAWAH (Contoh: "amazon" - Tipis & Abu-abu)
                      Text(
                        job.company,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400, // Tidak tebal
                          color: const Color(0xFF64748B), // Warna abu-abu
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(job.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Applied on: ${job.dateApplied}",
                    style: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFF94A3B8))),
                Text(job.platform,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF13EC80))),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    switch (status) {
      case 'Interview':
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFB45309);
        break;
      case 'Offer':
        bg = const Color(0x3313EC80);
        text = const Color(0xFF065F46);
        break;
      case 'Rejected':
        bg = const Color(0xFFF1F5F9);
        text = const Color(0xFF64748B);
        break;
      default:
        bg = const Color(0xFFDBEAFE);
        text = const Color(0xFF1D4ED8);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status,
          style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: text)),
    );
  }
}
