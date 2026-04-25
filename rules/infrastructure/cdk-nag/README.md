# cdk-nag Rules

CDK security configurations for the eedom `cdk-nag` plugin. These are [cdk-nag](https://github.com/cdklabs/cdk-nag) pack configurations and suppression examples.

## How to use

Add cdk-nag to your CDK app's dependencies and configure it in your app entry point. The eedom cdk-nag plugin runs `cdk synth` then scans the output with cfn_nag — these examples show how to integrate cdk-nag directly into your CDK stack for earlier feedback.

## Included examples

| File | What it does |
|------|-------------|
| `app-with-nag.ts` | CDK app entry point with AwsSolutions pack enabled |
| `nag-suppressions.ts` | Example suppression patterns for known acceptable risks |
| `cdk-nag.config.yaml` | eedom config for cdk-nag plugin settings |
