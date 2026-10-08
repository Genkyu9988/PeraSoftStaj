# Explore ve AI Video: uyarılar — 4 Ekim 2026

Bu değişiklik, kullanıcının orijinal uygulamadan gönderdiği ekran görüntüleri ve
metinsel teyitleriyle doğrulanan eksik-seçim uyarılarını uygular. Diğer 13 Car
Mods, kullanıcının açık isteğiyle aynı ailedeki Neon/Tire davranışına göre
genellenmiştir; bu kartların orijinalde tek tek teyit edildiği iddia edilmez.
İş kuralları eğitim reposundan alınmış değildir; repo, kodu düzenleme
yaklaşımının kaynağıdır.
Gerçek görsel/video üretimi, kredi, galeri/kamera ve mevcut kapak/katalog
görsellerinin değiştirilmesi kapsamda değildir. Başarılı doğrulama mevcut mock
bilgilendirmesine gider.

## Kurallar ve kanıt kapsamı

| Ekran | Önce | Sonra | Yeterli girdi |
| --- | --- | --- | --- |
| Change Color dışındaki 15 Car Mods | Araç görseli | Sağdaki modifikasyon seçimi | Araç + seçenek |
| Change Color | Araç görseli | Renk | Araç + renk |
| Clone Car Style | Araç görseli | Referans görsel | Araç + referans |
| Explore Style Builder, Wallpaper Maker, Clone dışındaki AI Edits | Araç görseli | — | Yalnızca araç |
| AI Video | Araç görseli | — | Yalnızca araç |

Mesajlar noktalama ve dilleriyle korunur:

- Araç eksik: `Lütfen önce bir görsel seçin`
- Car Mods seçeneği eksik (Change Color hariç): `Lütfen önce bir hedef görsel seçin`
- Renk eksik: `Lütfen önce bir renk seçin`
- Clone aracı eksik: `Please upload your car image or select inspire image first`
- Clone referansı eksik: `Please upload the reference image.`

İki giriş de boşsa yalnızca araç mesajı çıkar. Sağ girişin dolu olması araç
eksikliğini karşılamaz. Clone'ın ilk mesajındaki "or", referansın tek başına
yeterli olduğu anlamına gelmez. Örnek araç seçimi de sol görsel gereksinimini
karşılar. Görsellerde araç seçili ancak Neon/Tire/renk/referans boşken ilgili
ikinci uyarı ayrıca gözlenmiştir.

Tek görselli Explore bölümlerindeki ortak mesaj kullanıcı tarafından açıkça
teyit edilmiştir; American ekranı görsel örnektir. AI Video'nun üç grubundan
Apex Transform, Cliff Drive ve Race Video ekranları aynı araç mesajını gösterir.
Ortak tek-görsel akışı mevcut 15 video kartına uygulanır; 15 kartın tamamının
orijinal uygulamada ayrı ayrı denendiği iddia edilmez.

### Kullanıcı onaylı genelleme ve korunan davranışlar

Neon, Tire ve Change Color dışındaki 13 Car Mods kartı: Customize Rims,
Suspension, Spoiler, Sound System,
Window Tints, Exhaust, Chrome Delete, Body Kit, Perspective, Mirror Swap,
Sunroof Mood, Put On Sticker, Upholstery. İlk uygulamada bu kartların pasif
butonları korunmuştu. Sonraki kullanıcı isteği, benzerliklerine göre aynı
yapının bu ekranlara da uygulanmasıdır. Artık butonları aktiftir; araç eksikse
araç, araç varken sağ seçenek eksikse hedef görsel mesajı çıkar.

Bu, **kullanıcı tarafından onaylanmış bir ürün varsayımıdır**; yeni ekran
görüntüleriyle doğrudan kanıtlanmış davranış olarak sunulmaz. Ortak iki-girişli
Car Mods kuralı gelecekte aynı türde eklenen başlıklara da uygulanır; tek-görsel
kuralına düşülmez. Change Color, Clone ve video istisnaları ayrı korunur.

Uyarılar artık 37 Explore + 15 AI Video = 52 kartın tamamında etkindir.

Araçsız sağ-giriş seçimi gösteren ekran görüntüsü işlem sırasını kanıtlamaz.
Bu nedenle panellerin açılışına yeni bir araç ön koşulu eklenmedi; mevcut
bağımsız seçim davranışı korundu. Üret ekranındaki kurallar, özellikle
Detail Edit için yalnızca araç + açı şartı, değiştirilmedi.

