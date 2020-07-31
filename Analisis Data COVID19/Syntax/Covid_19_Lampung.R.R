#ANALISIS DATA COVID 19 DI INDONESIA
#package yang dibutuhkan
library(httr)
library(dplyr)
library(ggplot2)
library(hrbrthemes)
library(lubridate)
library(tidyr)
#mengakses data dan menyimpan dalam resp
resp <- GET ("https://data.covid19.go.id/public/api/update.json")
status_code(resp) #cek status code
#cek status code dengan cara lain
resp$status_code
identical(resp$status_code, status_code(resp))
headers(resp)
cov_id_raw <- content(resp, as = "parsed", simplifyVector = TRUE) 
#mengekstrak komponen dalam covid_id_raw dan menyimpan ke-2 komponen dengan nama covid_id_update
length(cov_id_raw)
names(cov_id_raw)
cov_id_update <-cov_id_raw$update
#mengecek update kasus pertanggal 30 juli 2020
lapply(cov_id_update, names)
cov_id_update$penambahan$tanggal
cov_id_update$penambahan$jumlah_sembuh
cov_id_update$penambahan$jumlah_meninggal
cov_id_update$total$jumlah_positif
cov_id_update$total$jumlah_meninggal

#Kasus di lampung 30 juli
resp_lampung <- GET("https://data.covid19.go.id/public/api/prov_detail_LAMPUNG.json")
cov_lampung_raw <- content(resp_lampung, as = "parsed", simplifyVector = TRUE)
names(cov_lampung_raw)
cov_lampung_raw$kasus_total
cov_lampung_raw$meninggal_persen
cov_lampung_raw$sembuh_persen

#MENGETAHUI PERKEMBANGAN COVID 19 DI LAMPUNG DARI WAKTU KE WAKTU
cov_lampung <- cov_lampung_raw$list_perkembangan
str(cov_lampung)
head(cov_lampung)

#MELAKUKAN WRANGLING DATA AGAR DATA SIAP DIOLAH
#Menghapus kolom "DIRAWAT_OR_ISOLASI" dan "AKUMULASI_DIRAWAT_OR_ISOLASI"
#Menghapus semua kolom yang berisi nilai kumulatif
#Mengganti nama kolom "KASUS" menjadi "kasus_baru"
#Merubah format penulisan kolom MENINGGAL DAN SEMBUH menjadi huruf kecil
#Memperbaiki data pada kolom tanggal
new_cov_lampung <-
  cov_lampung %>% 
  select(-contains("DIRAWAT_OR_ISOLASI")) %>% 
  select(-starts_with("AKUMULASI")) %>% 
  rename(
    kasus_baru = KASUS,
    meninggal = MENINGGAL,
    sembuh = SEMBUH
  ) %>% 
  mutate(
    tanggal = as.POSIXct(tanggal / 1000, origin = "1970-01-01"),
    tanggal = as.Date(tanggal)
  )    
str(new_cov_lampung)

#MEMVISUALISASIKAN DATA DENGAN BENTUK LAIN (GAMBAR)
ggplot(new_cov_lampung, aes(x = tanggal, y = kasus_baru)) +
  geom_col()
#membuat grafik lebih mudah dipahami
ggplot(new_cov_lampung, aes(tanggal, kasus_baru)) +
  geom_col(fill = "salmon") +
  labs(
    x = NULL,
    y = "Jumlah kasus",
    title = "Kasus Harian Positif COVID-19 di Lampung",
    subtitle = "Terjadi pelonjakan kasus di awal bulan Mei mendekati Idul Fitri",
    caption = "Sumber Data: covid.19.go.id"
  ) +
  theme_ipsum(
    base_size = 13,
    plot_title_size = 21,
    grid = "Y",
    ticks = TRUE
  ) +
  theme(plot.title.position = "plot")

#Grafik Sembuh Harian 
ggplot(new_cov_lampung, aes(tanggal, sembuh)) +
  geom_col(fill = "olivedrab2") +
  labs(
    x = NULL,
    y = "Jumlah kasus",
    title = "Kasus Harian Sembuh Dari COVID-19 di Lampung",
    caption = "Sumber data: covid.19.go.id"
  ) +
  theme_ipsum(
    base_size = 13, 
    plot_title_size = 21,
    grid = "Y",
    ticks = TRUE
  ) +
  theme(plot.title.position = "plot")

#GRAFIK MENINGGAL
ggplot(new_cov_lampung, aes(tanggal, meninggal)) +
  geom_col(fill = "darkslategray4") +
  labs(
    x = NULL,
    y = "Jumlah kasus",
    title = "Kasus Harian Meninggal Akibat COVID-19 di Lampung",
    caption = "Sumber data: covid.19.go.id"
  ) +
  theme_ipsum(
    base_size = 13, 
    plot_title_size = 21,
    grid = "Y",
    ticks = TRUE
  ) +
  theme(plot.title.position = "plot")
