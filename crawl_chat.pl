#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;
use 5.010;

sub am0c{'am0c'};

use Net::Twitter;
use JSON;
use LWP::Simple;
use URI::Escape;
use YAML;


binmode(STDOUT,':utf8');


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
my $twt = YAML::LoadFile('am0c.yaml');
say @{$twt}."ea";
my @tt;
foreach my $twt (@{$twt}){
	my $t = {
		created_at=> $twt->{created_at},
		id=> $twt->{id},
		screen_name=>am0c,
		in_reply_to_screen_name=> $twt->{in_reply_to_screen_name},
		in_reply_to_status_id=> $twt->{in_reply_to_status_id},
		text=> $twt->{text},
	}; 

	# get conversations
	if( $t->{in_reply_to_status_id} ){
		say "has chat for ".$t->{text};
		my $previd = $t->{in_reply_to_status_id};
		my @chat;
		while( $previd ){
			if( $api->rate_remaining() < 10 ){
				my $sleep = $api->until_rate(1.0);
				if( $sleep ){
					say "sleep until $sleep";
					sleep($sleep);
				}	
			}


			my $twt = $api->show_status($previd);
			if( $twt ){
				my $ct = {
					created_at=> $twt->{created_at},
					id=> $twt->{id},
					screen_name=>$twt->{user}->{screen_name},
					in_reply_to_screen_name=> $twt->{in_reply_to_screen_name},
					in_reply_to_status_id=> $twt->{in_reply_to_status_id},
					text=> $twt->{text},
				};
				say "\t".$ct->{screen_name}.":".$ct->{text};
				$previd = $ct->{in_reply_to_status_id}; 
				push(@chat,$ct);
			}
			else{
				$previd = '';
			}
		}
		$t->{chat} = \@chat;
	}

	push(@tt,$t);	
}

YAML::DumpFile('am0c_chat.yaml',\@tt);
say "Done";

