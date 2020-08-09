yum_repos:
  docker:
    # Any repository configuration options
    # See: man yum.conf
    #
    # This one is required!
    baseurl: ${docker_repo_url}
    enabled: true
    failovermethod: priority
    gpgcheck: false
    gpgkey: file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL
    name: Extra Packages for Enterprise Linux 5 - Testing