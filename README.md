#Enterprise environment, using 1 process with 15 threads, queried 600 systems in ~15 minutes.

#Known Bugs:
Errors out on systems with more than one DNS entry (dual-homed etc.)

#Updates
Coming soon: Alternate mode for when storing network credentials is disabled also enabling the script to run as the current logged in user (no user/pass input) for instances where a system is compromised, but not the user password. As a workaround, the script can be changed to make the paramaters not mandatory.

1/12/16 Update: Previous update introduced an error that severely limited the speed due to a process being outside of the scriptblock. Please be sure to download the updated version to get the proper speed.

Update: Variable was in wrong position in the original version - fixed

Pivot-Entity queries local admins very quickly, but utilizes a DNS lookup because the WinNT Provider doesn't like FQDN.
Obviously you'll get some errors for network paths not found or no response.

#Usage:

Just run the script, it will prompt for all the arguments

Both versions of power admin take these arguments

"Thread:" - The number of threads to run concurrently

"Location:" - The location of a file with all hostnames or IP addresses seperated by line breaks

"User:" - Pretty obvious, supports DOMAIN\user format

"Pass:" - Also obvious

To Do: Support groups besides just administrators, bug fixes
