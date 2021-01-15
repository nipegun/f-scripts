#!/usr/bin/perl

# Read Fritz!Box configuration dump file and compute its checksum using CRC32.
# The problem is only knowing what to checksum exactly, and in this case its not pretty.
# Inspired from the very compact Visual Basic script by Michael Engelke available at
# http://www.mengelke.de/Projekte/FritzBoxVBScript 

# The Fritz!Box accepts a modified file where the checksum has been changed 
# manually to the output of this program in the last line. I have no idea what 
# happens if there is a syntax error anywhere inside the config file, so beware.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

use strict;
use warnings;

# ---
# Compute CRC start values
# ---

sub build_crc_table() {
   my @crctbl = (); # Accepts 256 values

   for (my $a = 0; $a < 256; $a++) {
      my $c = $a;
      for (my $b = 0; $b < 8; $b++) {
         my $d = $c & 0x01;
         $c = ($c >> 1) & 0x7FFFFFFF;
         if ($d) { 
            $c = $c ^ 0xEDB88320;
         }
      }
      push @crctbl, $c
   }

   my $print = 0;

   if ($print) {
      my $i = 0;
      foreach my $x (@crctbl) {
         print sprintf("CRC table value $i: %08x\n", $x);
         $i++
      }
   }

   return @crctbl
}

# ---
# Transform a string into a vector of its ASCII code points
# ---

sub numerize {
   my ($str) = @_;
   my @res = ();
   foreach my $ch (split('',$str)) {
      push @res, ord($ch)
   }
   return @res;
}

# ---
# Transform a hexstring into a vector of its 8-bit values
# ---

sub hexnumerize {
   my ($str) = @_;
   my @res = ();
   my $tmp;
   my $i = 0;
   foreach my $ch (split('',$str)) {
      if ($i == 0) { $tmp = $ch; $i++; }
      else         { $tmp.= $ch; $i=0; push @res,hex($tmp) } 
   }
   if ($i != 0) {
      die "Irregular hex string: $str\n";
   }
   return @res;
}

# ---
# Compute CRC-32 checksum
# See https://en.wikipedia.org/wiki/Cyclic_redundancy_check
# This must yield 414fa339:
# print sprintf("%08Xi\n", compute_crc32(numerize("The quick brown fox jumps over the lazy dog")));
# ---

sub compute_crc32 {
   my(@data)  = @_;
   my @crctbl = build_crc_table(); # not very efficient on multiple calls
   my $crc = 0xFFFFFFFF;
   my $i = 0;
   foreach my $x (@data) {
      my $index = ($crc ^ $x) & 0xFF;
      $crc = $crctbl[$index] ^ ($crc >> 8); # ">>" is zero-filling in Perl
      $crc = $crc & 0xFFFFFFFF;             # format to 32 bit
      #if ($i > 98700 && $i < 99000) {
      #   print sprintf("$i %c : $x => %08X\n",$x,$crc); 
      #}
      $i++
   }
   return $crc ^ 0xFFFFFFFF
}

# ---
# The name of the configuration file may have been given on the command line. 
# If so slurp the file.
# If nothing has been given, slurp STDIN.
# After that, the input can be found in "@lines" (line terminators are still in there)
# ---

my @lines;

if ($ARGV[0]) {
   open(my $fh,'<',$ARGV[0]) or die "Could not open file '$ARGV[0]': $!";
   @lines = <$fh>;
   close($fh)
}
else {
   @lines = <>;
}

# ---
# Stateful analysis.
# If there are lines after "END OF EXPORT" we will disregard them
# ---

my $firmware;       # will capture firmware version
my $fritzbox;       # will capture name string in header
my @data = ();      # will capture 8-bit values to be CRC-checksummed later
my $cursum;         # will capture the current CRC checksum in the text

# "state" indicates where we are in the file

my $state = 'NOTSTARTED';

# we consider the lines as a stack and push/pop to the stack

@lines = reverse @lines;

while (@lines && $state ne 'END') {

   my $line = pop @lines;

   if ($state eq 'NOTSTARTED') {
      if ($line =~ /^\*{4} (.*?) CONFIGURATION EXPORT/) {
         $fritzbox = $1;
         $state    = 'HEADER'
      }
      else {
         chomp $line;
         die "Expected 'CONFIGURATION EXPORT' in NOTSTARTED state, got '$line'"
      }
      next
   }

   if ($state eq 'HEADER') {
      chomp $line;
      if ($line =~ /(\w+)=([\w\$\.]+)$/) {
         my $key = $1;
         my $val = $2;
         if ($key eq 'FirmwareVersion') { $firmware = $val }
         push @data,numerize($key);
         push @data,numerize($val);
         push @data,0;
      }
      elsif ($line =~ /^\*{4}/) {
         $state = 'NEXTSECTION';
         push @lines,$line
      }
      else {
         die "Unexpected line in HEADER state: '$line'"
      }
      next
   }

   if ($state eq 'NEXTSECTION') {
      chomp $line;
      if ($line =~ /^\*{4} (?:CRYPTED)?(CFG|BIN)FILE:(\S+)/) {
         $state = "INSIDESECTION_$1";
         my $secname = $2;
         print "Section $line\n";
         push @data,numerize($secname);
         push @data,0
      }   
      elsif ($line =~ /^\*{4} END OF EXPORT (\w{8}) \*{4}/) {
         $state  = 'END';
         $cursum = $1
      }
      else {
          die "Unexpected line in NEXTSECTION state: '$line'"
      }
      next
   }

   if ($state eq 'INSIDESECTION_BIN') {
      chomp $line;
      if ($line =~ /^\*{4} END OF FILE \*{4}/) {
         $state = 'NEXTSECTION'
      } 
      else {
         push @data,hexnumerize($line)
      } 
      next
   }

   if ($state eq 'INSIDESECTION_CFG') {
      if ($line =~ /^\*{4} END OF FILE \*{4}/) {
         # Something unbelievably dirty: All section-internal linefeeds (and carriage returns)
         # are kept as is for checksumming, except for the last one before the "END OF FILE"
         if ($data[-1] == ord("\n")) {
            pop @data;
            if ($data[-1] == ord("\r")) {
               pop @data;
            }
         }
         $state = 'NEXTSECTION'
      }
      else {
         # More dirty stuff: Double backspaces are replaced by single ones for some reason.
         $line =~ s/\\\\/\\/g;
         push @data,numerize($line)
      }
      next
   } 

   die "Unexpected state $state"

}

if ($state ne 'END') {
   die 'Did not find proper end of configuration'
}
if (@lines) {
   my $n = @lines;
   print "There are still $n lines left that will be disregarded"
}

my $crc = compute_crc32(@data);
my $newsum = sprintf("%08X", $crc);

print "$fritzbox with firmware $firmware\n";

if ($newsum eq $cursum) {
   print "Checksum is OK: $cursum\n"
}
else {
   print "Found new checksum: $newsum\n";
   print "Checksum embedded in file is $cursum\n"
}
