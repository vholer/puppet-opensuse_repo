#!/usr/bin/perl -w
use Mojo::UserAgent;
use File::Flat;
use File::Temp qw(tempdir);
use File::Path qw(remove_tree);
use File::Copy::Recursive qw(dirmove);

my $url='https://download.opensuse.org/repositories/';
my $ua = Mojo::UserAgent->new->max_redirects(0); #no redirects away
my $temp = tempdir( CLEANUP => 1 );
my $dst = './files';

sub read_page($) {
	# iterate over list of links in html->body->pre section
	my @links;
	for my $l ($ua->get($_[0])->res->dom->find('html body div table tr a')->each) {
		my $href = $l->{href};
		# filter "?C=N;O=D" and absolute parent's path
		if ($href !~ /^[\/?]/) {
			$href =~ s/^\.\///; # strip leading ./
			push(@links, $href);
		}
	}
	return(\@links);
}

sub read_structure($$) {
	print $_[0],"\n";

	# read links and download SUSE* only,
	# if directorires are OS specific
	my $links = read_page($_[0]);
	my @spec_links = grep{ /^(SLE_|openSUSE_|repodata\/$)/ } @$links;
	$links = \@spec_links if @spec_links;

	for my $l (@$links) {
		next if $l =~ /^(Fedora|home):\//;
		my $nl = $_[0].$l;
		if ($nl =~ /\/$/) {
			read_structure($nl, $_[1]);
		} elsif ($nl =~ /\/repodata\/repomd\.xml\.key$/) {
			my $fc = $ua->get($nl)->res->content->asset->slurp;
			my $fn = $nl;
			$fn =~ s/^${url}\/?(.*)/$1/;  # remove URL
			$fn = "$_[1]/${fn}"; # prefix with output dir

			if ($fn && $fc) {
				File::Flat->write($fn,$fc)
					or die("Failed to write ${fn}")
			}
		}
	}
}

#####

# write timestamp
open(T, '>', "${temp}/.timestamp")
		or die('Could not open timestamp');
print(T time(),"\n") or die;
close(T) or die;

# read whole OpenSUSE web structure
read_structure($url, $temp);


# replace old keys with newly read keys
if (-d $dst) {
	remove_tree($dst)
		or die($!)
}

dirmove($temp, $dst)
	or die("Move failed: $!");
