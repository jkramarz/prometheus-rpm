PACKAGES = prometheus \
alertmanager \
node_exporter \
mysqld_exporter \
redis_exporter \
blackbox_exporter

.PHONY: $(PACKAGES)

all: $(PACKAGES)

$(PACKAGES):
	docker run --rm \
		-v ${PWD}/$@:/rpmbuild/SOURCES:z \
		-v ${PWD}/_dist:/rpmbuild/RPMS/x86_64:z \
		lest/centos7-rpm-builder \
		build-spec SOURCES/$@.spec

sign:
	docker run --rm \
		-v ${PWD}/_dist:/rpmbuild/RPMS/x86_64 \
		-v ${PWD}/bin:/rpmbuild/bin \
		-v ${PWD}/RPM-GPG-KEY-prometheus-rpm:/rpmbuild/RPM-GPG-KEY-prometheus-rpm \
		-v ${PWD}/secret.asc:/rpmbuild/secret.asc \
		-v ${PWD}/.passphrase:/rpmbuild/.passphrase \
		lest/centos7-rpm-builder \
		bin/sign

publish: sign
	package_cloud push --skip-errors prometheus-rpm/release/el/7 _dist/*.rpm

clean:
	rm -rf _dist
	rm **/*.tar.gz
