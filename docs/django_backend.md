# Django yerel backend — Mody AI

## Ne değişti?

Flutter artık katalog, seçim ve geçmiş verileri için HTTP API kullanır. Django
bilgisayardaki `C:\capstone-main\modyai.db` dosyasını açar. Bu dosya artık yalnız
inceleme kopyası değil, bu yerel backend'in asıl veritabanıdır. Asansör projesinin
`C:\capstone-main\db.sqlite3` dosyasına, Python ortamına veya koduna dokunulmadı.

Django kodu Flutter deposunun `backend/` klasöründedir; ayrı `.venv` içinde
Python 3.13 / Django 5.2.18 kullanır. Eski tablolar korunur; ORM modelleri
`managed=False` olduğu için Django mevcut şemayı yeniden yaratmaz. Bileşik
anahtarlı tablolar repository katmanındaki parametreli SQL ile kullanılır.

Bu sürüm **tek çalışma alanlı yerel geliştirme sürümüdür**. Kullanıcı hesapları,
çok kullanıcılı veri ayrımı, Django admin paneli, internet yayını, otomatik
offline senkronizasyon ve gerçek AI üretimi eklenmedi. Demo üretim servisi aynı.

## Her açılışta çalıştırma

Flutter proje klasöründe iki terminal kullanın:

Birinci terminal — Django açık kalmalı:

```powershell
.\backend\.venv\Scripts\python.exe .\backend\manage.py runserver 127.0.0.1:8765 --noreload
```

İkinci terminal — Flutter:

```powershell
flutter run --dart-define-from-file=backend/flutter.local.json
```

Hata/tekrar dene demosu gerekiyorsa:

```powershell
flutter run --dart-define-from-file=backend/flutter.local.json --dart-define=MODY_DEMO_FAIL_FIRST=true
```

`backend/start_local.ps1` de aynı yerel sunucuyu başlatır. 8765 portunda zaten
sunucu çalışıyorsa ikinci kopyayı başlatmayın. Sunucuyu terminalde Ctrl+C ile
durdurabilirsiniz. Arka planda başlatılmış Mody AI sunucusunu durdurmak için
`backend/stop_local.ps1` kullanılabilir; yalnız bu projenin sunucusunu hedefler.
Android emülatörü bilgisayara `http://10.0.2.2:8765` üzerinden
erişir. Fiziksel telefon için bu adres geçerli değildir; ayrı ağ/HTTPS kurulumu
gerekir. Sunucu yalnız `127.0.0.1` üzerinde dinler; LAN/internete açılmaz.

## İlk kurulum / başka bilgisayar

```powershell
python -m venv backend/.venv
.\backend\.venv\Scripts\python.exe -m pip install -r backend/requirements.txt
.\backend\.venv\Scripts\python.exe backend/configure_local.py --database C:/capstone-main/modyai.db
.\backend\.venv\Scripts\python.exe backend/manage.py check
```

`--database` **mevcut Mody AI v2 SQLite dosyası** olmalıdır. Asansörün `db.sqlite3`
dosyasını vermeyin. Komut şema/bütünlük kontrolü ve SQLite backup API ile yedek
alır. Verileri silmez veya seed ile değiştirmez. Boş veritabanı oluşturmaz;
ilk yerel SQLite kurulumundan dışa aktarılan Mody AI dosyası gerekir. Bu mevcut
şema geçişinde `migrate` çalıştırmaya gerek yoktur. İleride şema değişikliği ayrı
ve veri korumalı Django migration olarak tasarlanmalıdır.

İki yerel dosya üretilir, ikisi de Git dışında tutulur:

- `backend/.local.json`: veritabanı yolu, Django secret key, geliştirme API anahtarı.
- `backend/flutter.local.json`: Flutter'ın API adresi ve aynı geliştirme anahtarı.

Bu dosyaları paylaşmayın. Anahtarların terminal çıktısına basılması gerekmez.
API anahtarı uygulamaya derlenir; **üretim kullanıcı kimlik doğrulaması değildir**.
HTTP yalnız localhost/emülatör geliştirmesi için desteklenir ve Android'de
cleartext izni sadece debug manifestinde açılır. Yayın sürümünde HTTPS, gerçek
kimlik doğrulama, kullanıcı bazlı yetkilendirme ve üretim sunucusu gerekir.

## API sözleşmesi

Tüm isteklerde `Authorization: Bearer <yerel geliştirme anahtarı>` gerekir.
İstek/yanıt gövdeleri JSON'dur; istekler boyut ve alan doğrulamasından geçer.

- `GET /api/v1/health`: API/şema hazır mı?
- `GET /api/v1/catalog`: v2 katalog snapshot'ı. Flutter aynı `CatalogCodec` ile
  hem eski SQLite hem yeni API verisini doğrular.
- `GET /api/v1/creations`: geçmiş kayıtları.
- `POST /api/v1/creations`: `{ "records": [...] }`. Append-only; mevcut aynı
  kimlik/aynı içerik tekrar gönderilirse ekleme yapılmaz. Aynı kimlik/farklı
  içerik 409 hatasıdır. Batch transaction içindedir; hata kısmi kayıt bırakmaz.
