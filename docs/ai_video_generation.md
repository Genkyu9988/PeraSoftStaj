# AI Video — sahte servis ve demo sonuç

Tarih: 8 Ekim 2026.

## Kapsam

Mevcut 15 şablon bağlandı: 5 transformation, 5 drive scene, 5 filter.
Yeni seçenek veya medya eklenmedi. Katalogdaki geçici örnek isimler de
değiştirilmedi; bu şablonların gerçekte uygulanabildiği iddia edilmez.

Araç seç → Video Oluştur → yaklaşık 1,5 saniyelik demo yüklenmesi → demo sonuç.
Sonuçta **orijinal araç fotoğrafı**, **Kaynak: AI Video**, **Şablon** ve **Araç**
gösterilir. Açıklama açıkça şablonun uygulanmadığını ve gerçek video
üretilmediğini söyler. Video oynatıcı, video dosyası, gerçek AI isteği veya
ücretli işlem yoktur. Kapaklar statik fotoğraf olarak kalır.

## Davranışlar

- Mevcut araç-gerekli uyarısı korunur; eksik/geçersiz araç veya bilinmeyen
  şablon servise gönderilmez. Renk/jant/referans gibi ikinci girdi istenmez.
- Gönderilen veri yalnızca `vehicleId` ve `AiVideoTemplate` taşır. Eski
  Explore seçenekleri videonun isteğine sızmaz. İstek değişmezdir.
- Yüklenirken gönderme düğmesi, form dokunmaları ve odak engellenir.
  Cubit ayrıca çift gönderimi önler.
- Hata → Tekrar Dene aynı istek nesnesini kullanır. Seçimlere Dön, formu
  değiştirmeden serbest bırakır; kullanıcı başka araçla yeni istek yapabilir.
- Vazgeç sonrası geç gelen başarı/hata yok sayılır. Sonuç sayfası açılmaz;
  eski cevap daha yeni isteğin durumunu değiştiremez.
- Detaydan geri çıkıldığında Cubit kapanır; geç yanıt sayfa açmaz.
- Başka sayfa detayın üzerindeyken sonuç o sayfanın önüne geçmez. Detaya
  dönünce Demo Sonucunu Gör ile açılabilir; sonuç bir kez tüketilir.
- Sonuçtan dönüşte araç seçimi korunur. Demo durumu ve sonucu cache'e
  yazılmaz; üretim geçişleri `onApplied` çağırmaz.
- Ortak 20 saniyelik süre sınırı ve güvenli hata mesajları korunur.

İptal, yerel asenkron cevabı geçersiz kılmaktır. Gerçek bir sunucu işini
iptal etme ya da harcanan krediyi geri alma garantisi değildir.

## Kodlama mantığı ve dosyalar

| Dosya | Sorumluluk |
| --- | --- |
| `product/model/ai_video_template.dart` | 15 mevcut başlık için sabit, tipli şablon kimlikleri. Cache başlıkları değişmez. |
| `product/model/generation_request.dart` | Ayrı `AiVideoGenerationRequest`; Üret veya Explore isteği gibi davranmaz. |
| `feature/ai_video/view_model/ai_video_generation_cubit.dart` | Video girdisini doğrular, uygun isteği kurar. Context, navigator veya depolama bilmez. |
| `feature/editor/view_model/editor_generation_cubit.dart` | Aynı detay görünümünün Explore/AI Video için kullanabildiği küçük ortak `submit` sözleşmesi. |
| `feature/generation/view_model/generation_flow_cubit.dart` | Önceden çalışan ortak asenkron yaşam döngüsü. Bu adımda kopyalanmadı veya değiştirilmedi. |
| `feature/editor/view/explore_detail_view.dart` | Ekran türüne uygun Cubit'i oluşturur/kapatır; ortak panel ve listener bağlantısını kullanır. Form/sheet/timer sahipliği ekranda kalır. |
| `feature/ai_video/view/ai_video_view.dart` | Testte verilen servisi detay ekranına iletir; verilmezse detay kendi demo servisini oluşturur. |
| `feature/generation/view/generation_result_view.dart` | İstek türlerini exhaustive switch ile ele alır; yeni tür unutulursa derleyici uyarır. Video açıklaması ve özeti ayrı, görünüm ortak. |

