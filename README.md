# PeraSoft Staj

Bu proje, Mody AI uygulamasının ana ekranından esinlenilen bir Flutter arayüz
çalışmasıdır. Dart ve Flutter konuları staj süresince bu proje üzerinde
uygulanır.

## Django yerel backend — 9 Ekim 2026

Varsayılan veri kaynağı artık Django API. Backend kodu `backend/` içinde;
yerel geliştirme veritabanı `C:\capstone-main\modyai.db`. Asansör veritabanından
ayrıdır. Kataloglar, seçimler ve geçmiş API üzerinden okunup yazılır; demo AI
servisi değişmedi. Sunucu açık olmalı; gerçek hesap/üretim yayını eklenmedi.

```powershell
# Terminal 1 (açık kalsın)
.\backend\.venv\Scripts\python.exe backend/manage.py runserver 127.0.0.1:8765 --noreload
# Terminal 2
flutter run --dart-define-from-file=backend/flutter.local.json
```

Kurulum, API sözleşmesi, güvenlik sınırları, veri yönetimi ve yerel SQLite'a
bilinçli geri dönüş: [Django backend rehberi](docs/django_backend.md).
Yerel yapılandırma dosyaları anahtar içerir; Git'e eklenmez.

**959 Flutter testi + 15 API testi başarılı**, statik analiz temiz. Emülatörde
mevcut 7 kayıt, sunucuya seçim yazma, yeniden açılış ve backend kapalı → tekrar
dene akışı doğrulandı. İnternete yayınlanmış veya çok kullanıcılı bir servis değildir.

## Önceki adım: SQLite v2 — 9 Ekim 2026

Ekranlar artık SQLite'tan yüklenen katalogları kullanıyor. Araç/parça listeleri,
stil/renk/açı seçenekleri, Explore/AI Video kartları, kapaklar, seçim ayarları
ve geçmiş `modyai.db` içinde. SharedPreferences yalnız bir kerelik aktarım
kaynağı ve kurtarma kopyasıdır; üretim akışında yeni seçimler SQLite'a yazılır.

SQL ile yeni araba/spoiler ekleme örnekleri, PK/FK ilişkileri, görsel dosyası/URL
desteği ve sınırlar: [SQLite katalog rehberi](docs/sqlite_catalog.md).
Uygulamayı verilerini silmeden tamamen yeniden başlatın. Katalog oturum başında
yüklenir; yönetim ekranı ve bulut eşitleme eklenmedi.

**946 test başarılı**, statik analiz temiz, Android debug APK derlendi.
Emülatörde eski 6 kayıt ve seçimler korunarak v2'ye geçiş ve yeniden açılış
doğrulandı; sayaçlar 4 Mody’s + 2 video olarak kaldı.

## Önceki adım: SQLite yerel geçmiş v1 — 9 Ekim 2026

Garaj/Your Creations geçmişi `modyai.db` dosyasına taşındı. İlk açılışta
SharedPreferences'taki eski kayıtlar tek transaction ile içe alınır; eski
veri kurtarma kopyası olarak silinmez. Küçük form seçimleri SharedPreferences'ta
bu ilk adımda kalıyordu; v2 ile bunlar da SQLite'a taşındı.

`vehicles → creations → creation_parts` ilişkileri 1:N'dir; PK, FK, bileşik
anahtarlar ve güvenli taşıma ayrıntıları [SQLite şema notunda](docs/sqlite_history.md).
Yeni paket nedeniyle uygulamayı durdurup `flutter run` ile yeniden başlatın;
uygulama verilerini temizlemeyin. Gerçek AI veya bulut eşitleme eklenmedi.

**933 test başarılı**, statik analiz temiz, Android debug APK derlendi.
Bu geçişin gerçek cihazda eski kayıtlarla kontrolü henüz yapılmadı;
bağlı emülatör/telefon bulunmuyordu.

## Demo geçmişi ve stil seçimi — 9 Ekim 2026

Your Creations/Garaj geçmişi ve Stil → Uygula görsel düzeltmesi birlikte
doğrulandı. Stil kartını uygulamak artık hem stili hem karttaki örnek aracı
seçer; boş/dolu kaynakta çalışır. Paneli kapatma iptal eder, ekstra/renk korunur.

Kullanıcı yeniden açılışta geçmişin korunmasını, iptal edilen işlemde kayıt
eklenmemesini, hata → tekrar dene sonrasında yalnız bir video kaydı oluşmasını
ve Garaj detayından dönüşte sayaçların değişmemesini doğruladı. Ekran
görüntülerinde video denemesi öncesi 4 Mody's / 1 video, sonrası 4 / 2 görüldü.

9 Ekim gönderim öncesi kontrol: **863 test başarılı**, statik analiz temiz,
Android debug APK derlemesi başarılı. Değişen 23 Dart dosyası biçim
kontrolünden değişiklik gerektirmeden geçti.

- [Son doğrulama, kanıt türleri ve kapsam sınırları](docs/demo_release_verification.md)
- [Stil kartı → araç eşlemesi ve regresyon testleri](docs/style_vehicle_selection.md)
- [Ders/transkript/GitHub kaynaklarının kod karşılıkları](docs/learning_sources.md)

