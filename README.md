# AWS AMI for CSYE 6225

## Team Information

| Name | NEU ID | Email Address |
| --- | --- | --- |
| Jinansi Thakkar | 001835505 | thakkar.j@husky.neu.edu |
| Kinnari Sanghvi | 001837528 | sanghvi.ki@husky.neu.edu |
| Vignesh Raghuraman | 001837157 | raghuraman.v@husky.neu.edu |
| Karan Magdani | 001250476 | magdani.k@husky.neu.edu |

## Validate Template

```
packer validate ubuntu-ami.json
```

## Build AMI

```
packer build \
    -var 'aws_access_key=REDACTED' \
    -var 'aws_secret_key=REDACTED' \
    -var 'aws_region=us-east-1' \
    -var 'subnet_id=REDACTED' \
    ubuntu-ami.json
```
