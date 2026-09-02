import * as ssm from 'aws-cdk-lib/aws-ssm';
import { CfnDocument } from 'aws-cdk-lib/aws-ssm';

// ruleid: cdk-ssm-document-default-update-method
const replaced = new ssm.CfnDocument(this, 'Doc1', { name: 'runbook', content: {} });
// ruleid: cdk-ssm-document-default-update-method
const replacedBare = new CfnDocument(this, 'Doc2', { name: 'runbook', content: {} });
// ok: cdk-ssm-document-default-update-method
const versioned = new ssm.CfnDocument(this, 'Doc3', { name: 'runbook', content: {}, updateMethod: 'NewVersion' });
