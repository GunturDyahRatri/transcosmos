import 'package:quran_audio/data/model/ayat.dart';
import 'package:quran_audio/data/model/surah.dart';

/// Convert SurahDetail → Surah agar kompatibel dengan AudioPlayerCubit
extension SurahDetailMapper on SurahDetail {
  Surah toSurah() {
    return Surah(
      nomor: nomor,
      nama: nama,
      namaLatin: namaLatin,
      jumlahAyat: jumlahAyat,
      arti: arti,
      tempatTurun: tempatTurun,
      audio: audio,
      deskripsi: deskripsi,
    );
  }
}
