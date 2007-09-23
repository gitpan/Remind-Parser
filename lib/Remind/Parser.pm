package Remind::Parser;

use strict;
use warnings;

use vars qw($VERSION);

$VERSION = '0.01';

unless (caller()) {
    eval "require YAML"
        or die "YAML required to run the package source as a filter";
    my $reminders = __PACKAGE__->new->parse(\*STDIN);
    print YAML::Dump($reminders);
}

# --- Constructor

sub new {
    my $cls = shift;
    my $self = bless {
        @_,
    }, $cls;
    return $self->_init;
}

sub _init {
    my ($self) = @_;
    # Nothing to do
    return $self;
}

# --- Accessors

sub strict { scalar(@_) > 1 ? $_[0]->{'strict'} = $_[1] : $_[0]->{'strict'} }

# --- Other public methods

sub parse {
    my ($self, $fh) = @_;
    my ($file, $line, $loc, %file);
    my ($past_header, $all_done);
    my @reminders;
    my %loc2event;
    my %loc2count;
    my $next_event = 1;
    my $start = <$fh>;
    if ($start !~ /^# rem2ps begin$/) {
        die "First line of input is not the proper header: $_"
            if $self->strict;
    }
    while (<$fh>) {
        chomp;
        if ($all_done) {
            die "Spurious input at end of input: $_"
                if $self->strict;
            last;
        }
        if (/^# fileinfo (\d+) (.+)/) {
            ($line, $file) = ($1, $2);
            $loc = "$file:$line";
            $past_header = 1;
        }
        elsif ($past_header) {
            # We've skipped past the header
            if (/^# rem2ps end$/) {
                # All done
                $all_done = 1;
            }
            else {
                my ($date, $special, $tag, $duration, $offset, $description) = split / +/, $_, 6;
                my ($year, $month, $day) = split m{[-/]}, $date;
                my $event = $loc2event{$loc} ||= $next_event++;
                my $instance = ++$loc2count{$loc};
                my %reminder = (
                    'event'       => $event,
                    'instance'    => $instance,
                    'file'        => $file,
                    'line'        => $line,
                    'year'        => $year  + 0,
                    'month'       => $month + 0,
                    'day'         => $day   + 0,
                    'description' => $description,
                    $tag eq '*'     ? () : ('tag'     => $tag),
                    $special eq '*' ? () : ('special' => $special),
                );
                my ($begin, $end);
                if ($offset eq '*') {
                    # Untimed (whole day) reminder
                    $reminder{'all_day'} = 1;
                }
                else {
                    # Timed reminder
                    my $hour   = int($offset / 60);
                    my $minute = $offset % $hour;
                    $reminder{'hour'}   = $hour;
                    $reminder{'minute'} = $minute;
                }
                push @reminders, \%reminder;
            }
        }
    }
    return \@reminders;
}


1;


=head1 NAME

Remind::Parser - parse `remind -lp' output

=head1 SYNOPSIS

    use Remind::Parser;
    $parser = Remind::Parser->new(...);
    $reminders = $parser->parse(\*STDIN);
    foreach (@$reminders) {
        ...
    }

=head1 DESCRIPTION

B<Remind::Parser> parses an input stream produced by remind(1) and intended for
back-end programs such as B<rem2ps(1)> or B<wyrd(1)>.

For details on the input format, see L<rem2ps(1)>.

=head1 PUBLIC METHODS

=over 4

=item B<new>(I<%args>)

    $parser = Remind::Parser->new;
    $parser = Remind::Parser->new('strict' => 1);

Create a new parser.  A single (key, value) pair may be supplied:

If B<strict> is specified, the B<parse> method will complain of any lines of
input following the C<# rem2ps end> line.

=item B<strict>([I<boolean>])

    $is_strict = $parser->strict;
    $parser->strict(1);  # Be strict
    $parser->strict(0);  # Don't be strict

Get or set the parser's B<strict> property.
If B<strict> is specified, the B<parse> method will complain of any lines of
input following the C<# rem2ps end> line.

=item B<parse>(I<$filehandle>)

    $events = Remind::Parser->parse(\*STDIN);

Parse the contents of a filehandle, returning a reference to a list of
reminders.  The input must have been produced by invoking
B<remind -l -p[>I<num>B<]>; otherwise, it will not be parsed correctly.
(If remind's B<-pa> option was used, "pre-notification" reminders are correctly
parsed but cannot be distinguished from other reminders.)

Each reminder returned is a hash containing the following elements:

=over 4

=item B<day>

=item B<month>

=item B<year>

The day, month, and year of the reminder.

=item B<description>

The reminder description (taken from the B<MSG> portion of the remind(1)
source).

=item B<all_day>

If this element is present and has a true value, the reminder is an all-day
event.  Otherwise, it's a timed event.

=item B<hour>

=item B<minute>

The hour and minute of the reminder, if it's a timed reminder.  Absent
otherwise.

=item B<tag>

The B<TAG> string from the remind(1) source.  Absent if no B<TAG> string was
present.

=item B<special>

The B<SPECIAL> string from the remind(1) source.  Absent if no B<SPECIAL> string
was present.

=item B<line>

=item B<file>

The line number and file name of the file containing the reminder.

=item B<event>

=item B<instance>

These two elements together uniquely identify a reminder.  Reminders triggered
from a single file and line share the same B<event> identifier but have distinct
B<instance> identifiers.

=back

=back

=head1 BUGS

There are no known bugs.  Please report bugs to the author via e-mail
(see below).

=head1 TO DO

Parse formats other than that produced by C<remind -l -p[a|num]>?

Add an option to skip reminders with unrecognized B<SPECIAL>s?

=head1 AUTHOR

Paul Hoffman (nkuitse AT cpan DOT org)

=head1 COPYRIGHT

Copyright 2007 Paul M. Hoffman.

This is free software, and is made available under the same terms as Perl
itself.

=head1 SEE ALSO

L<remind(1)>,
L<rem2ps(1)>,
L<wyrd(1)>
