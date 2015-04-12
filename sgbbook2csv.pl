#!/usr/bin/perl

#######################################################
# sgbbook2csv
# ---------------------
# converts a description of character meetups in a book
# into node and edge CSV tables, starting from an input
# file that conforms to the Stanford Graph Base book format
# (e.g.  'anna.dat' and/or 'jean.dat')
#
# usage
# ---------------------
# sgbbook2csv.pl SGB_FILE.dat NODE_OUT.csv EDGE_OUT.csv
#
# Author: Matthew W. Taylor
# Copyright (c) 2015, Northwestern University
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
# 
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#######################################################

@srcnodedata;
@srcedgedata;
@nodedata;
@edgedata;

$numArgs = $#ARGV + 1;
if ($numArgs < 3) {
	print("\nusage: sgbbook2csv.pl PATH_TO_SGB_FILE.dat PATH_TO_NODE_CSV_OUTPUT.csv PATH_TO_EDGE_CSV_OUTPUT.csv\n");
	exit(0);
}
$sgbbookfile = $ARGV[0];
$nodeoutfile = $ARGV[1];
$edgeoutfile = $ARGV[2];

sub read_in_file;
sub generate_edge_list;
sub generate_node_list;
sub write_edge_file;
sub write_node_file;
sub trim;
sub ttrim;

sub read_in_file {

	# open the sgb file and iterate to gather the blocks
	open($infile, "<:encoding(UTF-8)", $sgbbookfile)
		or die "cannot open < $sgbbookfile: $!";
		
	# first section of file contains node data, second contains edge data
	# sections are separated by an empty line
	my $section = 1; 
	my $line;

	while($line = <$infile>) {

		if($line =~ /\*.*/) { 
			# looks like a comment line, ignore it	
		 }
		elsif($line =~ /^$/) {
			# looks like an empty line, change modes
			$section++;
		}
		elsif($section eq 1) {
			chop($line);
			push @srcnodedata, $line;
		} 
		else {
			chop($line);
			push @srcedgedata, $line;
		}
	}
	close($infile);
}

sub generate_edge_list {
	# chapters have 1 or more sets of meetups
	my $chapter = "";
	# a meetup involves one or more characters
	my $meetups = "";
	my $idcounter = 0;

	foreach(@srcedgedata) {
		$line = $_;
		if ($line =~ /\:/) {
			($chapter, $meetups) = split(/\:/, $line, 2);
			
			# an array of meetup sets split on semicolons
			@meetupgroups = split(/;/, $meetups);
			
			foreach(@meetupgroups) {
				#meetup members are separated by commas
				@meetupmembers = split(/,/, $_);
				my $meetupSize = @meetupmembers;
				if ($meetupSize < 2) {
					# not interested in meetup parties of one
				} 
				else {
					# we want to generate a list of meetups
					# all combinations of characters in the meetup
					# taken two at a time 
					
					foreach my $a (0..$#meetupmembers) {
 					   foreach my $b ($a+1..$#meetupmembers) {
 					   	# log the meetup
 					   	$idcounter++;
 					   	push @edgedata, $meetupmembers[$a] . "," . $meetupmembers[$b] ."," . "Undirected" . "," . $idcounter . "," .$chapter;
    					}
					}
				}
			}
			
		} else {
			# no meetup data for this line, did not contain a colon
		}
	}
}

sub generate_node_list {
	
	foreach(@srcnodedata) {
		$line = $_;
		my($nodeID, $labelanddescription) = split(/\s/, $line, 2);
		my($description, $label) = split(/\t/, $labelanddescription, 2); 
		
		$label=~s/^\s+//;
		$label=~s/\s+$//;
		
		$description=~s/^\s+//;
		$description=~s/\s+$//;

		$nodeID=~s/^\s+//;
		$nodeID=~s/\s+$//;
		
		if ($label eq "") {
			$label = $nodeID;
		}	
		push @nodedata, "\"$nodeID\",\"$label\",\"$description\"";
	}		
}

sub write_node_file {
	my $filehandle;
	open($filehandle, ">:encoding(UTF-8)", $nodeoutfile) or die "Could not open file '$filename'";
	print $filehandle ("Id,Label,Description" . "\n");
	foreach(@nodedata) {
		print $filehandle ($_ . "\n");
	}
	close($filehandle);
}

sub write_edge_file {
	my $filehandle;
	open($filehandle, ">:encoding(UTF-8)", $edgeoutfile) or die "Could not open file '$filename'";
	print $filehandle ("Source,Target,Type,Id,Label" ."\n");
	foreach(@edgedata) {
		print $filehandle ($_ . "\n");
	}
	close($filehandle);
}

sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };
sub  ttrim { my $s = shift; $s =~ s/^\t+|\t+$//g; return $s };


read_in_file;
generate_edge_list;
generate_node_list;
write_node_file;
write_edge_file;
