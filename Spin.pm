use strict;
package Spin;

sub new {
	my $self = {};
	$self->{pid} = undef;
	$self->{message} = $_[1];
	bless($self);
	return($self);
}

sub start {
	my $self = shift;
	use Time::HiRes qw(sleep);
	use IO::Handle;
	STDERR->autoflush(1);
	STDOUT->autoflush(1);
	use Term::Size;
	my $message = $self->{message};
	my @spin = ('/', '-', '\\', '|');
	my $spincount = '0';
	my $spinner;
	my ( $termlength, undef ) = Term::Size::chars *STDOUT{IO};
	my $space = ( $termlength - $message - 50 );
	my $pid = fork();
	if ( $pid eq 0 ) {
		while (1) {
			if ( $spincount eq ( $#spin + 1 ) ) { $spincount = '0' }
			print "[" . $spin[$spincount] . "] $message" . "\ "x$space . "\r";
			$spincount++;
			sleep(0.1);
		}
	}
	$self->{pid} = $pid;
	return 1;
}

sub stop {
	my $self = shift;
	use Term::Size;
	my ( $termlength, undef ) = Term::Size::chars *STDOUT{IO};
	my ($pid) = $self->{pid};
	kill(9, $pid);
	print "\ "x$termlength . "\r";
}

sub update {
	my $self = shift;
	if ( $self->{pid} ) {
		$self->stop;
	}

	$self->{message} = shift;

	if ( $self->{pid} ) {
		$self->start;
	}
	return 1;
}

1;
