# SQLite v2 — kataloglar, seçimler ve geçmiş

> Sonraki adımda varsayılan çalışma modu Django API'ye taşındı. Güncel çalıştırma
> için [Django backend rehberini](django_backend.md) okuyun. Bu belgedeki SQL
> tablo/ekleme örnekleri geçerlidir; Django modunda hedef bilgisayardaki
> `C:\capstone-main\modyai.db` dosyasıdır, emülatör kopyası değildir.

9 Ekim 2026. Yerel uygulama verilerinin çalışma kaynağı `modyai.db` oldu.
Araç, parça, stil/renk/açı, Explore ve AI Video kartları, referans görselleri,
seçim ayarları ve geçmiş SQLite'tan okunur. SharedPreferences yalnızca eski
kayıtları bir kere taşımak için okunur; yeni seçimler oraya yazılmaz.

## Açılış ve güvenli geçiş

`SqliteAppLoader` önce veritabanını açar. v1 → v2 şema değişikliği transaction
içinde çalışır. Katalog tutarlı bir snapshot olarak okunup `CatalogStore`'a
kurulur; sonra eski seçimler aktarılır; en son ekranlar ve geçmiş Cubit'i açılır.
Veritabanı okunamazsa boş geçmişle veya hardcoded seçeneklerle devam edilmez;
kayıtları silmeyen **Tekrar Dene** ekranı gösterilir.

Mevcut katalog sınıfları ekranlarla doğrulama katmanı için aynı erişim noktası
olarak kaldı. `seed*` tanımları yalnız kurulum/yükseltme verisidir. Uygulama her
açılışta seed satırlarını yeniden yazmaz. İzole widget testleri/önizlemeler seed
kullanabilir; üretim giriş noktası SQLite yüklenmeden bu erişimi engeller.

Seçimler `app_settings` içinde JSON belge olarak saklanır; her form alanı için
ayrı tablo yapılmadı. Eski `modyai.v1.selections` içeriği ilk aktarımda aynen
saklanır. Bozuk JSON aktarımı tamamlanmış sayılmaz. Eski preference dosyası ve
geçmiş kopyası kurtarma amacıyla yerinde bırakılır. Başarılı aktarımın marker'ı
`shared_preferences_selections_v2`'dir; geçmişin v1 marker'ı korunur.

## Tablolar ve kimlikler

- `vehicles`: PK `id`; araç adı, görsel yolu, `position`, isteğe bağlı
  `sample_position`. `sample_position` doluysa Örnek Arabalar satırında da çıkar.
- `parts`: PK `id`; ortak parça görseli. Detail Edit ve Explore aynı parçaya
  referans verebilir.
- `part_categories`: PK `id`; mevcut Front Bumper, Spoiler vb. kategori
  anahtarları ve sıraları.
- `detail_part_options`: bileşik PK `(category_id, slot)`; `category_id` kategoriye,
  `part_id` parçaya FK. Kategori başına birçok parça seçeneği vardır. Bir parça
  birden fazla kategoriye bağlanabilir; bağlantı tablosu bu N:M ilişkiyi kurar.
- `angle_categories`: bileşik PK `(angle, category_id)`; açıya göre gösterilen
  kategori bağlantıları. Bir kategori birden fazla açıda kullanılabilir.
- `mod_options`: bileşik PK `(operation, part_id)`; Explore işlemine bağlı parça
  adı, açıklama, eski ad eşlemesi ve gösterim sırası.
- `reference_cars`: PK `id`; stil referans fotoğrafları. Kaynak araç değildir.
- `catalog_sections` / `catalog_entries`: PK `id` ve bileşik PK
  `(section_id, entry_key)`. Listeler, kimlik eşlemeleri ve kapak görselleri gibi
  küçük katalog tanımları. `value_json` bir JSON string veya integer değeridir;
  sıralama `position` ile belirlenir. Bölümden girdilere ilişki 1:N.
- `app_settings`: PK `key`; şu an `selections` JSON belgesi.
- `creations`: PK `id`; `vehicle_id` üzerinden araçtan geçmişe 1:N.
- `creation_parts`: PK `(creation_id, category)`; geçmişten parça seçimlerine
  1:N. `(category, selected_index)` artık `detail_part_options(category_id, slot)`
  alanlarına bileşik FK'dir.
- `migration_log`: PK `migration_key`; tamamlanan veri aktarımları.

**Eski parça slotlarını değiştirmeyin veya başka parçaya atamayın.** Mevcut
kayıtlar indeks tuttuğu için slot kimliği sabittir; yeni seçenek son slota
eklenir. Trigger slot/kategori/parça eşlemesinin değiştirilmesini engeller;
FK kullanılan seçeneklerin silinmesini engeller. Slotlarda boşluk olması
açılış doğrulamasında reddedilir. Bu sürümde parça silme/arşivleme arayüzü yoktur.

## SQL ile yeni araba ekleme

Önce uygulamayı tamamen kapatın ve veritabanının yedeğini alın. Canlı uygulamanın
veritabanını başka bir araçla değiştirmeyin. DB Browser'da düzenlediğiniz dosyanın
telefon/emülatörün uygulama alanındaki **gerçek veritabanı** olması gerekir;
bilgisayardaki bağımsız kopyayı düzenlemek uygulamayı kendiliğinden değiştirmez.

Aşağıdaki örnekler mevcut bir asset'i yeniden kullanır; yeni bir fotoğraf üretmez.
Kimlikler örnektir; aynı INSERT'i ikinci kez çalıştırmak PK nedeniyle reddedilir.

```sql
PRAGMA foreign_keys = ON;
BEGIN;
INSERT INTO vehicles(id, label, asset_path, position, sample_position)
SELECT 'my_new_car', 'Yeni Arabam', 'assets/images/sport.jpg',
       COALESCE(MAX(position), -1) + 1, NULL
FROM vehicles;
COMMIT;
```

