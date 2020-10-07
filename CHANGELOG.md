# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog 1.0.0].

## [Unreleased]

- all infrastructures are listed
- individual infrastructures can be viewed
- fetch and display environment variables for each service from AWS ParameterStore
- users can add a new environment variable
- users can update an existing environment variable
- users can delete existing environment variables
- environment variables are displayed on their own tab
- infrastructure list is not longer full width
- users can see infrastructure variables as well as environment variables for a given infrastructure
- users can create and update infrastructure variables
- users can delete infrastructure variables
- users are shown a warning about the effect of using any action within the service
- secret environment variables are hidden by default
- secret environment variables can be shown and hidden individually by clicking the cell
- infrastructure variables are shown for every infrastructure (not just those running on the core AWS account)
- multiple environment variables can be added at once with a .env file
- users can see build information in the form of AWS CodePipelines
- users can execute new code pipeline runs to deploy apps
- users can see the code pipeline for Dalmatian Core
- users can execute a new pipeline run for Dalmatian Core

[unreleased]: TODO
[keep a changelog 1.0.0]: https://keepachangelog.com/en/1.0.0/