`GenerationService` ve `FakeGenerationService` yeniden yazılmadı. Mevcut
sözleşme yeni isteği de taşır. Sahte sonuç hâlâ yerel fotoğraf içindir;
gelecekteki gerçek video sağlayıcısının iş kimliği, sorgulama, medya ve hata
cevapları ayrıca modellenmelidir. Gerçek entegrasyon tek satırlık bir
değişiklik olarak sunulmaz.

Bu, tüm uygulamanın state yönetimini değiştirme adımı değildir. Explore'un
üretim Cubit'i ortak editor sözleşmesine uyarlandı; Üret'in seçim mantığı,
Front/Rear/Side parça ilişkileri ve Fikir Ver kuralları değişmedi. Yeni paket,
GetIt/Vexana/Hive/router altyapısı, kamera/galeri veya rehber eklenmedi.

## Öğretmenin tavsiyeleri: kaynak ve somut uygulama

Gönderilen transkriptlerin ilgili bölümleri tekrar okundu; önceden yerel
MP4'lerden çıkarılmış kod kareleriyle karşılaştırıldı. Bu çalışmada özellikle
18. ders 42:40, 19. ders 72:20 ve Mimari v2 13. ders 47:55 kareleri tekrar
incelendi. Bu, bütün videoların kesintisiz sesli izlendiği iddiası değildir.

