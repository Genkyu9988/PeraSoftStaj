# AI API öncesi mevcut kapsamın doğrulaması

Tarih: 8 Ekim 2026. Gerçek AI servisi veya yeni özellik eklenmedi.

Bu belge responsive doğrulama aşamasının tarihli kaydıdır. Sonradan eklenen
Your Creations/Garaj, stil görseli düzeltmesi ve kullanıcının manuel
sonuçları için [9 Ekim son doğrulama notuna](demo_release_verification.md) bakın.

## Düzeltilenler

- Üret seçim kutularındaki sabit 88 piksel yükseklik, büyük yazıda taşmaya
  neden oluyordu. Minimum yükseklik korunur; içerik büyüyebilir ve metin sarılır.
- Alt menü sabit yükseklik yerine içeriğe göre büyür; etiketler ortalanır.
- Renk adları satıra sığmadığında sarılır; kategori düğmeleri/satırlar büyür.
- Ortak seçim paneli kısa ekran/klavye alanında gerektiğinde tüm çerçeveyi
  kaydırır. Normal alanda iç listeler kaydırılabilir kalır. Çok kısa alanda
  Uygula'ya ulaşmak için panel başlığı/kenarı üzerinden çerçeve kaydırılabilir.
- Ana işlem düğmeleri uzun/büyük metni kesmek yerine sarar.
- Üret'in üst bölümü gerektiğinde form ile birlikte kayar; büyük yazı veya
  klavye açıkken gönderme alanı sabit üst içerik arkasında sıkışmaz.
- Explore Change Color kutusu içerikle büyür. Garaj profil metinlerinin yatay
  taşması giderildi; profil/boş durum kısa ekranda kaydırılabilir.

Sorumluluklar korunur: widget yerleşimi görünümde, üretim durumu Cubit'te,
servis davranışı `GenerationService` arayüzünün arkasında kalır. Cache biçimi,
Uygula/iptal, açı–parça eşleşmesi, istek/sonuç sözleşmesi değiştirilmedi.

## Otomatik doğrulama

- Başlangıç: 731 mevcut test başarılı.
- Sonuç: **745 test başarılı**; 14 yeni test `responsive_verification_test.dart`.
- `flutter analyze --no-pub`: temiz.
- `flutter build apk --debug --no-pub`: başarılı.
- Değiştirilen Dart dosyaları formatlandı; `git diff --check` temiz.

Yeni testlerin kapsamı:

- 320×568 ve 390×844, 1x/2x yazı; sistem güvenli alanları.
- Üret'in üç modunda demo sonucu, geri dönüş ve ana sekmelerden dönünce
  seçimlerin korunması.
- 320×568/2x yazıda Japanese, Customize Rims, Change Color, Clone Car Style
  ve Cliff Drive'ın tam editörü: vazgeç, geç gelen cevabı yok sayma, hata,
  aynı istekle tekrar dene, sonuçtan dönüş ve yeniden gönderim.
- Kısa renk panelinde Uygula/geri; araç panelinde klavye; Custom Edit'te
  yazı+klavye+sonuçtan dönüş; seçim başlıklarında metnin kesilmemesi.

Kaydırılabilir yeni üst alan testte ekran dışında kalabildiğinden ilgili
eski testler metadata okurken `skipOffstage: false` kullanır ve etkileşimden
önce öğeyi görünür alana getirir. Seçim/cache/istek beklentileri kaldırılmadı.
Kontrollü yüklenme sırasında `pumpAndSettle` ile yapay olarak timeout'a
ilerlemek yerine gerekli kare pompalanır; sonucun zamanı testin kontrolündedir.

## Android emülatör kontrolü

Android 17 / API 37 emülatöründe debug APK kuruldu; uygulama verileri silinmedi.

- Normal yazıda Üret → demo sonuç → Android sistem geri tuşu; aynı araç,
  stil, ekstra ve renk korundu. Sonucun orijinal fotoğraf olduğu açıklaması görüldü.
- Sistem yazı ayarı 2.0 ve 320×568 mantıksal ekranla Üret/alt menü, renk
  panelini açma/kaydırma/Uygula, Garaj'a geçiş kontrol edildi.
- Renk panelinde aynı onaylı renk korundu. Test bitince ekran boyutu ve yazı
  ayarı eski değerlerine (1344×2992 fiziksel, 480 dpi, font_scale 1.0) döndürüldü.

Bu, bütün senaryoların fiziksel cihazda tamamlandığı anlamına gelmez.
Hata–tekrar dene ve geç cevap kontrolleri otomatik widget/state testleriyle
yapıldı. Fiziksel Android/iOS, gerçek klavye çeşitleri, TalkBack/VoiceOver ve
farklı cihaz yönelimlerinin tam matrisi henüz doğrulanmadı. Gerçek AI sonucu
ve gerçek video bu sürümde yoktur.

## Kaynakların kullanımı

Öğretmenin esnek yerleşim, veri/callback alan widget, bağımlılık enjeksiyonu
ve bağımsız test yaklaşımı kullanıldı. Ders/pinned repo/kod eşleştirmeleri
[Yararlanılan kaynaklar](learning_sources.md) belgesinde açıklanmıştır.

## Elle tekrar kontrol

```sh
flutter run
# Hata -> Tekrar Dene kontrolü için uygulamayı yeniden başlat:
flutter run --dart-define=MODY_DEMO_FAIL_FIRST=true
```

Üret, Explore ve AI Video'da geçerli seçim yapın. İlk istekte hata bayrağı
açıksa hata görünür; Tekrar Dene aynı seçimlerle demo sonuca gider.
Vazgeç seçimleri silmemeli; sonuçtan geri dönmek eski hata panelini açmamalı.
Normal kullanım için bayraksız yeniden başlatın; yalnız hot reload yeterli değildir.
