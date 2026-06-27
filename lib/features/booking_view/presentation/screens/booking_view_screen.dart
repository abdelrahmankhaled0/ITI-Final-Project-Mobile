import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:taborq/core/routes/navigations.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/features/booking_view/presentation/cubit/booking_view_cubit.dart';
import 'package:taborq/features/booking_view/presentation/cubit/booking_view_states.dart';

class BookingViewScreen extends StatelessWidget {
  const BookingViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingViewCubit()..getTicketsByUserId(),
      child: BlocConsumer<BookingViewCubit, BookingViewStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = BookingViewCubit.get(context);
          final theme = Theme.of(context);

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              centerTitle: false,
              title: Text(
                'Bookings',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: 24,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                // تصميم Modern لأيقونة الـ AppBar
                Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.calendar_month, color: theme.primaryColor),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            body: _buildBody(context, state, cubit, theme),
          );
        },
      ),
    );
  }

  // 🛠️ دالة بناء محتوى الشاشة بناءً على الحالة
  Widget _buildBody(
      BuildContext context,
      BookingViewStates state,
      BookingViewCubit cubit,
      ThemeData theme, // تمرير الثيم للدالة
      ) {
    if (state is BookingViewLoadingState) {
      return Center(
          child: CircularProgressIndicator(
              strokeWidth: 3, color: theme.primaryColor));
    }

    if (cubit.tickets.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.confirmation_number_outlined,
                  size: 70,
                  color: theme.primaryColor,
                ),
              ),
              const Gap(24),
              Text(
                "No Tickets Found",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(8),
              Text(
                "Your booked tickets will appear here",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    // 🚀 عرض التذاكر بتصميم الـ List الاحترافي
    return ListView.builder(
      itemCount: cubit.tickets.length,
      padding: const EdgeInsets.only(left: 16.0, top: 12 , right: 16.0 , bottom: 80),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        var ticket = cubit.tickets[index];
        final formattedDate = DateFormat('MMMM d, yyyy').format(ticket.date);
        final formattedTime = DateFormat('h:mm a').format(ticket.date);

        // لون الـ Status ديناميكي حسب الحالة
        final statusColor = ticket.status.toLowerCase() == 'pending'
            ? Colors.orange
            : theme.primaryColor;

        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: GestureDetector(
            onTap: () => _showDeleteDialog(context, cubit, ticket, theme),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(48),
                boxShadow: [
                  // إظهار الظل في اللايت مود فقط عشان الدارك مود يكون Clean
                  if (theme.brightness == Brightness.light)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. الصورة الخاصة بالخدمة مع الـ Badges
                    Stack(
                      children: [
                        Image(
                          height: 150,
                          width: double.infinity,
                          image: NetworkImage(ticket.uri),
                          fit: BoxFit.cover,
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.1),
                                  Colors.black.withOpacity(0.4),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // رقم التذكرة (Top Left)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.tag,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const Gap(4),
                                Text(
                                  'Q-${ticket.ticketNumber.toString().padLeft(3, '0')}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // حالة التذكرة (Top Right)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(180),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              ticket.status,
                              style:  TextStyle(
                                color: Colors.white.withAlpha(200),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 2. تفاصيل التذكرة بالأسفل
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.bussinessName,
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            ticket.serviceName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Gap(12),
                          // خط فاصل يعتمد على الثيم
                          Divider(
                              color: theme.dividerColor.withOpacity(0.3),
                              height: 1),
                          const Gap(12),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 16,
                                      color: AppColors.grayColor
                                    ),
                                    const Gap(8),
                                    Text(
                                      formattedDate,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.grayColor
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 16,
                                    color: AppColors.grayColor,
                                  ),
                                  const Gap(8),
                                  Text(
                                    formattedTime,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.grayColor
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 🛠️ دالة الدايلوج الاحترافية المحدثة
  void _showDeleteDialog(
      BuildContext context,
      BookingViewCubit cubit,
      var ticket,
      ThemeData theme, // استقبال الثيم لضبط ألوان الدايلوج
      ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: theme.scaffoldBackgroundColor, // يتغير حسب المود
          elevation: 10,
          contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1), // شفافية تناسب الدارك واللايت
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded, // أيقونة أرق وأكثر عصرية
                  color: Colors.red,
                  size: 30,
                ),
              ),
              const Gap(24),
              Text(
                "Delete Booking?",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(12),
              Text(
                "Are you sure you want to cancel this booking? This action cannot be undone.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.dividerColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => AppNavigations.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      cubit.deleteTicketById(ticket);
                      AppNavigations.pop(context);

                      Fluttertoast.showToast(
                        msg: "Deleted Successfully",
                        backgroundColor: theme.primaryColor,
                        textColor: Colors.white,
                      );
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

