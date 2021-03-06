#!/usr/bin/perl

# Title:       HAE requires IPv6
# Description: Check for IPv6
# Modified:    2013 Jun 21

##############################################################################
#  Copyright (C) 2013 SUSE LLC
##############################################################################
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; version 2 of the License.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, see <http://www.gnu.org/licenses/>.

#  Authors/Contributors:
#   Jason Record (jrecord@suse.com)

##############################################################################

##############################################################################
# Module Definition
##############################################################################

use strict;
use warnings;
use SDP::Core;
use SDP::SUSE;

##############################################################################
# Overriden (eventually or in part) from SDP::Core Module
##############################################################################

@PATTERN_RESULTS = (
	PROPERTY_NAME_CLASS."=HAE",
	PROPERTY_NAME_CATEGORY."=Communication",
	PROPERTY_NAME_COMPONENT."=IPv6",
	PROPERTY_NAME_PATTERN_ID."=$PATTERN_ID",
	PROPERTY_NAME_PRIMARY_LINK."=META_LINK_TID",
	PROPERTY_NAME_OVERALL."=$GSTATUS",
	PROPERTY_NAME_OVERALL_INFO."=None",
	"META_LINK_TID=http://www.suse.com/support/kb/doc.php?id=7012111"
);




##############################################################################
# Local Function Definitions
##############################################################################

sub ipv6Disabled {
	SDP::Core::printDebug('> ipv6Disabled', 'BEGIN');
	my $RCODE = 1;
	my $FILE_OPEN = 'modules.txt';
	my $SECTION = 'lsmod';
	my @CONTENT = ();

	if ( SDP::Core::getSection($FILE_OPEN, $SECTION, \@CONTENT) ) {
		foreach $_ (@CONTENT) {
			next if ( m/^\s*$/ ); # Skip blank lines
			if ( /^ipv6\s/ ) {
				SDP::Core::printDebug("PROCESSING", $_);
				$RCODE = 0;
				last;
			}
		}
	} else {
		SDP::Core::updateStatus(STATUS_ERROR, "ERROR: ipv6Disabled(): Cannot find \"$SECTION\" section in $FILE_OPEN");
	}
	SDP::Core::printDebug("< ipv6Disabled", "Returns: $RCODE");
	return $RCODE;
}

##############################################################################
# Main Program Execution
##############################################################################

SDP::Core::processOptions();
	if ( SDP::SUSE::haeEnabled() ) {
		if ( ipv6Disabled() ) {
			SDP::Core::updateStatus(STATUS_WARNING, "IPv6 Disabled, Enable for HAE clusters");
		} else {
			SDP::Core::updateStatus(STATUS_ERROR, "IPv6 Enabled");
		}
	} else {
		SDP::Core::updateStatus(STATUS_ERROR, "HAE is not enabled");
	}
SDP::Core::printPatternResults();

exit;


