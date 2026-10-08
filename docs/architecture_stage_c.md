# Mimari C — Üret için sahte servis ve sonuç akışı

Tarih: 6 Ekim 2026.

7 Ekim devamı: ortak yaşam döngüsü Explore'a da bağlandı. Bu belgenin aşağıdaki
kapsamı 6 Ekim aşamasını anlatır; güncel genişletme ve kaynak karşılaştırması
[Explore sahte servis notlarında](explore_generation.md) bulunur.

## Kapsam ve davranış

Yalnızca Üret'in Style Builder, Custom Edit ve Detail Edit modları bağlandı.
Explore, AI Video, Garaj, galeri/kamera, rehber ve Canlı Edit bu adımın dışında.
Yeni paket, gerçek HTTP isteği, AI anahtarı veya ücretli işlem eklenmedi.

Geçerli gönderim → yaklaşık 1,5 saniyelik demo yüklenmesi → demo sonuç sayfası.
Sonuç **seçilen orijinal yerel fotoğraftır**. “Demo sonuç — AI ile üretilmedi”
ve değişikliklerin görsele uygulanmadığı açıklaması sayfanın üstündedir.
Altında yalnızca gönderilen modun seçimleri gösterilir. Üretilmiş gibi
gösterilen bir görsel, indirme veya Garaj'a sonuç kaydetme yoktur.

- Mevcut validator ve uyarı sırası korunur. Geçersiz gönderim servisi çağırmaz.
- Style: araç + en az bir stil/ekstra/renk. Custom: araç + kırpılınca boş
  olmayan açıklama. Detail: araç + açı; parça ve renk isteğe bağlıdır.
- İstek, gönderim anındaki değerlerin değişmez kopyasıdır. Custom metnin
  kenar boşlukları yalnızca istekte temizlenir; düzenleyicideki metin korunur.
- Front/Rear/Side parça eşleştirmeleri ve Fikir Ver kuralları değişmez.
- Yüklenirken form, odak ve gönderme düğmesi kilitlidir. Cubit de ikinci
  gönderimi engeller; yalnızca düğmenin çizilmesine güvenilmez.
- Vazgeç seçimi temizlemez. Eski isteğin geç dönen başarı/hatası yok sayılır.
  Bu mantıksal iptaldir; gelecekteki bir uzak AI işinin iptali değildir.
- Hata ekranı güvenli bir açıklama, Tekrar Dene ve Seçimlere Dön sunar.
  Tekrar Dene aynı başarısız istek kopyasını kullanır. Ham hata/anahtar gösterilmez.
- 20 saniyelik süre sınırı asılı kalan serviste yüklenmeyi sonlandırır.
- Başarı yönlendirmesi listener'dadır. Sonuç işlem kimliği ile tüketilir;
  geri dönüşte yeniden açılmaz, aynı seçimlerle yeni üretim yapılabilir.
- Üret başka ana sekmedeyken veya üstünde başka route varken sonuç otomatik
  açılmaz. Sonuç oturumda korunur; Üret'e dönünce Demo Sonucunu Gör ile açılır.
- Seçimler eski cache şemasında kalır. Yüklenme, hata, sonuç ve Custom taslak
  metin diske kaydedilmez. Servis geçişleri `onApplied` çağırmaz.

## Öğretmenin kaynaklarının somut karşılığı

Kullanıcının yerel 9, 18 ve 19. ders kayıtlarının ilgili kareleri ve aynı
derslerin transkriptleri önceki incelemelerde karşılaştırıldı; bu uygulamada
ilgili transkript bölümleri ve repo kodları tekrar kontrol edildi. Bu ifade
tüm videoların kesintisiz ses/görüntü olarak baştan sona izlendiği anlamına gelmez.
Zamanlar yaklaşık olup 19. derste toplam dakika biçimindedir.

