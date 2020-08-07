#Customer Segmentation With R
#import data sesuaikan dengan lokasi file di komputer kalian
pelanggan <- read.delim("D:/LEARNING/R/Customer Segmentation/Data.txt")
pelanggan
library(ggplot2)
#DATA PREPARATION
#membuat variable baru dengan nama field_yang_digunakan yg isinya berupa vector "Jenis.Kelamin", "Umur" dan "Profesi"
field_yang_digunakan <- c("Jenis.Kelamin","Umur","Profesi")
#Menampilkan data pelanggan dengan nama kolom sesuai isi vector field_yang_digunakan
pelanggan [field_yang_digunakan]

#Konversi data menjadi numerik
#Untuk fungsi k-means, ketiga kolom ini tidak bisa digunakan kecuali isi dikonversi menjadi numerik. 
#Salah satu caranya adalah dengan menggunakan fungsi data.matrix.
pelanggan_matrix <- data.matrix(pelanggan[c("Jenis.Kelamin","Profesi","Tipe.Residen")])
pelanggan_matrix #cek apakah data sudah terkonversi kedalam matrix atau belum

#pengabungkan data matrik ke dalam variabel asal
pelanggan <- data.frame(pelanggan,pelanggan_matrix)
#Tampilkan hasil penggabungan
#jika berhasil maka akan muncul Jenis.Kelamin.1 dst...
pelanggan
#Normalisasi Nilai Normalisasi bisa dilakukan dengan banyak cara. Untuk kasus kita, cukup dengan pembagian sehingga nilai jutaan menjadi puluhan namun tidak mengurangi akurasi data
pelanggan$NilaiBelanjaSetahun <- pelanggan$NilaiBelanjaSetahun / 1000000
#Mengisi data master untuk mengetahui masing masing pengkodean
#Mengisi data master
Profesi <- unique(pelanggan[c("Profesi","Profesi.1")])
Jenis.Kelamin <- unique(pelanggan[c("Jenis.Kelamin","Jenis.Kelamin.1")])
Tipe.Residen <- unique(pelanggan[c("Tipe.Residen","Tipe.Residen.1")])
Profesi
#BAGIAN K-MEANS
set.seed(100) #fungsi kmeans ini biasanya disertai dengan pemanggilan function seet.seed. Ini berguna agar kita "menyeragamkan" daftar nilai acak yang sama dari kmeans sehingga kita mendapatkan output yang sama.
#fungsi kmeans untuk membentuk 5 cluster dengan 25 skenario random dan simpan ke dalam variable segmentasi
#nstart, merupakan jumlah kombinasi acak yang dihasilkan secara internal oleh R. Dan dalam jumlah yang kita berikan, algoritma akan memilih mana yang terbaik dari kombinasi-kombinasi tersebut.
segmentasi <- kmeans(x=pelanggan[c("Jenis.Kelamin.1","Umur","Profesi.1","Tipe.Residen.1","NilaiBelanjaSetahun")],centers=5,nstart=25)
#tampilkan hasil k-means
segmentasi
segmentasi$cluster

#Penggabungan hasil cluster ke data awal
pelanggan$cluster <-segmentasi$cluster
str(pelanggan)
which(pelanggan$cluster == 1) #Filter cluster ke-1.

#Analisa hasil
length(which(pelanggan$cluster == 1))
pelanggan[which(pelanggan$cluster == 1),] #malihat data cluster 1
pelanggan[which(pelanggan$cluster == 2),]
pelanggan[which(pelanggan$cluster == 3),]
pelanggan[which(pelanggan$cluster == 4),]
pelanggan[which(pelanggan$cluster == 5),]
segmentasi$centers #melihat hasil cluster means

