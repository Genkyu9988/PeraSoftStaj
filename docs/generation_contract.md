# Girdi–sonuç sözleşmesi: sağlayıcıdan bağımsız hazırlık

Tarih: 8 Ekim 2026.

## Yapılan iş

Mevcut sözleşme yeniden yazılmadı. `GenerationInput` alt türleri, Cubit'ler,
`GenerationService.generate` imzası, ekran akışı ve cache şeması korundu.
Yeni `GenerationInputResolver`, mevcut seçim anlık görüntüsünü
`GenerationPlan` modeline çözümler. Sahte servis bu çözümlemeyi gerçekten
kullanır; bağımsız testler plandaki bütün alanları denetler.

| Girdi | Çözülmüş anlam |
| --- | --- |
| Araç kimliği | Aynı kimlik + yerel asset yolu. Henüz yüklenmiş dosya/URL değil. |
| Stil / ekstra / açı etiketi | Açık ve sabit uygulama kimliği; ekrandaki dil ve cache değerleri değişmez. |
| `Rear`, `Spoiler: 0` | `angle.rear`, `spoiler.race_wing` ve mevcut parça görseli. |
| `Özel Mor` | `color.special.purple`, kategori `special`, mevcut örnek rengin ARGB değeri. |
| Explore hedefi | Mevcut `CarModCatalog` kimliği, referans görseli ve mevcut instruction metni. |
| Stil klonlama referansı | Hedef araçtan ayrı `GenerationAsset`. |
| AI Video | Mevcut tipli şablon isteği ve beklenen medya türü `video`. |

`GenerationPlan.request`, özeti/işlemi/şablonu/Custom Edit açıklamasını içeren
asıl değişmez isteği saklar. Çözümlenmiş alanlara yalnız etkin moda/işleme
ait seçimler alınır. Diğer sekmelerin alanlarından yeni bir düzenleme türetilmez.
Parçaların kullanıcı seçim sırası korunur; parça listesi değiştirilemez.

`Premium` ve `Özel` kategori adları otomatik olarak metalik/sedefli gibi
fiziksel boya özellikleri sayılmaz. ARGB değeri ekran örneğidir, AI çıktısının
renk doğruluğu garantisi değildir. Video şablonları da sağlayıcının hazır
efekt/model kimlikleri değildir. Henüz desteklenebilirlik iddiası yoktur.

## Hatalar ve mevcut davranış

- Style Builder: mevcut en az bir stil/ekstra/renk kuralı korunur.
- Custom Edit: boş olmayan açıklama gerekir. Resolver metni yeniden yazmaz;
  mevcut Cubit'in gönderim anındaki kenar boşluğu temizliği korunur.
- Detail Edit: açı zorunlu; parça ve renk opsiyonel. Yanlış açıya ait kategori,
  negatif/geçersiz indeks sessizce düşürülmez; çözümleme başarısız olur.
- Explore: yalnız o işleme ait hedef/renk/referans kabul edilir.
- Eksik/bilinmeyen aktif girdi `GenerationInputException(field)` üretir.
  Bu geliştirme teşhisidir; kullanıcıya ham exception gösterilmez. Sahte servis
  bunu mevcut güvenli `unavailable` hata türüne çevirir.
- Geçersiz istek demo fail-first sayacını tüketmez.
- Önceki başarı/hata/tekrar dene/vazgeç/geç yanıt/tek yönlendirme davranışları
  değişmez. Retry aynı snapshot'ı kullanır; yerel iptal sunucu iptali değildir.

Eski cache verilerinin restorasyon politikası değişmedi: geçersiz eski
seçimler mevcut filtrelerden geçer. Resolver ise gönderim sınırındaki
geçersiz isteği sessizce başka bir isteğe dönüştürmez.

## Sonuç ayrımı

`GenerationResult` artık sealed temel tip; mevcut tek alt tür
`DemoGenerationResult`. Orijinal fotoğraf yolu yalnız bu demo alt türünde.
Demo, istek video olsa bile `mediaKind: image` döndürür. Böylece beklenen
medya ile gerçekten dönen medya aynı şeymiş gibi gösterilemez.

Sonuç görünümü alt türü exhaustive switch ile açar. Gerçek görsel/video
sonuç türü eklenince onu ayrıca ele almak gerekecek; demo fotoğrafına
sessiz bir geri dönüş yolu yoktur. Bu aşamada gerçek çıktı URL'si, video
oynatıcı veya sağlayıcı yanıt modeli **eklenmedi**.