| Kaynak | Öğretmenin vurgusu | Projedeki karar |
| --- | --- | --- |
| Temelden Zirveye #4, 14:44–14:53; #5, 44:08–44:35 | Karmaşıklık arttığında parçalama, parametre alan ortak bileşenler | Video için ikinci bir yüklenme/hata ekranı kopyalamadık; `GenerationPanel` ve sonuç görünümü paylaşılıyor. |
| [#9](https://www.youtube.com/watch?v=laSlXorExj4), 80–82. dakika | Servis çağrısı, await, hata geldiğinde ekranın davranışını düşünme | Ortak akışın başarı/hata/zaman aşımı durumları ve yüklenme kilidi korunur. |
| [#18](https://www.youtube.com/watch?v=MBOrcEErqPw), 17–18 ve 39–43. dakika | Dışarıdan bağımlılık verme, ağ olmadan hazır modelle davranışı test etme | Zorunlu servis enjeksiyonu; testte elle tamamlanan başarı/hata. Sahte gecikme widget veya Cubit'e taşınmadı. |
| [#19](https://www.youtube.com/watch?v=euw6Np2Z9n4), 62–64. dakika ve 72:20 karesi | Etkileşimi state ile engelleme, servis sözleşmesi, listener ile yönlendirme | Düğme selector'ı, ortak form kilidi ve filtrelenmiş başarı listener'ı. |
| [Mimari v2 #11](https://www.youtube.com/watch?v=tj5-EBrczxk), 25–26. dakika | Asenkron dönüşte Cubit kapanmış olabilir; katmanları ihtiyaçla geliştirme | Mevcut kapanış/deneme kimliği korumaları aynen kullanılır; tüm projeye yeni bir temel mimari dayatılmaz. |
| [Mimari v2 #13](https://www.youtube.com/watch?v=NBUyfAEmdj4), 03–18 ve 46–49. dakika | Değiştirilebilir bağımlılıklar, bağımsız test kurulumu, sunumun veri alması | Her testte yeni servis; state ve widget testleri ayrı; ortak panel veriyi ve callback'leri alır. |

İncelenen GitHub karşılıkları:

- [Flutter-Full-Learn / random_image.dart](https://github.com/VB10/Flutter-Full-Learn/blob/a97929b6d06c35b9353551a207150388d30ec784/lib/core/random_image.dart): parametreli StatelessWidget yaklaşımı; örnekteki ağ görseli bizim statik kapakları değiştirme gerekçesi değildir.
- [req_res_test.dart](https://github.com/VB10/Flutter-Full-Learn/blob/a97929b6d06c35b9353551a207150388d30ec784/test/req_res_test.dart): `MockReqResService`, ağ kullanmadan hazır model döndürür.
- [login_cubit.dart](https://github.com/VB10/Flutter-Full-Learn/blob/a97929b6d06c35b9353551a207150388d30ec784/lib/404/bloc/feature/login/cubit/login_cubit.dart): `ILoginService` constructor'dan alınır ve cevap state'e aktarılır.
- [Template v2 / base_cubit.dart](https://github.com/VB10/architecture_template_v2/blob/4c1cbaefbea2281f377a33eb3052348b5cf3e225/lib/product/state/base/base_cubit.dart): `isClosed` kontrolü. Salt inceleme kopyasından tekrar okundu.
- [home_view_model_test.dart](https://github.com/VB10/architecture_template_v2/blob/4c1cbaefbea2281f377a33eb3052348b5cf3e225/test/view_model/home_view_model_test.dart): servis/cache mock'larıyla bağımsız kurulum ve state beklentileri. Salt inceleme kopyasından tekrar okundu.

Tipli video isteği, eski cevabı deneme kimliğiyle eleme, tek yönlendirme,
çift gönderim ve süre sınırı ürünümüze özgü uyarlamalardır. Hepsinin ders
örneğinde hazır bulunduğu iddia edilmez. Derste bir paketin geçmesi, bu
aşamada o paketi projeye eklemek için tek başına gerekçe değildir.

## Doğrulama

- `flutter analyze --no-pub`: temiz.
- `flutter test --no-pub --reporter expanded`: **632 test başarılı**.
- Yeni **25 birim/state testi**: 15 şablonun eşleşmesi ve geçerli isteği,
  eksik/bilinmeyen girdiler, state sırası, eşitlik, aynı istekle tekrar deneme,
  çift gönderim, iptal/kapanış sonrası yanıt, zaman aşımı ve yanlış iş sonucu.
- Yeni **24 widget testi**: 15 şablonun sonuç/dönüşü ve statik kapağı, form
  kilidi, uyarı, hata, iptal, gerçek `AiVideoView` üzerinden navigasyon,
  üst route, seçimlerin korunması ve 320×568 / 2× metinde ortak panel/sonuç.
- Mevcut AI Video uyarı testleri başarıda eski mock mesaj yerine sonuç
  sayfasını bekler. Uyarı ve seçim silme kontrolleri kaldırılmadı.
- Üret, Explore, cache, navigasyon ve mevcut görsel testleri tam pakette geçti.
- `flutter build apk --debug --no-pub`: başarılı.
- `tool/preview_ai_video_generation_test.dart`: 390×844 boyutta 8 önizleme
  (düzenleyici, yüklenme, hata, Apex/Cliff Drive/Race sonuçları, dönüş ve iptal).
  Bunlar test ortamında Arial ile oluşturulan görünümlerdir; cihaz/video çıktısı
  değildir. Bu aşamada canlı telefon/emülatör etkileşim testi yapılmadı.

## Elle deneme

Uygulamayı yeniden başlatın; mevcut ana girişten AI Video sekmesine geçin
veya yalnız bu sekmede başlatmak için:

```sh
flutter run -t lib/main_ai_video.dart
```

1. Apex Transform / Cliff Drive / Race Video açın. Araç seçmeden Video
   Oluştur'a basınca mevcut görsel-seç uyarısı çıkmalı.
2. Örnek araç seçip Video Oluştur'a basın. Demo sonucu, aynı araç ve doğru
   şablon adıyla açılmalı; gerçek video üretilmediği açıklaması görünmeli.
3. Seçimlere Dön; araç seçimi kalmalı. Tekrar üretip yüklenirken Vazgeç deyin;
   birkaç saniye bekleyince sonuç kendiliğinden açılmamalı.
4. Üretim sürerken telefonun geri tuşuyla detaydan çıkın; eski yanıt yeni
   sayfada sonuç açmamalı. Detayı yeniden açınca araç seçimi korunmalı.

Kontrollü hata için uygulamayı durdurup şu bayrakla yeniden çalıştırın:

```sh
flutter run -t lib/main_ai_video.dart --dart-define=MODY_DEMO_FAIL_FIRST=true
```

Her yeni detay oturumunun ilk isteği demo hatası verir. Aynı ekranda Tekrar
Dene başarılı olmalı. Hata ekranından Seçimlere Dön de seçimleri korumalı.
Detayı kapatıp yeniden açmak yeni demo servisi oluşturur. Bayrak tüm varsayılan
demo servislerini etkiler; Üret/Explore'a özel sanılmamalıdır. Normal davranışa
dönmek için uygulamayı bayraksız yeniden başlatın; hot reload yeterli değildir.
