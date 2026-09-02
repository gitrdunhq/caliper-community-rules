import * as path from 'path';
import { Code } from 'aws-cdk-lib/aws-lambda';
import * as lambda from 'aws-cdk-lib/aws-lambda';

// ruleid: cdk-code-fromasset-relative-literal
const relative = Code.fromAsset('lambda');
// ruleid: cdk-code-fromasset-relative-literal
const relativeNs = lambda.Code.fromAsset('./lambda');
// ok: cdk-code-fromasset-relative-literal
const anchored = Code.fromAsset(path.join(__dirname, '..', 'lambda'));
// ok: cdk-code-fromasset-relative-literal
const absolute = lambda.Code.fromAsset('/opt/build/lambda');
