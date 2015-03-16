# mysql-sonarqube

Sonar + MySql

Sonar plugins: 
 sonar-android-plugin-1.0
 sonar-build-breaker-plugin-1.1
 sonar-checkstyle-plugin-2.2
 sonar-java-plugin-2.8
 sonar-l10n-fr-plugin-1.10
 sonar-pmd-plugin-2.3
 sonar-widget-lab-plugin-1.6
 sonar-cobertura-plugin-1.6.3

Included the installation of android-sdk for sonar-android analyses.

Default user and password for mysql is sonar:123qwe.

docker run -i -t -d –name mysql-sonarqube -p 9000:9000 -p 3306:3306 jmfiz/mysql-sonarqube

Sonar-server will be accesible at http://localhost:9000 . Default username:password is admin:admin.