| Kaynak | Gösterilen yöntem | Projeye uyarlama |
| --- | --- | --- |
| [9 — Servis kullanımı](https://www.youtube.com/watch?v=laSlXorExj4&t=2980s), 49–51 ve 75–91. dakika | Yüklenme, hata yakalama, servis çıkarma ve arayüze bağımlı olma | `GenerationService`, `FakeGenerationService`, Cubit'te açık durumlar ve hata yolları. |
| [18 — Test edilebilirlik](https://www.youtube.com/watch?v=MBOrcEErqPw&t=137s), 02:17–02:49, 17–18. dakika | Test edilebilirliği baştan düşünme; bağımlılıkları parametre olarak verme | Cubit'in zorunlu `generationService` parametresi; view'da değiştirilebilir servis. Global servis araması yok. |
| Ders 18, 35–43. dakika | IStore/MockStore ve hazır model döndüren MockReqResService | İnternetsiz hazır sonuç; gecikme ve ilk N başarısız çağrı kontrollü. Testte tamamlanması elle yönetilen servis. |
| [19 — Cubit](https://www.youtube.com/watch?v=euw6Np2Z9n4&t=3550s), 58–64. dakika | copyWith, BlocSelector, işlemde etkileşimi durdurma, ILoginService enjeksiyonu | Seçimleri koruyan state; ayrı form kilidi ve gönderme düğmesi selector'ları; servis UI'dan ayrıdır. |
| Ders 19, 68–73. dakika | Listener'da yönlendirme, küçük widget'lar | `GenerationOverlay`, `GenerationResultView`, sonuç kimliği kontrol eden `BlocListener`. Builder içinde yönlendirme yok. |

Ana repo: [VB10/Flutter-Full-Learn](https://github.com/VB10/Flutter-Full-Learn).
İncelenen revizyon: `a97929b6d06c35b9353551a207150388d30ec784`.

- [req_res_test.dart](https://github.com/VB10/Flutter-Full-Learn/blob/a97929b6d06c35b9353551a207150388d30ec784/test/req_res_test.dart): hazır model veren sahte servis.
- [user_save_model.dart](https://github.com/VB10/Flutter-Full-Learn/blob/a97929b6d06c35b9353551a207150388d30ec784/lib/303/testable/user_save_model.dart): sözleşme ve değiştirilebilir bağımlılık.
- [login_cubit.dart](https://github.com/VB10/Flutter-Full-Learn/blob/a97929b6d06c35b9353551a207150388d30ec784/lib/404/bloc/feature/login/cubit/login_cubit.dart): servis constructor'dan alınır, async işlem state üretir.
- [login_cubit_state.dart](https://github.com/VB10/Flutter-Full-Learn/blob/a97929b6d06c35b9353551a207150388d30ec784/lib/404/bloc/feature/login/cubit/login_cubit_state.dart): copyWith/Equatable örneği.
- [login_view.g.dart](https://github.com/VB10/Flutter-Full-Learn/blob/a97929b6d06c35b9353551a207150388d30ec784/lib/404/bloc/feature/login/view/login_view.g.dart): selector ile kilitleme, listener ile navigasyon.

Mimari v2 reposunun B aşamasında kurulan selector/test düzeni korunur; yeni
BaseCubit/GetIt/Vexana/Hive katmanı eklenmez. Ders 18'de picker anlatılması
projeye picker ekleme gerekçesi değildir. Öğretmenin yöntemleri alınır,
ürün kuralları kullanıcının doğruladığı davranışlardan gelir.

Örnekleri bilinçli uyarladığımız noktalar: bool toggle yerine açık durum,
durum/sonuç/hata/işlem kimliğinin tamamını eşitliğe dahil etme, kapanmış Cubit'e
emit etmeme, çift gönderim, zaman aşımı ve eski yanıt kontrolü. Bunlar ders
örneğinin tamamında hazır varmış gibi sunulmaz; uygulamamızın güvenlikleridir.
[BlocListener](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocListener-class.html)
her state değişiminde çalışabileceğinden kullanıcı işlemi başına tek yönlendirme
ayrıca kontrol edilir.

## Dosya sorumlulukları

- `product/model/generation_request.dart`: aktif modun değişmez istek modeli.
- `product/model/generation_result.dart`: yalnızca demo için orijinal yerel
  fotoğraf ve isteğin sonucu. Gerçek sağlayıcı medya cevabı değildir.
- `product/service/generation`: ağ/UI/cache bilmeyen sözleşme, kontrollü fake.
- `feature/generate/view_model/state/generation_activity.dart`: geçici işlem
  durumu; isimli constructor'lar eski hata/sonucun yeni isteğe taşınmasını önler.
- `GenerateCubit`: validator → istek kopyası → servis → state; retry/iptal.
- `ModyHomeView`: servisi bağlama, sahip olduğu Cubit'i kapatma, listener ve
  mevcut controller/panel taslakları. `BlocProvider.value` sahipliği değişmedi.
- `GenerationFormGuard`/`GenerationSubmitButton`: sadece ilgili bool'u seçer.
- `GenerationOverlay`/`GenerationResultView`: yüklenme, hata ve demo sunumu.

## Deneme

Normal açılışta demo servis her zaman başarılıdır; rastgele hata oluşturulmaz.
Üret'te Fikir Ver, ardından üretim düğmesi: yüklenme ve demo sonuç görünür.
Geri dönüldüğünde seçimler yerindedir.

İlk geçerli isteği bilinçli başarısız yapmak için:

```sh
flutter run --dart-define=MODY_DEMO_FAIL_FIRST=true
```

Tekrar Dene başarılı olur. Bayraksız yeniden başlatmak normal davranışı
geri getirir. Bayrak yalnızca fake servisin başlangıç senaryosunu belirler;
geçersiz form denemesi senaryoyu tüketmez.

## Doğrulama ve sınırlar

- `flutter test --no-pub`: **510 test başarılı** (473 önceki + 37 yeni).
  Üç eski test dosyasında eski “Bilgiler hazır” yer tutucu beklentisi yeni
  demo sonuç + geri dönüşe uyarlandı; doğrulama/seçim kontrolleri kaldırılmadı.
- Yeni 6 servis, 21 Cubit akış ve 10 widget testi: üç mod, hata/retry,
  double-submit, iptal/geç yanıt, kapanma, timeout, sonuç kimliği, cache'e
  yazmama, gerçek ana sekme geçişi ve sonuçtan geri dönüş.
- `flutter analyze --no-pub`: temiz. Android debug APK derlemesi başarılı.
- İsteğe bağlı `tool/preview_generation_test.dart`, ağsız olarak yüklenme,
  hata ve üç sonuç görünümünü PNG üretir. Önizleme fontu parametre ile verilir;
  platform altın görsel testi veya telefon görüntüsü değildir.
- Yeni hata/sonuç bileşenleri 320px ve 2× yazıda ayrı test edildi. Mevcut
  ana formun 1,4× testleri de geçti. Eski sabit yükseklikli seçenek kutuları ve
  alt çubuğun 2× yazıdaki taşması saptandı; ortak ekranların responsive
  düzenlemesi bu servis çalışmasına eklenmedi.
- Emülatör ADB'de görünse de Android package/activity servisleri
  `Broken pipe` / `DEAD_OBJECT` döndürdü. APK yükleme/açılış doğrulanamadı;
  başarılı canlı cihaz testi iddiası yoktur. Emülatör verileri silinmedi.

Gerçek AI için sonraki aşama: sağlayıcı API sözleşmesi, güvenli sunucu
kimlik doğrulaması, gerekirse job/polling, gerçek medya/hata modelleri ve
iptal/ücret politikası. Bu demo sözleşmesi tek başına bunların yerine geçmez.
