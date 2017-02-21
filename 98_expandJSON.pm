################################################################################
#
#  Copyright (c) 2017 dev0
#
#  This script is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  The GNU General Public License can be found at
#  http://www.gnu.org/copyleft/gpl.html.
#  A copy is found in the textfile GPL.txt and important notices to the license
#  from the author is found in LICENSE.txt distributed with these scripts.
#
#  This script is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  This copyright notice MUST APPEAR in all copies of the script!
#
################################################################################

# $Id: 98_expandJSON.pm 100 1970-01-101 00:00:00Z dev0 $

# release change log:
# ------------------------------------------------------------------------------
# 1.0  initial release

package main;

use strict;
use warnings;
use POSIX;

sub expandJSON_update($$$;$$);

sub expandJSON_Initialize($$) {
  my ($hash) = @_;
  $hash->{DefFn}    = "expandJSON_Define";
  $hash->{NotifyFn} = "expandJSON_Notify";
  $hash->{AttrFn}   = "expandJSON_Attr";
  $hash->{AttrList} = "disable:1,0 "
                    . "disabledForIntervals "
                    . "showtime:1,0 "
                    . "addStateEvent:1,0 "
                    . "addReadingsPrefix:1,0";
}


sub expandJSON_Define(@) {
  my ($hash, $def) = @_;
  my @a = split("[ \t][ \t]*", $def);
  my $usg = "\nUse 'define <name> expandJSON <regexp>";
  return "Wrong syntax: $usg" if(int(@a) != 3);
  return "ERROR: Perl module JSON is not installed" if (expandJSON_isPmInstalled($hash,"JSON"));

  my $name = $a[0];
  my $type = $a[1];
  my $re   = $a[2];

  return "Mad regexp: starting with *" if($re =~ m/^\*/);
  eval { "test" =~ m/^$re$/ };
  return "Mad regexp $re: $@" if($@);

  $hash->{REGEXP} = $re;
  notifyRegexpChanged($hash, $re);

  readingsSingleUpdate($hash, "state", "active", 0);
  return undef;
}


sub expandJSON_Attr($$) {
  my ($cmd,$name,$aName,$aVal) = @_;
  my $hash = $defs{$name};
  my $type = $hash->{TYPE};
  my $ret;

  if ($cmd eq "set" && !defined $aVal) {
    $ret = "not empty"
  }
  elsif ($aName eq "addReadingsPrefix") {
    $cmd eq "set" 
      ? $aVal =~ m/^(0|1)$/ ? ($hash->{$aName} = $aVal) : ($ret = "0,1") 
      : delete $hash->{$aName}
  }
  
  if ($ret) {
    my $msg = "$type $name: attr $name $aName: value must be: ";
    Log3 $name, 2, $msg.$ret;
    return $msg.$ret;
  }

  return undef;
}


sub expandJSON_Notify($$) {
  my ($hash, $dhash) = @_;

  my $name = $hash->{NAME};
  my $type = $hash->{TYPE};
  return "" if(IsDisabled($name));

  my $devName = $dhash->{NAME};
  my $re = $hash->{REGEXP};
  my $events = deviceEvents($dhash, AttrVal($name, "addStateEvent", 0));
  return if(!$events);

  for (my $i = 0; $i < int(@{$events}); $i++) {
    my $event = $events->[$i];
    $event = "" if(!defined($event));
    my $found = ($devName =~ m/^$re$/ || "$devName:$event" =~ m/^$re$/);

#    if(!$found && AttrVal($devName, "eventMap", undef)) {
#      my @res = ReplaceEventMap($devName, [$devName,$event], 0);
#      shift @res;
#      $event = join(" ", @res);
#      $found = ("$devName:$event" =~ m/^$re$/);
#    }

    if ($found) {
      my ($reading,$value) = split(": ",$event);
      InternalTimer(gettimeofday()+0.01, "expandJSON_do", "$name,,$devName,,$reading,,$value");
      readingsSingleUpdate($hash, "state", AttrVal($name,'showtime',1) 
        ? $dhash->{NTFY_TRIGGERTIME} : 'active', 1);
    }
  }

  return undef;
}


sub expandJSON_do($) {
  my ($p) = @_;
  my ($name,$dname,$dreading,$dvalue) = split(",,", $p, 4);
  my $dhash = $defs{$dname};
  my $hash = $defs{$name};
  my $type = $hash->{TYPE};
  my $h;

  eval { $h = decode_json($dvalue); 1; };
  if ( $@ ) {
    Log3 $name, 2, "$type $name: Mad JSON: $dname $dreading: $dvalue";
    Log3 $name, 2, "$type $name: $@";
    return undef;
  }

  my $sPrefix = $hash->{addReadingsPrefix} ? $dreading."_" : "";
  readingsBeginUpdate($dhash);
  expandJSON_update($dhash,$sPrefix,$h);
  readingsEndUpdate($dhash, 1);

  return undef;
}


