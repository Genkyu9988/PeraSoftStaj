# Demo üretim geçmişi — 8 Ekim 2026

9 Ekim güncellemesi: üretim ortamındaki depolama SQLite'a geçti. Aşağıdaki
SharedPreferences açıklaması ilk sürümün tarihli kaydı ve legacy taşıma
okuyucusu için geçerlidir. Güncel [SQLite şeması ve geçiş](sqlite_history.md).

Üret'in üç modu, Explore ve AI Video'daki kabul edilmiş başarılı demo
işlemleri artık ortak geçmişe eklenir. Araç seçme panellerindeki Your
Creations ve profil/Garaj aynı listeyi kullanır. Gerçek AI eklenmedi.

## Davranış

- Geçmiş tüm araç seçme panellerinden görülebilir. Bir karta dokunmak
  yalnız taslağı değiştirir; Uygula orijinal aracı seçer, kapatma iptal eder.
  Bu demolar yeni bir görsel içermediğinden dönüştürülmüş görsel seçilmez.
- Garaj'ın Tümü / Mody's / Videolar filtreleri ile profil sayaçları ortak
  listeden hesaplanır. Videolar, video isteğinin **demo kayıtlarıdır**;
  dosya/oynatıcı yoktur. Kartlarda bu açıkça belirtilir.
- Garaj kartı kaydedilmiş seçimlerle mevcut demo sonuç ekranını açar;
  yeniden üretim yapmaz. Garaja Dön veya sistem geri tuşu sayaç artırmaz.
- Hata, iptal, zaman aşımı, kapanmış ekran ve iptalden sonraki geç cevap
  kayıt oluşturmaz. Başarılı yeniden deneme bir kayıt oluşturur.
- Aynı seçimlerle ayrı bir başarılı işlem yapmak yeni kayıttır. Aynı
  tamamlanma/navigasyon olayının iki kez sayılmasıyla karıştırılmamalıdır.
- Eski sürümde işlem geçmişi tutulmadığından önceki denemeler geri
  getirilemez. Bu özellikten sonraki başarılı demolar saklanır.

## Sorumluluklar

| Parça | Sorumluluk |
| --- | --- |
| `CreationRecord` | Kimlik, UTC tarih, demo sonucu ve değişmez girdi anlık görüntüsü; açık JSON dönüşümü |
| `CreationRepository` | Depolama sözleşmesi; test/önizlemede bağımsız bellek uygulaması |
| `CreationCacheManager` | JSON şeması ve katalog doğrulaması, mevcut SharedManager üzerinden cihaz kaydı |
| `CreationHistoryCubit` | Ortak liste, ilk okuma/yeni kayıt birleştirme, sıralı yazma, ayrı depolama hata durumu |
| `GenerationFlowCubit.onCompleted` | Yalnız geçerli güncel başarıyı bildirme; depolama teknolojisini bilmez |
| `CreationGrid` | Veriyi/callback'i dışarıdan alan ortak kart görünümü |

`runModyApp` gerçek cihaz cache'ini verir. `MyApp`'ın varsayılan bellek
deposu test/önizlemeleri plugin ve diskten bağımsız tutar. Ortak Cubit
MaterialApp'ın üstündedir; yeni sayfalar ve root seçim panelleri de aynı
nesneyi görür. Tüm uygulama state'i Cubit'e taşınmadı.

Anahtar: `modyai.v1.creations`; içerik şeması `version: 1`. Seçimlerin
`modyai.v1.selections` anahtarı değiştirilmedi. Fotoğraf baytları/base64
yerine mevcut asset referansı saklanır. AI Video'nun demo sonucu hâlâ image
medya türündedir; yalnız istek türüne göre video-demo filtresine girer.

Bu küçük yerel demo geçmişidir; bulut yedekleme, hesaplar arası eşitleme
veya kritik veriler için dayanıklılık garantisi değildir. Uygulama
kaldırılması/verilerinin temizlenmesi yerel geçmişi de kaldırabilir.

## Hatalar ve veri koruma

Geçmiş okunamazsa mevcut disk kaydı boş listeyle ezilmez. Yeni demolar
oturumda görünür, kullanıcıya uyarı ve Kaydı tekrar dene gösterilir.
Tekrar okuma başarılı olursa eski ve yeni kayıtlar birleştirilir.

Desteklenmeyen sürüm, bozuk JSON, bilinmeyen katalog girdisi, geçersiz görsel
veya yinelenen kayıt kimliği tüm dosyanın yüklenmesini durdurur; boş/hayalet
kart üretilmez ve dosya korunur. Kalıcı bozuk dosyayı otomatik silme veya
sessizce kısmi veri kaybı yoktur; kurtarma/sürüm geçişi ayrı çalışma ister.

Yazma hatası üretim hatasına çevrilmez. Sonuç ve oturumdaki liste korunur;
kaydı yeniden denemek üretimi tekrarlamaz. Hızlı başarılar için yazmalar
sıralıdır. İlk açılıştaki geç okuma yeni başarıları ezmez.

## Derslerden nasıl yararlanıldı?

