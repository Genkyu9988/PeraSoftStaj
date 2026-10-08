# Detail Edit: açıya göre Ayarla — 4 Ekim 2026

Bu adım yalnızca açıya bağlı parça kategorileri, görseller, Uygula/iptal ve
seçim kaydı içindir. Üret düğmesinin eski doğrulama kuralları, kırmızı uyarı
mesajları, galeri/kamera ve AI servisi bu değişiklikte uygulanmadı.

Sonraki adım notu: Üret doğrulaması ve açı yokken panel açılmadan verilen
kırmızı uyarı artık [Üret uyarıları](generate_warnings.md) çalışmasında
uygulanmıştır. Aşağıdaki bekleyen-uyarı açıklamaları bu ilk adımın tarihçesidir.

## Ürün kuralları

Kategori listeleri kullanıcının orijinal uygulamadaki gözlemleri ve
ekran görüntülerinden alınmıştır; VB10 dersinin öğrettiği iş kuralları değildir.

| Açı | Ayarla kategorileri (sıralı) |
| --- | --- |
| Front | Front Bumper, Hood, Headlights |
| Rear | Spoiler, Exhaust, Rear Bumper & Diffuser, Tail Lights |
| Side | Spoiler, Rims/Wheels, Exhaust, Front Bumper, Rear Bumper & Diffuser, Hood, Side Skirts |

- 9 ortak kategori ve her birinde 3 temsili fotoğraf vardır. Aynı kategori,
  örneğin Hood, Front ve Side için aynı katalog nesnesini kullanır.
- Kategoriler dikey, kategori içindeki seçenekler yatay kaydırılır. Uygula
  düğmesi sabittir. Bir kategoriden tek seçenek seçilir; bütün kategorileri
  doldurmak gerekmez. Panelde tek bir parçayı uygulamak yeterlidir.
- Seçenek dokunuşu taslağı günceller; sadece Uygula kalıcı seçimi değiştirir.
  Panel iptali, geri ve dışarı dokunma onaylı seçimi değiştirmez.
- Farklı bir açı Uygula ile onaylanınca bütün parça seçimleri temizlenir.
  Renk, araç ve Style Builder seçimleri korunur. Kullanıcının doğruladığı
  Rear -> Front davranışı bütün farklı açı geçişlerine uygulanmıştır.
- Aynı açıyı tekrar uygulamak veya açı panelini iptal etmek parçaları silmez.
  Eski açıya geri dönmek eski parçaları otomatik geri getirmez.
- Araç kaldırılır/değiştirilirse açı, parçalar ve renk korunur.
- Açı yokken rastgele Rear listesi gösterilmez; panelde açı seçme açıklaması
  görünür. Orijinaldeki panel açılmadan gösterilen uyarı sonraki adımdadır.
- Üretim için son doğrulanmış kural araç + açıdır; parçalar ve renk opsiyoneldir.
  Bu kuralın Üret düğmesine bağlanması uyarı/doğrulama çalışmasına bırakıldı.

## Öğretim kaynakları ve somut uyarlama

İnceleme yerel transkriptlerin ilgili bölümlerinin okunması ve GitHub'daki
örneklerle karşılaştırılmasıyla yapıldı; videolar baştan sona yeniden izlendi
iddiası yoktur. Zamanlar transkript zamanlarıdır; otomatik metinde yazım hataları vardır.

| Kaynak | Vurgulanan mantık | Uygulama |
| --- | --- | --- |
| #7 List, Debug, Navigation; 56:49–58:13, 60:01–63:51, özellikle 70:14–71:27 | Modelin zorunlu/final alanları; model listesinden kart çizimi; karta tüm liste ve indeks yerine ilgili modeli vermek | `DetailPartCategory` ve `DetailPartCatalog`; `_PartSection(category: ...)`, `ListView.builder`, tek ortak kategori tanımı |
| #4 Stateless widget, padding, card ve image; 54:51–57:09 | Parametreli görsel bileşeni ve merkezi görsel yolları | Yollar `ImageItems` içinde; mevcut `ModyAssetImage` kullanılır; ekranlara asset yolu kopyalanmaz |
| #13 Sheet komponenti, Dialog, Generic; 43:00–45:58 | İçeriği parametreyle alınan ortak panel, nullable asenkron dönüş | Mevcut `showSelectionSheet<Map<String, int>>`; `null` iptal; üç ayrı panel kopyası yok |
| #14 Callback ve ekran analizi; 10:47–11:51, 54:09–56:26 | Alt bileşenin üst bileşene seçim bildirmesi; tekrarları ve kaydırma yönünü tasarımdan belirlemek | Stateless panelin seçim callback'i taslağı değiştirir; ekran onaylı state'i yönetir; dikey kategori + yatay görsel listesi |

Doğrudan repo örnekleri:

- [#7 my_collections_demos.dart](https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/demos/my_collections_demos.dart)
- [#4 image_learn.dart](https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/101/image_learn.dart)
- [#13 sheet_learn.dart](https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/202/sheet_learn.dart)
- [#14 callback_dropodown.dart](https://github.com/VB10/Flutter-Full-Learn/blob/main/lib/product/widget/callback_dropodown.dart)

Uygula/iptal taslak davranışı ve açı değişim kuralları projeye ait uyarlamadır;
ders örneğinin birebir uygulaması değildir. Mevcut await sonrası mounted/null
kontrolleri ve tek panel kilidi korunur. State ve cache katmanı yeniden yazılmaz;
yeni paket, singleton veya yeni state-management sistemi eklenmez.

## Kayıt uyumluluğu

`GenerateSelection.fromJson` ve ekran başlangıcı aynı katalog doğrulamasını
kullanır. Kategori başlıkları ve mevcut Rear görsellerinin 0/1/2 sırası korunur.
Seçenek sınırı sabit 3 kontrolü yerine ilgili kategori listesinden alınır.
Front/Side'ın yeni kategorileri de kaydedilir ve yeniden yüklenir.
Önceki sürümden kalan yanlış açıya ait parçalar, bilinmeyen kategoriler veya
geçersiz indeksler yüklenmez; geçerli seçimler korunur. Açı yoksa parça yüklenmez.

## Görseller

10 yeni Commons fotoğrafı eklendi; kalan 17 parça fotoğrafı tekrar kullanıldı.
Kaynak, üretici ve lisans bağlantıları `assets/IMAGE_CREDITS.txt` içindedir.
Fotoğraflar rötuşlanmadı; mevcut contain gösterimiyle kırpılmadan sunulur.
Bunlar orijinal uygulamanın arka plansız parça görselleri veya aynı araca uygun
ürün garantisi değildir. Özellikle üçüncü yan etek fotoğrafı, Modulo eteği
görünen aracın bütün görünümüdür. Görseller VB10 reposundan alınmamıştır.

## Kontroller

Kategori listeleri/sırası, ortak model kullanımı, eski kayıt uyumu, yeni
kategorilerin kayıt turu, bütün farklı açı geçişleri, aynı açı/iptal,
rengin korunması, araç kaldırma/değiştirme ve tek parça uygulama test edilir.
320 ve 390 piksel genişliklerde her açının her seçeneğine kaydırılarak ulaşılır;
görsel dosyalarının decode edilmesi ve kaynak kaydının bulunması da kontrol edilir.

Sonuç: tüm paket için 153 test başarılı; `flutter analyze` temiz. Ek olarak
test ortamında Front/Rear/Side panelinin üst ve alt görünümleri render edilip
görsel olarak kontrol edildi. Bu kontrolde Android emülatörü kullanılmadı.
