import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AnalyticScreen extends StatelessWidget {
  const AnalyticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildMonthPicker(),
              const SizedBox(height: 24),
              _buildTotalApplicationsCard(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildSmallStatsCard(
                          "Success Rate", "12%", "5 Interviews")),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildSmallStatsCard(
                          "Sources", "LinkedIn 60%", "Jobstreet 40%")),
                ],
              ),
              const SizedBox(height: 24),
              _buildHeatmapCard(),
              const SizedBox(height: 24),
              _buildWrappedCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Header
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Career Insights',
                  style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A))),
              Text('Track your progress',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: const Color(0xFF64748B))),
            ],
          ),
          const Icon(LucideIcons.share2, color: Color(0xFF64748B)),
        ],
      ),
    );
  }

  // 2. Month Selector
  Widget _buildMonthPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('October 2023',
              style:
                  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
          const Icon(Icons.keyboard_arrow_down, size: 20),
        ],
      ),
    );
  }

  // 3. Total Applications Card (Main Chart)
  Widget _buildTotalApplicationsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.send,
                      color: Color(0xFF13EC80), size: 20),
                  const SizedBox(width: 8),
                  Text('Total Applications',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: const Color(0xFF64748B))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0x3313EC80),
                    borderRadius: BorderRadius.circular(99)),
                child: Text('+15%',
                    style: GoogleFonts.inter(
                        color: const Color(0xFF0DB561),
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text('42',
              style: GoogleFonts.inter(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2)),
          Text('vs 36 last month',
              style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF94A3B8))),
          const SizedBox(height: 24),
          // Placeholder Bar Chart (Simple Row of bars)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              return Container(
                width: 30,
                height: [20.0, 40.0, 15.0, 50.0, 30.0, 60.0, 80.0][index],
                decoration: BoxDecoration(
                  color: index == 6
                      ? const Color(0xFF13EC80)
                      : const Color(0xFFF1F5F9),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  // 4. Small Stats Cards (Success Rate & Sources)
  Widget _buildSmallStatsCard(String title, String mainVal, String subVal) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF64748B))),
          const SizedBox(height: 12),
          Text(mainVal,
              style:
                  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subVal,
              style: GoogleFonts.inter(
                  fontSize: 12, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  // 5. Activity Heatmap
  Widget _buildHeatmapCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Activity Heatmap',
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0x1913EC80),
                    borderRadius: BorderRadius.circular(8)),
                child: Text('High Intensity',
                    style: GoogleFonts.inter(
                        color: const Color(0xFF13EC80), fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Heatmap grid placeholder
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(35, (index) {
              return Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: [0, 5, 10, 20, 30].contains(index)
                      ? const Color(0xFF13EC80)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  // 6. October Wrapped Card (Dark Card)
  Widget _buildWrappedCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your October Wrapped',
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
              "You're in the top 5% of active job seekers this month. Keep it up!",
              style: GoogleFonts.inter(
                  color: const Color(0xFFCBD5E1), fontSize: 14)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF13EC80),
                foregroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Share Summary',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
