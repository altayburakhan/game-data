# Proje Yol Haritası ve Durum Analizi

Bu belge, **GameAnalyze** projesinin mevcut durumunu, verinin uygunluğunu, Python'un nerede devreye gireceğini ve pipeline'ın nasıl çalıştığını "adım adım" anlatır.

---

## 1. Veri Uygunluk Analizi (Gold Layer)
Şu an elimizde olan `gamedata.gamedata` tablosu (Gold Layer) aşağıdaki sorular için **gayet uygundur**, ancak bazı ön hesaplamalara (aggregation) ihtiyaç duyar.

### A) A/B Testleri İçin Uygun mu?
*   **Evet.** Tabloda `experiment_id` ve `variant` (Control/Treatment) sütunları var.
*   **Nasıl Yapılır:**
    *   Hangi grubun (variant) daha çok para harcadığını (`revenue`) veya daha çok level geçtiğini (`level`) karşılaştırabiliriz.
    *   **Eksik:** 
### B) Retention (Elde Tutma) İçin Uygun mu?
*   **Evet.** `player_id`, `event_time` ve `event_name='install'` verisi mevcut.
*   **Nasıl Yapılır:**
    *   Bir oyuncunun `install` ettiği tarihi (Day 0) bulup, sonraki günlerde (`event_time`) oyuna girip girmediğine bakarak **Day 1, Day 7, Day 30 Retention** hesaplanabilir.

### C) Insight (İçgörü) İçin Uygun mu?
*   **Evet.** Ham olay verisi (Level atladı, Tutorial bitirdi, Satın aldı) çok detaylı.
*   **Örnek:** "Hangi level'da oyuncular oyunu bırakıyor?" sorusunun cevabı bu veride gizli (`level_complete` olaylarının dağılımı).

---

## 2. Python Nerede Kullanılmalı? (Fırsatlar)
SQL (BigQuery) veriyi toplamak, temizlemek ve filtrelemek için harikadır ama bazı konularda hantal kalır. Python tam burada devreye girer:

1.  **İstatistiksel Analiz (A/B Testi - Önerilen Başlangıç):**
    *   *Senaryo:* "Yeni özellik retention'ı %2 artırdı."
    *   *Python:* `scipy` kütüphanesi ile bunun bilimsel olarak anlamlı olup olmadığını (p-value) hesaplar. Yanılgıya düşmeni engeller.

2.  **Öngörü (Prediction / Machine Learning):**
    *   *Senaryo:* "Bu oyuncu para harcar mı?"
    *   *Python:* `scikit-learn` ile geçmiş verilere bakıp geleceği tahmin eden bir model kurabilirsin. SQL bunu yapamaz.

3.  **Karmaşık Anormallik Tespiti (Data Quality):**
    *   *Senaryo:* "Bugün gelirde %50 düşüş var, bir terslik mi var?"
    *   *Python:* Basit bir `IF` yerine, son 30 günün trendine bakıp "Bu düşüş normal değil, alarm ver!" diyen akıllı bir script yazılabilir.

---

## 3. Bu Pipeline Nasıl Çalışıyor? (Salaga Anlatır Gibi)

Bu sistemi bir **Fabrika Bandı** gibi düşün:

1.  **Hammadde Girişi (Google Sheets):**
    *   Oyun verileri Google Sheets'e ham olarak akar (veya dump edilir). Burası karışık, kirli olabilir.

2.  **Taşıyıcı ve Orkestra Şefi (Bruin - `pipeline.yml`):**
    *   Bruin, fabrikanın müdürüdür. Her sabah (schedule: daily) uyanır. "Hadi işe başlıyoruz" der.
    *   Önce hammaddeyi (Sheets) alır, BigQuery deposuna yığar (**Bronze Layer**).

3.  **Ayıklama Bandı (SQL Temizlik - Silver Layer):**
    *   BigQuery'de bir SQL çalışır. Bu SQL, "boş satırları at, tarih formatını düzelt, dolar işaretlerini temizle" der.
    *   Çıkan temiz veri **Silver Layer** olur.

4.  **Paketleme Bandı (SQL Filtreleme - Gold Layer):**
    *   Başka bir SQL çalışır. "Sadece parasını ödeyen, gerçek oyuncuları ve önemli olayları süz" der.
    *   Bu, analize hazır **Gold Layer** verisidir (Senin şu an baktığın veri).

5.  **Laboratuvar (Python - Sırada Bu Var):**
    *   Şimdi buraya bir Python adımı ekleyeceğiz.
    *   Müdür (Bruin), Gold Layer hazır olunca Python'a "Gel laboratuvara, şu veriyi test et" diyecek.
    *   Python hesap yapıp raporu masaya koyacak.

---

## 4. Adım Adım Yol Haritası (Ne Yapacağız?)

### Adım 1: Basit A/B Test Scripti (Python ile İlk Temas)
*   **Hedef:** Çok karmaşık olmayan, sadece "Variant A vs Variant B" karşılaştırmasını yapan ve sonucu ekrana yazan bir script.
*   **Neden:** Pipeline'a Python sokmayı öğrenmek için en temiz örnek.

### Adım 2: Veri Kalitesi Bekçisi
*   **Hedef:** "Eğer toplam kullanıcı sayısı dün ile bugün arasında %20 oynarsa hata ver" diyen bir koruma kalkanı.
*   **Neden:** Hatalı veri ile analiz yapmanı engeller.

### Adım 3: Dashboard Verisi Hazırlama
*   **Hedef:** Looker Studio veya Tableau için veriyi son haline getiren (örneğin Retention tablosunu hesaplayan) bir script.

**Öneri:** Adım 1'den (Basit A/B Testi) başlayalım. Çok uzun ve karışık olmayan, sadece işini yapan bir kod yazalım. Ne dersin?
