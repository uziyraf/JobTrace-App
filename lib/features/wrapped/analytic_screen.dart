import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobtracker/data/models/application_model.dart';
import 'package:jobtracker/data/models/daos/application_dao.dart';
import 'package:jobtracker/data/models/daos/habbit_dao.dart';
import 'package:jobtracker/data/models/habbit_model.dart';
import 'package:jobtracker/features/wrapped/wrapped_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AnalyticScreen extends StatefulWidget {
  const AnalyticScreen({super.key});

  @override
  State<AnalyticScreen> createState() => _AnalyticScreenState();
}

class _AnalyticScreenState extends State<AnalyticScreen> {
  final ApplicationDao _applicationDao = ApplicationDao();
  final HabitDao _habitDao = HabitDao();

  Future<List<ApplicationModel>>? _jobsFuture;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _jobsFuture = _applicationDao.getAllApplications();
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  List<DateTime> _getPastMonths() {
    List<DateTime> months = [];
    DateTime current = DateTime.now();
    for (int i = 0; i < 12; i++) {
      months.add(DateTime(current.year, current.month - i, 1));
    }
    return months;
  }

  String _formatDateToKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  DateTime? _parseFlexibleDate(String dateStr) {
    if (dateStr.isEmpty) return null;

    try {
      return DateTime.parse(dateStr);
    } catch (e) {}

    try {
      String cleanStr =
          dateStr.replaceAll('-', '/').replaceAll('.', '/').trim();
      List<String> parts = cleanStr.split('/');

      if (parts.length == 3) {
        int month = int.parse(parts[0]); // Bagian pertama = Bulan
        int day = int.parse(parts[1]); // Bagian kedua = Hari
        int year = int.parse(parts[2]); // Bagian ketiga = Tahun

        if (year > 1000) {
          return DateTime(year, month, day);
        }
      }
    } catch (e) {}

    print(
        "🚨 [DEBUG TANGGAL] Bos, sistem nyerah baca format tanggal ini: '$dateStr'");
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<ApplicationModel>>(
            future: _jobsFuture,
            builder: (context, jobSnapshot) {
              return StreamBuilder<List<HabitModel>>(
                  stream: _habitDao.getHabitsStream(),
                  builder: (context, habitSnapshot) {
                    // LOADING
                    if (jobSnapshot.connectionState ==
                            ConnectionState.waiting ||
                        habitSnapshot.connectionState ==
                            ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF13EC80)));
                    }

                    final allJobs = jobSnapshot.data ?? [];
                    final allHabits = habitSnapshot.data ?? [];

                    // --- FILTER BULAN (DENGAN PARSER TAHAN BANTING) ---
                    final jobs = allJobs.where((job) {
                      DateTime? parsedDate =
                          _parseFlexibleDate(job.dateApplied);
                      if (parsedDate != null) {
                        return parsedDate.month == _selectedMonth.month &&
                            parsedDate.year == _selectedMonth.year;
                      }
                      return false;
                    }).toList();

                    // --- HITUNG STATISTIK ---
                    int totalApplications = jobs.length;
                    int interviewsAndOffers = jobs
                        .where((job) =>
                            job.status == 'Interview' || job.status == 'Offer')
                        .length;
                    String successRate = totalApplications == 0
                        ? "0%"
                        : "${((interviewsAndOffers / totalApplications) * 100).toStringAsFixed(0)}%";

                    Map<String, int> sourceCount = {};
                    for (var job in jobs) {
                      sourceCount[job.platform] =
                          (sourceCount[job.platform] ?? 0) + 1;
                    }
                    var sortedSources = sourceCount.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));
                    String source1 = "No Data";
                    String source2 = "";
                    if (sortedSources.isNotEmpty) {
                      source1 =
                          "${sortedSources[0].key} ${((sortedSources[0].value / totalApplications) * 100).toStringAsFixed(0)}%";
                    }
                    if (sortedSources.length > 1) {
                      source2 =
                          "${sortedSources[1].key} ${((sortedSources[1].value / totalApplications) * 100).toStringAsFixed(0)}%";
                    }

                    // --- LOGIKA HEATMAP ---
                    Set<String> activeDates = {};

