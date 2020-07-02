![Screenshot of the app running locally, a few charts and a map are shown](screenshot.png)

> "This is a damn fine cup of coffee."
-- Agent Cooper

Web analytics software so simple it runs on your phone.

## What?

This is a web analytics tool that runs on Android devices. It registers visitors to any site you include the Javascript snippet in, and displays that data in a friendly way, accessible through a web page you can view in your local network. Its like Google Analytics, minus the ad-peddling Evil.

## How this thing works

This is really just a glorified log viewer.

If someone visits your monitored website, Javascript will hit the `/damn_fine_coffee` endpoint[1] and Nginx will create a log entry (for any other endpoint, it won't[2]).

Every day at midnight, a cron job processes the day's logs leveraging [Nginx log rotation](https://www.nginx.com/resources/wiki/start/topics/examples/logrotation/). Invalid logs (logs from sources other than the monitored domain) are discarded, IPs are annonymized using MD5 hexdigest, and high-level geo info is collected from the IPs. Each valid log entry becomes a row of the `hits` table.

The `hits` table is then used by the `viewer` app and we get the final dashboards, charts etc.

## Requirements

1. An Android phone running [Termux](https://termux.com/) (recommended: set up [SSH remote access](https://wiki.termux.com/wiki/Remote_Access))
2. A port forwarding rule in your router redirecting TCP port `443` to port `8433` on your phone's local IP (port `80` to `8080` if you don't want SSL)

Optional:
1. A domain with verified SSL leading to your phone (see [guide](https://lbrito1.github.io/blog/2020/06/free_https_home_server.html)) if you want/need SSL
2. A [Mapbox](https://www.mapbox.com/) account if you want map charts

## Installation guide

In your Android phone:
1. Clone this repository and `cd` into it
2. Create your `.env` config file with `cp -n .env.template .env` and add your passwords, domains etc
3. Run the setup script: `bash bin/setup.sh`

In the website you want to monitor, add a call to your phone:
```html
  <script>
    fetch("https://my-android-domain/damn_fine_coffee");
  </script>
```

15. Test if everything is working by hitting your monitored website from outside your network (e.g. with [Pingdom](https://tools.pingdom.com/)) and looking at the logs (`tail -f log/nginx.access.log`). If the request appears in the log, proceed to manually run the compiler job (`./bin/compile_logs.sh`), and finally check if the record is in Postgres (run `./bin/db.rb` to get a REPL database session, then write `puts Hits.last` to see the latest row).

### Optionals

#### SSL
If you want SSL, put your SSL keys somewhere in your phone, update `nginx.conf` if necessary with that path:
```
ssl_certificate /data/data/com.termux/files/home/fullchain.pem;
ssl_certificate_key /data/data/com.termux/files/home/privkey.pem;
```
And reload nginx with `nginx -s reload`.


## Usage

Set up the viewer app:
```bash
$ cd viewer
$ bundle
$ ./bin/run.sh
```

Then your data by navigating to `https://<your-android-local-ip>:3000`.

If you want to use map charts, add your Mapbox access token to `./viewer/.env`.

## TODOs
- [ ] Package this to make installation easier
- [ ] Clean up old logs

## Notes

[1] Most crawlers/bots won't magically know about the `/damn_fine_coffee` endpoint without the help of a sitemap or something, so hopefully so you won't get random traffic being logged.
[2] The web is full of crawlers, mostly hitting `/`, but also `/tp-link`, `/admin` etc. We want to just ignore those.
