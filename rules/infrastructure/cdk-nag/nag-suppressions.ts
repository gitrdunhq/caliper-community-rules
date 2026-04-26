import { Stack } from "aws-cdk-lib";
import { NagSuppressions } from "cdk-nag";

export function addKnownSuppressions(stack: Stack): void {
  NagSuppressions.addStackSuppressions(stack, [
    {
      id: "AwsSolutions-IAM4",
      reason:
        "AmazonS3ReadOnlyAccess managed policy used for CI/CD artifact-reader role — " +
        "grants read-only S3 access, no mutation capability",
    },
    {
      id: "AwsSolutions-L1",
      reason: "Lambda runtime pinned to project-standard Python 3.12 — not latest",
    },
  ]);
}