                    // Cek Habits
                    for (var h in allHabits) {
                      if (h.lastCompletedDate != null &&
                          h.lastCompletedDate!.month == _selectedMonth.month &&
                          h.lastCompletedDate!.year == _selectedMonth.year) {
                        activeDates.add(_formatDateToKey(h.lastCompletedDate!));
                      }
                    }

                    // Cek Jobs
                    for (var job in jobs) {
                      DateTime? parsedDate =
                          _parseFlexibleDate(job.dateApplied);
                      if (parsedDate != null) {
                        activeDates.add(_formatDateToKey(parsedDate));
                      }
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),
                          _buildMonthPicker(),
                          const SizedBox(height: 24),
                          _buildTotalApplicationsCard(totalApplications),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildSmallStatsCard(
                                      "Success Rate",
                                      successRate,
                                      "$interviewsAndOffers Interviews")),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _buildSmallStatsCard(
                                      "Sources", source1, source2)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildHeatmapCard(activeDates),
                          const SizedBox(height: 24),
                          _buildWrappedCard(totalApplications,
                              interviewsAndOffers, sourceCount, activeDates),
                          const SizedBox(height: 32),
                        ],
                      ),
                    );
                  });
            }),
      ),
    );
  }

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

  Widget _buildMonthPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DateTime>(
          value: DateTime(_selectedMonth.year, _selectedMonth.month, 1),
          icon: const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(Icons.keyboard_arrow_down,
                  size: 20, color: Color(0xFF0F172A))),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A)),
          items: _getPastMonths().map((DateTime date) {
            return DropdownMenuItem<DateTime>(
              value: date,
              child: Text("${_getMonthName(date.month)} ${date.year}"),
            );
          }).toList(),
          onChanged: (DateTime? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedMonth = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildTotalApplicationsCard(int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9))),
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
                child: Text('Active',
                    style: GoogleFonts.inter(
                        color: const Color(0xFF0DB561),
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text('$total',
              style: GoogleFonts.inter(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2)),
          Text('applications sent in ${_getMonthName(_selectedMonth.month)}',
              style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildSmallStatsCard(String title, String mainVal, String subVal) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9))),
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

  Widget _buildHeatmapCard(Set<String> activeDates) {
    int daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9))),
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
                child: Text(_getMonthName(_selectedMonth.month),
                    style: GoogleFonts.inter(
                        color: const Color(0xFF13EC80),
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(daysInMonth, (index) {
              int day = index + 1;
              String dayKey =
                  "${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
              bool isDone = activeDates.contains(dayKey);

              return Tooltip(
                message: "Day $day",
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isDone
                        ? const Color(0xFF13EC80)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _buildWrappedCard(int totalApplications, int interviews,
      Map<String, int> sourceCount, Set<String> activeDates) {
    // Hitung Habit Rate (Persentase hari aktif vs jumlah hari dalam sebulan)
    int daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    int activeDays = activeDates.length;
    int habitRate =
        daysInMonth == 0 ? 0 : ((activeDays / daysInMonth) * 100).toInt();

    // Olah data Sources buat dikirim ke Wrapped Screen
    var sortedSources = sourceCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    List<MapEntry<String, double>> topSourcesList = [];
    for (var source in sortedSources.take(3)) {
      double percentage = (source.value / totalApplications) * 100;
      topSourcesList.add(MapEntry(source.key, percentage));
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
          borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Your ${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year} Wrapped',
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
              "Ready to see your hustle recap? Let's unwrap your career progress!",
              style: GoogleFonts.inter(
                  color: const Color(0xFFCBD5E1), fontSize: 14)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // NAVIGASI KE LAYAR WRAPPED DENGAN MEMBAWA DATA ASLI
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MonthlyWrappedScreen(
                      monthName:
                          _getMonthName(_selectedMonth.month).toUpperCase(),
                      year: _selectedMonth.year.toString(),
                      totalApplications: totalApplications,
                      interviews: interviews,
                      habitRate: habitRate,
                      topSources: topSourcesList,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF13EC80),
                foregroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Open My Wrapped',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
