slurm-lex-accounting-upload
=============

This repo has the scripts used to track and report on allocation utilization on NREL HPC systems.

Install
===

```bash
python3 setup.py install
slurm-lex-accounting-upload --help
```

Usage
===

For Eagle, this script runs on the eagle-collector node as a cron.  This should run as a non-privileged user.
You can customize the clustername either as a cli argument to the script or by setting the NREL_CLUSTER environment variable.

The upload script can be given arguments to change behavior.  If no arguments it processes jobs from yesterday and today.
The Lex REST API allows for updates: it is fine to re-run for prior days if days are missed, or if something needs to change.
Lex will update existing records to the new data provided by this script.
The upload script uses [SlurmHandler](lib/slurm_lex_accounting/slurm.py) to interact with Slurm (mostly sacct) and the [LexHandler](lib/slurm_lex_accounting/lex.py) to interact with Lex.

```
Usage: slurm-lex-accounting-upload [options]

Options:
  -h, --help            show this help message and exit
  --clustername=CLUSTERNAME
                        The cluster name for reporting to lex.  You can also
                        set the OS environment variable NREL_CLUSTER.  The CLI
                        argument overrides the environment variable.
  --date=DAYSTRING      Date to use for processing jobs, if nothing is
                        specified it will process jobs with an end time from
                        today and yesterday. Example: %Y-%m-%d.
  --start=STARTING_DATE
                        Start date to process jobs by job end time. Similar to
                        --date, but allows you to specify a range of dates. If
                        date is specified, start and end will not be used.
                        Example: %Y-%m-%d. Defaults to yesterday.
  --end=ENDING_DATE     End date to process jobs by job end time. Similar to
                        --date, but allows you to specify a range of dates. If
                        date is specified, start and end will not be used.
                        Example: %Y-%m-%d. Defaults to today.
  --cred_file=CRED_FILE
                        Password file for lex.  Clear text file where first
                        line is the username and second line is the password.
                        Defaults to
                        /nopt/nrel/admin/accounting/data/.accessLexAcct.
  --dev                 Enable developer version of lex for testing.
  --insecure            Enable insecure tls, disable verification checks for
                        tls.
  --debug               Enable debug mode, more verbose output
  --server=SERVER       Set custom Lex server name or IP address (used for local
                        development), most likely needs --insecure.
```

Example Cron
===

```
MAILTO=firstname.lastname@nrel.gov
# accounting
*/30 * * * * /usr/local/bin/slurm-lex-accounting-upload > /tmp/slurm-lex-accounting-upload.log 2>&1
```
