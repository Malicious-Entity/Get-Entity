# Get-Entity
Scripts to query local admins quickly

1. Power Admin queries local admins in a multi-threaded manner very quickly
2. Power Admin Get Address does the same but also uses DNS to perform it by IP address.

Usage:
Just run the damn script, it will prompt for all the arguments
Both versions of power admin take these arguments
"Thread:" - The number of threads to run concurrently
"Location:" - The location of a file with all hostnames or IP addresses seperated by line breaks
"User:" - Pretty obvious, supports DOMAIN\user format
"Pass:" - Also obvious