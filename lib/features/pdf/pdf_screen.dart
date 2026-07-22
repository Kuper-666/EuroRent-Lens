import 'package:flutter/material.dart';
import '../../core/services/pdf_generator.dart';

class PdfScreen extends StatelessWidget {
  const PdfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('PDF Документы'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF212121),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PdfCard(
            title: 'Mieterprofil',
            subtitle: 'Профиль арендатора для Германии',
            icon: Icons.picture_as_pdf,
            onTap: () => _openMieterprofilForm(context),
          ),
          const SizedBox(height: 12),
          _PdfCard(
            title: 'Договор аренды',
            subtitle: 'Шаблон договора на немецком языке',
            icon: Icons.description,
            onTap: () => _openRentalContractForm(context),
          ),
          const SizedBox(height: 12),
          _PdfCard(
            title: 'Справка о доходах',
            subtitle: 'Подтверждение дохода для арендодателя',
            icon: Icons.account_balance,
            onTap: () => _openIncomeCertificateForm(context),
          ),
        ],
      ),
    );
  }

  void _openMieterprofilForm(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => const _MieterprofilForm(),
    ));
  }

  void _openRentalContractForm(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => const _RentalContractForm(),
    ));
  }

  void _openIncomeCertificateForm(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => const _IncomeCertificateForm(),
    ));
  }
}

// ── Mieterprofil Form ──────────────────────────────────────────────

class _MieterprofilForm extends StatefulWidget {
  const _MieterprofilForm();

  @override
  State<_MieterprofilForm> createState() => _MieterprofilFormState();
}

class _MieterprofilFormState extends State<_MieterprofilForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _dob = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _employer = TextEditingController();
  final _income = TextEditingController();
  final _occupants = TextEditingController();
  final _pets = TextEditingController();
  final _duration = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _dob.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _employer.dispose();
    _income.dispose();
    _occupants.dispose();
    _pets.dispose();
    _duration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Mieterprofil'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF212121),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Личные данные', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _field(_name, 'ФИО', Icons.person),
                    _field(_dob, 'Дата рождения (ДД.ММ.ГГГГ)', Icons.cake),
                    _field(_phone, 'Телефон', Icons.phone, keyboardType: TextInputType.phone),
                    _field(_email, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
                    _field(_address, 'Адрес', Icons.home),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Работа и доход', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _field(_employer, 'Работодатель', Icons.business),
                    _field(_income, 'Доход (EUR/мес)', Icons.euro, keyboardType: TextInputType.number),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Хозяйство', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _field(_occupants, 'Кол-во жильцов', Icons.people, keyboardType: TextInputType.number),
                    _field(_pets, 'Питомцы (если есть)', Icons.pets),
                    _field(_duration, 'Желаемый срок аренды', Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await PdfGenerator.generateMieterprofil(
                      name: _name.text,
                      dob: _dob.text,
                      phone: _phone.text,
                      email: _email.text,
                      address: _address.text,
                      employer: _employer.text,
                      income: _income.text,
                      occupants: _occupants.text,
                      pets: _pets.text.isNotEmpty ? _pets.text : null,
                      rentalDuration: _duration.text.isNotEmpty ? _duration.text : null,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Сгенерировать PDF', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'Обязательное поле' : null,
      ),
    );
  }
}

// ── Rental Contract Form ───────────────────────────────────────────

class _RentalContractForm extends StatefulWidget {
  const _RentalContractForm();

  @override
  State<_RentalContractForm> createState() => _RentalContractFormState();
}

class _RentalContractFormState extends State<_RentalContractForm> {
  final _formKey = GlobalKey<FormState>();
  final _landlord = TextEditingController();
  final _tenant = TextEditingController();
  final _address = TextEditingController();
  final _rent = TextEditingController();
  final _startDate = TextEditingController();
  final _endDate = TextEditingController();

  @override
  void dispose() {
    _landlord.dispose();
    _tenant.dispose();
    _address.dispose();
    _rent.dispose();
    _startDate.dispose();
    _endDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Договор аренды'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF212121),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Стороны', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _field(_landlord, 'Арендодатель (Vermieter)', Icons.person),
                    _field(_tenant, 'Арендатор (Mieter)', Icons.person_outline),
                    _field(_address, 'Адрес объекта', Icons.home),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Условия', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _field(_rent, 'Аренда (EUR/мес)', Icons.euro, keyboardType: TextInputType.number),
                    _field(_startDate, 'Дата начала (ДД.ММ.ГГГГ)', Icons.calendar_today),
                    _field(_endDate, 'Дата окончания (необязательно)', Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await PdfGenerator.generateRentalContract(
                      landlordName: _landlord.text,
                      tenantName: _tenant.text,
                      address: _address.text,
                      rentAmount: _rent.text,
                      startDate: _startDate.text,
                      endDate: _endDate.text.isNotEmpty ? _endDate.text : null,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Сгенерировать PDF', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'Обязательное поле' : null,
      ),
    );
  }
}

// ── Income Certificate Form ────────────────────────────────────────

class _IncomeCertificateForm extends StatefulWidget {
  const _IncomeCertificateForm();

  @override
  State<_IncomeCertificateForm> createState() => _IncomeCertificateFormState();
}

class _IncomeCertificateFormState extends State<_IncomeCertificateForm> {
  final _formKey = GlobalKey<FormState>();
  final _employee = TextEditingController();
  final _employer = TextEditingController();
  final _income = TextEditingController();
  final _startDate = TextEditingController();
  final _position = TextEditingController();

  @override
  void dispose() {
    _employee.dispose();
    _employer.dispose();
    _income.dispose();
    _startDate.dispose();
    _position.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Справка о доходах'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF212121),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Данные сотрудника', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _field(_employee, 'ФИО сотрудника', Icons.person),
                    _field(_position, 'Должность', Icons.work),
                    _field(_employer, 'Работодатель', Icons.business),
                    _field(_income, 'Доход (EUR/мес)', Icons.euro, keyboardType: TextInputType.number),
                    _field(_startDate, 'Дата устройства (ДД.ММ.ГГГГ)', Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await PdfGenerator.generateIncomeCertificate(
                      employeeName: _employee.text,
                      employerName: _employer.text,
                      monthlyIncome: _income.text,
                      employmentStart: _startDate.text,
                      position: _position.text.isNotEmpty ? _position.text : null,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Сгенерировать PDF', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'Обязательное поле' : null,
      ),
    );
  }
}

// ── Reusable PDF Card ──────────────────────────────────────────────

class _PdfCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _PdfCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF1E88E5), size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD)),
            ],
          ),
        ),
      ),
    );
  }
}
