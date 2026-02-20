import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SafeSpaceScreen extends StatefulWidget {
  const SafeSpaceScreen({super.key});

  @override
  State<SafeSpaceScreen> createState() => _SafeSpaceScreenState();
}

class _SafeSpaceScreenState extends State<SafeSpaceScreen> {
  String selectedTab = 'Trending';

  // Data dummy untuk feed komunitas
  final List<Map<String, dynamic>> posts = [
    {
      'name': 'Anonymous Mentor',
      'role': 'Senior Product Designer',
      'time': '2h ago',
      'content': "Just finished a mock interview session...",
      'likes': 124,
      'comments': 18,
      // Tambahkan <Color> di depan kurung siku
      'color': <Color>[Colors.blue, Colors.blue],
    },
    {
      'name': 'CareerExplorer_99',
      'role': 'Job Seeker',
      'time': '5h ago',
      'content': "Finally received my offer letter...",
      'likes': 856,
      'comments': 42,
      'hasImage': true,
      // Tambahkan <Color> di depan kurung siku
      'color': <Color>[Colors.orange, Colors.pink],
    },
    {
      'name': 'InterviewAce',
      'role': 'Software Engineer',
      'time': '8h ago',
      'content': "Question: How do you handle...",
      'answer': "Focus on the learning outcome...",
      'likes': 32,
      'comments': 56,
      // Tambahkan <Color> di depan kurung siku
      'color': <Color>[Colors.purple, Colors.indigo],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan Gradient background persis Figma
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4B5320), Color(0xFF708238)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabSection(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) => _buildPostCard(posts[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Header (SafeSpace Title & Icons)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: Colors.white24, shape: BoxShape.circle),
                child: const Icon(LucideIcons.users,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text('SafeSpace',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
          Row(
            children: [
              const Icon(LucideIcons.search, color: Colors.white),
              const SizedBox(width: 16),
              const Icon(LucideIcons.plusCircle, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Tab Menu (Trending, Recent, etc)
  Widget _buildTabSection() {
    final tabs = ['Trending', 'Recent', 'Q&A', 'Mentors'];
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: tabs.map((tab) {
          bool isSelected = selectedTab == tab;
          return GestureDetector(
            onTap: () => setState(() => selectedTab = tab),
            child: Container(
              margin: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color:
                    isSelected ? Colors.white.withOpacity(0.9) : Colors.white12,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  tab,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color:
                          isSelected ? const Color(0xFF4B5320) : Colors.white),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 3. Post Card (Feed Items)
  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: post['color']),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post['name'],
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    Text('${post['role']} • ${post['time']}',
                        style: GoogleFonts.poppins(
                            color: Colors.white70, fontSize: 10)),
                  ],
                ),
              ),
              const Icon(LucideIcons.moreHorizontal, color: Colors.white60),
            ],
          ),
          const SizedBox(height: 12),
          Text(post['content'],
              style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 14, height: 1.6)),
          if (post['hasImage'] == true) ...[
            const SizedBox(height: 12),
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(12)),
              child: const Center(
                  child:
                      Icon(LucideIcons.image, color: Colors.white24, size: 40)),
            ),
          ],
          if (post['answer'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white38),
              ),
              child: Text(post['answer'],
                  style:
                      GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          Row(
            children: [
              _buildPostStat(LucideIcons.heart, post['likes'].toString()),
              const SizedBox(width: 20),
              _buildPostStat(
                  LucideIcons.messageCircle, post['comments'].toString()),
              const Spacer(),
              const Icon(LucideIcons.bookmark, color: Colors.white60, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 6),
        Text(value,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