sub expandJSON_update($$$;$$) {
  # thanx to bgewehr for this recursive snippet
  # https://github.com/bgewehr/fhem
  my ($hash,$sPrefix,$ref,$prefix,$suffix) = @_;
  $prefix = "" if( !$prefix );
  $suffix = "" if( !$suffix );
  $suffix = "_$suffix" if( $suffix );

  if( ref( $ref ) eq "ARRAY" ) {
    while( my ($key,$value) = each @{ $ref } ) {
      expandJSON_update($hash,$sPrefix,$value,$prefix.sprintf("%02i",$key+1)."_");
    }
  }
  elsif( ref( $ref ) eq "HASH" ) {
    while( my ($key,$value) = each %{ $ref } ) {
      if( ref( $value ) ) {
        expandJSON_update($hash,$sPrefix,$value,$prefix.$key.$suffix."_");
      }
      else {
        (my $reading = $sPrefix.$prefix.$key.$suffix) =~ s/[^A-Za-z\d_\.\-\/]/_/g;
        readingsBulkUpdate($hash, $reading, $value);
      }
    }
  }
}


sub expandJSON_update_old($$;$$) {
  # thanx to bgewehr for this recursive snippet
  # https://github.com/bgewehr/fhem
  my ($hash,$ref,$prefix,$suffix) = @_;
  $prefix = "" if( !$prefix );
  $suffix = "" if( !$suffix );
  $suffix = "_$suffix" if( $suffix );

  if( ref( $ref ) eq "ARRAY" ) {
    while( my ($key,$value) = each @{ $ref } ) {
      expandJSON_update($hash,$value,$prefix.sprintf("%02i",$key+1)."_");
    }
  }
  elsif( ref( $ref ) eq "HASH" ) {
    while( my ($key,$value) = each %{ $ref } ) {
      if( ref( $value ) ) {
        expandJSON_update($hash,$value,$prefix.$key.$suffix."_");
      }
      else {
        (my $reading = $prefix.$key.$suffix) =~ s/[^A-Za-z\d_\.\-\/]/_/g;
        readingsBulkUpdate($hash, $reading, $value);
      }
    }
  }
}


sub expandJSON_isPmInstalled($$)
{
  my ($hash,$pm) = @_;
  my ($name,$type) = ($hash->{NAME},$hash->{TYPE});
  if (not eval "use $pm;1") 
  {
    Log3 $name, 1, "$type $name: perl modul missing: $pm. Install it, please.";
    $hash->{MISSING_MODULES} .= "$pm ";
    return "failed: $pm";
  }
  
  return undef;
}


1;


=pod
=item helper
=item summary Expand a JSON string from a reading into individual readings
=item summary_DE Expandiert eine JSON Zeichenkette in individuelle Readings
=begin html

<a name="expandJSON"></a>
<h3>expandJSON</h3>

<ul>
  <p>Expand a JSON string from a reading into individual readings</p>

  <ul>
    <li>Requirement: perl module JSON<br>
      Use "cpan install JSON" or operating system's package manager to install
      Perl JSON Modul. Depending on your os the required package is named: 
      libjson-perl or perl-JSON.
    </li>
  </ul><br>
  
  <a name="expandJSONdefine"></a>
  <b>Define</b><br><br>
  
  <ul>
    <code>define &lt;name&gt; expandJSON &lt;regex&gt;</code><br><br>

    <li>
      <code>&lt;name&gt;</code><br>
      A name of your choice.</li><br>

    <li>
      <code>&lt;regex&gt;</code><br>
      Regexp that must match your devices, readings and values that contain
      the JSON strings. Regepx syntax is the same as used by notify.<br>
      eg. <code>device:reading:.value</code></li><br>

    <li>
      Examples:<br>
      <code>define ej1 expandJSON device:reading:.{.*}</code><br>
      <code>define ej2 expandJSON sonoff_123:sensor.*:.*</code><br>
      <code>define ej3 expandJSON sonoff_.*:.*:.{.*}</code><br>
      <code>define ej4 expandJSON .*:sensor:.*</code><br>
      <code>define ej5 expandJSON .*:(sensor1|sensor2|teleme.*):.*</code><br>
      <code>define ej6 expandJSON (dev1|device.*|[Dd]evice.*):reading:.*</code><br>
      <code>define ej7 expandJSON (dev0\d+|[Dd]evice.*):(sen1|sen2|telem.*):.*</code><br>
      <code>define ej8 expandJSON d.*:jsonX:.{.*}|y.*:jsonY:.{.*Wifi.*{.*SSID.*}.*}</code></li><br>
  </ul>

  <a name="expandJSONset"></a>
  <b>Set</b><br><br>
  <ul>
    N/A<br><br>
  </ul>
  
  <a name="expandJSONget"></a>
  <b>Get</b><br><br>
  <ul>
    N/A<br><br>
  </ul>
  
  <a name="expandJSONattr"></a>
  <b>Attributes</b><br><br>
  <ul>
    <li><a name="">addReadingsPrefix</a><br>
      Add source reading as prefix to new generated readings. Useful if you have
      more than one reading with a JSON string that should be converted.
    </li><br>

    <li><a href="#disable">disable</a></li>
    <li><a href="#disabledForIntervals">disabledForIntervals</a></li>
    <li><a href="#addStateEvent">addStateEvent</a></li>
    <li><a href="#showtime">showtime</a></li><br>
  </ul>
</ul>

=end html
=cut