## Kodun sorumlulukları

- `ExploreValidationMessages`: Beş mesajın tek tanımı.
- `ExploreValidator`: Flutter/context/cache bağımlılığı yok. Onaylı girdileri
  alır; ilk hata mesajını, geçerli durumda `null` döndürür. Tipli
  `ExploreValidationRule` renk/hedef/referans/tek-görsel ayrımını yapar.
- `ruleFor`: Kartı görsel, hedef görsel, renk veya Clone kuralına eşler;
  artık nullable değildir. Car Mods için geçici pasif-butonu istisnası ve
  ekrandaki tekrarlanan zorunlu-girdi kontrolü kaldırılmıştır. Tek doğrulama
  noktası `ExploreValidator.validate` metodudur.
- `ExploreDetailView`: Doğrulamayı buton eyleminde çağırır. Hata varsa gösterip
  döner; başarıda mevcut mock mesajına geçer. Kontrol `build` sırasında uyarı
  üretmez. Yalnızca Apply/onaylı seçimler kullanılır.
- `ModyWarningContent`: Üret SnackBar'ı ile Explore bildiriminin ortak beyaz
  ikon/metin görünümü; uzun metin `Expanded` içinde satıra sarılır.
- `SelectionWarningFrame`: İş kuralı içermeyen, giriş kartlarının alt kenarına
  bağlı kırmızı bildirim. Sabit ekran koordinatı kullanılmaz. `IgnorePointer`
  sayesinde kullanıcı alttaki seçime dokunabilir; `liveRegion` erişilebilirlik
  bildirimi sağlar.

Bildirim route-local durumdur: global overlay veya kalıcı cache kaydı değildir.
Tekrar basış aynı bildirimi yeniler; kuyruk oluşturmaz. Araç/sağ seçim değişimi,
seçim panelinin açılması ve geri dönüş eski bildirimi temizler. Timer `dispose`
içinde iptal edilir; kapalı ekrana `setState` yapılmaz. Mevcut sheet `mounted`
ve `null` kontrolleri, panel kilidi, Apply/iptal ayrımı korunur.

Uyarı seçimleri değiştirmez, `onApplied` çağırmaz ve cache yazmaz. Araç
kaldırılınca sağdaki seçim korunur. Küçük ekranda gerekirse giriş kartları
görünür alana kaydırılır.

**Projeye özel tercihler:** 4 saniye gösterim süresi ve gerektiğinde otomatik
kaydırma. Orijinal uygulamanın süre/animasyon/kaydırma davranışının durağan
ekran görüntülerinden kesinleştiği iddia edilmez. Üret'in alt SnackBar konumu
aynen taşınmadı; Explore ekran görüntülerindeki kart çevresi yerleşimi esas
alındı. Yeni paket, singleton, state-management veya servis katmanı eklenmedi.

## Öğretmenin vurguları ve kullanılan gerçek kaynaklar

Yerel transkriptlerin ilgili bölümleri okunup GitHub koduyla karşılaştırıldı;
videoların tamamının yeniden izlendiği iddia edilmez. Ders numaraları yerel
transkript adlarıdır, GitHub README'deki sıralı liste indisleri değildir.
Otomatik transkriptlerdeki teknik terim hataları kaynak kodla karşılaştırılmıştır.

### #11 — Extension, OOP, Mixin, Form Validate

