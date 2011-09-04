#!/usr/bin/perl -w

use strict;
use CGI qw/:standard/;
use Net::SMTP;
use POSIX qw/strftime/;

sub puts($) { $_ = shift; print "$_\r\n"; }
sub headerblock()
{
  puts '<!--#set var="title" value="Feedback" -->';
  puts '<!--#include virtual="/ssi/header.shtml" -->';
}
sub footerblock()
{
  puts '<!--#include virtual="/ssi/footer.shtml" -->';
}
sub start()
{
  print "Content-Type: text/html; charset=ISO-8859-1\r\n\r\n";
}



my $dest = 'james@jameshunt.us';

our $name  = param('name');
our $email = param('email');
our $body  = param('thoughts');

# validate email or wipe it out
our $from = '';
if ($email =~ m/^[\w\+-]+\@([\da-zA-Z-]+\.)+[\da-zA-Z-]{2,}$/) { $from = $email; }

my $status = 'new';
if (request_method() eq 'POST') {
  if ($name ne '' && $from ne '' && $body ne '') {

    my $smtp = Net::SMTP->new('localhost');
    $smtp->mail($from);
    $smtp->recipient($dest);
    $smtp->data;
    $smtp->datasend("To: Clockwork <$dest>\n");
    $smtp->datasend("From: $name <$from>\n");
    $smtp->datasend("Subject: [cw] Clockwork Feedback\n");
    $smtp->datasend("\n");
    $smtp->datasend("$body");
    $smtp->datasend("\n");
    $smtp->datasend("\n");
    $smtp->datasend("---------------------------------------------------------\n");
    $smtp->datasend("This message dutifully delivered by the Clockwork website\n");
    $smtp->datasend("on behalf of " . remote_host() . ' / ' . remote_addr() . "\n");
    $smtp->datasend("on this day, " . strftime("%A, %B %d, %Y @ %H:%M:%S %Z", localtime) . "\n");
    $smtp->dataend;
    $smtp->quit;

    # Do something with the email
    $status = 'succeeded';
    $name = $email = $body = '';
  } else {
    $status = 'failed';
  }
}

start(); headerblock();
puts '<h1>What&apos;s on Your Mind?</h1>';
puts '<p>Got a question about <strong>Clockwork?</strong>  Interested in hacking on the codebase?  Anything else you just have to get off your chest?  Fill out the form below and we&apos;ll get back to you as soon as we can.</p>';
puts '<p>Until we get the community support infrastructure rolling (see the <a href="/roadmap#infrastructure">Roadmap</a> for the scoop), this is your best bet for reaching a developer.</p>';

puts '    <form method="post" action="/contact#form" id="form">';
puts '      <fieldset>';
puts '        <legend>Contact Us</legend>';
if ($status eq 'failed') {
  puts '        <p class="errors">Oops! We couldn&apos;t grok your input &mdash; is something missing?</p>';
} elsif ($status eq 'succeeded') {
  puts '        <p class="success">Thanks for your Feedback!  After our very own &ldquo;Deep Blue&rdquo; determines it&apos;s not SPAM,';
  puts '        we&apos;ll read it eagerly and get back to you!  Thanks again!</p>';
}

my $class = '';
$class = ($status eq 'failed' && $name eq '' ? 'error' : '');
puts '        <div class="' . $class . '">';
puts '          <label for="name">Your Name</label>';
puts '          <input type="text" name="name" id="name" value="' . $name . '" />';
puts '          <span class="error">If you don&apos;t want to give us your real name, use an alias...</span>';
puts '        </div>';

$class = ($status eq 'failed' && $from eq '' ? 'error' : '');
puts '        <div class="' . $class . '">';
puts '          <label for="email">and Email</label>';
puts '          <input type="text" name="email" id="email" value="' . $email . '" />';
puts '          <span class="help">We solemly swear that we won&apos;t sell you to the email slavers.</span>';
puts '          <span class="error">How are we supposed to get a hold of you?</span>';
puts '        </div>';

$class = ($status eq 'failed' && $body eq '' ? 'error' : '');
puts '        <div class="' . $class . '">';
puts '          <label for="comments">Thoughts</label>';
puts '          <textarea name="thoughts" id="thoughts" rows="8" cols="50"></textarea>';
puts '          <span class="error">Did you want to tell us something?</span>';
puts '        </div>';

puts '        <div class="buttons"><button type="submit">Submit</button></div>';
puts '      </fieldset>';
puts '    </form>';

footerblock();
