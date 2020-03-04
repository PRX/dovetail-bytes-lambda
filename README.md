# Dovetail Bytes Lambda

Log bytes downloaded by a CloudFront CDN.  Used in compliance with the [IAB 2.0 Podcasting Standard](https://www.iab.com/wp-content/uploads/2017/12/Podcast_Measurement_v2-Final-Dec2017.pdf) - so we know exactly which bytes of an mp3 file were sent to a listener.

As stated in the [AWS Docs](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html), normal CloudFront access logs are not "a complete accounting of all request". The edge lambda provides a more accurate picture of the CDN traffic, when processed via a Kinesis stream or some other means.

# Description

This edge lambda is intended to sit behind a CloudFront distribution, executing on every [viewer response](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-cloudfront-trigger-events.html).  If the request was a successful Dovetail-type request (containing a listener episode `?le=1234`), the number and location of bytes actually sent to the client will be logged to CloudWatch.

The logged data has the following JSON format:

```json
GET https://my.cloudfront.cdn/1234/the-digest/filename.mp3?le=the-listener-episode
{
  "le": "the-listener-episode",
  "start":0,
  "end":10,
  "total":316645,
  "digest":"the-digest",
  "region":"us-east-2",
}
```

- `le` - "listener episode" assigned by the Dovetail redirect. Normally a hash of the request's User-Agent, IP address, and episode guid. But can really be any unique identifier for "this listener downloading this episode". Can also be null/blank for bots or other traffic we don't need to record.
- `start` - first byte sent to the user (0-indexed)
- `end` - last byte sent to the user (0-indexed)
- `total` - byte size of the _entire_ file (not just the sent range of bytes)
- `digest` - unique string id for this arrangement of ad/original mp3 files provided by Dovetail
- `region` - AWS region the edge lambda is running in

# Dataflow

A listener makes the initial request to [Dovetail](https://github.com/PRX/internal/blob/master/devops/dovetail.md), which then redirects the user to this CDN with an assigned `digest` and `listener-episode`.

This lambda logs the listener episode and exactly which bytes of the mp3 were downloaded.

The resulting CloudWatch Logs are shipped over AWS Kinesis to the [dovetail-counts-lambda](https://github.com/PRX/dovetail-counts-lambda). The bytes downloaded for each listener-episode are accumulated in Redis, until they pass the IAB 2.0 threshold to count as downloads / ad-impressions.

# Developing

To get started, first install dev dependencies with `yarn`.  Then run `yarn test`.  End of list!

Or to use docker, just run `docker-compose build` and `docker-compose run test`.

# License

[AGPL License](https://www.gnu.org/licenses/agpl-3.0.html)