- **Temelden Zirveye #12:** 20–25. dakika ortak SharedManager;
  43–46 modele özel UserCacheManager ve dışarıdan bağımlılık;
  48–54 ve 62–72 JSON/model dönüşümü, başlatma ve hata ayıklama.
  Yerel MP4'ten 12 zaman damgalı kare, ilgili transkript bölümleri ve
  [sabit repo sürümü](https://github.com/VB10/Flutter-Full-Learn/tree/a97929b6d06c35b9353551a207150388d30ec784/lib/202/cache)
  karşılaştırıldı. Tam video kesintisiz izlenmiş sayılmaz.
- Örnek dosyalar: `shared_manager.dart`, `user_cache/user_cache_manager.dart`,
  `user_model.dart`, `shared_list_cache.dart`. Eski SharedPreferences
  başlatma kodu kopyalanmadı; mevcut SharedPreferencesAsync korundu.
- **#9/#18:** Servis sonucu, asenkron hata ayrımı, bağımlılığın dışarıdan
  verilmesi ve kontrollü sahte servisle ağsız test yaklaşımı sürdürüldü.
- **#19 ve Mimari v2 #11:** Değişmez state ve ortak Cubit; builder içinde
  kayıt/navigasyon yok. Başarı bildirimi mevcut ortak akışta yapılır.
- **#4/4.2/#5 ve Mimari v2 #8:** Parametreli ortak kart, dar ekran ve büyük
  yazıda tek sütuna geçen liste, kaydırma ve seçim paneli davranışı.
- **Mimari v2 #13:** Bağımsız repository ve kontrollü servis kullanılarak
  model/cache, state ve gerçek ekran akışları ayrı sınandı.

Mimari kaynak repo:
[architecture_template_v2 — 4c1cbae](https://github.com/VB10/architecture_template_v2/tree/4c1cbaefbea2281f377a33eb3052348b5cf3e225).
Önceki incelemenin ayrıntıları [learning_sources.md](learning_sources.md)'de.
Kimlik üretme, tek başarı kaydı, geç cevap engeli, bozuk dosyayı koruma ve
demo-video sınıflaması öğretmenin hazır örneği değil, ürün uyarlamalarımızdır.

Hive, JWT, compute, gerçek API, galeri/kamera veya video oynatma eklenmedi.

## Doğrulama

Bu özelliğin ilk doğrulaması: **836 test başarılı** (91 yeni test), `flutter analyze
--no-pub` temiz, `flutter build apk --debug --no-pub` başarılı.

Stil düzeltmesiyle birlikte güncel paket ve kullanıcının sonraki manuel
sonuçları [9 Ekim doğrulama notunda](demo_release_verification.md) tutulur.

Android emülatöründe mevcut uygulama verileri silinmeden güncel APK
kuruldu: Üret'te demo başarı → Garaj'da kart/sayaç; uygulamayı zorla
kapatıp yeniden açma → aynı kaydın korunması doğrulandı. Bu fiziksel
Android/iOS cihaz testi veya tüm modların emülatör matrisi değildir.
Yeniden açılıştan sonra Your Creations panelinde de aynı kayıt görüldü.
Ekran görüntüleri yerel doğrulama klasöründe tutuldu, repoya eklenmedi.

`creation_history_test.dart`: 55 mevcut girdi türünün JSON gidiş-dönüşü,
ayrı cache anahtarı, bozuk/eski veri, ilk okuma yarışı, yazma sırası,
hata/yeniden deneme, kapanmış Cubit, zaman aşımı ve geç cevaplar.

`creation_history_widget_test.dart`: Your Creations Uygula/iptal davranışı
Üret'in üç modu, Explore ve AI Video'da 390px/1x ve 320px/2x ölçülerinde;
Garaj filtre/sayaç/detay; gerçek demo akışından kayıt ve yeniden açılış;
üretimden bağımsız kayıt hatası/tekrar deneme.

Dar ekranda büyük profil üst içeriği kaydırılabilir; testte başlık alanından
kaydırarak alttaki listeye erişim de kontrol edilir.

## Kullanıcının manuel doğrulaması — 9 Ekim 2026'da derlenen sonuçlar

- Uygulama tamamen kapatılıp açıldığında Garaj kayıtları, sayaçlar ve
  Your Creations içeriği korundu (kullanıcı teyidi).
- Hazırlanırken Vazgeç: yeni kayıt oluşmadı, sayaç değişmedi (kullanıcı teyidi).
- AI Video / Cliff Drive / Mustang GT: hata panelinden Tekrar Dene ile demo
  sonuca ulaşıldı. Ekran görüntülerinde 4 Mody's / 1 video → 4 Mody's / 2 video
  geçişi görüldü. Başarısız deneme ve yeniden deneme birlikte yalnız bir yeni
  kayıt ekledi; eski Mustang kaydı önceki ayrı başarılı işlem olarak korundu.
- Garaj kaydını açıp Garaja Dön: sayaç değişmedi (kullanıcı teyidi).
- Daha önceki 2 → 3 Mody's artışı, kullanıcının arada ayrıca görsel demo
  oluşturmasıyla açıklandı; AI Video'nun görsel sayacını artırdığına kanıt değil.

Bu sonuçlar kullanıcının bildirdiği test ortamına aittir; fiziksel cihaz/iOS
matrisinin tamamlandığı veya gerçek görsel/video üretildiği anlamına gelmez.
