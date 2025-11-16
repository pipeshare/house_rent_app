import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/post/components/hint.dart';
import 'package:house_rent_app/screens/post/steps/form_step.dart';

class PriceStep extends StatefulWidget {
  final TextEditingController priceCtrl;
  final String? currency;
  final String? period;

  const PriceStep({
    super.key,
    required this.priceCtrl,
    this.currency = 'ZMW',
    this.period = 'month',
  });

  @override
  State<PriceStep> createState() => _PriceStepState();
}

class _PriceStepState extends State<PriceStep> {
  final List<String> _periods = ['month', 'week', 'day', 'year'];
  String _selectedPeriod = 'month';
  String _selectedCurrency = 'ZMW';

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.period ?? 'month';
    _selectedCurrency = widget.currency ?? 'ZMW';
  }

  void _onPeriodChanged(String? period) {
    if (period != null) {
      setState(() {
        _selectedPeriod = period;
      });
    }
  }

  void _onCurrencyChanged(String? currency) {
    if (currency != null) {
      setState(() {
        _selectedCurrency = currency;
      });
    }
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'month':
        return 'Per Month';
      case 'week':
        return 'Per Week';
      case 'day':
        return 'Per Day';
      case 'year':
        return 'Per Year';
      default:
        return 'Per Month';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormStep(
      title: 'Set Your Price',
      subtitle: 'How much do you want to charge?',
      children: [
        // Price Input Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              // Currency and Amount Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Currency Dropdown
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCurrency,
                      onChanged: _onCurrencyChanged,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'ZMW', child: Text('ZMW')),
                        DropdownMenuItem(value: 'USD', child: Text('USD')),
                        DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                        DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Price Input
                  Expanded(
                    child: TextField(
                      controller: widget.priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        hintText: 'e.g., 9,500',
                        border: OutlineInputBorder(),
                        prefixText: ' ',
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Period Selection
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedPeriod,
                  onChanged: _onPeriodChanged,
                  decoration: const InputDecoration.collapsed(hintText: null),
                  items: _periods.map((period) {
                    return DropdownMenuItem(
                      value: period,
                      child: Text(_getPeriodLabel(period)),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Price Breakdown
        if (widget.priceCtrl.text.isNotEmpty) _buildPriceBreakdown(),

        const SizedBox(height: 16),

        // Tips and Information
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Hint(
              text: '💡 Pricing Tips:',
            ),
            const SizedBox(height: 8),
            _buildTipItem('Research similar properties in your area'),
            _buildTipItem('Consider amenities and location premium'),
            _buildTipItem('Be open to negotiation but set a fair price'),
            _buildTipItem('Include utilities if applicable'),
          ],
        ),

        const SizedBox(height: 16),

        // Market Comparison
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.blue, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Average rent in Lusaka: ZMW 3,500 - ZMW 15,000 per month',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown() {
    final price = double.tryParse(widget.priceCtrl.text) ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 12),
          _buildBreakdownRow('Monthly', price),
          _buildBreakdownRow('Weekly', price / 4.345),
          _buildBreakdownRow('Daily', price / 30),
          _buildBreakdownRow('Yearly', price * 12),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String period, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            period,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            '${_selectedCurrency} ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
