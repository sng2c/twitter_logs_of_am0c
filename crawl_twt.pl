#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;
use 5.010;

sub amoc{'am0c'};

use Net::Twitter;
use JSON;
use LWP::Simple;
use URI::Escape;
use YAML;

my $consumer_key = ''; 
my $consumer_secret = '';
my $access_token = '';
my $access_token_secret = '';

my $api = Net::Twitter->new(
		traits   => [qw/OAuth API::REST RetryOnError RateLimit WrapError SimulateCursors/, 
		],
		max_retries => 3,
		consumer_key        => $consumer_key,
		consumer_secret     => $consumer_secret,
		access_token        => $access_token,
		access_token_secret => $access_token_secret,
);

## CHECK VALID ACCOUNT
#my $user = $api->verify_credentials();
#if( !defined($user) ){
#	say "잘못된 계정";
#	undef($api);
#	return;
#}
	
my $max = 200;
my $cnt=100;
my $max_id = 0;
$max_id = $ARGV[0] if($ARGV[0]);
my $total = 0;
my @twts;
while($cnt--){
	if( $api->rate_remaining() < 10 ){
		my $sleep = $api->until_rate(1.0);
		if( $sleep ){
			say "sleep until $sleep";
			sleep($sleep);
		}	
	}

	my $sts = [];	
	if( $max_id==0 ){
		$sts = $api->user_timeline({screen_name=>amoc ,trim_user=>1,count=>$max,include_rts=>1});
	}
	else{
		$sts = $api->user_timeline({screen_name=>amoc ,trim_user=>1,count=>$max,include_rts=>1,max_id=>$max_id});
	}

	if( !$sts || @{$sts} == 0 ){
		#say "max_id :  $max_id";
		#$max_id -= 1000000;
		#say "max_id-1000000 :  $max_id";
		#say "jump 10000 tweetid";
		last;
	}
	$total += @{$sts};
	push(@twts,@{$sts});
	say "total : $total";
	my $last = pop(@{$sts});
	$max_id = $last->{id} - 1;
	say "max_id :  $max_id";
}
YAML::DumpFile('am0c.yaml',\@twts);
say "Done";
