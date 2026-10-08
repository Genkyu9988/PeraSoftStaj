# Yararlanılan dersler ve projeye uyarlama

Tarih: 8 Ekim 2026. Bu not, mevcut frontend/demo sürümünün öğretim
kaynaklarını ve kaynaklardan alınan yöntemlerin kod karşılıklarını açıklar.

## İnceleme yöntemi

Kullanıcının sağladığı transkriptler, indirilen videoların ilgili zaman
damgalı kod kareleri ve öğretmenin GitHub dosyaları birlikte karşılaştırıldı.
Tüm videoların baştan sona kesintisiz sesli izlendiği iddia edilmez.
Temelden Zirveye 4/4.2/5 için transkript ve repo kodundan yararlanıldı;
9/18/19 ve Mimari v2 8/11/13 için indirilen video dosyaları da mevcuttu.
Videoların ara kod aşamaları reponun tamamlanmış sürümüyle birebir aynı
kabul edilmedi. MP4 ve transkript dosyaları bu repoya yüklenmedi.

## Ders → yöntem → Mody AI karşılığı

| Kaynak | Yararlanılan yaklaşım | Projede nasıl kullanıldı? |
| --- | --- | --- |
| Temelden Zirveye 4 / 4.2 / 5 — widget oluşturma | Küçük, parametreli `StatelessWidget`; veriyi ve callback'i dışarıdan alma | `GenerateOptionBoxes`, `GenerationPanel`, ortak seçim ve eylem bileşenleri. Sunum bileşeni servis çağırmaz veya cache'e yazmaz. |
| [Temelden Zirveye 9 — servis/Future/hata yönetimi](https://www.youtube.com/watch?v=laSlXorExj4) | Model, servis sözleşmesi, `Future/await`, `try/catch`, yüklenme durumu | `GenerationService`, `FakeGenerationService`, tipli istek/sonuç ve kullanıcıya güvenli hata mesajları. Sonraki girdi–sonuç hazırlığında saf `GenerationInputResolver`. |
| [Temelden Zirveye 18 — test edilebilirlik](https://www.youtube.com/watch?v=MBOrcEErqPw) | Bağımlılığı constructor'dan almak; testte hazır model döndüren servis kullanmak | Servis Cubit'e dışarıdan verilir. `ControlledGenerationService` başarı/hata zamanını testin kontrol etmesini sağlar; gerçek ağ veya yapay uzun bekleme gerekmez. Picker/Vexana eklemek zorunlu kabul edilmedi. |
| [Temelden Zirveye 19 — BLoC/Cubit](https://www.youtube.com/watch?v=euw6Np2Z9n4) | State, `copyWith`, `BlocSelector`, listener ile yan etki | Üret seçimleri ve ortak üretim durumları ayrıldı. Buton/panel gerektiği kadar dinler; sonuç navigasyonu `build` içinde yapılmaz. |
| [Mimari v2 8 — responsive ve özel widget](https://www.youtube.com/watch?v=GizG5X3gfsQ) | 30–34. dakika: ortak uyarlama bileşenleri; 46–47 ve 52:55–53:42: kullanılabilir alan ve esnek yerleşim; 54–57: açık parametreli dialog | Sabit yükseklik yüzünden taşan kutu/alt menü/renk satırları içerikle büyür. Kısa seçim panelleri gerektiğinde kayar. Üret ve Garaj üst içeriği dar alanda formu sıkıştırmaz. Yeni responsive paketi eklenmedi. |
| [Mimari v2 11 — state yönetimi](https://www.youtube.com/watch?v=tj5-EBrczxk) | 08–12: küçük dinleyiciler ve eşitlik; 14–18: servis enjeksiyonu; 21–26: listener ve kapanmış Cubit | Mevcut state/servis ayrımı korunur. Son responsive düzeltmeler Cubit'e taşınmaz; bunlar yerleşim sorumluluğudur. |
| [Mimari v2 13 — testler](https://www.youtube.com/watch?v=NBUyfAEmdj4) | 03–18: bağımsız sahte servis/cache ve state testi; 46–51: veri alan sunum widget'ının testi | Her senaryo kendi servisini kurar. Yeni responsive testleri gerçek ekranları, seçimleri ve iptal–hata–tekrar dene–dönüş akışını sınar; yalnız izole sonuç paneliyle yetinmez. |

Önceki dosya/tema düzenlemesinde Mimari v2 2/6/9 da kullanıldı.
Ayrıntılı bağlantı ve zamanlar [Mimari A](architecture_stage_a.md),
[Mimari B](architecture_stage_b.md), [Mimari C](architecture_stage_c.md),
[Explore](explore_generation.md), [AI Video](ai_video_generation.md) ve
[girdi–sonuç](generation_contract.md) notlarında korunur.

## GitHub kaynakları

İncelenen sürümler sabit commit bağlantılarıyla verilmiştir:

- [VB10/Flutter-Full-Learn — a97929b](https://github.com/VB10/Flutter-Full-Learn/tree/a97929b6d06c35b9353551a207150388d30ec784):
  `lib/101/stateless_learn.dart`, `lib/core/random_image.dart`,
  `lib/202/service/post_model.dart`, `lib/202/service/post_service.dart`,
  `lib/303/testable/user_save_model.dart`, `test/req_res_test.dart`,
  `lib/404/bloc/feature/login/cubit/login_cubit.dart` ve view/state dosyaları.
- [VB10/architecture_template_v2 — 4c1cbae](https://github.com/VB10/architecture_template_v2/tree/4c1cbaefbea2281f377a33eb3052348b5cf3e225):
  `module/widgets/lib/src/feature/responsive/adapt_all_view.dart`,
  `module/widgets/lib/src/feature/responsive/custom_responsive.dart`,
  `module/widgets/lib/src/widgets/dialog/success_dialog.dart`,
  `lib/development/preview_main.dart`,
  `lib/feature/home/view_model/home_view_model.dart`,
  `lib/product/state/base/base_cubit.dart`,
  `test/view_model/home_view_model_test.dart`, `test/widget/home_widget_test.dart`.

## Öğretmenin yaklaşımı ile kendi kararlarımızın sınırı

Öğretmenin örneklerinden sorumluluk ayrımı, bağımlılık enjeksiyonu, durum
eşitliği, esnek yerleşim ve test mantığı alındı. Uygulamanın tamamını aynı
paketlere veya aynı klasör/katman sayısına taşımadık.

Açı–parça uyumu, yalnız Uygula ile taslağın kaydı, deneme kimliğiyle geç
cevabı yok sayma, 20 saniyelik süre sınırı, sağlayıcıdan bağımsız plan ve
320/390 piksel–1x/2x test matrisi bu ürünün ihtiyaçlarına göre seçilmiştir.
Bunların öğretmenin örneğinde hazır bulunduğu iddia edilmez.

Mimari v2 8'in 52:20–52:27 bölümündeki önizlemeye tek başına güvenmeme
uyarısına uygun olarak widget testleri ile Android emülatör kontrolü ayrı
raporlanır. Emülatör kontrolü fiziksel Android/iOS cihaz testi değildir.

Gerçek AI API, sağlayıcı seçimi, backend, galeri/kamera, video oynatma veya
Garaj'a kayıt bu değişikliklerin parçası değildir. Demo sonuçlar yalnızca
seçilen orijinal fotoğrafı gösterir.
