import 'dart:io';

import '../imports/imports.dart';

/// A service to handle URL launching operations.
class UrlLauncherService {
  UrlLauncherService._();
  static final UrlLauncherService instance = UrlLauncherService._();

  /// Launch a URL string.
  FutureEither<void> launch(String url, {LaunchMode? mode}) async {
    return runTask(() async {
      final formattedUrl = _formatUrl(url);
      final uri = Uri.parse(formattedUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: mode ?? LaunchMode.externalApplication,
        );
      } else {
        throw Exception('Could not launch url: $formattedUrl');
      }
    });
  }

  /// Opens native maps with directions to the given coordinates.
  /// Uses Apple Maps on iOS and Google Maps on Android.
  FutureEither<void> launchMapDirections({
    required double latitude,
    required double longitude,
  }) async {
    return runTask(() async {
      final destination = '$latitude,$longitude';
      final candidates = _mapDirectionCandidates(destination);

      for (final candidate in candidates) {
        try {
          final launched = await launchUrl(
            candidate.uri,
            mode: candidate.mode,
          );
          if (launched) return;
        } catch (error) {
          AppLogger.warning(
            'Map launch failed for ${candidate.uri}: $error',
          );
        }
      }

      throw Exception('Could not open maps for destination: $destination');
    });
  }

  List<_MapLaunchCandidate> _mapDirectionCandidates(String destination) {
    final candidates = <_MapLaunchCandidate>[];

    if (Platform.isIOS) {
      candidates.add(
        _MapLaunchCandidate(
          uri: Uri.parse('maps://?daddr=$destination&dirflg=d'),
          mode: LaunchMode.externalNonBrowserApplication,
        ),
      );
      candidates.add(
        _MapLaunchCandidate(
          uri: Uri.parse('http://maps.apple.com/?daddr=$destination&dirflg=d'),
          mode: LaunchMode.externalApplication,
        ),
      );
    } else if (Platform.isAndroid) {
      candidates.add(
        _MapLaunchCandidate(
          uri: Uri.parse('google.navigation:q=$destination'),
          mode: LaunchMode.externalNonBrowserApplication,
        ),
      );
      candidates.add(
        _MapLaunchCandidate(
          uri: Uri.parse('geo:$destination?q=$destination'),
          mode: LaunchMode.externalApplication,
        ),
      );
    }

    candidates.add(
      _MapLaunchCandidate(
        uri: Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$destination',
        ),
        mode: LaunchMode.externalApplication,
      ),
    );
    candidates.add(
      _MapLaunchCandidate(
        uri: Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$destination',
        ),
        mode: LaunchMode.platformDefault,
      ),
    );

    return candidates;
  }

  String _formatUrl(String url) {
    if (url.isValidUrl && !url.contains('://')) {
      return 'https://$url';
    }
    if (url.isValidPhoneNumber) {
      return Platform.isAndroid
          ? 'whatsapp://send?phone=$url'
          : 'https://wa.me/$url';
    }
    return url;
  }
}

class _MapLaunchCandidate {
  const _MapLaunchCandidate({
    required this.uri,
    required this.mode,
  });

  final Uri uri;
  final LaunchMode mode;
}
