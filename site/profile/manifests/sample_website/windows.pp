#
class profile::sample_website::windows
    {
  require profile::iis

  # configure iis
  iis::manage_app_pool {'sample_website':
    require => [
      Windowsfeature[$iis_features],
      Iis::Manage_site['Default Web Site'],
    ],
  }

  iis::manage_site { $::fqdn:
    site_path  => 'C:\inetpub\wwwroot\sample_website',
    port       => '80',
    ip_address => '*',
    app_pool   => 'sample_website',
    require    => [
      Windowsfeature[$iis_features],
      Iis::Manage_app_pool['sample_website']
    ],
  }

  windows_firewall::exception { 'IIS':
    ensure       => present,
    direction    => 'in',
    action       => 'Allow',
    enabled      => 'yes',
    protocol     => 'TCP',
    local_port   => "${webserver_port}",
    display_name => 'HTTP Inbound',
    description  => 'Inbound rule for HTTP Server',
  }

  # deploy website
  $website_source_dir  = 'puppet:///modules/profile/sample_website'

  file { $website_source_dir:
    ensure  => directory,
    path    => 'C:\inetpub\wwwroot\sample_website',
    source  => $website_source_dir,
    recurse => true,
  }

  file { "C:\inetpub\wwwroot\sample_website\index.html":
    ensure  => file,
    content => epp('profile/index.html.epp'),
  }

}
