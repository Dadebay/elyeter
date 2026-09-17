/// Stand-in profile content until the account API exists. Replace with
/// `ProfileBloc` state; the widgets take plain values, so nothing else moves.
abstract final class ProfilePlaceholderData {
  static const userName = 'Myradow Maksat';
  static const orderCount = 23;

  /// Dialled as typed — `tel:` wants no spaces in the number.
  static const supportPhone = '+99362990344';

  /// The same number, grouped for reading.
  static const supportPhoneDisplay = '+993 62 990344';

  /// Picked out in bold inside the opening-hours line. Must read exactly as
  /// it does in the translations, or the line simply renders plain.
  static const supportHours = '09:00 - 19:00';
  static const instagramUrl = 'https://instagram.com/elyeter';
  static const tiktokUrl = 'https://tiktok.com/@elyeter';
  static const whatsappUrl = 'https://wa.me/99365000000';
  static const faqUrl = 'https://elyeter.com/faq';
}
