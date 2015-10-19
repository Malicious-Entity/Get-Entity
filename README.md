# Get-Entity
Scripts to query local admins quickly

1. Power Admin queries local admins very quickly, but utilizes a DNS lookup because the WinNT Provider doesn't like FQDN.
2. Power Admin Hosts does the same but without a DNS query, so it expects you to be able to provide the correct hostname for WinNT Provider.

Obviously you'll get some errors for network paths not found or no response.

Usage:

Just run the damn script, it will prompt for all the arguments

Both versions of power admin take these arguments

"Thread:" - The number of threads to run concurrently

"Location:" - The location of a file with all hostnames or IP addresses seperated by line breaks

"User:" - Pretty obvious, supports DOMAIN\user format

"Pass:" - Also obvious

To Do: Support groups besides just administrators, big fixes
