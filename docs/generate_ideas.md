# Fikir Ver ve Custom Edit metin önerileri — 5 Ekim 2026

Bu çalışma yerel katalogdan öneri üretir; AI servisine veya başka bir ağa
istek göndermez. Orijinal uygulamanın önerileri nasıl ürettiğine ilişkin
bir teknik iddia içermez. Aşağıdaki ürün kuralları kullanıcı tarafından
doğrulanmıştır; öğretim örnekleri bu kuralların kaynağı değildir.

## Onaylanan davranışlar

| Eylem | Değişen alanlar | Korunan alanlar |
| --- | --- | --- |
| Style Builder / Fikir Ver | Araç, bir stil, bir ekstra, bir renk | Detail açı/parça/renk, Custom açıklama |
| Custom Edit / Fikir Ver | Yalnızca araç | Açıklama ve iki diğer modun seçenekleri |
| Custom Edit / sihirli ikon | Açıklama, eski metnin yerine | Araç ve bütün seçimler |
| Detail Edit / Fikir Ver | Araç, açı, o açıdan tek parça, renk | Style seçenekleri, Custom açıklama |

- Araç, yalnızca beş örnekten değil, mevcut `VehicleCatalog.all` listesinin
  tamamından seçilir. Yeni araç, stil veya ekstra eklenmez.
- Renk havuzu mevcut Mat/Premium/Özel kategorilerindeki 12 seçenektir.
- Custom Edit araçsız da metin önerebilir. Üretim hâlâ araç ve boş olmayan
  açıklama ister. Metni kullanıcı düzenleyebilir; çarpı açıklamayı temizler.
- Metin havuzu, kullanıcının gönderdiği iki İngilizce açıklamadan oluşur.
  Metin üretimi yereldir; görseli inceleme veya araç tanıma yapılmaz.
- Aynı rastgele değer arka arkaya gelebilir. Farklı sonuç çıkana kadar dönen
  bir yeniden-deneme döngüsü yoktur.
- Bu eylemler üretimi başlatmaz. Mevcut doğrulama ve mock sonuç akışı korunur.
- Araç seçimi üç Üret modu arasında zaten ortaktır; bu davranış değiştirilmez.
- Açıklama daha önce olduğu gibi oturumluk kalır. Seçenekler mevcut kayıt
  akışına gönderilir; açıklama için yeni kalıcı kayıt alanı eklenmez.

## Detail Edit: bağımlı seçim sırası

Önce açı, ardından `DetailPartCatalog.forAngle(angle)` içinden kategori,
son olarak o kategorinin görsellerinden bir indeks seçilir. `all` parça
listesinden açıdan bağımsız seçim yapılmaz.

| Açı | İzin verilen kategoriler |
| --- | --- |
| Front | Front Bumper, Hood, Headlights |
| Rear | Spoiler, Exhaust, Rear Bumper & Diffuser, Tail Lights |
| Side | Spoiler, Rims/Wheels, Exhaust, Front Bumper, Rear Bumper & Diffuser, Hood, Side Skirts |

Her öneri eski parça haritasının tamamını tek yeni seçimle değiştirir.
Aynı açı tekrar seçilse de eski ek parçalar yeni öneriye taşınmaz.

Bu davranış **kullanıcının orijinal uygulamadan farklı olmasını istediği**
özelliktir: referans uygulamada Detail Fikir Ver yalnızca araç seçiyordu.
Manuel açı değişimi ise önceki kuralını korur: farklı açı Apply ile
onaylanırsa parçalar temizlenir, renk korunur; aynı açı veya iptal parçaları
silmez. Araç kaldırmak diğer seçimleri temizlemez.

## Sorumluluklar ve öğretmenin yöntemlerinin uyarlanması

- `GenerateOptionCatalog`: Manuel panel, rastgele öneri ve cache doğrulaması
  aynı stil/ekstra/renk tanımlarını kullanır. Eski kayıt değerleri değişmedi.
- `GenerateSuggestions`: Widget/context/cache/ağ bağımlılığı olmayan seçici.
  `Random` dışarıdan verilebilir. Sonucu tipli ve final alanlı küçük modellerle
  döndürür; açı ve parça ilişkisi burada kurulur.
- `ModificationPrompts`: İki yerel metnin tek tanımı.
- `ModyHomeView`: Alt butonlardan callback alır; öneriyi tek `setState` ile
  uygular ve tek `_notifyApplied` çağrısıyla kayda bildirir. Rastgele işlem
  `build` içinde çalışmaz. Metin mevcut controller üzerinden güncellenir;
  imleç sona alınır, eski uyarı temizlenir. Controller sahipliği/dispose korunur.
