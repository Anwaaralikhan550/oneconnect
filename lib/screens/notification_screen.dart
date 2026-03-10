import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/sticky_footer.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  bool showUnreadOnly = true;
  late TabController _tabController;

  // Responsive helpers
  double _sw(BuildContext context) => MediaQuery.of(context).size.width;
  double _rs(BuildContext context, double design) => (_sw(context) / 390.0) * design;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        showUnreadOnly = _tabController.index == 0;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .fetchNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void markAllAsRead() {
    Provider.of<NotificationProvider>(context, listen: false).markAllRead();
    setState(() {
      showUnreadOnly = false;
      _tabController.animateTo(1); // Switch to "All" tab
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          Column(
            children: [
              // Header Section
              _buildHeader(context),

              // Content Section - Takes remaining space
              Expanded(
                child: _buildNotificationsContent(),
              ),
            ],
          ),

          // Bell icon positioned at top
          Positioned(
            left: 0,
            right: 0,
            top: _rs(context, 130),
            child: Center(
              child: SvgPicture.string(
                '''<svg width="32" height="38" viewBox="0 0 32 38" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M16 4C10.48 4 6 8.48 6 14V20L2 24V26H30V24L26 20V14C26 8.48 21.52 4 16 4Z" fill="#FFCD29"/>
                <path d="M18 30H14C14 31.1 14.9 32 16 32C17.1 32 18 31.1 18 30Z" fill="#FFCD29"/>
                </svg>''',
                width: _rs(context, 32),
                height: _rs(context, 38),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const StickyFooter(selectedIndex: 0), // Using Home index for notifications
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _rs(context, 150),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: _rs(context, 15)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: _rs(context, 35),
                  height: _rs(context, 35),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3195AB),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: _rs(context, 18),
                  ),
                ),
              ),
              SizedBox(width: _rs(context, 15)),
              // Title - Centered
              Expanded(
                child: Center(
                  child: Text(
                    'Notification',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: _rs(context, 25),
                      color: const Color(0xFF515151),
                      letterSpacing: -0.28,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(width: _rs(context, 15)),
              // Share icon placeholder for symmetry
              SizedBox(
                width: _rs(context, 35),
                height: _rs(context, 35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsContent() {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        final allNotifications = provider.notifications;
        final unreadNotifications =
            allNotifications.where((n) => !n.isRead).toList();

        // Determine which list to display based on selected tab
        final displayList =
            showUnreadOnly ? unreadNotifications : allNotifications;

        if (provider.isLoading) {
          return Column(
            children: [
              SizedBox(height: _rs(context, 5)),
              _buildMarkAsReadSection(),
              SizedBox(height: _rs(context, 10)),
              _buildTabsWithNotifications(),
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        }

        if ((provider.error ?? '').trim().isNotEmpty && allNotifications.isEmpty) {
          return Column(
            children: [
              SizedBox(height: _rs(context, 5)),
              _buildMarkAsReadSection(),
              SizedBox(height: _rs(context, 10)),
              _buildTabsWithNotifications(),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        provider.error!,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: _rs(context, 13),
                          color: const Color(0xFF000000),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: _rs(context, 12)),
                      GestureDetector(
                        onTap: () {
                          Provider.of<NotificationProvider>(context, listen: false)
                              .fetchNotifications();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: _rs(context, 18),
                            vertical: _rs(context, 10),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3499AF),
                            borderRadius: BorderRadius.circular(_rs(context, 8)),
                          ),
                          child: Text(
                            'Retry',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: _rs(context, 13),
                              color: const Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            SizedBox(height: _rs(context, 5)),
            _buildMarkAsReadSection(),
            SizedBox(height: _rs(context, 10)),
            _buildTabsWithNotifications(),
            if (displayList.isEmpty) ...[
              Expanded(
                child: _buildEmptyState(),
              ),
            ] else ...[
              SizedBox(height: _rs(context, 25)),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: _rs(context, 20)),
                  child: Column(
                    children: displayList.map((notification) {
                      final timeAgo =
                          _formatTimeAgo(notification.createdAt);
                      final senderName = _notificationString(
                        notification.data,
                        ['senderName', 'businessName', 'title'],
                      );
                      final category = _notificationString(
                        notification.data,
                        ['category', 'type'],
                      );
                      final profileImage = _notificationString(
                        notification.data,
                        ['profilePhotoUrl', 'profileImageUrl', 'profileImage', 'imageUrl', 'iconUrl'],
                      );
                      final items = _notificationStringList(notification.data, 'items');
                      final isOnline = _notificationBool(
                        notification.data,
                        ['isOnline', 'online'],
                      );
                      return Column(
                        children: [
                          _buildNotificationCard(
                            profileImage: profileImage,
                            businessName: senderName.isNotEmpty
                                ? senderName
                                : notification.title,
                            category: category.isNotEmpty
                                ? category
                                : notification.type,
                            timeAgo: timeAgo,
                            title: notification.body,
                            items: items,
                            isOnline: isOnline ?? !notification.isRead,
                          ),
                          SizedBox(height: _rs(context, 20)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _notificationString(
    Map<String, dynamic>? data,
    List<String> keys,
  ) {
    if (data == null) return '';
    for (final key in keys) {
      final value = (data[key] ?? '').toString().trim();
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  List<String> _notificationStringList(Map<String, dynamic>? data, String key) {
    final raw = data?[key];
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
  }

  bool? _notificationBool(Map<String, dynamic>? data, List<String> keys) {
    if (data == null) return null;
    for (final key in keys) {
      final value = data[key];
      if (value is bool) return value;
      if (value is String) {
        final lowered = value.trim().toLowerCase();
        if (lowered == 'true') return true;
        if (lowered == 'false') return false;
      }
    }
    return null;
  }

  ImageProvider _notificationImageProvider(String? value) {
    final raw = (value ?? '').trim();
    if (raw.startsWith('http')) return NetworkImage(raw);
    if (raw.startsWith('assets/')) return AssetImage(raw);
    return const AssetImage('assets/images/notification_profile_1-3e518f.png');
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        SizedBox(height: _rs(context, 30)),
        // Mailbox icon
        Image.asset(
          'assets/icons/Mailbox Icon.png',
          width: _rs(context, 106),
          height: _rs(context, 106),
          fit: BoxFit.contain,
        ),
        SizedBox(height: _rs(context, 17)),
        // Title
        Text(
          'No notifications yet',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: _rs(context, 30),
            height: 1.21,
            color: const Color(0xFF000000),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: _rs(context, 17)),
        // Description
        SizedBox(
          width: _rs(context, 286),
          child: Text(
            'Your notification will appear here once you\'ve received them.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: _rs(context, 13),
              height: 1.21,
              color: const Color(0xFF000000),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: _rs(context, 17)),
        // Missing notifications question
        SizedBox(
          width: _rs(context, 286),
          child: Text(
            'Missing notifications?',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: _rs(context, 13),
              height: 1.21,
              color: const Color(0xFF000000),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: _rs(context, 17)),
        // Settings link
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/push-notification-settings');
          },
          child: SizedBox(
            width: _rs(context, 286),
            child: Text(
              'Go to notification  settings',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: _rs(context, 13),
                height: 1.21,
                color: const Color(0xFF0097B2),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const Spacer(),
        // Action buttons
        _buildActionButtons(),
        SizedBox(height: _rs(context, 30)),
      ],
    );
  }

  Widget _buildNoNotificationsContent() {
    return Column(
      children: [
        const SizedBox(height: 5),
        _buildTabs(),
        const SizedBox(height: 30),
        _buildNoNotificationText(),
        const Spacer(),
        _buildActionButtons(),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildMarkAsReadSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _rs(context, 25)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: markAllAsRead,
            child: Row(
              children: [
                // Two check icons
                Icon(
                  Icons.check,
                  size: _rs(context, 15),
                  color: const Color(0xFF039908),
                ),
                SizedBox(width: _rs(context, 2)),
                Icon(
                  Icons.check,
                  size: _rs(context, 15),
                  color: const Color(0xFF039908),
                ),
                SizedBox(width: _rs(context, 5)),
                Text(
                  'Mark all as read',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: _rs(context, 11),
                    color: const Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsWithNotifications() {
    final unreadCount =
        Provider.of<NotificationProvider>(context).unreadCount;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _rs(context, 25)),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF878787),
            indicatorWeight: 4,
            labelColor: const Color(0xFF0097B2),
            unselectedLabelColor: const Color(0xFF000000),
            labelStyle: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: _rs(context, 13),
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: _rs(context, 13),
            ),
            dividerColor: const Color(0xFFEAEAEA),
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Unread'),
                    if (unreadCount > 0) ...[
                      SizedBox(width: _rs(context, 5)),
                      Container(
                        width: _rs(context, 19),
                        height: _rs(context, 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8383),
                          borderRadius: BorderRadius.circular(_rs(context, 4)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromRGBO(0, 0, 0, 0.15),
                              offset: Offset(0, _rs(context, 2)),
                              blurRadius: _rs(context, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '$unreadCount',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: _rs(context, 13),
                              color: const Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Tab(text: 'All'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final unreadCount =
        Provider.of<NotificationProvider>(context).unreadCount;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _rs(context, 25)),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF676767),
        indicatorWeight: 4,
        labelColor: const Color(0xFF0097B2),
        unselectedLabelColor: const Color(0xFF000000),
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: _rs(context, 13),
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: _rs(context, 13),
        ),
        dividerColor: const Color(0xFFEAEAEA),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Unread'),
                SizedBox(width: _rs(context, 5)),
                Container(
                  width: _rs(context, 19),
                  height: _rs(context, 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F1F1),
                    borderRadius: BorderRadius.circular(_rs(context, 4)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.15),
                        offset: Offset(0, _rs(context, 2)),
                        blurRadius: _rs(context, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$unreadCount',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: _rs(context, 13),
                        color: const Color(0xFF6A6A6A),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Tab(text: 'All'),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String label, String date) {
    return Container(
      constraints: BoxConstraints(maxWidth: _rs(context, 318)),
      padding: EdgeInsets.symmetric(horizontal: _rs(context, 16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (label.isNotEmpty)
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: _rs(context, 13),
                color: const Color(0xFF000000),
              ),
            )
          else
            const SizedBox.shrink(),
          Flexible(
            child: Text(
              date,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: _rs(context, 10),
                color: const Color(0xFF000000),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required String profileImage,
    required String businessName,
    required String category,
    required String timeAgo,
    required String title,
    required List<String> items,
    required bool isOnline,
    Color? lastItemColor,
  }) {
    return Container(
      constraints: BoxConstraints(maxWidth: _rs(context, 318), minHeight: _rs(context, 112)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image section
          Stack(
            children: [
              Container(
                width: _rs(context, 60),
                height: _rs(context, 60),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: _notificationImageProvider(profileImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: _rs(context, 15),
                  height: _rs(context, 15),
                  decoration: BoxDecoration(
                    color: isOnline ? const Color(0xFF7FBA98) : const Color(0xFFFF9494),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: _rs(context, 1)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: _rs(context, 10)),
          // Content section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with business name, dot, and time
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      businessName,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: _rs(context, 10),
                        color: const Color(0xFF000000),
                      ),
                    ),
                    SizedBox(width: _rs(context, 12)),
                    Container(
                      width: _rs(context, 6),
                      height: _rs(context, 6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFDE59),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: _rs(context, 12)),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: _rs(context, 10),
                        color: const Color(0xFF8E8E8E),
                      ),
                    ),
                  ],
                ),
                // Pink underline
                Container(
                  width: _rs(context, 80),
                  height: _rs(context, 1),
                  margin: EdgeInsets.only(top: _rs(context, 1)),
                  color: const Color(0xFFF08D8D),
                ),
                SizedBox(height: _rs(context, 8)),
                // Content box
                Container(
                  width: _rs(context, 248),
                  padding: EdgeInsets.only(
                    left: _rs(context, 10),
                    top: _rs(context, 7),
                    bottom: _rs(context, 7),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    border: Border(
                      left: BorderSide(
                        color: const Color(0xFFA6A6A6),
                        width: _rs(context, 1),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: _rs(context, 11),
                          color: const Color(0xFF000000),
                          height: 1.21,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: _rs(context, 2)),
                      ...items.asMap().entries.map((entry) {
                        int index = entry.key;
                        String item = entry.value;
                        bool isLast = index == items.length - 1;
                        return Padding(
                          padding: EdgeInsets.only(top: _rs(context, 2)),
                          child: Text(
                            item,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: _rs(context, 11),
                              color: isLast && lastItemColor != null
                                ? lastItemColor
                                : const Color(0xFF000000),
                              height: 1.21,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(height: _rs(context, 8)),
                // Footer with category
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Category',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: _rs(context, 10),
                        color: const Color(0xFF0097B2),
                      ),
                    ),
                    SizedBox(width: _rs(context, 14)),
                    Text(
                      category,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: _rs(context, 10),
                        color: const Color(0xFF959595),
                      ),
                    ),
                    SizedBox(width: _rs(context, 3)),
                    Container(
                      width: _rs(context, 4),
                      height: _rs(context, 4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF093066),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCardWithImages({
    required String profileImage,
    required String businessName,
    required String category,
    required String timeAgo,
    required String title,
    required List<String> items,
    required String price,
    required List<String> productImages,
    required bool isOnline,
  }) {
    return Container(
      constraints: BoxConstraints(maxWidth: _rs(context, 318), minHeight: _rs(context, 195)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image section
          Stack(
            children: [
              Container(
                width: _rs(context, 60),
                height: _rs(context, 60),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: _notificationImageProvider(profileImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: _rs(context, 15),
                  height: _rs(context, 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7FBA98),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: _rs(context, 1)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: _rs(context, 10)),
          // Content section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Text(
                      businessName,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: _rs(context, 10),
                        color: const Color(0xFF000000),
                      ),
                    ),
                    SizedBox(width: _rs(context, 8)),
                    Container(
                      width: _rs(context, 6),
                      height: _rs(context, 6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFDE59),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: _rs(context, 8)),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: _rs(context, 10),
                        color: const Color(0xFF8E8E8E),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: _rs(context, 90),
                  height: _rs(context, 1),
                  margin: EdgeInsets.only(top: _rs(context, 1)),
                  color: const Color(0xFFF08D8D),
                ),
                SizedBox(height: _rs(context, 8)),
                // Content box with price
                SizedBox(
                  width: _rs(context, 248),
                  height: _rs(context, 100),
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: _rs(context, 10), top: _rs(context, 7), bottom: _rs(context, 7)),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          border: Border(left: BorderSide(color: const Color(0xFFA6A6A6), width: _rs(context, 1))),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: _rs(context, 11),
                                color: const Color(0xFF000000),
                                height: 1.21,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: _rs(context, 1)),
                            if (items.isNotEmpty)
                              Text(
                                items[0],
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  fontSize: _rs(context, 11),
                                  color: const Color(0xFF000000),
                                  height: 1.21,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            SizedBox(height: _rs(context, 1)),
                            if (items.length > 1)
                              Text(
                                items[1],
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  fontSize: _rs(context, 11),
                                  color: const Color(0xFF000000),
                                  height: 1.21,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (items.length > 2) ...[
                              SizedBox(height: _rs(context, 4)),
                              Text(
                                items[2],
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  fontSize: _rs(context, 11),
                                  color: const Color(0xFF000000),
                                  height: 1.21,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Price positioned exactly as in Figma
                      Positioned(
                        left: _rs(context, 16),
                        bottom: _rs(context, 7),
                        child: Row(
                          children: [
                            SvgPicture.string(
                              '''<svg width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg">
                              <path d="M0 0.75H12V2.25H0V0.75Z" fill="#1E1E1E"/>
                              </svg>''',
                              width: _rs(context, 12),
                              height: _rs(context, 12),
                            ),
                            SizedBox(width: _rs(context, 6)),
                            Text(
                              price,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: _rs(context, 11),
                                color: const Color(0xFF000000),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: _rs(context, 5)),
                // Product images
                SizedBox(
                  width: _rs(context, 124),
                  height: _rs(context, 34),
                  child: Row(
                    children: productImages.take(3).map((imagePath) {
                      int index = productImages.indexOf(imagePath);
                      return Container(
                        width: _rs(context, 34),
                        height: _rs(context, 34),
                        margin: EdgeInsets.only(right: index < 2 ? _rs(context, 11) : 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(_rs(context, 5)),
                          image: DecorationImage(
                            image: _notificationImageProvider(imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: _rs(context, 5)),
                // Footer with category
                Row(
                  children: [
                    Text(
                      'Category',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: _rs(context, 10),
                        color: const Color(0xFF0097B2),
                      ),
                    ),
                    SizedBox(width: _rs(context, 14)),
                    Text(
                      category,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: _rs(context, 10),
                        color: const Color(0xFF959595),
                      ),
                    ),
                    SizedBox(width: _rs(context, 3)),
                    Container(
                      width: _rs(context, 4),
                      height: _rs(context, 4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF093066),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoNotificationText() {
    return Column(
      children: [
        SizedBox(
          width: 106,
          height: 106,
          child: Image.asset(
            'assets/images/notification_mailbox.png',
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 17),
        const Text(
          'No notifications yet',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 30,
            height: 1.21,
            color: Color(0xFF000000),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 17),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 286),
          child: const Text(
            'Your notification will appear here once you\'ve received them.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 13,
              height: 1.21,
              color: Color(0xFF000000),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 17),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 286),
          child: const Text(
            'Missing notifications?',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 13,
              height: 1.21,
              color: Color(0xFF000000),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 17),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/push-notification-settings');
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 286),
            child: const Text(
              'Go to notification  settings',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 13,
                height: 1.21,
                color: Color(0xFF0097B2),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            width: _rs(context, 147),
            height: _rs(context, 48),
            decoration: BoxDecoration(
              color: const Color(0xFFEAEAEA),
              borderRadius: BorderRadius.circular(_rs(context, 8)),
            ),
            child: Center(
              child: Text(
                'Later',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: _rs(context, 16),
                  height: 1.26,
                  color: const Color(0xFF464646),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: _rs(context, 6)),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/push-notification-settings');
          },
          child: Container(
            width: _rs(context, 147),
            height: _rs(context, 48),
            decoration: BoxDecoration(
              color: const Color(0xFF3499AF),
              borderRadius: BorderRadius.circular(_rs(context, 8)),
            ),
            child: Center(
              child: Text(
                'Get Notified',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: _rs(context, 16),
                  height: 1.26,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      height: 129, // Exact Figma height
      decoration: const BoxDecoration(
        color: Color(0xFFF5F6F7),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 31,
          bottom: 30,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _FooterItem(
              iconPath: 'assets/images/footer_home_complete.svg',
              label: 'Home',
            ),
            _FooterItem(
              iconPath: 'assets/images/footer_search_complete.svg',
              label: 'Search',
            ),
            const _FooterScanItem(),
            _FooterItem(
              iconPath: 'assets/images/footer_call_icon.svg',
              label: 'Call',
            ),
            _FooterItem(
              iconPath: 'assets/images/figma_profile_icon.svg',
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterItem extends StatelessWidget {
  final String iconPath;
  final String label;

  const _FooterItem({
    required this.iconPath,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          iconPath,
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(
            Color(0xFF484C52),
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF484C52),
          ),
        ),
      ],
    );
  }
}

class _FooterScanItem extends StatelessWidget {
  const _FooterScanItem();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF0092AC),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/images/figma_scan_icon.svg',
              width: 24,
              height: 24,
            ),
          ),
        ),
      ],
    );
  }
}
