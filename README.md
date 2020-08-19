# Dalmatian Frontend

This service is intended to be used by developers and designers who need to view and change the way applications are hosted on Dalmatian.

Due to risks associated with the high level of access, this service is designed to be run locally instead of being hosted on the internet. It will use your machines AWS configuration.

## Prerequisites [likely to be missing details]

1. The ops team will need to add you as a Dalmatian Admin. This will include changing this file https://github.com/dxw/dalmatian-config/blob/master/dalmatian.yml#L15
2. Sign into the AWS web console https://eu-west-2.console.aws.amazon.com. The credentials will look similar to:
    ```
    IAM User: dalmatian-<your name>-admin
    Account: dalmatian-dxw
    ```
3. [Create yourself an access key here](https://console.aws.amazon.com/iam/home?region=eu-west-2#/security_credentials) and copy the values into your local ~/.aws/credentials file:
  ```
  # Dalmatian
  [dalmatian]
  aws_access_key_id =
  aws_secret_access_key =
  ```
4. Copy the following configuration into your ~/.aws/config:
    ```
    [profile dalmatian]
    role_arn = arn:aws:iam::511700466171:role/dalmatian-admin
    source_profile = mfa
    region=eu-west-2
    cli_follow_urlparam=false
    ```
5. [Follow the guidance of Dalmatian Tools to set up an MFA code](https://github.com/dxw/dalmatian-tools/). This should add more information into ~/.aws/credentials and allow you to start using the AWS API

## Getting started

Run the setup script:

```bash
script/setup
```

Run the tests:

```bash
script/test
```

Start the server:

```bash
script/server
```

Start a console:

```bash
script/console
```

## Static code analysis

Run [Brakeman](https://brakemanscanner.org/) to highlight any security vulnerabilities:
```bash
brakeman
```

To pipe the results to a file:
```bash
brakeman -o report.text
```

## Making changes

When making a change, update the [changelog](CHANGELOG.md) using the
[Keep a Changelog 1.0.0](https://keepachangelog.com/en/1.0.0/) format. Pull
requests should not be merged before any relevant updates are made.

## Releasing changes

When making a new release, update the [changelog](CHANGELOG.md) in the release
pull request.

## Architecture decision records

We use ADRs to document architectural decisions that we make. They can be found
in doc/architecture/decisions and contributed to with the
[adr-tools](https://github.com/npryce/adr-tools).

## Managing environment variables

We use [Dotenv](https://github.com/bkeepers/dotenv) to manage our environment variables locally.

The repository will include safe defaults for development in `/.env.example` and for test in `/.env.test`. We use 'example' instead of 'development' (from the Dotenv docs) to be consistent with current dxw conventions and to make it more explicit that these values are not to be committed.

To manage sensitive environment variables:

1. Add the new key and safe default value to the `/.env.example` file eg. `ROLLBAR_TOKEN=ROLLBAR_TOKEN`
2. Add the new key and real value to your local `/.env.development.local` file, which should never be checked into Git. This file will look something like `ROLLBAR_TOKEN=123456789`

## Access

TODO: Where can people find the service and the different environments?

## Source

This repository was bootstrapped from
[dxw's `rails-template`](https://github.com/dxw/rails-template).
