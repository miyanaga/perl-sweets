use 5.010;
use lib 'inc';
use ExtUtils::AutoInstall (
  -core => [
    'Any::Moose' => '',
    'AnyEvent' => '',
    'Carp' => '',
    'Encode' => '',
    'Exporter' => '',
    'File::Spec' => '',
    'Hash::Merge' => '',
    'HTML::Entities' => '',
    'JavaScript::Value::Escape' => '',
    'Moose' => '',
    'Try::Tiny' => '',
    'URI::Escape' => '',
    'YAML::Syck' => '',
  ]
);
WriteMakefile(
    NAME              => 'Sweets',
    VERSION_FROM      => 'lib/Sweets.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Sweets.pm', # retrieve abstract from module
       AUTHOR         => 'Kunihiko Miyanaga <miyanaga@ideamans.com>') : ()),
);