[Video](https://www.youtube.com/watch?v=W2zCsxTVVDE)

Transkript: `Temelden Zirveye Flutter#11 Extension, OOP,  Mixin, From Validate.txt`

- 63:34–64:56 ve 65:35–67:49: Geçerli durumda null, hata durumunda mesaj;
  doğrulamadan işleme devam etmeme.
- 67:53–68:44: Otomatik doğrulamanın bütün formu tetiklemesine dikkat.
- 69:12–70:55: Kontrolleri ayrı validator'a çıkarma, küçük tekrar kullanılabilir
  bileşenler. Burada ürün kuralları ekrandan ayrıldı.
- 71:06–71:58: Tek dilde bile mesajları merkezi sınıfta tutma.

[form_learn_view.dart](https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/202/form_learn_view.dart)
içindeki `FormFieldValidator` ve `ValidatorMessage` somut karşılıklardır.
Form/GlobalKey ve `AutovalidateMode.always` birebir kopyalanmadı: bu ekranda
görsel seçimleri ve öncelikli ilk-hata kontrolü gerekir. İlk açılışta uyarı yoktur.

### #13 — Sheet, Dialog, Generic

[Video](https://www.youtube.com/watch?v=9oP15tsQHsU)

Transkript: `Temelden Zirveye Flutter#13 Sheet komponenti, Dialog, Xcode Android Studio inceleme, Generic etc..txt`

- 03:21–04:36: Seçim, karar ve kısa bildirim için uygun bileşeni seçme.
- 17:30–17:58: Kapanmış ekranın context/yaşam döngüsüne dikkat etme.

[alert_learn.dart](https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/202/alert_learn.dart)
dialog örneğidir; kırmızı uyarının hazır kodu değildir.
[sheet_learn.dart](https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/202/sheet_learn.dart)
nullable/generic sheet sonucunu ve bileşen ayrımını gösterir. Bizde mevcut sheet
akışı korundu; kart üzerinde geçici bildirim görünümü projeye özel uyarlamadır.

### #18 — Picker, Vexana, Runner düşüncesi ve detayları

[Video](https://www.youtube.com/watch?v=MBOrcEErqPw)

Transkript: `Temelden Zirveye Flutter #18 Picker, Vexana, Runner düşüncesi ve detayları.txt`

- 02:17–02:49: Test edilebilir kodun önemi.
- 17:17–17:40: Dışarıdan parametre alarak test edebilme.
- 18:44–18:58: Sadece kütüphane eklemek değil, test düşüncesi.
- 33:06–38:42: Bağımlılığı ayırma ve kontrollü karşılıkla sonuç sınama.

[user_save_model.dart](https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/303/testable/user_save_model.dart)
ve [req_res_test.dart](https://github.com/VB10/Flutter-Full-Learn/blob/main/test/req_res_test.dart)
bu düşüncenin örnekleridir. Bizde doğrulayıcı sadece girdi aldığı için ek mock
kütüphanesine gerek olmadan var/yok kombinasyonları sınanır. Depolama arayüzü
ve servis katmanı bu özellik için tekrar oluşturulmadı.

Tamamlayıcı resmi belgeler:
[showSnackBar](https://api.flutter.dev/flutter/material/ScaffoldMessengerState/showSnackBar.html),
[clearSnackBars](https://api.flutter.dev/flutter/material/ScaffoldMessengerState/clearSnackBars.html),
[Stack](https://api.flutter.dev/flutter/widgets/Stack-class.html).

## Doğrulama sonucu

- `flutter test --reporter failures-only`: **331 test başarılı**.
- `flutter analyze`: **No issues found**.
- Yeni 38 saf doğrulayıcı testi: dört kuralın araç/seçenek/referans var-yok
  kombinasyonları, boşluklar, birebir metinler, tüm katalog eşlemeleri ve
  bütün Car Mods için ortak kural ve özel ekran istisnaları.
- 92 widget testi: 320/390 genişlikte 16 Car Mods + Clone için dört çift-giriş durumunun tamamı,
  35 tek-görselli kart, iptal/Apply, seçimin korunması, uyarıda cache callback'i
  çalışmaması, tekrarlanan basış/süre yenileme, uygulama ve sistem geri dönüşü.
  İptal/Apply ve araç kaldırmada sağ seçimin korunması bütün 16 Car Mods ve
  Clone için sınanır. Geçersiz/eski katalog seçimi üretim koşulunu karşılamaz.
- 320×568 kısa ekranda normal ve 1.4 kat yazı ölçeği kontrol edildi.
- Gerçek fontlarla 16 görüntü render edilip görsel olarak incelendi. Görseller
  git tarafından yok sayılan `.dart_tool/explore_previews/` altında; üretici
  `.dart_tool/explore_warning_visual_check_test.dart`.
- Önceki pasif-butonu bekleyen Clone, bütün Car Mods ve ortak action testleri
  yeni tıklanabilir-uyarı davranışına güncellendi. Yalnızca seçim panelindeki
  Uygula butonu onaylanabilecek bir seçim yokken pasif kalır.
- Üret'in mevcut doğrulama/seçim testleri dahil tüm eski testler geçer.

Görsel kontrol Flutter test ortamında yapıldı; emülatörde veya kullanıcının
telefonunda bu turda çalıştırıldığı iddia edilmez.
