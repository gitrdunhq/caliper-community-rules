import * as cr from 'aws-cdk-lib/custom-resources';

// ruleid: cdk-custom-resource-oncreate-without-onupdate
const shareOnce = new cr.AwsCustomResource(this, 'Share', {
    onCreate: { service: 'SSM', action: 'modifyDocumentPermission', parameters: {} },
    onDelete: { service: 'SSM', action: 'modifyDocumentPermission', parameters: {} },
    policy: cr.AwsCustomResourcePolicy.fromSdkCalls({ resources: ['*'] }),
});

// ok: cdk-custom-resource-oncreate-without-onupdate
const shareAlways = new cr.AwsCustomResource(this, 'ShareUpdated', {
    onCreate: { service: 'SSM', action: 'modifyDocumentPermission', parameters: {} },
    onUpdate: { service: 'SSM', action: 'modifyDocumentPermission', parameters: {} },
    onDelete: { service: 'SSM', action: 'modifyDocumentPermission', parameters: {} },
});
