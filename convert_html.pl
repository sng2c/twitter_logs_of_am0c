#!/usr/bin/env perl 
use strict;
use 5.010;
use YAML;
use Data::Printer;
use utf8;
use Date::Parse;
sub am0c{'am0c'};

binmode(STDOUT,':utf8');

my $logs = YAML::LoadFile('am0c_chat.yaml');
#my $logs = YAML::LoadFile('test.yaml');

sub to_localtime{
	my $time = str2time(shift->{created_at});
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
	$year+=1900;
	$mon++;
	return ($year, sprintf('%04d-%02d',$year,$mon),sprintf('%04d-%02d-%02d',$year,$mon, $mday),sprintf('%02d:%02d:%02d', $hour,$min,$sec));
}

say <<HEAD;
<!doctype html>
<html>
	<head>
		<link href="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.3.1/css/bootstrap-combined.min.css" rel="stylesheet">
		<script src="http://code.jquery.com/jquery.js"></script>
		<script src="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.3.1/js/bootstrap.min.js"></script>
		<style>
			.yearly {}
			.monthly {}
			.daily {}
			.single {}
			.chat {}

			li.am0c {}
			li.prev {}
			li.am0c.prev{}
		</style>
		<link href="am0c.css" rel="stylesheet">
	</head>
<body>
<div class="container">
<h1>am0c's twitter log</h1>

HEAD

my ($yearly,$monthly,$daily);
foreach my $log (@{$logs}){
	
	my($y,$m,$d,$t) = to_localtime( $log );

	if( $y ne $yearly ){
		say qq(</div> ) if $yearly;
		$yearly = $y;
		say qq(<div class='yearly'><a href='#$yearly' id='$yearly'>$yearly</a>);
	}
	if( $m ne $monthly){
		say qq(	</div> ) if $monthly;
		$monthly = $m;
		say qq(	<div class='monthly'><a href='#$monthly' id='$monthly'>$monthly</a>);
	}
	if( $d ne $daily){
		say qq( 	</div> ) if $daily;
		$daily = $d;
		say qq(		<div class='daily'><a href='#$daily' id='$daily'>$daily</a>);
	}



	say "			<ul>";
	if( $log->{chat} ){
		foreach my $chat (@{$log->{chat}}){
			my($y,$m,$d,$t) = to_localtime( $chat );
			say qq(				<li class="prev $chat->{screen_name}"> <span class='name'>$chat->{screen_name}</span> <span class='text'>$chat->{text}</span> <span class='time'>$d $t</span> </li>);
		}
	}

	say qq(				<li class="$log->{screen_name}"> <span class='name'>$log->{screen_name}</span> <span class='text'>$log->{text}</span> <span class='time'>$d $t</span> </li>);
	say "			</ul>";
}

say qq(		</div> );
say qq(	</div> );
say qq(</div> );

say qq(</div> );
say qq(</body>);
say qq(</html>);
