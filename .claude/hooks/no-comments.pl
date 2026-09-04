#!/usr/bin/perl
use strict; use warnings;
# ponytail: regex JSON extraction, no JSON module; hook input is Claude-generated, escapes handled below
local $/; my $in = <STDIN>;
my ($fp) = $in =~ /"file_path"\s*:\s*"((?:[^"\\]|\\.)*)"/;
exit 0 unless defined $fp && $fp =~ /\.(ts|tsx|js|jsx|mjs|cjs)$/;
my @bad;
while ($in =~ /"(?:new_string|content)"\s*:\s*"((?:[^"\\]|\\.)*)"/g) {
    my $t = $1;
    $t =~ s/\\u([0-9a-fA-F]{4})/chr hex $1/ge;
    $t =~ s/\\r//g; $t =~ s/\\n/\n/g; $t =~ s/\\t/\t/g; $t =~ s/\\"/"/g; $t =~ s{\\/}{/}g; $t =~ s/\\\\/\\/g;
    for (split /\r?\n/, $t) {
        push @bad, $_ if (m{^\s*//(?!/)} || m{^\s*/\*} || m{\{\s*/\*}) && !/\@ts-|eslint-|biome-ignore|prettier-ignore/;
    }
}
exit 0 unless @bad;
print STDERR "BLOCKED: comments are forbidden in this codebase. Rewrite the edit without these lines:\n", join("\n", @bad[0..($#bad<9?$#bad:9)]), "\n";
exit 2;
