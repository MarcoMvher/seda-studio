import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  AppLocalizations(this.locale);

  final Locale locale;

  // Helper method to get localized strings
  String _getString(String arKey, String enKey) {
    return locale.languageCode == 'ar' ? arKey : enKey;
  }

  // ==================== APP NAME ====================
  String get appName => _getString('ستوديو SEDA', 'SEDA Studio');

  // ==================== SPLASH SCREEN ====================
  String get loading => _getString('جاري التحميل...', 'Loading...');

  // ==================== LOGIN SCREEN ====================
  String get login => _getString('تسجيل الدخول', 'Login');
  String get username => _getString('اسم المستخدم', 'Username');
  String get password => _getString('كلمة المرور', 'Password');
  String get usernameHint => _getString('أدخل اسم المستخدم', 'Enter username');
  String get passwordHint => _getString('أدخل كلمة المرور', 'Enter password');
  String get loginError => _getString('فشل تسجيل الدخول', 'Login failed');
  String get invalidCredentials => _getString('اسم المستخدم أو كلمة المرور غير صحيحة', 'Invalid username or password');
  String get autoDetectRole => _getString('نوع المستخدم محدد تلقائياً: مندوب أو فرع', 'User type is auto-detected: Delegate or Branch');
  String get delegateRole => _getString('مندوب', 'Delegate');
  String get branchRole => _getString('فرع', 'Branch');
  String get delegateUsernameHint => _getString('أدخل اسم المندوب', 'Enter delegate username');
  String get branchUsernameHint => _getString('أدخل اسم المستخدم للفرع', 'Enter branch username');

  // ==================== CUSTOMER LIST ====================
  String get customers => _getString('العملاء', 'Customers');
  String get searchCustomers => _getString('بحث عن عملاء...', 'Search customers...');
  String get noCustomersFound => _getString('لم يتم العثور على عملاء', 'No customers found');
  String get loadingCustomers => _getString('جاري تحميل العملاء...', 'Loading customers...');
  String get errorLoadingCustomers => _getString('خطأ في تحميل العملاء', 'Error loading customers');
  String get logout => _getString('تسجيل الخروج', 'Logout');
  String get settings => _getString('الإعدادات', 'Settings');

  // ==================== CUSTOMER DETAILS ====================
  String get visits => _getString('الزيارات', 'Visits');
  String get orders => _getString('الطلبات', 'Orders');
  String get startVisit => _getString('بدء زيارة', 'Start Visit');
  String get noVisitsYet => _getString('لا توجد زيارات بعد', 'No visits yet');
  String get tapStartVisit => _getString('اضغط "بدء زيارة" لإنشاء واحدة', 'Tap "Start Visit" to create one');
  String get noOrdersFound => _getString('لم يتم العثور على طلبات', 'No orders found');
  String get order => _getString('طلب', 'Order');
  String get visit => _getString('زيارة', 'Visit');
  String get status => _getString('الحالة', 'Status');
  String get date => _getString('التاريخ', 'Date');
  String get value => _getString('القيمة', 'Value');
  String get items => _getString('العناصر', 'Items');
  String get scheduled => _getString('مجدول', 'Scheduled');
  String get createVisitFromOrder => _getString('إنشاء زيارة من الطلب', 'Create Visit from Order');

  // ==================== CREATE VISIT DIALOG ====================
  String get createVisit => _getString('إنشاء زيارة', 'Create Visit');
  String get customer => _getString('العميل', 'Customer');
  String get address => _getString('العنوان', 'Address');
  String get selectOrder => _getString('اختر طلباً:', 'Select an order:');
  String get noAvailableOrders => _getString('لا توجد طلبات متاحة. جميع الطلبات لديها زيارات بالفعل.', 'No available orders. All orders already have visits.');
  String get close => _getString('إغلاق', 'Close');
  String get cancel => _getString('إلغاء', 'Cancel');
  String get yes => _getString('نعم', 'Yes');
  String get no => _getString('لا', 'No');
  String get visitForOrder => _getString('زيارة للطلب #', 'Visit for Order #');

  // ==================== VISIT DETAILS ====================
  String get visitDetails => _getString('تفاصيل الزيارة', 'Visit Details');
  String get edit => _getString('تعديل', 'Edit');
  String get save => _getString('حفظ', 'Save');
  String get delete => _getString('حذف', 'Delete');
  String get add => _getString('إضافة', 'Add');
  String get notes => _getString('ملاحظات', 'Notes');
  String get notesHint => _getString('أضف ملاحظات...', 'Add notes...');
  String get measurements => _getString('القياسات', 'Measurements');
  String get addMeasurement => _getString('إضافة قياس', 'Add Measurement');
  String get noMeasurementsYet => _getString('لا توجد قياسات بعد', 'No measurements yet');
  String get addFirstMeasurement => _getString('أضف قياسك الأول', 'Add your first measurement');
  String get spaceName => _getString('اسم المساحة', 'Space Name');
  String get spaceNameHint => _getString('مثال: غرفة المعيشة', 'e.g., Living Room');
  String get widthCm => _getString('العرض (سم)', 'Width (cm)');
  String get heightCm => _getString('الارتفاع (سم)', 'Height (cm)');
  String get width => _getString('العرض', 'Width');
  String get height => _getString('الارتفاع', 'Height');
  String get enterWidth => _getString('أدخل العرض', 'Enter width');
  String get enterHeight => _getString('أدخل الارتفاع', 'Enter height');
  String get photos => _getString('الصور', 'Photos');
  String get addPhoto => _getString('إضافة صورة', 'Add Photo');
  String get noPhotosYet => _getString('لا توجد صور بعد', 'No photos yet');
  String get takePhoto => _getString('التقاط صورة', 'Take Photo');
  String get deleteMeasurement => _getString('حذف القياس', 'Delete Measurement');
  String get deleteMeasurementConfirm => _getString('هل أنت متأكد من حذف هذا القياس؟', 'Are you sure you want to delete this measurement?');

  // ==================== STATUS ====================
  String get statusPending => _getString('قيد الانتظار', 'Pending');
  String get statusInProgress => _getString('قيد التنفيذ', 'In Progress');
  String get statusCompleted => _getString('مكتمل', 'Completed');
  String get statusCancelled => _getString('ملغي', 'Cancelled');

  // ==================== VISIT ACTIONS ====================
  String get cancelVisit => _getString('إلغاء الزيارة', 'Cancel Visit');
  String get cancelVisitConfirmation => _getString('هل أنت متأكد من إلغاء هذه الزيارة؟', 'Are you sure you want to cancel this visit?');
  String get visitCancelled => _getString('تم إلغاء الزيارة', 'Visit cancelled');
  String get completeVisit => _getString('إنهاء الزيارة', 'Complete Visit');
  String get completeVisitConfirmation => _getString('هل تريد إنهاء هذه الزيارة؟', 'Do you want to complete this visit?');

  // ==================== VISITS LIST SCREEN ====================
  String get searchVisits => _getString('بحث في الزيارات...', 'Search visits...');
  String get filter => _getString('تصفية', 'Filter');
  String get refresh => _getString('تحديث', 'Refresh');
  String get allVisits => _getString('كل الزيارات', 'All Visits');
  String get noVisitsWithStatus => _getString('لا توجد زيارات بهذه الحالة', 'No visits with this status');
  String get branchUser => _getString('فرع - عرض فقط', 'Branch - View Only');

  // ==================== ORDER HISTORY ====================
  String get orderHistory => _getString('سجل الطلبات', 'Order History');
  String get noOrderHistory => _getString('لا يوجد سجل للطلبات المكتملة', 'No completed order history');
  String get completed => _getString('مكتمل', 'Completed');

  // ==================== ADMIN SELECT VIEW ====================
  String get adminSelectView => _getString('اختر العرض', 'Select View');
  String get delegates => _getString('المندوبين', 'Delegates');
  String get branches => _getString('الفروع', 'Branches');
  String get delegatesViewDesc => _getString('عرض العملاء والطلبات', 'View customers and orders');
  String get branchesViewDesc => _getString('عرض الزيارات والقياسات', 'View visits and measurements');
  String get delegateLabel => _getString('المندوب', 'Delegate');
  String get by => _getString('بواسطة', 'By');

  // ==================== ERRORS ====================
  String get error => _getString('خطأ', 'Error');
  String get tryAgain => _getString('إعادة المحاولة', 'Try Again');
  String get failedToLoad => _getString('فشل في التحميل', 'Failed to load');
  String get failedToCreate => _getString('فشل في الإنشاء', 'Failed to create');
  String get failedToUpdate => _getString('فشل في التحديث', 'Failed to update');
  String get failedToDelete => _getString('فشل في الحذف', 'Failed to delete');
  String get noOrdersForCustomer => _getString('لا توجد طلبات لهذا العميل. لا يمكن إنشاء زيارة.', 'No orders found for this customer. Cannot create visit.');
  String get allOrdersHaveVisits => _getString('جميع الطلبات لديها زيارات بالفعل', 'All orders already have visits');

  // ==================== FORM VALIDATION ====================
  String get pleaseFillAllFields => _getString('يرجى ملء جميع الحقول', 'Please fill all fields');
  String get pleaseEnterWidth => _getString('يرجى إدخال العرض', 'Please enter width');
  String get pleaseEnterHeight => _getString('يرجى إدخال الارتفاع', 'Please enter height');
  String get widthMustBePositive => _getString('يجب أن يكون العرض أكبر من صفر', 'Width must be greater than 0');
  String get heightMustBePositive => _getString('يجب أن يكون الارتفاع أكبر من صفر', 'Height must be greater than 0');

  // ==================== SETTINGS SCREEN ====================
  String get language => _getString('اللغة', 'Language');
  String get selectLanguage => _getString('اختر اللغة', 'Select Language');
  String get arabic => _getString('العربية', 'Arabic');
  String get english => _getString('English', 'English');
  String get logoutConfirm => _getString('هل أنت متأكد من تسجيل الخروج؟', 'Are you sure you want to logout?');
  String get loginAgain => _getString('تسجيل الدخول مرة أخرى', 'Login Again');
  String get youAreNotLoggedIn => _getString('لست مسجلاً للدخول', 'You are not logged in');
  String get goToLogin => _getString('الذهاب لتسجيل الدخول', 'Go to Login');
  String get changePassword => _getString('تغيير كلمة المرور', 'Change Password');
  String get currentPassword => _getString('كلمة المرور الحالية', 'Current Password');
  String get newPassword => _getString('كلمة المرور الجديدة', 'New Password');
  String get confirmPassword => _getString('تأكيد كلمة المرور', 'Confirm Password');
  String get currentPasswordHint => _getString('أدخل كلمة المرور الحالية', 'Enter current password');
  String get newPasswordHint => _getString('أدخل كلمة المرور الجديدة', 'Enter new password');
  String get confirmPasswordHint => _getString('أكيد كلمة المرور الجديدة', 'Confirm new password');
  String get passwordChanged => _getString('تم تغيير كلمة المرور بنجاح', 'Password changed successfully');
  String get passwordChangeFailed => _getString('فشل تغيير كلمة المرور', 'Failed to change password');
  String get passwordsDoNotMatch => _getString('كلمات المرور غير متطابقة', 'Passwords do not match');
  String get invalidPasswordLength => _getString('كلمة المرور يجب أن تكون 8 أحرف على الأقل', 'Password must be at least 8 characters');

  // ==================== ERROR TYPES ====================
  String get errorNetwork => _getString('خطأ في الشبكة', 'Network Error');
  String get errorAuth => _getString('خطأ في المصادقة', 'Authentication Error');
  String get errorPermission => _getString('خطأ في الصلاحيات', 'Permission Error');
  String get errorNotFound => _getString('غير موجود', 'Not Found');
  String get errorValidation => _getString('خطأ في التحقق', 'Validation Error');
  String get errorServer => _getString('خطأ في الخادم', 'Server Error');

  // ==================== SPECIFIC ERROR MESSAGES ====================
  // Network Errors
  String get noInternetConnection => _getString('لا يوجد اتصال بالإنترنت', 'No internet connection');
  String get connectionTimeout => _getString('انتهت مهلة الاتصال', 'Connection timeout');
  String get serverUnreachable => _getString('لا يمكن الوصول للخادم', 'Server unreachable');

  // Auth Errors
  String get sessionExpired => _getString('جلسة العمل منتهية', 'Session expired');

  // Visit Errors
  String get failedToLoadVisit => _getString('فشل تحميل الزيارة', 'Failed to load visit');
  String get failedToCreateVisit => _getString('فشل إنشاء الزيارة', 'Failed to create visit');
  String get failedToUpdateVisit => _getString('فشل تحديث الزيارة', 'Failed to update visit');
  String visitNotFound(int id) => _getString('الزيارة رقم $id غير موجودة', 'Visit #$id not found');

  // Measurement Errors
  String get failedToLoadMeasurements => _getString('فشل تحميل القياسات', 'Failed to load measurements');
  String get failedToAddMeasurement => _getString('فشل إضافة القياس', 'Failed to add measurement');
  String get failedToUpdateMeasurement => _getString('فشل تحديث القياس', 'Failed to update measurement');
  String get failedToDeleteMeasurement => _getString('فشل حذف القياس', 'Failed to delete measurement');
  String measurementNotFound(int id) => _getString('القياس رقم $id غير موجود', 'Measurement #$id not found');

  // Image Errors
  String get failedToUploadImage => _getString('فشل رفع الصورة', 'Failed to upload image');
  String get failedToDeleteImage => _getString('فشل حذف الصورة', 'Failed to delete image');
  String get imageTooLarge => _getString('حجم الصورة كبير جداً', 'Image size is too large');
  String get invalidImageFormat => _getString('صيغة الصورة غير مدعومة', 'Unsupported image format');

  // Customer Errors
  String get failedToLoadCustomers => _getString('فشل تحميل العملاء', 'Failed to load customers');
  String get customerNotFound => _getString('العميل غير موجود', 'Customer not found');

  // Order Errors
  String get failedToLoadOrders => _getString('فشل تحميل الطلبات', 'Failed to load orders');
  String get orderNotFound => _getString('الطلب غير موجود', 'Order not found');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'ar' || locale.languageCode == 'en';
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
