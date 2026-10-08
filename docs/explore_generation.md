# Explore — ortak sahte üretim akışı

Tarih: 7 Ekim 2026.

8 Ekim devamı: kullanıcı onayıyla AI Video da ortak sahte akışa bağlandı.
Aşağıdaki kapsam sınırları 7 Ekim aşamasına aittir. Güncel değişiklikler
[AI Video sahte servis notlarında](ai_video_generation.md) açıklanır.

## Kullanıcıya görünen sonuç

Explore'un 37 işlemi (16 Car Mods, 5 Style Builder, 5 Wallpaper Maker,
11 AI Edits) sahte servise bağlandı. Üret'in Style Builder, Custom Edit ve
Detail Edit akışları aynı davranışla korunur. Detail Edit yeni eklenmiş bir
akış değildir; mevcut çalışan akışı ortak altyapıya taşındı.

Geçerli seçim → yaklaşık 1,5 saniyelik yüklenme → demo sonuç. Sonuçta seçilen
**orijinal araç fotoğrafı** ve gönderilen seçimler bulunur. Fotoğraf üzerinde
modifikasyon yapılmaz; “AI ile üretilmedi” açıklaması görünür kalır. Sonuç
Garaj'a kaydedilmez; gerçek ağ isteği, anahtar veya ücretli işlem yoktur.

| İşlem türü | Gerekli alanlar | Sonuç özeti |
| --- | --- | --- |
| Tek girdili işlem; ör. Japanese | Araç | Explore, işlem, araç |
| Seçenekli Car Mod; ör. Customize Rims, Window Tints | Araç + o işleme ait hedef | Yukarıdakiler + hedefin adı |
| Change Color | Araç + mevcut katalogdan renk | Yukarıdakiler + renk |
| Clone Car Style | Araç + referans | Yukarıdakiler + referansın adı |

Uyarı sırası, seçim panelleri, Uygula/iptal ayrımı, örnek araçlar ve cache
biçimi korunur. Geçersiz veya başka işleme ait seçenek servise gönderilmez.
İstekte yalnız etkin işlemin alanları bulunur; örneğin Japanese isteği eski
bir jant veya renk seçimini taşımaz.

## Davranış güvenceleri

- Yüklenirken form ve gönderme düğmesi kilitlenir. Cubit de art arda gönderimi
  engeller; güvence yalnız düğmenin pasifleştirilmesine bağlı değildir.
- Vazgeç seçimleri silmez. İptal edilen isteğin geç gelen başarısı/hatası yok
  sayılır; yeni isteğin sonucunu değiştiremez. Bu **mantıksal iptaldir**, ileride
  bir sunucudaki AI işini gerçekten durdurma garantisi değildir.
- Tekrar Dene, başarısız olan isteğin aynı değişmez seçimlerini gönderir.
- Hata ekranındaki Seçimlere Dön formu tekrar açar. Kullanıcı seçimlerini
  değiştirebilir ve yeni bir istek başlatabilir.
- Sonuçtan dönünce aynı seçimler korunur; eski hata veya sonuç yeniden açılmaz.
- Detay ekranından geri çıkınca Cubit kapanır; geç yanıt navigasyon yapmaz.
- Başka bir sayfa detayın üzerindeyken sonuç otomatik açılmaz. Detaya dönünce
  Demo Sonucunu Gör ile açılabilir. Yönlendirme builder'da değil listener'dadır.
- 20 saniyelik süre sınırı asılı kalan serviste hata durumuna geçiş sağlar.
- Üretim durumları cache'e yazılmaz ve `onApplied` çağırmaz.

## Kodun sorumlulukları

1. `ExploreDetailView`: mevcut form/sheet/timer işlemleri, üretim paneli
   bağlantısı ve navigasyon. Oluşturduğu `ExploreGenerationCubit` nesnesini
   kendisi kapatır. AI Video için bu nesne hiç oluşturulmaz.
2. `ExploreGenerationCubit`: mevcut kataloglarla girdiyi doğrular ve
   `ExploreGenerationRequest` oluşturur. UI context veya depolama bilmez.
