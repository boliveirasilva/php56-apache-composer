PHP5.6 + FIREBIRD2.5 + OCI8
===========================
###### based on: php:5.6-apache-jessie

This image was made for a specific legated project.

License
-------
You must accept the OTN Development and Distribution License Agreement
for Instant Client to download this software.
<http://www.oracle.com/technetwork/licenses/instant-client-lic-152016.html>

Running
-------
Run the container:
```
docker container run -p 8080:80 -v $(pwd):/var/www/html -d boliveirasilva/php56-firebird25-oci8
```

Available Resources
-------------------
+ Debian Jessie
+ PHP 5.6
+ Apache 2.4
+ MySQL
+ Firebird 2.5
+ Oracle OCI8
+ Composer 1.10
+ Git
