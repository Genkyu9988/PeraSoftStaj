# Mimari A — Davranışı koruyan dosya ve tema düzenlemesi

Tarih: 5 Ekim 2026.

Bu adım mevcut Mody AI kodunu düzenler. Yeni ürün davranışı, state yönetim
paketi, ağ servisi veya AI bağlantısı eklemez. Öğretmenin yöntemleri ile
bu projeye özgü kararlar aşağıda ayrı belirtilmiştir.

## Dayanak: kullanıcının gönderdiği Flutter Mimari v2 dersleri

Videoların ilgili bölümleri kullanıcının yerel transkriptlerinden okunmuş,
kod karşılıkları kaynak reponun incelenen sürümüyle karşılaştırılmıştır.
Bu not bütün video görüntülerinin baştan sona izlendiği anlamına gelmez.
Zamanlar otomatik transkriptlerden geldiği için yaklaşık kabul edilmelidir.

| Ders | İlgili bölüm | Burada uygulanan ilke |
| --- | --- | --- |
| [2 — Proje/modül ve klasör yapısı](https://www.youtube.com/watch?v=TIrcxptk89Y&t=367s) | 06:07–09:30 | Feature/product ayrımı; başka geliştiricinin dosyanın yerini anlayabilmesi. |
| [6 — Tema kullanımı](https://www.youtube.com/watch?v=Zq7qioZYUx8&t=1090s) | 18:10–20:15 | ThemeData/TextTheme tanımının merkezi ve ayrı tutulması. |
| [8 — Özel widget tasarlama](https://www.youtube.com/watch?v=GizG5X3gfsQ&t=2011s) | 33:31–34:59 | Bileşenin kullanımının ve sorumluluğunun anlaşılabilmesi. |
| [9 — Stateless/Stateful](https://www.youtube.com/watch?v=4-rr5y5xyaI&t=1337s) | 22:17–25:28 | Veri/callback iletişimi, üstten gelen değeri gizlice değiştirmeme, yaşam döngüsü kontrolleri. |
| [13 — Testler](https://www.youtube.com/watch?v=NBUyfAEmdj4&t=2796s) | 46:36–47:40 | Görsel widget'ı iş bağımlılıklarından ayırıp verilerle test etme. |

Kaynak: [VB10/architecture_template_v2](https://github.com/VB10/architecture_template_v2),
incelenen commit: `4c1cbaefbea2281f377a33eb3052348b5cf3e225`.

Gerçek kod karşılıkları:

- [custom_dark_theme.dart](https://github.com/VB10/architecture_template_v2/blob/4c1cbaefbea2281f377a33eb3052348b5cf3e225/lib/product/init/theme/custom_dark_theme.dart)
- [home_user_list.dart](https://github.com/VB10/architecture_template_v2/blob/4c1cbaefbea2281f377a33eb3052348b5cf3e225/lib/feature/home/view/widget/home_user_list.dart)
- [home_widget_test.dart](https://github.com/VB10/architecture_template_v2/blob/4c1cbaefbea2281f377a33eb3052348b5cf3e225/test/widget/home_widget_test.dart)

Bizim uyarlamamız: mevcut tek tema için ayrı tema arayüzü, LightTheme veya
tema değiştirme state'i gerekmedi. `ModyTheme.dark()` eski ThemeData'yı üretir.
Widget'lar veri/callback ile çalışır; mevcut state ve controller sahipliği korunur.
Şablonun paketleri, scriptleri, renkleri ve bütün modülleri kopyalanmadı.

## Dosya yerleşimi

```text
lib/
  main.dart                     # mevcut uygulama başlangıcı / MyApp
  main_ai_video.dart            # mevcut alternatif giriş noktaları
  main_explore.dart
  main_garage.dart
  feature/
    shell/view/                 # dört ana sekme ve keep-alive
    generate/
      view/                     # üç modun state'i ve controller yaşam döngüsü
        widget/                 # sadece Generate'a ait sunum bileşenleri
      logic/                    # mevcut saf, Random enjekte edilebilen öneriler
      data/                     # mevcut yerel metin örnekleri
    explore/view/
      widget/                   # Explore'a özel seçenek ızgarası
    ai_video/view/
    editor/view/                # Explore ve AI Video'nun ortak detay ekranı
      widget/                   # detay kapağı ve uyarı yerleşimi
    garage/
      view/
      data/
  product/
    init/
      selection_loader.dart     # önce kayıtları okur, sonra ana ekranı açar
      theme/                    # ModyTheme ve mevcut ColorItems
    catalog/                    # araç, parça, renk, kart ve referans katalogları
    constants/                  # asset yolları ve yerleşim ölçüleri
    model/                      # ortak kullanılan/kaydedilen seçim modelleri
    validation/                 # mevcut saf doğrulayıcılar ve uyarı metinleri
    widget/                     # birden fazla özellikte kullanılan bileşenler
    utility/                    # ortak görsel geri bildirim
    navigation/                 # mevcut Navigator yardımcısı
    cache/                      # SharedPreferences adaptörü ve kayıt yöneticisi
```

Yerleşim kuralları:

- Bir widget yalnızca Generate'a aitse `feature/generate/view/widget` içinde
  kalır. Sırf widget olduğu için her şey `product` altına taşınmaz.
- Explore ve AI Video aynı `ExploreDetailView` ekranını kullanır. Bu nedenle
  mevcut sınıf adı korunarak `feature/editor/view` altına taşındı. İki kopya
  oluşturulmadı, yeni bir detay ekranı veya navigasyon akışı eklenmedi.
- Kataloglar hem ekranlar hem cache doğrulaması tarafından kullanılır;
  `product/catalog` altındadır. Modeller `product/model` içindedir. JSON
  dönüşümü bu adımda yeniden yazılmadı.
- `product/init/selection_loader.dart` uygulamayı birleştiren başlangıç
  noktasıdır; shell ekranını açması bilinçlidir. Ortak widget, katalog,
  model, validator ve cache dosyaları feature ekranlarını içe aktarmaz.
- Yeni boş `view_model`, `service`, `module/core` gibi klasörler oluşturulmadı.
  Bu düzen henüz Cubit/MVVM geçişinin tamamlandığı anlamına gelmez.
- Test dosyalarının adları ve önceki davranış kontrolleri korunur; taşınan
  kodun importları güncellenir. Eski yollarda yönlendiren kopyalar bırakılmaz.

## Üret görünümünden ayrılan bileşenler

`ModyHomeView` seçimlerin, controller'ların, modal sonuçlarının ve kayda
bildirimin sahibidir. Aşağıdaki sunum dosyaları aynı widget ağaçlarını,
ölçüleri, metinleri, anahtarları ve callback bağlantılarını korur:

- `style_builder_content.dart`
- `custom_edit_content.dart` (açıklama alanı dahil)
- `detail_edit_content.dart`
- `generate_mode_tabs.dart`
- `generate_idea_button.dart`
- `generate_option_boxes.dart`
- `generate_options_panel.dart`

`detail_adjustment_panel.dart` da yalnızca Generate'a ait olduğu için buraya
taşındı. Görsel bileşenlere cache manager, Random veya yeni servis verilmedi.
Custom metin controller'ı alt widget tarafından oluşturulmaz/dispose edilmez;
sahibi hâlâ ModyHomeView'dır.

## Değişmemesi gerekenler

- `modyai.v1.selections` anahtarı, JSON alanları, katalog kimlikleri, görünür
  başlıklar ve parça sıraları aynı kalır. Veri göçü veya kayıt silme yoktur.
- Seçim taslağı Uygula ile onaylanır; iptal edilen taslak kaydedilmez.
- Farklı açı onaylamak parçaları temizler, rengi korur; aynı açı ve iptal
  parçaları temizlemez. Aracı kaldırmak diğer seçimleri temizlemez.
- Style Fikir Ver: araç + stil + tek ekstra + renk. Custom: yalnızca araç.
  Detail: araç + açı + o açıya uygun tek parça + renk; eski parça haritası
  yeni haritaya eklenmez. Tek işlem tek kayıt bildirimi üretir.
- Uyarı metinleri/öncelikleri, sekme yaşam döngüsü, açıklama alanı, klavye,
  kaydırma ve örnek araç davranışları korunur.
- `ThemeData.dark()` varsayılanları, `0xffF5F5F7` metin rengi, siyah scaffold
  ve kalın başlıklar korunur. `labelLarge` eskisi gibi `bodyMedium` üzerinden
  oluşturulur; "düzeltme" adıyla font değişikliği yapılmaz.
- Galeri/kamera eklenmez; AI Video kapakları statik kalır. Rehber/Canlı Edit
  geri gelmez. Sihirli metin düğmesinin mevcut davranışı değiştirilmez.

## Doğrulama

- Düzenleme öncesi: 423 test başarılı.
- Eski testlerin davranış beklentileri değiştirilmedi; yalnızca import yolları
  güncellendi.
- `mody_theme_test.dart`: bütün ThemeData'nın eski yapılandırmayla eşitliği,
  MyApp bağlantısı ve widget'a ulaşan (yerelleştirilmiş) tema eşitliği.
- `generate_presentation_test.dart`: ayrı sunum widget'larının state/cache
  gerektirmeden callback ile haberleşmesi; seçim ve Uygula'nın bağımsızlığı.
- Düzenleme sonrası: 428 test başarılı (önceki 423 + 5 yeni test).
- `flutter analyze`: temiz. `dart format --output=none --set-exit-if-changed
  lib test`: değişiklik gerekmiyor. `git diff --check`: temiz.
- `flutter build apk --debug --no-pub`: başarılı; debug APK üretildi.
- Taşıma öncesi/sonrası kaynak karşılaştırması: mevcut 86 Dart dosyasının
  84'ünde importlar dışında gövde değişikliği yok. Diğer iki dosyada tema
  (`main.dart`) ve sunum widget'ları (`ModyHomeView`) ayrıldı. ModyHomeView'ın
  state/controller/iş kuralları ve ayrılan widget gövdeleri, sınıf adları ve
  biçimlendirme farkları dışında korundu.
- Paketler, lock dosyası ve analiz kuralları değiştirilmedi.
- Canlı emülatör testi yapılmadı: kontrol sırasında bağlı Android cihazı veya
  çalışan emülatör yoktu. Dar ekran, klavye, sekmeler, kalıcı kayıt ve Fikir Ver
  kontrolleri mevcut widget/unit testlerinde geçti; bunlar cihaz testi değildir.

Sonraki B aşaması (ayrı çalışma): GenerateCubit/GenerateState pilotu. Bu
dosya düzenlemesi BLoC, GetIt, Hive, AutoRoute veya AI API'yi içermez.
