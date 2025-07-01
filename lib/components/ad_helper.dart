import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-7832633450114085/4103383576';
    } else if (Platform.isIOS) {
      return 'Your iOS Ad Unit ID here'; // Reemplaza con tu ID de anuncio de banner para iOS
    } else {
      throw UnsupportedError('Plataforma no soportada para anuncios');
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-7832633450114085/3652312650';
    } else if (Platform.isIOS) {
      return 'Your iOS Ad Unit ID here'; // Reemplaza con tu ID de anuncio de banner para iOS
    } else {
      throw UnsupportedError('Plataforma no soportada para anuncios');
    }
  }
}
