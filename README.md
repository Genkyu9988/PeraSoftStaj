# PeraSoft Staj

Bu proje, Mody AI uygulamasının ana ekranından esinlenilen bir Flutter arayüz
çalışmasıdır. Dart ve Flutter konuları staj süresince bu proje üzerinde
uygulanır.

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
- Örnek araba görselleri yerine dairesel yer tutucular kullanılır.
- Hedef görünüm 390 x 844 boyutundaki telefon portresidir.

## Explore önizlemesi

Explore sekmesi seçili olarak uygulama açılabilir:

```sh
flutter run -t lib/main_explore.dart
```

Normal `flutter run` komutu Üret ekranını açmaya devam eder.
Explore içinde Car Mods, Style Builder, Wallpaper Maker ve AI Edits bölümleri
beşer resimsiz mock seçenek içerir. Ana içerik dikey; Style Builder ve Wallpaper
Maker sıraları yatay kaydırılır. Kartlar Navigator ile detay ekranını açar;
alt çubuk dört ana bölüm arasında geçiş yapar.
Görsellerde yalnızca dört seçenek görünen iki yatay bölüme geçici olarak
Racing ve Night City isimleri eklenmiştir.

Kaynak: VB10/Flutter-Full-Learn reposunun #7 aşamasındaki `47ba0f3` sürümü.
`list_view_learn.dart` içindeki dikey/yatay liste ve sınırlı yükseklik yaklaşımı,
`list_view_builder.dart` içindeki `ListView.separated` ve
`stateless_learn.dart` içindeki ortak widget yaklaşımı kullanılmıştır.
Başlık ve alt çubuk iki ekranda ortak widget'lardır; yeni paket eklenmemiştir.

## AI Video önizlemesi

```sh
flutter run -t lib/main_ai_video.dart
```

AI Video Transformations ve AI Drive Scenes yatay kaydırılan beşer mock
seçenek içerir. AI Video Filters iki sütunda beş seçenek gösterir.
Ana içerik dikey kaydırılır. Başlık, kartlar ve yatay listeler Explore ile
ortaktır. Kartlar ortak mock resim seçimi detayını açar; gerçek resim,
video oynatıcı veya API bağlantısı yoktur.
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

## Henüz kapsamda olmayanlar

- Yapay zekâ veya servis bağlantısı
- Gerçek araç görselleri

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
