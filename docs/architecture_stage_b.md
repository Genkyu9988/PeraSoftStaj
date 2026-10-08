# Mimari B — Yalnızca Üret ekranında Cubit pilotu

Tarih: 5–6 Ekim 2026.

Bu adım kullanıcının onayıyla yalnızca Üret'in (Style Builder, Custom Edit,
Detail Edit) onaylanmış seçimlerini ve doğrulama kararlarını Cubit'e taşır.
Explore, AI Video ve Garaj'ın state yönetimi değiştirilmez. Cubit her projede
zorunlu bir aşama veya AI API'ye geçişin ön şartı değildir.

## Öğretmenin kaynaklarından alınan yöntemler

Kullanıcının gönderdiği yerel transkriptlerin ilgili bölümleri ve aşağıdaki
repo dosyaları incelendi. Bu ifade bütün video görüntülerinin baştan sona
izlendiği anlamına gelmez; otomatik transkript zamanları yaklaşık kabul edilir.

| Ders / bölüm | Öğretmenin gösterdiği yaklaşım | Bu projedeki karşılığı |
| --- | --- | --- |
| [11 — BLoC ile state yönetimi](https://www.youtube.com/watch?v=tj5-EBrczxk&t=650s), 10:50–12:37 | BlocSelector, eşitlik ve props | Sadece gereken immutable değerleri seçen üç BlocSelector; Equatable state. |
| Ders 11, 14:35–15:17 | Bağımlılıkları dışarıdan alarak test edebilme | GenerateSuggestions, GenerateValidator ve kayıt bildirimi constructor ile verilir. |
| Ders 11, 21:00–22:25 | Builder/listener ayrımı; eşit state'in yeniden tetiklenmemesi | Uyarılar BlocListener'da gösterilir; aynı uyarının tekrar gösterilebilmesi için her denemenin kimliği vardır. |
| Ders 11, 35:01–35:54 | Mevcut nesneyi BlocProvider.value ile sunma | Cubit'in sahibi ModyHomeView State'idir; provider yalnızca erişim sağlar, State dispose sırasında kapatır. |
| [13 — Testler](https://www.youtube.com/watch?v=NBUyfAEmdj4&t=179s), 02:59–04:19 | Test edilecek sınıfta global bağımlılık aramamak | Cubit içinde GetIt, BuildContext veya gerçek depolama erişimi yoktur. |
| Ders 13, 13:50–14:35 | bloc_test ile state geçişlerini test etme | Seçim, öneri, uyarı, eşit state ve kapanmış Cubit senaryoları test edilir. |

Kaynak repo: [VB10/architecture_template_v2](https://github.com/VB10/architecture_template_v2).
İncelenen commit: `4c1cbaefbea2281f377a33eb3052348b5cf3e225`.

- [home_view_model.dart](https://github.com/VB10/architecture_template_v2/blob/4c1cbaefbea2281f377a33eb3052348b5cf3e225/lib/feature/home/view_model/home_view_model.dart): constructor bağımlılıkları, state üzerinden karar, copyWith/emit.
- [home_state.dart](https://github.com/VB10/architecture_template_v2/blob/4c1cbaefbea2281f377a33eb3052348b5cf3e225/lib/feature/home/view_model/state/home_state.dart): immutable alanlar ve Equatable.
- [base_cubit.dart](https://github.com/VB10/architecture_template_v2/blob/4c1cbaefbea2281f377a33eb3052348b5cf3e225/lib/product/state/base/base_cubit.dart): kapandıktan sonra emit etmeme.
- [home_view_model_test.dart](https://github.com/VB10/architecture_template_v2/blob/4c1cbaefbea2281f377a33eb3052348b5cf3e225/test/view_model/home_view_model_test.dart): enjekte edilen bağımlılıklar ve blocTest.

Öğretmenin HomeViewModel'i BaseCubit üzerinden Cubit kullanır; bu çalışmada
event sınıflı Bloc'tan Cubit'e geçilmedi. Önceki Üret seçimleri setState ile
tutuluyordu. Tek pilot için ayrıca bir BaseCubit katmanı kopyalanmadı;
kapanma kontrolleri GenerateCubit içinde bulunur. Öğretmenin paketlerinin,
GetIt/Hive/network katmanının tamamı eklenmedi.

Front/Rear/Side eşleşmeleri, Fikir Ver kuralları, uyarı metinleri ve kayıt
öncelikleri öğretmenin örneğinden değil, kullanıcının doğruladığı ürün
kurallarından gelir. Bunları değiştirmek bu geçişin amacı değildir.

## Sorumluluklar

- `feature/generate/view_model/generate_cubit.dart`: onaylanmış seçimleri
  değiştirme, mevcut öneri yardımcısını çağırma, mevcut validator ile kontrol
  etme ve onaylanan seçim için bir kayıt bildirimi üretme.
- `feature/generate/view_model/state/generate_state.dart`: değişmez seçim
  durumu, copyWith, değer eşitliği ve geçici uyarı/bilgi durumu. Parça haritası
  dışarıdan kopyalanır ve değiştirilemez. Görünen parça sırası da eşitliğe dahil
  edilir; yalnızca Map eşitliği sıralamayı dikkate almaz.
- `ModyHomeView`: PageController, TextEditingController, panel açma/kapatma,
  modal taslakları, odak ve görünür modun sahibi olmaya devam eder. Bu UI
  durumları için setState kalması bilinçlidir. Açıklama alanı kaydedilmez;
  gönderme anındaki metin Cubit'e doğrulama girdisi olarak verilir.
- `BlocSelector`: araç görseli, Style Builder seçenekleri ve Detail Edit
  seçenekleri kendi kullandıkları değerleri dinler. Widget'lar cache yazmaz.
  Bu ayrım test edilir; uygulama genelinde ölçülmüş bir hız artışı iddiası yoktur.
- `BlocListener`: Cubit'in geri bildirimini mevcut ModyFeedback aracılığıyla
  gösterir. Uyarı metni aynı olsa bile yeni deneme kimliği yeniden gösterimi
  sağlar. Daha yeni seçim veya mod değişikliği eski bildirimi geçersiz kılar.

Ana sekmeler arasında geçerken Cubit korunur; Üret'in sahibi kaldırıldığında
kapatılır. `BlocProvider.value` nesneyi kendisi kapatmadığı için bu sahiplik
açıkça belirtilmiştir. Yeniden açılan ekran mevcut GenerateSelection kaydından
başlar; ikinci bir kayıt şeması veya veri göçü yoktur.

`MainTabsView` içindeki tek bağlantı değişikliği, `isActive` bilgisinin canlı
okunan bir callback olmasıdır. TabBarView animasyonu sırasında çocuk widget
güncellemesini geciktirebilir; eski bool değerine bakan asenkron uyarı Explore'a
taşınabiliyordu. Listener şimdi doğrudan güncel sekme durumunu okur. Ana sekme
yönetimi Cubit'e taşınmamıştır.

## Korunan kurallar

- Style Fikir Ver: araç + stil + tek ekstra + renk. Custom: yalnızca araç;
  açıklama korunur. Detail: araç + açı + o açıya uygun tek parça + renk.
- Detail önerisi eski parça haritasını tamamen değiştirir; farklı açıdan parça
  taşınmaz. Manuel farklı açı onayı parçaları temizler, rengi korur. Aynı açı
  ve iptal eski parçaları silmez. Araç değişimi/kaldırılması diğer seçimleri silmez.
- Uygula öncesindeki modal taslağı Cubit'e/kayda gitmez. İptal ve uyarılar
  kayıt bildirimi üretmez. Custom metin ve sihirli ikonun yerel davranışı korunur.
- Style için araç + en az bir stil/ekstra/renk; Custom için araç + boş olmayan
  açıklama; Detail için araç + açı gerekir. Detail parça/renk paneli açmak için
  yalnızca açı gerekir. Mevcut validator ve uyarı metinleri değişmedi.
- Her onay/Fikir Ver bir tam seçim kopyasıyla tam bir kez `onApplied` çağırır.
  Aynı rastgele sonuç yeniden çıkıp Equatable emit'i bastırsa bile bu bildirim
  korunur. Bu yüzden kalıcı kayıt BlocListener'a veya builder'a bağlanmaz.
- Mevcut MainTabsView → SelectionCacheManager kayıt akışı, sıralı kayıt
  davranışı, `modyai.v1.selections` anahtarı ve JSON alanları aynı kalır.
- Görünüm, ölçüler, klavye davranışı, kataloglar ve mevcut renk/parça sıraları
  korunur. Yeni galeri/kamera veya AI bağlantısı yoktur. AI Video kapakları
  statik kalır; rehber ve Canlı Edit geri getirilmez.

## Paketler

Üç doğrudan bağımlılık eklendi: `flutter_bloc: ^9.1.1`, `equatable: ^3.0.0`;
test için `bloc_test: ^10.0.0`. Lock dosyası bunları ve gereken dolaylı
bağımlılıkları içerir; önceden kilitlenmiş paketlerin sürümleri değiştirilmedi.

API ve sahiplik davranışı için resmi kaynaklar da kontrol edildi:
[flutter_bloc](https://pub.dev/packages/flutter_bloc),
[Equatable](https://pub.dev/packages/equatable),
[bloc_test](https://pub.dev/packages/bloc_test).

## Doğrulama

- Geçiş öncesi 428 test geçti. Eski test dosyaları ve beklentileri değiştirilmedi.
- `generate_cubit_test.dart`: 39 yeni test. Immutable state, parça sırası,
  açı geçişleri, her açıya uygun öneri, uyarı öncelikleri, tekrar bildirim,
  tek kayıt, kayıt kopyaları, bağımlılık enjeksiyonu ve kapanmış Cubit.
- `generate_cubit_widget_test.dart`: 6 yeni test. Seçici yeniden çizim,
  tekrarlı/gecikmiş uyarılar, ana sekme geçişi, sahiplik/kapanma/yeniden açılma,
  açık taslak paneliyle ekranın kaldırılması.
- `flutter test`: **473 test başarılı** (428 mevcut + 45 yeni).
- `flutter analyze`: sorun yok. Değişen Dart dosyaları için format kontrolü
  değişiklik gerektirmiyor; `git diff --check` temiz.
- `flutter build apk --debug --no-pub`: başarılı; Android debug APK üretildi.
- Eski lib/test dosyalarının geçiş öncesi SHA-256 karşılaştırması: yalnızca
  ModyHomeView ve MainTabsView değişti. Dört yeni Dart dosyası eklendi
  (Cubit, state ve iki test dosyası).
- Canlı cihaz/emülatör testi yapılmadı; `adb devices` bağlı cihaz göstermedi.
  Widget testleri ve APK derlemesi gerçek cihaz testinin yerine geçmez.

Yeni paketler ve state sahipliği değiştiğinden uygulamayı yalnızca hot reload
ile değil, durdurup yeniden çalıştırarak deneyin. Kalıcı seçimler aynı biçimde
yüklenir; kaydedilmeyen Custom metin, eskisi gibi yeni oturumda geri gelmez.
