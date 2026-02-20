import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobtracker/features/job_tracker/add_application_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ListApplicationScreen extends StatefulWidget {
  const ListApplicationScreen({super.key});

  @override
  State<ListApplicationScreen> createState() => _ListApplicationScreenState();
}

class _ListApplicationScreenState extends State<ListApplicationScreen> {
  // Variable filter ini nanti akan digunakan untuk query ke Database (Backend)
  String selectedFilter = 'All';

  // Struktur List ini sudah saya samakan dengan Model Data yang kita siapkan di folder /data/
  final List<Map<String, dynamic>> applications = [
    {
      'company': 'Google',
      'role': 'Senior Product Designer',
      'status': 'Interview',
      'date': 'Applied 2 days ago',
      'platform': 'LinkedIn',
      'logo': 'https://placehold.co/100x100',
    },
    {
      'company': 'Amazon',
      'role': 'Frontend Developer',
      'status': 'Applied',
      'date': 'Applied 1 week ago',
      'platform': 'Indeed',
      'logo': 'https://placehold.co/100x100',
    },
    {
      'company': 'Airbnb',
      'role': 'UX Researcher',
      'status': 'Offer',
      'date': 'Applied 3 weeks ago',
      'platform': 'Website',
      'logo': 'https://placehold.co/100x100',
    },
    {
      'company': 'Spotify',
      'role': 'Product Manager',
      'status': 'Rejected',
      'date': 'Applied 1 month ago',
      'platform': 'LinkedIn',
      'logo': 'https://placehold.co/100x100',
    },
  ];

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
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final item = applications[index];
                  // Logic filter sederhana: jika bukan 'All', maka saring berdasarkan status
                  if (selectedFilter != 'All' &&
                      item['status'] != selectedFilter) {
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
        onPressed: () {
          // Fungsi Navigator untuk pindah ke halaman AddApplicationScreen
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddApplicationScreen()),
          );
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

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Container(
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
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                      image: NetworkImage(job['logo']), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job['role'],
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(job['company'],
                        style: GoogleFonts.inter(
                            fontSize: 14, color: const Color(0xFF64748B))),
                  ],
                ),
              ),
              _buildStatusBadge(job['status']),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(job['date'],
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF94A3B8))),
              Text(job['platform'],
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF13EC80))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    // Fungsi ini memudahkan Backend untuk memberikan warna otomatis sesuai status
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