- `_IdeaArea` / `_DescriptionIconArea`: İş kuralı bilmeyen tıklanabilir bileşenler.
- Mevcut `SelectionCacheManager` yazma sırası ve panel Apply/iptal akışı korunur.
  Yeni paket, singleton veya state-management sistemi eklenmez.

### Kontrol edilen eğitim kaynakları

Transkriptlerin ilgili bölümleri okunup repo kodlarıyla karşılaştırıldı;
videoların tümünün yeniden izlendiği iddia edilmez. Numara, yerel transkript
dosyasındaki ders numarasıdır; GitHub README listesinin sıra numarası değildir.
Transkriptler `C:/Users/andin/Downloads` altındaki Temelden Zirveye Flutter
metin dosyalarıdır. Otomatik transkript teknik terimleri kodla doğrulanmıştır.

| Ders / transkript aralığı | Gerçek öğretim noktası | Kod karşılığı |
| --- | --- | --- |
| [#14 Callback / Custom Button](https://www.youtube.com/watch?v=YSN-1OiNnLM), 10:47–11:51; 26:17–30:29 | Alt/üst bileşen callback iletişimi; `Random().nextInt(10)`; sonuçla state güncelleme | [answer_button.dart](https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/product/widget/button/answer_button.dart), [call_back_learn.dart](https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/303/call_back_learn.dart) |
| [#7 List / Model](https://www.youtube.com/watch?v=NtVN5rr579Y), 56:49–58:13; 70:14–71:27 | Zorunlu/final model alanları; bileşene tüm liste/indeks yerine ilgili model | [my_collections_demos.dart](https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/demos/my_collections_demos.dart) |
| [#6 State / yaşam döngüsü](https://www.youtube.com/watch?v=YSbQ5_yS2ug), 52:23–52:58; 63:13–64:33 | İlk hazırlık ve ekranın kaynaklarının yaşam döngüsü | [statefull_life_cycle_learn.dart](https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/101/statefull_life_cycle_learn.dart) |
| [#18 Test edilebilirlik](https://www.youtube.com/watch?v=MBOrcEErqPw), 02:17–02:49; 17:18–17:40; 35:40–38:42 | Bağımlılığı dışarıdan alarak testte kontrollü karşılık kullanma | [user_save_model.dart](https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/303/testable/user_save_model.dart), [req_res_test.dart](https://github.com/VB10/Flutter-Full-Learn/blob/main/test/req_res_test.dart) |
| [#12 Cache](https://www.youtube.com/watch?v=_v7m71TXFww), 20:21–21:38; 23:48–24:30 | Ortak kayıt yöneticisi | [shared_manager.dart](https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/202/cache/shared_manager.dart) |
| [#11 Form](https://www.youtube.com/watch?v=W2zCsxTVVDE), 69:12–70:55; 71:06–71:58 | Ayrı validator ve merkezi mesajlar | [form_learn_view.dart](https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/202/form_learn_view.dart) |

Açıya göre kategori süzme, tek işlemde kayıt bildirimi, ortak seçenek kataloğu
ve metin havuzu bizim projeye özgü uyarlamalarımızdır. Dersin hazır özelliği
olarak sunulmaz. `random_image.dart` rastgele katalog seçimi değildir;
ağ görseli gösteren bir bileşendir ve bu algoritmaya kaynak alınmamıştır.

Resmî teknik doğrulama: [Random.nextInt](https://api.dart.dev/dart-math/Random/nextInt.html)
üst sınırı dışlar; indeks gerçek liste uzunluğundan üretilir.
[TextEditingController](https://api.flutter.dev/flutter/widgets/TextEditingController-class.html)
metin/imleç birlikte değiştirilirken `value` kullanımı ve dispose gerekliliğini
açıklar. Öğretmenin eski API kullanımları birebir kopyalanmamıştır.

## Arayüz kapsamı

- Üret sekmelerinin yanındaki soru işareti ve Canlı Edit bileşeni kaldırıldı.
  Yeni bir rehber ekranı yapılmadı. Üç mod sekmesi kalan genişliği paylaşır;
  Detail üretim butonu tam kullanılabilir genişliğe açılır.
- Dar ekranda sekme yazıları kesilmeden sığar. 700 pikselden kısa ekranlarda
  araç önizlemesi 140 piksel; klavye açıkken önceki 100 piksel davranışı korunur.
- Açıklama kartı yazı ölçeğiyle büyür; temizleme düğmesi başlığın yanında,
  sihirli ikon metin alanının sağ altındadır. Büyük yazıda iki eylemin tıklama
  alanları çakışmaz. Kısa ekranda içerik kaydırılabilir.
- Galeri/kamera eklenmedi. AI Video kapakları statik görsel kalır.

## Test kapsamı

- Kontrollü `SequenceRandom`: beklenmeyen rastgele çağrı veya hatalı indeks
  testte başarısız olur. Belirli bir sonucun şans eseri çıkması beklenmez.
- 12 aracın tamamı, 12 renk ve bütün stil/ekstra seçeneklerine erişim.
- Front 9, Rear 12, Side 21: toplam 42 açı/kategori/parça birleşimi.
- Öneri değerlerinin JSON kaydından kayıpsız geri yüklenmesi.
- 320/390 genişliklerde UI, manuel panel seçili durumu, Apply/iptal,
  araçsız sihirli metin, değiştirilebilir/temizlenebilir açıklama,
  eski parçaların tamamen değiştirilmesi ve modlar arası seçim korunması.
- Ana sekmeler üzerinden kayıt yöneticisine her fikir için tek yazma,
  uygulama ekranı yeniden oluşturulunca seçimlerin yüklenmesi.
- Hızlı ardışık öneriler, kısa ekran, büyük yazı ve klavye yaşam döngüsü.
- Görsel test üreticisi `.dart_tool/generate_ideas_visual_check_test.dart`;
  12 gerçek fontlu önizleme `.dart_tool/idea_previews` altında, git tarafından
  yok sayılır. Görsel inceleme test ortamındadır; telefon/emülatör testi değildir.

## Son doğrulama

- `flutter test --reporter failures-only`: **423 test başarılı**.
- Bu özellik için 71 saf seçim/katalog testi ve 21 widget/entegrasyon testi
  eklendi; önceki 331 test de geçiyor.
- `flutter analyze`: sorun yok.
- Değişen 9 Dart dosyasının format kontrolü temiz; `git diff --check` temiz.
- 320/390 genişlik, 844 ve kısa ekran için 568 yükseklik, kısa ekranda 1.4 yazı
  ölçeğiyle 12 önizleme üretildi ve incelendi. Uzun açıklama alanı ve kısa
  ekranın içeriği kaydırılarak kullanılır. Büyük yazıda eylemlere erişim ayrıca
  widget testleriyle doğrulandı.

## Açık debug oturumundaki Fikir Ver düzeltmesi — 5 Ekim 2026

- Kullanıcının üç modda da tepki alamadığı oturumda, VM üzerinden çalışan
  kodun güncel olduğu ancak `_suggestions` alanının `NotInitialized` kaldığı
  doğrulandı. Yeni alan yalnızca `initState` içinde atanıyordu; hot reload
  mevcut `State` için bu metodu tekrar çalıştırmaz.
- Başlatma, `late final` alanın ilk kullanımda çalışan initializer'ına taşındı.
  Test bağımlılığını dışarıdan alma ve tek öneri nesnesi kullanma korunuyor.
  Bu düzeltme proje teşhisidir; bir dersin birebir örneği olarak sunulmaz.
- Aynı çalışan oturuma hot reload uygulandı; daha önce başlatılmamış alanın
  ilk erişimde `GenerateSuggestions` nesnesine dönüştüğü canlı VM'de görüldü.
- Önceki değişikliklerden kalan eski model nesnelerini de yenilemek için
  emülatörde hot restart yapıldı. Uygulama verisi silinmedi. Üret ekranının
  yeniden başlatma öncesindeki seçimleri geri yüklendi.
- Açık emülatörde gerçek `TextButton` bileşeninin `onPressed` callback'i debug
  bağlantısıyla üç modda çağrıldı: Style dört alanı doldurdu; Custom araç
  seçti ve açıklamayı korudu; Detail `Rear / Exhaust` uyumlu seçimi yaptı.
  Test seçimleri sonrasında önceki seçimler geri yüklendi. Bu kontrol fiziksel
  ekran dokunuşu değildir; butona dokunma ve hit-test widget testlerindedir.
- Üretimdeki varsayılan öneri nesnesini kullanan yeni widget testi, reassemble
  sonrasında üç modun da çalıştığını kontrol eder. Canlı VM'ye sonradan alan
  eklenmesini tek başına simüle ettiği iddia edilmez.
- Sihirli metin düğmesi bu hata düzeltmesinde değiştirilmedi; AI API eklenmedi.
