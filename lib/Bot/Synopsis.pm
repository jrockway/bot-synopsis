package Bot::Synopsis;

use strict;
use warnings;
use feature ':5.10';
use Moses;
use Web::Scraper;
use URI;

override default_nickname => sub { 'Synopsis' };
override default_owner => sub 
  { 'jrockway!~jrockway@dsl092-134-178.chi1.dsl.speakeasy.net' };

event irc_bot_addressed => sub { 
    my ( $self, $irc, $nickstring, $channels, $message ) =
      @_[ OBJECT, SENDER, ARG0, ARG1, ARG2 ];
    my ($nick) = split /!/, $nickstring;
    my $reply = "syntax error";
    
    my $res = eval {
        my $s = scraper { 
            process '//a[@name=\'NAME\']/following::p[1]', 
              description => 'TEXT';
        };
        
        my $url = URI->new("http://search.cpan.org/perldoc?$message");
        
        $s->scrape($url);
    };
    
    given($res->{description} || ''){
        when(length $_ > 1){
            $reply = $_;
        }
        when(length $_ < 1){
            $reply = "No module found";
        }
    }
    
    $self->privmsg( $_ => "$nick: $reply" ) for @$channels;
}; 

1;
