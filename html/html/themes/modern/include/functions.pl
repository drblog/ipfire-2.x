#!/usr/bin/perl
###############################################################################
#                                                                             #
# IPFire.org - A linux based firewall                                         #
# Copyright (C) 2007  Michael Tremer & Christian Schmidt                      #
#                                                                             #
# This program is free software: you can redistribute it and/or modify        #
# it under the terms of the GNU General Public License as published by        #
# the Free Software Foundation, either version 3 of the License, or           #
# (at your option) any later version.                                         #
#                                                                             #
# This program is distributed in the hope that it will be useful,             #
# but WITHOUT ANY WARRANTY; without even the implied warranty of              #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               #
# GNU General Public License for more details.                                #
#                                                                             #
# You should have received a copy of the GNU General Public License           #
# along with this program.  If not, see <http://www.gnu.org/licenses/>.       #
#                                                                             #
###############################################################################
#                                                                             #
# Theme file for IPfire (based on ipfire theme)                               #
# Author kay-michael köhler kmk <michael@koehler.tk>                          #
#                                                                             #
# Version 1.0	March, 6th 2013                                               #
###############################################################################
#                                                                             #
# Modyfied theme by a.marx@ipfire.org January 2014                            #
#                                                                             #
# Cleanup code, deleted unused code and rewrote the rest to get a new working #
# IPFire default theme.                                                       #
###############################################################################

require "${General::swroot}/lang.pl";

###############################################################################
#
# print menu html elements for submenu entries
# @param submenu entries
sub showsubmenu() {
	my $submenus = shift;
	
	print '<ul class="dropdown-menu">';
	foreach my $item (sort keys %$submenus) {
		$link = getlink($submenus->{$item});
		next if (!is_menu_visible($link) or $link eq '');

		my $subsubmenus = $submenus->{$item}->{'subMenu'};

		if ($subsubmenus) {
			print '<li class="dropdown">';
		} else {
			print '<li>';
		}
		print '<a href="'.$link.'">'.$submenus->{$item}->{'caption'}.'</a>';

		&showsubmenu($subsubmenus) if ($subsubmenus);
		print '</li>';
	}
	print "</ul>"
}

###############################################################################
#
# print menu html elements
sub showmenu() {
	print '<div id="cssmenu" class="row"><div class="col-md-12">';

	print '<nav class="navbar navbar-default" role="navigation">
	<div class="navbar-header">
	<button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
		<span class="sr-only">Toggle navigation</span>
		<span class="icon-bar"></span>
		<span class="icon-bar"></span>
		<span class="icon-bar"></span>
	</button>
	<a class="navbar-brand" href="#">';

	 if ($settings{'WINDOWWITHHOSTNAME'} ne 'off') {
                print "$settings{'HOSTNAME'}.$settings{'DOMAINNAME'}";
        } else {
                print "<h1>IPFire</h1>";
        }

	print '</a>
	</div><!-- Collect the nav links, forms, and other content for toggling -->
	<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">';

	print '<ul class="nav navbar-nav">';

	foreach my $k1 ( sort keys %$menu ) {
		$link = getlink($menu->{$k1});
		next if (!is_menu_visible($link) or $link eq '');
		print '<li class="dropdown"><a href="#" class="dropdown-toggle" data-toggle="dropdown"><span>'.$menu->{$k1}->{'caption'}.'<b 
class="caret"></b></span></a>';
		my $submenus = $menu->{$k1}->{'subMenu'};
		&showsubmenu($submenus) if ($submenus);
		print "</li>";
	}

	print "</ul>";

	if ($settings{'SPEED'} ne 'off') {
                print <<EOF;
                        <p id='traffic' class='navbar-text navbar-right'>
                                <strong>Traffic:</strong>
                                In  <span id='rx_kbs'>--.-- Bit/s</span> &nbsp;
                                Out <span id='tx_kbs'>--.-- Bit/s</span>
                        </p>
EOF
        }

	print "</nav></div></div>";
}

###############################################################################
#
# print page opening html layout
# @param page title
# @param boh
# @param extra html code for html head section
# @param suppress menu option, can be numeric 1 or nothing.
#		 menu will be suppressed if param is 1
sub openpage {
	my $title = shift;
	my $boh = shift;
	my $extrahead = shift;
	my $suppressMenu = shift;
	my @tmp = split(/\./, basename($0));
	my $scriptName = @tmp[0];

	@URI=split ('\?',  $ENV{'REQUEST_URI'} );
	&General::readhash("${swroot}/main/settings", \%settings);
	&genmenu();

	my $headline = "IPFire";
	if (($settings{'WINDOWWITHHOSTNAME'} eq 'on') || ($settings{'WINDOWWITHHOSTNAME'} eq '')) {
		$headline =  "$settings{'HOSTNAME'}.$settings{'DOMAINNAME'}";
	}

	my @stylesheets = ("style.css");
	if ($THEME_NAME eq "ipfire-rounded") {
		push(@stylesheets, "style-rounded.css");
	}

print <<END;
<!DOCTYPE html>
<html>
	<head>
	<title>$headline - $title</title>
	$extrahead
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
	<link rel="shortcut icon" href="/favicon.ico" />
	<link href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css" rel="stylesheet">
	<script type="text/javascript" src="/include/jquery.js"></script>

	<script type="text/javascript">
		function swapVisibility(id) {
			\$('#' + id).toggle();
		}
	</script>
END

if ($settings{'SPEED'} ne 'off') {
print <<END
	<script type="text/javascript" src="/themes/ipfire/include/js/refreshInetInfo.js"></script>
END
;
}

print <<END
	</head>
	<body>
	<div class="container">	
END
;

&showmenu() if ($suppressMenu != 1);

print <<END
	<div class="jumbotron panel">
		<div id="main_inner" class="fixed">
			<h1>$title</h1>
END
;
}

###############################################################################
#
# print page opening html layout without menu
# @param page title
# @param boh
# @param extra html code for html head section
sub openpagewithoutmenu {
	openpage(shift,shift,shift,1);
	return;
}

###############################################################################
#
# print page closing html layout

sub closepage () {
	open(FILE, "</etc/system-release");
	my $system_release = <FILE>;
	$system_release =~ s/core/Core Update/;
	close(FILE);

print <<END;
		</div>
	</div>
	<div id="footer" class="well well-sm">
		<span class="pull-right">
			<a href="http://www.ipfire.org/" target="_blank"><strong>IPFire.org</strong></a> &bull;
			<a href="http://www.ipfire.org/donate" target="_blank">$Lang::tr{'support donation'}</a>
		</span>

		<strong>$system_release</strong>
	</div>
	</div><!-- container end -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
<script src="//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
</body>
</html>
END
;
}

###############################################################################
#
# print big box opening html layout
sub openbigbox {
}

###############################################################################
#
# print big box closing html layout
sub closebigbox {
}

###############################################################################
#
# print box opening html layout
# @param page width
# @param page align
# @param page caption
sub openbox {
	$width = $_[0];
	$align = $_[1];
	$caption = $_[2];

	if($align eq 'center') {
		print "<div class='post' align='center'>\n"
	}
	else {
		print "<div class='post'>\n";
	}

	if ($caption) {
		print "<h2>$caption</h2>\n";
	}
}

###############################################################################
#
# print box closing html layout
sub closebox {
	print "</div>";
}

1;
