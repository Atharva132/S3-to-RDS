resource "aws_db_instance" "myrds" {
    allocated_storage   = var.DB_Storage
    storage_type        = "gp2"
    identifier          = "gdtcdb"
    db_name             = "mydb"
    engine              = "mysql"
    engine_version      = "8.0.35"
    instance_class      = "db.t3.micro"
    username            = var.DB_USER
    password            = var.DB_PASSWORD
    publicly_accessible = true
    skip_final_snapshot = true
    vpc_security_group_ids = ["sg-0a6c1cf887701ff62", "sg-05b76b0fd64c226bb"]

    tags = {
        Name = "MyRDS"
    }
}