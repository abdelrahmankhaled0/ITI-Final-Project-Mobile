import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:taborq/core/routes/navigations.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';
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

          // 🚀 خلينا الـ Scaffold هو الأساس دايماً عشان الـ AppBar يفضل ثابت وشكل الأبلكيشن احترافي
          return Scaffold(
            appBar: AppBar(
              // backgroundColor: AppColors.primaryColor,
              elevation: 0,
              title: Text(
                'My Bookings',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Icon(Icons.calendar_month),
                ),
              ],
            ),
            body: _buildBody(context, state, cubit),
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
  ) {
    if (state is BookingViewLoadingState) {
      return Center(child: CircularProgressIndicator(strokeWidth: 3));
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
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.confirmation_number_outlined,
                  size: 70,
                  color: AppColors.primaryColor,
                ),
              ),
              const Gap(24),
              Text(
                "No Tickets Found",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const Gap(8),
              Text(
                "Your booked tickets will appear here",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // 🚀 عرض التذاكر بتصميم الـ List الاحترافي
    return ListView.builder(
      itemCount: cubit.tickets.length,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        var ticket = cubit.tickets[index];
        final formattedDate = DateFormat('MMMM d, yyyy').format(ticket.date);
        final formattedTime = DateFormat('h:mm a').format(ticket.date);

        // لون الـ Status ديناميكي حسب الحالة
        final statusColor = ticket.status.toLowerCase() == 'pending'
            ? Colors.orange.shade600
            : AppColors.primaryColor;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GestureDetector(
            onTap: () => _showDeleteDialog(context, cubit, ticket),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkColor.withAlpha(40),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. الصورة الخاصة بالخدمة مع الـ Badges فوقها بشكل شيك
                    Stack(
                      children: [
                        Image(
                          height: 140,
                          width: double.infinity,
                          image: NetworkImage(ticket.uri),
                          fit: BoxFit.cover,
                        ),
                        // تظليل خفيف فوق الصورة عشان الكلام والـ Badges تبان
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
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
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
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ticket.status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // اسم المكان والخدمة
                          Text(
                            ticket.bussinessName,
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            ticket.serviceName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Gap(12),
                          // خط فاصل منقط أو خفيف بين الداتا
                          Divider(color: Colors.grey.shade200, height: 1),
                          const Gap(12),
                          // التاريخ والوقت بشكل منظم جداً في Row
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 16,
                                      color: Colors.grey.shade500,
                                    ),
                                    const Gap(8),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
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
                                    color: Colors.grey.shade500,
                                  ),
                                  const Gap(8),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
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
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.lightColor,
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.redAccent,
                  size: 40,
                ),
              ),
              const Gap(20),
              Text(
                "Delete Booking?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const Gap(8),
              Text(
                "Are you sure you want to cancel this booking? This action cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => AppNavigations.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      cubit.deleteTicketById(ticket);
                      AppNavigations.pop(context);

                      Fluttertoast.showToast(
                        msg: "Deleted Successfully",
                        backgroundColor: AppColors.primaryColor,
                        textColor: Colors.white,
                      );
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(fontWeight: FontWeight.w600),
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
