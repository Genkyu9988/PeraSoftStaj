# Üret: doğrulama ve kırmızı uyarılar — 4 Ekim 2026

Bu adım yalnızca Üret ekranındaki Style Builder, Custom Edit ve Detail Edit
doğrulamasını kapsar. Explore/AI Video kuralları, galeri/kamera, üretim geçmişi
ve AI servisi eklenmedi. Doğrulama geçince mevcut mock bilgilendirme mesajı
gösterilir; gerçek görsel üretilmez.

## Doğrulanmış ürün kuralları

Bu kurallar VB10 derslerinden değil, kullanıcının orijinal uygulamada yaptığı
denemeler ve paylaştığı ekran görüntülerinden alınmıştır.

| Eylem | Kontrol sırası | Opsiyonel alanlar |
| --- | --- | --- |
| Style Builder: üret | Araç, ardından stil/ekstra/renkten herhangi biri | Diğer iki seçim |
| Custom Edit: üret | Araç, ardından boş olmayan açıklama | — |
| Detail Edit: üret | Araç, ardından açı | Ayarla ve renk; ikisi de boş kalabilir |
| Detail Edit: Ayarla/Renk aç | Yalnızca açı; yoksa panel açılmaz | Araç bu eylem için gerekmez |

Araç önceliği, veri giriş sırası zorunluluğu değildir. Araç olmadan stil veya
metin girilebilir; Detail Edit'te açı seçildikten sonra araç olmadan da parça
ve renk seçilebilir. Ayarla ile renk arasında zorunlu sıra yoktur.

Merkezi mesajlar, ekran görüntülerindeki metinleri korur:

- Araç eksik: **Araç Fotoğrafı Yüklemek İçin Dokunun**
- Style Builder seçimi eksik: **Lütfen en az bir stil, ayar veya renk seçin.**
- Açı eksik: **Önce lütfen bir açı seçin.**
- Custom Edit açıklaması eksik: **Lütfen bir metin girin**

Style Builder kontrolünün adı Ekstra olsa da orijinal uyarıdaki “ayar” sözcüğü
korunmuştur. Kullanıcı, araç varken açı olmadan üretime basıldığında da aynı
açı mesajının çıktığını son ekran görüntüsüyle doğrulamıştır.

## Kodun sorumlulukları

- `GenerateValidator`: Flutter/context/cache bağımlılığı olmadan onaylı girdileri
  kontrol eder. İlk eksikliğin mesajını, eksik yoksa `null` döndürür. Her modun
  adlandırılmış ayrı metodu vardır; Detail Edit doğrulaması parça/renk istemez.
- `GenerateValidationMessages`: Dört uyarı metninin tek tanımıdır.
- Mevcut `FormValidator.description`: `trim()` ile yalnızca boşluk, satır sonu
  veya tab içeren açıklamayı reddeder; merkezi mesajı kullanır.
- `ModyFeedback`: Sadece bildirim görünümü ve yaşam döngüsü. Kırmızı, yuvarlak
  köşeli, beyaz ikon/metinli floating SnackBar. Uzun mesaj satıra sarılır.
- `ModyHomeView`: Kullanıcı eyleminde doğrulayıcıyı çağırır; hata varsa bildirimi
  gösterip döner. Kontroller `build` içinde çalıştırılmaz. Ayarla/Renk kontrolü,
  panel kilidi alınmadan ve sheet açılmadan yapılır.

Custom Edit'te formun bütün alanlarını otomatik doğrulamak yerine aynı saf
metin doğrulayıcısı üretim kontrolünden çağrılır. Böylece araç eksikken metin
hatası önce çıkmaz; aynı hata hem alan altında hem bildirimde gösterilmez.
TextEditingController'ın sahipliği ve dispose işlemi ekranda kalır.

Yeni bildirimden önce kuyruk ve mevcut bildirim temizlenir. Mod/ana sekme
değişiminde, araç seçiminde veya açıklama değiştiğinde eski bildirim temizlenir.
Seçim paneli açılışındaki mevcut bildirim kapatma davranışı korunur.
Gösterim süresi Flutter'ın varsayılanıdır; ekran görüntüsünden orijinal sürenin
tespit edildiği iddia edilmez. Normal uyarı için modal dialog/onay düğmesi yoktur.

Doğrulama seçimleri değiştirmez ve cache yazmaz. Araç silinince diğer seçimler
kalır. Önceki açı-parça çalışmasındaki farklı açı onayında parçaların sıfırlanması,
rengin korunması ve Uygula/iptal ayrımı değişmez. Sadece onaylanmış seçimler
üretime katılır. Ek paket, singleton, state-management veya servis katmanı eklenmedi.

## Eğitim kaynakları: alınan mantık ile proje uyarlamasının ayrımı

Yerel transkriptlerin ilgili bölümleri okunup GitHub örnekleriyle
karşılaştırılmıştır. Videoların tamamının yeniden izlendiği iddiası yoktur.
Zamanlar transkript zaman işaretleridir; otomatik metindeki teknik terim
hataları kod örnekleriyle karşılaştırılmıştır.