Ekrandaki metinler, görseller, seçenek sıraları ve kayıtlı seçimler aynıdır.
`Fikir Ver` ve Front/Rear/Side ürün kurallarına dokunulmadı. Paket eklenmedi.

## Kaynakların etkisi

Yeni 9. ders dosyası 1280×720, yaklaşık 1:43:15,69. İlgili sekiz kod karesi
transkriptin 32–35, 73–77, 80–82 ve 89–91. dakikalarıyla karşılaştırıldı.
Bu, videonun tamamını kesintisiz sesli izleme iddiası değildir.

- **9. ders / model dönüşümü:** [PostModel](https://github.com/VB10/Flutter-Full-Learn/blob/a97929b6d06c35b9353551a207150388d30ec784/lib/202/service/post_model.dart) gelen/giden veriyi temsil eder. Biz de veri ile dönüşüm sorumluluğunu ayırdık; henüz bilinmeyen JSON'u tahmin etmedik.
- **9. ders / servis arayüzü ve hata:** [PostService](https://github.com/VB10/Flutter-Full-Learn/blob/a97929b6d06c35b9353551a207150388d30ec784/lib/202/service/post_service.dart) model döndürür. Bizde UI'dan bağımsız resolver ve mevcut servis arayüzü birlikte kullanılır.
- **18. ders / değiştirilebilir servis:** [MockReqResService](https://github.com/VB10/Flutter-Full-Learn/blob/a97929b6d06c35b9353551a207150388d30ec784/test/req_res_test.dart) gibi internetsiz kontrollü sonuç korunur.
- **19 ve Mimari v2 11:** Önceki dışarıdan servis verme, state eşitliği, listener ve kapanış korumaları yeniden yazılmadı.
- **Mimari v2 13:** [ViewModel testi](https://github.com/VB10/architecture_template_v2/blob/4c1cbaefbea2281f377a33eb3052348b5cf3e225/test/view_model/home_view_model_test.dart) gibi bağımsız örnekler ve açık beklentiler. Yeni testlerde ağ yoktur.

Parça kimlikleri, açı eşleştirmesi ve demo medya ayrımı ürünümüze özgü
uyarlamalardır; öğretmenin reposunda hazır AI entegrasyonu varmış gibi alınmadı.

## Doğrulama

- Yeni `generation_contract_test.dart`: **99 test**.
- Hedefli servis/akış testleriyle birlikte **212 test başarılı**.
- Tam test paketi: **731 test başarılı** (önceki 632 + yeni 99).
- `flutter analyze --no-pub`: temiz.
- `flutter build apk --debug --no-pub`: başarılı.
- Kaydedilmiş seçimlerle uyumluluk, tüm 37 Explore işlemi, 15 video şablonu,
  12 renk, bütün Detail Edit açı/parça eşleşmeleri ve sınır hataları test edildi.
- Eski testlerde yalnız yeni demo alt türü kullanıldı; servis testlerinin
  eksik örnek girdileri gerçek ürün kurallarına uygun hâle getirildi.
  Var olan iptal/hata/navigasyon kontrolleri kaldırılmadı.
- Bu aşamada canlı cihaz testi yapılmadı.
- AI Video için mevcut widget-test aracıyla 8 önizleme yeniden üretildi.
  Sonuç, hata ve iptal sonrası seçim görüntüleri görsel olarak incelendi.
  Apex sonuç ve hata PNG'leri önceki sürümle SHA-256 düzeyinde aynı;
  düzenleyici, dönüş ve iptal görüntüleri de kendi aralarında aynı.
  Bu doğrulama cihaz ekran kaydı veya gerçek video çıktısı değildir.

## Sağlayıcı seçildikten sonra yapılacaklar

1. Asset'i gerçek dosya verisine/yükleme referansına çevirmek; boyut, biçim
   ve sağlayıcı kabul sınırlarını doğrulamak.
2. Uygulama kimliklerini gerçek prompt/parametre/efektlere eşlemek;
   sağlanamayan şablonlar için ürün davranışını kararlaştırmak.
3. Gerçek çıktı görseli/video, güvenli medya adresi ve sağlayıcı hataları
   için doğrulanmış yanıt örneklerinden modeller oluşturmak.
4. Gerekiyorsa uzaktaki iş kimliği, durum sorgulama, iptal ve tekrar denemede
   çift ücretlendirmeyi önleme davranışlarını bağlamak.

`GenerationPlan` bir API sözleşmesi veya JSON şeması değildir. Django,
Firebase, AI anahtarı, HTTP paketi veya ücretli üretim bu adımda eklenmedi.
