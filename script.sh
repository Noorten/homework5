#!/bin/bash
sudo -i
yum install -y wget rpmdevtools rpm-build createrepo yum-utils cmake gcc git nano

mkdir rpm && cd rpm
yumdownloader --source nginx

cd rpm
rpm -Uvh nginx*.src.rpm

yum -y builddep nginx

cd /root
git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli

cd /root
cd ngx_brotli/deps/brotli
mkdir out
cd out
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_CXX_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_INSTALL_PREFIX=./installed ..
cmake --build . --config Release -j 2 --target brotlienc

cd /root
cd ngx_brotli/deps/brotli
mkdir out
cd out
cmake --build . --config Release -j 2 --target brotlienc

dnf install sed
sed -i "/-with-debug/a\\  --add-module=/root/ngx_brotli \\\\" "/root/rpmbuild/SPECS/nginx.spec"

cd /root/rpmbuild/SPECS/
rpmbuild -ba nginx.spec -D 'debug_package %{nil}'
cp /root/rpmbuild/RPMS/noarch/* ~/rpmbuild/RPMS/x86_64/

cd /root/rpmbuild/RPMS/x86_64
yum -y localinstall *.rpm

cd /root/rpmbuild/RPMS/x86_64
systemctl start nginx
systemctl status nginx

mkdir /usr/share/nginx/html/repo
cp /root/rpmbuild/RPMS/x86_64/*.rpm /usr/share/nginx/html/repo/
createrepo /usr/share/nginx/html/repo/

line_number=$(grep -n "root  " "/etc/nginx/nginx.conf" | head -n1 | cut -d: -f1)
sed -i "${line_number}a\\        index index.html index.htm;" "/etc/nginx/nginx.conf"
sed -i "/index index.html /a\\        autoindex on;" "/etc/nginx/nginx.conf"

nginx -t
nginx -s reload
curl -a http://localhost/repo/

echo "[otus]" > "/etc/yum.repos.d/otus.repo"
echo "name=otus-linux" >> "/etc/yum.repos.d/otus.repo"
echo "baseurl=http://localhost/repo" >> "/etc/yum.repos.d/otus.repo"
echo "gpgcheck=0" >> "/etc/yum.repos.d/otus.repo"
echo "enabled=1" >> "/etc/yum.repos.d/otus.repo"

yum repolist enabled | grep otus

yum repolist enabled | grep otus
cd /usr/share/nginx/html/repo/
wget https://repo.percona.com/yum/percona-release-latest.noarch.rpm
sleep 5
createrepo /usr/share/nginx/html/repo/
sleep 5
yum makecache
yum list | grep otus
sleep 5
yum install -y percona-release.noarch
