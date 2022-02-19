import 'package:dart_otp/dart_otp.dart';

class AuthEntry {
  String? name;
  String? customName;
  int? period;
  int? digits;
  OTPAlgorithm? algorithm;
  String? secret;
  String? issuer;
  TOTP? totp;

  AuthEntry(
      {this.name,
      this.customName,
      this.period,
      this.digits,
      this.algorithm,
      this.secret,
      this.issuer});

  String getAuthCode() => totp!.now();

  static List<String> getAegisNameAndUsername(String backupString) {
    List<String> result = [];

    String otpName = backupString.split('%3A')[0].split('?')[0];
    result.add(otpName); // name
    result.add(backupString.split('%3A')[1].split('?')[0]); // username

    return result;
  }

  static AuthEntry fromGauthString(String backupString, bool isAegis) {
    AuthEntry authEntry = AuthEntry();

    String urlSection = backupString.substring(15);

    if (isAegis) {
      List<String> aegisNameAndUsername = getAegisNameAndUsername(urlSection);
      authEntry.name = aegisNameAndUsername[0];
      authEntry.customName = aegisNameAndUsername[1];

      // Replace ASCII %40 with @
      if (authEntry.customName!.contains('%40'))
      {
        authEntry.customName = authEntry.customName!.replaceAll('%40', '@');
      }
    } else {
      authEntry.name = urlSection.split('?')[0];
    }

    List<String> parametersSplit = urlSection.split('?')[1].split('&');

    for (int i = 0; i < parametersSplit.length; i++) {
      List<String> keyValue = parametersSplit[i].split('=');

      if (keyValue[0] == 'secret') authEntry.secret = keyValue[1];
      else if (keyValue[0] == 'issuer') authEntry.issuer = keyValue[1];
      else if (keyValue[0] == 'period') authEntry.period = int.parse(keyValue[1]);
      else if (keyValue[0] == 'digits') authEntry.digits = int.parse(keyValue[1]);
      else if (keyValue[0] == 'algorithm') {
        String algorithmString = keyValue[1];
        OTPAlgorithm algorithm = OTPAlgorithm.SHA1;
        switch (algorithmString.toLowerCase()) {
          case 'sha1':
            algorithm = OTPAlgorithm.SHA1;
            break;
          case 'sha256':
            algorithm = OTPAlgorithm.SHA256;
            break;
          case 'sha384':
            algorithm = OTPAlgorithm.SHA384;
            break;
          case 'sha512':
            algorithm = OTPAlgorithm.SHA512;
            break;
        }
        authEntry.algorithm = algorithm;
      }

      // if (i == 0) authEntry.period = int.parse(keyValue[1]);
      // else if (i == 1) authEntry.digits = int.parse(keyValue[1]);
      // else if (i == 2) {
      //   String algorithmString = keyValue[1];
      //   OTPAlgorithm algorithm = OTPAlgorithm.SHA1;
      //   switch (algorithmString.toLowerCase()) {
      //     case 'sha1':
      //       algorithm = OTPAlgorithm.SHA1;
      //       break;
      //     case 'sha256':
      //       algorithm = OTPAlgorithm.SHA256;
      //       break;
      //     case 'sha384':
      //       algorithm = OTPAlgorithm.SHA384;
      //       break;
      //     case 'sha512':
      //       algorithm = OTPAlgorithm.SHA512;
      //       break;
      //   }
      //   authEntry.algorithm = algorithm;
      // }
      // else if (i == 3) authEntry.secret = keyValue[1];
      // else if (i == 4) authEntry.issuer = keyValue[1];
    }

    authEntry.totp = TOTP(
      secret: authEntry.secret,
      interval: authEntry.period,
      digits: authEntry.digits ?? 6,
      algorithm: authEntry.algorithm ?? OTPAlgorithm.SHA1,
    );

    return authEntry;
  }
}