3. `GenerationFlowCubit<S>`: Üret ve Explore'un ortak yüklenme, hata, tekrar
   deneme, zaman aşımı ve eski yanıt koruması. `GenerationService` dışarıdan
   verilir. Bu, tüm uygulamaya dayatılan bir BaseCubit değil; yalnız üretim
   yaşam döngüsünün tekrarını önleyen sınırlı bir ortak sınıftır.
4. `GenerationInput`: Üret ve Explore isteklerini tipli olarak ayırır.
   `ExploreOperation` 37 işlemin kimliğini ve girdi türünü belirtir; Explore
   isteği sahte bir `GenerateMode` içine sıkıştırılmaz. Mevcut cache değişmez.
5. `FakeGenerationService`: hazır orijinal fotoğrafı döndürür. Gerçek AI
   servisi değildir. Varsayılan örneği oluşturan factory, testte dışarıdan
   verilen servisi değiştirmez.
6. `GenerationPanel` ve `GenerationResultView`: veri ve callback alan ortak
   görünümler; Generate/Explore Cubit'ini bilmez. Sonuç özeti istek türüne
   göre hazırlanır. Eski Generate import yolları uyumluluk export'u olarak kalır.

Explore'un bütün seçimlerini Cubit'e taşımadık. Formun stateful sahipliği
korunur; yeni Cubit yalnız üretimi yönetir. Servis geçişlerinde form alt ağacı
yeniden oluşturulmaz, düğmenin etkinliği ayrı selector ile dinlenir.

## Derslerden aldığımız yöntemler

Kaynak incelemesi, gönderilen transkriptler, yerel videoların ilgili kod
kareleri ve repo dosyalarının karşılaştırmasına dayanır. Tüm kayıtların
kesintisiz sesli izlendiği iddia edilmez. Öğretmenin yöntemleri ile bizim
ürünümüze özgü güvenceler aşağıda ayrılmıştır.