| Ders / bölüm | Öğretmenin vurguladığı yaklaşım | Buradaki uyarlama |
| --- | --- | --- |
| #11 Extension, OOP, Mixin, Form Validate; 63:34–64:56 ve 65:35–67:49 | Geçerli durumda null, geçersizde mesaj; doğrulamadan işleme devam etmemek | `GenerateValidator`, ilk hata sonrası erken dönüş |
| #11; 67:53–68:44 | Otomatik doğrulamanın tetiklenme kapsamına dikkat etmek | Uyarı üretim/panel dokunuşunda gösterilir; ilk açılışta hata yok |
| #11; 69:12–70:55 | Doğrulama kodunu ayırmak, tekrarları küçük bileşenlerde toplamak | Ekrandan ayrı saf doğrulayıcı; mevcut metin doğrulayıcısını tekrar kullanmak |
| #11; 71:06–71:58 | Mesajları tek sınıfta yönetmek; tek dilde bile metinleri dağıtmamak | `GenerateValidationMessages` |
| #13 Sheet, Dialog, Generic; 03:21–04:36 | Seçim, karar ve kısa bildirim için uygun bileşeni seçmek | Seçimde sheet, eksik bilgi uyarısında SnackBar; AlertDialog kopyalanmadı |
| #18 Picker, Vexana, Runner; 02:17–02:49, 17:17–17:40, 18:44–18:58 | Test edilebilir kod, gerekli bağımlılıkları dışarıdan almak; test düşüncesi | Girdileri parametre alan, ekrandan bağımsız doğrulama |
| #18; 33:06–38:42 | Gerçek bağımlılığı kontrollü test karşılığıyla değiştirebilmek | Kurallar doğrudan girdilerle test edilir; bu özellik için depolama/mock kütüphanesi gerekmiyor |

GitHub: **VB10/Flutter-Full-Learn**

- [#11 form_learn_view.dart](https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/202/form_learn_view.dart): `FormFieldValidator`, `ValidatorMessage`, doğrulama geçerse devam.
- [#13 alert_learn.dart](https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/202/alert_learn.dart): dialog örneğidir; kırmızı SnackBar'ın hazır kodu değildir.
- [#18 user_save_model.dart](https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/303/testable/user_save_model.dart): bağımlılığın dışarıdan alınması.
- [#18 req_res_test.dart](https://github.com/VB10/Flutter-Full-Learn/blob/main/test/req_res_test.dart): kontrollü bağımlılıkla sonuç doğrulama.

Resmî Flutter tamamlayıcıları:

- [Form doğrulama](https://docs.flutter.dev/cookbook/forms/validation): validator sözleşmesi; bütün alanları kontrol etme ile bizim öncelikli birleşik kurallarımız farklıdır.
- [showSnackBar](https://api.flutter.dev/flutter/material/ScaffoldMessengerState/showSnackBar.html): kullanıcı eyleminden gösterme, kuyruk davranışı, alt navigasyon üstünde floating konum.
- [clearSnackBars](https://api.flutter.dev/flutter/material/ScaffoldMessengerState/clearSnackBars.html): eski mesaj kuyruğunu temizleme.

## Test kapsamı

- Style Builder'daki araç var/yok × sekiz stil/ekstra/renk kombinasyonu.
- Detail Edit'te araç var/yok × açı boş/Front/Rear/Side.
- Custom Edit'te araç var/yok × null/boş/boşluk/tab-satır sonu/anlamlı metin.
- Araç önceliği, dört mesajın birebir metni, panel ön koşulunun araçtan bağımsızlığı.
- 320/390 genişlikte kırmızı bildirim ve alt navigasyonun üzerinde yerleşim.
- Klavye açıkken Custom Edit, iptal edilmiş taslak, yalnızca açıyla geçiş,
  yalnızca stil/ekstra/renkle geçiş, renk önce/parça sonra seçimi.
- Uyarıda cache yazılmaması, araç kaldırmada diğer seçimlerin korunması.
- Aynı frame içindeki tekrar basışlar, mod ve ana sekme değişiminde bildirim temizliği.

Önceki testlerde açı seçmeden renk/parça paneli açılması bekleniyordu; panel
testleri yeni ön koşulu sağlayacak şekilde güncellendi. Açı yokken boş parça
paneli bekleyen test artık panelin hiç açılmamasını ve kırmızı uyarıyı doğrular.

### Doğrulama sonucu

- `flutter test --reporter failures-only`: **201 test başarılı**.
- `flutter analyze`: **No issues found**.
- `git diff --check`: hata yok.
- Bu özelliğin doğrulayıcı dosyasında 38 saf kural testi; ekran dosyasında
  15 widget testi bulunur. Diğer mevcut açı, seçim, cache ve gezinme testleri
  de tüm paket çalıştırmasında geçti.
- Dört uyarı 320 ve 390 genişlikte gerçek font/ikonlarla render edildi;
  sekiz görüntü görsel olarak incelendi. Önizlemeler yerel, Git tarafından
  yok sayılan `.dart_tool/generate_previews/` dizinindedir.
- Görsel kontrol Flutter test ortamında yapıldı; Android emülatöründe çalışma
  iddiası yoktur. Galeri/kamera ve AI servis davranışı testin kapsamında değildir.
