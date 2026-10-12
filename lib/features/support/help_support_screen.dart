import 'package:flutter/material.dart';

import '../../core/actions.dart';
import '../../core/app_config.dart';
import '../../core/app_theme.dart';
import '../../core/supabase_service.dart';
import '../../core/toast.dart';
import 'report_incident_screen.dart';
import 'rules_help_screen.dart';
import 'support_content.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

enum _Channel { marshal, whatsapp, email }

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  static const ink = Color(0xFF11182D);
  static const muted = Color(0xFF697083);
  static const softBlue = Color(0xFFF0F2FF);

  static const _incidentTypes = {
    'Lighting / Floodlights': (Icons.bolt, 'Lighting'),
    'Net / Floor Hazard': (Icons.sports_tennis, 'Court damage'),
    'Ventilation / A/C': (Icons.ac_unit, 'Other'),
    'Turnstile Gate Barrier': (Icons.door_front_door_outlined, 'Safety hazard'),
    'Locker & Shower': (Icons.shower_outlined, 'Lockers & showers'),
  };

  final _search = TextEditingController();
  final _message = TextEditingController();
  String _selectedIncident = 'Lighting / Floodlights';
  bool _haltedGame = true;
  _Channel _channel = _Channel.marshal;

  @override
  void dispose() {
    _search.dispose();
    _message.dispose();
    super.dispose();
  }

  List<FaqEntry> get _filteredFaqs {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return faqs;
    return faqs.where((f) => f.question.toLowerCase().contains(q) || f.answer.toLowerCase().contains(q)).toList();
  }

  void _openReport({String? description}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportIncidentScreen(
          initialCategory: _incidentTypes[_selectedIncident]?.$2,
          initialSeverity: _haltedGame ? 'High' : 'Medium',
          initialDescription: description,
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _message.text.trim();
    if (text.length < 5) {
      toast('Please write your message first.');
      return;
    }
    switch (_channel) {
      case _Channel.marshal:
        _openReport(description: text);
        _message.clear();
      case _Channel.whatsapp:
        await openWhatsApp(AppConfig.supportWhatsApp, text);
      case _Channel.email:
        await sendEmail(AppConfig.supportEmail, subject: 'SportsBook support request', body: text);
    }
  }

  Future<void> _suggestVenue() async {
    final name = TextEditingController();
    final area = TextEditingController();
    final notes = TextEditingController();
    final key = GlobalKey<FormState>();
    String sport = 'Badminton';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Suggest a New Venue', style: TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Form(
              key: key,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(controller: name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Venue name'), validator: (v) => (v ?? '').trim().length < 3 ? 'Enter the venue name' : null),
                TextFormField(controller: area, decoration: const InputDecoration(labelText: 'Area (e.g. Colombo 05)'), validator: (v) => (v ?? '').trim().isEmpty ? 'Enter the area' : null),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: sport,
                  decoration: const InputDecoration(labelText: 'Sport'),
                  items: const ['Badminton', 'Tennis', 'Futsal', 'Basketball', 'Padel', 'Table Tennis', 'Swimming'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setLocal(() => sport = v ?? sport),
                ),
                TextFormField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes (address, contact, why it is great)')),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () { if (key.currentState!.validate()) Navigator.pop(ctx, true); }, child: const Text('Submit')),
          ],
        ),
      ),
    );
    final n = name.text.trim();
    final a = area.text.trim();
    final nt = notes.text.trim();
    name.dispose();
    area.dispose();
    notes.dispose();
    if (ok != true) return;
    try {
      await SupabaseService().suggestVenue(name: n, area: a, sport: sport, notes: nt);
      toast('Thanks! We will review "$n" for onboarding.');
    } catch (e) {
      toast('Could not send suggestion: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredFaqs;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: ink, size: 20), onPressed: () => Navigator.pop(context)),
        title: Row(children: [
          Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.sports_baseball, color: Colors.white, size: 14)),
          const SizedBox(width: 8),
          const Expanded(child: Text('Help & Support', style: TextStyle(color: ink, fontSize: 15, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
        ]),
        actions: [
          IconButton(tooltip: 'Report a fault', icon: const Icon(Icons.flag_outlined, color: muted, size: 20), onPressed: () => _openReport()),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: muted, size: 20),
            onSelected: (v) {
              switch (v) {
                case 'rules':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RulesHelpScreen()));
                case 'venue':
                  _suggestVenue();
                case 'report':
                  _openReport();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'rules', child: Text('Rules & Help')),
              PopupMenuItem(value: 'report', child: Text('Report a fault')),
              PopupMenuItem(value: 'venue', child: Text('Suggest a venue')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _searchBar(),
          const SizedBox(height: 16),
          if (_search.text.trim().isEmpty) ...[
            _hotlineCard(),
            const SizedBox(height: 20),
            _contactSection(),
            const SizedBox(height: 24),
            _reportPanel(),
            const SizedBox(height: 32),
          ],
          _faqHeader(),
          const SizedBox(height: 16),
          if (results.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: const Text('No help articles match your search. Try different words, or contact us above.', style: TextStyle(color: muted, fontSize: 13)),
            )
          else
            for (final f in results) _faqItem(f),
          const SizedBox(height: 24),
          _suggestCard(),
          const SizedBox(height: 40),
          _footer(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _searchBar() => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))]),
        child: TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search issues, court rules, refund policy',
            hintStyle: const TextStyle(color: muted, fontSize: 12),
            prefixIcon: const Icon(Icons.search, color: muted, size: 18),
            suffixIcon: _search.text.isEmpty ? null : IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => setState(_search.clear)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      );

  Widget _hotlineCard() {
    final phone = AppConfig.supportPhone;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE5EDFF), Color(0xFFD0DDFB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.phone_in_talk, color: Colors.white, size: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.circle, size: 6, color: Color(0xFF10B981)),
              SizedBox(width: 4),
              Text('24/7 COURT OPS HOTLINE', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 8),
            const Text('Need immediate help with lights or gate access?', style: TextStyle(color: ink, fontSize: 15, fontWeight: FontWeight.w800, height: 1.25)),
            const SizedBox(height: 6),
            Text(phone.isEmpty ? 'Hotline number not set up yet' : phone, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
          ]),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: () => callNumber(phone),
          icon: const Icon(Icons.call, size: 14),
          label: const Text('Call Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), minimumSize: Size.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        ),
      ]),
    );
  }

  Widget _contactSection() {
    final hint = switch (_channel) {
      _Channel.marshal => 'Describe the issue - it is sent to the venue manager as a support report.',
      _Channel.whatsapp => 'Opens WhatsApp with your message ready to send.',
      _Channel.email => 'Opens your mail app with your message ready to send.',
    };
    final sendLabel = switch (_channel) {
      _Channel.marshal => 'Send to Marshal',
      _Channel.whatsapp => 'Open WhatsApp',
      _Channel.email => 'Open Email',
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('WHO WOULD YOU LIKE TO TALK TO?', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _contactCard(_Channel.marshal, Icons.support_agent_rounded, 'Chat Marshal', 'Venue manager')),
        const SizedBox(width: 8),
        Expanded(child: _contactCard(_Channel.whatsapp, Icons.chat_bubble_outline_rounded, 'WhatsApp', 'Player line')),
        const SizedBox(width: 8),
        Expanded(child: _contactCard(_Channel.email, Icons.email_outlined, 'Email Us', 'Formal inquiries')),
      ]),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            controller: _message,
            maxLines: 3,
            decoration: InputDecoration(hintText: 'Type your message…', border: InputBorder.none, helperText: hint, helperMaxLines: 2),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send_rounded, size: 16),
              label: Text(sendLabel),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: const StadiumBorder()),
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _contactCard(_Channel channel, IconData icon, String title, String subtitle) {
    final selected = _channel == channel;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => _channel = channel),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.primary : const Color(0xFFE9EEFF)),
        ),
        child: Column(children: [
          Icon(icon, color: selected ? Colors.white : AppColors.primary, size: 22),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: selected ? Colors.white : ink, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: selected ? Colors.white70 : muted, fontSize: 9, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _reportPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFFFE5E5), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 18)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Report a Fault', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
              Text('Tell the venue manager about court issues', style: TextStyle(color: muted, fontSize: 11)),
            ]),
          ),
        ]),
        const SizedBox(height: 18),
        const Text('SELECT INCIDENT TYPE', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final e in _incidentTypes.entries)
            ChoiceChip(
              avatar: Icon(e.value.$1, size: 14, color: _selectedIncident == e.key ? Colors.white : AppColors.primary),
              label: Text(e.key, style: const TextStyle(fontSize: 11)),
              selected: _selectedIncident == e.key,
              showCheckmark: false,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(color: _selectedIncident == e.key ? Colors.white : ink, fontWeight: FontWeight.w600),
              onSelected: (_) => setState(() => _selectedIncident = e.key),
            ),
        ]),
        const SizedBox(height: 18),
        const Text('URGENCY LEVEL', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Active game halted', style: TextStyle(fontSize: 11))),
            ButtonSegment(value: false, label: Text('General maintenance', style: TextStyle(fontSize: 11))),
          ],
          selected: {_haltedGame},
          onSelectionChanged: (s) => setState(() => _haltedGame = s.first),
        ),
        const SizedBox(height: 18),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openReport(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(color: softBlue, borderRadius: BorderRadius.circular(12)),
            child: const Column(children: [
              Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 22),
              SizedBox(height: 8),
              Text('+ Add Photo of Court Issue', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
              Text('Helps floor marshals bring proper gear', style: TextStyle(color: muted, fontSize: 10)),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _openReport(),
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Submit Report to Arena Manager', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0D6EFD), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          ),
        ),
      ]),
    );
  }

  Widget _faqHeader() => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Expanded(child: Text('Frequently Asked\nQuestions', style: TextStyle(color: ink, fontSize: 20, fontWeight: FontWeight.w800, height: 1.15))),
        TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RulesHelpScreen())),
          child: const Text('Rules & Help →', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ]);

  Widget _faqItem(FaqEntry f) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Theme(
          data: ThemeData(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 14),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            leading: Icon(f.icon, color: AppColors.primary, size: 20),
            title: Text(f.question, style: const TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w600)),
            children: [Text(f.answer, style: const TextStyle(color: muted, fontSize: 12, height: 1.5))],
          ),
        ),
      );

  Widget _suggestCard() => InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _suggestVenue,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.add_location_alt_outlined, color: AppColors.primary, size: 20)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Suggest a New Venue in Colombo', style: TextStyle(color: ink, fontSize: 13, fontWeight: FontWeight.w700)),
                Text('Know a court, pitch, or swimming pool we should onboard?', style: TextStyle(color: muted, fontSize: 11)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, color: muted),
          ]),
        ),
      );

  Widget _footer() => const Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.verified_user_outlined, size: 14, color: AppColors.primary),
          SizedBox(width: 6),
          Text('Colombo Sports Authority (CSA)', style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
        SizedBox(height: 6),
        Text('SportsBook Help Center • Version 2.4.0', style: TextStyle(color: muted, fontSize: 10)),
      ]);
}
