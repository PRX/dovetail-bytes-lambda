# Dovetail Bytes Lambda

Log bytes downloaded by a CloudFront CDN

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

- `le` - "listener episode" assigned by the Dovetail redirect. Normally a hash of the request's User-Agent, IP address, and episode guid. But can really be any unique identifier for "this listener downloading this episode".
- `start` - first byte sent to the user (0-indexed)
- `end` - last byte sent to the user (0-indexed)
- `total` - byte size of the _entire_ file (not just the sent range of bytes)
- `digest` - unique string id for this arrangement of ad/original mp3 files provided by Dovetail
- `region` - AWS region the edge lambda is running in

# Developing

To get started, first install dev dependencies with `yarn`.  Then run `yarn test`.  End of list!

Or to use docker, just run `docker-compose build` and `docker-compose run test`.

# License

[AGPL License](https://www.gnu.org/licenses/agpl-3.0.html)