- `GET /api/v1/selections`: seçimler + `ETag` başlığı.
- `PUT /api/v1/selections`: `{ "selections": {...} }` ve `If-Match: <ETag>`.
  Eski revision ile yazma 412 hatasıdır; başka oturumun seçimi ezilmez. Flutter
  hızlı ardışık kayıtları sıraya koyar. Çakışma sonrası yeniden açıp sunucudaki
  seçimleri yükleyin; istemci körlemesine tekrar yazarak çatışmayı çözmez.

Eksik/yanlış anahtar 401, geçersiz seçim 400, yanlış yöntem 405, yanlış içerik
türü 415, veritabanı erişim hatası 503 olarak döner. Endpoint'ler cookie/session
auth kullanmaz; CSRF yerine bearer-only API sınırı vardır. CORS açılmadı.

## Veriyi nereden düzenleyeceğim?

DB Browser for SQLite veya Python ile **`C:\capstone-main\modyai.db`** açılır.
[SQL katalog rehberindeki](sqlite_catalog.md) araba/spoiler INSERT örnekleri bu
dosyada kullanılabilir. Düzenlemeden önce yedek alın; tercihen sunucuyu durdurup
değişiklikleri kaydedin ve tekrar başlatın. Flutter kataloğu açılışta yüklediği
için uygulamayı da tamamen yeniden açın. Açık bir DB Browser transaction'ını
unutmak backend yazılarını kilitleyebilir.

Görsel dosyaları hâlâ BLOB değildir. APK'daki `assets/...` yolları ve HTTPS
görsel URL'leri kullanılabilir. Bilgisayardaki `C:\...jpg` yolu telefonda mevcut
değildir. Medya yükleme/servis etme endpoint'i bu aşamada eklenmedi.

## Eski telefon SQLite dosyası

Silinmedi. Django modunda katalog/seçim/geçmiş için okunmaz veya yazılmaz;
otomatik fallback yapılmaz. Backend kapalıysa açılışta **Tekrar Dene** ekranı,
oturum içindeki kayıt hatalarında mevcut kayıt uyarıları gösterilir.

Yerel SQLite sürümüne bilinçli geri dönüş:

```powershell
flutter run --dart-define=MODY_DATA_SOURCE=sqlite
```

**Bu eski bağımsız veri kaynağına döner.** Backend'de sonradan yapılan işlemler
otomatik olarak telefondaki eski dosyaya kopyalanmaz. İki modu sırayla kullanıp
senkronize olduklarını varsaymayın. Backend'e geçmeden önce bilgisayar kopyası
ve emülatör dosyasının SHA-256 hash'lerinin aynı olduğu doğrulandı: 7 kayıt.

## Testler

```powershell
.\backend\.venv\Scripts\python.exe backend/test_backend.py
flutter test
flutter analyze --no-pub
```

Python testleri geçici dizinde şema fixture'ından veritabanı kurar; kullanıcının
veritabanına bağlanmaz. 15 test: auth, şema/katalog, JSON/method doğrulaması,
idempotence, immutable kayıt çakışması, batch rollback, parça/araç doğrulaması,
eski görsel snapshot'ı, ETag yarışması ve SQL'den eklenen araç.

Flutter tarafındaki 13 yeni API testi: bearer/redirect sınırı, HTTP hata kodları,
bozuk yanıt, idempotent kayıt gövdesi, sıralı ETag yazıları, sürüm kontrolü,
backend kapalıyken hata ve başarıyla tekrar açılış. Eski SQLite testleri korunur.

9 Ekim 2026 doğrulaması: **959 Flutter testi + 15 Django API testi başarılı**;
Flutter analizinde ve Django `check` komutunda sorun yok. Android x86_64 debug
APK emülatöre veri silinmeden kuruldu. Tam APK depolama sınırına takıldığı için
kurulumda `--split-per-abi --target-platform android-x64` kullanıldı.

Emülatörde 7 geçmiş kaydı (5 görsel demo + 2 video demo) API'den görüntülendi.
Araç seçimi geçici değiştirilip bilgisayardaki veritabanına PUT ile yazıldığı,
yeniden açılışta sunucudan geldiği doğrulandı; önceki Porsche 911 seçimi geri
getirildi. Sunucu durdurulduğunda bağlantı hatası, yeniden başlatılıp Tekrar Dene
seçildiğinde normal açılış cihazda kontrol edildi. Yeni demo kaydı oluşturulmadı.

## Resmî kaynaklar

- [Django: mevcut veritabanıyla entegrasyon](https://docs.djangoproject.com/en/5.2/howto/legacy-databases/)
- [Django: üretime dağıtım](https://docs.djangoproject.com/en/5.2/howto/deployment/)

Mevcut veritabanına bağlanma ve geliştirme sunucusunu üretim sunucusundan ayrı
tutma kararlarında bu belgeler kullanıldı. Bu değişiklik için yeni ders videosu
veya transkript izlendiği iddia edilmiyor.
