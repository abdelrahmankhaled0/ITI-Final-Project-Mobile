import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:taborq/core/routes/routes.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';
import 'package:taborq/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:taborq/features/booking/presentation/cubit/booking_state.dart';
import 'package:taborq/features/booking/presentation/screens/subServices_screen.dart';
import 'package:taborq/features/business_datails/cubit/business_details_cubit.dart';
import 'package:taborq/features/chatbot/cubit/chatbot_cubit.dart';
import 'package:taborq/features/chatbot/data/chat_message_model.dart';
import 'package:taborq/features/notifications/presentation/cubit/notification_cubit.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (!mounted) return;

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => ChatBotCubit(),
      child: BlocConsumer<ChatBotCubit, ChatBotState>(
        listener: (context, state) {
          if (state is ChatBotSuccessState) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _scrollToBottom(),
            );
          }
        },
        builder: (context, state) {
          var cubit = BlocProvider.of<ChatBotCubit>(context);

          return Scaffold(
            backgroundColor: isDark
                ? const Color(0xFF0B0F14)
                : const Color(0xFFF8F9FA),
            appBar: AppBar(
              backgroundColor: isDark ? Colors.transparent : Colors.white,
              elevation: 0,
              scrolledUnderElevation: 1,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white : AppColors.darkColor,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryColor.withOpacity(0.15),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.primaryColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Tabourq AI",
                    style: AppTextStyles.textStyle16.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.lightColor
                          : AppColors.darkColor,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      itemCount: cubit.messages.length,
                      itemBuilder: (context, index) {
                        final msg = cubit.messages[index];
                        if (msg.type == MessageType.confirmation) {
                          return _BookingConfirmationCard(
                            data: msg.bookingData!,
                            isDark: isDark,
                            chatCubit: cubit,
                          );
                        }
                        return _buildMessageBubble(msg, isDark);
                      },
                    ),
                  ),
                  if (state is ChatBotLoadingState)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  _buildInputBar(cubit, state, isDark),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel msg, bool isDark) {
    final dynamicRadius = msg.isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          );

    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!msg.isUser) ...[
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: isDark
                        ? Color(0xFF172026).withAlpha(200)
                        : AppColors.neutralColor10,
                    child: const Icon(
                      Icons.smart_toy_outlined,
                      size: 14,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: msg.isUser
                          ? AppColors.primaryColor
                          : (isDark ? const Color(0xFF172026) : Colors.white),
                      borderRadius: dynamicRadius,
                      boxShadow: msg.isUser
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: msg.type == MessageType.image
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(msg.mediaPath!),
                              width: 220,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          )
                        : msg.type == MessageType.voice
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_circle_filled_rounded,
                                color: msg.isUser
                                    ? AppColors.lightColor
                                    : AppColors.primaryColor,
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 80,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: msg.isUser
                                      ? Colors.white54
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Voice",
                                style: AppTextStyles.textStyle14.copyWith(
                                  color: msg.isUser
                                      ? AppColors.lightColor
                                      : AppColors.darkColor,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            msg.message!,
                            style: AppTextStyles.textStyle14.copyWith(
                              color: msg.isUser
                                  ? AppColors.lightColor
                                  : (isDark
                                        ? AppColors.lightColor
                                        : AppColors.darkColor),
                              height: 1.3,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            // 🌟 عرض كروت الخدمات المقترحة أسفل بالونة الرسالة النصية للبوت مباشرة
            if (!msg.isUser &&
                msg.suggestedServices != null &&
                msg.suggestedServices!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: _buildSuggestedServicesList(msg.suggestedServices!),
              ),
          ],
        ),
      ),
    );
  }

  // 🌟 كروت اقتراحات الخدمات (صورة + اسم + زر تفاصيل وشو مور)
  Widget _buildSuggestedServicesList(List<dynamic> services) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 190,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: Colors.grey.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    service['serviceImage'] ?? 'https://placedog.net/500',
                    height: 85,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 85,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    service['serviceName'] ?? 'Service',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.textStyle14.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.lightColor
                          : AppColors.darkColor,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 28,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        final String bId = service['businessId'] ?? '';
                        final String sId = service['serviceId'] ?? '';
                        final String sName =
                            service['serviceName'] ?? 'Service Details';

                        final String lat = service['lat']?.toString() ?? '';
                        final String lng = service['lng']?.toString() ?? '';

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MultiBlocProvider(
                              providers: [
                                BlocProvider<BusinessDetailsCubit>(
                                  create: (context) => BusinessDetailsCubit(),
                                ),
                                BlocProvider.value(
                                  value: context.read<BookingCubit>(),
                                ),
                              ],
                              child: SubServicesScreen(
                                businessId: bId,
                                serviceId: sId,
                                serviceName: sName,
                                lat: lat,
                                lng: lng,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Show More",
                        style: AppTextStyles.textStyle14.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar(ChatBotCubit cubit, ChatBotState state, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF172026) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.image_outlined,
              color: AppColors.primaryColor,
              size: 22,
            ),
            onPressed: () => cubit.sendImage(ImageSource.gallery),
          ),
          GestureDetector(
            onTap: () {
              if (state is ChatBotRecordingState) {
                cubit.stopRecording();
              } else {
                cubit.startRecording();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: state is ChatBotRecordingState
                    ? Colors.red.withOpacity(0.2)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                state is ChatBotRecordingState
                    ? Icons.mic_rounded
                    : Icons.mic_none_rounded,
                color: state is ChatBotRecordingState
                    ? Colors.red
                    : AppColors.primaryColor,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextFormField(
              controller: _controller,
              style: AppTextStyles.textStyle14.copyWith(
                color: isDark ? AppColors.lightColor : AppColors.darkColor,
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                filled: false,
                hintText: state is ChatBotRecordingState
                    ? "Listening..."
                    : "Ask about a booking...",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              if (_controller.text.trim().isNotEmpty) {
                cubit.sendTextMessage(_controller.text);
                _controller.clear();
              }
            },
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryColor,
              child: Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🌟 Standalone widget for the booking confirmation card. It now hands off
// the actual booking to BookingCubit.bookQueuePlace — the EXACT same queue
// flow "Book Now" uses on SubServicesScreen — instead of writing directly to
// the flat 'tickets' collection. That means real queue tickets get created
// under Queues/{businessId}/services/{serviceId}/tickets, ticket numbers are
// generated by the same Firestore transaction/counter, and the user gets the
// same "already booked" handling and queue-update notifications as anywhere
// else in the app.
class _BookingConfirmationCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isDark;
  final ChatBotCubit chatCubit;

  const _BookingConfirmationCard({
    required this.data,
    required this.isDark,
    required this.chatCubit,
  });

  @override
  State<_BookingConfirmationCard> createState() =>
      _BookingConfirmationCardState();
}

class _BookingConfirmationCardState extends State<_BookingConfirmationCard> {
  // 🌟 Covers just the brief avgServiceTime lookup before bookQueuePlace
  // takes over and BookingCubit's own BookingLoading state drives the UI.
  bool _isFetchingService = false;

  void _showStatusToast({
    required String message,
    required Color backgroundColor,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  Future<void> _confirmBooking(BuildContext context) async {
    final String businessId = widget.data['businessId'] ?? '';
    final String serviceId = widget.data['serviceId'] ?? '';
    final String serviceName = widget.data['serviceName'] ?? '';

    if (businessId.isEmpty || serviceId.isEmpty) {
      _showStatusToast(
        message: "Missing booking details — please try asking again.",
        backgroundColor: Colors.red.shade700,
      );
      return;
    }

    setState(() => _isFetchingService = true);

    // 🌟 avgServiceTime lives on the LIVE Queue service doc
    // (Queues/{businessId}/services/{serviceId}), not on the catalog doc the
    // chatbot reads services from — same source bookQueuePlace's own queue
    // listeners use, and the same fallback default (10) BookingCubit itself
    // uses elsewhere when the field is missing.
    int avgServiceTime = 10;
    try {
      final serviceDoc = await FirebaseFirestore.instance
          .collection('Queues')
          .doc(businessId)
          .collection('services')
          .doc(serviceId)
          .get();
      if (serviceDoc.exists) {
        avgServiceTime = serviceDoc.data()?['avgServiceTime'] ?? avgServiceTime;
      }
    } catch (_) {
      // Keep the default avgServiceTime if this lookup fails.
    }

    if (!mounted) return;
    setState(() => _isFetchingService = false);

    if (!context.mounted) return;
    context.read<BookingCubit>().bookQueuePlace(
      businessId: businessId,
      serviceId: serviceId,
      serviceName: serviceName,
      avgServiceTime: avgServiceTime,
      notificationCubit: context.read<NotificationCubit>(),
    );
  }

  Widget _buildCardRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: isDark ? Colors.white60 : Colors.black45),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: AppTextStyles.textStyle14.copyWith(
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.textStyle14.copyWith(
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final isDark = widget.isDark;

    return BlocListener<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingSuccess) {
          _showStatusToast(
            message:
                "Successfully booked! Your number is: Q-${state.ticketCode}",
            backgroundColor: Colors.green.shade700,
          );
          widget.chatCubit.addAssistantMessage(
            "🎉 Your appointment at (${state.businessName}) for ${state.serviceName} is confirmed — your ticket number is Q-${state.ticketCode}.",
          );
        } else if (state is BookingAlreadyBookedState) {
          context.read<BookingCubit>().startQueueListener(
            businessId: data['businessId'] ?? '',
            serviceId: data['serviceId'] ?? '',
            userTurnNumber: state.ticketCode,
            ticketId: state.ticketId,
            avgServiceTime: state.avgServiceTime,
            notificationCubit: context.read<NotificationCubit>(),
            serviceName: state.serviceName,
            businessName: state.businessName,
          );
          _showStatusToast(
            message:
                "You already have an active booking. Your ticket is Q-${state.ticketCode}.",
            backgroundColor: Colors.orange.shade800,
          );
          widget.chatCubit.addAssistantMessage(
            "You already have an active ticket Q-${state.ticketCode} for ${state.serviceName} at ${state.businessName}.",
          );
        } else if (state is BookingFailure) {
          _showStatusToast(
            message: state.errorMessage,
            backgroundColor: Colors.red.shade700,
          );
        }
      },
      child: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          final bool isLoading = _isFetchingService || state is BookingLoading;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2923) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.statusGreen.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.statusGreen.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.statusGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Booking Match Found!",
                      style: AppTextStyles.textStyle16.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.statusGreen,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0x1A000000),
                  ),
                ),
                _buildCardRow(
                  Icons.business_rounded,
                  "Clinic",
                  data['bussinessName'] ?? 'Unknown',
                  isDark,
                ),
                const SizedBox(height: 10),
                _buildCardRow(
                  Icons.medical_services_rounded,
                  "Service",
                  data['serviceName'] ?? 'General Consultation',
                  isDark,
                ),
                const SizedBox(height: 10),
                _buildCardRow(
                  Icons.access_time_filled_rounded,
                  "Requested Time",
                  data['bookingTime'] != null
                      ? DateFormat(
                          'EEEE, MMM d - hh:mm a',
                        ).format(DateTime.parse(data['bookingTime']))
                      : 'As soon as possible',
                  isDark,
                ),
                const SizedBox(height: 4),
                Text(
                  "You'll join the live queue — your actual turn depends on how many people are ahead of you when you confirm.",
                  style: AppTextStyles.textStyle12.copyWith(
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusGreen,
                          foregroundColor: AppColors.lightColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: isLoading
                            ? null
                            : () => _confirmBooking(context),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                "Confirm Appointment",
                                style: AppTextStyles.textStyle14.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.shade300),
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: isLoading
                            ? null
                            : () => widget.chatCubit.sendTextMessage(
                                "Cancel booking and change the schedule",
                              ),
                        child: Text(
                          "Cancel",
                          style: AppTextStyles.textStyle14.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
