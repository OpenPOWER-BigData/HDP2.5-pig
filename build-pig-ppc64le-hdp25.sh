#!/bin/bash
HADOOP_VERSION="2.7.3.2.5.0.0-1245"
cat <<__EOT__ >> ivy/libraries.properties
hadoop-common.version=$HADOOP_VERSION
hadoop-hdfs.version=$HADOOP_VERSION
hadoop-mapreduce.version=$HADOOP_VERSION
__EOT__
export ANT_OPTS="-Xmx4096m"

( mkdir -p $HOME/.m2/repository/apache-forrest ;
  cd $HOME/.m2/repository/apache-forrest  ;
  /usr/bin/wget -N https://archive.apache.org/dist/forrest/0.9/apache-forrest-0.9.tar.gz
  echo "ea58a078e3861d4dfc8bf3296a53a5f8  apache-forrest-0.9.tar.gz" >apache-forrest-0.9.tar.md5
  if ! md5sum  -c --quiet apache-forrest-0.9.tar.md5 ; then
    exit 1
  fi
)
tar xf  $HOME/.m2/repository/apache-forrest/apache-forrest-0.9.tar.gz
export FORREST_HOME=`pwd`/apache-forrest-0.9

BUILD_OPTS="-Dversion=0.16.0 -Dforrest.home=${FORREST_HOME}  -Dhadoopversion=23"

ant $BUILD_OPTS clean published pigunit-jar smoketests-jar javadoc "$@"
for build_file in contrib/piggybank/java/build.xml ; do
  ant $BUILD_OPTS -buildfile $build_file clean jar "$@"
done
ant $BUILD_OPTS tar "$@"

cd build
mvn install:install-file -Dfile=pig-0.16.0.jar -DgroupId=org.apache.org -DartifactId=pig -Dversion=1.15.1 -Dpackaging=jar
cd ..
