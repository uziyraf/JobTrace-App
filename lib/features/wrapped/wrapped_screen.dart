import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MonthlyWrappedScreen extends StatelessWidget {
  final String monthName;
  final String year;
  final int totalApplications;
  final int interviews;
  final int habitRate; // Persentase 0-100
  final List<MapEntry<String, double>>
      topSources; // Daftar platform & persentasenya

  const MonthlyWrappedScreen({
    super.key,
    required this.monthName,
    required this.year,
    required this.totalApplications,
    required this.interviews,
    required this.habitRate,
    required this.topSources,
  });

  // LOGIKA GAMIFIKASI: Nentuin Level berdasarkan jumlah apply
  Map<String, String> _calculateLevel() {
    if (totalApplications >= 30) {
      return {
        'title': 'THE RELENTLESS APPLIER',
        'desc':
            'AWARDED FOR SUBMITTING 30+ APPLICATIONS. YOUR CONSISTENCY IS CRUSHING THE COMPETITION.'
      };
    } else if (totalApplications >= 15) {
      return {
        'title': 'THE STEADY GRINDER',
        'desc':
            'AWARDED FOR SOLID CONSISTENCY. YOU ARE BUILDING STRONG MOMENTUM THIS MONTH.'
      };
    } else if (totalApplications > 0) {
      return {
        'title': 'THE RISING STAR',
        'desc':
            'EVERY JOURNEY STARTS WITH A SINGLE STEP. KEEP WARMING UP THAT ENGINE.'
      };
    } else {
      return {
        'title': 'THE SLEEPING DRAGON',
        'desc':
            'TAKING A BREAK IS FINE, BUT DON\'T LET YOUR SWORD RUST. TIME TO WAKE UP!'
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = _calculateLevel();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // BACKGROUND GRADIENT ALA SPOTIFY WRAPPED
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF00FF),
                      Color(0xFF2D00F7),
                      Color(0xFFADFF2F)
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        '$monthName $year UNWRAPPED',
                        style: GoogleFonts.archivoBlack(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          letterSpacing: 3,
                        ),
                      ),
                      const Icon(LucideIcons.share2, color: Color(0xFFADFF2F)),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // TITLE CARDS
                  Text('YOUR',
                      style: GoogleFonts.archivoBlack(
                          color: Colors.white, fontSize: 64, height: 0.9)),
                  Text('HUSTLE',
                      style: GoogleFonts.archivoBlack(
                          color: const Color(0xFFADFF2F),
                          fontSize: 64,
                          height: 0.9)),
                  Text('RECAP',
                      style: GoogleFonts.archivoBlack(
                          color: const Color(0xFFFF00FF),
                          fontSize: 64,
                          height: 0.9)),
                  const SizedBox(height: 24),

                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text:
                                '$monthName was legendary.\nYou’re officially in the ',
                            style: GoogleFonts.spaceGrotesk(
                                color: Colors.white, fontSize: 20)),
                        TextSpan(
                            text: 'Top 5%',
                            style: GoogleFonts.spaceGrotesk(
                                color: const Color(0xFFADFF2F),
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: '\nof seekers.',
                            style: GoogleFonts.spaceGrotesk(
                                color: Colors.white, fontSize: 20)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // TOTAL APPLICATIONS CARD (White)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('APPLICATIONS SENT',
                            style: GoogleFonts.archivoBlack(
                                color: Colors.black,
                                fontSize: 12,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 8),
                        Text('$totalApplications',
                            style: GoogleFonts.archivoBlack(
                                color: Colors.black, fontSize: 80, height: 1)),
                        const SizedBox(height: 16),
                        Text('MORE THAN 90% OF JOB SEEKERS THIS MONTH.',
                            style: GoogleFonts.spaceGrotesk(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // INTERVIEWS & HABITS ROW
                  Row(
                    children: [
                      // INTERVIEW CARD (Blue)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D00F7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('INTERVIEWS',
                                  style: GoogleFonts.archivoBlack(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 10,
                                      letterSpacing: 1)),
                              const SizedBox(height: 24),
                              Text('${interviews.toString().padLeft(2, '0')}',
                                  style: GoogleFonts.archivoBlack(
                                      color: Colors.white,
                                      fontSize: 48,
                                      height: 1)),
                              const SizedBox(height: 8),
                              Text('KEEP MOMENTUM',
                                  style: GoogleFonts.spaceGrotesk(
                                      color: const Color(0xFFADFF2F),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // HABIT RATE CARD (Magenta)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF00FF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('HABIT RATE',
                                  style: GoogleFonts.archivoBlack(
                                      color: Colors.black.withOpacity(0.6),
                                      fontSize: 10,
                                      letterSpacing: 1)),
                              const SizedBox(height: 24),
                              Text('$habitRate%',
                                  style: GoogleFonts.archivoBlack(
                                      color: Colors.black,
                                      fontSize: 48,
                                      height: 1)),
                              const SizedBox(height: 8),
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10)),
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: habitRate / 100,
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // TOP SOURCES (Only show if there's data)
                  if (topSources.isNotEmpty) ...[
                    Text('THE PLACES YOU HUNTED',
                        style: GoogleFonts.archivoBlack(
                            color: Colors.white, fontSize: 24)),
                    const SizedBox(height: 16),
                    ...topSources.map((source) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.circle,
                                    color: Color(0xFFADFF2F), size: 12),
                                const SizedBox(width: 12),
                                Text(source.key,
                                    style: GoogleFonts.spaceGrotesk(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Text('${source.value.toStringAsFixed(0)}%',
                                style: GoogleFonts.archivoBlack(
                                    color: const Color(0xFFADFF2F),
                                    fontSize: 20)),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 32),
                  ],

                  // LEVEL ATTAINED CARD (Black & Lime)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: const Color(0xFFADFF2F), width: 2),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x33ADFF2F),
                            blurRadius: 20,
                            spreadRadius: 5)
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(LucideIcons.award,
                            color: Color(0xFFADFF2F), size: 48),
                        const SizedBox(height: 16),
                        Text('LEVEL ATTAINED',
                            style: GoogleFonts.archivoBlack(
                                color: const Color(0xFFADFF2F),
                                fontSize: 10,
                                letterSpacing: 4)),
                        const SizedBox(height: 12),
                        Text(level['title']!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.archivoBlack(
                                color: Colors.white,
                                fontSize: 28,
                                height: 1.1)),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: const Color(0xFFADFF2F).withOpacity(0.1),
                              border: Border.all(
                                  color: const Color(0xFFADFF2F)
                                      .withOpacity(0.3))),
                          child: Text(
                            level['desc']!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                                color: const Color(0xFFADFF2F),
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
