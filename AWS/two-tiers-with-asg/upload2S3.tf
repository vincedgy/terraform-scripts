resource "aws_s3_bucket_object" "index" {
  bucket = "${var.s3_bucket}"
  key    = "index.html"
  source = "assets/index.html"
  etag   = "${md5(file("assets/index.html"))}"
}
#Flyer_Innovation_Day.JPG
resource "aws_s3_bucket_object" "image" {
  bucket = "${var.s3_bucket}"
  key    = "Flyer_Innovation_Day.JPG"
  source = "assets/Flyer_Innovation_Day.JPG"
  etag   = "${md5(file("assets/Flyer_Innovation_Day.JPG"))}"
}