field_yang_digunakan.1 <- c("Jenis.Kelamin.1","Umur","Profesi.1","Tipe.Residen.1","NilaiBelanjaSetahun")
#Membandingkan dengan 2 cluster kmeans, masing-masing 2 dan 5
set.seed(100)
kmeans(x=pelanggan[c(field_yang_digunakan.1)],centers=2, nstart=25)
set.seed(100)
kmeans(x=pelanggan[c(field_yang_digunakan.1)],centers=5, nstart=25)
#cek komponen dari detail objek kmeans
segmentasi$cluster        #vektor dari cluster untuk tiap titik data
segmentasi$centers        #merupakan informasi titik centroid dari tiap cluster
segmentasi$totss          #total sum of swuares (SS) untuk titik data
segmentasi$withinss       #total sum of swuares per cluster
segmentasi$tot.withinss   #total penjumlahan dari tiap SS dari withinss
segmentasi$betweenss      #perbedaan nilai antara totss dan tot.withinss
segmentasi$size           #jumlah titik data pada tiap cluster
segmentasi$iter           #jumlah iterasi luar yang digunakan oleh kmeans
segmentasi$ifault         #nilai integer yang menunjukan indikator masalah pada algoritmal

#Simulasi Jumlah Cluster dan SS
sse <- sapply(1:10,
              function(param_k)
              {
                kmeans(x=pelanggan[c("Jenis.Kelamin.1","Umur","Profesi.1","Tipe.Residen.1","NilaiBelanjaSetahun")], param_k, nstart=25)$tot.withinss
              }
)
sse

#Grafik Elbow Effect untuk memvisualisasikan vector Sum of Squares (SS) atau Sum of Squared Errors (SSE)
jumlah_cluster_max <- 10
ssdata = data.frame(cluster=c(1:jumlah_cluster_max),sse)
ggplot(ssdata, aes(x=cluster,y=sse)) +
  geom_line(color="red") + geom_point() +
  ylab("Within Cluster Sum of Squares") + xlab("Jumlah Cluster") +
  geom_text(aes(label=format(round(sse, 2), nsmall = 2)),hjust=-0.2, vjust=-0.5) +
  scale_x_discrete(limits=c(1:jumlah_cluster_max))


#Menamai Tiap Cluster
Segmen.Pelanggan <- data.frame(cluster=c(1,2,3,4,5),Nama.Segmen=c("Diamond Senior Member", "Gold Young Professional", "Silver Youth Gals", "Diamond Professional", "Silver Mid Professional"))
Segmen.Pelanggan
#Menggabungkan seluruh aset ke dalam variable Identitas.Cluster
Identitas.Cluster <- list(Profesi=Profesi, Jenis.Kelamin=Jenis.Kelamin, Tipe.Residen=Tipe.Residen, Segmentasi=segmentasi, Segmen.Pelanggan=Segmen.Pelanggan, field_yang_digunakan.1=field_yang_digunakan.1)
Identitas.Cluster

#menyimpan objek dalam bentuk file
saveRDS(Identitas.Cluster,"cluster.rds")

#Data baru, isi variabel sesuai data awal untuk mensegmentasikan otomatis

databaru <- data.frame(Customer_ID="CUST-100", Nama.Pelanggan="Bihaqi Al Rafik", Umur=23, Jenis.Kelamin="Pria",Profesi="Pelajar",Tipe.Residen="Cluster",NilaiBelanjaSetahun=2.0)
readRDS(file="cluster.rds")
Identitas.Cluster <- readRDS(file="cluster.rds")
Identitas.Cluster
#Masukkan perintah untuk penggabungan data
merge(databaru, Identitas.Cluster$Profesi)
merge(databaru, Identitas.Cluster$Jenis.Kelamin)
merge(databaru, Identitas.Cluster$Tipe.Residen)
databaru <- merge(databaru, Identitas.Cluster$Profesi)
databaru <- merge(databaru, Identitas.Cluster$Jenis.Kelamin)
databaru <- merge(databaru, Identitas.Cluster$Tipe.Residen)

#menentukan data baru di cluster mana
which.min(sapply( 1:5, function (x) sum((databaru[Identitas.Cluster$field_yang_digunakan.1] - Identitas.Cluster$Segmentasi$centers[x,])^2 )))
Identitas.Cluster$Segmen.Pelanggan[which.min(sapply(1:5, function(x) sum((databaru[Identitas.Cluster$field_yang_digunakan.1] - Identitas.Cluster$Segmentasi$centers[x,])^2 ))),]
