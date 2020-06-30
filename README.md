![Agent Cooper drinking coffee](damn_fine_coffee.gif)
> "This is a damn fine cup of coffee."
-- Agent Cooper

Web analytics software so simple it runs on your phone.

## Requirements

1. An Android phone running [Termux](https://termux.com/) (recommended: set up [SSH remote access](https://wiki.termux.com/wiki/Remote_Access))
2. A domain with verified SSL leading to your phone (see [guide](https://lbrito1.github.io/blog/2020/06/free_https_home_server.html))

## Installation guide

In your Android phone:
1. Create a port forwarding rule in your router redirecting requests to TCP port `443` to your phone's port `8433`
2. Install Nginx, Postgres, Ruby and Bundler:
```bash
$ pkg update
$ pkg install nginx      # tested with 1.17.8
$ pkg install postgresql # tested with 12.3
$ pkg install ruby       # tested with 2.6.5
$ gem install bundler
```
3. Put your SSL keys somewhere in your phone; update `nginx.conf` if necessary with the corrrect path:
```
ssl_certificate /data/data/com.termux/files/home/fullchain.pem;
ssl_certificate_key /data/data/com.termux/files/home/privkey.pem;
```
4. Clone this repository
5. Give execution permission to the helper scripts:
```bash
$ chmod +x ./bin/*
$ chmod +x ./viewer/bin/*
```
6. Start nginx and postgres:
```bash
$ ./bin/run.sh
```
7. Create a password for your database and update `viewer/.env` with it:
```bash
ANDROID_DATABASE_PASSWORD=replace_me_with_real_key
```
8. Create the `android_analytics` Postgres user with the same password you chose in the previous step:
```bash
$ createuser --interactive --pwprompt
...
```
9. Create the `hits` database:
```bash
bundle exec ruby ./tasks/run_migrations.rb
```
10. Create the `blazer` databases (used for data visualization):
```
bundle exec viewer/rails db:setup
```
11. Fill the `VALID_DOMAINS` constant in `app/models/hits.rb` with the domains you expect to monitor
12. Add a call to your phone in the web page you're monitoring:
```html
  <script>
    fetch("https://my-android-domain/damn_fine_coffee");
  </script>
```
13. Add `crond` to your `bash_profile` or `bashrc`:
```bash
if ! pgrep -f "crond" >/dev/null; then
echo "[Starting crond...]" && crond && echo "[OK]"
else
echo "[crond is running]"
fi
```
14. Add the compiler job to your crontab:
```bash
crontab -e

# Add this line:
0 0 * * * /data/data/com.termux/files/home/android-analytics/bin/compile_logs.sh
```
15. Test if everything is working by hitting your monitored website from outside your network (e.g. with [Pingdom](https://tools.pingdom.com/)) and looking at the logs (`tail -f log/nginx.access.log`). If the request appears in the log, proceed to manually run the compiler job (`./bin/compile_logs.sh`), and finally check if the record is in Postgres (run `./bin/db.rb` to get a REPL database session, then write `puts Hits.last` to see the latest row).
16. Set up the viewer app:
```bash
cd viewer
bundle
./bin/run.sh
```
17. Check your data by navigating to `https://<your-android-local-ip>:3000`.

## How this thing works

This is really just a glorified log viewer.

If someone visits your monitored website, Javascript will hit the `/damn_fine_coffee` endpoint[1] and Nginx will create a log entry (for any other endpoint, it won't[2]).

Every day at midnight, a cron job processes the day's logs leveraging [Nginx log rotation](https://www.nginx.com/resources/wiki/start/topics/examples/logrotation/). Invalid logs (logs from sources other than the monitored domain) are discareded, IPs are annonymized using MD5 hexdigest, and high-level geo info is collected from the IPs. Each valid log entry becomes a row of the `hits` table.

The `hits` table is then used by the `viewer` app and we get the final dashboards, charts etc.

## TODOs
- [ ] Package this to make installation easier
- [ ] Clean up old logs

## Notes

[1] Most crawlers/bots won't magically know about the `/damn_fine_coffee` endpoint without the help of a sitemap or something, so hopefully so you won't get random traffic being logged.
[2] The web is full of crawlers, mostly hitting `/`, but also `/tp-link`, `/admin` etc. We want to just ignore those.
