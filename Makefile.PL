# Makefile.PL for a package defined by PP code.

use ExtUtils::MakeMaker;
use Config;

eval {
  require PDL::Core::Dev;            # Pick up development utilities
  PDL::Core::Dev->import;
  require PDL::Bad;                  # check for bad value support
};
my $pdl_installed = ($@) ? 0 : 1;

# -- Add new subroutines here! --

my @src = qw(pscoast.c gmt_init.c gmt_map.c gmt_shore.c gmt_support.c);
my @obj = @src;
map {s/\.[fc]/\.o/;} @obj; # swap .f, .c for .o

my $install = $Config{'installsitearch'};

# 
## Search for netcdf library and include file
#

foreach my $libdir (
		    $ENV{NETCDF_LIBDIR}, 
		    '/usr/local/netcdf/lib',
		    '/usr/local/lib',
		    '/opt/local/lib',
		    '/usr/lib',
		    '/opt/lib',
		                  # Add new library paths here!!
		    ) {

  if (-e "$libdir/libnetcdf.so") {
    $netcdf_lib_path = $libdir;
    print "Found libnetcdf.so at $libdir/libnetcdf.so\n";
    last;
  }

  if (-e "$libdir/libnetcdf.a") {
    $netcdf_lib_path = $libdir;
    print "Found libnetcdf.a at $libdir/libnetcdf.a\n";
    last;
  }

}

die "Cannot find netcdf library, libnetcdf.so or libnetcdf.a.  
Please install NetCDF or export NETCDF_LIBDIR with the correct library path" 
  unless defined ($netcdf_lib_path);

foreach my $incdir (
		    $ENV{NETCDF_INCDIR}, 
		    '/usr/local/netcdf/include',
		    '/usr/local/include',
		    '/opt/local/include',
		    '/usr/include',
		    '/opt/include',
		                  # Add new header paths here!!
		    ) {

  if (-e "$incdir/netcdf.h") {
    $netcdf_include_path = $incdir;
    print "Found netcdf.h at $incdir/netcdf.h\n";
    last;
  }
}

die "Cannot find netcdf header file, netcdf.h.
Please install NetCDF or export NETCDF_INCDIR with the correct include" 
  unless defined ($netcdf_include_path);

# Make sure bad value support is compiled in.
die "PDL::Graphics::PLplot::Map *requires* bad value support (Set WITH_BADVAL => 1 in perldl.conf)"
  if (!$PDL::Bad::Status && $pdl_installed);

# Check if compiled under gcc/Linux.  In which case, define bool for the compiler
$define_bool = '';
if ($Config{'osname'} =~ linux) {
  $define_bool = '-Dbool=int';
  print "Defining bool=int (linux seems to need this)\n";
}

my %pmfiles;
if ($pdl_installed) {
  %pmfiles = map { $_ => "\$(INST_LIBDIR)/Map/$_" } glob ("binned*cdf");
  $pmfiles{'Map.pm'} = '$(INST_LIBDIR)/Map.pm';
}

#print "pmfiles = \n";
#for (keys %pmfiles) { print "$_ => $pmfiles{$_}\n"; }

my $inc = '';
if ($pdl_installed) {
  $inc = &PDL_INCLUDE()." -I$netcdf_include_path -I./include";
}

$package = ["map.pd",Map,PDL::Graphics::PLplot::Map];
my $postamble = $pdl_installed ? pdlpp_postamble($package) : '';
WriteMakefile(
	      'NAME'  	     => 'PDL::Graphics::PLplot::Map',
	      'CCFLAGS'      => "$define_bool",
	      'PREREQ_PM'    => { PDL => 0 },
	      'PREREQ_PRINT' => 1,
              'DEFINE'       => 
	      "-D_SVID_SOURCE -DGMT_DEFAULT_PATH=\\\".\\\" -DGMT_INSTALL_PATH=\\\"$install/PDL/Graphics/PLplot/Map\\\"",  
	      'VERSION_FROM' => 'map.pd',
	      'OBJECT'       => 'Map.o ' . join (" ", @obj),
	      'PM'           => \%pmfiles,
#             'OPTIMIZE'     => '-g',
	      'INC'          => $inc,
	      'LIBS'         => ["-L$netcdf_lib_path -lnetcdf"],  
	      'clean'        => {'FILES'  => 
				   'Map.pm Map.xs Map.o Map.c pscoast.o testmap.png'},
	      'dist'         => { COMPRESS => 'gzip', SUFFIX => 'gz' },	
	      );
sub MY::postamble { $postamble; }










