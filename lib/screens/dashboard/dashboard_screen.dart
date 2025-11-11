import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:horizon_finance/widgets/bottom_nav_menu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horizon_finance/widgets/projection_chart_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide Provider, AuthState;
import 'package:horizon_finance/features/transactions/services/transaction_service.dart';
import 'package:horizon_finance/features/transactions/models/transactions.dart';
import 'package:horizon_finance/screens/transaction/transaction_form_screen.dart';
import 'package:horizon_finance/widgets/pie_chart_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // Estado dos dados
  bool _isLoading = true;
  String? _errorMessage;

  double _saldoAtual = 0;
  double _receitasMes = 0;
  double _despesasMes = 0;
  List<Transaction> _ultimasTransacoes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final transactionService = ref.read(TransactionServiceProvider);

      final dashboardData = await transactionService.getDashboardData();

      if (mounted) {
        setState(() {
          _saldoAtual = dashboardData.saldoAtual;
          _receitasMes = dashboardData.receitasMes;
          _despesasMes = dashboardData.despesasMes;
          _ultimasTransacoes = dashboardData.ultimasTransacoes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Tentar novamente',
              textColor: Colors.white,
              onPressed: _loadData,
            ),
          ),
        );
      }
    }
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = Theme.of(context).primaryColor;
    final Color secondaryColor = Theme.of(context).colorScheme.secondary;

    // Mostra loading se estiver carregando
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primaryBlue),
              const SizedBox(height: 16),
              Text(
                'Carregando seus dados...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- 1. HEADER ---
              _buildHeader(primaryBlue),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- 2. CARTÃO DE SALDO ATUAL E RESUMO ---
                    _buildBalanceSummaryCard(primaryBlue, secondaryColor),
                    const SizedBox(height: 25),

                    const ProjectionChartCard(),
                    const SizedBox(height: 25),

                    // --- 3. PROJEÇÃO DOS PRÓXIMOS 30 DIAS (Placeholder) ---
                    _buildProjectionChartCard(primaryBlue),
                    const SizedBox(height: 25),

                    // --- 4. METAS EM ANDAMENTO ---
                    _buildGoalsSection(primaryBlue),
                    const SizedBox(height: 25),

                    // --- 5. ATIVIDADE RECENTE ---
                    _buildRecentActivitySection(primaryBlue),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Navegação inferior
      bottomNavigationBar: _buildBottomNavBar(context, primaryBlue),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TransactionFormScreen(
                  initialType: TransactionType.despesa),
            ),
          );

          _loadData();
        },
        backgroundColor: primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildHeader(Color primaryBlue) {
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['name'] ?? 'Usuário';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bem-vindo ao Horizons Finance!',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242)),
              ),
              const SizedBox(height: 5),
              Text(
                '${_getGreeting()}, $userName!',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.waving_hand_outlined, color: primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSummaryCard(Color primaryBlue, Color secondaryColor) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saldo Atual',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 5),
            Text(
              'R\$ ${_formatCurrency(_saldoAtual)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _saldoAtual >= 0 ? primaryBlue : Colors.red,
              ),
            ),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIncomeExpenseItem(
                  label: 'Receitas',
                  amount: _receitasMes,
                  color: const Color(0xFF2E7D32), // Verde para Receita
                ),
                _buildIncomeExpenseItem(
                  label: 'Despesas',
                  amount: _despesasMes,
                  color: const Color(0xFFE53935), // Vermelho para Despesa
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseItem(
      {required String label, required double amount, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          'R\$ ${_formatCurrency(amount)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectionChartCard(Color primaryBlue) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Projeção dos Próximos 30 Dias',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryBlue.withOpacity(0.3)),
              ),
              padding: const EdgeInsets.all(8),
              // Usando o novo widget de pie chart
              child: DashboardPieChart(
                receitas: _receitasMes,
                despesas: _despesasMes,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsSection(Color primaryBlue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metas em Andamento',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryBlue.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 10),
        _buildGoalProgress('Reserva de Emergência', 0.65, primaryBlue),
        _buildGoalProgress('Carro Novo', 0.20, primaryBlue),
      ],
    );
  }

  Widget _buildGoalProgress(String name, double progress, Color primaryBlue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 14)),
              Text('${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              color: primaryBlue,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(Color primaryBlue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Atividade Recente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryBlue.withOpacity(0.9),
              ),
            ),
            if (_ultimasTransacoes.isEmpty)
              Text(
                'Nenhuma transação',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (_ultimasTransacoes.isEmpty)
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
                      'Nenhuma transação registrada ainda',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ..._ultimasTransacoes.map((transaction) {
            return _buildRecentTransaction(transaction);
          }).toList(),
      ],
    );
  }

  Widget _buildRecentTransaction(Transaction transaction) {
    final isIncome = transaction.tipo == TransactionType.receita;
    final statusColor =
        isIncome ? const Color(0xFF2E7D32) : const Color(0xFFE53935);
    final sign = isIncome ? '+' : '-';

    // Calcula há quanto tempo foi criada
    final now = DateTime.now();
    final diff = now.difference(transaction.dataCriacao);
    String timeAgo;

    if (diff.inDays > 0) {
      timeAgo = '${diff.inDays}d atrás';
    } else if (diff.inHours > 0) {
      timeAgo = '${diff.inHours}h atrás';
    } else if (diff.inMinutes > 0) {
      timeAgo = '${diff.inMinutes}min atrás';
    } else {
      timeAgo = 'Agora';
    }

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
      subtitle: Text(timeAgo),
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

  Widget _buildBottomNavBar(BuildContext context, Color primaryBlue) {
    return BottomNavMenu(
      currentIndex: 0,
      primaryColor: primaryBlue,
    );
  }
}
