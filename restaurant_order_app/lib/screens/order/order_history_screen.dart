import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../widgets/loading/loading_indicator.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load orders
    // context.read<OrderBloc>().add(LoadOrders());
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(OrderStatus.preparing, OrderStatus.readyForPickup, OrderStatus.outForDelivery),
          _buildOrderList(OrderStatus.delivered),
          _buildOrderList(OrderStatus.cancelled),
        ],
      ),
    );
  }
  
  Widget _buildOrderList(OrderStatus status, [OrderStatus? status2, OrderStatus? status3]) {
    // This is a placeholder implementation since OrderBloc isn't implemented yet
    // Normally this would use BlocBuilder
    return _buildMockOrderList(status, status2, status3);
    
    /* Actual implementation would look like:
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrdersLoading) {
          return const Center(child: LoadingIndicator());
        } else if (state is OrdersLoaded) {
          final filteredOrders = state.orders
              .where((order) => 
                order.status == status || 
                (status2 != null && order.status == status2) ||
                (status3 != null && order.status == status3))
              .toList();
          
          if (filteredOrders.isEmpty) {
            return _buildEmptyState(status);
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              return _buildOrderCard(order);
            },
          );
        } else if (state is OrdersError) {
          return Center(
            child: Text('Error: ${state.message}'),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
    */
  }
  
  // Placeholder until OrderBloc is implemented
  Widget _buildMockOrderList(OrderStatus mainStatus, [OrderStatus? status2, OrderStatus? status3]) {
    List<OrderStatus> statuses = [mainStatus];
    if (status2 != null) statuses.add(status2);
    if (status3 != null) statuses.add(status3);
    
    if (mainStatus == OrderStatus.delivered) {
      // Show mock completed orders
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return _buildOrderCard(
            Order(
              id: 'ORD${1000 + index}',
              restaurantId: 'REST${100 + index}',
              restaurantName: 'Restaurant ${index + 1}',
              items: [],
              subtotal: 24.99 + (index * 5.0),
              tax: 2.06 + (index * 0.4),
              total: 27.05 + (index * 5.5),
              createdAt: DateTime.now().subtract(Duration(days: index + 1)),
              status: OrderStatus.delivered,
              paymentMethod: const PaymentMethod(
                id: 'PM001',
                type: 'credit_card',
                cardBrand: 'visa',
                last4: '4242',
              ),
            ),
          );
        },
      );
    } else if (statuses.contains(OrderStatus.preparing) || 
               statuses.contains(OrderStatus.readyForPickup) || 
               statuses.contains(OrderStatus.outForDelivery)) {
      // Show mock active orders
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 2,
        itemBuilder: (context, index) {
          OrderStatus orderStatus = index == 0 
              ? OrderStatus.preparing 
              : OrderStatus.outForDelivery;
          
          return _buildOrderCard(
            Order(
              id: 'ORD${2000 + index}',
              restaurantId: 'REST${200 + index}',
              restaurantName: 'Restaurant ${index + 3}',
              items: [],
              subtotal: 18.50 + (index * 6.0),
              tax: 1.53 + (index * 0.5),
              total: 20.03 + (index * 6.5),
              createdAt: DateTime.now().subtract(Duration(hours: index + 1)),
              status: orderStatus,
              paymentMethod: const PaymentMethod(
                id: 'PM002',
                type: 'credit_card',
                cardBrand: 'mastercard',
                last4: '5678',
              ),
            ),
          );
        },
      );
    } else {
      // Show mock cancelled orders or empty state
      return _buildEmptyState(mainStatus);
    }
  }
  
  Widget _buildEmptyState(OrderStatus status) {
    String message = 'No orders found';
    IconData icon = Icons.receipt_long;
    
    if (status == OrderStatus.cancelled) {
      message = 'No cancelled orders';
      icon = Icons.cancel_outlined;
    } else if (status == OrderStatus.delivered) {
      message = 'No completed orders yet';
      icon = Icons.check_circle_outline;
    } else {
      message = 'No active orders';
      icon = Icons.access_time;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          if (status != OrderStatus.cancelled) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.go('/restaurants');
              },
              child: const Text('Browse Restaurants'),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.go('/orders/${order.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.restaurantName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(order.id.length - 6).toUpperCase()}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, y • h:mm a').format(order.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount'),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Payment Method'),
                  Text(
                    _getPaymentMethodName(order.paymentMethod),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      context.go('/orders/${order.id}');
                    },
                    child: const Text('View Details'),
                  ),
                  if (order.status == OrderStatus.outForDelivery || 
                      order.status == OrderStatus.readyForPickup) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        context.go('/orders/${order.id}/tracking');
                      },
                      child: const Text('Track Order'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case OrderStatus.preparing:
        color = Colors.blue;
        text = 'Preparing';
        break;
      case OrderStatus.readyForPickup:
        color = Colors.green;
        text = 'Ready for Pickup';
        break;
      case OrderStatus.outForDelivery:
        color = Colors.purple;
        text = 'Out for Delivery';
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        text = 'Delivered';
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  String _getPaymentMethodName(PaymentMethod paymentMethod) {
    if (paymentMethod.type == 'credit_card' && 
        paymentMethod.cardBrand != null && 
        paymentMethod.last4 != null) {
      return '${_capitalizeFirstLetter(paymentMethod.cardBrand!)} ••••${paymentMethod.last4}';
    }
    return _capitalizeFirstLetter(paymentMethod.type);
  }
  
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }
} 