Yeni araç Hazır Arabalar panelinde görünür. Örnek Arabalar satırına da eklemek için:

```sql
UPDATE vehicles
SET sample_position = (SELECT COALESCE(MAX(sample_position), -1) + 1 FROM vehicles)
WHERE id = 'my_new_car';
```

## SQL ile yeni spoiler ekleme

Hem Detail Edit → Rear/Side → Spoiler hem Explore → Spoiler için:

```sql
PRAGMA foreign_keys = ON;
BEGIN;
INSERT INTO parts(id, asset_path)
VALUES ('spoiler.my_new', 'assets/images/spoiler.jpg');

INSERT INTO detail_part_options(category_id, slot, part_id)
SELECT 'Spoiler', COALESCE(MAX(slot), -1) + 1, 'spoiler.my_new'
FROM detail_part_options WHERE category_id = 'Spoiler';

INSERT INTO mod_options(operation, part_id, position, label, instruction, legacy_name)
SELECT 'Spoiler', 'spoiler.my_new', COALESCE(MAX(position), -1) + 1,
       'Yeni Spoiler', 'Apply this spoiler while preserving the input vehicle.', ''
FROM mod_options WHERE operation = 'Spoiler';
COMMIT;
```

İşlem sonrasında `PRAGMA foreign_key_check;` boş sonuç vermeli,
`PRAGMA integrity_check;` sonucu `ok` olmalı. Uygulamayı **tamamen yeniden
başlatın**; katalog oturum açılışında yüklenir. Çalışırken otomatik izleme veya
yönetim ekranı bu kapsamda eklenmedi. Yeni araç/parça akışı testlerde SQL INSERT
ile gerçek widget panellerinde doğrulanır; demo geçmişine de kaydedilebilir.

## Fotoğraflar ve URL'ler

SQLite görsel dosyasını BLOB olarak tutmaz. `asset_path`/`original_image_path`
alanları eski adlarını korur ama görüntü bileşeni üç kaynak tipini destekler:

- `assets/images/...`: uygulamayla paketlenen dosya; yeni asset eklemek derleme ister.
- Cihazda erişilebilir dosyanın mutlak yolu veya `file:` URI'si.
- `https://...`: ağ üzerinden görsel; internet ve erişilebilir adres gerekir.

Bilgisayardaki `C:\...` yolu Android cihazda mevcut değildir. Cihaz dosyası kalıcı
uygulama alanında tutulmalıdır; geçici dosya silinirse fotoğraf kaybolur. Görsel
yüklenemezse hata simgesi gösterilir. Galeri seçici, dosya kopyalama, URL indirme
önbelleği veya yükleme servisi bu değişiklikte yapılmadı.

Geçmiş kaydı kendi orijinal görsel yolunu saklar. Katalogdaki görsel yolu
değiştirildiğinde geçmiş eski yolunu korur; o dosyanın kendisini silmeyin.

## Sınırlar

SQLite yereldir; başka kullanıcılara otomatik katalog dağıtımı yoktur. Çalışma
ortamı native sqflite (Android/iOS/macOS); Windows FFI yalnız test bağımlılığıdır.
Windows desktop/web çalışma desteği eklenmedi.

Yeni bir araba veya mevcut işleme yeni parça eklemek kod değişikliği istemez.
Yeni bir AI işlem **davranışı** ise SQL satırıyla oluşturulamaz: desteklenen
Explore/AI Video işlem kimlikleri domain enum'larında kalır. Mevcut kartlar
SQL'de sıralanabilir, gizlenebilir (liste girdisi kaldırılarak), kapakları
değiştirilebilir. Desteklenmeyen işlem adı açılışta açık hata verir. Kalıcı
kimlikleri/kategori anahtarlarını ve mevcut işlem başlıklarını gelişigüzel
yeniden adlandırmayın. Arayüz metinleri, tema ve iş kuralları Dart'ta kalır.

Gerçek AI, kullanıcı hesabı, profil düzenleme veya bulut veritabanı eklenmedi.

## Doğrulama — 9 Ekim 2026

- Tam Flutter test paketi: **946 test başarılı**; `flutter analyze --no-pub` temiz.
- Android debug APK derlendi ve açık emülatöre mevcut verileri silmeden kuruldu.
- 13 yeni katalog/seçim testi: SQL-only araç ve spoiler'ın gerçek panellerde
  görünmesi, kaydedilmesi, yeniden açılış; v1 yükseltme ve hatada rollback;
  immutable slot/FK koruması; seçim aktarımı ve ardışık kayıtlar; bozuk katalogda
  sessiz seed fallback olmaması; geçmişin eski görsel yolunu koruması.
- Önceki 70 SQLite geçmiş testi de tam paket içinde geçti.
- Emülatörde şema v1 → v2; **6 geçmiş kaydının tüm alanları** eski kopyayla aynı.
  Garaj sayacı **4 Mody’s + 2 video**. Eski seçimler SQLite'a birebir taşındı.
- Cihazda araç seçimi geçici olarak Porsche 911 yapıldı; uygulama kapatılıp
  açılınca SQLite'tan geri geldi. Preference dosyasının hash'i değişmedi.
  Test sonunda önceki Klasik Mustang seçimi geri getirildi; seçim JSON'u eski
  seçimlerle tekrar aynı. Yeni demo kaydı eklenmedi.
- `PRAGMA integrity_check = ok`, `PRAGMA foreign_key_check` boş.
- Native Detail Edit yeni parça kaydı emülatörde üretilmedi; bu senaryo
  FFI SQLite ve gerçek Flutter panel testlerinde doğrulandı.
