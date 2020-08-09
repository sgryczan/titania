yum_repos:
  # The name of the repository
  pkg-main:
    # Any repository configuration options
    # See: man yum.conf
    #
    # This one is required!
    baseurl: ${package_repo_url}
    enabled: true
    failovermethod: priority
    gpgcheck: false
    gpgkey: file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL
    name: Extra Packages for Enterprise Linux 5 - Testing
