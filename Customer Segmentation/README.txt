Data Descirption
1. Customer ID: Kode pelanggan dengan format campuran teks CUST- diikuti angka
2. Nama Pelanggan: Nama dari pelanggan dengan format teks tentunya
3. Jenis Kelamin: Jenis kelamin dari pelanggan, hanya terdapat dua isi data kategori yaitu Pria dan Wanita
4. Umur: Umur dari pelanggan dalam format angka
5. Profesi: Profesi dari pelanggan, juga bertipe teks kategori yang terdiri dari Wiraswasta, Pelajar, Professional, Ibu Rumah Tangga, dan Mahasiswa.
6. Tipe Residen: Tipe tempat tinggal dari pelanggan kita, untuk dataset ini hanya ada dua kategori: Cluster dan Sector. 
7. NilaiBelanjaSetahun: Merupakan total belanja dalam kurun wktu setahun.

dati data terlihat kalau ada 2 variabel yang berisi angka saja, yaitu Umur dan NilaiBelanjaSetahun. 
Sisanya diisi data kategori untuk variabel "Jenis Kelamin", "Profesi" dan "Tipe Residen". 
Sedangkan "Customer ID" dan "Nama Pelanggan" kita anggap memiliki nilai yang unik untuk tiap baris data dan mewakili tiap individu.
dengan contoh dataset inilah, kita akan mencoba mencari jumlah segmentasi yang paling optimal – dimana antar tiap data pelanggan dalam segmen memiliki kemiripan tinggi.

#Tahapan
Dasar dari semua hal sebelum penggunaan analisa data, yaitu tahap persiapan data atau data preparation.
Untuk algoritma clustering k-means yang akan kita gunakan di R, 
maka tahap data preparationnya adalah menyiapkan data yang di dalamnya harus berisi numerik.

Namun pada banyak kasus riil, data tidak sepenuhnya berisi numerik seperti telah kita lihat sendiri dan praktekkan dengan contoh dataset yang digunakan pada bab ini dengan langkah-langkah berikut:

1. Mengenal Contoh File Dataset Pelanggan, dimana kita mengerti dulu bagaimana bentuk dan isi dari contoh yang digunakan.
2. Membaca File dengan read.csv, dimana kita membaca suatu file teks dengan pemisah berupa tab menggunakan fungsi read.csv.
3. Vector untuk Menyimpan Nama Field, dimana nama-nama field bisa disimpan dalam bentuk vector sehingga bisa digunakan berulang ketika kita buturh referensi nama-nama field yang sama.
4. Konversi Data dengan data.matrix, dimana kita bisa melakukan konversi data dari kategori teks menjadi numerik.
5. Menggabungkan Hasil Konversi, dimana hasil konversi ini perlu kita gabungkan kembali ke variable asal agar kita tidak kehilangan referensinya.
6. Menormalisasikan Nilai Belanja, dimana kita merubah skala data nilai belanja dari jutaan menjadi puluhan dengan tujuan penyederhanaan perhitungan namun tidak mengurangi akurasi.
7. Membuat Data Master, dimana kita meringkas data kategori dan numerik ke dalam variable-variable yang kita sebut sebagai data master.
Dengan demikian, kita sudah siap melangkah ke bab berikutnya: Clustering dan Algoritma K-Means.

Penamaan Masing2 Kluster:

Cluster 1 : Diamond Senior Member: alasannya adalah karena umurnya rata-rata adalah 61 tahun dan pembelanjaan di atas 8 juta.
Cluster 2 : Gold Young Professional: alasannya adalah karena umurnya rata-rata adalah 31 tahun, professional dan pembelanjaan cukup besar.
Cluster 3 : Silver Youth Gals: alasannya adalah karena umurnya rata-rata adalah 20, wanita semua, profesinya bercampur antar pelajar dan professional serta pembelanjaan sekitar 6 juta.
Cluster 4 : Diamond Profesional: alasannya adalah karena umurnya rata-rata adalah 42 tahun, pembelanjaan paling tinggi dan semuanya professional.
Cluster 5 : Silver Mid Professional: alasannya adalah karena umurnya rata-rata adalah 52 tahun dan pembelanjaan sekitar 6 juta.