Gerçek AI, sunucu, galeri/kamera veya video oynatma eklenmedi. Aşağıdaki
test sayıları ve kapsam açıklamaları ilgili aşamaların tarihli kayıtlarıdır.

## Your Creations ve Garaj — 8 Ekim 2026

Üret'in üç modu, Explore ve AI Video'nun başarılı demo işlemleri ortak
geçmişe kaydedilir. Your Creations'tan orijinal araç yeniden seçilebilir;
Garaj listeleri, filtreleri ve profil sayaçları aynı kaynaktan güncellenir.
Geçmiş uygulama yeniden açılınca yüklenir. İptal/hata kaydedilmez;
sonuca tekrar bakmak yeni kayıt oluşturmaz. Video kartları oynatılabilir
video değil, açıkça işaretlenmiş video-demo kayıtlarıdır.

Temelden Zirveye #12'nin video/transkript/repo örnekleri kullanılarak
model–cache–arayüz ayrımı korundu; Hive veya başka paket eklenmedi.
[Davranış, kayıt/hata politikası, kaynak eşlemesi ve testler](docs/creation_history.md).

**836 test başarılı**, statik analiz temiz, Android debug APK derlendi.
Emülatörde üretim → Garaj ve uygulama yeniden açılışında kayıt kontrol edildi.

Çalıştırma: `flutter run`. Demo hata/tekrar deneme:
`flutter run --dart-define=MODY_DEMO_FAIL_FIRST=true`.

## AI API öncesi doğrulama — 8 Ekim 2026

Küçük ekran ve büyük yazıda seçim kutuları, alt menü, renk panelleri ve
işlem düğmelerinin taşma/erişim sorunları düzeltildi. Üret ve Garaj üst
alanları gerektiğinde kaydırılabilir. Seçimler, cache, açı–parça uyumu ve
Cubit/servis sorumlulukları korunur; gerçek AI API veya yeni paket eklenmedi.

**745 test başarılı**, statik analiz temiz, Android debug APK derlendi.
Android emülatöründe normal/büyük yazı ve sistem geri dönüşü için sınırlı
kontrol yapıldı; fiziksel cihaz doğrulaması tamamlanmış sayılmaz.

- [Hangi videodan, transkriptten ve GitHub örneğinden nasıl yararlandık?](docs/learning_sources.md)
- [Düzeltmeler, test kapsamı ve cihaz kontrolünün sınırları](docs/pre_api_verification.md)

