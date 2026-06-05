import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:intl/intl.dart';
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
          if (state is BookingViewLoadingState) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }
          if (cubit.tickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 80,
                    color: AppColors.primaryColor,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "No Tickets Found",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Your booked tickets will appear here",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return Scaffold(
            backgroundColor: AppColors.lightColor,
            appBar: AppBar(
              backgroundColor: AppColors.primaryColor,
              title: Text(
                'Bookings',
                style: AppTextStyles.textStyle18.copyWith(
                  color: AppColors.lightColor,
                ),
              ),
              centerTitle: true,
            ),

            body: ListView.builder(
              itemCount: cubit.tickets.length,
              itemBuilder: (context, index) {
                var ticket = cubit.tickets[index];
                final formattedDate = DateFormat(
                  'MMMM d, yyyy',
                ).format(ticket.date);

                final formattedTime = DateFormat('h:mm a').format(ticket.date);
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8,
                  ),
                  child: Container(
                    // height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image(
                              height: 150,
                              width: double.infinity,
                              image: NetworkImage(ticket.uri),
                              fit: BoxFit.fill,
                            ),
                          ),
                          Gap(20),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Date of booking : ${formattedDate}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Time of booking : ${formattedTime}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Badge(
                                label: Text(
                                  ticket.ticketNumber,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: AppColors.grayColor,
                                padding: EdgeInsetsDirectional.all(8),
                              ),
                            ],
                          ),
                          Gap(10),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ticket.bussinessName,
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    ticket.serviceName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Badge(
                                label: Text(ticket.status),
                                padding: EdgeInsetsGeometry.all(8),
                                backgroundColor: AppColors.primaryColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
