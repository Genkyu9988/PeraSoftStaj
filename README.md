# PeraSoft Staj

Bu proje, Mody AI uygulamasının ana ekranından esinlenilen bir Flutter arayüz
çalışmasıdır. Dart ve Flutter konuları staj süresince bu proje üzerinde
uygulanır.

## Mevcut kapsam

- Uygulamada şimdilik yalnızca ana ekran bulunur.
- Style Builder, Custom Edit ve Detail Edit modları bulunur.
- Üst sekmeler ve yatay kaydırma aynı `PageView` üzerinde senkronize çalışır.
- Stil, Ekstra, Açı, Ayarla ve Renk panelleri kullanıcı etkileşimiyle açılır.
- Renk kategorileri seçildiğinde örnek renk başlıkları güncellenir.
- Custom Edit alanı `TextField` ve `TextEditingController` ile kullanıcıdan
  açıklama alır.
- `PageController` ve `TextEditingController`, `initState` içinde hazırlanır ve
  `dispose` içinde temizlenir.
- Yapay zekâ veya başka bir API bağlantısı henüz yoktur.
- Örnek araba görselleri yerine dairesel yer tutucular kullanılır.
- Hedef görünüm 390 x 844 boyutundaki telefon portresidir.

## Henüz kapsamda olmayanlar

- Navigation ve birden fazla uygulama ekranı
- `ListView` ve dinamik liste üretimi
- Yapay zekâ veya servis bağlantısı
- Gerçek araç görselleri

Bu konular ilgili eğitim bölümlerine gelindiğinde eklenecektir.

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
