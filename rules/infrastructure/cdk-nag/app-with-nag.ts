import { App, Aspects } from "aws-cdk-lib";
import { AwsSolutionsChecks } from "cdk-nag";
import { MyStack } from "../lib/my-stack";

const app = new App();
new MyStack(app, "MyStack");

Aspects.of(app).add(new AwsSolutionsChecks({ verbose: true }));

app.synth();