| Kaynak | Öğretmenin yöntemi / vurgusu | Bu uygulamadaki karşılığı |
| --- | --- | --- |
| Temelden Zirveye 4 / 4.2 / 5 | Parametreli StatelessWidget, ekranı küçük bileşenlere ayırma, callback ile davranışı dışarıdan verme | Ortak `GenerationPanel` ve sonuç görünümü; Cubit bağlantısı dışarıda. Ekranların seçenekleri birbirine kopyalanmaz. |
| Ders 9 | Future/await, hata yakalama, servis sözleşmesi, yüklenme sırasında etkileşimi yönetme | `GenerationService`, açık üretim durumları ve form kilidi. |
| Ders 18, 17–18 ve 35–43. dakika | Bağımlılığı constructor'dan verme, test için hazır model döndüren mock servis | Enjekte edilen servis ve istenen anda tamamlanan `ControlledGenerationService`. Picker eklenmedi. |
| Ders 19, 58–73. dakika | Cubit/state, selector, copyWith, listener'da yönlendirme | Üret'in mevcut seçim state'i korunur; Explore üretim durumu ayrı yönetilir, sonuç listener'da açılır. |
| [Mimari v2 11](https://www.youtube.com/watch?v=tj5-EBrczxk), 08–12, 14–18, 21–26. dakika | Küçük dinleyiciler, `Equatable.props`, servis enjeksiyonu, kapanmış Cubit kontrolü | İstek/sonuç/hata/deneme kimliği eşitliğe dahil; servis dışarıdan alınır; kapalı veya eski işlem sonucu state değiştiremez. |
| [Mimari v2 13](https://www.youtube.com/watch?v=NBUyfAEmdj4), 03–18 ve 46–51. dakika | Bağımlılıkları sahteleştirme, bağımsız state testleri, yalnız veri alan sunum widget'ı | Her testte ayrı servis; state sırası ve gerçek ekran etkileşimleri ayrı testler; ortak panel için bağımsız widget testi. |

İncelenen repo revizyonları:

- [VB10/Flutter-Full-Learn — a97929b](https://github.com/VB10/Flutter-Full-Learn/tree/a97929b6d06c35b9353551a207150388d30ec784):
  `lib/101/stateless_learn.dart`, `lib/core/random_image.dart`,
  `test/req_res_test.dart`, `lib/303/testable/user_save_model.dart`,
  `lib/404/bloc/feature/login/cubit/login_cubit.dart` ve view/state örnekleri.
- [VB10/architecture_template_v2 — 4c1cbae](https://github.com/VB10/architecture_template_v2/tree/4c1cbaefbea2281f377a33eb3052348b5cf3e225):
  `lib/product/state/base/base_cubit.dart`,
  `lib/feature/home/view_model/home_view_model.dart`,
  `test/view_model/home_view_model_test.dart`,
  `test/view_model/mock/login_service_mock.dart`,
  `test/view_model/mock/user_cache_mock.dart`,
  `test/widget/home_widget_test.dart`.

Çift gönderim kontrolü, deneme kimliğiyle geç yanıtı eleme, istek türlerini
ayırma, 20 saniyelik süre sınırı ve sonucu bir kez tüketme bizim ürün
uyarlamalarımızdır; öğretmenin örneğinde hepsinin hazır bulunduğu söylenmez.
İlgili 9/18/19 kaynak bağlantıları [Mimari C](architecture_stage_c.md),
önceki widget ayrımı [Mimari A](architecture_stage_a.md) notlarında da bulunur.

## Doğrulama

- `flutter analyze --no-pub`: temiz.
- `flutter test --no-pub --reporter expanded`: **583 test başarılı**.
- Yeni 61 birim/state testi: 37 işlemin kapsamı, gerekli alanlar ve istek
  içeriği, geçersiz seçim, hata/tekrar deneme, iptal, kapanış ve zaman aşımı.
- Yeni 12 widget testi: dört girdi türü, gerçek Explore navigasyonu, form
  kilidi, seçimlerin korunması, geç yanıt, üst route ve AI Video regresyonu.
- Mevcut Üret ve cache testleri de tüm test paketinde çalıştı.
- Ortak panel/sonuç 320×568 ve 2× metin ölçeğinde test edildi. Bu, tüm eski
  ekranların her erişilebilirlik boyutunda doğrulandığı anlamına gelmez.
- `tool/preview_explore_generation_test.dart` ile 390×844 boyutunda yüklenme,
  hata ve dört sonuç türünün görüntüsü incelendi. Bu görüntüler widget-test
  ortamında Arial ile üretilir; fiziksel cihaz/emülatör ekran görüntüsü değildir.
- `flutter build apk --debug --no-pub`: başarılı; `app-debug.apk` oluşturuldu.
- Bu çalışmada canlı cihaz/emülatör etkileşim testi yapılmadı.

## Elle deneme

Normal demo için:

```sh
flutter run -t lib/main_explore.dart
```

1. Customize Rims veya Window Tints açın; araç ve ilgili hedefi seçin.
2. Arabamı Modifiye Et → yüklenme → demo sonuç. Araç ve hedefi kontrol edin.
3. Seçimlere Dön; önceki seçimler kalmalı, hata paneli açılmamalı.
4. Yeniden üretimi başlatıp hemen Vazgeç'e basın; birkaç saniye sonra sonuç
   kendiliğinden açılmamalı. Aynı kontrolü telefonun geri tuşuyla yapabilirsiniz.
5. Japanese için yalnız araç; Change Color için araç + renk; Clone Car Style
   için araç + referans ile deneyin. Eksik girdiler servisi başlatmamalı.

Kontrollü hata için uygulamayı durdurup yeniden çalıştırın:

```sh
flutter run -t lib/main_explore.dart --dart-define=MODY_DEMO_FAIL_FIRST=true
```

Varsayılan Explore servisinde her yeni detay oturumunun ilk çağrısı hata verir;
aynı ekranda Tekrar Dene başarılı olur. Detayı kapatıp yeniden açmak yeni servis
oluşturur. Üret'in varsayılan servisi kendi ekran ömrü boyunca tutulur. Testte
servis dışarıdan verilirse davranışı verilen servis belirler. Normal sürümde
bu bayrak kapalıdır. Deneme bitince bayraksız yeniden başlatın; hot reload
derleme zamanı bayrağını değiştirmez.

## Bilinçli kapsam sınırı

AI Video'nun statik görselleri ve mock mesajı korunur; üretim servisi bu
ekranlara bağlanmaz. Kamera/galeri, rehber, Canlı Edit, gerçek AI API, GetIt,
Vexana, Hive, yeni router, tüm uygulamayı Cubit'e taşıma ve yeni paket yoktur.
