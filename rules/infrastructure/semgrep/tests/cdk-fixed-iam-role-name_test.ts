import * as iam from 'aws-cdk-lib/aws-iam';
import { Role } from 'aws-cdk-lib/aws-iam';

// ruleid: cdk-fixed-iam-role-name
const fixed = new iam.Role(this, 'R1', { roleName: 'cleanup-lambda-role', assumedBy: principal });
// ruleid: cdk-fixed-iam-role-name
const fixedBare = new Role(this, 'R2', { roleName: 'cleanup-lambda-role', assumedBy: principal });
// ruleid: cdk-fixed-iam-role-name
const fixedBuilder = builder.overrideRoleName('cleanup-lambda-role');
// ok: cdk-fixed-iam-role-name
const generated = new iam.Role(this, 'R3', { assumedBy: principal });
// ok: cdk-fixed-iam-role-name
const regional = new iam.Role(this, 'R4', { roleName: `cleanup-${this.region}`, assumedBy: principal });
