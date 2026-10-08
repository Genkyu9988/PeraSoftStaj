# Stil kartı → kaynak araç seçimi

Kullanıcının bildirdiği durum: Stil panelinde Sportif/Şehir gibi bir kart
seçilip Uygula denince stil etiketi değişiyor, üstteki araç görseli ise
eski araçta veya boş kalıyordu. Bunun nedeni görsel önbelleği değil,
`GenerateCubit.selectStyle` metodunun yalnız `style` alanını değiştirmesiydi.

## Yeni davranış

Manuel Stil → Uygula, stil ve kartta gösterilen örnek araç kimliğini tek
state güncellemesi ve tek seçim-kayıt bildirimiyle uygular:

| Stil | Araç kimliği |
| --- | --- |
| Klasik | mustang_classic |
| Sportif | porsche_911 |
| Off Road | jeep_wrangler |
| SUV | bmw_ix5 |
| Yarış | porsche_race |
| Şehir | fiat_500 |

Eşleme `GenerateOptionCatalog.styleVehicleIds` içindedir. Bir test, her
kimliğin katalog fotoğrafının stil kartı görseliyle aynı olduğunu doğrular.
Liste indeksleri veya araç adları kimlik olarak kullanılmaz.

Panelde yalnız karta dokunmak taslağı değiştirir; kapatma eski stil/araç
seçimini korur. Uygula aynı stile yeniden basıldığında da araç seçer.
Ekstra, renk, açı ve parça seçimleri korunur. Bilinmeyen stil ve üretim
sırasında engellenen form değişikliği araç seçimini değiştiremez.

Fikir Ver'in mevcut rastgele araç/stil seçimi değiştirilmedi. Önceden
kaydedilen farklı stil/araç eşleşmeleri açılışta zorla dönüştürülmez.
Geçmiş demolar değiştirilmez ve stil seçmek üretim geçmişine kayıt eklemez.

`style_vehicle_selection_test.dart`: altı stil × boş/dolu kaynak için
atomik state/cache güncellemesi, gerçek widget görseli, Uygula/iptal,
gönderilecek istek, aynı stilin yeniden uygulanması ve yeniden açılış.
Önce mevcut kodla Sportif/boş araç testi çalıştırılıp `porsche_911` yerine
boş kimlik döndüğü doğrulandı; düzeltme bundan sonra uygulandı.

## Doğrulama (8 Ekim 2026)

- `flutter analyze --no-pub`: hata/uyarı yok.
- `flutter test --no-pub`: 863 test geçti (bu düzeltme için 27 yeni test).
- Android debug APK derlendi ve emülatöre mevcut uygulama verileri korunarak
  yüklendi.
- Emülatörde boş kaynak + zaten seçili Şehir → Uygula, Fiat 500 görselini
  getirdi. Dolu kaynakta Sportif → Uygula, görseli Porsche 911 ile değiştirdi.
- Sportif/Porsche seçiliyken panelde SUV seçilip panel kapatılınca önceki
  stil ve görsel korundu. Ekstra/renk her iki uygulamada da değişmedi.

Kullanıcı düzeltmeyi deneyip çalıştığını ayrıca teyit etti. Geçmiş özelliğiyle
birlikte son kontrol [9 Ekim doğrulama notunda](demo_release_verification.md).
