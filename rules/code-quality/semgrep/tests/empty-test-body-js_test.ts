// ruleid: empty-test-body-js
test('SQS Queue Created', () => {
    // const template = Template.fromStack(stack);
});
// ruleid: empty-test-body-js
it('does nothing', async () => {});
// ok: empty-test-body-js
test('creates the queue', () => {
    expect(template.resourceCountIs('AWS::SQS::Queue', 1)).toBeUndefined();
});
// ok: empty-test-body-js
it('rejects bad input', async () => {
    await expect(handler({})).rejects.toThrow();
});