#PENGAMATAN PER MINGGU
cov_lampung_pekanan <- new_cov_lampung %>% 
  count(
    tahun = year(tanggal),
    pekan_ke = week(tanggal),
    wt = kasus_baru,
    name = "jumlah"
  )

glimpse(cov_lampung_pekanan)

#mengetahui Perkembangan tiap minggu, apakah mengalami kenaikan atau penurunan kasus, jika mengalami penurunan dari minggu sebelumnya akan bernilai TRUE
cov_lampung_pekanan <-
  cov_lampung_pekanan %>% 
  mutate(
    jumlah_pekanlalu = dplyr::lag(jumlah, 1),
    jumlah_pekanlalu = ifelse(is.na(jumlah_pekanlalu), 0, jumlah_pekanlalu),
    lebih_baik = jumlah < jumlah_pekanlalu
  )
glimpse(cov_lampung_pekanan)

#membuat grafik fluktuasi kasus per pekan
ggplot(cov_lampung_pekanan, aes(pekan_ke, jumlah, fill = lebih_baik)) +
  geom_col(show.legend = FALSE) +
  scale_x_continuous(breaks = 9:29, expand = c(0, 0)) +
  scale_fill_manual(values = c("TRUE" = "seagreen3", "FALSE" = "salmon")) +
  labs(
    x = NULL,
    y = "Jumlah kasus", 
    title = "Kasus Pekanan Positif COVID-19 di Lampung",
    subtitle = "Warna hijau menunjukan penambahan kasus baru lebih kecil dibandingkan pekan sebelumnya",
    caption = "Sumber data: covid.19.go.id"
  ) +
  theme_ipsum(
    base_size = 13,
    plot_title_size = 21,
    grid = "Y",
    ticks = TRUE
  ) +
  theme(plot.title.position = "plot")
#Fungsi mengetahui kasus aktif yang masih dirawat dengan fungsi Cumsum
cov_lampung_akumulasi <- 
  new_cov_lampung %>% 
  transmute(
    tanggal,
    akumulasi_aktif = cumsum(kasus_baru) - cumsum(sembuh) - cumsum(meninggal),
    akumulasi_sembuh = cumsum(sembuh),
    akumulasi_meninggal = cumsum(meninggal)
  )
tail(cov_lampung_akumulasi)
#perkembangan kasus aktif dengan diagram garis
ggplot(data = cov_lampung_akumulasi, aes(x = tanggal, y = akumulasi_aktif)) +
  geom_line()
#Transformasi data
dim(cov_lampung_akumulasi)
cov_lampung_akumulasi_pivot <- 
  cov_lampung_akumulasi %>% 
  gather(
    key = "kategori",
    value = "jumlah",
    -tanggal
  ) %>% 
  mutate(
    kategori = sub(pattern = "akumulasi_", replacement = "", kategori)
  )
dim(cov_lampung_akumulasi_pivot)
glimpse(cov_lampung_akumulasi_pivot)
#membuat pivot longer
#Semenjak tidyr versi 1.0.0, Anda disarankan untuk menggunakan fungsi pivot_longer() sebagai pengganti gather() dan pivot_wider() sebagai pengganti spread(). pivot_longer() dan pivot_wider() memiliki fitur yang lebih lengkap dibandingkan gather() dan spread(). Proses transformasi cov_lampung_akumulasi menjadi cov_lampung_akumulasi_pivot dapat dikerjakan dengan menggunakan pivot_longer()
#bandingkan dengan yang atas
cov_lampung_akumulasi_pivot<-
  cov_lampung_akumulasi %>%
  pivot_longer(
    cols = -tanggal,
    names_to = "kategori",
    names_prefix = "akumulasi_",
    values_to = "jumlah"
  )
#Grafik perbandingan kasus aktif sembuh dan meninggal
ggplot(cov_lampung_akumulasi_pivot, aes(tanggal, jumlah, colour = (kategori))) +
  geom_line(size = 0.9) +
  scale_y_continuous(sec.axis = dup_axis(name = NULL)) +
  scale_colour_manual(
    values = c(
      "aktif" = "salmon",
      "meninggal" = "darkslategray4",
      "sembuh" = "olivedrab2"
    ),
    labels = c("Aktif", "Meninggal", "Sembuh")
  ) +
  labs(
    x = NULL,
    y = "Jumlah kasus akumulasi",
    colour = NULL,
    title = "Dinamika Kasus COVID-19 di Lampung",
    caption = "Sumber data: covid.19.go.id"
  ) +
  theme_ipsum(
    base_size = 13,
    plot_title_size = 21,
    grid = "Y",
    ticks = TRUE
  ) +
  theme(
    plot.title = element_text(hjust = 0.5),
    legend.position = "top"
  )
