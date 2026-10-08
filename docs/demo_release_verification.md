# Demo geçmişi ve stil seçimi — son doğrulama

Not tarihi: 9 Ekim 2026 (Europe/Istanbul). Kapsam: mevcut sahte servisli
Flutter uygulaması. Gerçek AI bağlantısı, sağlayıcı, backend veya yeni paket
eklenmedi. Bu tarih kayıt tarihidir; ekran görüntülerindeki cihaz saatleri
ayrıca bir fiziksel cihaz/platform doğrulaması sayılmaz.

## Gönderilen değişiklikler

- Üret'in Style Builder, Custom Edit ve Detail Edit modları, Explore ve
  AI Video kabul edilmiş başarılı demoları ortak yerel geçmişe ekler.
- Your Creations ve Garaj aynı kayıtları kullanır. Filtreler ve sayaçlar
  ortak listeden hesaplanır; video demoları görsel sayacına dahil edilmez.
- İptal, hata, zaman aşımı ve geç cevap kayıt oluşturmaz. Geçmiş sonucunu
  açmak/geri dönmek yeni üretim değildir. Ayrı başarılı işlemler, seçimleri
  aynı olsa bile ayrı kayıttır.
- Depolama hatası üretim hatasından ayrıdır. Okunamayan kayıtlar ezilmez;
  oturumdaki kayıtlar ve yeniden kaydetme seçeneği korunur.
- Stil → Uygula, karttaki örnek aracı ve stili birlikte günceller. Boş/dolu
  görsel ve aynı stili yeniden uygulama desteklenir. Taslağı kapatma iptal
  eder; ekstra/renk ve eski geçmiş kayıtları değişmez.

## Kullanıcının manuel sonuçları

| Kontrol | Gözlenen sonuç | Kanıt |
| --- | --- | --- |
| Stil seçimi | Uygula ile üst görsel artık güncelleniyor | Düzeltme sonrası kullanıcı teyidi; önceki emülatör kontrolü |
| Tam kapatma/yeniden açma | Garaj kayıtları, sayaçlar ve Your Creations korundu | Kullanıcı teyidi |
| Hazırlanırken Vazgeç | Yeni kayıt yok, sayaç değişmedi | Kullanıcı teyidi |
| Hata → Tekrar Dene → başarı | AI Video/Cliff Drive/Mustang GT için yalnız bir yeni video kaydı | Önce 4 Mody's / 1 video, sonra 4 / 2 ekran görüntüleri |
| Garaj detayı → Garaja Dön | Sayaç değişmedi | Kullanıcı teyidi |

Hata ekranı ile sonuç arasındaki kayıtsızlık tek başına bir Garaj ara
görüntüsüyle belgelenmedi; önce/sonra toplamı yalnız bir kayıt eklendiğini
gösterir. Hatanın kendisinin kayıt eklemediği ayrıca otomatik testle sınanır.
Önceki 2 → 3 Mody's artışı için kullanıcı arada bir görsel demo daha
oluşturduğunu teyit etti; bu bir video/görsel sınıflama hatası değildir.

## Otomatik doğrulamanın kapsamı

9 Ekim 2026'da bu sürüm üzerinde gönderimden önce yeniden çalıştırıldı:

| Kontrol | Sonuç |
| --- | --- |
| `flutter test --no-pub --reporter expanded` | 863 test başarılı |
| `flutter analyze --no-pub` | Hata/uyarı yok |
| `flutter build apk --debug --no-pub` | Android debug APK başarıyla derlendi |
| Değişen Dart dosyalarında `dart format --output=none --set-exit-if-changed` | 23 dosya, değişiklik gerekmiyor |
| `git diff --check` | Boşluk hatası yok |

Toplam, önceki 745 test + geçmiş için 91 + stil düzeltmesi için 27 testtir.
Bu son çalıştırmada uygulama kodu değiştirilmedi; mevcut özellikler ve testler
kontrol edildi, belgeler güncellendi. Yeni derleme emülatöre kurulmadı;
emülatör ve kullanıcı teyitleri yukarıda ayrı belirtilmiştir.

- `test/creation_history_test.dart` ve `test/creation_history_widget_test.dart`:
  91 test; JSON dönüşümü, ayrı cache anahtarı, bozuk/eski kayıt, okuma/yazma
  yarışları, iptal/hata/tekrar dene, ortak liste ve filtreler, detaydan dönüş,
  yeniden açılış ve kayıt hatasını üretim hatasından ayırma.
- `test/style_vehicle_selection_test.dart`: 27 test; altı stil için boş/dolu
  kaynak, tek state/cache güncellemesi, gerçek görsel yolu, Uygula/iptal,
  gönderilen istek, aynı stil ve kalıcı seçim.
- Önceki responsive ve üretim akışı testleri korunur; 320×568/390×844,
  1x/2x yazı ve kontrollü servisle geç cevap davranışı da test paketindedir.

## Sınırlar

- Manuel teyitler bütün modların tüm cihazlardaki test matrisi değildir.
  Fiziksel Android/iOS, TalkBack/VoiceOver, farklı klavyeler ve yönelimlerin
  tamamı doğrulanmış sayılmaz.
- Sonuçlar seçilen orijinal fotoğraflardır. Gerçek değiştirilmiş görsel,
  oynatılabilir video, fotoğraf içe aktarma veya bulut eşitleme yoktur.
- Demo kayıtları yereldir; uygulama verilerini silmek/kaldırmak geçmişi
  kaybettirebilir. Bu kontrol sırasında uygulama verileri silinmedi.
- Ham ekran görüntüleri, indirilen MP4'ler ve transkriptler repoya eklenmez.

## Tekrar çalıştırma

```sh
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --debug --no-pub
flutter run --dart-define=MODY_DEMO_FAIL_FIRST=true
```

Hata bayrağı her yeni düzenleyici servisinin ilk geçerli denemesini
başarısız yapar. İlk işlemi iptal etmeden bekleyip Tekrar Dene ile sürdürün.
Test bitince uygulamayı durdurup `flutter run` ile yeniden başlatın;
yalnız hot reload ile çalıştırma parametresi değişmez.

Öğretmenin yöntemlerinin hangi dosyalara uyarlandığı
[kaynak notunda](learning_sources.md); önceki sonuçlar
[geçmiş](creation_history.md), [stil](style_vehicle_selection.md) ve
[responsive doğrulama](pre_api_verification.md) notlarında tutulur.
