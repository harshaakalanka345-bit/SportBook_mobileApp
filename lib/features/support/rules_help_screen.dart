import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import 'support_content.dart';

/// Venue rules, policies and how-to guides.
class RulesHelpScreen extends StatelessWidget {
  const RulesHelpScreen({super.key});

  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8FF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAF8FF),
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: ink), onPressed: () => Navigator.pop(context)),
          title: const Text('Rules & Help', style: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800)),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: muted,
            indicatorColor: AppColors.primary,
            tabs: [Tab(text: 'Rules & Policies'), Tab(text: 'How-to Guides')],
          ),
        ),
        body: TabBarView(children: [_rules(), _guides()]),
      ),
    );
  }

  Widget _rules() => ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          for (final s in ruleSections)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE9EEFF))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF0F2FF), borderRadius: BorderRadius.circular(10)), child: Icon(s.icon, color: AppColors.primary, size: 18)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(s.title, style: const TextStyle(color: ink, fontSize: 15, fontWeight: FontWeight.w800))),
                ]),
                const SizedBox(height: 10),
                for (final item in s.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Padding(padding: EdgeInsets.only(top: 6, right: 10), child: Icon(Icons.circle, size: 5, color: AppColors.primary)),
                      Expanded(child: Text(item, style: const TextStyle(color: muted, fontSize: 13, height: 1.45))),
                    ]),
                  ),
              ]),
            ),
        ],
      );

  Widget _guides() => ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          for (final g in helpGuides)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE9EEFF))),
              child: Theme(
                data: ThemeData(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  title: Text(g.title, style: const TextStyle(color: ink, fontSize: 14, fontWeight: FontWeight.w700)),
                  children: [
                    for (var i = 0; i < g.steps.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(g.steps[i], style: const TextStyle(color: muted, fontSize: 13, height: 1.4))),
                        ]),
                      ),
                  ],
                ),
              ),
            ),
        ],
      );
}
