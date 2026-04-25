import { Stack } from "aws-cdk-lib";
import { NagSuppressions } from "cdk-nag";

export function addKnownSuppressions(stack: Stack): void {
  NagSuppressions.addStackSuppressions(stack, [
    {
      id: "AwsSolutions-IAM4",
      reason: "Managed policies acceptable for CI/CD service role — scoped by trust policy",
    },
    {
      id: "AwsSolutions-L1",
      reason: "Lambda runtime pinned to project-standard Python 3.12 — not latest",
    },
  ]);
}
