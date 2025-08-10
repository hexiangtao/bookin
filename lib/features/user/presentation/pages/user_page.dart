import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookin/features/auth/data/api/user_api.dart';
import 'package:bookin/features/payment/presentation/pages/wallet_page.dart';
import 'package:bookin/features/coupon/presentation/pages/coupon_list_page.dart';
import 'package:bookin/features/user/presentation/pages/address_list_page.dart';
// import 'package:bookin/features/user/presentation/pages/favorite_list_page.dart'; // File not found
// import 'package:bookin/features/user/presentation/pages/record_list_page.dart'; // File not found
// import 'package:bookin/features/user/presentation/pages/profile_edit_page.dart'; // File not found
import 'package:bookin/features/coupon/presentation/pages/coupon_center_page.dart';
// import 'package:bookin/pages/user/about_page.dart'; // File not found
// import 'package:bookin/pages/user/membership_page.dart'; // File not found
// import 'package:bookin/pages/user/feedback_page.dart'; // File not found
// import 'package:bookin/pages/user/invite_page.dart'; // File not found
import 'package:bookin/features/auth/presentation/pages/login_page.dart'; // Import login page for navigation after logout
import 'package:bookin/features/order/presentation/pages/order_list_page.dart';
import 'package:bookin/shared/providers/user_provider.dart'; // Import UserProvider

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  void initState() {
    super.initState();
    // Fetch user info when the page initializes
    // This is now handled by the UserProvider's constructor and fetchUserInfo method
    // We can trigger a refresh here if needed, but Provider will notify listeners.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Provider.of<UserProvider>(context, listen: false).fetchUserInfo(context);
      } catch (e) {
        // Handle the error gracefully, user will see login prompt if not authenticated
        print('Failed to fetch user info in UserPage: $e');
      }
    });
  }

  Future<void> _logout() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.logout(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已退出登录'),
          duration: Duration(seconds: 2),
        ),
      );
      // Navigate to login page and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('退出登录失败: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('退出登录失败: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildOrderStatusItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              if (count > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFunction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final UserInfo? userInfo = userProvider.userInfo;
        final bool isLoading = !userProvider.isLoggedIn && userProvider.userInfo == null; // Simplified loading check

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // If not logged in and not loading, it means fetchUserInfo failed or no token
        // In a real app, you might want to redirect to login here if not already there.
        if (!userProvider.isLoggedIn) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('请先登录'),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  child: const Text('去登录'),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('我的'),
          ),
          body: RefreshIndicator(
            onRefresh: () => userProvider.fetchUserInfo(context), // Refresh user info
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // User Info Section
                  Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: userInfo?.avatar != null
                                ? NetworkImage(userInfo!.avatar!)
                                : null,
                            child: userInfo?.avatar == null
                                ? const Icon(Icons.person, size: 40)
                                : null,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            userInfo?.nickname ?? '未登录',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            userInfo?.phone ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 10),
                          // ElevatedButton(
                          //   onPressed: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(builder: (context) => const ProfileEditPage()),
                          //     );
                          //   },
                          //   child: const Text('编辑资料'),
                          // ),
                        ],
                      ),
                    ),
                  ),

                  // Order Status Section
                  Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '我的订单',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const OrderListPage()),
                                  );
                                },
                                child: const Text(
                                  '查看全部',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildOrderStatusItem(
                                context,
                                icon: Icons.payment,
                                label: '待付款',
                                count: userInfo?.pendingPaymentCount ?? 0,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const OrderListPage(initialTab: 1),
                                    ),
                                  );
                                },
                              ),
                              _buildOrderStatusItem(
                                context,
                                icon: Icons.schedule,
                                label: '待服务',
                                count: userInfo?.pendingServiceCount ?? 0,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const OrderListPage(initialTab: 2),
                                    ),
                                  );
                                },
                              ),
                              _buildOrderStatusItem(
                                context,
                                icon: Icons.build,
                                label: '服务中',
                                count: userInfo?.inServiceCount ?? 0,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const OrderListPage(initialTab: 2),
                                    ),
                                  );
                                },
                              ),
                              _buildOrderStatusItem(
                                context,
                                icon: Icons.rate_review,
                                label: '待评价',
                                count: userInfo?.pendingCommentCount ?? 0,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const OrderListPage(initialTab: 3),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Quick Functions Section
                  Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '快捷功能',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildQuickFunction(
                                context,
                                icon: Icons.account_balance_wallet,
                                label: '钱包',
                                subtitle: '¥${(userInfo?.balance ?? 0.0).toStringAsFixed(2)}',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const WalletPage()),
                                  );
                                },
                              ),
                              _buildQuickFunction(
                                context,
                                icon: Icons.card_giftcard,
                                label: '优惠券',
                                subtitle: '${userInfo?.couponCount ?? 0}张',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CouponListPage()),
                                  );
                                },
                              ),
                              _buildQuickFunction(
                                context,
                                icon: Icons.favorite,
                                label: '收藏',
                                subtitle: '${userInfo?.favoriteCount ?? 0}个',
                                onTap: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(builder: (context) => const FavoriteListPage()),
                                  // );
                                },
                              ),
                              _buildQuickFunction(
                                context,
                                icon: Icons.location_on,
                                label: '地址',
                                subtitle: '管理',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AddressListPage()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Other sections (e.g., Wallet, Coupons, Addresses, Settings)
                  Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.account_balance_wallet),
                          title: const Text('我的钱包'),
                          trailing: Text('¥${(userInfo?.balance ?? 0.0).toStringAsFixed(2)}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const WalletPage()),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.card_giftcard),
                          title: const Text('我的优惠券'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CouponListPage()),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: const Text('我的地址'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AddressListPage()),
                            );
                          },
                        ),
                        // ListTile(
                        //   leading: const Icon(Icons.favorite),
                        //   title: const Text('我的收藏'),
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(builder: (context) => const FavoriteListPage()),
                        //     );
                        //   },
                        // ),
                        // ListTile(
                        //   leading: const Icon(Icons.history),
                        //   title: const Text('消费记录'),
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(builder: (context) => const RecordListPage()),
                        //     );
                        //   },
                        // ),
                        ListTile(
                          leading: const Icon(Icons.local_activity),
                          title: const Text('优惠券中心'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CouponCenterPage()),
                            );
                          },
                        ),
                        // ListTile(
                        //   leading: const Icon(Icons.card_membership),
                        //   title: const Text('我的会员'),
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(builder: (context) => const MembershipPage()),
                        //     );
                        //   },
                        // ),
                        // ListTile(
                        //   leading: const Icon(Icons.feedback),
                        //   title: const Text('意见反馈'),
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(builder: (context) => const FeedbackPage()),
                        //     );
                        //   },
                        // ),
                        // ListTile(
                        //   leading: const Icon(Icons.person_add),
                        //   title: const Text('邀请有礼'),
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(builder: (context) => const InvitePage()),
                        //     );
                        //   },
                        // ),
                        // ListTile(
                        //   leading: const Icon(Icons.info_outline),
                        //   title: const Text('关于我们'),
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(builder: (context) => const AboutPage()),
                        //     );
                        //   },
                        // ),
                      ],
                    ),
                  ),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('退出登录', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}