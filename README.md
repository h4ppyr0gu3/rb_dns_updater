# DNS Updater

This script is designed to be run every 5 to 10 minutes to update your DNS records in cloudflare

## Requirements

It requires the following:
- Cloudflare Email
- Cloudflare Auth Key
- Cloudflare API Key
- Cloudflare Domain Name

## Usage

Variables can be passed in by the command line but will fall back to environment variables if not set.
the following environment variables are used

- `CLOUDFLARE_EMAIL`
- `CLOUDFLARE_AUTH_KEY`
- `CLOUDFLARE_API_KEY`
- `CLOUDFLARE_DOMAIN`

```bash
# Usage: dns_updater [options]
#   -e, --email EMAIL                Cloudflare Email Address
#       --auth-key AUTH_KEY          Cloudflare Auth Key
#       --api-key API_KEY            Cloudflare API Key
#   -d, --domain DOMAIN              Cloudflare Domain Name
#   -v, --[no-]verbose               Run verbosely

# Note: You can also set the environment variables in the script
dns_updater
```

## Installation

```bash
curl https://raw.githubusercontent.com/h4ppyr0gu3/rb_dns_updater/master/install.sh | bash
```

## How it works

**N.B.** This only updates `A` records

This script queries the IP address of the current machine and then compares that with a file that will exist if it has run before, that file will contain the ip address
if the new ip address is the same as the previous ip address, it will not update the DNS record
if they are different it will log information and update the DNS record

