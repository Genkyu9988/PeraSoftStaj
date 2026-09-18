# PeraSoft Staj

Bu proje, Mody AI uygulamasının ana ekranından esinlenilen statik bir Flutter
arayüz çalışmasıdır.

## Proje kapsamı

- Uygulamada yalnızca ana ekran bulunur.
- Ekrandaki alanlar henüz tıklanabilir değildir.
- Style Builder, Custom Edit ve Detail Edit statik içerikleri hazırlanmıştır.
- İçerikler arasında geçiş henüz kullanıcı etkileşimine bağlanmamıştır.
- Stil, Ekstra ve Renk için görselsiz mock seçenek panelleri bulunur.
- Detail Edit içinde Açı, Yapılandırma ve ortak Renk panelleri bulunur.
- Seçenek panelleri henüz tıklama veya seçim durumuna bağlı değildir.
- Yapay zekâ veya başka bir API bağlantısı yoktur.
- Örnek araba görselleri yerine dairesel yer tutucular kullanılır.
- Arayüz `StatelessWidget` ve temel Flutter widget'ları ile hazırlanmıştır.
- Bu aşamada hedef görünüm 390 x 844 boyutundaki telefon portresidir.

## Çalıştırma

```sh
flutter pub get
flutter run
```

## Statik önizleme değerleri

`MyApp` içindeki `contentIndex` ana içeriği belirler:

- `0`: Style Builder
- `1`: Custom Edit
- `2`: Detail Edit

`panelIndex` değeri `0` olduğunda panel kapalıdır. Style Builder içinde
`1` Stil, `2` Ekstra, `3` Renk panelini; Detail Edit içinde `1` Açı,
`2` Yapılandırma, `3` ortak Renk panelini gösterir.

## Kontrol

```sh
flutter analyze
flutter test
```
