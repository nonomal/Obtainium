import 'package:obtainium/app_sources/fdroid.dart';
import 'package:obtainium/custom_errors.dart';
import 'package:obtainium/providers/source_provider.dart';

class IzzyOnDroid extends AppSource {
  late FDroid fd;

  IzzyOnDroid() {
    hosts = ['izzysoft.de'];
    fd = FDroid();
    additionalSourceAppSpecificSettingFormItems =
        fd.additionalSourceAppSpecificSettingFormItems;
    allowSubDomains = true;
  }

  @override
  String sourceSpecificStandardizeURL(String url) {
    RegExp standardUrlRegExA =
        RegExp('^https?://android.${getSourceRegex(hosts)}/repo/apk/[^/]+');
    RegExpMatch? match = standardUrlRegExA.firstMatch(url.toLowerCase());
    if (match == null) {
      RegExp standardUrlRegExB = RegExp(
          '^https?://apt.${getSourceRegex(hosts)}/fdroid/index/apk/[^/]+');
      match = standardUrlRegExB.firstMatch(url.toLowerCase());
    }
    if (match == null) {
      throw InvalidURLError(name);
    }
    return match.group(0)!;
  }

  @override
  Future<String?> tryInferringAppId(String standardUrl,
      {Map<String, dynamic> additionalSettings = const {}}) async {
    return fd.tryInferringAppId(standardUrl);
  }

  @override
  Future<APKDetails> getLatestAPKDetails(
    String standardUrl,
    Map<String, dynamic> additionalSettings,
  ) async {
    String? appId = await tryInferringAppId(standardUrl);
    return fd.getAPKUrlsFromFDroidPackagesAPIResponse(
        await sourceRequest(
            'https://apt.izzysoft.de/fdroid/api/v1/packages/$appId'),
        'https://android.izzysoft.de/frepo/$appId',
        standardUrl,
        name,
        autoSelectHighestVersionCode:
            additionalSettings['autoSelectHighestVersionCode'] == true,
        trySelectingSuggestedVersionCode:
            additionalSettings['trySelectingSuggestedVersionCode'] == true,
        filterVersionsByRegEx: additionalSettings['filterVersionsByRegEx']);
  }
}
