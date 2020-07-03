![This is a damn fine cup of coffee.](damn_fine_coffee.gif)
> "This is a damn fine cup of coffee."
-- Agent Cooper

Web analytics software so simple it runs on your phone.

## What?

This is a web analytics tool that runs on Android devices. Its like Google Analytics, minus the ad-peddling Evil.

In short, you add a line of Javascript calling your phone. Annonymized visits will be stored in your phone and viewable in a friendly way, accessible through a web page you can open in your local network.

## How this thing works

![diagram](diagram.png)
This is really just a glorified log viewer.

When someone visits your website, Javascript hits the `/damn_fine_coffee` endpoint[1] and Nginx creates a log entry (for any other endpoint, it won't[2]).

Every day at around midnight, a cron job processes the day's logs leveraging [Nginx log rotation](https://www.nginx.com/resources/wiki/start/topics/examples/logrotation/). Invalid logs (requests from non-monitored domains) are discarded, IPs are annonymized using MD5 hexdigest, and high-level geo info is collected from the IPs. Each valid log entry becomes a row of the `hits` table.

The `hits` table is then used by the `viewer` app and we get the final dashboards, charts etc.

## Requirements

1. An Android phone running [Termux](https://termux.com/) (recommended: set up [SSH remote access](https://wiki.termux.com/wiki/Remote_Access)). Remember to press "Acquire wakelock" on Termux as well.
2. A port forwarding rule in your router redirecting TCP port `443` to port `8433` on your phone's local IP (port `80` to `8080` if you don't want SSL)

Optional:
1. A domain with verified SSL leading to your phone (see [guide](https://lbrito1.github.io/blog/2020/06/free_https_home_server.html)) if you want/need SSL
2. A [Mapbox](https://www.mapbox.com/) account if you want map charts

## Installation guide

In your Android phone:
1. Clone this repository and `cd` into it;
2. Create your `.env` config file with `cp -n .env.template .env` and add your passwords, domains etc;
3. Copy your SSL keys to your phone (read About SSL below for more information);
4. Run the setup script: `bash bin/setup.sh`;

In the website you want to monitor, add a call to your phone:
```html
<script> fetch("https://my-android-domain/damn_fine_coffee"); </script>
```

All set! Now if you access your monitored website from outside your network (e.g. with [Pingdom](https://tools.pingdom.com/)) and run `tail -f log/nginx.access.log` on your phone, you should see the request getting logged.

Next step is to manually run the compiler job (`./bin/compile_logs.sh`), which will send that request to the DB (by default it is ran daily at 23:59 -- just run it manually once to see if everything is OK).

Now go to `http://<your-phones-local-ip>:3000` and you should see that request in the dashboard! 🎉

![Screenshot of the app running locally, a few charts and a map are shown](screenshot.png)

#### About SSL

This project assumes you have a valid SSL certificate, but it should work fine without one.

If you don't want to use SSL, just comment out the SSL-related parts of `nginx.conf`.

If you want SSL, put your SSL keys somewhere in your phone and update `nginx.conf` if necessary with that path:
```
ssl_certificate /data/data/com.termux/files/home/fullchain.pem;
ssl_certificate_key /data/data/com.termux/files/home/privkey.pem;
```
Then reload nginx with `nginx -s reload`.

## Notes

[1] Most crawlers/bots won't magically know about the `/damn_fine_coffee` endpoint without the help of a sitemap or something, so hopefully so you won't get random traffic being logged.

[2] The web is full of crawlers, mostly hitting `/`, but also `/tp-link`, `/admin` etc. We want to just ignore those.
