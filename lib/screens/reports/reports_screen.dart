import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/bottom_nav_menu.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _dataInicio = DateTime.now().subtract(const Duration(days: 30));
  DateTime _dataFim = DateTime.now();
  
  List<Transaction> _transacoesFiltradas = [];

  @override
  void initState() {
    super.initState();
    _carregarTransacoes();
  }

  Future<void> _carregarTransacoes() {
    // TODO: Implementar lógica real de carregamento
    // Filtrando transações entre _dataInicio e _dataFim
    setState(() {
      // _transacoesFiltradas = seuServico.getTransacoesPorPeriodo(_dataInicio, _dataFim);
    });
  }

  Future<void> _selecionarData(BuildContext context, bool isDataInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDataInicio ? _dataInicio : _dataFim,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isDataInicio) {
          _dataInicio = picked;
          // Garante que data início não seja depois da data fim
          if (_dataInicio.isAfter(_dataFim)) {
            _dataFim = _dataInicio;
          }
        } else {
          _dataFim = picked;
          // Garante que data fim não seja antes da data início
          if (_dataFim.isBefore(_dataInicio)) {
            _dataInicio = _dataFim;
          }
        }
        _carregarTransacoes();
      });
    }
  }

  String _formatarData(DateTime data) {
    return DateFormat('dd/MM/yyyy').format(data);
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Relatórios e Análises',
            style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filtros de Data
            _buildDateFilters(primaryBlue),
            const SizedBox(height: 20),

            // Cartão do Gráfico
            _buildChartCard(primaryBlue),
            const SizedBox(height: 20),

            // Lista de Categorias de Despesas (Legenda do Gráfico)
            _buildCategoryList('Alimentação', 850.00, Colors.blueAccent),
            _buildCategoryList('Moradia', 1500.00, Colors.redAccent),
            _buildCategoryList('Transporte', 450.00, Colors.orangeAccent),
            _buildCategoryList('Lazer', 300.00, primaryBlue),
            
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),

            // Lista de Transações
            _buildTransactionsList(primaryBlue),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavMenu(
        currentIndex: 1,
        primaryColor: primaryBlue,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implementar ação do FAB
        },
        backgroundColor: primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildDateFilters(Color primaryColor) {
    return Row(
      children: [
        Expanded(
          child: _buildDateField(
            label: 'Data Início',
            date: _dataInicio,
            onTap: () => _selecionarData(context, true),
            primaryColor: primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDateField(
            label: 'Data Fim',
            date: _dataFim,
            onTap: () => _selecionarData(context, false),
            primaryColor: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatarData(date),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Icon(Icons.calendar_today, size: 16, color: primaryColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(Color primaryColor) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribuição de Despesas',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF424242)),
            ),
            const SizedBox(height: 15),
            Container(
              height: 200,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('GRÁFICO DE PIZZA (FL_CHART)',
                  style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(String name, double amount, Color color) {
    return ListTile(
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(name),
      trailing: Text(
        'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}',
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: Color(0xFF424242)),
      ),
      onTap: () {},
    );
  }

  Widget _buildTransactionsList(Color primaryBlue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transações no Período',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryBlue.withOpacity(0.9),
              ),
            ),
            if (_transacoesFiltradas.isEmpty)
              Text(
                'Nenhuma transação',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              )
            else
              Text(
                '${_transacoesFiltradas.length} transações',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (_transacoesFiltradas.isEmpty)
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Nenhuma transação no período selecionado',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ..._transacoesFiltradas.map((transaction) {
            return _buildTransactionCard(transaction);
          }).toList(),
      ],
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isIncome = transaction.tipo == TransactionType.receita;
    final statusColor =
        isIncome ? const Color(0xFF2E7D32) : const Color(0xFFE53935);
    final sign = isIncome ? '+' : '-';

    // Formata a data da transação
    final dataFormatada = DateFormat('dd/MM/yyyy').format(transaction.dataCriacao);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: statusColor.withOpacity(0.1),
        child: Icon(
          isIncome ? Icons.trending_up : Icons.trending_down,
          color: statusColor,
        ),
      ),
      title: Text(
        transaction.descricao,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(dataFormatada),
      trailing: Text(
        '$sign R\$ ${_formatCurrency(transaction.valor)}',
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        /// TODO: Abrir detalhes da transação
      },
    );
  }
}

// Classes de modelo (ajuste conforme seu modelo real)
enum TransactionType { receita, despesa }

class Transaction {
  final String descricao;
  final double valor;
  final TransactionType tipo;
  final DateTime dataCriacao;

  Transaction({
    required this.descricao,
    required this.valor,
    required this.tipo,
    required this.dataCriacao,
  });
}