Ana kaynaklar: Temelden Zirveye Flutter 4/5 (widget), 9 (servis), 18
(test edilebilirlik), 19 (Cubit); Mimari v2 8 (responsive), 11 (state),
13 (testler). Önceki dosya/tema adımlarında Mimari v2 2/6/9 da kullanıldı.
[Flutter-Full-Learn](https://github.com/VB10/Flutter-Full-Learn) ve
[architecture_template_v2](https://github.com/VB10/architecture_template_v2)
örneklerinden yöntem alındı; tüm paketler veya mimari olduğu gibi kopyalanmadı.
Alttaki bölümler önceki aşamaların tarihli kayıtlarıdır.

## Girdi–sonuç hazırlığı — 8 Ekim 2026

Mevcut seçimler sağlayıcıdan bağımsız `GenerationPlan` modeline çözümlenir:
araç/referans görselleri, açık parça kimlikleri ve ortak renk anlamları.
Eski cache biçimi, ekranlar ve açı–parça kuralları korunur. Sahte sonuç artık
açıkça `DemoGenerationResult`; video isteği gerçek video çıktısı sayılmaz.
Gerçek API JSON'u, yükleme, sunucu ve sağlayıcı yanıtı henüz eklenmedi.

99 yeni testle toplam 731 test başarılı; statik analiz temiz, debug APK derlendi.
Kaynakların uygulanışı, kapsam ve kalan sağlayıcı işleri:
[Girdi–sonuç sözleşmesi](docs/generation_contract.md).

## AI Video — sahte üretim akışı — 8 Ekim 2026

AI Video'nun mevcut 15 şablonu ortak sahte servise bağlandı. Video Oluştur
artık yüklenme, demo sonuç, hata/tekrar deneme ve vazgeçme akışını çalıştırır.
Kapaklar statik görsel kalır; gerçek video üretilmez veya oynatılmaz. Sonuç
seçilen orijinal araç fotoğrafını, AI Video kaynağını ve şablon adını gösterir.
Üret ve Explore davranışları, seçimler ve cache biçimi korunur.

632 test başarılı; analiz temiz, Android debug APK derlendi. Widget-test
önizlemeleri incelendi; bu aşamada canlı cihaz testi yapılmadı. Kaynakların
kod karşılıkları, kapsam ve elle deneme komutları:
[AI Video sahte servis notları](docs/ai_video_generation.md).
Alttaki bölümler önceki aşamaların tarihli kayıtlarıdır.

## Explore — ortak sahte üretim akışı — 7 Ekim 2026

Explore'daki 37 işlem artık Üret ile aynı sahte servis yaşam döngüsünü kullanır:
doğrulama, yüklenme, hata/tekrar deneme, vazgeçme ve demo sonuç. Sonuçta orijinal
araç fotoğrafı, işlem ve gönderilen hedef/renk/referans gösterilir; gerçek AI
üretimi yapılmaz. Üret'in Style Builder, Custom Edit ve Detail Edit akışları
korunur. AI Video bu genişletmeye dahil değildir; statik kapaklar ve mevcut
mock davranışı değişmez.

Seçim panelleri ve cache biçimi korunur; Explore'da yalnız üretim durumu Cubit
ile yönetilir. Yeni paket eklenmedi. Ders 4/5, 9/18/19 ve Mimari v2 11/13'ün
somut kod karşılıkları ve deneme adımları:
[Explore sahte servis notları](docs/explore_generation.md).

583 test başarılı, statik analiz temiz, Android debug APK derlendi. Görsel
kontrolün kapsamı bağlantılı notta bulunur. Alttaki bölümler önceki aşamaların tarihli
kayıtlarıdır; eski kapsam sınırları kendi tarihleri için geçerlidir.

## Mimari C — sahte üretim servisi — 6 Ekim 2026

Üret'in üç modunda yüklenme, hata/tekrar deneme, vazgeçme ve demo sonuç akışı
hazır. Sonuç mevcut araç fotoğrafını ve gönderilen seçimleri gösterir;
**AI ile üretilmediği açıkça belirtilir**. Uyarılar, Fikir Ver, açı-parça
eşleşmeleri ve cache biçimi korunur. Diğer ekranlara servis/Cubit taşınmadı.

9, 18 ve 19. derslerin zamanları, öğretmenin repo kodları, uyarlama kararları
ve deneme komutları: [Mimari C notları](docs/architecture_stage_c.md).
510 test başarılı, analiz temiz, Android debug APK derlendi. Emülatörün
Android servis hatası nedeniyle canlı yükleme/açılış doğrulanamadı.

Normal demo başarılıdır. Kontrollü hata ve tekrar deneme için
`flutter run --dart-define=MODY_DEMO_FAIL_FIRST=true` kullanılabilir.
Alttaki bölümler önceki aşamaların tarihli kayıtlarıdır.

## Mimari B — Üret ekranında Cubit pilotu — 6 Ekim 2026

Yalnızca Üret'in onaylanmış seçimleri, Fikir Ver ve doğrulama kararları
GenerateCubit/GenerateState'e taşındı. Controller'lar ve panel taslakları
görünümde kaldı; Explore, AI Video ve Garaj Cubit'e geçirilmedi. Ekran tasarımı,
uyarı metinleri, açı-parça eşleşmeleri ve mevcut kayıt biçimi korunur.

Mimari v2 ders 11 ve 13'teki yöntemlerin repo karşılıkları, sahiplik ve test
ayrıntıları: [Mimari B notları](docs/architecture_stage_b.md).
473 test başarılı, analiz temiz, Android debug APK derlendi. Bağlı cihaz
olmadığından canlı emülatör testi yapılmadı. Yeni paketler nedeniyle uygulamayı
durdurup yeniden çalıştırın.
Alttaki bölümler önceki aşamaların tarihli kayıtlarıdır.

## Mimari A — dosya ve tema düzenlemesi — 5 Ekim 2026

Mevcut ekranlar `lib/feature` altında sorumluluklarına göre düzenlendi;
ortak katalog, model, doğrulama, widget ve kayıt kodları `lib/product` altında
gruplandı. Explore ve AI Video'nun ortak detay ekranı `feature/editor`
altındadır. Üret görünümünün alt bileşenleri ayrı widget dosyalarına çıkarıldı.
Tema `product/init/theme/mody_theme.dart` içine alındı; tasarım ve davranışlar
değiştirilmedi. Yeni paket, AI API veya Cubit eklenmedi; kayıt biçimi korunur.

Kullanılan Mimari v2 dersleri (2, 6, 8, 9, 13), öğretmenin repo karşılıkları,
yerleşim kuralları ve doğrulama: [Mimari A notları](docs/architecture_stage_a.md).
Bu aşamanın sonucu: 428 test başarılı, analiz temiz, Android debug APK derlendi.
Emülatör kapalı olduğundan bu aşamada canlı cihaz testi yapılmadı.
Alttaki tarihli bölümler önceki geliştirme aşamalarının kayıtlarıdır.

## Fikir Ver ve metin önerileri — 5 Ekim 2026

Fikir Ver artık Style Builder'da mevcut katalogdan araç + stil + ekstra + renk,
Custom Edit'te yalnızca araç, Detail Edit'te araç + açı + o açıya uygun tek parça
+ renk seçer. Detail parça havuzu seçilen açıyla sınırlıdır; önceki parçalar
taşınmaz. Custom Edit'in sihirli ikonu araç olmadan da yerel İngilizce açıklama
önerir; metin düzenlenebilir ve çarpıyla temizlenebilir. Öneriler üretimi
başlatmaz; mevcut uyarılar ve kayıt kuralları korunur.

Üret'teki soru işareti ve Canlı Edit kaldırıldı. Gerçek fotoğraf yükleme
eklenmedi; AI Video kapakları statik görsel kalır. Öğretmenin örnekleri,
uyarlama kararları ve test kapsamı: [Fikir Ver notları](docs/generate_ideas.md).
Alttaki eski tarihli yer tutucu açıklamaları önceki kilometre taşlarını anlatır.
Son doğrulama: 422 test başarılı, `flutter analyze` temiz; 12 gerçek fontlu
önizleme test ortamında incelendi. Bu turda telefon/emülatör testi yapılmadı.

## Detail Edit: açıya göre Ayarla — 4 Ekim 2026

Front 3, Rear 4, Side 7 kategori gösterir. Dokuz ortak kategori üçer parça
fotoğrafı kullanır; on yeni kaynaklı fotoğraf eklenmiştir. Kategoriler dikey,
fotoğraflar yatay kaydırılır. Farklı bir açı onaylanınca parçalar sıfırlanır,
renk korunur; aynı açıyı onaylama ve iptal seçimleri silmez. Araç kaldırma
diğer seçimleri etkilemez. Yeni kategoriler de kalıcı kayda dahildir.
Üret düğmesi doğrulaması/uyarıları bu adımda değiştirilmemiştir.
Öğretim kaynakları, ürün kuralları ve test kapsamı:
[Detail Edit notları](docs/detail_angle_parts.md).

## Mock UI v1 — 30 Eylül 2026

İlk mock frontend kilometre taşıdır; gerçek medya veya AI üretimi içeren
tamamlanmış bir ürün sürümü değildir. Dört ana ekran, detay navigasyonu,
Uygula/iptal akışları, kalıcı seçim kaydı, form doğrulama, ortak seçim paneli
ve ortak işlem butonu bu kapsamda tamamlanmıştır.

Son kontrol: Android emülatöründe dört ana ekranın görsel turu yapıldı;
`flutter analyze` temiz, `flutter test` sonucu 51 test başarılıdır.
Testler seçimlerin uygulanması/iptali, navigasyon, cache, dar ekranlar,
klavye ve ortak bileşen davranışlarını kapsar.

Üret'teki fotoğraf alanı, Fikir Ver ve Canlı Edit ile Garaj profil düzenleme
ve menü kontrolleri yer tutucudur. Galeri/kamera, gerçek görseller, servis
bağlantısı, üretim sonuçları ve yüklenme/hata/yeniden deneme akışları bu
kilometre taşının kapsamı dışındadır.

## Yerel araç ve parça görselleri

Üret ekranındaki beş örnek araç ile Style Builder'ın altı Stil ve altı Ekstra
seçeneği, `assets/images/` içindeki 12 yerel fotoğrafı kullanır. Beş örnek araç
Stil görsellerini yeniden kullanır; yeni seçenek eklenmez. Örnek araçlar bu
aşamada yalnızca önizlemedir; fotoğraf seçme/üretime gönderme henüz bağlı değildir.
Galeri, kamera, Firebase ve AI bağlantısı eklenmemiştir.

VB10 #4'teki `lib/101/image_learn.dart` (`6b43107`) içindeki `ImageItems` ve
`PngImage` yaklaşımı esas alınmıştır: yollar `ImageItems` içinde merkezileştirilir,
`ModyAssetImage` parametre alan bir StatelessWidget ile Image.asset gösterir.
#4.2 ve #5'teki ortak bileşen yaklaşımı korunur. Görseller bozulursa alternatif
ikon gösterilir; contain kullanımı araç/parçanın kırpılmasını önler.
Stil/Ekstra Uygula, iptal ve cache davranışları değişmemiştir; diğer ekranların
mock görselleri kapsam dışıdır. Üret modları ortak Örnek Arabalar widget'ını kullanır.

Detail Edit de aynı yapıyı kullanır: Front/Rear/Side için üç fotoğraf,
Spoiler/Exhaust/Rear Bumper & Diffuser/Tail Lights için üçer parça önizlemesi.
14 yeni dosya eklenmiştir; mevcut spoiler görseli yeniden kullanıldığı için
toplam 26 benzersiz yerel fotoğraf vardır. Açı görselleri temsili örneklerdir;
üçü aynı aracın farklı çekimleri değildir. Seçenek adları ve kayıt indeksleri
değişmez; Uygula/iptal/cache davranışı korunur. Parça listesi kaydırılırken
Uygula sabit kalır. Renk paneli değişmez.

Bu genişletmede #4 transkriptinin 53–59. dakika aralığındaki yol yönetimi ve
ortak görsel widget'ı ile #5'in 44–45 ve 50–51. dakikalarındaki parametreli
bileşen/sorumluluk ayrımı esas alınmıştır. Repo karşılıkları:
[image_learn.dart](https://github.com/VB10/Flutter-Full-Learn/blob/6b43107/lib/101/image_learn.dart)
ve [random_image.dart](https://github.com/VB10/Flutter-Full-Learn/blob/afee901/lib/core/random_image.dart).
Öğretmenin örnekleri projeye uyarlanır; ekranlara dosya yolları dağıtılmaz,
gereksiz state veya yeni paket eklenmez.

Kaynak ve lisanslar `assets/IMAGE_CREDITS.txt` içinde korunur. Üret ekranındaki
Örnek Arabalar bilgi düğmesi ve açtığı kaynak penceresi kaldırılmıştır.

## Mevcut kapsam

- Üret, Explore, AI Video ve Garaj ekranları ortak navigasyonla bağlıdır.
- Style Builder, Custom Edit ve Detail Edit modları bulunur.
- Üst sekmeler ve yatay kaydırma aynı `PageView` üzerinde senkronize çalışır.
- Stil, Ekstra, Açı, Ayarla ve Renk panelleri kullanıcı etkileşimiyle açılır.
- Renk kategorileri seçildiğinde örnek renk başlıkları güncellenir.
- Style Builder'da Stil, Ekstra ve Renk seçimleri yalnızca Uygula ile kaydedilir;
  uygulanmadan kapatılan
  paneldeki değişiklik atılır. Seçimler panel kapanınca ve üst modlar arasında
  geçişte korunur. Style Builder ve Detail Edit'te onaylanan seçimler
  cihazda saklanır ve uygulama yeniden açıldığında yüklenir.
- Custom Edit alanı ortak `ModyTextFormField`, `Form` ve
  `TextEditingController` ile açıklama alır ve boş girişleri doğrular.
- `PageController` ve `TextEditingController`, `initState` içinde hazırlanır ve
  `dispose` içinde temizlenir.
- Yapay zekâ veya başka bir API bağlantısı henüz yoktur.
- Üret'te örnek arabalar yerel fotoğraflardır; diğer medya alanları mock kalır.
- Hedef görünüm 390 x 844 boyutundaki telefon portresidir.

## Explore önizlemesi

Üret ve Explore/AI Video detayları ortak `SampleCarsArea` bileşeniyle aynı beş
yerel araç fotoğrafını gösterir. Liste yatay kayar; callback yalnızca ilgili
ekranın mevcut seçim akışını açar. Yeni global seçim state'i veya API eklenmez.
#5 transkript 44:08–44:35 ortak bileşen tavsiyesi, #4 merkezi görsel yolları ve
#7 ListView.separated yaklaşımı uygulanmıştır. Sonraki kullanıcı onayıyla kapak
başlığı ortak `DetailCoverHeader` bileşenine taşınmıştır: `Stack` içinde kapak,
yan/alt siyah `LinearGradient` katmanları, başlık ve geri düğmesi bulunur.
Bu fade uygulaması eğitimden birebir alınmamıştır; Flutter'ın resmî Stack
örneğindeki yaklaşım kullanılmıştır. Fotoğraflar değişmez, kapakta BoxFit.cover
kullanılır. Dekoratif katmanlar IgnorePointer ile etkileşimi engellemez.

Güncel: Explore'un 20 kartının mevcut kapak görseli, açılan detay ekranının
üstünde de gösterilir. Görsel yolu detay ekranına parametre olarak aktarılır;
aynı `ModyAssetImage` bileşeni kullanılır. Yeni görsel veya paket eklenmez.
Resim Seçin paneli, alt seçenekler ve kayıt davranışı değişmez. Henüz kapağı
olmayan AI Video detayları önceki yer tutucuyu kullanmaya devam eder.

Explore sekmesi seçili olarak uygulama açılabilir:

```sh
flutter run -t lib/main_explore.dart
```

Normal `flutter run` komutu Üret ekranını açmaya devam eder.
Explore içinde Car Mods, Style Builder, Wallpaper Maker ve AI Edits bölümleri
beşer yerel kapak görselli seçenek içerir. Ana içerik dikey; Style Builder ve Wallpaper
Maker sıraları yatay kaydırılır. Kartlar Navigator ile detay ekranını açar;
alt çubuk dört ana bölüm arasında geçiş yapar.
Görsellerde yalnızca dört seçenek görünen iki yatay bölüme geçici olarak
Racing ve Night City isimleri eklenmiştir.

Explore görselleri yalnızca ana listedeki 20 karta bağlıdır. Detay ekranı üst
alanı, Resim Seçin paneli, örnek araçlar ve Rim/Neon gibi alt seçenekler bu
değişiklikte mock kalır. 10 yeni fotoğraf ve mevcut katalogdan 10 fotoğraf
kullanılır (proje toplamı 36 benzersiz fotoğraf). Bunlar orijinal uygulamanın
birebir görselleri veya AI çıktıları değil, temsili kapaklardır; Dream Car & Me
kapak görseli yalnızca spor araç gösterir, kullanıcı portresi içermez.

#4 `ImageItems`/`Image.asset`, #5 parametreli StatelessWidget ve #7 liste/kart
yaklaşımı korunur. `MockOptionCard` isteğe bağlı `imagePath` alır;
`HorizontalMockOptions` görsel eşlemesini dışarıdan alır. Görsel verilmezse
eski mock içerik değişmeden gösterilir; AI Video ve seçim panelleri etkilenmez.
Kapak yolları `ImageItems.exploreCovers` içindedir. Fotoğraflar kırpılmadan
gösterilir ve başlık için ayrı alan bırakılır. Yeni paket veya state eklenmez.

### Car Mods alt seçenek görselleri

Sonraki adımda yalnızca Rim/Suspension/Neon/Tire 1–5 kartlarına görseller
eklenmiştir. 15 yeni dosya ve 5 mevcut görsel kullanılır; toplam katalog 51
benzersiz görseldir. Bunlar temsili önizlemelerdir; Neon örnekleri aynı aracın
beş renk varyantı değil, farklı ışık sahneleri ve bir illüstrasyondur.
Detayın üst görseli, Resim Seçin, örnek araçlar ve renk paneli değişmemiştir.
Style Builder/Wallpaper Maker/AI Edits detaylarına yeni seçenek eklenmez.

#4 yol yönetimi (`image_learn.dart`), #5 parametreli ortak bileşen
(`random_image.dart`, transkript 44:08–44:35), #13 panelden sonuç döndürme
(`sheet_learn.dart`, transkript 16:48–17:25) ve #12 cache sorumluluk ayrımı
esas alınır. `ImageItems.carModOptions` görsel eşlemesini tutar; panel bunu
dışarıdan alıp mevcut ortak karta iletir. Cache'e dosya yolu yazılmaz,
seçenek adları değişmez. Uygulanmayan taslaklar yine iptal edilir.

### Anlamlı seçenek kataloğu (güncel)

Numaralı Car Mods adları artık UI'da kullanılmaz. `CarModCatalog` her seçenek
için sabit `id`, görünen `label`, görsel ve İngilizce `instruction` tutar.
Örneğin `tire.whitewall` → Beyaz Yanak → yalnızca lastiğin yanak bandını beyaz
yapma açıklaması. Görünen ad/asset yolu API talimatı yerine kullanılmamalıdır.
Bu açıklamalar gelecekteki entegrasyon için hazırlanmıştır; henüz API'ye
gönderilmez ve model sonucunun doğruluğu garanti edilmez. Lastik deseninin
görünürlüğü giriş fotoğrafının açısına bağlıdır.

Jant, lastik ve süspansiyon seçenekleri fotoğraftaki özelliği adlandırır.
Neonlar aynı gerçek araç fotoğrafı üzerinde mor/turkuaz/yeşil/kırmızı/çok renkli
alt ışık gösterir. Kırmızı orijinal fotoğraftır; diğer dört varyantın alt ışığı
yerleşik görsel düzenleme aracıyla değiştirilmiştir. Bunlar düzenlenmiş fotoğraf
önizlemeleridir, uygulamanın ürettiği AI sonuçları değildir. Tüm seçenekler ortak
`ModyAssetImage` bileşenini kullanır; çizim bileşeni kaldırılmıştır. Kaynak, lisans
ve düzenleme istemleri [NEON_PHOTO_EDITS.md](assets/NEON_PHOTO_EDITS.md) içindedir.
Eski karma neon dosyaları ve lisansları korunmuştur. Aktif katalog 52 görseldir.

Cache artık Car Mods için sabit kimlik saklar. Eski Rim/Suspension/Tire 1–5
değerleri görselin anlamına göre yeni kimliklere çevrilir. Eski Neon 1–5'in
tekil renk karşılığı olmadığı için seçim boşaltılır; kullanıcı yeniden seçer.
Geçersiz veya başka gruba ait kimlikler kabul edilmez. Renk, mock resim,
ana kapaklar ve diğer ekranlar değişmez; Uygula/iptal akışı korunur.

Kaynak: VB10/Flutter-Full-Learn reposunun #7 aşamasındaki `47ba0f3` sürümü.
`list_view_learn.dart` içindeki dikey/yatay liste ve sınırlı yükseklik yaklaşımı,
`list_view_builder.dart` içindeki `ListView.separated` ve
`stateless_learn.dart` içindeki ortak widget yaklaşımı kullanılmıştır.
Başlık ve alt çubuk iki ekranda ortak widget'lardır; yeni paket eklenmemiştir.

## AI Video önizlemesi

```sh
flutter run -t lib/main_ai_video.dart
```

AI Video Transformations ve AI Drive Scenes yatay kaydırılan beşer seçenek
içerir. AI Video Filters iki sütunda beş seçenek gösterir. 15 kart, mevcut
yerel fotoğrafları geçici kapak olarak yeniden kullanır. Bunlar gerçek video
kareleri değildir; Cliff Fly/Snow Drift gibi efektleri birebir temsil etmez.
Görsel eşlemeleri `ImageItems.aiVideoCovers` içindedir; kart ve detay aynı yolu
kullanır. Detayda ortak fade başlığı, Örnek Arabalar ve Resim Seçin paneli vardır.
Uygula/iptal ve kart bazlı cache değişmez. Yeni seçenek, dosya, paket, video
oynatıcı veya API bağlantısı eklenmemiştir. Kullanıcının resim seçimi mock kalır.
#4 transkript 54:51–57:59 (parametreli görsel bileşeni / image_learn.dart) ve
#5 44:08–44:35 (ortak bileşen / random_image.dart) yaklaşımı korunur. Fade,
önceden onaylanan resmî Flutter örneğine dayalı ortak bileşenden gelir.
İlk iki bölümün görselde görünmeyen son ikişer adı geçici mock isimlerdir.

## Garaj önizlemesi

```sh
flutter run -t lib/main_garage.dart
```

Mock profil çemberi, kullanıcı adı ve sıfır sayaçları bulunur.
Tümü, Mody's ve Videolar sekmeleri tıklama veya PageView kaydırmasıyla
değişir. Seçili sekmenin alt çizgisi güncellenir. Gerçek kayıt veya medya yoktur.
Profil düzenleme ve menü yalnızca görseldir. Arka plan siyahtır; reklam bannerı yoktur.
Alt çubuktan ekran geçişi bağlıdır; Garaj'ın seçili iç sekmesi korunur.

## Navigasyon

`flutter run` dört bölümün bağlı olduğu uygulamayı Üret sekmesinden açar.
Alternatif giriş dosyaları aynı uygulamayı ilgili sekme seçili başlatır.
`MainTabsView`, enum ve TabController ile ana sekmeleri yönetir. Ana bölümler
arasında yatay kaydırma kapalıdır; Üret ve Garaj içindeki PageView davranışı korunur.
Keep-alive sarmalayıcı seçimleri ve ekran durumlarını uygulama açıkken korur.
Controller dispose edilir; yeni paket eklenmemiştir.

Explore ve AI Video detayları ortak `openPage` yardımcısı üzerinden
Navigator.push/MaterialPageRoute ile açılır. Geri oku veya telefonun geri tuşu
detayı kapatır; seçim paneli açıkken geri tuşu önce paneli kapatır.
Resim ve seçenekler yalnızca Uygula ile üst ekrana kaydedilir. Uygulanmayan
taslak atılır. Onaylanan seçimler kart bazında cihazda saklanır.

Kaynak örnekler: VB10/Flutter-Full-Learn `47ba0f3` sürümündeki
`lib/101/navigation_learn.dart` ve `5252a21` sürümündeki `lib/202/tab_learn.dart`.

## Kalıcı seçim kaydı

Eğitmenin #12 cache yaklaşımındaki sorumluluk ayrımı kullanılır:
`SharedManager` cihazdaki anahtar/değer kaydını, `SelectionCacheManager`
JSON dönüşümünü ve kayıt sırasını yönetir. Seçimler model sınıflarının
`toJson` / `fromJson` metotlarıyla dönüştürülür; ekranlar depolamaya doğrudan erişmez.

Kaynak: [VB10 cache örneği](https://github.com/VB10/Flutter-Full-Learn/tree/3a6fdda/lib/202/cache),
özellikle `shared_manager.dart` ve `user_cache/user_cache_manager.dart`.
Eski örnekteki `SharedPreferences.getInstance()` yerine yeni projeler için
önerilen `SharedPreferencesAsync` kullanılır (`shared_preferences` paketi).

Üret'in stil, ekstra, renk, açı ve parça seçimleri; Explore ve AI Video'nun
kart bazındaki onaylı mock resim/seçenekleri saklanır. Uygula'ya basılmayan
taslaklar saklanmaz. Tüm giriş dosyaları aynı kayıt yükleme yolunu kullanır.
Hızlı ardışık kayıtlar sırayla işlenir. Bozuk kayıt veya okuma hatasında
varsayılanlarla devam edilir ve uyarı gösterilir; yazma hatasında oturumdaki
seçimler korunur ve kullanıcı uyarılır. Geçersiz alanlar varsayılana döner.

Custom Edit metni, aktif sekme, kaydırma konumu ve gerçek medya kalıcı değildir.
Bu katman hassas veriler veya büyük medya dosyaları için kullanılmaz.
Yeni eklenti nedeniyle ilk çalıştırmada uygulamayı durdurup `flutter run`
ile yeniden başlatın; yalnızca hot reload yeterli değildir.

## Form doğrulama ve ortak metin alanı

#10'daki özel TextField bileşeni ve #11'deki Form yaklaşımı temel alınmıştır.
Repo örnekleri: `lib/demos/password_text_field.dart` ve
`lib/202/form_learn_view.dart` (VB10/Flutter-Full-Learn).
Parola alanı kopyalanmaz; controller'ın ekranda tutulması ve özel alanın
ayrı widget olması yaklaşımı çok satırlı açıklama alanına uyarlanır.

Custom Edit, `GlobalKey<FormState>` üzerinden `validate()` çağırır.
`FormValidator` boş veya sadece boşluk içeren açıklamayı reddeder.
`AutovalidateMode.onUserInteraction` sayesinde ilk açılışta hata gösterilmez;
kullanıcı girişini düzelttikçe hata güncellenir. Yeni satır girişi desteklenir,
alan dışına dokununca veya gönderince klavye kapanır.

Style Builder için Stil/Ekstra/Renk; Detail Edit için Açı/en az bir parça/Renk
onayları kontrol edilir. Taslaklar geçerli seçim sayılmaz. Geçerli girişte
yalnızca mock bilgilendirme mesajı gösterilir; gerçek üretim başlatılmaz.
Fotoğraf alanı bu aşamada yer tutucu olduğundan fotoğraf zorunluluğu yoktur.
Klavye açıkken üst görsel alanı küçülür, mod içerikleri dikey kaydırılabilir.
Custom Edit metninin kalıcı kayıt kapsamı değişmemiştir.

## Ortak seçim paneli

#13'ün [sheet örneği](https://github.com/VB10/Flutter-Full-Learn/blob/3f84b1a/lib/202/sheet_learn.dart)
temel alınır: `showModalBottomSheet<T>` paneli açar, `Navigator.pop<T>`
Uygula ile onaylanan değeri döndürür. `selection_sheet.dart` açılışı, geçici
seçimi ve ortak başlığı yönetir. Ekran, sonucu bekleyip yalnızca null olmayan
onaylı sonucu kendi state'ine ve mevcut cache callback'ine aktarır.

Stil, Ekstra, Renk, Açı, Ayarla ve Explore/AI Video mock seçimleri aynı modal
yapıyı kullanır. Panel açıkken arka ekran ve alt sekmeler etkileşime kapalıdır.
Çarpı, sistem geri tuşu, dışarı dokunma veya başlıktan aşağı sürükleme iptaldir:
taslak kaydedilmez. Uygula düğmeleri sabit kalırken listeler/grid içerikleri
kaydırılabilir. SafeArea korunur. Eski Stack üstü paneller kaldırılmıştır;
yeni paket, seçenek veya gerçek görsel seçimi eklenmemiştir.

## Ortak işlem butonu

#14'teki `answer_button.dart` ve `laoding_button.dart` örneklerinin
parametre/callback yaklaşımı kullanılır. `ModyActionButton` başlığı, isteğe
bağlı ikonu, görünümü ve `onPressed` callback'ini dışarıdan alır; null callback
butonu pasif yapar. Üret'in gradyanı, mavi işlem/Uygula butonları ve rim gibi
mock seçeneklerin mevcut tema görünümü korunur. Sekme ve kart butonları bu
bileşene dönüştürülmez.

Doğrulama, seçim onayı ve cache işlemleri ekranlarda kalır. Butonda yerel
durum gerekmediği için StatelessWidget kullanılır; eğitimdeki yüklenme
örneği bu aşamada eklenmez. Yeni paket veya gerçek üretim bağlantısı yoktur.

## Üret uyarıları — 4 Ekim 2026

Üret ekranındaki eksik bilgi kontrolleri kırmızı alt bildirimle gösterilir:
Style Builder araç + stil/ekstra/renkten herhangi biri; Custom Edit araç +
boş olmayan metin; Detail Edit yalnızca araç + açı ister. Parçalar ve renk
Detail Edit'te opsiyoneldir. Açı seçmeden Ayarla/Renk paneli açılmaz.
Üretime basıldığında eksik araç kontrolü her modda önceliklidir.

#11'deki ayrı validator/merkezi mesaj, #13'teki uygun bildirim bileşeni ve
#18'deki test edilebilir kod yaklaşımı uyarlanmıştır. Kontrol mantığı artık
`GenerateValidator` içindedir; ekran yalnızca eylemi bağlar ve sonucu gösterir.
Custom Edit'te aynı hata ayrıca metin alanının altında tekrarlanmaz.
Önceki Form/doğrulama bölümündeki bütün seçimleri zorunlu tutan davranışın
yerine bu kurallar geçer. Geçerli giriş hâlâ mock bilgi mesajıyla sonuçlanır.

Ayrıntılı kaynak-zaman eşlemesi, öğretmenin vurguları ile uygulamaya özel
kararların ayrımı ve test kapsamı: [Üret uyarıları](docs/generate_warnings.md).

## Explore ve AI Video uyarıları — 4 Ekim 2026

Explore ve AI Video kartlarında eksik seçim artık üretim butonunu pasifleştirmez;
basıldığında ilk eksik alanın kırmızı uyarısı seçim kartlarının üzerinde çıkar.
Car Mods araç + seçenek, Change Color araç + renk, Clone araç + referans ister.
Tek görselli Explore ve AI Video kartlarında araç yeterlidir. Clone'ın orijinal
İngilizce mesajları korunur. Üret ekranının çalışan kuralları değişmemiştir.

`ExploreValidator` ve merkezi mesajlar #11'in; ayrı bildirim sunumu ve yaşam
döngüsü #13'ün; 38 saf doğrulama ve 92 widget testi #18'in ilgili yaklaşımını
uyarlar. Bildirim seçim/cache değiştirmez; Apply/iptal ayrımı korunur.

Kapsam 37 Explore + 15 AI Video kartının tamamıdır. Neon/Tire ve Change Color
dışındaki 13 Car Mods için, kullanıcının açık isteğiyle Neon/Tire'ın araç +
hedef görsel kuralı genellenmiştir. Bu kartlarda aynı davranışın orijinal
uygulamada tek tek teyit edildiği iddia edilmez; kullanıcı onaylı varsayımdır.

Tüm paket: **331 test başarılı**, statik analiz temiz. Kaynak zamanları,
kanıt sınırları, 16 görsel kontrol ve uygulamaya özel tercihler:
[Explore ve AI Video uyarıları](docs/explore_warnings.md).

## Henüz kapsamda olmayanlar

- Gerçek AI/ağ servisi bağlantısı (yerel sahte servis hazırdır)
- Kullanıcının kendi araç fotoğrafını yüklemesi ve gerçek üretim sonuçları

Bu konular sonraki entegrasyon aşamalarında ayrıca değerlendirilecektir.

## Çalıştırma

```sh
flutter pub get
flutter run
```

## Kontrol

```sh
flutter analyze
flutter test
```
