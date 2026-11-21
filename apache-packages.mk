# Minimum Alpine apache2 package version for the -apache variant of each PHP
# version. Updated by wodby/images when Alpine publishes a newer package, so a
# changed line rebuilds the images with that Apache release. Builds install the
# newest available package and fail if the repository offers an older one.
APACHE_PACKAGE_VERSION_8.6 := 2.4.71-r0
APACHE_PACKAGE_VERSION_8.5 := 2.4.71-r0
APACHE_PACKAGE_VERSION_8.4 := 2.4.71-r0
APACHE_PACKAGE_VERSION_8.3 := 2.4.71-r0
APACHE_PACKAGE_VERSION_8.2 := 2.4.71-r0
