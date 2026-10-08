# Hazır araç kataloğu

## Modifikasyon önizlemesi — 3 Ekim 2026

Explore'da neon, jant, lastik ve süspansiyon onaylandığında sağ kutu artık
seçilen CarModOption.imagePath görselini gösterir. Fotoğrafa dokunmak paneli
yeniden açar; X yalnızca modifikasyonu temizler. Araç ve üst kapak korunur.
Renk paneli değişmedi; bu fotoğraflar AI sonucu değil seçenek önizlemeleridir.

VehicleImageInput ve modifikasyon kutusu ortak SelectionImageBox kullanır.
Bu uyarlama #5'in parametreli bileşen, #14'ün seçili değeri bağlama ve callback,
#6'nın state güncelleme, #13'ün panel sonucu yaklaşımını birleştirir.
Görsel üzerindeki X, repodaki Stack/Positioned örneğindeki katmanlama mantığını
kullanır. Eğitimde bu iki kutulu araç arayüzü birebir bulunmaz.
Testler: car_mod_images_test.dart (Uygula/iptal ve fotoğraf eşleşmesi),
modification_preview_test.dart (bağımsız temizleme, yeniden açılış, kapak korunması).

## Kapsam

- Üret, Explore ve AI Video aynı 12 araçlık yerel kataloğu kullanır.
- Örnek Arabalar, bu kataloğun beş nesneden oluşan alt kümesidir; ayrı bir fotoğraf listesi değildir.
- Bu aşamada yeni dosya indirilmedi. Mevcut, kaynakları `assets/IMAGE_CREDITS.txt` içinde kayıtlı fotoğraflar kullanıldı. Tam araç fotoğrafları seçildi; parça yakın planları kataloğa alınmadı.
- Örnek araca dokunmak doğrudan seçer. Paneldeki seçim ise yalnızca Uygula ile onaylanır; kapatma/geri hareketi taslağı iptal eder.
- Seçilen fotoğraf giriş alanında görünür. X aracı temizler, stil/renk/efekt seçimlerini temizlemez. Explore/AI Video kapak görseli değişmez.
- Katalog ortaktır, seçim durumu global değildir. Üret kendi aracını, her Explore/AI Video kartı kendi aracını saklar.
- Kullanım geçmişi eklenmedi. Panelin ilk sekmesi Hazır Arabalar'dır. Your Creations gerçek üretim verisi bağlanana kadar boş durum gösterir; sahte üretimler giriş fotoğrafı olamaz. Kamera/galeri yoktur.

## Eğitim kaynakları ve uygulama karşılığı

Bu eşleştirme ilgili yerel transkript bölümleri ve VB10 kaynak kodu kontrol edilerek yapıldı. Videoların tamamının yeniden izlendiği anlamına gelmez. Otomatik transkriptlerde kelime hataları bulunduğundan zamanlar bölüm aralığı olarak verilmiştir.

| Eğitim | Kontrol edilen bölüm / kaynak | Bu özellikte karşılığı |
| --- | --- | --- |
| #4 Stateless widget, padding, card ve image widgetları | 54:51–57:59: görseli parametre alan ortak bileşene ayırma. [image_learn.dart](https://github.com/VB10/Flutter-Full-Learn/blob/6b43107/lib/101/image_learn.dart) | Asset yolları ImageItems içinde; ortak ModyAssetImage tekrar kullanılıyor. Görsel yükleme kodu ekranlara kopyalanmıyor. |
| #14 Part-Partof, Callback, Dropdown, Custom button | 10:47–11:51: alt bileşenin üst bileşene haber vermesi ve callback önemi. [call_back_learn.dart](https://github.com/VB10/Flutter-Full-Learn/blob/master/lib/303/call_back_learn.dart) | SampleCarsArea ve VehicleSelectionPanel, ValueChanged<String> ile araç kimliğini bildirir; VehicleImageInput seç/temizle callback'lerini alır. Durumu ekran yönetir. |
| #13 Sheet komponenti, Dialog, Generic | 16:48–17:25: Navigator.pop ile panel sonucu ve çağıran ekranda güncelleme; 17:30 sonrası context yaşam döngüsü uyarısı. [sheet_learn.dart](https://github.com/VB10/Flutter-Full-Learn/blob/3f84b1a/lib/202/sheet_learn.dart) | Mevcut showSelectionSheet<String> üzerinden Future<String?> sonucu beklenir. null iptaldir; await sonrasında mounted kontrol edilir. |
| #12 Cache katmanı | 32:39–33:09: manager üzerinden tekrar kullanılabilir kayıt katmanı. [user_cache_manager.dart](https://github.com/VB10/Flutter-Full-Learn/blob/3a6fdda/lib/202/cache/user_cache/user_cache_manager.dart) | Ekranlar doğrudan SharedPreferences çağırmaz. Mevcut GenerateSelection/ExploreSelection → SelectionCacheManager → SharedManager akışı genişletildi. Fotoğraf baytları değil araç kimliği saklanır. |

## Eğitimden birebir alınmayan, projeye özel kararlar

CatalogVehicle ve VehicleCatalog, 12 araç içeriği, sabit kimlikler, örnek alt kümesi, taslak/onay ayrıntıları, boş üretim sekmesi ve eski kayıt doğrulaması bu uygulamanın gereksinimleridir. Hocanın aynı araç kataloğunu yazdığı ya da bu kararları aynen zorunlu tuttuğu iddia edilmez. Eğitimdeki bileşen, callback ve katman ayırma mantığı bu gereksinimlere uygulanmıştır. Yeni bir state-management paketi veya gereksiz servis katmanı eklenmemiştir.

Null safety: model alanları required/final; bulunamayan araç nullable döner; kayıttan gelen Object? doğrulanır. Eski Örnek Araç 1–5 gerçek katalog kimliklerine çevrilir. Eski Mock Araç/Mock Üretim ve bilinmeyen değerler rastgele fotoğrafa eşlenmez, boş seçime döner.

## Doğrulama

`test/vehicle_catalog_test.dart`: benzersiz 12 kimlik/fotoğraf, beş nesnelik alt küme, bozuk/eskimiş veri, model JSON dönüşümü, 320/390 genişlikte Üret örnek seçimi, son katalog aracına kaydırma, Uygula/iptal, yeniden açılış, X ile temizleme, efekt/kapak korunması ve boş üretim sekmesi.

Mevcut navigasyon, cache, Explore, AI Video ve ortak örnek araç testleri yeni gerçek fotoğraf akışına güncellendi. `test/local_images_test.dart` katalog dahil bütün kullanılan yerel görsellerin paketten yüklenip çözülebildiğini denetler.
