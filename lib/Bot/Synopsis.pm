package Bot::Synopsis;

use strict;
use warnings;
use feature ':5.10';
use Moses;
use Web::Scraper;
use URI;

my $LIBERAL_MODULE = qr/\b(?<module>(?:\w+(?:::)?)+)\b/;
my $STRICT_MODULE = qr/\b(?<module>[A-Z](?:\w+(?:::))+\w+)\b/;

sub _extract_module_name {
    my ($self, $message) = @_;

    return $+{module} if $message=~ /$STRICT_MODULE/;
    confess 'no module found' unless $message =~ /$LIBERAL_MODULE/;

    return $+{module};
}

sub _get_description {
    my ($self, $module) = @_;
        
    my $res = eval {
        my $s = scraper { 
            process '//a[@name=\'NAME\']/following::p[1]', 
              description => 'TEXT';
        };
        
        my $url = URI->new("http://search.cpan.org/perldoc?$module");
        
        $s->scrape($url);
    };
    
    given($res->{description}){
        return $_ if $_;
    }
    
    # not the best way to indicate an error, but whatever
    return "no description found for $module";
}

sub _do_it {
    my ($self, $message) = @_;
    return eval { 
        $self->_get_description(
            $self->_extract_module_name($message),
        );
    } || 'syntax error';
}

override default_nickname => sub {
    'Synopsis'
};

override default_owner    => sub { 
    'jrockway!~jrockway@dsl092-134-178.chi1.dsl.speakeasy.net'
};

event irc_public => sub {
    my ( $self, $irc, $nickstring, $channels, $message ) =
      @_[ OBJECT, SENDER, ARG0, ARG1, ARG2 ];
    my ($nick) = split /!/, $nickstring;

    return if $message =~ /Synopsis/; # XXX
    return unless $message =~ /::.*[?]/;
    my $reply = $self->_do_it($message);
    
    $self->privmsg( $_ => $reply ) for @$channels;
};

event irc_bot_addressed => sub { 
    my ( $self, $irc, $nickstring, $channels, $message ) =
      @_[ OBJECT, SENDER, ARG0, ARG1, ARG2 ];
    my ($nick) = split /!/, $nickstring;

    my $reply = $self->_do_it($message);
    
    $self->privmsg( $_ => "$nick: $reply" ) for @$channels;
}; 

1;
