import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myecommerce/Web/service/Firebase/firebase_service.dart';
import 'package:myecommerce/Web/service/responsive_service.dart';
import 'package:url_launcher/url_launcher.dart';

class Banners extends StatefulWidget {
  const Banners({super.key});

  @override
  State<Banners> createState() => _BannersState();
}

class _BannersState extends State<Banners> {
  final PageController _pageController = PageController();
  final firebaseService = FirebaseService();
  Timer? _timer;
  int _currentIndex = 0;
  List<BannerModel> _banners = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  void _loadBanners() {
    firebaseService.getBanners().listen(
      (snapshot) {
        if (!mounted) return;

        setState(() {
          _banners = snapshot.docs
              .map((doc) => BannerModel.fromFirestore(doc))
              .toList();
          _isLoading = false;
          _hasError = false;
        });

        // Start auto-slide only if we have banners
        if (_banners.isNotEmpty && _timer == null) {
          _startAutoSlide();
        } else if (_banners.isEmpty && _timer != null) {
          _timer?.cancel();
          _timer = null;
        }
      },
      onError: (error) {
        debugPrint('Error loading banners: $error');
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      },
    );
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || _banners.isEmpty) return;

      _currentIndex = (_currentIndex + 1) % _banners.length;

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }

      if (mounted) setState(() {});
    });
  }

  void _goToPrevious() {
    if (_banners.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _banners.length) % _banners.length;
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() {});
  }

  void _goToNext() {
    if (_banners.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _banners.length;
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() {});
  }

  Future<void> _handleBannerTap(String? link) async {
    if (link == null || link.isEmpty) return;

    try {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch $link');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        final horizontalPadding = ResponsiveService.getResponsiveValue(
          context: context,
          mobile: 16.0,
          tablet: 24.0,
          desktop: 80.0,
          largeDesktop: 120.0,
        );

        final verticalPadding = ResponsiveService.getResponsiveValue(
          context: context,
          mobile: 12.0,
          tablet: 16.0,
          desktop: 20.0,
        );

        final bannerHeight = ResponsiveService.getResponsiveValue(
          context: context,
          mobile: 180.0,
          tablet: 240.0,
          desktop: 300.0,
          largeDesktop: 350.0,
        );

        final borderRadius = ResponsiveService.getResponsiveValue(
          context: context,
          mobile: 8.0,
          tablet: 12.0,
          desktop: 14.0,
        );

        final showArrows = deviceType != DeviceType.mobile;
        final arrowSize = deviceType == DeviceType.tablet ? 36.0 : 40.0;
        final arrowIconSize = deviceType == DeviceType.tablet ? 20.0 : 24.0;

        // Loading state
        if (_isLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Container(
              height: bannerHeight,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // Error state
        if (_hasError) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Container(
              height: bannerHeight,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load banners',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Empty state
        if (_banners.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Container(
              height: bannerHeight,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No active banners',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: SizedBox(
            height: bannerHeight,
            child: Stack(
              children: [
                /// PageView with banners from Firebase
                PageView.builder(
                  controller: _pageController,
                  itemCount: _banners.length,
                  onPageChanged: (index) {
                    _currentIndex = index;
                    setState(() {});
                  },
                  itemBuilder: (context, index) {
                    final banner = _banners[index];
                    return GestureDetector(
                      onTap: () => _handleBannerTap(banner.link),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              banner.imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade300,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 48,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          banner.title,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Clickable indicator overlay
                            if (banner.link != null && banner.link!.isNotEmpty)
                              Positioned(
                                top: 12,
                                right: 12,
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
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.touch_app,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Tap to visit',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                /// Left Arrow (Hidden on mobile)
                if (showArrows && _banners.length > 1)
                  Positioned(
                    left: 10,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        width: arrowSize,
                        height: arrowSize,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            size: arrowIconSize,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: _goToPrevious,
                        ),
                      ),
                    ),
                  ),

                /// Right Arrow (Hidden on mobile)
                if (showArrows && _banners.length > 1)
                  Positioned(
                    right: 10,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        width: arrowSize,
                        height: arrowSize,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            size: arrowIconSize,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: _goToNext,
                        ),
                      ),
                    ),
                  ),

                /// Dot Indicators
                if (_banners.length > 1)
                  Positioned(
                    bottom: ResponsiveService.getResponsiveValue(
                      context: context,
                      mobile: 8.0,
                      tablet: 10.0,
                      desktop: 12.0,
                    ),
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_banners.length, (index) {
                        final isActive = _currentIndex == index;
                        final dotWidth = ResponsiveService.getResponsiveValue(
                          context: context,
                          mobile: isActive ? 20.0 : 6.0,
                          tablet: isActive ? 16.0 : 7.0,
                          desktop: isActive ? 14.0 : 8.0,
                        );
                        final dotHeight = ResponsiveService.getResponsiveValue(
                          context: context,
                          mobile: 6.0,
                          tablet: 7.0,
                          desktop: 8.0,
                        );

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: dotWidth,
                          height: dotHeight,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white : Colors.white54,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
}

/// Banner Model
class BannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final String? link;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String uploadedBy;

  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.link,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.uploadedBy = '',
  });

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BannerModel(
      id: doc.id,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      link: data['link'],
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      uploadedBy: data['uploadedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'link': link,
      'isActive': isActive,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'uploadedBy': uploadedBy,
    };
  }
}
