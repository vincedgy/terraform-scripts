resource "aws_s3_bucket_object" "object" {
  bucket = "${var.s3_bucket}"
  key    = "index.html"
  source = "assets/index.html"
  etag   = "${md5(file("assets/index.html"))}"
}
