#############################################################################
# THE OLD WAY
# /usr/sbin/groupadd -g 2050 sscope2
#/usr/sbin/groupadd -g 902 omsuser
#/usr/sbin/useradd –g 2050 –u 2050 –s /bin/bash –m –d /home/sscope2 sscope2
#/usr/sbin/useradd –g 902 –u 902 –s /bin/bash –m –d /home/omsuser omsuser
#############################################################################
#The DevOps way
#Create the standard groups
group { 'omsuser':
ensure => 'present',
gid    => '902',
}
group { 'sscope2':
ensure => 'present',
gid    => '2050',
}
#Create the standard users
user { ['omsuser']  :
  ensure     => 'present',
  uid        => '902',
  managehome => true,
  groups     => [ 'omsuser'],
  password   => pw_hash('ChangeM3', 'SHA-512','random'),
  gid        => '902',
  shell      => '/bin/bash',
}
user { [ 'sscope2' ] :
  ensure     => 'present',
  uid        => '2050',
  managehome => true,
  groups     => ['sscope2'],
  password   => pw_hash('ChangeM3', 'SHA-512','random'),
  gid        => '2050',
  shell      => '/bin/bash',
}
# Define a variable with the standard text for a sudoers file to create in the file
$sudofile = '#Managed by Puppet
#Allow root to run any commands anywhere
root                                      ALL=(ALL)       ALL
%wheel                                    ALL=(ALL)       ALL 
%ADL-SR_NBCU-IT_WEB_UNIX_Localadmin       ALL=(ALL)       NOPASSWD: ALL
omsuser                                   ALL=(ALL)       NOPASSWD: ALL
'
#Create the sudoers file with the text from the variable above
file { '/etc/sudoers' :
  ensure  => 'file',
  content => $sudofile,
}
