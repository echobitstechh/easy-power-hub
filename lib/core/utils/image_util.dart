class ImageUtils {
  /// Cloudinary AI background-removal cutout, mirroring the web app's
  /// `Utils.getCutoutImageUrl()`. Falls back to the original URL for
  /// non-Cloudinary images.
  static String getCutoutImageUrl(String? url) {
    if (url == null ||
        !url.contains('res.cloudinary.com') ||
        !url.contains('/upload/')) {
      return url ?? '';
    }
    return url.replaceFirst(
        '/upload/', '/upload/e_background_removal/f_png/q_auto/');
  }
}
